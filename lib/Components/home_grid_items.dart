import 'package:flutter/material.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usea_staff_test/screens/attendance/attendance_screen.dart';
import 'package:usea_staff_test/screens/calendar/calendar_screen.dart';
import 'package:usea_staff_test/screens/card/card_screen.dart';
import 'package:usea_staff_test/screens/home_screen.dart';
import 'package:usea_staff_test/screens/member/member_screen.dart';
import 'package:usea_staff_test/screens/permission/permission_screen.dart';
import '../constant/constant.dart';
import '../screens/scan_qr/CheckIn_out.dart';

class MenuGrid extends StatefulWidget {
  const MenuGrid({super.key});

  @override
  _MenuGridState createState() => _MenuGridState();
}

class _MenuGridState extends State<MenuGrid> {
  List<Map<String, dynamic>> menuItems = [
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

  int gridColumns = 3;

  @override
  void initState() {
    super.initState();
    _loadMenuOrder(); // Load the saved menu order on app startup
  }

  Future<void> _loadMenuOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final savedOrder = prefs.getStringList('menuOrder');

    if (savedOrder != null) {
      setState(() {
        // Reorder `menuItems` based on savedOrder
        menuItems.sort((a, b) {
          int aIndex = savedOrder.indexOf(a['route']);
          int bIndex = savedOrder.indexOf(b['route']);
          return aIndex.compareTo(bIndex);
        });
      });
    }
  }

  Future<void> _saveMenuOrder() async {
    final prefs = await SharedPreferences.getInstance();
    // Save the current order of `menuItems` based on their routes
    final order = menuItems.map((item) => item['route'] as String).toList();
    await prefs.setStringList('menuOrder', order);
  }

  // Method to show a dialog for selecting grid columns
  void _showColumnSelectDialog() {
    showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Custom GridItems',
            style: getTitle(),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  '2 Items',
                  style: getSubTitle(),
                ),
                onTap: () {
                  Navigator.pop(context, 2);
                },
              ),
              const Divider(thickness: 0.5),
              ListTile(
                title: Text(
                  '3 Items',
                  style: getSubTitle(),
                ),
                onTap: () {
                  Navigator.pop(context, 3);
                },
              ),
            ],
          ),
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          gridColumns = value;
        });
      }
    });
  }

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
        return const CheckInAndOutRecord();
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _showColumnSelectDialog,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundShape,
          borderRadius: BorderRadius.circular(roundedCornerMD),
        ),
        padding: const EdgeInsets.all(smPadding - 2),
        child: ReorderableGridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridColumns,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            childAspectRatio: 2.5 / 2,
          ),
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              key: ValueKey(menuItems[index]),
              onTap: () {
                Navigator.push(
                  context,
                  CustomPageRoute(
                    child: getPage(menuItems[index]['route']),
                  ),
                );
              },
              // onLongPress: _showColumnSelectDialog,
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
          onReorder: (oldIndex, newIndex) {
            setState(() {
              final item = menuItems.removeAt(oldIndex);
              menuItems.insert(newIndex, item);
            });
            _saveMenuOrder();
          },
        ),
      ),
    );
  }
}
