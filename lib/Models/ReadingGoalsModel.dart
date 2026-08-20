// lib/Models/ReadingGoalsModel.dart

// ============================================================
// DAY READING
// ============================================================

// ignore_for_file: file_names

class DayReading {
  final String label;
  final int minutes;

  const DayReading({
    required this.label,
    required this.minutes,
  });

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'minutes': minutes,
    };
  }

  factory DayReading.fromMap(
    Map<String, dynamic> map,
  ) {
    return DayReading(
      label: map['label']?.toString() ?? '',
      minutes: (map['minutes'] as num?)?.toInt() ?? 0,
    );
  }
}

// ============================================================
// READING CHALLENGE
// ============================================================

class ReadingChallenge {
  final String id;
  final String title;
  final String subtitle;
  final int current;
  final int target;
  final bool completed;

  const ReadingChallenge({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.current,
    required this.target,
    this.completed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'current': current,
      'target': target,
      'completed': completed,
    };
  }

  factory ReadingChallenge.fromMap(
    Map<String, dynamic> map,
  ) {
    final current =
        (map['current'] as num?)?.toInt() ?? 0;

    final target =
        (map['target'] as num?)?.toInt() ?? 0;

    return ReadingChallenge(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      subtitle: map['subtitle']?.toString() ?? '',
      current: current,
      target: target,
      completed:
          map['completed'] == true ||
          (target > 0 && current >= target),
    );
  }
}

// ============================================================
// READING GOAL MODEL
// ============================================================

class ReadingGoalModel {
  // ==========================================================
  // BOOK DATA
  // ==========================================================

  final int booksRead;

  final int yearlyGoal;

  final List<String> completedBookIds;

  // ==========================================================
  // READING TIME
  // ==========================================================

  final int totalReadingMinutes;

  // ==========================================================
  // LAST READING DATE
  // ==========================================================

  /// Date of the last reading activity.
  ///
  /// Stored as:
  /// yyyy-MM-dd
  final String? lastReadingDate;

  // ==========================================================
  // STREAK
  // ==========================================================

  final int currentStreakDays;

  // ==========================================================
  // MONTHLY GOAL
  // ==========================================================

  final int monthlyGoalCurrent;

  final int monthlyGoalTarget;

  // ==========================================================
  // DAILY GOAL
  // ==========================================================

  final int dailyGoalCurrent;

  final int dailyGoalTarget;

  // ==========================================================
  // WEEKLY READING
  // ==========================================================

  final List<DayReading> weeklyData;

  // ==========================================================
  // CHALLENGES
  // ==========================================================

  final List<ReadingChallenge> challenges;

  const ReadingGoalModel({
    this.booksRead = 0,
    this.yearlyGoal = 12,
    this.completedBookIds = const <String>[],
    this.totalReadingMinutes = 0,
    this.lastReadingDate,
    this.currentStreakDays = 0,
    this.monthlyGoalCurrent = 0,
    this.monthlyGoalTarget = 5,
    this.dailyGoalCurrent = 0,
    this.dailyGoalTarget = 30,
    this.weeklyData = const <DayReading>[],
    this.challenges = const <ReadingChallenge>[],
  });

  // ==========================================================
  // TOTAL HOURS
  // ==========================================================

  int get totalReadingHours {
    return totalReadingMinutes ~/ 60;
  }

  // ==========================================================
  // REMAINING MINUTES
  // ==========================================================

  int get totalReadingMinutesRemainder {
    return totalReadingMinutes % 60;
  }

  // ==========================================================
  // DAILY GOAL PROGRESS
  // ==========================================================

  double get dailyGoalProgress {
    if (dailyGoalTarget <= 0) {
      return 0;
    }

    return (dailyGoalCurrent / dailyGoalTarget)
        .clamp(0.0, 1.0);
  }

  // ==========================================================
  // YEARLY GOAL PROGRESS
  // ==========================================================

  double get yearlyGoalProgress {
    if (yearlyGoal <= 0) {
      return 0;
    }

    return (booksRead / yearlyGoal)
        .clamp(0.0, 1.0);
  }

  // ==========================================================
  // COPY WITH
  // ==========================================================

