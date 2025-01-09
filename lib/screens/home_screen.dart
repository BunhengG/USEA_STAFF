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
      child: const SafeArea(
        child: Scaffold(
          backgroundColor: backgroundColor,
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: smPadding),
                  ScrollableAppBar(),
                  SizedBox(height: defaultPadding),
                  Profile(),
                  WorkingPeriodSection(),
                  SizedBox(height: defaultPadding),
                  MenuGrid(),
                  SizedBox(height: defaultPadding),
                  SectionHeader(),
                  SizedBox(height: defaultPadding),
                  TaskTabs(),
                  SizedBox(height: defaultPadding),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
