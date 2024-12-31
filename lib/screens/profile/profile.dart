import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:usea_staff_test/constant/constant.dart';
import '../../auth/login_screen.dart';
import '../../helper/shared_pref_helper.dart';
import 'package:quickalert/quickalert.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  /// Show logout confirmation dialog
  Future<void> _logout(BuildContext context) async {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      title: 'Leave Company!',
      text: 'Are you sure you want to leave this company?',
      confirmBtnText: 'Sign Out',
      cancelBtnText: 'Cancel',
      headerBackgroundColor: Theme.of(context).primaryColor,
      backgroundColor: secondaryColor,
      borderRadius: 26,
      textColor: titleColor,
      titleColor: Theme.of(context).primaryColor,
      confirmBtnColor: Colors.redAccent,
      cancelBtnTextStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: titleColor,
      ),
      confirmBtnTextStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: secondaryColor,
      ),
      onConfirmBtnTap: () async {
        Navigator.pop(context);
        await _performLogoutActions(context);
      },
      onCancelBtnTap: () {
        Navigator.pop(context);
      },
    );
  }

  /// Perform logout actions
  Future<void> _performLogoutActions(BuildContext context) async {
    try {
      // Clear all stored user data
      await SharedPrefHelper.clearUserData();

      Future.microtask(() {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      });
    } catch (e) {
      debugPrint('Logout error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to logout. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const FaIcon(
              FontAwesomeIcons.signOutAlt,
              color: Colors.redAccent,
            ),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to the Profile App!'),
          ],
        ),
      ),
    );
  }
}
