import 'package:flutter/material.dart';

import '../../Components/custom_appbar_widget.dart';
import '../../constant/constant.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'FAQ'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to the FAQ!',
              style: getSubTitle(),
            ),
          ],
        ),
      ),
    );
  }
}
