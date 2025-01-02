import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // Show no records found if the list is empty
          if (attendanceProvider.attendances.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No attendance records found.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // Display attendance list
          return ListView.separated(
            itemCount: attendanceProvider.attendances.length,
            itemBuilder: (context, index) {
              final attendance = attendanceProvider.attendances[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    leading: const Icon(
                      Icons.access_alarm,
                      color: Colors.blueAccent,
                    ),
                    title: Text(
                      attendance.username,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${attendance.date.toLocal().toString().split(' ')[0]} - ${attendance.attendStatus}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    trailing: Icon(
                      attendance.attendStatus == 'Present'
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: attendance.attendStatus == 'Present'
                          ? Colors.green
                          : Colors.red,
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
