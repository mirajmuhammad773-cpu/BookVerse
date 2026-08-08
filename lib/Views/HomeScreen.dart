
import 'package:bookverse/Models/BookModel.dart';
import 'package:bookverse/ViewModels/Book-view-model.dart';
import 'package:bookverse/Views/BookDetails.dart';
import 'package:bookverse/Widgets/Carouselwidget.dart';
import 'package:bookverse/Widgets/Homewidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookHomeScreen extends StatefulWidget {
  const BookHomeScreen({super.key});

  @override
  State<BookHomeScreen> createState() => _BookHomeScreenState();
}

class _BookHomeScreenState extends State<BookHomeScreen> {
  // ------------------------------------------------------------
  // EXISTING CAROUSEL DATA
  // UI / DESIGN SAME
  // ------------------------------------------------------------

  final books = const [
    FeaturedBook(
      title: 'The Alchemist',
      author: 'Paulo Coelho',
      rating: 4.8,
      ratingCount: '12.4k',
      imageUrl:
          'https://m.media-amazon.com/images/I/71aFt4+OTOL.SL1500.jpg',
      themeColors: [
        Color(0xFF3B2E7E),
        Color(0xFF3B1440),
      ],
      glowColor: Color(0xFFE8794E),
    ),

    FeaturedBook(
      title: 'Deep Work',
      author: 'Cal Newport',
      rating: 4.6,
      ratingCount: '8.1k',
      imageUrl:
          'https://m.media-amazon.com/images/I/71g2ednj0JL._SL1500_.jpg',
      themeColors: [
        Color(0xFF124E4A),
        Color(0xFF0B2E2C),
      ],
      glowColor: Color(0xFF39C9B5),
    ),

    FeaturedBook(
      title: '1984',
      author: 'George Orwell',
      rating: 4.9,
      ratingCount: '20.7k',
      imageUrl:
          'https://m.media-amazon.com/images/I/71kxa1-0mfL._SL1500_.jpg',
      themeColors: [
        Color(0xFF6E1F2A),
        Color(0xFF2B0D12),
      ],
      glowColor: Color(0xFFE05A6E),
    ),

    FeaturedBook(
      title: 'The Book of Life',
      author: 'Dr. Joseph Murphy',
      rating: 4.9,
      ratingCount: '30.7k',
      imageUrl:
          'https://s3.ap-south-1.amazonaws.com/storage.commonfolks.in/docs/products/images_full/write-a-new-name-in-the-book-of-life_FrontImage_415.jpg',
      themeColors: [
        Color(0xFF2EDF58),
        Color(0xFF6CD278),
      ],
      glowColor: Color(0xFF75AB85),
    ),
  ];

  // ------------------------------------------------------------
  // HOME BACKGROUND
  // ------------------------------------------------------------

  List<Color> bgColors = const [
    Color(0xFFE9E4FF),
    Color(0xFFFFFFFF),
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<BookViewModel>().loadPopularBooks();
    });
  }

  // ------------------------------------------------------------
  // OPEN BOOK DETAILS
  // API BOOKS ONLY
  // ------------------------------------------------------------

  void _openBookDetails(BookModel book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookDetailsScreen(
          book: book,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BookViewModel>();

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              bgColors.first.withOpacity(0.35),
              Colors.white,
              Colors.white,
            ],
            stops: const [
              0,
              0.4,
              1,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              16,
              10,
              16,
              20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ------------------------------------------------
                // HEADER
                // ------------------------------------------------

                HomeHeader(
                  userName: 'Miraj',
                  avatarUrl:
                      'https://i.pravatar.cc/150?img=12',
                  onBellTap: () {},
                ),

                const SizedBox(height: 18),

                // ------------------------------------------------
                // FEATURED CAROUSEL
                // ------------------------------------------------

                FeaturedBookCarousel(
                  books: books,
                  onPageColorChanged: (colors) {
                    if (!mounted) return;

                    setState(() {
                      bgColors = colors;
                    });
                  },
                  onReadNow: (book) {
                    // Existing behavior.
                    // No details navigation added here.
                  },
                ),

                const SizedBox(height: 22),

                // ------------------------------------------------
                // CATEGORIES
                // ------------------------------------------------

                CategoryList(
                  onCategoryTap: (category) {
                    // Category screen later.
                  },
                ),

                const SizedBox(height: 22),

                // ------------------------------------------------
                // FAMOUS BOOKS
                // ------------------------------------------------

                const Text(
                  'Famous Books',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 12),

                _buildFamousBooks(viewModel),

                const SizedBox(height: 22),

                // ------------------------------------------------
                // CONTINUE READING
                // ------------------------------------------------

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Continue Reading',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.deepPurple.shade300,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                ContinueReadingCard(
                  title: 'Atomic Habits',
                  author: 'James Clear',
                  progress: 0.48,
                  coverImageUrl:
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQZ4DanN_F93azExyOVDqe-Y03jgwITBGkBHNJx6TV5GsWSm1GpE4g7sp0&s=10',
                  coverColor:
                      const Color(0xFFE9A24B),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FAMOUS BOOKS
  // ============================================================

  Widget _buildFamousBooks(
    BookViewModel viewModel,
  ) {
    if (viewModel.isLoading &&
        viewModel.popularBooks.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 35),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (viewModel.errorMessage != null &&
        viewModel.popularBooks.isEmpty) {
      return _buildErrorWidget(
        onRetry: () {
          context
              .read<BookViewModel>()
              .loadPopularBooks();
        },
      );
    }

    if (viewModel.popularBooks.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Center(
          child: Text(
            'No books available',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return Column(
      children: viewModel.popularBooks
          .take(5)
          .map(
            (book) => _buildApiBookCard(book),
          )
          .toList(),
    );
  }

  // ============================================================
  // SAME STYLE BOOK CARD
  // ============================================================

  Widget _buildApiBookCard(
    BookModel book,
  ) {
    return GestureDetector(
      onTap: () {
        _openBookDetails(book);
      },
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
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // --------------------------------------------------
            // COVER
            // --------------------------------------------------

            ClipRRect(
              borderRadius:
                  BorderRadius.circular(10),
              child: Image.network(
                book.imageUrl,
                width: 64,
                height: 88,
                fit: BoxFit.cover,
                loadingBuilder:
                    (context, child, progress) {
                  if (progress == null) {
                    return child;
                  }

                  return Container(
                    width: 64,
                    height: 88,
                    color: const Color(0xFFE5E5EC),
                    child: const Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder:
                    (context, error, stackTrace) {
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

            // --------------------------------------------------
            // BOOK INFORMATION
            // --------------------------------------------------

            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 4,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      book.author,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(
                          Icons
                              .local_fire_department_rounded,
                          color:
                              Color(0xFFF5A623),
                          size: 17,
                        ),

                        const SizedBox(width: 4),

                        Text(
                          _formatDownloads(
                            book.downloadCount,
                          ),
                          style:
                              const TextStyle(
                            fontSize: 13,
                            fontWeight:
                                FontWeight.w700,
                            color:
                                Colors.black87,
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

            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildErrorWidget({
    required VoidCallback onRetry,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 34,
            color: Colors.grey,
          ),

          const SizedBox(height: 8),

          const Text(
            'Unable to load books',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          TextButton(
            onPressed: onRetry,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DOWNLOAD FORMAT
  // ============================================================

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

