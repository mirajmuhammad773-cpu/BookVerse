class AppNotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final String icon;
  final String eventKey;
  final bool isRead;
  final DateTime createdAt;

  const AppNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.icon,
    required this.eventKey,
    required this.isRead,
    required this.createdAt,
  });

  // ============================================================
  // FIRESTORE -> MODEL
  // ============================================================

  factory AppNotificationModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return AppNotificationModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      type: map['type']?.toString() ?? 'general',
      icon: map['icon']?.toString() ?? '🔔',
      eventKey: map['eventKey']?.toString() ?? '',
      isRead: map['isRead'] as bool? ?? false,
      createdAt: _parseDateTime(map['createdAt']),
    );
  }

  // ============================================================
  // MODEL -> FIRESTORE
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'icon': icon,
      'eventKey': eventKey,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // ============================================================
  // DATE PARSER
  // ============================================================

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }

    return DateTime.now();
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  AppNotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    String? icon,
    String? eventKey,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      eventKey: eventKey ?? this.eventKey,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}