import 'package:BookVerse/Repository/Book-Repository.dart';

// ============================================================
// VIEW MODELS
// ============================================================

import 'package:BookVerse/ViewModels/AchievementProvider.dart';
import 'package:BookVerse/ViewModels/Book-view-model.dart';
import 'package:BookVerse/ViewModels/BookDownloadProvider.dart';
import 'package:BookVerse/ViewModels/FavoriteBookProvider.dart';
import 'package:BookVerse/ViewModels/FontProvider.dart';
import 'package:BookVerse/ViewModels/BrightnessProvider.dart';
import 'package:BookVerse/ViewModels/NotificationProvider.dart';
import 'package:BookVerse/ViewModels/PlansProvider.dart';
import 'package:BookVerse/ViewModels/ReadingGoalProvider.dart';
import 'package:BookVerse/ViewModels/ReadingHistoryProvider.dart';
import 'package:BookVerse/ViewModels/TaotoTurnpageProvider.dart';
import 'package:BookVerse/ViewModels/UserProvider.dart';

// ============================================================
// PAYMENT PROVIDER
// ============================================================

import 'package:BookVerse/ViewModels/PaymentProvider.dart';

// ============================================================
// SCREENS
// ============================================================

import 'package:BookVerse/Views/SplashScreen.dart';

// ============================================================
// FLUTTER / FIREBASE / STRIPE
// ============================================================

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';

void main() async {
  // ==========================================================
  // FLUTTER INITIALIZATION
  // ==========================================================

  WidgetsFlutterBinding.ensureInitialized();

  // ==========================================================
  // FIREBASE
  // ==========================================================

  await Firebase.initializeApp();

  // ==========================================================
  // STRIPE
  // ==========================================================

  Stripe.publishableKey =
      'pk_test_51U5hLcGlv6wZRQSOpP5hyPSsihYL1D6wJatkxE3FsDma1gBZikvql6tCvOIh40sdw2tuHxJlCXBRFPQa1XlmLBVi00GWxpD1aB';

  await Stripe.instance.applySettings();

  // ==========================================================
  // RUN APP
  // ==========================================================

  runApp(
    MultiProvider(
      providers: [
        // TaptoTurnPageProvider 

        ChangeNotifierProvider(
          create: (_) => TapToTurnPageProvider(),
        ),

        // NotificationProvider
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(),
        ),
        
        // ======================================================
        // FONT PROVIDER
        // ======================================================

        ChangeNotifierProvider(
          create: (_) => FontProvider()
            ..loadFontPreference(),
        ),

        // ======================================================
        // BRIGHTNESS PROVIDER
        // ======================================================

        ChangeNotifierProvider(
          create: (_) => BrightnessProvider()
            ..loadBrightnessPreference(),
        ),

        // ======================================================
        // PLANS PROVIDER
        // ======================================================

        ChangeNotifierProvider(
          create: (_) => PlanProvider(),
        ),

        // ======================================================
        // PAYMENT PROVIDER
        // ======================================================

        ChangeNotifierProvider(
          create: (_) => PaymentProvider(),
        ),

        // ======================================================
        // DOWNLOAD PROVIDER
        // ======================================================

        ChangeNotifierProvider(
          create: (_) => DownloadProvider(),
        ),

        // ======================================================
        // READING HISTORY PROVIDER
        // ======================================================

        ChangeNotifierProvider(
          create: (_) => ReadingHistoryProvider(),
        ),

        // ======================================================
        // READING GOAL PROVIDER
        // ======================================================

        ChangeNotifierProvider(
          create: (_) => ReadingGoalProvider(),
        ),

        // ======================================================
        // USER PROVIDER
        // ======================================================

        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(),
        ),

        // ======================================================
        // BOOK PROVIDER
        // ======================================================

        ChangeNotifierProvider(
          create: (_) => BookViewModel(
            repository: BookRepository(),
          ),
        ),

        // ======================================================
        // ACHIEVEMENT PROVIDER
        // ======================================================

        ChangeNotifierProvider(
          create: (_) => AchievementProvider(),
        ),

        // ======================================================
        // FAVOURITE BOOKS PROVIDER
        // ======================================================

        ChangeNotifierProvider(
          create: (_) => FavouriteBooksProvider(),
        ),
      ],

      child: const MyApp(),
    ),
  );
}

// ============================================================
// MY APP
// ============================================================

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    // ========================================================
    // FONT PROVIDER
    // ========================================================

    final FontProvider fontProvider =
        context.watch<FontProvider>();

    // ========================================================
    // MATERIAL APP
    // ========================================================

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'BookVerse',

      // ======================================================
      // GLOBAL THEME
      // ======================================================

      theme: ThemeData(
        useMaterial3: true,

        // ====================================================
        // GLOBAL FONT
        // ====================================================

        fontFamily:
            fontProvider.selectedFont,
      ),

      // ======================================================
      // SPLASH SCREEN
      // ======================================================

      home: const BookVerseSplashScreen(),
    );
  }
}