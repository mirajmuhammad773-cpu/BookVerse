// lib/Widgets/ReadingGoalsWidgets.dart
// ignore_for_file: deprecated_member_use, prefer_const_constructors

import 'package:bookverse/Models/ReadingGoalsModel.dart';
import 'package:flutter/material.dart';

const goalsPurple = Color(0xFF6C4CE0);
const goalsIndigo = Color(0xFF4A3AAE);

// ============================================================
// 1) Header card - circular progress + motivational text
// ============================================================
class ReadingGoalsHeaderCard extends StatelessWidget {
  final int booksRead;
  final int yearlyGoal;

  const ReadingGoalsHeaderCard({super.key, required this.booksRead, required this.yearlyGoal});

  @override
  Widget build(BuildContext context) {
    final progress = yearlyGoal == 0 ? 0.0 : (booksRead / yearlyGoal).clamp(0.0, 1.0);
    final percent = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [goalsPurple, goalsIndigo]),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            height: 92,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(92, 92),
                  painter: _RingPainter(progress: progress),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.menu_book_rounded, color: Colors.white, size: 16),
                    Text('$booksRead / $yearlyGoal', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    const Text('Books', style: TextStyle(color: Colors.white70, fontSize: 9)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("You're Doing Great! 🎉", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text("You're $percent% closer to your yearly goal",
                    style: const TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.3)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Goal: $yearlyGoal books this year', style: const TextStyle(color: Colors.white, fontSize: 10)),
                          Text('$percent%', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 4,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    final track = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);

    final arc = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -1.5708, 6.2832 * progress, false, arc);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.progress != progress;
}

// ============================================================
// 2) Stats row - 4 small stat cards
// ============================================================
class StatMini {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  const StatMini({required this.icon, required this.color, required this.value, required this.label});
}

class ReadingStatsRow extends StatelessWidget {
  final List<StatMini> stats;
  const ReadingStatsRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < stats.length; i++) ...[
          if (i != 0) const SizedBox(width: 10),
          Expanded(child: _card(stats[i])),
        ],
      ],
    );
  }

  Widget _card(StatMini s) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(color: s.color.withOpacity(0.08), borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Icon(s.icon, color: s.color, size: 18),
          const SizedBox(height: 6),
          Text(s.value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
          const SizedBox(height: 2),
          Text(s.label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9.5, color: Colors.grey)),
        ],
      ),
    );
  }
}

// ============================================================
// 3) Set Reading Goals card - period tabs + daily progress
// ============================================================
class SetGoalsCard extends StatelessWidget {
  final List<String> periods;
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;
  final String goalTitle;
  final String goalSubtitle;
  final int current;
  final int target;
  final VoidCallback? onEditGoals;

  const SetGoalsCard({
    super.key,
    required this.periods,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.goalTitle,
    required this.goalSubtitle,
    required this.current,
    required this.target,
    this.onEditGoals,
  });

