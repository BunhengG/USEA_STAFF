import 'package:flutter/material.dart';
import 'package:usea_staff_test/Components/custom_appbar_widget.dart';
import 'package:usea_staff_test/constant/constant.dart';
import 'package:provider/provider.dart';
import '../../helper/shared_pref_helper.dart';
import '../../provider/check_in_out_provider.dart';
import 'OpenMap.dart';
import 'scanQr_screen.dart';
import 'widget/bottom_sheet_reason.dart';
import 'widget/digital_clock.dart';
import 'widget/shift_details.dart';

class CheckInAndOutRecord extends StatefulWidget {
  const CheckInAndOutRecord({super.key});

  @override
  _CheckInAndOutRecordState createState() => _CheckInAndOutRecordState();
}

class _CheckInAndOutRecordState extends State<CheckInAndOutRecord> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<CheckInOutProvider>(context, listen: false);
      final userIdSPH = await SharedPrefHelper.getUserId();

      if (userIdSPH != null) {
        String userId = userIdSPH;
        String currentTime =
            DateTime.now().toLocal().toString().substring(11, 19);

        provider.updateButtonState(currentTime, userId);
      } else {
        print("User ID is null. Please log in again.");
      }
    });
  }

  final firstShiftCheckOut = "12:00";
  final secondShiftCheckOut = "5:00";

  final checkInReasons = [
    'Sorry I\'m late.',
    'អ៊ីនធឺណិតយឺត',
    'បញ្ហាសុខភាព',
    'អាកាសធាតុ',
    'រថយន្តខូច',
    'ភ្លេច Check-in',
    'ភ្លេចទូរស័ព្ទ',
    'ស្ទះផ្លូវ',
    'ជួបគ្រោះថ្នាក់',
    'រលុតទូរស័ព្ទ',
  ];

  final checkOutReason = [
    'ចុះទៅខេត្តបន្ទាន់',
    'ណាត់ជួបគ្រូពេទ្យ',
    'អត់ស្រួលខ្លួន',
    'មានរឿងបន្ទាន់',
    'ធ្វើឯកសារបន្ទាន់',
  ];

  void _showReasonCheckIn(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return ReasonBottomSheet(
          title: 'Why are you late?',
          subtitle: 'Please fill or select a reason.',
          reasons: checkInReasons,
          onReasonSubmitted: (reason) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CheckInOutQRScreen(reason: reason),
              ),
            ).then((qrCode) {
              if (qrCode != null) {
                final provider = Provider.of<CheckInOutProvider>(
                  context,
                  listen: false,
                );
                provider.checkInOut(qrCode, reason: reason);
              } else {
                print('Invalid QR code format.');
              }
            });
          },
        );
      },
    );
  }

  void _showReasonCheckOut(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return ReasonBottomSheet(
          title: 'Why are you leaving early?',
          subtitle: 'Please fill or select a reason.',
          reasons: checkOutReason,
          onReasonSubmitted: (reason) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CheckInOutQRScreen(reason: reason),
              ),
            ).then((qrCode) {
              if (qrCode != null) {
                final provider = Provider.of<CheckInOutProvider>(
                  context,
                  listen: false,
                );
                provider.checkInOut(qrCode, reason: reason);
              } else {
                print('Invalid QR code format.');
              }
            });
          },
        );
      },
    );
  }

  void _openMap() {
    Future.delayed(const Duration(milliseconds: 300), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const OpenMap(),
        ),
      );
    });
  }

  final String errorAllowRange =
      "You are not within the allowed range for check-in.";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(title: 'Check Record'),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Consumer<CheckInOutProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: primaryColor),
              );
            }

            Color buttonColor;
            String buttonText;
            VoidCallback? onTap;

            // Button logic based on shift status
            switch (provider.shiftStatus) {
              case 'checkIn':
                buttonColor = checkIn;
                buttonText = 'Check-in';

                if (provider.shouldShowCheckInReason) {
                  onTap = () => _showReasonCheckIn(context);
                } else {
                  provider.checkInOut("qrCode", reason: "");
                }
                break;
              case 'checkOut':
                buttonColor = checkOut;
                buttonText = 'Check-out';

                if (provider.shouldShowCheckOutReason) {
                  onTap = () => _showReasonCheckOut(context);
                } else {
                  onTap = () => provider.checkInOut("qrCode", reason: "");
                }
                break;
              case 'disabled':
                buttonColor = placeholderColor;
                buttonText = 'Disabled';
                onTap = null;
                break;
              default:
                buttonColor = anvColor;
                buttonText = 'Unknown';
                onTap = null;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(mdPadding),
                  decoration: BoxDecoration(
                    boxShadow: const [shadowLg],
                    color: secondaryColor,
                    borderRadius: BorderRadius.circular(roundedCornerSM),
                  ),
                  child: const Column(
                    children: [
                      ShiftDetailsWidget(),
                      SizedBox(height: defaultPadding),
                    ],
                  ),
                ),

                // The "Check In" or "Check Out" button
                if (provider.shiftStatus != 'disabled')
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: defaultPadding),
                    child: GestureDetector(
                      onTap: onTap,
                      child: _buildCheckInOutButton(buttonColor, buttonText),
                    ),
                  ),

                // The "Open Map" button
                if (provider.errorMessage == errorAllowRange)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: defaultPadding),
                    child: _buildMapButton(),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCheckInOutButton(Color buttonColor, String buttonText) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: buttonColor,
        shape: BoxShape.circle,
        boxShadow: const [shadowLg],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            textAlign: TextAlign.center,
            buttonText,
            style: getWhiteBody().copyWith(fontSize: 14),
          ),
          const DigitalClock(),
        ],
      ),
    );
  }

  Widget _buildMapButton() {
    return GestureDetector(
      onTap: _openMap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: mdPadding),
        child: Center(
          child: Text(
            'Open Map',
            style: getSubTitle().copyWith(color: primaryColor),
          ),
        ),
      ),
    );
  }
}
