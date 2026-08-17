// lib/ViewModels/ReadingGoalProvider.dart

import 'package:bookverse/Models/BookModel.dart';
import 'package:bookverse/Models/ReadingGoalsModel.dart';
import 'package:bookverse/Repository/ReadingGoalRepository.dart';
import 'package:flutter/material.dart';

class ReadingGoalProvider extends ChangeNotifier {
  // ============================================================
  // REPOSITORY
  // ============================================================

  final ReadingGoalRepository _repository =
      ReadingGoalRepository();

  // ============================================================
  // MODEL
  // ============================================================

  ReadingGoalModel _data =
      const ReadingGoalModel();

  // ============================================================
  // STATE
  // ============================================================

  bool _isLoading = false;

  bool _isInitialized = false;

  String? _errorMessage;

  // ============================================================
  // READING SESSION
  // ============================================================

  DateTime? _sessionStartTime;

  // Prevent duplicate save of the same provider session.
  bool _sessionSaving = false;

  // ============================================================
  // CONSTRUCTOR
  // ============================================================

  ReadingGoalProvider() {
    loadReadingGoals();
  }

  // ============================================================
  // GETTERS
  // ============================================================

  ReadingGoalModel get data => _data;

  bool get isLoading => _isLoading;

  bool get isInitialized => _isInitialized;

  String? get errorMessage => _errorMessage;

  // ============================================================
  // BOOK DATA
  // ============================================================

  int get booksRead => _data.booksRead;

  int get yearlyGoal => _data.yearlyGoal;

  List<String> get completedBookIds =>
      List.unmodifiable(
        _data.completedBookIds,
      );

  // ============================================================
  // READING TIME
  // ============================================================

  int get totalReadingMinutes =>
      _data.totalReadingMinutes;

  int get totalReadingHours =>
      _data.totalReadingMinutes ~/ 60;

  int get totalReadingMinutesRemainder =>
      _data.totalReadingMinutes % 60;

  // ============================================================
  // STREAK
  // ============================================================

  int get currentStreakDays =>
      _data.currentStreakDays;

  // ============================================================
  // MONTHLY
  // ============================================================

  int get monthlyGoalCurrent =>
      _data.monthlyGoalCurrent;

  int get monthlyGoalTarget =>
      _data.monthlyGoalTarget;

  // ============================================================
  // DAILY
  // ============================================================

  int get dailyGoalCurrent =>
      _data.dailyGoalCurrent;

  int get dailyGoalTarget =>
      _data.dailyGoalTarget;

  // ============================================================
  // WEEKLY
  // ============================================================

  int get weeklyReadingMinutes =>
      _data.weeklyData.fold(
        0,
        (sum, day) => sum + day.minutes,
      );

  int get weeklyReadingTarget =>
      _data.dailyGoalTarget * 7;

  List<DayReading> get weeklyData =>
      List.unmodifiable(
        _data.weeklyData,
      );

  // ============================================================
  // CHALLENGES
  // ============================================================

  List<ReadingChallenge> get challenges =>
      List.unmodifiable(
        _data.challenges,
      );

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> loadReadingGoals() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final result =
          await _repository.loadReadingGoals();

      if (result == null) {
        _data = _createDefaultData();

        await _repository.saveReadingGoals(
          _data,
        );
      } else {
        _data = _prepareLoadedData(
          result,
        );
      }

      _isInitialized = true;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _isInitialized = true;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // PREPARE LOADED DATA
  // ============================================================

  ReadingGoalModel _prepareLoadedData(
    ReadingGoalModel model,
  ) {
    final today =
        _dateKey(DateTime.now());

    if (model.lastReadingDate != null &&
        model.lastReadingDate != today) {
      return _recalculateData(
        model.copyWith(
          dailyGoalCurrent: 0,
          lastReadingDate: today,
        ),
      );
    }

    if (model.lastReadingDate == null) {
      return _recalculateData(
        model.copyWith(
          lastReadingDate: today,
        ),
      );
    }

    return _recalculateData(
      model,
    );
  }

  // ============================================================
  // DEFAULT DATA
  // ============================================================

