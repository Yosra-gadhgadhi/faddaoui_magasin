import 'package:flutter/material.dart';

import 'package:elfaddoui_app/core/theme/app_colors.dart';

class AppSkeletonBlock extends StatefulWidget {
  final double height;
  final double width;
  final double radius;

  const AppSkeletonBlock({
    super.key,
    required this.height,
    this.width = double.infinity,
    this.radius = 14,
  });

  @override
  State<AppSkeletonBlock> createState() => _AppSkeletonBlockState();
}

class _AppSkeletonBlockState extends State<AppSkeletonBlock>
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.9)),
            gradient: LinearGradient(
              begin: Alignment(-1 + (t * 1.2), -0.2),
              end: Alignment(1 + (t * 1.2), 0.2),
              colors: const [
                Color(0xFFF7F2F4),
                Color(0xFFF0E5EA),
                Color(0xFFF7F2F4),
              ],
            ),
          ),
        );
      },
    );
  }
}
