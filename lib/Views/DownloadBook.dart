// lib/Screens/DownloadedBooksScreen.dart
import 'package:bookverse/Widgets/DownloadBookwidget.dart';
import 'package:flutter/material.dart';

class DownloadedBooksScreen extends StatelessWidget {
  const DownloadedBooksScreen({super.key});

  static const purple = Color(0xFF6C4CE0);

  static const List<DownloadedBook> _books = [
    DownloadedBook(
      title: 'Atomic Habits',
      author: 'James Clear',
      sizeLabel: '8.4 MB',
      coverColor: Color(0xFF16324F),
      textColor: Color(0xFFE8A54B),
    ),
    DownloadedBook(
      title: 'The Psychology of Money',
      author: 'Morgan Housel',
      sizeLabel: '6.7 MB',
      coverColor: Colors.white,
      textColor: Color(0xFF2F6B4F),
    ),
    DownloadedBook(
      title: 'Rich Dad Poor Dad',
      author: 'Robert T. Kiyosaki',
      sizeLabel: '5.1 MB',
      coverColor: Color(0xFF6B3FA0),
      textColor: Color(0xFFF4D35E),
    ),
    DownloadedBook(
      title: 'The 5 AM Club',
      author: 'Robin Sharma',
      sizeLabel: '4.2 MB',
      coverColor: Color(0xFFE8622C),
      textColor: Colors.white,
    ),
    DownloadedBook(
      title: 'Deep Work',
      author: 'Cal Newport',
      sizeLabel: '3.6 MB',
      coverColor: Color(0xFFF4C430),
      textColor: Colors.black87,
    ),
    DownloadedBook(
      title: 'Think and Grow Rich',
      author: 'Napoleon Hill',
      sizeLabel: '4.0 MB',
      coverColor: Colors.black,
      textColor: Colors.white,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      body: SafeArea(
        child: Column(
          children: [
            // ---------------- Header ----------------
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  _iconButton(Icons.arrow_back_rounded, () => Navigator.maybePop(context)),
                 const SizedBox(width: 35),
                        const Text('Downloaded Books',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
            ),
            const SizedBox(height: 16),

           
            // ---------------- Search bar ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search downloaded books...',
                          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13.5),
                          prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Icon(Icons.tune_rounded, color: Colors.black87, size: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ---------------- Book list (custom widget, filter row removed) ----------------
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: _books.length,
                itemBuilder: (context, i) => DownloadedBookItem(
                  book: _books[i],
                  onTap: () {},
                  onMoreTap: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Icon(icon, size: 18, color: Colors.black87),
      ),
    );
  }
}