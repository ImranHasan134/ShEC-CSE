import 'package:flutter/material.dart';

void showTimeTableDialog(BuildContext context, ColorScheme previewScheme) {
  final colors = Theme.of(context).colorScheme;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: isDark ? colors.surface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.access_time_filled, color: previewScheme.primary, size: 24),
            const SizedBox(width: 12),
            const Text(
              'Aesthetic Time Table',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'The background color scheme dynamically adapts to these time periods to create a soothing, ambient aesthetic.',
                style: TextStyle(fontSize: 12.5),
              ),
              const SizedBox(height: 20),
              _TimeTableItem(
                title: 'Morning (5:00 AM - 12:00 PM)',
                label: 'Sunrise Golden Amber & Warm Peach',
                icons: const [Icons.wb_twilight, Icons.wb_sunny_outlined],
                dotColors: [previewScheme.primary, const Color(0xFFFF9100), const Color(0xFFFFD600)],
                previewScheme: previewScheme,
              ),
              const SizedBox(height: 14),
              _TimeTableItem(
                title: 'Afternoon (12:00 PM - 5:00 PM)',
                label: 'High-energy Sky Cyan & Emerald',
                icons: const [Icons.wb_sunny, Icons.light_mode],
                dotColors: [previewScheme.primary, const Color(0xFF00E5FF), const Color(0xFF00E676)],
                previewScheme: previewScheme,
              ),
              const SizedBox(height: 14),
              _TimeTableItem(
                title: 'Evening (5:00 PM - 9:00 PM)',
                label: 'Twilight Crimson Sunset & Magenta',
                icons: const [Icons.wb_twilight_sharp, Icons.nights_stay_outlined],
                dotColors: [previewScheme.primary, const Color(0xFFFF1744), const Color(0xFFD500F9)],
                previewScheme: previewScheme,
              ),
              const SizedBox(height: 14),
              _TimeTableItem(
                title: 'Night (9:00 PM - 5:00 AM)',
                label: 'Deep Cosmic Indigo & Midnight Blue',
                icons: const [Icons.nights_stay, Icons.bedtime],
                dotColors: [previewScheme.primary, const Color(0xFF2979FF), const Color(0xFF651FFF)],
                previewScheme: previewScheme,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: TextButton.styleFrom(
              foregroundColor: previewScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('Got it', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      );
    },
  );
}

class _TimeTableItem extends StatelessWidget {
  final String title;
  final String label;
  final List<IconData> icons;
  final List<Color> dotColors;
  final ColorScheme previewScheme;

  const _TimeTableItem({
    required this.title,
    required this.label,
    required this.icons,
    required this.dotColors,
    required this.previewScheme,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainer.withValues(alpha: 0.4) : colors.surfaceContainer.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icons[0], size: 16, color: previewScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant.withValues(alpha: 0.85)),
          ),
          const SizedBox(height: 8),
          Row(
            children: dotColors.map((dotColor) {
              return Container(
                margin: const EdgeInsets.only(right: 6),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                  boxShadow: [
                    BoxShadow(
                      color: dotColor.withValues(alpha: 0.4),
                      blurRadius: 4,
                      spreadRadius: 1,
                    )
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
