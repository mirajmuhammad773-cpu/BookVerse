
// lib/Screens/HistoryBooksScreen.dart

import 'dart:async';

import 'package:bookverse/Models/BookModel.dart';
import 'package:bookverse/ViewModels/Book-view-model.dart';
import 'package:bookverse/Widgets/bookwidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'BookDetails.dart';

class HistoryBooksScreen extends StatefulWidget {
  const HistoryBooksScreen({
    super.key,
  });

  @override
  State<HistoryBooksScreen> createState() =>
      _HistoryBooksScreenState();
}

class _HistoryBooksScreenState
    extends State<HistoryBooksScreen> {
  static const Color purple = Color(0xFF6C4CE0);

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

      if (viewModel.historyBooks.isEmpty) {
        viewModel.loadHistoryBooks();
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

    if (query.isEmpty) {
      viewModel.clearHistorySearch();

      if (viewModel.historyBooks.isEmpty) {
        viewModel.loadHistoryBooks();
      }

      return;
    }

    _searchDebounce = Timer(
      const Duration(milliseconds: 500),
      () {
        if (!mounted) return;

        context
            .read<BookViewModel>()
            .searchHistoryBooks(query);
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B5E3C),
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () {
            Navigator.maybePop(context);
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
        ),
        title: const Text(
          'History Books',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),

      backgroundColor: const Color(0xFFF7F7FB),

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

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
                  border: Border.all(
                    color: const Color(0xFFEAE8F2),
                  ),
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
                      TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText:
                        'Search history books...',
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
                                Icons
                                    .history_edu_rounded,
                                color: purple,
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

            const SizedBox(height: 16),

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
                      viewModel.historyBooks.isEmpty) {
                    return const Center(
                      child:
                          CircularProgressIndicator(
                        color: purple,
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
                        color: purple,
                      ),
                    );
                  }

                  // ==================================================
                  // CURRENT BOOKS
                  // ==================================================

                  final List<BookModel> books =
                      isSearching
                          ? List<BookModel>.from(
                              viewModel
                                  .historySearchResults,
                            )
                          : viewModel.historyBooks
                              .cast<BookModel>()
                              .take(
                                BookViewModel
                                    .maxBooksPerScreen,
                              )
                              .toList();

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
                          30,
                        ),
                        itemCount: books.length,
                        itemBuilder:
                            (context, index) {
                          final book = books[index];

                          return Padding(
                            padding:
                                const EdgeInsets.only(
                              bottom: 14,
                            ),
                            child: BookCardWidget(
                              book: book,
                              onTap: () {
                                _openBookDetails(
                                  book,
                                );
                              },
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
                            color: purple,
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
  // ERROR
  // ============================================================

  Widget _buildError(
    BookViewModel viewModel,
    bool isSearching,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 44,
              color: Colors.grey,
            ),

            const SizedBox(height: 12),

            Text(
              isSearching
                  ? 'Unable to search history books'
                  : 'Unable to load history books',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Please check your internet connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 14),

            ElevatedButton(
              onPressed: () {
                if (isSearching) {
                  final query =
                      _searchController.text.trim();

                  if (query.isNotEmpty) {
                    viewModel.searchHistoryBooks(
                      query,
                    );
                  }
                } else {
                  viewModel.loadHistoryBooks();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: purple,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
              child: const Text(
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
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.history_edu_outlined,
            size: 45,
            color: Colors.grey,
          ),

          const SizedBox(height: 12),

          Text(
            isSearching
                ? 'No history books found'
                : 'No history books available',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),

          if (isSearching) ...[
            const SizedBox(height: 5),
            const Text(
              'Try another search.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

