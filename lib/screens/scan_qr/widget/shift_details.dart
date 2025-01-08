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

    final shiftSummary = provider.shiftSummary;
    final firstShift = shiftSummary?.shiftRecord.firstShift;
    final secondShift = shiftSummary?.shiftRecord.secondShift;

    final dateShift = shiftSummary?.date ?? 'No date available';
    final firstCheckInTime = firstShift?.checkIn.time ?? 'N/A';
    final firstCheckInStatus = firstShift?.checkIn.status ?? 'N/A';
    final firstCheckOutStatus = firstShift?.checkOut.status ?? 'N/A';
    final firstCheckOutTime = firstShift?.checkOut.time ?? 'N/A';

    final secondCheckInStatus = secondShift?.checkIn.status ?? 'N/A';
    final secondCheckInTime = secondShift?.checkIn.time ?? 'N/A';
    final secondCheckOutStatus = secondShift?.checkOut.status ?? 'N/A';
    final secondCheckOutTime = secondShift?.checkOut.time ?? 'N/A';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: mdPadding),
      child: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: backgroundColor))
          : provider.errorMessage != null
              ? Center(
                  child: Text(provider.errorMessage!, style: getSubTitle()),
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
                          const SizedBox(height: smPadding - 4),
                          Text(
                            dateShift,
                            style: getTitle().copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: defaultPadding * 2),

                          // NOTE: 1st Check-in
                          _buildCheckIn(
                            '1st Check-in : ',
                            firstCheckInTime,
                            firstCheckInStatus,
                          ),

                          // NOTE: 1st Check-out
                          if (firstCheckInTime != 'N/A')
                            _buildCheckout(
                              '1st Check-out : ',
                              firstCheckOutStatus,
                              firstCheckOutTime,
                            ),

                          //? Divider
                          if (firstCheckOutTime != 'N/A')
                            const Padding(
                              padding: EdgeInsets.only(bottom: defaultPadding),
                              child: Divider(color: backgroundColor),
                            ),

                          //NOTE: 2st Check-in
                          if (firstCheckOutTime != 'N/A')
                            _buildCheckIn(
                              '2st Check-in : ',
                              secondCheckInTime,
                              secondCheckInStatus,
                            ),

                          //NOTE: 2st Check-out
                          if (secondCheckInTime != 'N/A')
                            _buildCheckout(
                              '2st Check-out : ',
                              secondCheckOutStatus,
                              secondCheckOutTime,
                            ),
                        ],
                      ),
                    ),
    );
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
                  style: title != 'N/A'
                      ? getTitle().copyWith(color: textColor)
                      : getTitle(),
                ),
                Text(shiftTitle, style: getSubTitle()),
              ],
            ),
            const SizedBox(width: defaultPadding * 2),

            if (title != 'N/A')
              Text(
                value,
                style: getBody().copyWith(fontSize: 14),
              )
          ],
        ),
        //? Time
        if (title != 'N/A')
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
    String title,
    String value,
  ) {
    return Column(
      children: [
        Row(
          children: [
            //! st Check-out
            Row(
              children: [
                Text(
                  '• ',
                  style: title != 'N/A'
                      ? getTitle().copyWith(color: textColor)
                      : getTitle(),
                ),
                Text(shiftTitle, style: getSubTitle()),
              ],
            ),
            const SizedBox(width: defaultPadding * 1.3),
            Text(
              title == 'N/A'
                  ? ''
                  : title == 'Good'
                      ? '🔵 Good'
                      : '',
              style: getBody().copyWith(fontSize: 14),
            )
          ],
        ),
        //? Time
        if (title != 'N/A')
          ListTile(
            title: Text(
              'Time: $value',
              style: getSubTitle().copyWith(fontSize: 16),
            ),
          ),
      ],
    );
  }
}
