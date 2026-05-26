import 'package:flutter/material.dart';
import 'package:hidden_drawer_menu/hidden_drawer_menu.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:ShEC_CSE/features/profile/models/profile_state.dart';
import 'package:ShEC_CSE/features/dashboard/screens/home_screen.dart';
import 'package:ShEC_CSE/backend/services/update_service.dart';
import 'package:ShEC_CSE/features/notices/screens/notices_screen.dart';
import 'package:ShEC_CSE/features/messenger/screens/messenger_screen.dart';
import 'package:ShEC_CSE/features/contests/screens/contests_screen.dart';
import 'package:ShEC_CSE/backend/services/notification_service.dart';
import 'package:ShEC_CSE/features/profile/presentation/screens/profile_screen.dart';
import 'package:ShEC_CSE/backend/services/notice_service.dart';
import 'package:ShEC_CSE/backend/services/job_service.dart';
import 'package:ShEC_CSE/backend/services/contest_service.dart';
import 'package:ShEC_CSE/backend/services/chat_service.dart';
import 'package:ShEC_CSE/features/dashboard/presentation/widgets/animated_profile_icon.dart';
import 'package:ShEC_CSE/features/dashboard/presentation/widgets/main_drawer_menu.dart';
import 'package:ShEC_CSE/features/dashboard/presentation/widgets/ambient_background.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> with WidgetsBindingObserver {
  int _currentIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _screens = [
      DashboardScreen(
        onNavigateToTab: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      const NoticesScreen(),
      const MessengerScreen(),
      const ContestsScreen(),
    ];
    // Initialize Notification Service
    NotificationService.initialize();
    // Initialize Real-time subscriptions
    NoticeService.subscribeToNotices();
    JobService.subscribeToJobs();
    ContestService.subscribeToContests();
    ChatService.subscribeToAllMessages();
    // Check for App Updates
    UpdateService.instance.checkForUpdates();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Unsubscribe from services to prevent memory leaks and duplicate notifications
    NoticeService.unsubscribeFromNotices();
    JobService.unsubscribeFromJobs();
    ContestService.unsubscribeFromContests();
    ChatService.unsubscribeFromMessages();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-fetch and re-subscribe to ensure we didn't miss anything while in background
      NoticeService.fetchNotices(forceRefresh: true);
      JobService.fetchJobs(forceRefresh: true);
      ContestService.fetchContestsAndCourses(forceRefresh: true);
      ChatService.fetchRooms();
    }
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 1:
        return 'Notices';
      case 2:
        return 'Messenger';
      case 3:
        return 'Contests';
      default:
        return 'ShEC CSE';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SimpleHiddenDrawer(
      menu: MainDrawerMenu(colors: colors),
      screenSelectedBuilder: (position, controller) {
        return PopScope(
          canPop: _currentIndex == 0,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            setState(() => _currentIndex = 0);
          },
          child: AmbientTimeBackground(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
              leading: ListenableBuilder(
                listenable: UpdateService.instance,
                builder: (context, _) {
                  return Badge(
                    isLabelVisible: UpdateService.instance.hasUpdate,
                    child: IconButton(
                      icon: const Icon(Icons.menu),
                      tooltip: 'Open navigation drawer',
                      onPressed: () => controller.toggle(),
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
                    _currentIndex == 0 ? 'ShEC CSE' : _getAppBarTitle(_currentIndex),
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
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                          },
                          child: AnimatedProfileIcon(profile: profile, colors: colors),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
            bottomNavigationBar: Container(
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
                            icon: Icons.notifications,
                            text: 'Notices',
                            leading: Badge(
                              label: unread['notices']! > 0 ? Text('${unread['notices']}') : null,
                              isLabelVisible: unread['notices']! > 0,
                              child: Icon(
                                Icons.notifications,
                                color: _currentIndex == 1 ? colors.primary : colors.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                          GButton(
                            icon: Icons.message,
                            text: 'Messenger',
                            leading: Badge(
                              label: unread['messenger']! > 0 ? Text('${unread['messenger']}') : null,
                              isLabelVisible: unread['messenger']! > 0,
                              child: Icon(
                                Icons.message,
                                color: _currentIndex == 2 ? colors.primary : colors.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                          GButton(
                            icon: Icons.emoji_events,
                            text: 'Contests',
                            leading: Badge(
                              label: unread['contests']! > 0 ? Text('${unread['contests']}') : null,
                              isLabelVisible: unread['contests']! > 0,
                              child: Icon(
                                Icons.emoji_events,
                                color: _currentIndex == 3 ? colors.primary : colors.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ],
                        selectedIndex: _currentIndex,
                        onTabChange: (index) {
                          setState(() => _currentIndex = index);
                          if (index == 1) NotificationService.clearUnread('notices');
                          if (index == 2) NotificationService.clearUnread('messenger');
                          if (index == 3) NotificationService.clearUnread('contests');
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
      slidePercent: 60.0,
      verticalScalePercent: 90.0,
      contentCornerRadius: 24.0,
      enableCornerAnimation: true,
    );
  }
}