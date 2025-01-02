import 'package:flutter/material.dart';
// import 'package:percent_indicator/percent_indicator.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:usea_staff_test/constant/constant.dart';

import '../../../model/permission.dart';

class PermissionCardWidget extends StatelessWidget {
  final List<PermissionItem> permissions;

  const PermissionCardWidget({super.key, required this.permissions});

  @override
  Widget build(BuildContext context) {
    const totalPermissions = 18;
    final totalPermissionDaysUsed = permissions.fold<int>(
        0, (sum, permission) => sum + permission.permissionDay);

    final remainingPermissions = totalPermissions - totalPermissionDaysUsed;
    final percentage = remainingPermissions / totalPermissions;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        color: secondaryColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(roundedCornerMD),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          height: MediaQuery.of(context).size.height * 0.3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircularPercentIndicator(
                radius: 60.0,
                lineWidth: 14.0,
                animation: true,
                animationDuration: 1000,
                percent: percentage,
                center: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${remainingPermissions.toInt()}',
                      style: getSubTitle(),
                    ),
                    Text(
                      'Remain',
                      style: getSubTitle(),
                    )
                  ],
                ),
                circularStrokeCap: CircularStrokeCap.round,
                // arcType: ArcType.FULL,
                // curve: Curves.easeInOut,
                // arcBackgroundColor: placeholderColor,
                backgroundColor: const Color(0xFFE7E7E7),
                progressColor:
                    remainingPermissions == 18 ? anvColor : primaryColor,
              ),
              const SizedBox(width: 10),
              Text(
                'Total Permissions: $totalPermissions',
                style: getSubTitle(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
