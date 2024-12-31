import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:usea_staff_test/auth/login_qr.dart';
import 'package:usea_staff_test/constant/constant.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  // Launch Telegram URL
  Future<void> _launchUrl() async {
    final Uri telegramUrl = Uri.parse('https://t.me/hengKhunNathip');
    if (await canLaunchUrl(telegramUrl)) {
      await launchUrl(telegramUrl);
    } else {
      throw 'Could not launch $telegramUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLogo(),
            _buildWelcomeText(),
            _buildQRCodeButton(context),
            _buildContactRow(),
          ],
        ),
      ),
    );
  }

  // Widget for logo image
  Widget _buildLogo() {
    return Image.asset('assets/img/usealogo.png', scale: 4);
  }

  // Widget for welcome text
  Widget _buildWelcomeText() {
    return Padding(
      padding:
          const EdgeInsets.only(top: defaultPadding, bottom: defaultPadding),
      child: Text(
        'Welcome to usea staff!'.toUpperCase(),
        style: getTitle(),
      ),
    );
  }

  // Widget for QR code button
  Widget _buildQRCodeButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 6,
        padding: const EdgeInsets.symmetric(
          horizontal: defaultPadding * 2,
          vertical: defaultPadding,
        ),
        shape: const StadiumBorder(),
        foregroundColor: secondaryColor,
        backgroundColor: primaryColor,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginQRScreen(),
          ),
        );
      },
      child: Text(
        'Sign in with QR code'.toUpperCase(),
        style: getWhiteSubTitle(),
      ),
    );
  }

  // Widget Button Contact Us.
  Widget _buildContactRow() {
    return Padding(
      padding: const EdgeInsets.only(top: defaultPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Don\'t have an account?',
            style: getSubTitle(),
          ),
          TextButton(
            onPressed: _launchUrl,
            child: Text(
              'Contact Us.',
              style: getSubTitle().copyWith(
                color: primaryColor,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
