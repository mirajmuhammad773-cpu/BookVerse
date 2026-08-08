// import 'package:bookverse/Views/BookDetails.dart';
// import 'package:bookverse/Widgets/Booklistwidget.dart';
// import 'package:flutter/material.dart';

// class HistoryBooksScreen extends StatelessWidget {
//   const HistoryBooksScreen({super.key});

//   static const List<GenreBookData> _books = [
//     GenreBookData(
//       title: 'Sapiens: A Brief History of Humankind',
//       author: 'Yuval Noah Harari',
//       imageUrl: 'https://covers.openlibrary.org/b/isbn/9780062316097-L.jpg',
//       rating: 4.7,
//       ratingCount: '28,410',
//     ),
//     GenreBookData(
//       title: 'Guns, Germs, and Steel',
//       author: 'Jared Diamond',
//       imageUrl: 'https://covers.openlibrary.org/b/isbn/9780393317558-L.jpg',
//       rating: 4.5,
//       ratingCount: '12,860',
//     ),
//     GenreBookData(
//       title: 'A People\'s History of the United States',
//       author: 'Howard Zinn',
//       imageUrl: 'https://covers.openlibrary.org/b/isbn/9780062397348-L.jpg',
//       rating: 4.6,
//       ratingCount: '9,730',
//     ),
//     GenreBookData(
//       title: 'The Silk Roads',
//       author: 'Peter Frankopan',
//       imageUrl: 'https://covers.openlibrary.org/b/isbn/9781101912379-L.jpg',
//       rating: 4.5,
//       ratingCount: '6,215',
//     ),
//     GenreBookData(
//       title: '1776',
//       author: 'David McCullough',
//       imageUrl: 'https://covers.openlibrary.org/b/isbn/9780743226721-L.jpg',
//       rating: 4.6,
//       ratingCount: '8,940',
//     ),
//     GenreBookData(
//       title: 'SPQR: A History of Ancient Rome',
//       author: 'Mary Beard',
//       imageUrl: 'https://covers.openlibrary.org/b/isbn/9780871404237-L.jpg',
//       rating: 4.4,
//       ratingCount: '5,382',
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // Background is a gradient — vintage brown at the top, fading down to white.
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color(0xFF6F4E37), // vintage brown, top
//               Color(0xFFDCC7A8), // fading lighter tan
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
//                       'History',
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
//                       Text('Search history books...', style: TextStyle(color: Colors.grey, fontSize: 13.5)),
//                     ],
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 18),

//               // Book list — the SAME GenreBookListItem widget used in
//               // the Fantasy/Romance/Self-Help screens, called again for
//               // each book with different arguments.
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