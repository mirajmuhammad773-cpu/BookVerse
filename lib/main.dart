import 'package:bookverse/Repository/Book-Repository.dart';

import 'package:bookverse/ViewModels/AchievementProvider.dart';
import 'package:bookverse/ViewModels/Book-view-model.dart';
import 'package:bookverse/ViewModels/BookDownloadProvider.dart';
import 'package:bookverse/ViewModels/FavoriteBookProvider.dart';
import 'package:bookverse/ViewModels/PlansProvider.dart';
import 'package:bookverse/ViewModels/ReadingGoalProvider.dart';
import 'package:bookverse/ViewModels/ReadingHistoryProvider.dart';
import 'package:bookverse/ViewModels/UserProvider.dart';

// ============================================================
// PAYMENT PROVIDER
// ============================================================
import 'package:bookverse/ViewModels/PaymentProvider.dart';

import 'package:bookverse/Views/SplashScreen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  Stripe.publishableKey =
      'pk_test_51T90APK3SgPBD2SDbyFyY5xEl7dUWFXLJZLlHluI2RBlcc3Rgi1Gw5cPTJJZAqOUiBt1RpMmO37OVkpTKSPtkSRM00uxNcOJev';

  await Stripe.instance.applySettings();

  runApp(
    MultiProvider(
      providers: [
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
        // READING HISTORY
        // ======================================================

        ChangeNotifierProvider(
          create: (_) => ReadingHistoryProvider(),
        ),

        // ======================================================
        // READING GOAL
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

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'BookVerse',

      theme: ThemeData(
        useMaterial3: true,
      ),

      home: const BookVerseSplashScreen(),
    );
  }
}