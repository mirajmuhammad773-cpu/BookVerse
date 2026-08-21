import 'package:flutter/material.dart';

class NotificationTileWidget extends StatelessWidget {
  final String emoji;
  final Color iconBgColor;
  final String title;
  final String description;
  final String time;
  final Color? dotColor;

  const NotificationTileWidget({
    super.key,
    required this.emoji,
    required this.iconBgColor,
    required this.title,
    required this.description,
    required this.time,
    this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final horizontalPadding = width * 0.035;
    final fontScale = width < 360 ? 0.9 : 1.0;

    return Container(
      margin: EdgeInsets.only(
        bottom: width * 0.03,
      ),
      padding: EdgeInsets.all(
        horizontalPadding,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ======================================================
          // ICON
          // ======================================================

          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ),

          SizedBox(
            width: horizontalPadding,
          ),

          // ======================================================
          // TEXT
          // ======================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.5 * fontScale,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 3),

                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.5 * fontScale,
                    color: Colors.grey,
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          SizedBox(
            width: horizontalPadding * 0.5,
          ),

          // ======================================================
          // TIME + UNREAD DOT
          // ======================================================

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: TextStyle(
                  fontSize: 11 * fontScale,
                  color: Colors.grey,
                ),
              ),

              if (dotColor != null) ...[
                const SizedBox(height: 6),

                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}