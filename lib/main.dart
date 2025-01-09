import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usea_staff_test/provider/calendar_provider.dart';
import 'package:usea_staff_test/provider/memeber_provider.dart';
import 'package:usea_staff_test/provider/mycard_provider.dart';
import 'package:usea_staff_test/provider/permission_provider.dart';
import 'package:usea_staff_test/splash_screen.dart';
// import 'auth/gate/authGate.dart';
import 'provider/attendance_provider.dart';
import 'provider/check_in_out_provider.dart';
import 'provider/record_provider.dart';
import 'provider/task_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => PermissionProvider()),
        ChangeNotifierProvider(create: (_) => CalendarProvider()),
        ChangeNotifierProvider(create: (_) => MemberProvider()),
        ChangeNotifierProvider(create: (_) => CardProvider()),
        ChangeNotifierProvider(create: (_) => CheckInOutProvider()),
        ChangeNotifierProvider(create: (_) => ShiftDetailsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // home: const AuthGate(),
      home: const SplashScreen(),

      debugShowCheckedModeBanner: false,
      title: 'Employee Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
