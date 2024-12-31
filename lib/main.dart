import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:usea_staff_test/screens/home_screen.dart';
import 'auth/gate/authGate.dart';
import 'provider/task_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
      title: 'Employee Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
