import 'package:flutter/material.dart';
import 'package:usea_staff_test/constant/constant.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color? backgroundColor;
  final TextStyle? subtitle;
  final String? iconPath;

  CustomAppBar({
    required this.title,
    this.backgroundColor = Colors.transparent,
    TextStyle? subtitle,
    this.iconPath = 'assets/icon/back.png',
  }) : this.subtitle = subtitle ?? getSubTitle();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: subtitle,
      ),
      centerTitle: true,
      backgroundColor: backgroundColor,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(4.0),
        child: IconButton(
          icon: Image.asset(
            iconPath!,
            scale: 12,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
