import 'package:bookverse/Repository/Book-Repository.dart';
import 'package:bookverse/Repository/Favoritebookprovider.dart';
import 'package:bookverse/ViewModels/Book-view-model.dart';
import 'package:bookverse/Views/SplashScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // ======================================================
        // BOOK PROVIDER
        // ======================================================

        ChangeNotifierProvider(
          create: (_) => BookViewModel(
            repository: BookRepository(),
          ),
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