  @override
  Widget build(BuildContext context) {
    final progress = target == 0 ? 0.0 : (current / target).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: const [
                Icon(Icons.track_changes_rounded, color: goalsPurple, size: 18),
                SizedBox(width: 8),
                Text('Set your Reading Goals', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
              ]),
              GestureDetector(
                onTap: onEditGoals,
                child: Row(mainAxisSize: MainAxisSize.min, children: const [
                  Icon(Icons.edit_outlined, size: 13, color: goalsPurple),
                  SizedBox(width: 4),
                  Text('Edit Goals', style: TextStyle(color: goalsPurple, fontSize: 12, fontWeight: FontWeight.w600)),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (int i = 0; i < periods.length; i++) ...[
                if (i != 0) const SizedBox(width: 8),
                Expanded(child: _periodTab(periods[i])),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFF6F4FE), borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: goalsPurple.withOpacity(0.15), shape: BoxShape.circle),
                  child: const Icon(Icons.menu_book_rounded, color: goalsPurple, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(goalTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                          Text('${(progress * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                        ],
                      ),
                      Text(goalSubtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation(goalsPurple),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text('$current / $target min', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _periodTab(String label) {
    final active = label == selectedPeriod;
    return GestureDetector(
      onTap: () => onPeriodChanged(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? goalsPurple : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? goalsPurple : Colors.grey.shade300),
        ),
        child: Text(label, style: TextStyle(fontSize: 12.5, color: active ? Colors.white : Colors.black87, fontWeight: active ? FontWeight.w600 : FontWeight.w500)),
      ),
    );
  }
}

// ============================================================
// 4) Weekly reading chart - REAL bar chart driven by numeric data.
// Bar heights are computed from actual minute values (no icons,
// no hardcoded pixel heights) so swapping in backend data later
// is a straight data-prop change, nothing else.
// ============================================================
class WeeklyReadingChart extends StatelessWidget {
  final List<DayReading> data;
  final VoidCallback? onSeeDetails;
  final double maxBarHeight;

  const WeeklyReadingChart({
    super.key,
    required this.data,
    this.onSeeDetails,
    this.maxBarHeight = 110,
  });

  @override
  Widget build(BuildContext context) {
    final maxMinutes = data.isEmpty ? 1 : data.map((d) => d.minutes).reduce((a, b) => a > b ? a : b);
    final peakIndex = data.isEmpty
        ? -1
        : data.indexWhere((d) => d.minutes == maxMinutes);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: const [
                Icon(Icons.bar_chart_rounded, color: goalsPurple, size: 18),
                SizedBox(width: 8),
                Text('Weekly Reading Overview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
              ]),
              GestureDetector(
                onTap: onSeeDetails,
                child: Row(mainAxisSize: MainAxisSize.min, children: const [
                  Text('See Details', style: TextStyle(color: goalsPurple, fontSize: 12, fontWeight: FontWeight.w600)),
                  Icon(Icons.chevron_right_rounded, color: goalsPurple, size: 16),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 18),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (int i = 0; i < data.length; i++)
                  Expanded(child: _bar(data[i], maxMinutes, i == peakIndex)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(DayReading d, int maxMinutes, bool isPeak) {
    final fraction = maxMinutes == 0 ? 0.0 : d.minutes / maxMinutes;
    final barHeight = maxBarHeight * fraction;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isPeak) const Text('👑', style: TextStyle(fontSize: 12)),
        Text('${d.minutes}m', style: const TextStyle(fontSize: 9.5, color: Colors.black54, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          width: 20,
          height: barHeight < 6 ? 6 : barHeight, // minimum visible sliver for 0/near-0 values
          decoration: BoxDecoration(
            color: isPeak ? goalsPurple : goalsPurple.withOpacity(0.55),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ),
        const SizedBox(height: 6),
        Text(d.label, style: const TextStyle(fontSize: 10.5, color: Colors.grey)),
      ],
    );
  }
}

// ============================================================
// 5) Reading challenges card
// ============================================================
class ReadingChallengesCard extends StatelessWidget {
  final List<ReadingChallenge> challenges;
  final VoidCallback? onViewAll;

  const ReadingChallengesCard({super.key, required this.challenges, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: const [
                Icon(Icons.emoji_events_rounded, color: goalsPurple, size: 18),
                SizedBox(width: 8),
                Text('Reading Challenges', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
              ]),
              GestureDetector(
                onTap: onViewAll,
                child: Row(mainAxisSize: MainAxisSize.min, children: const [
                  Text('View All', style: TextStyle(color: goalsPurple, fontSize: 12, fontWeight: FontWeight.w600)),
                  Icon(Icons.chevron_right_rounded, color: goalsPurple, size: 16),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (int i = 0; i < challenges.length; i++) ...[
                if (i != 0) const SizedBox(width: 10),
                Expanded(child: _challengeTile(challenges[i], i)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _challengeColor(int index) {
    const palette = [
      goalsPurple,
      goalsIndigo,
      Color(0xFF2E7D32),
      Color(0xFFE8A93B),
      Color(0xFF00A9A5),
    ];

    return palette[index % palette.length];
  }

  Widget _challengeTile(ReadingChallenge c, int index) {
    final accentColor = _challengeColor(index);
    final progress = c.target == 0 ? 0.0 : (c.current / c.target).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: accentColor.withOpacity(0.08), borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (c.completed)
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(color: Color(0xFF2E7D32), shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 15),
            )
          else
            Icon(Icons.menu_book_rounded, color: accentColor, size: 18),
          const SizedBox(height: 8),
          Text(c.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Colors.black87)),
          const SizedBox(height: 2),
          if (c.completed)
            const Text('Completed', style: TextStyle(fontSize: 10, color: Colors.grey))
          else ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(accentColor),
              ),
            ),
            const SizedBox(height: 4),
            Text('${c.current} / ${c.target}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ],
      ),
    );
  }
}