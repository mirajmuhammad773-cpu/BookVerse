const functions = require("firebase-functions");
const admin = require("firebase-admin");
const Stripe = require("stripe");

admin.initializeApp();
const db = admin.firestore();
const STRIPE_API_VERSION = "2024-06-20";

// ------------------------------------------------------------------
// createPaymentIntent → PaymentRepository.createStripePaymentIntent() isay call karta hai
// ------------------------------------------------------------------
exports.createPaymentIntent = functions
  .runWith({ secrets: ["STRIPE_SECRET_KEY"] })
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Pehle login karein.");
    }

    const stripe = Stripe(process.env.STRIPE_SECRET_KEY, { apiVersion: STRIPE_API_VERSION });
    const uid = context.auth.uid;
    const { paymentId, planId, planName, billingCycle, amount, currency } = data;

    if (!paymentId || !planId || !amount) {
      throw new functions.https.HttpsError("invalid-argument", "Zaroori fields missing hain.");
    }

    // Testing ke liye client ka amount use ho raha hai.
    // Production mein "plans" collection se planId ke against price server-side lookup karein.
    const amountInCents = Math.round(amount * 100);

    const userRef = db.collection("users").doc(uid);
    const userSnap = await userRef.get();
    let stripeCustomerId = userSnap.data()?.stripeCustomerId;

    if (!stripeCustomerId) {
      const customer = await stripe.customers.create({ metadata: { firebaseUID: uid } });
      stripeCustomerId = customer.id;
      await userRef.set({ stripeCustomerId }, { merge: true });
    }

    const ephemeralKey = await stripe.ephemeralKeys.create(
      { customer: stripeCustomerId },
      { apiVersion: STRIPE_API_VERSION }
    );

    const paymentIntent = await stripe.paymentIntents.create({
      amount: amountInCents,
      currency: (currency || "usd").toLowerCase(),
      customer: stripeCustomerId,
      metadata: { uid, paymentId, planId, billingCycle: billingCycle || "monthly" },
      automatic_payment_methods: { enabled: true },
    });

    await db.collection("payments").doc(paymentId).update({
      paymentIntentId: paymentIntent.id,
      stripeCustomerId,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      clientSecret: paymentIntent.client_secret,
      customerId: stripeCustomerId,
      ephemeralKey: ephemeralKey.secret,
    };
  });

// ------------------------------------------------------------------
// stripeWebhook → Stripe khud call karega. YAHAN plan ACTIVATE hota hai (source of truth)
// ------------------------------------------------------------------
exports.stripeWebhook = functions
  .runWith({ secrets: ["STRIPE_SECRET_KEY", "STRIPE_WEBHOOK_SECRET"] })
  .https.onRequest(async (req, res) => {
    const stripe = Stripe(process.env.STRIPE_SECRET_KEY, { apiVersion: STRIPE_API_VERSION });
    const sig = req.headers["stripe-signature"];

    let event;
    try {
      event = stripe.webhooks.constructEvent(req.rawBody, sig, process.env.STRIPE_WEBHOOK_SECRET);
    } catch (err) {
      console.error("Webhook signature ghalat hai:", err.message);
      return res.status(400).send(`Webhook Error: ${err.message}`);
    }

    if (event.type === "payment_intent.succeeded") {
      const pi = event.data.object;
      const { uid, paymentId, planId, billingCycle } = pi.metadata;

      const paymentRef = db.collection("payments").doc(paymentId);
      const paymentSnap = await paymentRef.get();
      const planName = paymentSnap.data()?.planName || planId;

      const now = new Date();
      const expiry = new Date(now);
      expiry.setDate(expiry.getDate() + (billingCycle === "yearly" ? 365 : 30));

      const batch = db.batch();

      batch.update(paymentRef, {
        status: "succeeded",
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      batch.set(
        db.collection("users").doc(uid),
        {
          activePlanId: planId,
          activePlanName: planName,
          billingCycle: billingCycle || "monthly",
          planActivatedAt: admin.firestore.FieldValue.serverTimestamp(),
          planExpiresAt: admin.firestore.Timestamp.fromDate(expiry),
        },
        { merge: true }
      );

      await batch.commit();
    }

    if (event.type === "payment_intent.payment_failed") {
      const { paymentId } = event.data.object.metadata;
      if (paymentId) {
        await db.collection("payments").doc(paymentId).update({
          status: "failed",
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
    }

    res.json({ received: true });
  });