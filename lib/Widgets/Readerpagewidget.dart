import 'package:flutter/material.dart';

class ReaderPageContent extends StatelessWidget {
  final BookPageData page;
  final double fontSize;
  final Color textColor;
  final Color chapterLabelColor;

  const ReaderPageContent({
    super.key,
    required this.page,
    required this.fontSize,
    required this.textColor,
    required this.chapterLabelColor,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        24,
        12,
        24,
        30,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (page.chapterLabel.isNotEmpty)
            Text(
              page.chapterLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: chapterLabelColor,
              ),
            ),

          const SizedBox(height: 8),

          if (page.title.isNotEmpty)
            Text(
              page.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: fontSize + 3,
                fontWeight: FontWeight.bold,
                height: 1.35,
                color: textColor,
              ),
            ),

          const SizedBox(height: 22),

          ...page.paragraphs.map(
            (paragraph) {
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: 18,
                ),
                child: Text(
                  paragraph,
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: fontSize,
                    height: 1.75,
                    color: textColor,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}


class BookPageData {
  final String chapterLabel;
  final String title;
  final int pageNumber;
  final int totalPages;
  final int pagesLeftInChapter;
  final int chapterIndex;
  final List<String> paragraphs;

  const BookPageData({
    required this.chapterLabel,
    required this.title,
    required this.pageNumber,
    required this.totalPages,
    required this.pagesLeftInChapter,
    required this.chapterIndex,
    required this.paragraphs,
  });
}