  ReadingGoalModel _createDefaultData() {
    return ReadingGoalModel(
      booksRead: 0,
      yearlyGoal: 12,
      completedBookIds: const [],
      totalReadingMinutes: 0,
      lastReadingDate:
          _dateKey(DateTime.now()),
      currentStreakDays: 0,
      monthlyGoalCurrent: 0,
      monthlyGoalTarget: 5,
      dailyGoalCurrent: 0,
      dailyGoalTarget: 30,
      weeklyData: const [
        DayReading(
          label: 'Mon',
          minutes: 0,
        ),
        DayReading(
          label: 'Tue',
          minutes: 0,
        ),
        DayReading(
          label: 'Wed',
          minutes: 0,
        ),
        DayReading(
          label: 'Thu',
          minutes: 0,
        ),
        DayReading(
          label: 'Fri',
          minutes: 0,
        ),
        DayReading(
          label: 'Sat',
          minutes: 0,
        ),
        DayReading(
          label: 'Sun',
          minutes: 0,
        ),
      ],
      challenges: const [],
    );
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<bool> _save() async {
    try {
      await _repository.saveReadingGoals(
        _data,
      );

      _errorMessage = null;

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();

      return false;
    }
  }

  // ============================================================
  // START READING SESSION
  // ============================================================

  void startReadingSession({
    BookModel? book,
  }) {
    // Already running.
    if (_sessionStartTime != null) {
      return;
    }

    _sessionStartTime =
        DateTime.now();

    _sessionSaving = false;
  }

  // ============================================================
  // SAVE READING SESSION
  // ============================================================

  Future<void> saveReadingSession({
    BookModel? book,
    required int minutes,
  }) async {
    // ----------------------------------------------------------
    // Prevent duplicate saves.
    // ----------------------------------------------------------

    if (_sessionSaving) {
      return;
    }

    int actualMinutes = minutes;

    final startTime =
        _sessionStartTime;

    if (startTime != null) {
      final providerDuration =
          DateTime.now().difference(
        startTime,
      );

      final providerMinutes =
          providerDuration.inMinutes;

      if (providerMinutes >
          actualMinutes) {
        actualMinutes =
            providerMinutes;
      }
    }

    // ----------------------------------------------------------
    // Clear session BEFORE saving.
    //
    // This is important because if Firebase takes time,
    // another lifecycle callback must not save the same session.
    // ----------------------------------------------------------

    _sessionStartTime = null;

    _sessionSaving = true;

    try {
      // --------------------------------------------------------
      // Ignore sessions shorter than one complete minute.
      // --------------------------------------------------------

      if (actualMinutes <= 0) {
        return;
      }

     

      await addReadingTime(
        actualMinutes,
      );
    } finally {
      _sessionSaving = false;
    }
  }

  // ============================================================
  // ADD READING TIME
  // ============================================================

  Future<void> addReadingTime(
    int minutes,
  ) async {
    if (minutes <= 0) {
      return;
    }

    final now =
        DateTime.now();

    final todayDate =
        _dateKey(now);

    // ==========================================================
    // DAILY READING
    // ==========================================================

    int todayMinutes;

    if (_data.lastReadingDate ==
        todayDate) {
      todayMinutes =
          _data.dailyGoalCurrent +
              minutes;
    } else {
      todayMinutes =
          minutes;
    }

    // ==========================================================
    // TOTAL READING TIME
    // ==========================================================

    final newTotal =
        _data.totalReadingMinutes +
            minutes;

    // ==========================================================
    // WEEKLY DATA
    // ==========================================================

    final updatedWeekly =
        _updateTodayWeeklyData(
      minutes,
    );

    // ==========================================================
    // STREAK
    // ==========================================================

    final newStreak =
        _calculateStreak(
      todayMinutes,
    );

    // ==========================================================
    // UPDATE MODEL
    // ==========================================================

    _data = _data.copyWith(
      totalReadingMinutes:
          newTotal,
      dailyGoalCurrent:
          todayMinutes,
      weeklyData:
          updatedWeekly,
      currentStreakDays:
          newStreak,
      lastReadingDate:
          todayDate,
    );

    // ==========================================================
    // UPDATE CHALLENGES
    // ==========================================================

    _data = _recalculateData(
      _data,
    );

    // ==========================================================
    // UPDATE UI IMMEDIATELY
    // ==========================================================

    notifyListeners();

    // ==========================================================
    // SAVE TO FIREBASE
    // ==========================================================

    await _save();
  }

  // ============================================================
  // COMPLETE BOOK
  // ============================================================

  Future<bool> addCompletedBook(
    String bookId,
  ) async {
    if (bookId.trim().isEmpty) {
      return false;
    }

    final cleanBookId =
        bookId.trim();

    // ----------------------------------------------------------
    // ALREADY COMPLETED
    // ----------------------------------------------------------

    if (_data.completedBookIds
        .contains(cleanBookId)) {
      return true;
    }

    // ----------------------------------------------------------
    // COPY IDS
    // ----------------------------------------------------------

    final updatedIds =
        List<String>.from(
      _data.completedBookIds,
    );

    updatedIds.add(
      cleanBookId,
    );

    // ----------------------------------------------------------
    // UPDATE
    // ----------------------------------------------------------

    _data = _data.copyWith(
      booksRead:
          _data.booksRead + 1,
      completedBookIds:
          updatedIds,
      monthlyGoalCurrent:
          _data.monthlyGoalCurrent + 1,
    );

    // ----------------------------------------------------------
    // CHALLENGES
    // ----------------------------------------------------------

    _data = _recalculateData(
      _data,
    );

    notifyListeners();

    // ----------------------------------------------------------
    // FIREBASE
    // ----------------------------------------------------------

    return await _save();
  }

  // ============================================================
  // CHECK BOOK COMPLETED
  // ============================================================

  bool isBookCompleted(
    String bookId,
  ) {
    return _data.completedBookIds
        .contains(
      bookId.trim(),
    );
  }

  // ============================================================
  // YEARLY GOAL
  // ============================================================

  Future<bool> setYearlyGoal(
    int goal,
  ) async {
    if (goal <= 0) {
      return false;
    }

    _data = _data.copyWith(
      yearlyGoal: goal,
    );

    notifyListeners();

    return await _save();
  }

  // ============================================================
  // DAILY GOAL
  // ============================================================

  Future<bool> setDailyGoal(
    int goal,
  ) async {
    if (goal <= 0) {
      return false;
    }

    _data = _data.copyWith(
      dailyGoalTarget: goal,
    );

    notifyListeners();

    return await _save();
  }

  // ============================================================
  // MONTHLY GOAL
  // ============================================================

  Future<bool> setMonthlyGoal(
    int goal,
  ) async {
    if (goal <= 0) {
      return false;
    }

    _data = _data.copyWith(
      monthlyGoalTarget: goal,
    );

    notifyListeners();

    return await _save();
  }

  // ============================================================
  // UPDATE WEEKLY DATA
  // ============================================================

  List<DayReading>
      _updateTodayWeeklyData(
    int minutes,
  ) {
    final today =
        _dayLabel(
      DateTime.now(),
    );

    final List<DayReading>
        updated = [];

    bool found = false;

    for (final day
        in _data.weeklyData) {
      if (day.label == today) {
        updated.add(
          DayReading(
            label: day.label,
            minutes:
                day.minutes + minutes,
          ),
        );

        found = true;
      } else {
        updated.add(day);
      }
    }

    // ----------------------------------------------------------
    // Safety fallback
    // ----------------------------------------------------------

    if (!found) {
      updated.add(
        DayReading(
          label: today,
          minutes: minutes,
        ),
      );
    }

    return _sortWeek(
      updated,
    );
  }

  // ============================================================
  // SORT WEEK
  // ============================================================

  List<DayReading> _sortWeek(
    List<DayReading> data,
  ) {
    const order = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    final copy =
        List<DayReading>.from(
      data,
    );

    copy.sort(
      (a, b) =>
          order.indexOf(a.label) -
          order.indexOf(b.label),
    );

    return copy;
  }

  // ============================================================
  // DAY LABEL
  // ============================================================

  String _dayLabel(
    DateTime date,
  ) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'Mon';

      case DateTime.tuesday:
        return 'Tue';

      case DateTime.wednesday:
        return 'Wed';

      case DateTime.thursday:
        return 'Thu';

      case DateTime.friday:
        return 'Fri';

      case DateTime.saturday:
        return 'Sat';

      case DateTime.sunday:
        return 'Sun';

      default:
        return 'Mon';
    }
  }

  // ============================================================
  // DATE KEY
  // ============================================================

  String _dateKey(
    DateTime date,
  ) {
    final month =
        date.month.toString().padLeft(
              2,
              '0',
            );

    final day =
        date.day.toString().padLeft(
              2,
              '0',
            );

    return '${date.year}-$month-$day';
  }

  // ============================================================
  // STREAK
  // ============================================================

  int _calculateStreak(
    int todayMinutes,
  ) {
    if (todayMinutes <= 0) {
      return _data.currentStreakDays;
    }

    if (_data.currentStreakDays <= 0) {
      return 1;
    }

    return _data.currentStreakDays;
  }

  // ============================================================
  // CHALLENGES
  // ============================================================

  ReadingGoalModel _recalculateData(
    ReadingGoalModel model,
  ) {
    final List<ReadingChallenge>
        challenges = [];

    // ==========================================================
    // 7 DAY STREAK
    // ==========================================================

    final streakCurrent =
        model.currentStreakDays
            .clamp(0, 7);

    challenges.add(
      ReadingChallenge(
        id: '7_day_streak',
        title: '7-Day Streak',
        subtitle:
            streakCurrent >= 7
                ? 'Completed'
                : '',
        current:
            streakCurrent,
        target: 7,
        completed:
            streakCurrent >= 7,
      ),
    );

    // ==========================================================
    // 5 BOOKS
    // ==========================================================

    final booksCurrent =
        model.booksRead.clamp(
      0,
      5,
    );

    challenges.add(
      ReadingChallenge(
        id: 'read_5_books',
        title: 'Read 5 Books',
        subtitle:
            booksCurrent >= 5
                ? 'Completed'
                : '',
        current:
            booksCurrent,
        target: 5,
        completed:
            booksCurrent >= 5,
      ),
    );

    // ==========================================================
    // 100 HOURS
    // ==========================================================

    final hours =
        model.totalReadingMinutes ~/
            60;

    final hoursCurrent =
        hours.clamp(
      0,
      100,
    );

    challenges.add(
      ReadingChallenge(
        id: 'read_100_hours',
        title: 'Read 100 Hours',
        subtitle:
            hoursCurrent >= 100
                ? 'Completed'
                : '',
        current:
            hoursCurrent,
        target: 100,
        completed:
            hoursCurrent >= 100,
      ),
    );

    return model.copyWith(
      challenges:
          challenges,
    );
  }

  // ============================================================
  // RESET DAILY
  // ============================================================

  Future<void> resetDailyGoal() async {
    _data = _data.copyWith(
      dailyGoalCurrent: 0,
      lastReadingDate:
          _dateKey(
        DateTime.now(),
      ),
    );

    notifyListeners();

    await _save();
  }

  // ============================================================
  // RESET ALL
  // ============================================================

  Future<bool> resetReadingGoals() async {
    _sessionStartTime = null;

    _data =
        _createDefaultData();

    notifyListeners();

    return await _save();
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refresh() async {
    await loadReadingGoals();
  }

  // ============================================================
  // FORCE SAVE CURRENT SESSION
  // ============================================================
  //
  // Optional helper.
  // ReaderScreen normally calls saveReadingSession().
  //
  // This method can also be used if another screen needs to
  // safely close the current reading session.
  // ============================================================

  Future<void> finishReadingSession({
    BookModel? book,
  }) async {
    if (_sessionStartTime == null) {
      return;
    }

    final duration =
        DateTime.now().difference(
      _sessionStartTime!,
    );

    await saveReadingSession(
      book: book,
      minutes: duration.inMinutes,
    );
  }
}