import 'package:bookverse/Repository/AchievementProvider.dart';
import 'package:bookverse/Repository/Book-Repository.dart';
import 'package:bookverse/Repository/Favoritebookprovider.dart';
import 'package:bookverse/ViewModels/Book-view-model.dart';
import 'package:bookverse/ViewModels/UserProvider.dart';
import 'package:bookverse/Views/SplashScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp( );
  runApp(
    MultiProvider(
      providers: [

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