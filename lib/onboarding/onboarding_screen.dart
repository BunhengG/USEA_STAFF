import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:usea_staff_test/auth/login_screen.dart';
import 'package:usea_staff_test/constant/constant.dart';
import 'package:usea_staff_test/onboarding/pages/intro_page_2.dart';
import 'package:usea_staff_test/onboarding/pages/intro_page_3.dart';

import 'pages/intro_page_1.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool _isLastPage = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                _isLastPage = index == 2;
              });
            },
            children: const [
              PageOne(),
              PageTwo(),
              PageThree(),
            ],
          ),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => _controller.jumpToPage(2),
                  child: Text('Skip'.toUpperCase(), style: getWhiteSubTitle()),
                ),
                SmoothPageIndicator(
                  controller: _controller,
                  count: 3,
                  effect: const SwapEffect(
                    activeDotColor: primaryColor,
                    dotColor: secondaryColor,
                    dotHeight: 14,
                    dotWidth: 14,
                    spacing: 8.0,
                  ),
                ),
                TextButton(
                  onPressed: _isLastPage
                      ? () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        }
                      : () => _controller.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.ease,
                          ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: defaultPadding,
                      vertical: smPadding,
                    ),
                    decoration: BoxDecoration(
                      boxShadow: const [shadow],
                      color: secondaryColor,
                      borderRadius: BorderRadius.circular(roundedCornerSM),
                    ),
                    child: Text(
                      _isLastPage ? 'Done'.toUpperCase() : 'Next'.toUpperCase(),
                      style: getSubTitle(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
