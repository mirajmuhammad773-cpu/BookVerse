// lib/Widgets/FavouriteApiBookCard.dart

// ignore_for_file: file_names

import 'package:bookverse/Models/BookModel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FavouriteApiBookCard extends StatelessWidget {
  final BookModel book;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  final bool isFavorite;

  const FavouriteApiBookCard({
    super.key,
    required this.book,
    this.onTap,
    this.onFavoriteTap,
    this.isFavorite = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F6F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFECECF2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------------------------------------
            // COVER
            // ------------------------------------------------

            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: book.imageUrl.trim().isEmpty
                  ? Container(
                      width: 64,
                      height: 88,
                      color: const Color(0xFFE5E5EC),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: Colors.grey,
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: book.imageUrl,
                      width: 64,
                      height: 88,
                      fit: BoxFit.cover,

                      placeholder: (context, url) {
                        return Container(
                          width: 64,
                          height: 88,
                          color: const Color(0xFFE5E5EC),
                          child: const Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        );
                      },

                      errorWidget: (context, url, error) {
                        return Container(
                          width: 64,
                          height: 88,
                          color: const Color(0xFFE5E5EC),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(width: 14),

            // ------------------------------------------------
            // BOOK INFORMATION
            // ------------------------------------------------

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          color: Color(0xFFF5A623),
                          size: 17,
                        ),

                        const SizedBox(width: 4),

                        Text(
                          _formatDownloads(
                            book.downloadCount,
                          ),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(width: 4),

                        const Text(
                          'downloads',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 5),

            // ------------------------------------------------
            // FAVORITE + ARROW
            // ------------------------------------------------

            Column(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onFavoriteTap,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isFavorite
                          ? Colors.redAccent
                          : Colors.grey,
                      size: 20,
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey,
                  size: 22,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDownloads(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }

    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }

    return count.toString();
  }
}