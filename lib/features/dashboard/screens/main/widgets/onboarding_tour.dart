import 'package:flutter/material.dart';
import 'package:ShEC_CSE/core/services/tour_service.dart';
import 'package:ShEC_CSE/features/dashboard/presentation/widgets/guided_tour_overlay.dart';
import 'package:ShEC_CSE/features/dashboard/screens/home_screen.dart';

class OnboardingTour extends StatelessWidget {
  final GlobalKey drawerKey;
  final GlobalKey profileKey;
  final GlobalKey noticesTabKey;
  final GlobalKey messengerTabKey;
  final GlobalKey contestsTabKey;
  final Function(int) onStepChanged;

  const OnboardingTour({
    super.key,
    required this.drawerKey,
    required this.profileKey,
    required this.noticesTabKey,
    required this.messengerTabKey,
    required this.contestsTabKey,
    required this.onStepChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: TourService.instance.isTourActive,
      builder: (context, isActive, _) {
        if (!isActive) return const SizedBox.shrink();
        return GuidedTourOverlay(
          steps: [
            TourStep(
              targetKey: drawerKey,
              title: 'Navigation Menu',
              description: 'Tap this icon to open the navigation drawer. Access settings, aesthetics settings, members directories, accounting, and more!',
            ),
            TourStep(
              targetKey: profileKey,
              title: 'Your Profile',
              description: 'Tap your profile picture to edit personal details, reset passwords, or review academic information.',
            ),
            TourStep(
              targetKey: DashboardScreen.quickAccessKey,
              title: 'Quick Access Panel',
              description: 'Instantly hop to Notices, Messenger, Careers, CGPA Calculator, or programming club events here! You can customize these shortcuts to your liking.',
            ),
            TourStep(
              targetKey: noticesTabKey,
              title: 'Notice Board',
              description: 'Access the Departmental and Club Notice Boards. Committee members can publish new notices, pin announcements, and toggle visibility right here.',
            ),
            TourStep(
              targetKey: messengerTabKey,
              title: 'CSE Messenger',
              description: 'Engage in real-time academic and club group conversations. Chat across the General group, Problem Solving forum, or Committee-only channels.',
            ),
            TourStep(
              targetKey: contestsTabKey,
              title: 'Contest Arena',
              description: 'Check ongoing and upcoming programming contests across multiple platforms and explore curated academic courses.',
            ),
          ],
          onStepChanged: onStepChanged,
          onComplete: () {
            TourService.instance.completeTour();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('🎉 Onboarding completed successfully! Enjoy the app!'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
          onSkip: () {
            TourService.instance.completeTour();
          },
        );
      },
    );
  }
}
