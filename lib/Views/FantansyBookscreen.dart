
// lib/Screens/FantasyBooksScreen.dart

// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:bookverse/Models/BookModel.dart';
import 'package:bookverse/ViewModels/Book-view-model.dart';
import 'package:bookverse/Widgets/bookwidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'BookDetails.dart';

class FantasyBooksScreen extends StatefulWidget {
  const FantasyBooksScreen({super.key});

  @override
  State<FantasyBooksScreen> createState() =>
      _FantasyBooksScreenState();
}

class _FantasyBooksScreenState
    extends State<FantasyBooksScreen> {

  static const Color purple = Color(0xFF6C4CE0);

  // Maximum fantasy books
  static const int maxBooks = 200;

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

      if (viewModel.fantasyBooks.isEmpty) {
        viewModel.loadFantasyBooks();
      }
    });
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void _onSearchChanged() {
    final query = _searchController.text.trim();

    if (mounted) {
      setState(() {
        _searchQuery = query;
      });
    }

    _searchDebounce?.cancel();

    // Empty search
    if (query.isEmpty) {
      final viewModel = context.read<BookViewModel>();

      viewModel.clearFantasySearch();

      if (viewModel.fantasyBooks.isEmpty) {
        viewModel.loadFantasyBooks();
      }

      return;
    }

    // Search after 500ms
    _searchDebounce = Timer(
      const Duration(milliseconds: 500),
      () {
        if (!mounted) return;

        context
            .read<BookViewModel>()
            .searchFantasyBooks(query);
      },
    );
  }

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
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: purple,
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
          'Fantasy Books',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),

      backgroundColor: const Color(0xFFF7F7FB),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        child: Column(
          children: [
             SizedBox(height: 12),
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
                        'Search fantasy books...',

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
                                    .auto_awesome_rounded,
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

            const SizedBox(height: 14),

            // ==================================================
            // BOOK LIST
            // ==================================================

            Expanded(
              child: Consumer<BookViewModel>(
                builder: (
                  context,
                  viewModel,
                  child,
                ) {

                  // ==================================================
                  // SEARCH LOADING
                  // ==================================================

                  if (_searchQuery.isNotEmpty &&
                      viewModel.isSearching) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: purple,
                      ),
                    );
                  }

                  // ==================================================
                  // INITIAL LOADING
                  // ==================================================

                  if (_searchQuery.isEmpty &&
                      viewModel.isLoading &&
                      viewModel.fantasyBooks.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: purple,
                      ),
                    );
                  }

                  // ==================================================
                  // GET FANTASY BOOKS
                  // ==================================================

                  final List<BookModel> books =
                      _getBooks(viewModel);

                  // ==================================================
                  // ERROR
                  // ==================================================

                  if (viewModel.errorMessage != null &&
                      books.isEmpty) {
                    return _buildError(viewModel);
                  }

                  // ==================================================
                  // EMPTY
                  // ==================================================

                  if (books.isEmpty) {
                    return _buildEmpty();
                  }

                  // ==================================================
                  // BOOK LIST
                  // ==================================================

                  return ListView.builder(
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

                    itemBuilder: (
                      context,
                      index,
                    ) {
                      final book = books[index];

                      return Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom: 12,
                        ),

                        // ==========================================
                        // REUSABLE BOOK CARD
                        // ==========================================

                        child: BookCardWidget(
                          book: book,

                          onTap: () {
                            _openBookDetails(book);
                          },
                        ),
                      );
                    },
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
  // GET BOOKS
  // ============================================================

  List<BookModel> _getBooks(
    BookViewModel viewModel,
  ) {

    // Normal Fantasy Books
    if (_searchQuery.isEmpty) {
      return viewModel.fantasyBooks
          .cast<BookModel>()
          .take(maxBooks)
          .toList();
    }

    // Fantasy Search Results
    return viewModel.fantasySearchResults
        .cast<BookModel>()
        .toList();
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError(
    BookViewModel viewModel,
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
              _searchQuery.isNotEmpty
                  ? 'Unable to search fantasy books'
                  : 'Unable to load fantasy books',

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

                if (_searchQuery.isNotEmpty) {
                  viewModel.searchFantasyBooks(
                    _searchQuery,
                  );
                } else {
                  viewModel.loadFantasyBooks();
                }
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: purple,
                foregroundColor: Colors.white,
                elevation: 0,

                shape:
                    RoundedRectangleBorder(
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

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [

          const Icon(
            Icons.auto_awesome_outlined,
            size: 45,
            color: Colors.grey,
          ),

          const SizedBox(height: 12),

          Text(
            _searchQuery.isEmpty
                ? 'No fantasy books available'
                : 'No fantasy books found',

            textAlign: TextAlign.center,

            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),

          if (_searchQuery.isNotEmpty) ...[
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

