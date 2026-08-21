import 'package:BookVerse/ViewModels/NotificationProvider.dart';
import 'package:BookVerse/Widgets/NotificationWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  // ============================================================
  // TIME FORMAT
  // ============================================================

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'min' : 'mins'} ago';
    }

    if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    }

    if (difference.inDays == 1) {
      return 'Yesterday';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    }

    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  // ============================================================
  // NOTIFICATION COLOR
  // ============================================================

  Color _getIconBackground(String type) {
    switch (type) {
      case 'book':
        return const Color(0xFFDCEAFB);

      case 'achievement':
        return const Color(0xFFFDF0DC);

      case 'goal':
        return const Color(0xFFECE3FB);

      case 'streak':
        return const Color(0xFFFDE3E1);

      case 'challenge':
        return const Color(0xFFDDF4E9);

      case 'favorite':
        return const Color(0xFFFCE4EC);

      default:
        return const Color(0xFFEAEAEA);
    }
  }

  // ============================================================
  // DOT COLOR
  // ============================================================

  Color _getDotColor(String type) {
    switch (type) {
      case 'book':
        return const Color(0xFF3B82F6);

      case 'achievement':
        return const Color(0xFFF59E0B);

      case 'goal':
        return const Color(0xFF8B5CF6);

      case 'streak':
        return const Color(0xFFE85D45);

      case 'challenge':
        return const Color(0xFF22A06B);

      case 'favorite':
        return const Color(0xFFE91E63);

      default:
        return Colors.grey;
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final horizontalPadding = width * 0.05;

    return Scaffold(
      backgroundColor: Colors.white,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        automaticallyImplyLeading: false,

        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),

        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: width < 360 ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        centerTitle: true,

        // ======================================================
        // MARK ALL AS READ
        // ======================================================

        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              if (!provider.hasUnreadNotifications) {
                return const SizedBox.shrink();
              }

              return IconButton(
                tooltip: 'Mark all as read',
                onPressed: () {
                  provider.markAllAsRead();
                },
                icon: const Icon(
                  Icons.done_all,
                  color: Colors.white,
                ),
              );
            },
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
          ),
          child: Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              final notifications = provider.notifications;

              // ==================================================
              // EMPTY STATE
              // ==================================================

              if (notifications.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '🔔',
                        style: TextStyle(fontSize: 55),
                      ),
                      SizedBox(height: 15),
                      Text(
                        'No notifications yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Your reading activity and achievements\nwill appear here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // ==================================================
              // NOTIFICATIONS
              // ==================================================

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),

                  // ----------------------------------------------
                  // HEADER
                  // ----------------------------------------------

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent',
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      if (provider.unreadCount > 0)
                        Text(
                          '${provider.unreadCount} unread',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ----------------------------------------------
                  // LIST
                  // ----------------------------------------------

                  Expanded(
                    child: ListView.builder(
                      itemCount: notifications.length,
                      padding: const EdgeInsets.only(
                        bottom: 20,
                      ),
                      itemBuilder: (context, index) {
                        final notification =
                            notifications[index];

                        return GestureDetector(
                          onTap: () {
                            if (!notification.isRead) {
                              provider.markAsRead(
                                notification.id,
                              );
                            }
                          },

                          child: NotificationTileWidget(
                            emoji: notification.icon,
                            iconBgColor:
                                _getIconBackground(
                              notification.type,
                            ),
                            title: notification.title,
                            description:
                                notification.message,
                            time: _formatTime(
                              notification.createdAt,
                            ),
                            dotColor: notification.isRead
                                ? null
                                : _getDotColor(
                                    notification.type,
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}