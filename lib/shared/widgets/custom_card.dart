import 'package:flutter/material.dart';

enum CardType { elevated, outlined, flat }

class CustomCard extends StatelessWidget {
  final Widget child;
  final CardType type;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final double elevation;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final Gradient? gradient;
  final List<BoxShadow>? customShadows;
  final Border? border;

  const CustomCard({
    super.key,
    required this.child,
    this.type = CardType.elevated,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 12,
    this.elevation = 2,
    this.padding,
    this.margin,
    this.onTap,
    this.width,
    this.height,
    this.gradient,
    this.customShadows,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            decoration: _buildDecoration(),
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    switch (type) {
      case CardType.elevated:
        return BoxDecoration(
          color: backgroundColor ?? Colors.white,
          gradient: gradient,
          borderRadius: BorderRadius.circular(borderRadius),
          border: border,
          boxShadow: customShadows ?? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: elevation * 2,
              offset: Offset(0, elevation),
            ),
          ],
        );

      case CardType.outlined:
        return BoxDecoration(
          color: backgroundColor ?? Colors.white,
          gradient: gradient,
          borderRadius: BorderRadius.circular(borderRadius),
          border: border ?? Border.all(
            color: borderColor ?? Colors.grey.shade300,
            width: 1,
          ),
        );

      case CardType.flat:
        return BoxDecoration(
          color: backgroundColor ?? Colors.white,
          gradient: gradient,
          borderRadius: BorderRadius.circular(borderRadius),
          border: border,
        );
    }
  }
}

// Specialized cards for common use cases
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ActionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      backgroundColor: color.withValues(alpha: 0.1),
      border: Border.all(color: color.withValues(alpha: 0.3)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  const InfoCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
} 