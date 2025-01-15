import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
                padding: const EdgeInsets.all(16.0),
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
              final shiftSummary = attendance.shiftRecord;
              final firstShift = shiftSummary.firstShift;
              final secondShift = shiftSummary.secondShift;

              final dateShift = attendance.date;
              final firstCheckInTime = firstShift.checkIn.time;
              final firstCheckInStatus = firstShift.checkIn.status;
              final firstCheckOutStatus = firstShift.checkOut.status;
              final firstCheckOutTime = firstShift.checkOut.time;

              final secondCheckInStatus = secondShift.checkIn.status;
              final secondCheckInTime = secondShift.checkIn.time;
              final secondCheckOutStatus = secondShift.checkOut.status;
              final secondCheckOutTime = secondShift.checkOut.time;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: mdPadding),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: const [shadowLg],
                    borderRadius: BorderRadius.circular(roundedCornerSM),
                    color: secondaryColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(mdPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(formatDate(dateShift), style: getTitle()),

                            // 1st
                            _buildCheckIn(
                              '1st Check-in : ',
                              firstCheckInTime,
                              firstCheckInStatus,
                            ),

                            if (firstCheckInTime != 'N/A')
                              _buildCheckout(
                                '1st Check-out : ',
                                firstCheckOutTime,
                                firstCheckOutStatus,
                              ),

                            if (firstCheckOutTime != 'N/A')
                              // 2st
                              _buildCheckIn(
                                '2st Check-in : ',
                                secondCheckInTime,
                                secondCheckInStatus,
                              ),
                            if (secondCheckInTime != 'N/A')
                              _buildCheckout(
                                '2st Check-out : ',
                                secondCheckOutTime,
                                secondCheckOutStatus,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) =>
                const SizedBox(height: defaultMargin * 1.5),
          );
        },
      ),
    );
  }

  String formatDate(String date) {
    try {
      return DateFormat('dd MMMM yyyy').format(DateTime.parse(date));
    } catch (e) {
      return date;
    }
  }

  Widget _buildCheckIn(
    String shiftTitle,
    String title,
    String value,
  ) {
    return Column(
      children: [
        Row(
          children: [
            //! st Check-in
            Row(
              children: [
                Text(
                  '• ',
                  style: getTitle().copyWith(color: textColor),
                ),
                Text(shiftTitle, style: getSubTitle()),
              ],
            ),
            const SizedBox(width: defaultPadding * 2),

            Text(
              value,
              style: getBody().copyWith(fontSize: 14),
            )
          ],
        ),
        //? Time
        ListTile(
          title: Text(
            'Time : $title',
            style: getSubTitle().copyWith(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckout(
    String shiftTitle,
    String time,
    String status,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              '• ',
              style: getTitle().copyWith(color: textColor),
            ),
            Text(shiftTitle, style: getSubTitle()),
            const SizedBox(width: defaultPadding * 1.3),
            Text(
              status,
              style: getBody().copyWith(fontSize: 14),
            ),
          ],
        ),
        ListTile(
          title: Text(
            'Time: $time',
            style: getSubTitle().copyWith(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
