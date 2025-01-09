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
              'assets/img/usealogo.png',
              fit: BoxFit.cover,
              width: 140,
            ),
            const Text(
              'សាកលវិទ្យាល័យ សៅស៍អុីសថ៍អេយសៀ',
              style: TextStyle(
                fontSize: titleSize - 2,
                fontFamily: ft_Kh_Title,
                color: titlePrimaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'University of South-East Asia'.toUpperCase(),
              style: const TextStyle(
                fontSize: titleSize - 2,
                fontFamily: ft_Kh_Title,
                color: titlePrimaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            Lottie.asset('assets/icon/loading.json', width: 120),
          ],
        ),
      ),
    );
  }
}
