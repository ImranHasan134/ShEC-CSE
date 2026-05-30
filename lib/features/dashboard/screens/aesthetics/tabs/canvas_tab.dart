import 'package:flutter/material.dart';

class CanvasTab extends StatelessWidget {
  final GlobalKey canvasElementsKey;
  final bool localWallpaperEnabled;
  final String localWallpaper;
  final String localPattern;
  final double localWallpaperDensity;
  final ColorScheme previewScheme;
  final ValueChanged<bool> onWallpaperEnabledChanged;
  final ValueChanged<String> onWallpaperChanged;
  final ValueChanged<String> onPatternChanged;
  final ValueChanged<double> onWallpaperDensityChanged;

  const CanvasTab({
    super.key,
    required this.canvasElementsKey,
    required this.localWallpaperEnabled,
    required this.localWallpaper,
    required this.localPattern,
    required this.localWallpaperDensity,
    required this.previewScheme,
    required this.onWallpaperEnabledChanged,
    required this.onWallpaperChanged,
    required this.onPatternChanged,
    required this.onWallpaperDensityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildGlassCard(
            context: context,
            key: canvasElementsKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SwitchListTile(
                  activeColor: previewScheme.primary,
                  title: Row(
                    children: [
                      Icon(Icons.wallpaper, color: previewScheme.primary),
                      const SizedBox(width: 12),
                      const Text(
                        'Static Canvas Elements',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  subtitle: const Padding(
                    padding: EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Display beautiful vector wallpapers and geometric patterns. Drawn crisply on top of ambient auroras without any blur.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  value: localWallpaperEnabled,
                  onChanged: onWallpaperEnabledChanged,
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: localWallpaperEnabled
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(height: 1),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'STATIC BACKGROUND WALLPAPER',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                      color: previewScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildWallpaperGrid(previewScheme),
                                  const SizedBox(height: 24),
                                  Text(
                                    'STATIC BACKGROUND PATTERN',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                      color: previewScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    child: Row(
                                      children: [
                                        'none',
                                        'dots',
                                        'grid',
                                        'waves',
                                        'stripes',
                                      ].map((pat) {
                                        final isSelected = localPattern == pat;
                                        String label;
                                        IconData icon;
                                        switch (pat) {
                                          case 'none':
                                            label = 'None';
                                            icon = Icons.blur_off;
                                            break;
                                          case 'dots':
                                            label = 'Dots Grid';
                                            icon = Icons.blur_on;
                                            break;
                                          case 'grid':
                                            label = 'Line Grid';
                                            icon = Icons.grid_on;
                                            break;
                                          case 'waves':
                                            label = 'Waves';
                                            icon = Icons.waves;
                                            break;
                                          case 'stripes':
                                            label = 'Diagonal Stripes';
                                            icon = Icons.dehaze;
                                            break;
                                          default:
                                            label = 'None';
                                            icon = Icons.blur_off;
                                        }
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 8.0),
                                          child: ChoiceChip(
                                            label: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(icon, size: 16, color: isSelected ? Colors.white : previewScheme.onSurface),
                                                const SizedBox(width: 6),
                                                Text(label),
                                              ],
                                            ),
                                            selected: isSelected,
                                            selectedColor: previewScheme.primary,
                                            labelStyle: TextStyle(
                                              color: isSelected ? Colors.white : previewScheme.onSurface,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            onSelected: (selected) {
                                              if (selected) {
                                                onPatternChanged(pat);
                                              }
                                            },
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Wallpaper & Pattern Density', style: TextStyle(fontWeight: FontWeight.bold)),
                                      Text('${localWallpaperDensity.toStringAsFixed(1)}x',
                                          style: TextStyle(color: previewScheme.primary, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  Slider(
                                    value: localWallpaperDensity,
                                    min: 0.5,
                                    max: 2.0,
                                    divisions: 15,
                                    activeColor: previewScheme.primary,
                                    inactiveColor: previewScheme.primary.withValues(alpha: 0.2),
                                    onChanged: onWallpaperDensityChanged,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
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
      elevation: isDark ? 0 : 2,
      color: isDark ? colors.surfaceContainer.withValues(alpha: 0.7) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.outline.withValues(alpha: isDark ? 0.1 : 0.2)),
      ),
      child: child,
    );
  }

  Widget _buildWallpaperGrid(ColorScheme previewScheme) {
    final wallpapersList = [
      {'id': 'none', 'title': 'None', 'desc': 'Standard time aurora sky', 'icon': Icons.blur_off},
      {'id': 'starry', 'title': 'Starry Sky', 'desc': 'Cosmic void and constellations', 'icon': Icons.star_border},
      {'id': 'geometric', 'title': 'Geometric', 'desc': 'Overlapping polygonal circles', 'icon': Icons.category},
      {'id': 'wave', 'title': 'Neon Wave', 'desc': 'Layered glowing curves', 'icon': Icons.waves},
      {'id': 'tech_grid', 'title': 'Matrix Grid', 'desc': 'Futuristic tech wireframe blueprints', 'icon': Icons.grid_goldenratio},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.8,
      ),
      itemCount: wallpapersList.length,
      itemBuilder: (context, index) {
        final wp = wallpapersList[index];
        final isSelected = localWallpaper == wp['id'];
        return GestureDetector(
          onTap: () => onWallpaperChanged(wp['id'] as String),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? previewScheme.primary.withValues(alpha: 0.08) : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? previewScheme.primary : previewScheme.outline.withValues(alpha: 0.1),
                width: isSelected ? 2.0 : 1.0,
              ),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  wp['icon'] as IconData,
                  color: isSelected ? previewScheme.primary : previewScheme.onSurface.withValues(alpha: 0.7),
                  size: 20,
                ),
                const SizedBox(height: 6),
                Text(
                  wp['title'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isSelected ? previewScheme.primary : previewScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  wp['desc'] as String,
                  style: TextStyle(
                    fontSize: 9,
                    color: previewScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
