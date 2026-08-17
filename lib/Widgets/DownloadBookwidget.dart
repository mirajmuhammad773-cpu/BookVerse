// lib/Widgets/DownloadedBookItem.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class DownloadedBook {
  final String title;
  final String author;
  final String sizeLabel; // e.g. '8.4 MB'
  final int progress; // 0..100
  final Color coverColor;
  final Color textColor;

  const DownloadedBook({
    required this.title,
    required this.author,
    required this.sizeLabel,
    this.progress = 100,
    required this.coverColor,
    this.textColor = Colors.white,
  });
}

class DownloadedBookItem extends StatelessWidget {
  final DownloadedBook book;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;

  const DownloadedBookItem({
    super.key,
    required this.book,
    this.onTap,
    this.onMoreTap,
  });

  static const green = Color.fromARGB(255, 14, 218, 24);

  @override
  Widget build(BuildContext context) {
    final isComplete = book.progress >= 100;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 60,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: book.coverColor, borderRadius: BorderRadius.circular(8)),
              child: Text(
                book.title,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: book.textColor, fontWeight: FontWeight.bold, fontSize: 9),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                  const SizedBox(height: 2),
                  Text(book.author, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.menu_book_rounded, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('Book • ${book.sizeLabel}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ]),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: onMoreTap,
                  child: const Icon(Icons.more_vert_rounded, size: 18, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${book.progress}%',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isComplete ? green : Colors.red)),
                    const SizedBox(width: 6),
                    Icon(
                      isComplete ? Icons.check_circle_rounded : Icons.downloading_rounded,
                      size: 18,
                      color: green,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}