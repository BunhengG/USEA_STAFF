import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usea_staff_test/constant/constant.dart';
import '../../../provider/record_provider.dart';

class ShiftDetailsWidget extends StatefulWidget {
  const ShiftDetailsWidget({super.key});

  @override
  _ShiftDetailsWidgetState createState() => _ShiftDetailsWidgetState();
}

class _ShiftDetailsWidgetState extends State<ShiftDetailsWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500), // Adjust duration as needed
      vsync: this, // TickerProviderStateMixin provides vsync
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // Fetch shift details when the widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ShiftDetailsProvider>(context, listen: false)
          .fetchShiftDetails();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

    // Start fade-in animation once the data is loaded
    if (!provider.isLoading) {
      _controller.forward();
    }

    double _calculatePlaceholderHeight(
      String firstCheckInTime,
      String firstCheckOutTime,
      String secondCheckInTime,
      String secondCheckOutTime,
    ) {
      double baseHeight = 120.0;
      int itemCount = 0;

      // Check if the first check-in time exists
      if (firstCheckInTime != 'N/A') itemCount++;
      // Check if the first check-out time exists
      if (firstCheckOutTime != 'N/A') itemCount++;
      // Check if the second check-in time exists
      if (secondCheckInTime != 'N/A') itemCount++;
      // Check if the second check-out time exists
      if (secondCheckOutTime != 'N/A') itemCount++;

      double additionalHeightPerItem = 40.0;
      return baseHeight + (itemCount * additionalHeightPerItem);
    }

    return Container(
      color: secondaryColor,
      child: provider.isLoading
          ? Container(
              height: _calculatePlaceholderHeight(
                firstCheckInTime,
                firstCheckOutTime,
                secondCheckInTime,
                secondCheckOutTime,
              ),
              padding: const EdgeInsets.all(mdPadding),
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.circular(roundedCornerSM),
              ),
              // child: CircularProgressIndicator(color: backgroundColor),
            )
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
                  : FadeTransition(
                      opacity: _fadeAnimation,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: smPadding - 4),
                            Text(
                              dateShift,
                              style: getTitle().copyWith(fontSize: 16),
                            ),
                            const SizedBox(height: defaultPadding * 1.5),

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
                                padding:
                                    EdgeInsets.only(bottom: defaultPadding),
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
            // Text(
            //   title == 'N/A'
            //       ? ''
            //       : title == 'Good'
            //           ? '🔵 Good'
            //           : '',
            //   style: getBody().copyWith(fontSize: 14),
            // )
            if (title != 'N/A')
              Text(
                title,
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
