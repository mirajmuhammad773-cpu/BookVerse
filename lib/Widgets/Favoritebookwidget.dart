import 'package:bookverse/Views/ReaderScreen.dart';
import 'package:flutter/material.dart';


// ================================================================
// FONT SIZE CONTROL
// ================================================================

class ReaderFontControl extends StatelessWidget {
  final double fontSize;
  final double minFontSize;
  final double maxFontSize;
  final ValueChanged<double> onChanged;

  const ReaderFontControl({
    super.key,
    required this.fontSize,
    required this.minFontSize,
    required this.maxFontSize,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const mutedColor = Color(0xFF8A8375);

    return Row(
      children: [
        const Text(
          'Aa',
          style: TextStyle(
            fontSize: 13,
            color: mutedColor,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(width: 5),

        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 8,
              ),
              overlayShape: const RoundSliderOverlayShape(
                overlayRadius: 16,
              ),
              activeTrackColor: const Color(0xFF3B82F6),
              inactiveTrackColor: mutedColor.withOpacity(0.3),
              thumbColor: const Color(0xFF3B82F6),
            ),
            child: Slider(
              value: fontSize,
              min: minFontSize,
              max: maxFontSize,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

// ================================================================
// READER THEME BUTTON
// ================================================================

class ReaderThemeButton extends StatelessWidget {
  final bool isDayMode;
  final VoidCallback onTap;

  const ReaderThemeButton({
    super.key,
    required this.isDayMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 6),
        child: Icon(
          isDayMode
              ? Icons.light_mode_rounded
              : Icons.dark_mode_rounded,
          color: const Color(0xFFE8A23D),
          size: 20,
        ),
      ),
    );
  }
}

// ================================================================
// PAGE INFORMATION
// ================================================================

class ReaderPageInfo extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int pagesLeftInChapter;

  const ReaderPageInfo({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.pagesLeftInChapter,
  });

  @override
  Widget build(BuildContext context) {
    const mutedColor = Color(0xFF8A8375);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$currentPage / $totalPages',
          style: const TextStyle(
            fontSize: 12,
            color: mutedColor,
          ),
        ),

        Text(
          '$pagesLeftInChapter pages left in chapter',
          style: const TextStyle(
            fontSize: 12,
            color: mutedColor,
          ),
        ),
      ],
    );
  }
}

// ================================================================
// READER PAGE CONTENT
// ================================================================

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
        28,
        20,
        28,
        30,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ======================================================
          // CHAPTER
          // ======================================================

          Text(
            page.chapterLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: chapterLabelColor,
            ),
          ),

          const SizedBox(height: 12),

          // ======================================================
          // TITLE
          // ======================================================

          Text(
            page.title,
            style: TextStyle(
              fontSize: fontSize + 5,
              fontWeight: FontWeight.bold,
              height: 1.25,
              color: textColor,
            ),
          ),

          const SizedBox(height: 24),

          // ======================================================
          // PARAGRAPHS
          // ======================================================

          ...page.paragraphs.map(
            (paragraph) {
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: 18,
                ),
                child: Text(
                  paragraph,
                  style: TextStyle(
                    fontSize: fontSize,
                    height: 1.75,
                    color: textColor,
                  ),
                  textAlign: TextAlign.left,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}