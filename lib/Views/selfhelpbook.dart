      // import 'package:bookverse/Views/BookDetails.dart';
      // import 'package:bookverse/Widgets/Booklistwidget.dart';
      // import 'package:flutter/material.dart';

      // class SelfHelpBooksScreen extends StatelessWidget {
      //   const SelfHelpBooksScreen({super.key});

      //   static const List<GenreBookData> _books = [
      //     GenreBookData(
      //       title: 'Atomic Habits',
      //       author: 'James Clear',
      //       imageUrl: 'https://m.media-amazon.com/images/I/91bYsX41DVL._SL1500_.jpg',
      //       rating: 4.8,
      //       ratingCount: '24,102',
      //     ),
      //     GenreBookData(
      //       title: 'The Psychology of Money',
      //       author: 'Morgan Housel',
      //       imageUrl: 'https://covers.openlibrary.org/b/isbn/9780857197689-L.jpg',
      //       rating: 4.7,
      //       ratingCount: '13,540',
      //     ),
      //     GenreBookData(
      //       title: 'Rich Dad Poor Dad',
      //       author: 'Robert T. Kiyosaki',
      //       imageUrl: 'https://m.media-amazon.com/images/I/81bsw6fnUiL._SL1500_.jpg',
      //       rating: 4.5,
      //       ratingCount: '19,870',
      //     ),
      //     GenreBookData(
      //       title: 'The 5 AM Club',
      //       author: 'Robin Sharma',
      //       imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSJpo2D8xGqD5N4l0r0ZwMl5Tdgvbx0SdCDLSPMd0DZ8g&s=10',
      //       rating: 4.4,
      //       ratingCount: '7,320',
      //     ),
      //     GenreBookData(
      //       title: 'Can\'t Hurt Me',
      //       author: 'David Goggins',
      //       imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQGEAbkQ3OS2z4qYyyvKHFkyLYAOLUjfN8pgMPvcKXD2Q&s=10',
      //       rating: 4.9,
      //       ratingCount: '15,690',
      //     ),
      //     GenreBookData(
      //       title: 'The Power of Now',
      //       author: 'Eckhart Tolle',
      //       imageUrl: 'https://m.media-amazon.com/images/I/61ipn3zChbL._AC_UF1000,1000_QL80_.jpg',
      //       rating: 4.6,
      //       ratingCount: '11,205',
      //     ),
      //   ];

      //   @override
      //   Widget build(BuildContext context) {
      //     return Scaffold(
      //       // Background is a gradient — green at the top, fading down to white.
      //       body: Container(
      //         width: double.infinity,
      //         height: double.infinity,
      //         decoration: const BoxDecoration(
      //           gradient: LinearGradient(
      //             begin: Alignment.topCenter,
      //             end: Alignment.bottomCenter,
      //             colors: [
      //               Color(0xFF10B981), // green, top
      //               Color(0xFFD1FAE5), // fading lighter
      //               Colors.white, // white, bottom
      //             ],
      //             stops: [0.0, 0.28, 0.55],
      //           ),
      //         ),
      //         child: SafeArea(
      //           child: Column(
      //             children: [
      //               // Header
      //               Padding(
      //                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      //                 child: Row(
      //                   children: [
      //                     IconButton(
      //                       onPressed: () => Navigator.maybePop(context),
      //                       icon: const Icon(Icons.arrow_back, color: Colors.white),
      //                     ),
      //                     const Text(
      //                       'Self-Help',
      //                       style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white),
      //                     ),
      //                   ],
      //                 ),
      //               ),

      //               // Search bar
      //               Padding(
      //                 padding: const EdgeInsets.symmetric(horizontal: 18),
      //                 child: Container(
      //                   padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      //                   decoration: BoxDecoration(
      //                     color: Colors.white.withOpacity(0.9),
      //                     borderRadius: BorderRadius.circular(14),
      //                     border: Border.all(color: const Color(0xFFECECF2)),
      //                   ),
      //                   child: const Row(
      //                     children: [
      //                       Icon(Icons.search_rounded, color: Colors.grey, size: 20),
      //                       SizedBox(width: 8),
      //                       Text('Search self-help books...', style: TextStyle(color: Colors.grey, fontSize: 13.5)),
      //                     ],
      //                   ),
      //                 ),
      //               ),

      //               const SizedBox(height: 18),

      //               // Book list — the SAME GenreBookListItem widget used in
      //               // the Fantasy/Romance screens, called again for each book
      //               // with different arguments.
      //               Expanded(
      //                 child: ListView.builder(
      //                   padding: const EdgeInsets.symmetric(horizontal: 18),
      //                   itemCount: _books.length,
      //                   itemBuilder: (context, index) {
      //                     return GenreBookListItem(
      //                       book: _books[index],
      //                       onTap: () {
      //                         Navigator.push(context, MaterialPageRoute(builder: (context) => const BookDetailsScreen()));
      //                       },
      //                     );
      //                   },
      //                 ),
      //               ),
      //             ],
      //           ),
      //         ),
      //       ),
      //     );
      //   }
      // }