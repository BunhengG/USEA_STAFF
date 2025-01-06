import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usea_staff_test/constant/constant.dart';
import '../../../provider/record_provider.dart';

class ShiftDetailsWidget extends StatefulWidget {
  const ShiftDetailsWidget({super.key});

  @override
  _ShiftDetailsWidgetState createState() => _ShiftDetailsWidgetState();
}

class _ShiftDetailsWidgetState extends State<ShiftDetailsWidget> {
  @override
  void initState() {
    super.initState();
    // Fetch shift details when the widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ShiftDetailsProvider>(context, listen: false)
          .fetchShiftDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ShiftDetailsProvider>(context);

    return Container(
      padding: const EdgeInsets.all(mdPadding),
      child: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.errorMessage != null
              ? Center(
                  child: Text(
                    provider.errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                )
              : provider.shiftSummary == null
                  ? Center(
                      child: Text(
                        'No shift data available.',
                        style: getSubTitle(),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(provider.shiftSummary!.date, style: getTitle()),
                          const SizedBox(height: defaultPadding),

                          // First Shift Details
                          Row(
                            children: [
                              Text('• 1st Check-in:', style: getSubTitle()),
                              const SizedBox(width: 26),
                              Text(
                                '🔴 ${provider.shiftSummary!.shiftRecord.firstShift.checkIn.status}',
                                style: getBody().copyWith(fontSize: 14),
                              )
                            ],
                          ),

                          ListTile(
                            title: Text(
                              'Time : ${provider.shiftSummary!.shiftRecord.firstShift.checkIn.time}',
                              style: getSubTitle(),
                            ),
                          ),

                          Row(
                            children: [
                              Text('• 1st Check-Out:', style: getSubTitle()),
                              const SizedBox(width: 26),
                              Text(
                                '🔵 ${provider.shiftSummary!.shiftRecord.firstShift.checkOut.status}',
                                style: getBody().copyWith(fontSize: 14),
                              )
                            ],
                          ),

                          ListTile(
                            title: Text(
                              'Time: ${provider.shiftSummary!.shiftRecord.firstShift.checkOut.time}',
                              style: getSubTitle(),
                            ),
                          ),
                          const Divider(),

                          // Second Shift Details

                          Row(
                            children: [
                              Text('• 2st Check-In:', style: getSubTitle()),
                              const SizedBox(width: 26),
                              Text(
                                '🔴 ${provider.shiftSummary!.shiftRecord.secondShift.checkIn.status}',
                                style: getBody().copyWith(fontSize: 14),
                              )
                            ],
                          ),
                          ListTile(
                            title: Text(
                              'Time: ${provider.shiftSummary!.shiftRecord.secondShift.checkIn.time}',
                              style: getSubTitle(),
                            ),
                          ),
                          Row(
                            children: [
                              Text('• 2st Check-Out:', style: getSubTitle()),
                              const SizedBox(width: 26),
                              Text(
                                '🔵 ${provider.shiftSummary!.shiftRecord.secondShift.checkOut.status}',
                                style: getBody().copyWith(fontSize: 14),
                              )
                            ],
                          ),
                          ListTile(
                            title: Text(
                              'Time: ${provider.shiftSummary!.shiftRecord.secondShift.checkOut.time}',
                              style: getSubTitle(),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
