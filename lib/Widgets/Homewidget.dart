// lib/Widgets/HomeHeader.dart
// ignore_for_file: unnecessary_non_null_assertion, unnecessary_null_comparison

import 'package:bookverse/Views/FantansyBookscreen.dart';
import 'package:bookverse/Views/RomanceBook.dart';
import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final String avatarUrl;
  final bool hasNotification;
  final VoidCallback? onBellTap;
  final VoidCallback? onAvatarTap;

  const HomeHeader({
    super.key,
    required this.userName,
    required this.avatarUrl,
    this.hasNotification = true,
    this.onBellTap,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text('Hello, $userName ', style: const TextStyle(fontSize: 15, color: Colors.black87)),
                const Text('👋', style: TextStyle(fontSize: 15)),
              ]),
              const SizedBox(height: 6),
              const Text('Find your\nnext favorite book',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.25)),
            ],
          ),
        ),
        GestureDetector(
          onTap: onBellTap,
          child: Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 10),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Stack(
              children: [
                const Center(child: Icon(Icons.notifications_none_rounded, color: Colors.black54, size: 20)),
                if (hasNotification)
                  Positioned(
                    top: 9,
                    right: 9,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: onAvatarTap,
          child: CircleAvatar(radius: 20, backgroundImage: NetworkImage(avatarUrl)),
        ),
      ],
    );
  }
}


class BookSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;

  const BookSearchBar({super.key, this.onChanged, this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return Container(
              height: 40,

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextField(
        onChanged: onChanged,
        onSubmitted: (_) => onSubmitted?.call(),
        decoration: InputDecoration(
          hintText: 'Search books, authors...',
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12,),
        ),
      ),
    );
  }
}



class BookCategory {
  final IconData icon;
  final String label;
  final Color color;
  const BookCategory(this.icon, this.label, this.color);
}

class CategoryList extends StatelessWidget {
  final VoidCallback? onSeeAll;

  const CategoryList({super.key, this.onSeeAll, required Null Function(BookCategory) onCategoryTap});

  static const categories = [
    BookCategory(Icons.auto_awesome_rounded, 'Fantasy', Color(0xFFE9E4FF)),
    BookCategory(Icons.favorite_rounded, 'Romance', Color(0xFFFFE4EC)),
    BookCategory(Icons.wb_sunny_rounded, 'Self Help', Color(0xFFFFEFD9)),
    BookCategory(Icons.account_balance_rounded, 'History', Color(0xFFF3E4FF)),
    BookCategory(Icons.rocket_launch_rounded, 'Sci-Fi', Color(0xFFDCEBFF)),
    BookCategory(Icons.more_horiz_rounded, 'More', Color(0xFFEFEFEF)),
  ];

