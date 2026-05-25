// lib/features/dashboard/screens/aesthetics_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:ShEC_CSE/features/dashboard/presentation/widgets/ambient_background.dart';
import 'package:ShEC_CSE/core/services/theme_service.dart';

class AestheticsSettingsScreen extends StatelessWidget {
  const AestheticsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final themeService = ThemeService.instance;

    return AmbientTimeBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Aesthetics & Themes',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: ListenableBuilder(
          listenable: Listenable.merge([
            themeService,
            ambientBackgroundEnabled,
            ambientSparkleDensity,
            ambientAnimationSpeed,
          ]),
          builder: (context, _) {
            final isEnabled = ambientBackgroundEnabled.value;
            final density = ambientSparkleDensity.value;
            final speed = ambientAnimationSpeed.value;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Live Preview Panel
                  _buildLivePreviewCard(context, colors, isEnabled, density, speed),
                  const SizedBox(height: 20),

                  // 2. Ambient Background Switch Control
                  _buildGlassCard(
                    context,
                    child: SwitchListTile(
                      activeColor: colors.primary,
                      title: Row(
                        children: [
                          Icon(Icons.auto_awesome, color: colors.primary),
                          const SizedBox(width: 12),
                          const Text(
                            'Ambient Background',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      subtitle: const Padding(
                        padding: EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Enable live, time-based drifting aurora meshes, soft blurs, and sparkling particles. Disabling this is helpful for battery savings or solid readability.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      value: isEnabled,
                      onChanged: (val) {
                        ambientBackgroundEnabled.value = val;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Ambient Sliders (Density and Speed) - only interactive if enabled
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: isEnabled ? 1.0 : 0.4,
                    child: AbsorbPointer(
                      absorbing: !isEnabled,
                      child: _buildGlassCard(
                        context,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ANIMATION PREFERENCES',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                  color: colors.primary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Density Slider
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Sparkle Density', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text('$density particles', style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Slider(
                                value: density.toDouble(),
                                min: 10.0,
                                max: 150.0,
                                divisions: 14,
                                activeColor: colors.primary,
                                inactiveColor: colors.primary.withOpacity(0.2),
                                onChanged: (val) {
                                  ambientSparkleDensity.value = val.toInt();
                                },
                              ),
                              const SizedBox(height: 12),
                              // Speed Slider
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Drift Speed', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text('${speed.toStringAsFixed(1)}x', style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Slider(
                                value: speed,
                                min: 0.2,
                                max: 3.0,
                                divisions: 28,
                                activeColor: colors.primary,
                                inactiveColor: colors.primary.withOpacity(0.2),
                                onChanged: (val) {
                                  ambientAnimationSpeed.value = val;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. Theme Selection (Theme Mode Grid)
                  _buildGlassCard(
                    context,
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
                              color: colors.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildThemeModeItem(context, themeService, AppThemeMode.system, 'System', Icons.brightness_auto, colors),
                              const SizedBox(width: 8),
                              _buildThemeModeItem(context, themeService, AppThemeMode.light, 'Light', Icons.light_mode, colors),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildThemeModeItem(context, themeService, AppThemeMode.dark, 'Dark', Icons.dark_mode, colors),
                              const SizedBox(width: 8),
                              _buildThemeModeItem(context, themeService, AppThemeMode.night, 'Night', Icons.nights_stay, colors),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 5. Color Scheme Palette Selector
                  _buildGlassCard(
                    context,
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
                              color: colors.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 2.2,
                            ),
                            itemCount: AppColorTheme.values.length,
                            itemBuilder: (context, index) {
                              final colorTheme = AppColorTheme.values[index];
                              final isSelected = themeService.colorTheme == colorTheme;
                              
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
                              }

                              return InkWell(
                                onTap: () => themeService.setColorTheme(colorTheme),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: primaryVal.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected ? primaryVal : colors.outline.withOpacity(0.1),
                                      width: isSelected ? 2.0 : 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: primaryVal,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        title,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          color: isSelected ? primaryVal : colors.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGlassCard(BuildContext context, {required Widget child}) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: colors.surfaceContainer.withOpacity(0.7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.outline.withOpacity(0.1)),
      ),
      child: child,
    );
  }

  Widget _buildLivePreviewCard(
    BuildContext context,
    ColorScheme colors,
    bool isEnabled,
    int density,
    double speed,
  ) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary.withOpacity(0.15),
            colors.primaryContainer.withOpacity(0.05),
          ],
        ),
        border: Border.all(color: colors.primary.withOpacity(0.2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Render a miniature ambient background to visualize changes instantly!
          if (isEnabled)
            const Positioned.fill(
              child: AmbientTimeBackground(
                child: SizedBox.expand(),
              ),
            )
          else
            Positioned.fill(
              child: Container(
                color: colors.surface,
              ),
            ),
          
          // Front visual representation overlay
          Positioned.fill(
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(16.0),
              color: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isEnabled ? Icons.auto_awesome : Icons.do_not_disturb_on,
                    color: isEnabled ? colors.primary : Colors.grey,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isEnabled ? 'Live Preview Active' : 'Ambient Backdrop Disabled',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isEnabled ? colors.primary : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isEnabled
                        ? 'Density: $density particles • Speed: ${speed.toStringAsFixed(1)}x'
                        : 'Using solid background to save performance.',
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeModeItem(
    BuildContext context,
    ThemeService themeService,
    AppThemeMode mode,
    String label,
    IconData icon,
    ColorScheme colors,
  ) {
    final isSelected = themeService.themeMode == mode;
    return Expanded(
      child: InkWell(
        onTap: () => themeService.setThemeMode(mode),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? colors.primary : colors.surfaceContainer.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? colors.primary : colors.outline.withOpacity(0.08),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : colors.onSurface.withOpacity(0.7),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : colors.onSurface.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
