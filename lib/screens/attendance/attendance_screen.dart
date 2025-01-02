import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usea_staff_test/constant/constant.dart';
import '../../Components/custom_appbar_widget.dart';
import '../../provider/attendance_provider.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch attendance data when the screen loads
    Provider.of<AttendanceProvider>(context, listen: false).fetchAttendances();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(title: 'Attendance'),
      body: Consumer<AttendanceProvider>(
        builder: (context, attendanceProvider, child) {
          // Show loading indicator
          if (attendanceProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Show error message if any
          if (attendanceProvider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  attendanceProvider.errorMessage!,
                  style: getSubTitle().copyWith(color: uAtvColor),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // Show no records found if the list is empty
          if (attendanceProvider.attendances.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No attendance records found.',
                  style: getSubTitle(),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // Display attendance list
          return ListView.separated(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: attendanceProvider.attendances.length,
            itemBuilder: (context, index) {
              final attendance = attendanceProvider.attendances[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: mdPadding),
                child: Card(
                  color: secondaryColor,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(roundedCornerSM),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(mdPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              attendance.attendStatus == 'A1' ? 'A1' : 'A2',
                              style: attendance.attendStatus == 'A1'
                                  ? getTitle()
                                  : getTitle().copyWith(color: uAtvColor),
                            ),

                            //* Vertical Divider
                            Container(
                              height: 50,
                              width: 3,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius:
                                    BorderRadius.circular(roundedCornerSM),
                              ),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                            ),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //* Title Section
                                Row(
                                  children: [
                                    Text(
                                      'Check In / Out',
                                      style: getSubTitle().copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: mdPadding),
                                    Text(
                                      attendance.date
                                          .toLocal()
                                          .toString()
                                          .split(' ')[0],
                                      style: getBody()
                                          .copyWith(color: primaryColor),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: mdPadding),
                                Text(
                                  '🔵 ${attendance.morningTime} AM',
                                  style: getBody(),
                                ),
                                Text(
                                  '🔵 ${attendance.afternoonTime} PM',
                                  style: getBody(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 10),
          );
        },
      ),
    );
  }
}
