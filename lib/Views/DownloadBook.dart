// lib/Screens/DownloadedBooksScreen.dart

import 'package:bookverse/Models/BookDownloadModel.dart';
import 'package:bookverse/ViewModels/BookDownloadProvider.dart';
import 'package:bookverse/Widgets/DownloadBookwidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DownloadedBooksScreen extends StatefulWidget {
  const DownloadedBooksScreen({
    super.key,
  });

  @override
  State<DownloadedBooksScreen> createState() =>
      _DownloadedBooksScreenState();
}

class _DownloadedBooksScreenState
    extends State<DownloadedBooksScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color purple =
      Color(0xFF6C4CE0);

  // ============================================================
  // SEARCH
  // ============================================================

  final TextEditingController _searchController =
      TextEditingController();

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

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!mounted) return;

        context
            .read<DownloadProvider>()
            .loadDownloadHistory();
      },
    );
  }

  // ============================================================
  // SEARCH CHANGE
  // ============================================================

  void _onSearchChanged() {
    if (!mounted) return;

    setState(() {
      _searchQuery =
          _searchController.text
              .trim()
              .toLowerCase();
    });
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
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
      backgroundColor:
          const Color(0xFFF7F7FB),

      body: SafeArea(
        child: Column(
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
                children: [

                  _iconButton(
                    Icons.arrow_back_rounded,
                    () {
                      Navigator.maybePop(
                        context,
                      );
                    },
                  ),

                  const SizedBox(
                    width: 35,
                  ),

                  const Text(
                    'Downloaded Books',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            // ==================================================
            // SEARCH BAR
            // ==================================================

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Row(
                children: [

                  Expanded(
                    child: Container(
                      decoration:
                          BoxDecoration(
                        color:
                            Colors.white,
                        borderRadius:
                            BorderRadius.circular(
                          30,
                        ),
                        border: Border.all(
                          color:
                              Colors.grey.shade200,
                        ),
                      ),
                      child: TextField(
                        controller:
                            _searchController,

                        decoration:
                            InputDecoration(
                          hintText:
                              'Search downloaded books...',

                          hintStyle:
                              TextStyle(
                            color:
                                Colors.grey.shade500,
                            fontSize: 13.5,
                          ),

                          prefixIcon:
                              const Icon(
                            Icons.search_rounded,
                            color:
                                Colors.grey,
                          ),

                          suffixIcon:
                              _searchQuery
                                      .isNotEmpty
                                  ? IconButton(
                                      onPressed:
                                          () {
                                        _searchController
                                            .clear();
                                      },
                                      icon:
                                          const Icon(
                                        Icons
                                            .close_rounded,
                                        size: 19,
                                        color:
                                            Colors.grey,
                                      ),
                                    )
                                  : null,

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

                  const SizedBox(
                    width: 10,
                  ),

                  // ==================================================
                  // REFRESH
                  // ==================================================

                  GestureDetector(
                    onTap: () {
                      context
                          .read<
                              DownloadProvider>()
                          .loadDownloadHistory();
                    },
                    child: Container(
                      padding:
                          const EdgeInsets.all(
                        12,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            Colors.white,
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                        border: Border.all(
                          color:
                              Colors.grey.shade200,
                        ),
                      ),
                      child:
                          const Icon(
                        Icons
                            .refresh_rounded,
                        color:
                            Colors.black87,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            // ==================================================
            // BOOK LIST
            // ==================================================

            Expanded(
              child:
                  Consumer<DownloadProvider>(
                builder: (
                  context,
                  provider,
                  child,
                ) {

                  // ============================================
                  // LOADING
                  // ============================================

                  if (provider.isLoading) {
                    return const Center(
                      child:
                          CircularProgressIndicator(
                        color: purple,
                      ),
                    );
                  }

                  // ============================================
                  // ERROR
                  // ============================================

                  if (provider.errorMessage !=
                      null) {
                    return _buildError(
                      provider,
                    );
                  }

                  // ============================================
                  // SEARCH FILTER
                  // ============================================

                  final books =
                      provider.downloads
                          .where(
                            (book) {
                              if (_searchQuery
                                  .isEmpty) {
                                return true;
                              }

                              final title =
                                  book.title
                                      .toLowerCase();

                              final author =
                                  book.author
                                      .toLowerCase();

                              return title.contains(
                                    _searchQuery,
                                  ) ||
                                  author.contains(
                                    _searchQuery,
                                  );
                            },
                          )
                          .toList();

                  // ============================================
                  // EMPTY
                  // ============================================

                  if (books.isEmpty) {
                    if (_searchQuery
                        .isNotEmpty) {
                      return _buildNoSearchResult();
                    }

                    return _buildEmptyState();
                  }

                  // ============================================
                  // LIST
                  // ============================================

                  return RefreshIndicator(
                    color: purple,

                    onRefresh: () async {
                      await provider
                          .loadDownloadHistory();
                    },

                    child:
                        ListView.builder(
                      physics:
                          const AlwaysScrollableScrollPhysics(),

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

                      itemBuilder:
                          (
                        context,
                        index,
                      ) {
                        final download =
                            books[index];

                        return DownloadedBookItem(
                          book:
                              _convertToWidgetModel(
                            download,
                          ),

                          // ==================================
                          // OPEN BOOK
                          // ==================================

                          onTap: () {
                            _openDownloadedBook(
                              download,
                            );
                          },

                          // ==================================
                          // MORE
                          // ==================================

                          onMoreTap: () {
                            _showBookOptions(
                              context,
                              download,
                            );
                          },
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
  // CONVERT DOWNLOAD MODEL → WIDGET MODEL
  // ============================================================

  DownloadedBook _convertToWidgetModel(
    DownloadModel download,
  ) {
    return DownloadedBook(
      title: download.title,
      author: download.author,

      sizeLabel:
          download.formattedFileSize,

      // DownloadModel mein progress field nahi hai.
      // History mein saved book already downloaded hai.
      progress: 100,

      coverColor:
          const Color(0xFFE8E5F8),

      textColor:
          purple,
    );
  }

  // ============================================================
  // OPEN DOWNLOADED BOOK
  // ============================================================

  Future<void> _openDownloadedBook(
    DownloadModel download,
  ) async {
    if (download.localFilePath.isEmpty) {
      _showMessage(
        'Downloaded file is not available.',
      );

      return;
    }

    final provider =
        context.read<DownloadProvider>();

    try {
      final localBook =
          await provider.getDownloadedBook(
        download.bookId,
      );

      if (!mounted) return;

      if (localBook == null) {
        _showMessage(
          'Downloaded book could not be found.',
        );

        return;
      }

      // --------------------------------------------------------
      // IMPORTANT
      // --------------------------------------------------------
      //
      // Aapka current ReaderScreen HTTP URL se book load karta hai.
      // Is liye localFilePath ko direct ReaderScreen mein bhejna
      // tabhi possible hoga jab ReaderScreen mein local file support
      // add ki jaye.
      //
      // Filhaal downloaded file verify kar rahe hain.
      // --------------------------------------------------------

      _showMessage(
        '${localBook.title} is downloaded and ready to read.',
      );

    } catch (e) {
      debugPrint(
        'Open downloaded book error: $e',
      );

      _showMessage(
        'Unable to open downloaded book.',
      );
    }
  }

  // ============================================================
  // MORE OPTIONS
  // ============================================================

  void _showBookOptions(
    BuildContext context,
    DownloadModel download,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          Colors.white,

      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),

      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              20,
            ),

            child: Column(
              mainAxisSize:
                  MainAxisSize.min,

              children: [

                // ==========================================
                // HANDLE
                // ==========================================

                Container(
                  width: 40,
                  height: 4,
                  decoration:
                      BoxDecoration(
                    color:
                        Colors.grey.shade300,
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                // ==========================================
                // TITLE
                // ==========================================

                Text(
                  download.title,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                // ==========================================
                // DELETE
                // ==========================================

                ListTile(
                  leading:
                      Container(
                    padding:
                        const EdgeInsets.all(
                      9,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          Colors.red.shade50,
                      borderRadius:
                          BorderRadius.circular(
                        10,
                      ),
                    ),
                    child: Icon(
                      Icons
                          .delete_outline_rounded,
                      color:
                          Colors.red.shade600,
                    ),
                  ),

                  title:
                      const Text(
                    'Remove Download',
                    style:
                        TextStyle(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  subtitle:
                      const Text(
                    'Delete this book from your device',
                    style:
                        TextStyle(
                      fontSize: 11,
                      color:
                          Colors.grey,
                    ),
                  ),

                  onTap: () {
                    Navigator.pop(
                      sheetContext,
                    );

                    _confirmDelete(
                      download,
                    );
                  },
                ),

                const SizedBox(
                  height: 6,
                ),

                // ==========================================
                // CANCEL
                // ==========================================

                ListTile(
                  leading:
                      const Icon(
                    Icons.close_rounded,
                    color:
                        Colors.grey,
                  ),

                  title:
                      const Text(
                    'Cancel',
                  ),

                  onTap: () {
                    Navigator.pop(
                      sheetContext,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // CONFIRM DELETE
  // ============================================================

  void _confirmDelete(
    DownloadModel download,
  ) {
    showDialog(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              18,
            ),
          ),

          title:
              const Text(
            'Remove Download?',
          ),

          content:
              Text(
            'Are you sure you want to remove "${download.title}" from your downloaded books?',
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child:
                  const Text(
                'Cancel',
              ),
            ),

            TextButton(
              onPressed: () async {
                Navigator.pop(
                  dialogContext,
                );

                final provider =
                    context.read<
                        DownloadProvider>();

                final success =
                    await provider
                        .deleteDownloadedBook(
                  download.bookId,
                );

                if (!mounted) return;

                _showMessage(
                  success
                      ? 'Download removed.'
                      : provider.errorMessage ??
                          'Unable to remove download.',
                );
              },

              child:
                  const Text(
                'Remove',
                style:
                    TextStyle(
                  color:
                      Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),

        child: Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [

            Container(
              padding:
                  const EdgeInsets.all(18),

              decoration:
                  BoxDecoration(
                color:
                    purple.withOpacity(0.10),
                shape:
                    BoxShape.circle,
              ),

              child:
                  const Icon(
                Icons
                    .download_for_offline_rounded,
                size: 42,
                color: purple,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            const Text(
              'No downloaded books',
              style:
                  TextStyle(
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

            const Text(
              'Books you download will appear here.',
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
                fontSize: 12.5,
                color:
                    Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // NO SEARCH RESULT
  // ============================================================

  Widget _buildNoSearchResult() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),

        child: Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [

            const Icon(
              Icons.search_off_rounded,
              size: 44,
              color: Colors.grey,
            ),

            const SizedBox(
              height: 12,
            ),

            const Text(
              'No books found',
              style:
                  TextStyle(
                fontSize: 15,
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const SizedBox(
              height: 5,
            ),

            Text(
              'No downloaded book matches "$_searchQuery".',
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontSize: 12,
                color: Colors.grey,
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
    DownloadProvider provider,
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
              size: 42,
              color: Colors.grey,
            ),

            const SizedBox(
              height: 12,
            ),

            const Text(
              'Unable to load downloads',
              style:
                  TextStyle(
                fontSize: 15,
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              provider.errorMessage ??
                  'Something went wrong.',
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            ElevatedButton.icon(
              onPressed: () {
                provider
                    .loadDownloadHistory();
              },

              icon:
                  const Icon(
                Icons.refresh_rounded,
                size: 18,
              ),

              label:
                  const Text(
                'Try Again',
              ),

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    purple,
                foregroundColor:
                    Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ICON BUTTON
  // ============================================================

  Widget _iconButton(
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding:
            const EdgeInsets.all(8),

        decoration:
            BoxDecoration(
          color:
              Colors.white,
          shape:
              BoxShape.circle,
          border:
              Border.all(
            color:
                Colors.grey.shade200,
          ),
        ),

        child: Icon(
          icon,
          size: 18,
          color:
              Colors.black87,
        ),
      ),
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content:
              Text(message),
          behavior:
              SnackBarBehavior.floating,
          duration:
              const Duration(
            seconds: 2,
          ),
        ),
      );
  }
}