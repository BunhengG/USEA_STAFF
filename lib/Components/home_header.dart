import 'package:flutter/material.dart';
import 'package:usea_staff_test/constant/constant.dart';

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
            onPressed: () {},
            child: Text('Add Task',
                style: getSubTitle().copyWith(color: primaryColor)),
          ),
        ],
      ),
    );
  }
}
