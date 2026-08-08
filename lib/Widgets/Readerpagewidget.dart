import 'package:flutter/material.dart';

/// Simple data model for one page of reading content. Swap the
/// `paragraphs` here for real data from your backend/API later —
/// nothing else needs to change.
class BookPageData {
  final String chapterLabel; // e.g. 'CHAPTER 1'
  final String title; // e.g. 'The Journey Begins'
  final List<String> paragraphs;
  final int pageNumber; // e.g. 12
  final int totalPages; // e.g. 208
  final int pagesLeftInChapter;

  const BookPageData({
    required this.chapterLabel,
    required this.title,
    required this.paragraphs,
    required this.pageNumber,
    required this.totalPages,
    required this.pagesLeftInChapter,
  });
}

/// ReaderPageContent
/// Renders a single reading page — chapter label, title, a small
/// ornamental divider, then the paragraphs — all at a caller-supplied
/// [fontSize] so the "Aa" slider on the Reader screen can resize text
/// live. Built as its own widget so the Reader screen just calls it
/// once per page inside a PageView.
///
/// Usage:
/// ReaderPageContent(page: myBookPage, fontSize: 17, textColor: Colors.black87)
class ReaderPageContent extends StatelessWidget {
  final BookPageData page;
  final double fontSize;
  final Color textColor;
  final Color chapterLabelColor;

  const ReaderPageContent({
    super.key,
    required this.page,
    required this.fontSize,
    this.textColor = const Color(0xFF2B2620),
    this.chapterLabelColor = const Color(0xFF9C6B3E),
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          Text(
            page.chapterLabel,
            style: TextStyle(
              color: chapterLabelColor,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize + 8,
              fontWeight: FontWeight.w700,
              fontFamily: 'Georgia',
            ),
          ),
          const SizedBox(height: 16),
          _OrnamentalDivider(color: chapterLabelColor.withOpacity(0.6)),
          const SizedBox(height: 22),
          for (final paragraph in page.paragraphs)
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Text(
                paragraph,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: textColor,
                  fontSize: fontSize,
                  height: 1.65,
                  fontFamily: 'Georgia',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OrnamentalDivider extends StatelessWidget {
  final Color color;
  const _OrnamentalDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 40, height: 1, color: color),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.circle, size: 4, color: color),
        ),
        Container(width: 40, height: 1, color: color),
      ],
    );
  }
}