  // Fantasy -> FantasyScreen, Romance -> RomanceScreen, and so on —
  // each category navigates to its OWN dedicated screen class, per
  // your request, instead of one shared/generic screen.
  void _handleCategoryTap(BuildContext context, String label) {
    Widget? screen;
    switch (label) {
      case 'Fantasy':
        screen = const FantasyBooksScreen();
        break;
      case 'Romance':
        screen = const RomanceBooksScreen();
        break;
      case 'Self Help':
        // screen = const SelfHelpBooksScreen();
        break;
      case 'History':
        // screen = const HistoryBooksScreen();
        break;
      case 'Sci-Fi':
        // screen = const SciFiBooksScreen();
        break;
      case 'More':
        _showMoreCategoriesSheet(context);
        return;
    }

    if (screen != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => screen!));
    }
  }

  // 'More' isn't its own genre — show a quick picker that opens the
  // same 5 dedicated screens above.
  void _showMoreCategoriesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text('All Categories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                for (final c in categories.where((c) => c.label != 'More'))
                  ListTile(
                    leading: Icon(c.icon, color: Colors.black54),
                    title: Text(c.label),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _handleCategoryTap(context, c.label);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Categories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            GestureDetector(
              onTap: onSeeAll,
              child: Text('See All', style: TextStyle(fontSize: 12, color: Colors.deepPurple.shade300)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 74,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final c = categories[i];
              return GestureDetector(
                onTap: () => _handleCategoryTap(context, c.label),
                child: SizedBox(
                  width: 58,
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(color: c.color, shape: BoxShape.circle),
                        child: Icon(c.icon, color: Colors.black54, size: 20),
                      ),
                      const SizedBox(height: 6),
                      Text(c.label, style: const TextStyle(fontSize: 10, color: Colors.black54)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ContinueReadingCard extends StatelessWidget {
  final String title;
  final String author;
  final double progress; // 0..1
  final Color coverColor;
  final String? coverImageUrl; // NEW: optional network image for the cover
  final VoidCallback? onTap;

  const ContinueReadingCard({
    super.key,
    required this.title,
    required this.author,
    required this.progress,
    required this.coverColor,
    this.coverImageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            _buildCover(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                  Text(author, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 5,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(coverColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text('${(progress * 100).round()}%', style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  // Row mein sabse pehle real cover image dikhati hai (agar URL diya
  // ho); image na ho ya load fail ho jaye to wahi purana color-block
  // fallback (title text ke sath) dikha deta hai — kabhi khali/crash
  // nahi hota.
  Widget _buildCover() {
    final placeholder = Container(
      width: 50,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: coverColor, borderRadius: BorderRadius.circular(8)),
      child: Text(
        title,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );

    if (coverImageUrl == null || coverImageUrl!.isEmpty) {
      return placeholder;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        coverImageUrl!,
        width: 50,
        height: 60,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progressEvent) {
          if (progressEvent == null) return child;
          return SizedBox(
            width: 50,
            height: 60,
            child: Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: coverColor),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => placeholder,
      ),
    );
  }
}

class BookBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BookBottomNav({super.key, required this.currentIndex, required this.onTap});

  static const items = [
    (Icons.home_rounded, 'Home'),
    (Icons.menu_book_rounded, 'Library'),
    (Icons.favorite_rounded, 'Favorites'),
    (Icons.calendar_month_rounded, 'Plans'),
    (Icons.person_rounded, 'Profile'),
  ];

  static const active = Color(0xFF6C4CE0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(items.length, (i) {
          final isActive = i == currentIndex;
          final (icon, label) = items[i];
          return GestureDetector(
            onTap: () => onTap(i),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 22, color: isActive ? active : Colors.grey),
                const SizedBox(height: 3),
                Text(label, style: TextStyle(fontSize: 10, color: isActive ? active : Colors.grey, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500)),
              ],
            ),
          );
        }),
      ),
    );
  }
}


/// Simple data model for one entry in the Famous Books list.

class FamousBook {
  final String title;
  final String author;
  final String imageUrl;

  const FamousBook({
    required this.title,
    required this.author,
    required this.imageUrl,
  });
}

class FamousBooksList extends StatelessWidget {
  final List<FamousBook> books;
  final void Function(FamousBook book)? onTap;

  // List ki total height
  final double height;

  // Har card ki width
  final double cardWidth;

  const FamousBooksList({
    super.key,
    required this.books,
    this.onTap,

    // Default values
    this.height = 250,
    this.cardWidth = 190,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,

      child: ListView.separated(
        scrollDirection: Axis.horizontal,

        // Agar HomeScreen ke andar hai to padding optional hai
        padding: const EdgeInsets.symmetric(horizontal: 16),

        itemCount: books.length,

        separatorBuilder: (_, __) =>
            const SizedBox(width: 14),

        itemBuilder: (context, index) {
          final book = books[index];

          return SizedBox(
            width: cardWidth,

            child: _FamousBookCard(
              book: book,
              onTap: onTap == null
                  ? null
                  : () => onTap!(book),
            ),
          );
        },
      ),
    );
  }
}

class _FamousBookCard extends StatelessWidget {
  final FamousBook book;
  final VoidCallback? onTap;

  const _FamousBookCard({
    required this.book,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(18),

          border: Border.all(
            color: Colors.grey.shade200,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        clipBehavior: Clip.antiAlias,

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // =========================
            // BOOK COVER
            // =========================

            Expanded(
              child: Image.network(
                book.imageUrl,

                width: double.infinity,

                fit: BoxFit.cover,

                loadingBuilder:
                    (context, child, progress) {
                  if (progress == null) {
                    return child;
                  }

                  return Container(
                    color: Colors.grey.shade100,

                    child: const Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,

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
                    color: Colors.grey.shade200,

                    child: const Center(
                      child: Icon(
                        Icons.menu_book_rounded,
                        color: Colors.grey,
                        size: 28,
                      ),
                    ),
                  );
                },
              ),
            ),

            // =========================
            // BOOK NAME + AUTHOR
            // =========================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                14,
                10,
                14,
                12,
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
                      fontSize: 14.5,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