  ReadingGoalModel copyWith({
    int? booksRead,
    int? yearlyGoal,
    List<String>? completedBookIds,
    int? totalReadingMinutes,
    String? lastReadingDate,
    int? currentStreakDays,
    int? monthlyGoalCurrent,
    int? monthlyGoalTarget,
    int? dailyGoalCurrent,
    int? dailyGoalTarget,
    List<DayReading>? weeklyData,
    List<ReadingChallenge>? challenges,
  }) {
    return ReadingGoalModel(
      booksRead:
          booksRead ?? this.booksRead,
      yearlyGoal:
          yearlyGoal ?? this.yearlyGoal,
      completedBookIds:
          completedBookIds ??
              this.completedBookIds,
      totalReadingMinutes:
          totalReadingMinutes ??
              this.totalReadingMinutes,
      lastReadingDate:
          lastReadingDate ??
              this.lastReadingDate,
      currentStreakDays:
          currentStreakDays ??
              this.currentStreakDays,
      monthlyGoalCurrent:
          monthlyGoalCurrent ??
              this.monthlyGoalCurrent,
      monthlyGoalTarget:
          monthlyGoalTarget ??
              this.monthlyGoalTarget,
      dailyGoalCurrent:
          dailyGoalCurrent ??
              this.dailyGoalCurrent,
      dailyGoalTarget:
          dailyGoalTarget ??
              this.dailyGoalTarget,
      weeklyData:
          weeklyData ??
              this.weeklyData,
      challenges:
          challenges ??
              this.challenges,
    );
  }

  // ==========================================================
  // TO MAP
  // ==========================================================

  Map<String, dynamic> toMap() {
    return {
      'booksRead': booksRead,
      'yearlyGoal': yearlyGoal,
      'completedBookIds': completedBookIds,
      'totalReadingMinutes':
          totalReadingMinutes,
      'lastReadingDate':
          lastReadingDate,
      'currentStreakDays':
          currentStreakDays,
      'monthlyGoalCurrent':
          monthlyGoalCurrent,
      'monthlyGoalTarget':
          monthlyGoalTarget,
      'dailyGoalCurrent':
          dailyGoalCurrent,
      'dailyGoalTarget':
          dailyGoalTarget,
      'weeklyData':
          weeklyData
              .map(
                (day) => day.toMap(),
              )
              .toList(),
      'challenges':
          challenges
              .map(
                (challenge) =>
                    challenge.toMap(),
              )
              .toList(),
    };
  }

  // ==========================================================
  // FROM MAP
  // ==========================================================

  factory ReadingGoalModel.fromMap(
    Map<String, dynamic> map,
  ) {
    // --------------------------------------------------------
    // COMPLETED BOOK IDS
    // --------------------------------------------------------

    final List<String> completedIds = [];

    final completedBookIds =
        map['completedBookIds'];

    if (completedBookIds is List) {
      for (final id in completedBookIds) {
        completedIds.add(
          id.toString(),
        );
      }
    }

    // --------------------------------------------------------
    // WEEKLY DATA
    // --------------------------------------------------------

    final List<DayReading> weekly = [];

    final weeklyData =
        map['weeklyData'];

    if (weeklyData is List) {
      for (final item in weeklyData) {
        if (item is Map) {
          weekly.add(
            DayReading.fromMap(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }

    // --------------------------------------------------------
    // CHALLENGES
    // --------------------------------------------------------

    final List<ReadingChallenge>
        challengeList = [];

    final challenges =
        map['challenges'];

    if (challenges is List) {
      for (final item in challenges) {
        if (item is Map) {
          challengeList.add(
            ReadingChallenge.fromMap(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }

    // --------------------------------------------------------
    // RETURN MODEL
    // --------------------------------------------------------

    return ReadingGoalModel(
      booksRead:
          (map['booksRead'] as num?)
                  ?.toInt() ??
              0,

      yearlyGoal:
          (map['yearlyGoal'] as num?)
                  ?.toInt() ??
              12,

      completedBookIds:
          completedIds,

      totalReadingMinutes:
          (map['totalReadingMinutes']
                      as num?)
                  ?.toInt() ??
              0,

      lastReadingDate:
          map['lastReadingDate']
              ?.toString(),

      currentStreakDays:
          (map['currentStreakDays']
                      as num?)
                  ?.toInt() ??
              0,

      monthlyGoalCurrent:
          (map['monthlyGoalCurrent']
                      as num?)
                  ?.toInt() ??
              0,

      monthlyGoalTarget:
          (map['monthlyGoalTarget']
                      as num?)
                  ?.toInt() ??
              5,

      dailyGoalCurrent:
          (map['dailyGoalCurrent']
                      as num?)
                  ?.toInt() ??
              0,

      dailyGoalTarget:
          (map['dailyGoalTarget']
                      as num?)
                  ?.toInt() ??
              30,

      weeklyData:
          weekly,

      challenges:
          challengeList,
    );
  }
}