// lib/Screens/BookNavScreen.dart
import 'package:bookverse/Views/FavoritesScreen.dart';
import 'package:bookverse/Views/HomeScreen.dart';
import 'package:bookverse/Views/LibraryScreen.dart';
import 'package:bookverse/Views/PlansScreen.dart';
import 'package:bookverse/Views/ProfileScreen.dart';
import 'package:flutter/material.dart';

class BookNavScreen extends StatefulWidget {
  const BookNavScreen({super.key});

  @override
  State<BookNavScreen> createState() => _BookNavScreenState();
}

class _BookNavScreenState extends State<BookNavScreen> {
  int selectedIndex = 0;

  final screens = [
    const BookHomeScreen(),
    const MyLibraryScreen(),
    const FavouriteBooksScreen(),
    const ChoosePlanScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, 'Home', 0),
                _buildNavItem(Icons.library_books, 'Library', 1),
                _buildNavItem(Icons.favorite, 'Favorites', 2),
                _buildNavItem(Icons.auto_awesome, 'Plans', 3),
                _buildNavItem(Icons.person, 'Profile', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = selectedIndex == index;
    
    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF232B45) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.black,
              size: isSelected ? 22 : 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}