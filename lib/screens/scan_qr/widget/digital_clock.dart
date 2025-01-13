import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:usea_staff_test/constant/constant.dart';

class DigitalClock extends StatefulWidget {
  const DigitalClock({super.key});

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = DateTime.now();
    // final format = DateFormat('hh:mm:ss a');
    final format = DateFormat('hh:mm a');
    return Text(
      format.format(dateTime),
      style: getWhiteSubTitle().copyWith(fontSize: 18),
    );
  }
}
