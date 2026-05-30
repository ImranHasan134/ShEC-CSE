import 'package:flutter/material.dart';
import 'package:ShEC_CSE/features/dashboard/presentation/widgets/ambient_background.dart';

class LivePreviewCard extends StatelessWidget {
  final GlobalKey previewCardKey;
  final ColorScheme previewScheme;
  final bool localEnabled;
  final double localSpeed;
  final int localDensity;
  final String localStyle;
  final bool localAuroraEnabled;
  final String localPattern;
  final String localWallpaper;
  final bool localWallpaperEnabled;
  final String Function(String) getStyleTitle;

  const LivePreviewCard({
    super.key,
    required this.previewCardKey,
    required this.previewScheme,
    required this.localEnabled,
    required this.localSpeed,
    required this.localDensity,
    required this.localStyle,
    required this.localAuroraEnabled,
    required this.localPattern,
    required this.localWallpaper,
    required this.localWallpaperEnabled,
    required this.getStyleTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: previewCardKey,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: previewScheme.primary.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Decoupled preview background - loads local override parameters in real-time
          Positioned.fill(
            child: AmbientTimeBackground(
              overrideEnabled: localEnabled,
              overrideSpeed: localSpeed,
              overrideDensity: localDensity,
              overrideStyle: localStyle,
              overrideColorScheme: previewScheme,
              overridePattern: localPattern,
              overrideAuroraEnabled: localAuroraEnabled,
              overrideWallpaper: localWallpaper,
              overrideWallpaperEnabled: localWallpaperEnabled,
              child: const SizedBox.expand(),
            ),
          ),

          // High-end glassmorphic information card overlay
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: previewScheme.surfaceContainer.withValues(alpha: 0.8),
                child: Row(
                  children: [
                    Icon(
                      localEnabled || localAuroraEnabled ? Icons.auto_awesome : Icons.do_not_disturb_on,
                      color: localEnabled || localAuroraEnabled ? previewScheme.primary : Colors.grey,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            localEnabled || localAuroraEnabled
                                ? 'Live Preview Canvas'
                                : 'Background Disabled',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: previewScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            localEnabled || localAuroraEnabled
                                ? 'Style: ${getStyleTitle(localStyle)} • Wallpaper: $localWallpaper'
                                : 'Saving performance with flat base colors.',
                            style: TextStyle(
                              fontSize: 10,
                              color: previewScheme.onSurfaceVariant.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: previewScheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'PREVIEW',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: previewScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Premium overlay border to ensure it never gets obscured by active custom painter canvas under BackdropFilter
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: previewScheme.primary.withValues(alpha: 0.6),
                    width: 2.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
