import 'package:flutter/material.dart';
import 'package:usea_staff_test/constant/constant.dart';
import '../../helper/shared_pref_helper.dart';
import '../../screens/home_screen.dart';
import '../login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  _AuthGateState createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Future<bool> _loginStatusFuture;

  @override
  void initState() {
    super.initState();
    _loginStatusFuture = _checkLoginStatus();
  }

  // Method to check login status from SharedPreferences
  Future<bool> _checkLoginStatus() async {
    String? userId = await SharedPrefHelper.getUserId();
    String? password = await SharedPrefHelper.getPassword();
    return userId != null && password != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _loginStatusFuture,
      builder: (context, snapshot) {
        // Show loading screen while checking the login status
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: secondaryColor),
          );
        }

        // If there's an error, show an error message
        if (snapshot.hasError) {
          // return Center(child: Text('Error: ${snapshot.error}'));
          return Center(
            child: Text(
              'Oops! Something went wrong. Please try again.',
              style: getSubTitle(),
            ),
          );
        }

        // Return the appropriate screen based on login status
        return snapshot.data == true ? const HomeScreen() : const LoginScreen();
      },
    );
  }
}
