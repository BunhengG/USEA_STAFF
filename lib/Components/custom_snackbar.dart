import 'package:flutter/material.dart';
import 'package:usea_staff_test/constant/constant.dart';

class CustomSnackbar extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final IconData? icon;
  final TextStyle? textStyle;

  const CustomSnackbar({
    super.key,
    required this.message,
    this.backgroundColor = secondaryColor,
    this.icon,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: defaultPadding,
          vertical: mdPadding,
        ),
        padding: const EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(roundedCornerSM),
        ),
        child: Row(
          children: [
            if (icon != null)
              Icon(
                icon,
                color: secondaryColor,
                size: 24,
              ),
            if (icon != null) const SizedBox(width: mdMargin),
            Expanded(
              child: Text(message, style: textStyle ?? getWhiteSubTitle()),
            ),
          ],
        ),
      ),
    );
  }
}
