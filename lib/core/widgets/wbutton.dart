import 'package:flutter/material.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';

class WButton extends StatelessWidget {
  final String label;
  final Widget? icon;
  final ButtonStyle? style;
  final VoidCallback? onPressed;
  final TextStyle? labelStyle;

  const WButton({
    super.key,
    required this.label,
    this.icon,
    this.style,
    this.onPressed,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    final ButtonStyle baseStyle = ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 18),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 2,
    );

    final ButtonStyle finalStyle = baseStyle.merge(style);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onPressed ?? () {},
          icon: icon ?? const SizedBox.shrink(),
          label: Text(
            label,
            style: labelStyle ??
                const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
          ),
          style: finalStyle,
        ),
      ),
    );
  }
}
