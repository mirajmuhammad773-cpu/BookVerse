// lib/Widgets/FeaturedBookCarousel.dart
// ignore_for_file: deprecated_member_use, prefer_const_constructors, unused_element_parameter

import 'dart:async';

import 'package:flutter/material.dart';

class FeaturedBook {
  final String title;
  final String imageUrl;
  final String author;
  final double rating;
  final String ratingCount;
  final List<Color> themeColors; // book cover gradient - carousel & top bg follow this
  final Color glowColor;

  const FeaturedBook({
        required this.imageUrl,

    required this.title,
    required this.author,
    required this.rating,
    required this.ratingCount,
    required this.themeColors,
    required this.glowColor,
  });
}

class FeaturedBookCarousel extends StatefulWidget {
  final List<FeaturedBook> books;
  final ValueChanged<List<Color>>? onPageColorChanged;
  final void Function(FeaturedBook book)? onReadNow;
  final Duration autoPlayInterval;

  const FeaturedBookCarousel({
    super.key,
    required this.books,
    this.onPageColorChanged,
    this.onReadNow,
    this.autoPlayInterval = const Duration(seconds: 4),
  });

  @override
  State<FeaturedBookCarousel> createState() => _FeaturedBookCarouselState();
}

class _FeaturedBookCarouselState extends State<FeaturedBookCarousel> {
 
  static const _initialVirtualPage = 10000;

  late final PageController _controller = PageController(
    viewportFraction: 1,
    initialPage: _initialVirtualPage,
  );

 
  int _rawIndex = _initialVirtualPage;
  Timer? _autoPlayTimer;

  int get _realIndex => widget.books.isEmpty ? 0 : _rawIndex % widget.books.length;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    if (widget.books.length <= 1) return;
    _autoPlayTimer = Timer.periodic(widget.autoPlayInterval, (_) {
      if (!_controller.hasClients) return;
      
      _controller.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 230,
          child: PageView.builder(
            controller: _controller,
            
            onPageChanged: (i) {
              setState(() => _rawIndex = i);
              widget.onPageColorChanged?.call(widget.books[_realIndex].themeColors);
             
              _startAutoPlay();
            },
            itemBuilder: (context, i) {
              final book = widget.books[i % widget.books.length];
              return _BookCard(
                book: book,
                
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.books.length, (i) {
            final active = i == _realIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? widget.books[_realIndex].glowColor : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}


class _BookCard extends StatelessWidget {
  final FeaturedBook book;
  const _BookCard({required this.book,});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: book.themeColors),
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('FEATURED BOOK',
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    Text(book.title,
                        style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold)),
                    Text(book.author, style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                      const SizedBox(width: 3),
                      Text('${book.rating}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 4),
                      Text('(${book.ratingCount})', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)),
                    ]),
                    const SizedBox(height: 18),
                 
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _BookCoverArt(book: book),
            ],
          ),
        ],
      ),
    );
  }
}

// Painted "3D book" cover - night sky gradient + moon + stars + title,
// so the artwork always matches the book's theme colors exactly (no
// network dependency, always in sync with the carousel/background).


class _BookCoverArt extends StatelessWidget {
  final FeaturedBook book;

  const _BookCoverArt({
    super.key,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.06,
      child: Container(
        width: 96,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.30),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [

            /// Book Cover Image
            Image.network(
              book.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;

                return Container(
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
              errorBuilder: (_, __, ___) {
                return Container(
                  color: Colors.grey.shade300,
                  child: const Icon(
                    Icons.menu_book,
                    size: 40,
                  ),
                );
              },
            ),

            /// Dark Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(.75),
                  ],
                ),
              ),
            ),

            /// Title
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  book.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}