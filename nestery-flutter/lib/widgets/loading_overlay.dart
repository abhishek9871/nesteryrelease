import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/utils/constants.dart';

class LoadingOverlay extends ConsumerWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingText;
  final Color? backgroundColor;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingText,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? Colors.black.withValues(alpha: 0.5),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Constants.primaryColor,
                    ),
                  ),
                  if (loadingText != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      loadingText!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class CustomProgressIndicator extends ConsumerWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const CustomProgressIndicator({
    super.key,
    this.size = 40,
    this.color,
    this.strokeWidth = 4.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? theme.colorScheme.primary,
        ),
        strokeWidth: strokeWidth,
      ),
    );
  }
}

class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Duration duration;

  const ShimmerLoading({
    super.key,
    required this.child,
    required this.isLoading,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    )..addListener(() {
        setState(() {});
      });

    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ShimmerLoading oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: const [
            Color(0xFFEBEBF4),
            Color(0xFFF4F4F4),
            Color(0xFFEBEBF4),
          ],
          stops: const [0.1, 0.3, 0.4],
          begin: Alignment(_animation.value, -0.5),
          end: Alignment(-_animation.value, 0.5),
        ).createShader(bounds);
      },
      child: widget.child,
    );
  }
}

class PropertyCardShimmer extends StatelessWidget {
  final bool isHorizontal;

  const PropertyCardShimmer({
    super.key,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      isLoading: true,
      child: isHorizontal
          ? _buildHorizontalShimmer(context)
          : _buildVerticalShimmer(context),
    );
  }

  Widget _buildVerticalShimmer(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 180,
            decoration: const BoxDecoration(
              color: Color(0xFFEBEBF4),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
          ),
          // Content placeholders
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title placeholder
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBEBF4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                // Location placeholder
                Container(
                  width: 200,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBEBF4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 12),
                // Rating and amenities placeholder
                Row(
                  children: [
                    Container(
                      width: 100,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBEBF4),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 80,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBEBF4),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalShimmer(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              color: Color(0xFFEBEBF4),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
          ),
          // Content placeholders
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title placeholder
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBEBF4),
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Location placeholder
                  Container(
                    width: 150,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBEBF4),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Price placeholder
                  Container(
                    width: 80,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBEBF4),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Amenities placeholder
                  Container(
                    width: 120,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBEBF4),
                      borderRadius: BorderRadius.circular(5),
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
}
