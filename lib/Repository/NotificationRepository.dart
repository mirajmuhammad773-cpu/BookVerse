import 'package:BookVerse/Models/NotificationModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _notifications(
    String userId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications');
  }

  // ============================================================
  // CREATE NOTIFICATION
  // ============================================================

  Future<void> createNotification({
    required String userId,
    required AppNotificationModel notification,
  }) async {
    await _notifications(userId)
        .doc(notification.id)
        .set(notification.toMap());
  }

  // ============================================================
  // GET NOTIFICATIONS
  // ============================================================

  Stream<List<AppNotificationModel>> getNotifications(
    String userId,
  ) {
    return _notifications(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) {
            return snapshot.docs
                .map(
                  (doc) => AppNotificationModel.fromMap(
                    doc.data(),
                  ),
                )
                .toList();
          },
        );
  }

  // ============================================================
  // MARK ONE AS READ
  // ============================================================

  Future<void> markAsRead({
    required String userId,
    required String notificationId,
  }) async {
    await _notifications(userId)
        .doc(notificationId)
        .update({
      'isRead': true,
    });
  }

  // ============================================================
  // MARK ALL AS READ
  // ============================================================

  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _notifications(userId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.update(
        doc.reference,
        {
          'isRead': true,
        },
      );
    }

    await batch.commit();
  }

  // ============================================================
  // DELETE NOTIFICATION
  // ============================================================

  Future<void> deleteNotification({
    required String userId,
    required String notificationId,
  }) async {
    await _notifications(userId)
        .doc(notificationId)
        .delete();
  }

  // ============================================================
  // CHECK DUPLICATE EVENT
  // ============================================================

  Future<bool> notificationExists({
    required String userId,
    required String eventKey,
  }) async {
    final snapshot = await _notifications(userId)
        .where(
          'eventKey',
          isEqualTo: eventKey,
        )
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }
}