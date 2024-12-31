import 'package:flutter/material.dart';

import '../constant/constant.dart';
import 'task_card.dart';

class TaskTabs extends StatelessWidget {
  const TaskTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: backgroundShape,
              borderRadius: BorderRadius.circular(roundedCornerMD),
            ),
            child: TabBar(
              labelPadding: const EdgeInsets.symmetric(horizontal: 5),
              labelColor: primaryColor,
              labelStyle: getSubTitle(),
              unselectedLabelColor: placeholderColor,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorColor: Colors.transparent,
              dividerColor: Colors.transparent,
              isScrollable: false,
              splashBorderRadius: BorderRadius.circular(roundedCornerSM),
              splashFactory: InkRipple.splashFactory,
              tabs: [
                Tab(
                  child: Container(
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.circular(roundedCornerSM),
                    ),
                    child: const Center(child: Text('Today')),
                  ),
                ),
                Tab(
                  child: Container(
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.circular(roundedCornerSM),
                    ),
                    child: const Center(child: Text('Tomorrow')),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: defaultMargin * 2),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: const TabBarView(
              children: [
                TaskCard(),
                Center(child: Text('No tasks for tomorrow')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
