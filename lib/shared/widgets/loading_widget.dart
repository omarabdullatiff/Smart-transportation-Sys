import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';

enum LoadingType { circular, linear, dots, wave }

class LoadingWidget extends StatelessWidget {
  final LoadingType type;
  final String? message;
  final Color? color;
  final double size;
  final bool showMessage;

  const LoadingWidget({
    super.key,
    this.type = LoadingType.circular,
    this.message,
    this.color,
    this.size = 24,
    this.showMessage = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLoadingIndicator(),
        if (showMessage && message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: TextStyle(
              color: color ?? AppColor.primary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    switch (type) {
      case LoadingType.circular:
        return SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? AppColor.primary,
            ),
            strokeWidth: 3,
          ),
        );

      case LoadingType.linear:
        return SizedBox(
          width: size * 4,
          child: LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? AppColor.primary,
            ),
            backgroundColor: (color ?? AppColor.primary).withValues(alpha: 0.2),
          ),
        );

      case LoadingType.dots:
        return DotsLoadingIndicator(
          color: color ?? AppColor.primary,
          size: size,
        );

      case LoadingType.wave:
        return WaveLoadingIndicator(
          color: color ?? AppColor.primary,
          size: size,
        );
    }
  }
}

class DotsLoadingIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const DotsLoadingIndicator({
    super.key,
    required this.color,
    required this.size,
  });

  @override
  State<DotsLoadingIndicator> createState() => _DotsLoadingIndicatorState();
}

class _DotsLoadingIndicatorState extends State<DotsLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _animations = List.generate(3, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.2,
            0.6 + index * 0.2,
            curve: Curves.elasticOut,
          ),
        ),
      );
    });

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: widget.size * 0.1),
              child: Transform.scale(
                scale: _animations[index].value,
                child: Container(
                  width: widget.size * 0.3,
                  height: widget.size * 0.3,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class WaveLoadingIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const WaveLoadingIndicator({
    super.key,
    required this.color,
    required this.size,
  });

  @override
  State<WaveLoadingIndicator> createState() => _WaveLoadingIndicatorState();
}

class _WaveLoadingIndicatorState extends State<WaveLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animations = List.generate(4, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.1,
            0.5 + index * 0.1,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: widget.size * 0.05),
              child: Container(
                width: widget.size * 0.15,
                height: widget.size * (0.5 + _animations[index].value * 0.5),
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(widget.size * 0.075),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

// Full screen loading overlay
class LoadingOverlay extends StatelessWidget {
  final String? message;
  final LoadingType type;
  final Color? backgroundColor;
  final Color? loadingColor;

  const LoadingOverlay({
    super.key,
    this.message,
    this.type = LoadingType.circular,
    this.backgroundColor,
    this.loadingColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: LoadingWidget(
            type: type,
            message: message ?? 'Loading...',
            color: loadingColor,
            size: 32,
          ),
        ),
      ),
    );
  }

  static void show(
    BuildContext context, {
    String? message,
    LoadingType type = LoadingType.circular,
    Color? backgroundColor,
    Color? loadingColor,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingOverlay(
        message: message,
        type: type,
        backgroundColor: backgroundColor,
        loadingColor: loadingColor,
      ),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}

// Page loading widget for when entire page is loading
class PageLoading extends StatelessWidget {
  final String? message;
  final LoadingType type;
  final Color? color;

  const PageLoading({
    super.key,
    this.message,
    this.type = LoadingType.circular,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: LoadingWidget(
          type: type,
          message: message ?? 'Loading...',
          color: color,
          size: 48,
        ),
      ),
    );
  }
} 