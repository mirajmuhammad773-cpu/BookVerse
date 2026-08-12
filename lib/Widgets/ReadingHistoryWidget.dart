import 'package:flutter/material.dart';

/// Simple data model for one entry in the reading history list.
class ReadingHistoryData {
  final String title;
  final String author;
  final String imageUrl;
  final String lastRead; // e.g. 'Today, 9:20 AM'
  final double progress; // 0..1
  final String status; // 'In Progress', 'Completed', 'Saved'

  const ReadingHistoryData({
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.lastRead,
    required this.progress,
    required this.status,
  });
}

/// ReadingHistoryItem
/// A single card in the Reading History list — cover, title, author,
/// "Last read: ..." line, a progress bar with percentage, and a
/// 3-dot menu button. Built as its own widget so the Reading History
/// screen can call it once per book, just by passing a
/// [ReadingHistoryData].
///
/// Usage:
/// ReadingHistoryItem(book: myHistoryEntry, onMenuTap: () => ...)
class ReadingHistoryItem extends StatelessWidget {
  final ReadingHistoryData book;
  final VoidCallback? onTap;
  final VoidCallback? onMenuTap;

  static const _primary = Color(0xFF6366F1);

  const ReadingHistoryItem({
    super.key,
    required this.book,
    this.onTap,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEFEFF4)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                book.imageUrl,
                width: 62,
                height: 82,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    width: 62,
                    height: 82,
                    color: const Color(0xFFEDEBFB),
                    child: const Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 62,
                  height: 82,
                  color: const Color(0xFFEDEBFB),
                  child: const Icon(Icons.menu_book_rounded, color: _primary),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          book.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ),
                      GestureDetector(
                        onTap: onMenuTap,
                        child: const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(Icons.more_vert_rounded, color: Colors.grey, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Last read: ${book.lastRead}',
                    style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: book.progress,
                            minHeight: 6,
                            backgroundColor: const Color(0xFFE9E9F0),
                            valueColor: const AlwaysStoppedAnimation(_primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${(book.progress * 100).round()}%',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black87),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}