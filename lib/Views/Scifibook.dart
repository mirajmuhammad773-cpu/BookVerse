
// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:bookverse/Models/BookModel.dart';
import 'package:bookverse/ViewModels/Book-view-model.dart';
import 'package:bookverse/Widgets/bookwidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'BookDetails.dart';

class SciFiBooksScreen extends StatefulWidget {
  const SciFiBooksScreen({
    super.key,
  });

  @override
  State<SciFiBooksScreen> createState() =>
      _SciFiBooksScreenState();
}

class _SciFiBooksScreenState
    extends State<SciFiBooksScreen> {

  // ============================================================
  // MAX BOOKS
  // ============================================================

  static const int maxBooks = 200;

  // ============================================================
  // SEARCH
  // ============================================================

  final TextEditingController _searchController =
      TextEditingController();

  Timer? _searchDebounce;

  String _searchQuery = '';

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _searchController.addListener(
      _onSearchChanged,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final viewModel =
          context.read<BookViewModel>();

      if (viewModel.sciFiBooks.isEmpty) {
        viewModel.loadSciFiBooks();
      }
    });
  }

  // ============================================================
  // SEARCH LISTENER
  // ============================================================

  void _onSearchChanged() {
    final query =
        _searchController.text.trim();

    if (mounted) {
      setState(() {
        _searchQuery = query;
      });
    }

    _searchDebounce?.cancel();

    // ==========================================================
    // EMPTY SEARCH
    // ==========================================================

    if (query.isEmpty) {
      final viewModel =
          context.read<BookViewModel>();

      viewModel.clearSciFiSearch();

      if (viewModel.sciFiBooks.isEmpty) {
        viewModel.loadSciFiBooks();
      }

      return;
    }

    // ==========================================================
    // SEARCH DEBOUNCE
    // ==========================================================

    _searchDebounce = Timer(
      const Duration(milliseconds: 500),
      () {
        if (!mounted) return;

        context
            .read<BookViewModel>()
            .searchSciFiBooks(query);
      },
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
  // OPEN DETAILS
  // ============================================================

  void _openBookDetails(
    BookModel book,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            BookDetailsScreen(
          book: book,
        ),
      ),
    );
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refreshBooks() async {
    final viewModel =
        context.read<BookViewModel>();

    await viewModel.loadSciFiBooks();
  }

  // ============================================================
  // GET BOOKS
  // ============================================================

  List<BookModel> _getBooks(
    BookViewModel viewModel,
  ) {
    if (_searchQuery.isEmpty) {
      return viewModel.sciFiBooks
          .take(maxBooks)
          .toList();
    }

    return viewModel.sciFiSearchResults
        .toList();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            const Color.fromARGB(
          255,
          65,
          113,
          216,
        ),
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
          'Sci-Fi Books',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),

      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [

            const SizedBox(height: 16),

            // ==================================================
            // SEARCH BAR
            // ==================================================

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 18,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(14),
                  border: Border.all(
                    color:
                        const Color(0xFFECECF2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.06),
                      blurRadius: 10,
                      offset:
                          const Offset(0, 4),
                    ),
                  ],
                ),

                child: TextField(
                  controller:
                      _searchController,

                  textInputAction:
                      TextInputAction.search,

                  textCapitalization:
                      TextCapitalization.sentences,

                  decoration:
                      InputDecoration(
                    hintText:
                        'Search sci-fi books...',

                    hintStyle: TextStyle(
                      color:
                          Colors.grey.shade500,
                      fontSize: 13.5,
                    ),

                    prefixIcon:
                        const Icon(
                      Icons.search_rounded,
                      color: Colors.grey,
                      size: 21,
                    ),

                    suffixIcon:
                        _searchQuery.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _searchController
                                      .clear();
                                },
                                icon:
                                    const Icon(
                                  Icons
                                      .close_rounded,
                                  color:
                                      Colors.blue,
                                ),
                              )
                            : const Icon(
                                Icons
                                    .auto_awesome_rounded,
                                color:
                                    Colors.grey,
                                size: 20,
                              ),

                    border:
                        InputBorder.none,

                    contentPadding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ==================================================
            // BOOK LIST
            // ==================================================

            Expanded(
              child:
                  Consumer<BookViewModel>(
                builder: (
                  context,
                  viewModel,
                  child,
                ) {

                  // ==================================================
                  // SEARCH LOADING
                  // ==================================================

                  if (_searchQuery
                          .isNotEmpty &&
                      viewModel.isSearching) {
                    return _buildLoading();
                  }

                  // ==================================================
                  // INITIAL LOADING
                  // ==================================================

                  if (_searchQuery.isEmpty &&
                      viewModel.isLoading &&
                      viewModel.sciFiBooks
                          .isEmpty) {
                    return _buildLoading();
                  }

                  // ==================================================
                  // CURRENT BOOKS
                  // ==================================================

                  final books =
                      _getBooks(viewModel);

                  // ==================================================
                  // ERROR
                  // ==================================================

                  if (viewModel.errorMessage !=
                          null &&
                      books.isEmpty) {
                    return _buildError(
                      viewModel,
                    );
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

                  return RefreshIndicator(
                    color: Colors.grey,

                    onRefresh:
                        _refreshBooks,

                    child:
                        ListView.builder(
                      physics:
                          const AlwaysScrollableScrollPhysics(
                        parent:
                            BouncingScrollPhysics(),
                      ),

                      padding:
                          const EdgeInsets
                              .fromLTRB(
                        18,
                        2,
                        18,
                        25,
                      ),

                      itemCount:
                          books.length,

                      itemBuilder:
                          (
                        context,
                        index,
                      ) {
                        final book =
                            books[index];

                        return Padding(
                          padding:
                              const EdgeInsets
                                  .only(
                            bottom: 12,
                          ),

                          // ==================================================
                          // CUSTOM BOOK CARD WIDGET
                          // ==================================================

                          child:
                              BookCardWidget(
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
  // LOADING
  // ============================================================

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: Colors.grey,
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError(
    BookViewModel viewModel,
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
              _searchQuery.isNotEmpty
                  ? 'Unable to search sci-fi books'
                  : 'Unable to load sci-fi books',

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

            Text(
              viewModel.errorMessage ??
                  'Please check your internet connection and try again.',

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            ElevatedButton(
              onPressed: () {
                if (_searchQuery
                    .isNotEmpty) {
                  viewModel
                      .searchSciFiBooks(
                    _searchQuery,
                  );
                } else {
                  viewModel
                      .loadSciFiBooks();
                }
              },

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.grey,
                foregroundColor:
                    Colors.white,
                elevation: 0,

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
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

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize:
            MainAxisSize.min,

        children: [

          const Icon(
            Icons.auto_awesome_outlined,
            size: 45,
            color: Colors.grey,
          ),

          const SizedBox(
            height: 12,
          ),

          Text(
            _searchQuery.isEmpty
                ? 'No sci-fi books available'
                : 'No sci-fi books found',

            textAlign:
                TextAlign.center,

            style:
                const TextStyle(
              fontSize: 15,
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          if (_searchQuery
              .isNotEmpty) ...[
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
}

