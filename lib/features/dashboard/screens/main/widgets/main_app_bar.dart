import 'package:flutter/material.dart';
import 'package:ShEC_CSE/backend/services/update_service.dart';
import 'package:ShEC_CSE/features/profile/models/profile_state.dart';
import 'package:ShEC_CSE/features/dashboard/presentation/widgets/animated_profile_icon.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentIndex;
  final VoidCallback onMenuPressed;
  final VoidCallback onProfilePressed;
  final ColorScheme colors;
  final GlobalKey drawerKey;
  final GlobalKey profileKey;
  final String title;

  const MainAppBar({
    super.key,
    required this.currentIndex,
    required this.onMenuPressed,
    required this.onProfilePressed,
    required this.colors,
    required this.drawerKey,
    required this.profileKey,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: ListenableBuilder(
        listenable: UpdateService.instance,
        builder: (context, _) {
          return Badge(
            isLabelVisible: UpdateService.instance.hasUpdate,
            child: IconButton(
              key: drawerKey,
              icon: const Icon(Icons.menu),
              tooltip: 'Open navigation drawer',
              onPressed: onMenuPressed,
            ),
          );
        },
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/branding/logo.png', height: 28, width: 28),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        ValueListenableBuilder<ProfileData>(
          valueListenable: currentProfile,
          builder: (context, profile, _) {
            return Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Tooltip(
                message: 'View Profile',
                child: GestureDetector(
                  key: profileKey,
                  onTap: onProfilePressed,
                  child: AnimatedProfileIcon(profile: profile, colors: colors),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
