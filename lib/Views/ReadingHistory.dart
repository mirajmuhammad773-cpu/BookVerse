import 'package:bookverse/Widgets/ReadingHistoryWidget.dart';
import 'package:flutter/material.dart';

class ReadingHistoryScreen extends StatefulWidget {
  const ReadingHistoryScreen({super.key});

  @override
  State<ReadingHistoryScreen> createState() => _ReadingHistoryScreenState();
}

class _ReadingHistoryScreenState extends State<ReadingHistoryScreen> {
  static const _primary = Color(0xFF6366F1);

  int _selectedFilter = 0;
  final _filters = const ['All', 'In Progress', 'Completed', 'Saved'];

  final List<ReadingHistoryData> _history = const [
    ReadingHistoryData(
      title: 'Atomic Habits',
      author: 'James Clear',
      imageUrl: 'https://m.media-amazon.com/images/I/91bYsX41DVL._SL1500_.jpg',
      lastRead: 'Today, 9:20 AM',
      progress: 0.65,
      status: 'In Progress',
    ),
    ReadingHistoryData(
      title: 'The Psychology of Money',
      author: 'Morgan Housel',
      imageUrl: 'https://m.media-amazon.com/images/I/71g2ednj0JL._SL1500_.jpg',
      lastRead: 'Yesterday, 8:15 PM',
      progress: 0.42,
      status: 'In Progress',
    ),
    ReadingHistoryData(
      title: 'Rich Dad Poor Dad',
      author: 'Robert T. Kiyosaki',
      imageUrl: 'https://m.media-amazon.com/images/I/81bsw6fnUiL._SL1500_.jpg',
      lastRead: '2 days ago',
      progress: 0.28,
      status: 'In Progress',
    ),
    ReadingHistoryData(
      title: 'Think and Grow Rich',
      author: 'Napoleon Hill',
      imageUrl: 'https://m.media-amazon.com/images/I/71UypkUjStL._SL1500_.jpg',
      lastRead: '5 days ago',
      progress: 0.73,
      status: 'In Progress',
    ),
    ReadingHistoryData(
      title: 'The 5 AM Club',
      author: 'Robin Sharma',
      imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQV5tLvoApvMGecB8c3YD1DLQAVV-hZcudgpf2evYklBg&s',
      lastRead: '1 week ago',
      progress: 0.19,
      status: 'Saved',
    ),
  ];

  List<ReadingHistoryData> get _visibleHistory {
    if (_selectedFilter == 0) return _history;
    final label = _filters[_selectedFilter];
    if (label == 'Completed') {
      return _history.where((b) => b.progress >= 1.0).toList();
    }
    return _history.where((b) => b.status == label).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  ),
                  const Expanded(
                    child: Text(
                      'Reading History',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.filter_list_rounded, color: Colors.black87),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F7),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search_rounded, color: Colors.grey, size: 20),
                    SizedBox(width: 8),
                    Text('Search books...', style: TextStyle(color: Colors.grey, fontSize: 13.5)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Filter chips
            SizedBox(
              height: 38,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final isSelected = _selectedFilter == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? _primary : const Color(0xFFF3F3F7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _filters[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black54,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // History list — the SAME ReadingHistoryItem widget, called
            // again for each entry with different arguments.
            Expanded(
              child: _visibleHistory.isEmpty
                  ? const Center(child: Text('No books here yet.', style: TextStyle(color: Colors.grey)))
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      children: [
                        for (final book in _visibleHistory)
                          ReadingHistoryItem(
                            book: book,
                            onTap: () {},
                            onMenuTap: () {},
                          ),
                        const SizedBox(height: 4),
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.access_time_rounded, size: 13, color: Colors.grey.shade400),
                              const SizedBox(width: 6),
                              Text(
                                'History shows the last 50 books you read',
                                style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}