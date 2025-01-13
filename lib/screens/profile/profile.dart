import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:usea_staff_test/constant/constant.dart';
import '../../auth/login_screen.dart';
import '../../helper/shared_pref_helper.dart';
import 'package:quickalert/quickalert.dart';

import '../../provider/mycard_provider.dart';
import 'widget/profile_details_card.dart';

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
      headerBackgroundColor: primaryColor,
      backgroundColor: secondaryColor,
      borderRadius: roundedCornerSM,
      textColor: textColor,
      titleColor: uAtvColor,
      confirmBtnColor: uAtvColor,
      cancelBtnTextStyle: getWhiteSubTitle(),
      confirmBtnTextStyle: getWhiteSubTitle(),
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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: getSubTitle(),
        ),
        centerTitle: true,
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(4.0),
          child: IconButton(
            icon: Image.asset(
              'assets/icon/back.png',
              scale: 12,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: Image.asset(
              'assets/icon/signout.png',
              scale: 8,
            ),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Consumer<CardProvider>(builder: (context, cardProvider, child) {
          // Show loading indicator
          if (cardProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          // Show error message if any
          if (cardProvider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  cardProvider.errorMessage!,
                  style: getSubTitle().copyWith(color: uAtvColor),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // Show no records found if the list is empty
          if (cardProvider.cards.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No Card records found.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // Display the Card card at the top
          return Column(
            children: [
              // Display the list of Cards
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cardProvider.cards.length,
                itemBuilder: (context, index) {
                  final card = cardProvider.cards[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.25,
                        width: double.infinity,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Stack(
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: card.image,
                                    fit: BoxFit.fitWidth,
                                    width: double.infinity,
                                    placeholder: (context, url) =>
                                        const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                  Positioned.fill(
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 16.0,
                                        sigmaY: 16.0,
                                      ),
                                      child: Container(
                                        width: double.infinity,
                                        color: Colors.black45.withOpacity(0.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // CircleAvatar on top
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 46,
                                    backgroundColor: secondaryColor,
                                    child: CachedNetworkImage(
                                      imageUrl: card.image,
                                      placeholder: (context, url) =>
                                          const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                      fit: BoxFit.cover,
                                      scale: 6,
                                    ),
                                  ),
                                  _buildTextDetailsProfile(
                                    '',
                                    card.name,
                                    20,
                                  ),
                                  _buildTextDetailsProfile(
                                    'ID: ',
                                    card.userId,
                                    12,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: defaultMargin * 2),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            child: WorkingPeriodSection(),
                          ),
                          const SizedBox(height: defaultMargin),
                          _buildTextDetails(
                            FontAwesomeIcons.user,
                            card.name,
                          ),
                          _buildTextDetails(
                            FontAwesomeIcons.idCard,
                            card.userId,
                          ),
                          _buildTextDetails(
                            FontAwesomeIcons.transgenderAlt,
                            card.gender == 'M' ? 'Male' : 'Female',
                          ),
                          _buildTextDetails(
                            FontAwesomeIcons.calendarAlt,
                            card.dob!.toLocal().toString().split(' ')[0],
                          ),
                          _buildTextDetails(
                            FontAwesomeIcons.briefcase, // Icon for "Position"
                            card.position,
                          ),
                        ],
                      )
                    ],
                  );
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: defaultPadding),
              ),
            ],
          );
        }),
      ),
    );
  }

  _buildTextDetailsProfile(
    String title,
    String value,
    double size,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: getSubTitle().copyWith(color: secondaryColor, fontSize: size),
        ),
        Text(
          value,
          style: getSubTitle().copyWith(color: secondaryColor, fontSize: size),
        ),
      ],
    );
  }

  _buildTextDetails(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: smPadding,
      ),
      child: Container(
        padding: const EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: BorderRadius.circular(roundedCornerSM),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: smPadding,
                right: defaultPadding,
              ),
              child: FaIcon(
                icon,
                color: primaryColor,
              ),
            ),
            Text(
              value,
              style: getSubTitle(),
            ),
          ],
        ),
      ),
    );
  }
}
