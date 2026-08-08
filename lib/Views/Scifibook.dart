// import 'package:bookverse/Views/BookDetails.dart';
// import 'package:bookverse/Widgets/Booklistwidget.dart';
// import 'package:flutter/material.dart';

// class SciFiBooksScreen extends StatelessWidget {
//   const SciFiBooksScreen({super.key});

//   static const List<GenreBookData> _books = [
//     GenreBookData(
//       title: 'Dune',
//       author: 'Frank Herbert',
//       imageUrl: 'https://covers.openlibrary.org/b/isbn/9780441013593-L.jpg',
//       rating: 4.8,
//       ratingCount: '32,150',
//     ),
//     GenreBookData(
//       title: '1984',
//       author: 'George Orwell',
//       imageUrl: 'https://covers.openlibrary.org/b/isbn/9780451524935-L.jpg',
//       rating: 4.7,
//       ratingCount: '41,820',
//     ),
//     GenreBookData(
//       title: 'Foundation',
//       author: 'Isaac Asimov',
//       imageUrl: 'https://covers.openlibrary.org/b/isbn/9780553293357-L.jpg',
//       rating: 4.6,
//       ratingCount: '15,470',
//     ),
//     GenreBookData(
//       title: 'The Martian',
//       author: 'Andy Weir',
//       imageUrl: 'https://covers.openlibrary.org/b/isbn/9780553418026-L.jpg',
//       rating: 4.7,
//       ratingCount: '19,305',
//     ),
//     GenreBookData(
//       title: "Ender's Game",
//       author: 'Orson Scott Card',
//       imageUrl: 'https://covers.openlibrary.org/b/isbn/9780812550702-L.jpg',
//       rating: 4.6,
//       ratingCount: '22,690',
//     ),
//     GenreBookData(
//       title: 'Brave New World',
//       author: 'Aldous Huxley',
//       imageUrl: 'https://covers.openlibrary.org/b/isbn/9780060850524-L.jpg',
//       rating: 4.5,
//       ratingCount: '18,240',
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // Background is a gradient — electric blue at the top, fading down to white.
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color(0xFF0066FF), // electric blue, top
//               Color(0xFFBFDBFE), // fading lighter blue
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
//                       'Sci-Fi Books',
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
//                       Text('Search sci-fi books...', style: TextStyle(color: Colors.grey, fontSize: 13.5)),
//                     ],
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 18),

//               // Book list — the SAME GenreBookListItem widget used in
//               // the Fantasy/Romance/Self-Help/History screens, called
//               // again for each book with different arguments.
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