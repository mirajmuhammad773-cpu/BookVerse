import 'package:bookverse/Models/PlansModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class PlanRepository {
  // ============================================================
  // FIRESTORE
  // ============================================================

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ============================================================
  // PLANS COLLECTION
  // ============================================================

  CollectionReference<Map<String, dynamic>>
      get _plansCollection {
    return _firestore.collection('plans');
  }

  // ============================================================
  // GET ACTIVE PLANS
  // ============================================================

  Future<List<PlanModel>> getPlans() async {
    try {
      final snapshot = await _plansCollection
          .where(
            'isActive',
            isEqualTo: true,
          )
          .get();

      final plans = snapshot.docs
          .map(
            (document) =>
                PlanModel.fromDocument(document),
          )
          .toList();

      // --------------------------------------------------------
      // SORT
      // Free → Premium → Pro
      // --------------------------------------------------------

      plans.sort(
        (a, b) {
          return _planOrder(
            a.name,
          ).compareTo(
            _planOrder(
              b.name,
            ),
          );
        },
      );

      return plans;
    } catch (e) {
      throw Exception(
        'Failed to load plans: ${e.toString()}',
      );
    }
  }

  // ============================================================
  // GET ALL PLANS
  // ============================================================

  Future<List<PlanModel>> getAllPlans() async {
    try {
      final snapshot =
          await _plansCollection.get();

      final plans = snapshot.docs
          .map(
            (document) =>
                PlanModel.fromDocument(document),
          )
          .toList();

      plans.sort(
        (a, b) {
          return _planOrder(
            a.name,
          ).compareTo(
            _planOrder(
              b.name,
            ),
          );
        },
      );

      return plans;
    } catch (e) {
      throw Exception(
        'Failed to load all plans: ${e.toString()}',
      );
    }
  }

  // ============================================================
  // GET SINGLE PLAN
  // ============================================================

  Future<PlanModel?> getPlan(
    String planId,
  ) async {
    try {
      final document =
          await _plansCollection
              .doc(planId)
              .get();

      if (!document.exists) {
        return null;
      }

      return PlanModel.fromDocument(
        document,
      );
    } catch (e) {
      throw Exception(
        'Failed to load plan: ${e.toString()}',
      );
    }
  }

  // ============================================================
  // GET PLAN PRICE
  // ============================================================
  //
  // monthly = true  → monthlyPrice
  // monthly = false → yearlyPrice
  //
  // Backend/payment layer bhi isi concept ko use karega.
  //
  // ============================================================

  Future<double> getPlanPrice({
    required String planId,
    required bool monthly,
  }) async {
    try {
      final plan =
          await getPlan(planId);

      if (plan == null) {
        throw Exception(
          'Plan not found.',
        );
      }

      if (!plan.isActive) {
        throw Exception(
          'This plan is not available.',
        );
      }

      return monthly
          ? plan.monthlyPrice
          : plan.yearlyPrice;
    } catch (e) {
      throw Exception(
        'Failed to get plan price: ${e.toString()}',
      );
    }
  }

  // ============================================================
  // WATCH ACTIVE PLANS
  // ============================================================

  Stream<List<PlanModel>>
      watchActivePlans() {
    return _plansCollection
        .where(
          'isActive',
          isEqualTo: true,
        )
        .snapshots()
        .map(
          (snapshot) {
            final plans = snapshot.docs
                .map(
                  (document) =>
                      PlanModel.fromDocument(
                    document,
                  ),
                )
                .toList();

            plans.sort(
              (a, b) {
                return _planOrder(
                  a.name,
                ).compareTo(
                  _planOrder(
                    b.name,
                  ),
                );
              },
            );

            return plans;
          },
        );
  }

  // ============================================================
  // ADD PLAN
  // ============================================================

  Future<String> addPlan(
    PlanModel plan,
  ) async {
    try {
      final document =
          _plansCollection.doc();

      final planWithId =
          plan.copyWith(
        id: document.id,
      );

      await document.set(
        planWithId.toMap(),
      );

      return document.id;
    } catch (e) {
      throw Exception(
        'Failed to add plan: ${e.toString()}',
      );
    }
  }

  // ============================================================
  // CREATE PLAN WITH SPECIFIC ID
  // ============================================================
  //
  // Is method se aap:
  //
  // premium
  // pro
  // free
  //
  // jaise fixed document IDs bana sakte hain.
  //
  // ============================================================

  Future<void> createPlanWithId({
    required String planId,
    required PlanModel plan,
  }) async {
    try {
      await _plansCollection
          .doc(planId)
          .set(
        plan.toMap(),
      );
    } catch (e) {
      throw Exception(
        'Failed to create plan: ${e.toString()}',
      );
    }
  }

  // ============================================================
  // UPDATE PLAN
  // ============================================================

  Future<void> updatePlan(
    PlanModel plan,
  ) async {
    try {
      await _plansCollection
          .doc(plan.id)
          .update(
        {
          ...plan.toMap(),
          'updatedAt':
              FieldValue.serverTimestamp(),
        },
      );
    } catch (e) {
      throw Exception(
        'Failed to update plan: ${e.toString()}',
      );
    }
  }

  // ============================================================
  // UPDATE MONTHLY PRICE
  // ============================================================

  Future<void> updateMonthlyPrice({
    required String planId,
    required double price,
  }) async {
    try {
      await _plansCollection
          .doc(planId)
          .update({
        'monthlyPrice': price,
        'updatedAt':
            FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception(
        'Failed to update monthly price: ${e.toString()}',
      );
    }
  }

  // ============================================================
  // UPDATE YEARLY PRICE
  // ============================================================

  Future<void> updateYearlyPrice({
    required String planId,
    required double price,
  }) async {
    try {
      await _plansCollection
          .doc(planId)
          .update({
        'yearlyPrice': price,
        'updatedAt':
            FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception(
        'Failed to update yearly price: ${e.toString()}',
      );
    }
  }

  // ============================================================
  // UPDATE FEATURES
  // ============================================================

  Future<void> updateFeatures({
    required String planId,
    required List<String> monthlyFeatures,
    required List<String> yearlyFeatures,
  }) async {
    try {
      await _plansCollection
          .doc(planId)
          .update({
        'monthlyFeatures':
            monthlyFeatures,
        'yearlyFeatures':
            yearlyFeatures,
        'updatedAt':
            FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception(
        'Failed to update plan features: ${e.toString()}',
      );
    }
  }

  // ============================================================
  // ACTIVATE PLAN
  // ============================================================

  Future<void> activatePlan(
    String planId,
  ) async {
    try {
      await _plansCollection
          .doc(planId)
          .update({
        'isActive': true,
        'updatedAt':
            FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception(
        'Failed to activate plan: ${e.toString()}',
      );
    }
  }

  // ============================================================
  // DEACTIVATE PLAN
  // ============================================================

  Future<void> deactivatePlan(
    String planId,
  ) async {
    try {
      await _plansCollection
          .doc(planId)
          .update({
        'isActive': false,
        'updatedAt':
            FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception(
        'Failed to deactivate plan: ${e.toString()}',
      );
    }
  }

  // ============================================================
  // DELETE PLAN
  // ============================================================

  Future<void> deletePlan(
    String planId,
  ) async {
    try {
      await _plansCollection
          .doc(planId)
          .delete();
    } catch (e) {
      throw Exception(
        'Failed to delete plan: ${e.toString()}',
      );
    }
  }

  // ============================================================
  // PLAN ORDER
  // ============================================================

  int _planOrder(
    String name,
  ) {
    switch (name.toLowerCase()) {
      case 'free':
        return 0;

      case 'premium':
        return 1;

      case 'pro':
        return 2;

      default:
        return 99;
    }
  }
}