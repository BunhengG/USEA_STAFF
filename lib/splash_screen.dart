import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:usea_staff_test/constant/constant.dart';

import 'auth/gate/authGate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToAuthGate();
  }

  void _navigateToAuthGate() async {
    await Future.delayed(const Duration(seconds: 3));
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AuthGate()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/img/logo.png',
              fit: BoxFit.cover,
              width: 140,
            ),
            Text(
              'Ultimate Check'.toUpperCase(),
              style: const TextStyle(
                fontSize: titleSize,
                fontFamily: ft_Eng,
                color: titlePrimaryColor,
                fontWeight: FontWeight.w600,
                wordSpacing: 3,
              ),
            ),
            const Text(
              'Suggests a top-tier solution.',
              style: TextStyle(
                fontSize: titleSize - 4,
                fontFamily: ft_Eng,
                color: titlePrimaryColor,
                fontWeight: FontWeight.w400,
              ),
            ),
            Lottie.asset('assets/icon/loading.json', width: 120),
          ],
        ),
      ),
    );
  }
}
