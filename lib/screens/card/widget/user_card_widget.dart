import 'package:flutter/material.dart';
import 'package:usea_staff_test/constant/constant.dart';

import '../../../model/permission.dart';

class CardBodyWidget extends StatelessWidget {
  final List<PermissionItem> permissions;

  const CardBodyWidget({super.key, required this.permissions});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(roundedCornerMD),
          color: secondaryColor,
          boxShadow: const [shadowLg],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          height: MediaQuery.of(context).size.height * 0.5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 10),
              Text(
                'Total Permissions',
                style: getSubTitle(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
