import 'package:flutter/material.dart';
import 'package:usea_staff_test/constant/constant.dart';
import 'package:usea_staff_test/Components/home_appbar.dart';
import 'package:usea_staff_test/screens/profile/profile.dart';

import '../Components/home_grid_items.dart';
import '../Components/home_header.dart';
import '../Components/task.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: smPadding),
                const ScrollableAppBar(),
                const SizedBox(height: defaultPadding),
                const _Profile(),
                _WorkingPeriodSection(),
                const SizedBox(height: defaultPadding),
                MenuGrid(),
                const SizedBox(height: defaultPadding),
                const SectionHeader(),
                const SizedBox(height: defaultPadding),
                TaskTabs(),
                const SizedBox(height: defaultPadding),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Profile extends StatelessWidget {
  const _Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CustomPageRoute(child: const ProfileScreen()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: primaryColor,
                child: Image.asset(
                  'assets/img/avator.png',
                  scale: 12,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, John Doe!',
                  style: getSubTitle(),
                ),
                Text(
                  'Mobile App Developer and ...',
                  style: getBody(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkingPeriodSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundShape,
        borderRadius: BorderRadius.circular(roundedCornerMD),
      ),
      padding: const EdgeInsets.all(smPadding - 2),
      child: Container(
        padding: const EdgeInsets.all(mdPadding),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(roundedCornerSM + 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Working period'.toUpperCase(), style: getWhiteSubTitle()),
            const SizedBox(height: 16),
            _buildBodyPeriod('Join At', '12 January 2023'),
            _buildBodyPeriod('End Probation At', '12 March 2023'),
            _buildBodyPeriod('Work Anniversary', '1 Year 10 Months 7 Days'),
          ],
        ),
      ),
    );
  }

  _buildBodyPeriod(String contentTitle, String contentValue) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              contentTitle,
              style: getWhiteBody(),
            ),
          ),
          Text(
            ' : ',
            style: getWhiteBody(),
          ),
          Expanded(
            flex: 3,
            child: Text(
              contentValue,
              style: getWhiteBody(),
            ),
          ),
        ],
      ),
    );
  }
}
