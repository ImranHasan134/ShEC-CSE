import 'package:flutter/material.dart';
import 'package:ShEC_CSE/core/services/theme_service.dart';

class ColorsTab extends StatelessWidget {
  final GlobalKey themeModeKey;
  final GlobalKey colorGridKey;
  final AppThemeMode localThemeMode;
  final AppColorTheme localColorTheme;
  final int localCustomColorValue;
  final double hueValue;
  final ColorScheme previewScheme;
  final ValueChanged<AppThemeMode> onThemeModeChanged;
  final ValueChanged<AppColorTheme> onColorThemeChanged;
  final ValueChanged<double> onHueValueChanged;
  final void Function(int, double) onCustomColorSwatchSelected;

  const ColorsTab({
    super.key,
    required this.themeModeKey,
    required this.colorGridKey,
    required this.localThemeMode,
    required this.localColorTheme,
    required this.localCustomColorValue,
    required this.hueValue,
    required this.previewScheme,
    required this.onThemeModeChanged,
    required this.onColorThemeChanged,
    required this.onHueValueChanged,
    required this.onCustomColorSwatchSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Theme Mode Selection Card
          _buildGlassCard(
            context: context,
            key: themeModeKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'THEME MODE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: previewScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildThemeModeItem(context, AppThemeMode.system, 'System', Icons.brightness_auto, previewScheme),
                      const SizedBox(width: 8),
                      _buildThemeModeItem(context, AppThemeMode.light, 'Light', Icons.light_mode, previewScheme),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildThemeModeItem(context, AppThemeMode.dark, 'Dark', Icons.dark_mode, previewScheme),
                      const SizedBox(width: 8),
                      _buildThemeModeItem(context, AppThemeMode.night, 'Night', Icons.nights_stay, previewScheme),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Color Scheme Palette Selection Card
          _buildGlassCard(
            context: context,
            key: colorGridKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'COLOR SCHEME',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: previewScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildColorGrid(previewScheme),
                  
                  // Rainbow HSL custom color picker
                  if (localColorTheme == AppColorTheme.custom) ...[
                    const Divider(height: 32),
                    _buildCustomColorPicker(previewScheme),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required BuildContext context, Key? key, required Widget child}) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      key: key,
      elevation: isDark ? 0 : 2, // Slight elevation in light mode to make it pop!
      color: isDark ? colors.surfaceContainer.withValues(alpha: 0.7) : Colors.white, // Solid opaque white in light mode to boost contrast
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.outline.withValues(alpha: isDark ? 0.1 : 0.2)),
      ),
      child: child,
    );
  }

  Widget _buildThemeModeItem(BuildContext context, AppThemeMode mode, String label, IconData icon, ColorScheme previewScheme) {
    final colors = Theme.of(context).colorScheme;
    final isSelected = localThemeMode == mode;
    return Expanded(
      child: InkWell(
        onTap: () => onThemeModeChanged(mode),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? previewScheme.primary : colors.surfaceContainer.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? previewScheme.primary : colors.outline.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : previewScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : previewScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorGrid(ColorScheme previewScheme) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2.1,
      ),
      itemCount: AppColorTheme.values.length,
      itemBuilder: (context, index) {
        final colorTheme = AppColorTheme.values[index];
        final isSelected = localColorTheme == colorTheme;

        Color primaryVal;
        String title;
        switch (colorTheme) {
          case AppColorTheme.teal:
            primaryVal = const Color(0xFF00ADB5);
            title = 'Teal';
            break;
          case AppColorTheme.blue:
            primaryVal = const Color(0xFF1E88E5);
            title = 'Ocean Blue';
            break;
          case AppColorTheme.purple:
            primaryVal = const Color(0xFF8E24AA);
            title = 'Cosmic';
            break;
          case AppColorTheme.green:
            primaryVal = const Color(0xFF43A047);
            title = 'Emerald';
            break;
          case AppColorTheme.amber:
            primaryVal = const Color(0xFFFFB300);
            title = 'Amber';
            break;
          case AppColorTheme.crimson:
            primaryVal = const Color(0xFFE53935);
            title = 'Crimson';
            break;
          case AppColorTheme.custom:
            primaryVal = Color(localCustomColorValue);
            title = 'Custom';
            break;
        }

        return InkWell(
          onTap: () => onColorThemeChanged(colorTheme),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: primaryVal.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? primaryVal : previewScheme.outline.withValues(alpha: 0.1),
                width: isSelected ? 2.0 : 1.0,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (colorTheme == AppColorTheme.custom)
                  // Sleek rainbow custom indicator
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                      gradient: const SweepGradient(
                        colors: [Colors.red, Colors.yellow, Colors.green, Colors.blue, Colors.purple, Colors.red],
                      ),
                    ),
                  )
                else
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: primaryVal,
                      shape: BoxShape.circle,
                    ),
                  ),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? primaryVal : previewScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomColorPicker(ColorScheme previewScheme) {
    // Custom presets list inside picker card
    final customSwatches = [
      {'color': const Color(0xFFFFC107), 'hue': 45.0},  // Vibrant Gold
      {'color': const Color(0xFFFF007F), 'hue': 330.0}, // Electric Pink
      {'color': const Color(0xFF39FF14), 'hue': 111.0}, // Neon Green
      {'color': const Color(0xFF00E5FF), 'hue': 187.0}, // Sky Blue
      {'color': const Color(0xFFD783FF), 'hue': 280.0}, // Cosmic Lavender
      {'color': const Color(0xFFFF5722), 'hue': 14.0},  // Fire Orange
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.palette, size: 16),
            SizedBox(width: 8),
            Text(
              'CUSTOM RAINBOW PICKER',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // HSL rainbow gradient track representing Hue
        Container(
          height: 16,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: const LinearGradient(
              colors: [
                Colors.red,
                Colors.orange,
                Colors.yellow,
                Colors.green,
                Colors.blue,
                Colors.indigo,
                Colors.purple,
                Colors.red,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
        ),

        // Hue Slider overlay
        Slider(
          value: hueValue,
          min: 0.0,
          max: 360.0,
          activeColor: Color(localCustomColorValue),
          inactiveColor: Colors.transparent,
          onChanged: onHueValueChanged,
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Hue Angle', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            Text('${hueValue.toStringAsFixed(0)}°',
                style: TextStyle(color: Color(localCustomColorValue), fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 16),

        const Text('Quick Swatches', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        
        // Horizontal preset swatches selection row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: customSwatches.map((sw) {
            final swatchColor = sw['color'] as Color;
            final isSelected = Color(localCustomColorValue).value == swatchColor.value ||
                               (hueValue - (sw['hue'] as double)).abs() < 5.0;

            return GestureDetector(
              onTap: () => onCustomColorSwatchSelected(swatchColor.value, sw['hue'] as double),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: swatchColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? previewScheme.onSurface : Colors.transparent,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: swatchColor.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
