import 'package:flutter/material.dart';

/// Simple data model for one book shown in the Library grid.
class LibraryBook {
  final String title;
  final String author;
  final double progress; // 0..1
  final String? imageUrl;
  final Color fallbackColor;
  final bool isDownloaded;

  const LibraryBook({
    required this.title,
    required this.author,
    required this.progress,
    required this.fallbackColor,
    this.imageUrl,
    this.isDownloaded = false,
  });
}

/// LibraryBookCard
/// A single grid item — cover image with a progress bar + percentage
/// overlaid at the bottom, then the book title and author beneath.
/// Built as its own widget so the Library grid can call it once per
/// book, just by passing a [LibraryBook].
///
/// Usage:
/// LibraryBookCard(book: myLibraryBook, onTap: () => ...)
class LibraryBookCard extends StatelessWidget {
  final LibraryBook book;
  final VoidCallback? onTap;

  const LibraryBookCard({super.key, required this.book, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 0.78,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Cover image, with a color fallback if none/failed.
                  book.imageUrl == null
                      ? Container(color: book.fallbackColor)
                      : Image.network(
                          book.imageUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: book.fallbackColor.withOpacity(0.5),
                              child: const Center(
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Container(color: book.fallbackColor),
                        ),

                
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            book.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.black87, ),
          ),
          Text(
            book.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}