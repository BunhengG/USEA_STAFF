import 'package:flutter/material.dart';
import 'package:usea_staff_test/constant/constant.dart';
import 'package:usea_staff_test/Components/home_appbar.dart';

import '../Components/home_card.dart';
import '../Components/home_grid_items.dart';
import '../Components/home_header.dart';
import '../Components/home_profile.dart';
import '../Components/task.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: SafeArea(
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
                  const Profile(),
                  const WorkingPeriodSection(),
                  const SizedBox(height: defaultPadding),
                  MenuGrid(),
                  const SizedBox(height: defaultPadding),
                  const SectionHeader(),
                  const SizedBox(height: defaultPadding),
                  const TaskTabs(),
                  const SizedBox(height: defaultPadding),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
