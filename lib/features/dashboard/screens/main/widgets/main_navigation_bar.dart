import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:ShEC_CSE/backend/services/notification_service.dart';

class MainNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChange;
  final ColorScheme colors;
  final GlobalKey noticesTabKey;
  final GlobalKey messengerTabKey;
  final GlobalKey contestsTabKey;

  const MainNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTabChange,
    required this.colors,
    required this.noticesTabKey,
    required this.messengerTabKey,
    required this.contestsTabKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ValueListenableBuilder<Map<String, int>>(
            valueListenable: NotificationService.unreadCounts,
            builder: (context, unread, _) {
              return GNav(
                rippleColor: colors.primary.withValues(alpha: 0.1),
                hoverColor: colors.primary.withValues(alpha: 0.05),
                gap: 8,
                activeColor: colors.primary,
                iconSize: 22,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                duration: const Duration(milliseconds: 300),
                tabBackgroundColor: colors.primary.withValues(alpha: 0.1),
                color: colors.onSurface.withValues(alpha: 0.6),
                tabs: [
                  const GButton(
                    icon: Icons.home,
                    text: 'Home',
                  ),
                  GButton(
                    key: noticesTabKey,
                    icon: Icons.notifications,
                    text: 'Notices',
                    leading: Badge(
                      label: unread['notices']! > 0 ? Text('${unread['notices']}') : null,
                      isLabelVisible: unread['notices']! > 0,
                      child: Icon(
                        Icons.notifications,
                        color: currentIndex == 1 ? colors.primary : colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  GButton(
                    key: messengerTabKey,
                    icon: Icons.message,
                    text: 'Messenger',
                    leading: Badge(
                      label: unread['messenger']! > 0 ? Text('${unread['messenger']}') : null,
                      isLabelVisible: unread['messenger']! > 0,
                      child: Icon(
                        Icons.message,
                        color: currentIndex == 2 ? colors.primary : colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  GButton(
                    key: contestsTabKey,
                    icon: Icons.emoji_events,
                    text: 'Contests',
                    leading: Badge(
                      label: unread['contests']! > 0 ? Text('${unread['contests']}') : null,
                      isLabelVisible: unread['contests']! > 0,
                      child: Icon(
                        Icons.emoji_events,
                        color: currentIndex == 3 ? colors.primary : colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
                selectedIndex: currentIndex,
                onTabChange: onTabChange,
              );
            },
          ),
        ),
      ),
    );
  }
}
