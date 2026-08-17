// lib/Screens/FavouriteBooksScreen.dart

import 'package:bookverse/Models/BookModel.dart';
import 'package:bookverse/ViewModels/FavoriteBookProvider.dart';
import 'package:bookverse/Views/BookDetails.dart';
import 'package:bookverse/Widgets/Booklistwidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavouriteBooksScreen extends StatefulWidget {
  const FavouriteBooksScreen({
    super.key,
  });

  @override
  State<FavouriteBooksScreen> createState() =>
      _FavouriteBooksScreenState();
}

class _FavouriteBooksScreenState
    extends State<FavouriteBooksScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color purple =
      Color(0xFF6C4CE0);

  // ============================================================
  // CONTROLLER
  // ============================================================

  final TextEditingController _searchController =
      TextEditingController();

  // ============================================================
  // SEARCH
  // ============================================================

  String _searchQuery = '';

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // FILTER BOOKS
  // ============================================================

  List<BookModel> _filteredBooks(
    List<BookModel> books,
  ) {
    final query =
        _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return books;
    }

    return books.where((book) {
      final title =
          book.title.toLowerCase();

      final author =
          book.author.toLowerCase();

      return title.contains(query) ||
          author.contains(query);
    }).toList();
  }

  // ============================================================
  // OPEN BOOK DETAILS
  // ============================================================

  void _openBook(
    BookModel book,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            BookDetailsScreen(
          book: book,
        ),
      ),
    );
  }

  // ============================================================
  // CLEAR SEARCH
  // ============================================================

  void _clearSearch() {
    _searchController.clear();

    setState(() {
      _searchQuery = '';
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F7FB),

      body: SafeArea(
        child: Consumer<
            FavouriteBooksProvider>(
          builder: (
            context,
            favouriteProvider,
            child,
          ) {
            final allBooks =
                favouriteProvider.favoriteBooks;

            final books =
                _filteredBooks(allBooks);

            return Column(
              children: [

                // ==================================================
                // HEADER
                // ==================================================

                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    0,
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [

                            const Text(
                              'Favourite Books',
                              style:
                                  TextStyle(
                                fontSize: 19,
                                fontWeight:
                                    FontWeight.bold,
                                color:
                                    Colors.black87,
                              ),
                            ),

                            const SizedBox(
                              height: 2,
                            ),

                            Text(
                              'Your saved and favorite books collection',
                              style:
                                  TextStyle(
                                fontSize: 11.5,
                                color: Colors
                                    .grey
                                    .shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                // ==================================================
                // SEARCH
                // ==================================================

                Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: Container(
                    decoration:
                        BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(
                        30,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(
                            0.04,
                          ),
                          blurRadius: 8,
                          offset:
                              const Offset(
                            0,
                            2,
                          ),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller:
                          _searchController,

                      onChanged:
                          (value) {
                        setState(() {
                          _searchQuery =
                              value;
                        });
                      },

                      textInputAction:
                          TextInputAction.search,

                      decoration:
                          InputDecoration(
                        hintText:
                            'Search your favorite books...',

                        hintStyle:
                            TextStyle(
                          color: Colors
                              .grey
                              .shade500,
                          fontSize: 13.5,
                        ),

                        prefixIcon:
                            const Icon(
                          Icons
                              .search_rounded,
                          color:
                              Colors.grey,
                        ),

                        suffixIcon:
                            _searchQuery
                                    .isNotEmpty
                                ? IconButton(
                                    tooltip:
                                        'Clear search',
                                    onPressed:
                                        _clearSearch,
                                    icon:
                                        const Icon(
                                      Icons
                                          .close_rounded,
                                      color:
                                          Colors.grey,
                                    ),
                                  )
                                : const Icon(
                                    Icons
                                        .tune_rounded,
                                    color:
                                        purple,
                                  ),

                        border:
                            InputBorder.none,

                        enabledBorder:
                            InputBorder.none,

                        focusedBorder:
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

                const SizedBox(
                  height: 14,
                ),

                // ==================================================
                // COLLECTION COUNT
                // ==================================================

                Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: Row(
                    children: [

                      Container(
                        padding:
                            const EdgeInsets.all(
                          8,
                        ),
                        decoration:
                            BoxDecoration(
                          color: purple
                              .withOpacity(
                            0.12,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            10,
                          ),
                        ),
                        child:
                            const Icon(
                          Icons
                              .favorite_rounded,
                          color: purple,
                          size: 16,
                        ),
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [

                            Text(
                              '${allBooks.length} Books',
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),

                            const Text(
                              'in your collection',
                              style:
                                  TextStyle(
                                fontSize: 11,
                                color:
                                    Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // SEARCH RESULT COUNT
                      if (_searchQuery
                          .trim()
                          .isNotEmpty)
                        Text(
                          '${books.length} found',
                          style:
                              const TextStyle(
                            fontSize: 11,
                            color:
                                Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                // ==================================================
                // BOOK LIST
                // ==================================================

                Expanded(
                  child: books.isEmpty
                      ? _buildEmptyState(
                          hasSearch:
                              _searchQuery
                                  .trim()
                                  .isNotEmpty,
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets
                                  .fromLTRB(
                            16,
                            0,
                            16,
                            20,
                          ),

                          itemCount:
                              books.length,

                          physics:
                              const BouncingScrollPhysics(),

                          itemBuilder:
                              (
                            context,
                            index,
                          ) {
                            final book =
                                books[index];

                            return FavouriteApiBookCard(
                              book: book,

                              isFavorite:
                                  favouriteProvider
                                      .isFavorite(
                                book,
                              ),

                              onTap: () {
                                _openBook(
                                  book,
                                );
                              },

                              onFavoriteTap:
                                  () {
                                favouriteProvider
                                    .toggleFavorite(
                                  book,
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState({
    required bool hasSearch,
  }) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [

            Container(
              width: 70,
              height: 70,
              decoration:
                  BoxDecoration(
                color: purple
                    .withOpacity(
                  0.10,
                ),
                shape:
                    BoxShape.circle,
              ),
              child:
                  const Icon(
                Icons
                    .favorite_border_rounded,
                color: purple,
                size: 34,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            Text(
              hasSearch
                  ? 'No books found'
                  : 'No Favourite Books',
              style:
                  const TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.bold,
                color:
                    Colors.black87,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              hasSearch
                  ? 'Try another book title or author.'
                  : 'Books you mark as favorite will appear here.',
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontSize: 12.5,
                color:
                    Colors.grey,
              ),
            ),

            // ==================================================
            // CLEAR SEARCH BUTTON
            // ==================================================

            if (hasSearch) ...[
              const SizedBox(
                height: 14,
              ),

              TextButton(
                onPressed:
                    _clearSearch,
                child:
                    const Text(
                  'Clear Search',
                  style:
                      TextStyle(
                    color: purple,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}