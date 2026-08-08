import 'dart:async';
import 'package:bookverse/Models/BookModel.dart';
import 'package:bookverse/ViewModels/Book-view-model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'BookDetails.dart';

class RomanceBooksScreen extends StatefulWidget {
  const RomanceBooksScreen({super.key});

  @override
  State<RomanceBooksScreen> createState() =>
      _RomanceBooksScreenState();
}

class _RomanceBooksScreenState extends State<RomanceBooksScreen> {
  static const Color pink = Color(0xFFEC4899);

  final TextEditingController _searchController =
      TextEditingController();

  Timer? _searchDebounce;

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final viewModel = context.read<BookViewModel>();

      if (viewModel.romanceBooks.isEmpty) {
        viewModel.loadRomanceBooks();
      }
    });
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void _onSearchChanged() {
    final query = _searchController.text.trim();

    _searchDebounce?.cancel();

    if (mounted) {
      setState(() {
        _searchQuery = query;
      });
    }

    final viewModel = context.read<BookViewModel>();

    // ==========================================================
    // EMPTY SEARCH
    // ==========================================================

    if (query.isEmpty) {
      viewModel.clearRomanceSearch();

      if (viewModel.romanceBooks.isEmpty) {
        viewModel.loadRomanceBooks();
      }

      return;
    }

    _searchDebounce = Timer(
      const Duration(milliseconds: 500),
      () {
        if (!mounted) return;

        context
            .read<BookViewModel>()
            .searchRomanceBooks(query);
      },
    );
  }

  // ============================================================
  // OPEN BOOK DETAILS
  // ============================================================

  void _openBookDetails(BookModel book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailsScreen(
          book: book,
        ),
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _searchDebounce?.cancel();

    _searchController.removeListener(
      _onSearchChanged,
    );

    _searchController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                8,
                8,
                16,
                8,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.maybePop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.black87,
                    ),
                  ),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Romance Books',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight:
                                FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // SEARCH BAR
            // ==================================================

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  textInputAction:
                      TextInputAction.search,
                  textCapitalization:
                      TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText:
                        'Search romance books...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13.5,
                    ),

                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Colors.grey,
                    ),

                    suffixIcon:
                        _searchQuery.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _searchController
                                      .clear();
                                },
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.grey,
                                ),
                              )
                            : const Icon(
                                Icons.favorite_rounded,
                                color: pink,
                              ),

                    border: InputBorder.none,

                    contentPadding:
                        const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ==================================================
            // BOOKS
            // ==================================================

            Expanded(
              child: Consumer<BookViewModel>(
                builder: (
                  context,
                  viewModel,
                  child,
                ) {
                  final bool isSearching =
                      _searchQuery.isNotEmpty;

                  // ==================================================
                  // INITIAL LOADING
                  // ==================================================

                  if (!isSearching &&
                      viewModel.isLoading &&
                      viewModel.romanceBooks.isEmpty) {
                    return const Center(
                      child:
                          CircularProgressIndicator(
                        color: pink,
                      ),
                    );
                  }

                  // ==================================================
                  // SEARCH LOADING
                  // ==================================================

                  if (isSearching &&
                      viewModel.isSearching) {
                    return const Center(
                      child:
                          CircularProgressIndicator(
                        color: pink,
                      ),
                    );
                  }

                  // ==================================================
                  // CURRENT BOOK LIST
                  // ==================================================

                  final List<BookModel> books;

                  if (isSearching) {
                  

                    books =
                        viewModel
                            .romanceSearchResults
                            .cast<BookModel>()
                            .toList();
                  } else {
                   
                    books =
                        viewModel
                            .romanceBooks
                            .cast<BookModel>()
                            .take(200)
                            .toList();
                  }

                  // ==================================================
                  // ERROR
                  // ==================================================

                  if (viewModel.errorMessage !=
                          null &&
                      books.isEmpty) {
                    return _buildError(
                      viewModel,
                      isSearching,
                    );
                  }

                  // ==================================================
                  // EMPTY
                  // ==================================================

                  if (books.isEmpty) {
                    return _buildEmpty(
                      isSearching,
                    );
                  }

                  // ==================================================
                  // BOOK LIST
                  // ==================================================

                  return Stack(
                    children: [
                      ListView.builder(
                        physics:
                            const BouncingScrollPhysics(),
                        padding:
                            const EdgeInsets.fromLTRB(
                          16,
                          2,
                          16,
                          25,
                        ),
                        itemCount: books.length,
                        itemBuilder:
                            (context, index) {
                          final book =
                              books[index];

                          return Padding(
                            padding:
                                const EdgeInsets.only(
                              bottom: 12,
                            ),
                            child:
                                _buildBookCard(
                              book,
                            ),
                          );
                        },
                      ),

                      // ==================================================
                      // SEARCH PROGRESS
                      // ==================================================

                      if (isSearching &&
                          viewModel.isSearching)
                        const Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child:
                              LinearProgressIndicator(
                            minHeight: 2,
                            color: pink,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BOOK CARD
  // ============================================================

  Widget _buildBookCard(
    BookModel book,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(16),
        onTap: () {
          _openBookDetails(book);
        },
        child: Container(
          padding:
              const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color:
                const Color(0xFFF6F6F9),
            borderRadius:
                BorderRadius.circular(16),
            border: Border.all(
              color:
                  const Color(0xFFECECF2),
            ),
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ==================================================
              // COVER
              // ==================================================

              ClipRRect(
                borderRadius:
                    BorderRadius.circular(10),
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
                    if (loadingProgress ==
                        null) {
                      return child;
                    }

                    return Container(
                      width: 68,
                      height: 94,
                      color:
                          const Color(
                        0xFFE5E5EC,
                      ),
                      child:
                          const Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: pink,
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
                      color:
                          const Color(
                        0xFFE5E5EC,
                      ),
                      child:
                          const Icon(
                        Icons
                            .menu_book_rounded,
                        color:
                            Colors.grey,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              // ==================================================
              // BOOK INFO
              // ==================================================

              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    vertical: 3,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        book.title,
                        maxLines: 2,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          fontSize: 15,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Colors.black87,
                        ),
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(
                        book.author,
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          fontSize: 12.5,
                          color:
                              Colors.grey,
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      Row(
                        children: [
                          const Icon(
                            Icons
                                .favorite_rounded,
                            color: pink,
                            size: 17,
                          ),

                          const SizedBox(
                            width: 4,
                          ),

                          Text(
                            _formatDownloads(
                              book.downloadCount,
                            ),
                            style:
                                const TextStyle(
                              fontSize: 13,
                              fontWeight:
                                  FontWeight
                                      .w700,
                              color:
                                  Colors.black87,
                            ),
                          ),

                          const SizedBox(
                            width: 4,
                          ),

                          const Text(
                            'downloads',
                            style:
                                TextStyle(
                              fontSize: 11.5,
                              color:
                                  Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                width: 5,
              ),

              // ==================================================
              // ARROW
              // ==================================================

              const Padding(
                padding:
                    EdgeInsets.only(
                  top: 34,
                ),
                child: Icon(
                  Icons
                      .chevron_right_rounded,
                  color:
                      Colors.grey,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError(
    BookViewModel viewModel,
    bool isSearching,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 44,
              color: Colors.grey,
            ),

            const SizedBox(
              height: 12,
            ),

            Text(
              isSearching
                  ? 'Unable to search romance books'
                  : 'Unable to load romance books',
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontSize: 15,
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            const Text(
              'Please check your internet connection and try again.',
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            ElevatedButton(
              onPressed: () {
                if (isSearching) {
                  final query =
                      _searchController
                          .text
                          .trim();

                  if (query.isNotEmpty) {
                    viewModel
                        .searchRomanceBooks(
                      query,
                    );
                  }
                } else {
                  viewModel
                      .loadRomanceBooks();
                }
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor: pink,
                foregroundColor:
                    Colors.white,
              ),
              child:
                  const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmpty(
    bool isSearching,
  ) {
    return Center(
      child: Column(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          const Icon(
            Icons.favorite_border_rounded,
            size: 45,
            color: Colors.grey,
          ),

          const SizedBox(
            height: 12,
          ),

          Text(
            isSearching
                ? 'No romance books found'
                : 'No romance books available',
            style:
                const TextStyle(
              fontSize: 15,
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          if (isSearching) ...[
            const SizedBox(
              height: 5,
            ),

            const Text(
              'Try another search.',
              style:
                  TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // DOWNLOAD FORMAT
  // ============================================================

  String _formatDownloads(
    int count,
  ) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }

    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }

    return count.toString();
  }
}

