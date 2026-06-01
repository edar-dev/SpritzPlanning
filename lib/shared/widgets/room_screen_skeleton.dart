import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';

/// Placeholder layout while room state is loading (sidebar + main panel).
class RoomScreenSkeleton extends StatelessWidget {
  const RoomScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ShimmerBox(width: 140, height: 18),
            const SizedBox(height: 6),
            _ShimmerBox(width: 72, height: 12),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;
          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 280,
                  child: _SidebarSkeleton(),
                ),
                const VerticalDivider(width: 1),
                const Expanded(child: _MainPanelSkeleton()),
              ],
            );
          }
          return const _MainPanelSkeleton();
        },
      ),
    );
  }
}

class _SidebarSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _ShimmerBox(width: 120, height: 14),
        const SizedBox(height: 16),
        ...List.generate(
          5,
          (_) => const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: _ShimmerBox(height: 52, width: double.infinity),
          ),
        ),
      ],
    );
  }
}

class _MainPanelSkeleton extends StatelessWidget {
  const _MainPanelSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _ShimmerBox(height: 100, width: double.infinity),
          const SizedBox(height: 24),
          const _ShimmerBox(width: 160),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: List.generate(
              8,
              (_) => const _ShimmerBox(width: 68, height: 92),
            ),
          ),
          const Spacer(),
          const _ShimmerBox(height: 48, width: double.infinity),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  const _ShimmerBox({
    this.width,
    this.height = 16,
  });

  final double? width;
  final double height;

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final base = const Color(AppColors.surfaceMuted);
    final highlight = const Color(AppColors.border);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = disableAnimations ? 0.5 : _controller.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDecorations.radiusSm),
            color: Color.lerp(base, highlight, t),
          ),
        );
      },
    );
  }
}
