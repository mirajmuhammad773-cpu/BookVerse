// lib/Widgets/FavouriteBookCard.dart
import 'package:flutter/material.dart';

class FavouriteBook {
  final String title;
  final String author;
  final double progress; // 0..1
  final String category;
  final Color coverColor;
  final Color textColor;
  final bool isFavorite;
  final String? imageUrl; // real cover photo - falls back to painted cover if null/fails

  const FavouriteBook({
    required this.title,
    required this.author,
    required this.progress,
    required this.category,
    required this.coverColor,
    this.textColor = Colors.black87,
    this.isFavorite = true,
    this.imageUrl,
  });
}

class FavouriteBookCard extends StatelessWidget {
  final FavouriteBook book;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onMoreTap;

  const FavouriteBookCard({
    super.key,
    required this.book,
    this.onTap,
    this.onFavoriteTap,
    this.onMoreTap,
  });

  static const purple = Color(0xFF6C4CE0);

  Widget _cover() {
    // Painted fallback (used when no imageUrl, or the network image fails to load)
    final painted = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: book.coverColor, borderRadius: BorderRadius.circular(14)),
      alignment: Alignment.center,
      child: Text(
        book.title,
        textAlign: TextAlign.center,
        maxLines: 3,
        style: TextStyle(color: book.textColor, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );

    if (book.imageUrl == null) return painted;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        book.imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return painted;
        },
        errorBuilder: (context, error, stackTrace) => painted,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 0.78,
            child: Stack(
              children: [
                _cover(),
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: onFavoriteTap,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Icon(
                        book.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: book.isFavorite ? Colors.red : Colors.grey,
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87)),
              ),
              GestureDetector(
                onTap: onMoreTap,
                child: const Icon(Icons.more_vert_rounded, size: 12, color: Colors.grey),
              ),
            ],
          ),
          Text(book.author, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: book.progress,
                    minHeight: 5,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation(purple),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text('${(book.progress * 100).round()}%', style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

// lib/Widgets/CategoryFilterChips.dart

class CategoryFilterChips extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  const CategoryFilterChips({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  static const purple = Color(0xFF6C4CE0);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final c = categories[i];
          final isActive = c == selected;
          return GestureDetector(
            onTap: () => onSelected(c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive ? purple : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isActive ? purple : Colors.grey.shade300),
              ),
              child: Text(
                c,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.black87,
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}