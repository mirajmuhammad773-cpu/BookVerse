// lib/Screens/ReadingGoalsScreen.dart
import 'package:bookverse/Widgets/ReadingGoalwidget.dart';
import 'package:flutter/material.dart';

class ReadingGoalsScreen extends StatefulWidget {
  const ReadingGoalsScreen({super.key});

  @override
  State<ReadingGoalsScreen> createState() => _ReadingGoalsScreenState();
}

class _ReadingGoalsScreenState extends State<ReadingGoalsScreen> {
 
  final int booksRead = 6;
  final int yearlyGoal = 12;
  final int totalReadingHours = 42;
  final int totalReadingMinutesRemainder = 30;
  final int currentStreakDays = 15;
  final int monthlyGoalCurrent = 2;
  final int monthlyGoalTarget = 5;

  String selectedPeriod = 'Daily';
  final periods = const ['Daily', 'Weekly', 'Monthly', 'Yearly'];
  final int dailyGoalCurrent = 20;
  final int dailyGoalTarget = 30;

  // Real per-day minutes - this is the exact shape a backend endpoint
  // like GET /reading-stats/weekly would return.
  final List<DayReading> weeklyData = const [
    DayReading('Mon', 75),
    DayReading('Tue', 35),
    DayReading('Wed', 28),
    DayReading('Thu', 10),
    DayReading('Fri', 20),
    DayReading('Sat', 30),
    DayReading('Sun', 90),
  ];

  final List<ReadingChallenge> challenges = const [
    ReadingChallenge(title: '7-Day Streak', subtitle: 'Completed', current: 7, target: 7, completed: true, accentColor: Color(0xFF2E7D32)),
    ReadingChallenge(title: 'Read 5 Books', subtitle: '', current: 3, target: 5, accentColor: goalsPurple),
    ReadingChallenge(title: 'Read 100 Hours', subtitle: '', current: 42, target: 100, accentColor: Color(0xFFE8A93B)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      body: SafeArea(
        child: Column(
          children: [
            // ---------------- Header ----------------
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  _iconButton(Icons.arrow_back_rounded, () => Navigator.maybePop(context)),
                 const SizedBox(width: 60),
                          const Text('Reading Goals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                       
                  
                ],
              ),
            ),
            const SizedBox(height: 14),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                children: [
                  // ---- Header card custom widget ----
                  ReadingGoalsHeaderCard(booksRead: booksRead, yearlyGoal: yearlyGoal),
                  const SizedBox(height: 14),

                  // ---- Stats row custom widget ----
                  ReadingStatsRow(stats: [
                    StatMini(icon: Icons.menu_book_rounded, color: goalsPurple, value: '$booksRead', label: 'Books Read'),
                    StatMini(icon: Icons.access_time_rounded, color: goalsPurple, value: '${totalReadingHours}h ${totalReadingMinutesRemainder}m', label: 'Total Reading Time'),
                    StatMini(icon: Icons.local_fire_department_rounded, color: const Color(0xFFE53935), value: '$currentStreakDays Days', label: 'Current Streak'),
                    StatMini(icon: Icons.star_rounded, color: const Color(0xFFE8A93B), value: '$monthlyGoalCurrent / $monthlyGoalTarget', label: 'Monthly Goal'),
                  ]),
                  const SizedBox(height: 14),

                  // ---- Set goals card custom widget ----
                  SetGoalsCard(
                    periods: periods,
                    selectedPeriod: selectedPeriod,
                    onPeriodChanged: (p) => setState(() => selectedPeriod = p),
                    goalTitle: 'Daily Reading Goal',
                    goalSubtitle: 'Read 30 minutes per day',
                    current: dailyGoalCurrent,
                    target: dailyGoalTarget,
                    onEditGoals: () {},
                  ),
                  const SizedBox(height: 14),

                  // ---- Real, data-driven bar chart custom widget ----
                  WeeklyReadingChart(data: weeklyData, onSeeDetails: () {}),
                  const SizedBox(height: 14),

                  // ---- Challenges custom widget ----
                  ReadingChallengesCard(challenges: challenges, onViewAll: () {}),
                  const SizedBox(height: 16),

                  // ---- Quote footer ----
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: goalsPurple.withOpacity(0.06), borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: const [
                        Text('"Today a reader, tomorrow a leader."',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13, color: Colors.black87)),
                        SizedBox(height: 4),
                        Text('— Margaret Fuller', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
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

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200)),
        child: Icon(icon, size: 18, color: Colors.black87),
      ),
    );
  }
}