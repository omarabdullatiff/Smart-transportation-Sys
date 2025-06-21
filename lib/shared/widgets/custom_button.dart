import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';

enum ButtonType { primary, secondary, outline, text, danger, success }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double elevation;
  final Widget? child;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.width,
    this.height = 50,
    this.borderRadius = 12,
    this.padding,
    this.textStyle,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.elevation = 0,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bool isButtonDisabled = isDisabled || isLoading || onPressed == null;
    
    return SizedBox(
      width: width,
      height: height,
      child: _buildButton(context, isButtonDisabled),
    );
  }

  Widget _buildButton(BuildContext context, bool isButtonDisabled) {
    switch (type) {
      case ButtonType.primary:
        return ElevatedButton(
          onPressed: isButtonDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppColor.primary,
            foregroundColor: textColor ?? Colors.white,
            elevation: elevation,
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            disabledBackgroundColor: Colors.grey.shade300,
            disabledForegroundColor: Colors.grey.shade600,
          ),
          child: _buildButtonContent(),
        );

      case ButtonType.secondary:
        return ElevatedButton(
          onPressed: isButtonDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? Colors.grey.shade100,
            foregroundColor: textColor ?? Colors.black87,
            elevation: elevation,
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            disabledBackgroundColor: Colors.grey.shade200,
            disabledForegroundColor: Colors.grey.shade500,
          ),
          child: _buildButtonContent(),
        );

      case ButtonType.outline:
        return OutlinedButton(
          onPressed: isButtonDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: textColor ?? AppColor.primary,
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            side: BorderSide(
              color: borderColor ?? AppColor.primary,
              width: 1.5,
            ),
            disabledForegroundColor: Colors.grey.shade500,
          ),
          child: _buildButtonContent(),
        );

      case ButtonType.text:
        return TextButton(
          onPressed: isButtonDisabled ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: textColor ?? AppColor.primary,
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            disabledForegroundColor: Colors.grey.shade500,
          ),
          child: _buildButtonContent(),
        );

      case ButtonType.danger:
        return ElevatedButton(
          onPressed: isButtonDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? Colors.red,
            foregroundColor: textColor ?? Colors.white,
            elevation: elevation,
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            disabledBackgroundColor: Colors.grey.shade300,
            disabledForegroundColor: Colors.grey.shade600,
          ),
          child: _buildButtonContent(),
        );

      case ButtonType.success:
        return ElevatedButton(
          onPressed: isButtonDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? Colors.green,
            foregroundColor: textColor ?? Colors.white,
            elevation: elevation,
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            disabledBackgroundColor: Colors.grey.shade300,
            disabledForegroundColor: Colors.grey.shade600,
          ),
          child: _buildButtonContent(),
        );
    }
  }

  Widget _buildButtonContent() {
    if (child != null) {
      return child!;
    }

    if (isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                textColor ?? (type == ButtonType.outline || type == ButtonType.text 
                    ? AppColor.primary 
                    : Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: textStyle,
          ),
        ],
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: textStyle,
          ),
        ],
      );
    }

    return Text(
      text,
      style: textStyle,
    );
  }
} 