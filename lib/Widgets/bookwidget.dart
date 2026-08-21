
import 'package:BookVerse/Models/BookModel.dart';
import 'package:flutter/material.dart';

class BookCardWidget extends StatelessWidget {
  final BookModel book;
  final VoidCallback? onTap;

  const BookCardWidget({
    super.key,
    required this.book,
    this.onTap,
  });

  static const Color purple = Color(0xFF6C4CE0);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
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

              // =========================
              // BOOK COVER
              // =========================

              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  book.imageUrl,
                  width: 68,
                  height: 94,
                  fit: BoxFit.cover,

                  loadingBuilder: (
                    context,
                    child,
                    loadingProgress,
                  ) {
                    if (loadingProgress == null) {
                      return child;
                    }

                    return Container(
                      width: 68,
                      height: 94,
                      color: const Color(0xFFE5E5EC),
                      child: const Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: purple,
                          ),
                        ),
                      ),
                    );
                  },

                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return Container(
                      width: 68,
                      height: 94,
                      color: const Color(0xFFE5E5EC),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: Colors.grey,
                        size: 28,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 14),

              // =========================
              // BOOK INFORMATION
              // =========================

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 3,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Text(
                        book.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        book.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 12),

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

              // =========================
              // ARROW
              // =========================

              const Padding(
                padding: EdgeInsets.only(top: 34),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey,
                  size: 22,
                ),
              ),
            ],
          ),
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

