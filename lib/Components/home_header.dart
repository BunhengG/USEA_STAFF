import 'package:flutter/material.dart';
import 'package:usea_staff_test/constant/constant.dart';
import 'package:usea_staff_test/screens/task/task_screen.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Tasks', style: getSubTitle()),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                CustomPageRoute(child: const TaskScreen()),
              );
            },
            child: Text('Add Task',
                style: getSubTitle().copyWith(color: primaryColor)),
          ),
        ],
      ),
    );
  }
}
