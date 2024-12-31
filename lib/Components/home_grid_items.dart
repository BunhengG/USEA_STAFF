import 'package:flutter/material.dart';
import 'package:usea_staff_test/screens/attendance/attendance_screen.dart';
import 'package:usea_staff_test/screens/calendar/calendar_screen.dart';
import 'package:usea_staff_test/screens/card/card_screen.dart';
import 'package:usea_staff_test/screens/home_screen.dart';
import 'package:usea_staff_test/screens/member/member_screen.dart';
import 'package:usea_staff_test/screens/permission/permission_screen.dart';
import 'package:usea_staff_test/screens/scan_qr/scanQr_screen.dart';
import '../constant/constant.dart';

class MenuGrid extends StatelessWidget {
  final List<Map<String, dynamic>> menuItems = [
    {
      'icon': 'assets/icon/attendance.png',
      'label': 'Attendances',
      'route': '/attendance'
    },
    {
      'icon': 'assets/icon/permission.png',
      'label': 'Permission',
      'route': '/permission'
    },
    {
      'icon': 'assets/icon/calendar.png',
      'label': 'Calendar',
      'route': '/calendar'
    },
    {
      'icon': 'assets/icon/member.png',
      'label': 'Members',
      'route': '/members',
    },
    {
      'icon': 'assets/icon/card.png',
      'label': 'Card',
      'route': '/card',
    },
    {
      'icon': 'assets/icon/scan_qr.png',
      'label': 'Scan QR',
      'route': '/scan_qr'
    },
  ];

  MenuGrid({super.key});

  Widget getPage(String route) {
    switch (route) {
      case '/attendance':
        return const AttendanceScreen();
      case '/permission':
        return const PermissionScreen();
      case '/calendar':
        return const CalendarScreen();
      case '/members':
        return const MemberScreen();
      case '/card':
        return const CardScreen();
      case '/scan_qr':
        return const ScanQrScreen();
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundShape,
        borderRadius: BorderRadius.circular(roundedCornerMD),
      ),
      padding: const EdgeInsets.all(smPadding - 2),
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: menuItems.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
          childAspectRatio: 2.5 / 2,
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                CustomPageRoute(
                  child: getPage(menuItems[index]['route']),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.circular(roundedCornerSM),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    menuItems[index]['icon'],
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    menuItems[index]['label'],
                    style: getBody().copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
