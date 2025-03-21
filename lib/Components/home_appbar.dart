import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:usea_staff_test/constant/constant.dart';
import 'package:usea_staff_test/screens/faq/faq.dart';
import 'package:usea_staff_test/screens/notification/notification_screen.dart';

class ScrollableAppBar extends StatelessWidget {
  const ScrollableAppBar({super.key});

  void _showLanguageModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(roundedCornerLG)),
      ),
      isScrollControlled: true,
      backgroundColor: backgroundColor,
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(roundedCornerLG),
                  ),
                  color: backgroundColor,
                ),
              ),
            ),
          ),
          // Modal content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding * 1.5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Select Language',
                    style: getSubTitle(),
                  ),
                  const SizedBox(height: mdPadding),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            print('Khmer selected');
                          },
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/icon/khmer.png',
                                width: 60,
                                height: 60,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Khmer',
                                style: getBody(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Flexible(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            print('English selected');
                          },
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/icon/english.png',
                                width: 60,
                                height: 60,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'English',
                                style: getBody(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // FAQ Button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                CustomPageRoute(child: const FAQScreen()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Image.asset('assets/icon/faq.png', scale: 6),
            ),
          ),
          // Notifications Button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                CustomPageRoute(child: const NotificationScreen()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Image.asset('assets/icon/noti.png', scale: 6),
            ),
          ),
          // Languages Button (Modal Popup)
          GestureDetector(
            onTap: () {
              _showLanguageModal(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Image.asset('assets/icon/languages.png', scale: 6),
            ),
          ),
        ],
      ),
    );
  }
}
