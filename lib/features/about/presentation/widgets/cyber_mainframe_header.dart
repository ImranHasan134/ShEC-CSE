import 'package:flutter/material.dart';
import '../../domain/entities/contributor_item.dart';
import 'contributor_painters.dart';

class CyberMainframeHeader extends StatefulWidget {
  final List<ContributorItem> contributors;
  final Widget Function(BuildContext, List<ContributorItem>) builder;

  const CyberMainframeHeader({
    super.key,
    required this.contributors,
    required this.builder,
  });

  @override
  State<CyberMainframeHeader> createState() => _CyberMainframeHeaderState();
}

class _CyberMainframeHeaderState extends State<CyberMainframeHeader> with SingleTickerProviderStateMixin {
  late AnimationController _sweepController;

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _sweepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Stack(
      children: [
        widget.builder(context, widget.contributors),
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _sweepController,
              builder: (context, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: CustomPaint(
                    painter: ScanlinePainter(
                      progress: _sweepController.value,
                      color: colors.primary,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
