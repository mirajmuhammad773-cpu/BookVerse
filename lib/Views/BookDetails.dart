
// ignore_for_file: unused_field

import 'package:bookverse/Models/BookModel.dart';
import 'package:bookverse/Views/ReaderScreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class BookDetailsScreen extends StatefulWidget {
  final BookModel book;

  const BookDetailsScreen({
    super.key,
    required this.book,
  });

  @override
  State<BookDetailsScreen> createState() =>
      _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  Color _bgColor = const Color(0xFFE9A3B0);

  bool _isFavorite = false;

  int _dotIndex = 0;

  // Book information
  String _pages = '—';
  String _chapters = '—';

  bool _isLoadingBookInfo = false;

  // Download state

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(
        const Duration(milliseconds: 350),
        () {
          if (mounted) {
            _detectCoverColor();
          }
        },
      );

      _loadBookInformation();
    });
  }

  // ============================================================
  // CHECK DOWNLOAD AVAILABILITY
  // ============================================================

  bool get _canDownload {
    return widget.book.textUrl.trim().isNotEmpty;
  }

  // ============================================================
  // DETECT BOOK COVER COLOR
  // ============================================================

  Future<void> _detectCoverColor() async {
    if (widget.book.imageUrl.isEmpty) {
      return;
    }

    try {
      final palette =
          await PaletteGenerator.fromImageProvider(
        CachedNetworkImageProvider(
          widget.book.imageUrl,
        ),
        size: const Size(200, 280),
        maximumColorCount: 24,
      );

      final detected =
          palette.vibrantColor?.color ??
          palette.dominantColor?.color ??
          palette.mutedColor?.color;

      if (detected != null && mounted) {
        setState(() {
          _bgColor = detected;
        });
      }
    } catch (_) {
      // Keep fallback color.
    }
  }

  // ============================================================
  // LOAD BOOK INFORMATION
  // ============================================================

  Future<void> _loadBookInformation() async {
    if (widget.book.textUrl.trim().isEmpty) {
      return;
    }

    setState(() {
      _isLoadingBookInfo = true;
    });

    try {
      // ReaderScreen actual text load karegi.
      //
      // Yahan pages/chapters ke liye API text directly fetch
      // karne ke bajaye hum safe fallback use kar rahe hain.
      //
      // Agar BookModel mein pages/chapters fields available
      // hon to unhein yahan directly use kiya ja sakta hai.

      if (mounted) {
        setState(() {
          _pages = 'Available';
          _chapters = 'Available';
          _isLoadingBookInfo = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingBookInfo = false;
        });
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --------------------------------------------------
            // HERO SECTION
            // --------------------------------------------------

            _TopSection(
              bgColor: _bgColor,
              coverUrl: widget.book.imageUrl,
              isFavorite: _isFavorite,
              dotIndex: _dotIndex,

              onBack: () {
                Navigator.maybePop(context);
              },

              

             

              onDotChanged: (index) {
                setState(() {
                  _dotIndex = index;
                });
              },
            ),

            // --------------------------------------------------
            // BOOK INFORMATION
            // --------------------------------------------------

            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                18,
                20,
                0,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // ------------------------------------------------
                  // TITLE
                  // ------------------------------------------------

                  Text(
                    widget.book.title,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 2),

                  // ------------------------------------------------
                  // AUTHOR
                  // ------------------------------------------------

                  Text(
                    widget.book.author,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: _bgColor,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ------------------------------------------------
                  // RATING
                  // ------------------------------------------------


                  const SizedBox(height: 18),

                  // ------------------------------------------------
                  // STATS
                  // ------------------------------------------------

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7FA),
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        _statColumn(
                          _pages,
                          'Pages',
                        ),

                        _statDivider(),

                        _statColumn(
                          _chapters,
                          'Chapters',
                        ),

                        _statDivider(),

                        _statColumn(
                          _canDownload
                              ? 'Online'
                              : '—',
                          'Reading Time',
                        ),

                        _statDivider(),

                        _statColumn(
                          widget.book.language,
                          'Language',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ------------------------------------------------
                  // ABOUT BOOK
                  // ------------------------------------------------

                  const Text(
                    'About Book',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    widget.book.description.isEmpty
                        ? 'No description available for this book.'
                        : widget.book.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 4),

                  GestureDetector(
                    onTap: _showFullDescription,
                    child: Text(
                      'Read More',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _bgColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ------------------------------------------------
                  // READ NOW + DOWNLOAD + BOOKMARK
                  // ------------------------------------------------

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 54,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _bgColor,
                                Colors.deepPurple.shade300,
                              ],
                            ),
                            borderRadius:
                                BorderRadius.circular(28),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius:
                                  BorderRadius.circular(28),
                              onTap: _openReader,
                              child: const Center(
                                child: Text(
                                  'Read Now',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight:
                                        FontWeight.w700,
                                    fontSize: 15.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    
                      const SizedBox(width: 10),

                      // ------------------------------------------------
                      // BOOKMARK
                      // ------------------------------------------------

                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.bookmark_border_rounded,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  

  // ============================================================
  // OPEN READER
  // ============================================================

  void _openReader() {
    if (widget.book.textUrl.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This book is not available for online reading.',
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReaderScreen(
          book: widget.book,
        ),
      ),
    );
  }

  // ============================================================
  // FULL DESCRIPTION
  // ============================================================

  void _showFullDescription() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              30,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    widget.book.title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    widget.book.description.isEmpty
                        ? 'No description available.'
                        : widget.book.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // STAT DIVIDER
  // ============================================================

  Widget _statDivider() {
    return Container(
      width: 1,
      height: 30,
      color: Colors.grey.shade300,
    );
  }

  // ============================================================
  // STAT COLUMN
  // ============================================================

  Widget _statColumn(
    String value,
    String label,
  ) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// TOP HERO SECTION
// ================================================================

class _TopSection extends StatelessWidget {
  final Color bgColor;
  final String coverUrl;
  final bool isFavorite;
  final int dotIndex;

  final VoidCallback onBack;
  final ValueChanged<int> onDotChanged;

  const _TopSection({
    required this.bgColor,
    required this.coverUrl,
    required this.isFavorite,
    required this.dotIndex,
    required this.onBack,
    required this.onDotChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      height: 420,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            bgColor.withOpacity(0.9),
            bgColor.withOpacity(0.35),
            Colors.white,
          ],
          stops: const [
            0.0,
            0.55,
            1.0,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // ----------------------------------------------------
            // TOP BUTTONS
            // ----------------------------------------------------

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  _circleButton(
                    icon: Icons.arrow_back,
                    onTap: onBack,
                  ),

               
                ],
              ),
            ),

            // ----------------------------------------------------
            // BOOK STAND
            // ----------------------------------------------------

            Align(
              alignment: const Alignment(0, 0.58),
              child: Container(
                width: 190,
                height: 26,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withOpacity(0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
              ),
            ),

            // ----------------------------------------------------
            // BOOK COVER
            // ----------------------------------------------------

            Align(
              alignment: const Alignment(0, 0.1),
              child: Transform.rotate(
                angle: -0.05,
                child: Container(
                  width: 150,
                  height: 210,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withOpacity(0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(8),
                    child: coverUrl.isEmpty
                        ? Container(
                            color:
                                const Color(0xFFE5E5EC),
                            child: const Icon(
                              Icons.menu_book_rounded,
                              size: 50,
                              color: Colors.grey,
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: coverUrl,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) {
                              return Container(
                                color:
                                    const Color(0xFFE5E5EC),
                                child: const Center(
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorWidget:
                                (context, url, error) {
                              return Container(
                                color:
                                    const Color(0xFFE5E5EC),
                                child: const Icon(
                                  Icons
                                      .menu_book_rounded,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CIRCLE BUTTON
  // ============================================================

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = Colors.black87,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 18,
        ),
      ),
    );
  }
}

