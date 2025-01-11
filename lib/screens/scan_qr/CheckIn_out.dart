import 'package:flutter/material.dart';
import 'package:usea_staff_test/Components/custom_appbar_widget.dart';
import 'package:usea_staff_test/constant/constant.dart';
import 'package:provider/provider.dart';
import '../../Components/custom_snackbar.dart';
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

  void _showReasonCheckIn(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return ReasonBottomSheet(
          title: 'Why are you late?',
          subtitle: 'Please fill or select a reason.',
          reasons: const [
            'Sorry I\'m late.',
            'Sorry, Traffic is bad.',
            'Sorry I\'m Sick.',
          ],
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
          reasons: const [
            'Medical Appointment',
            'Family Obligation',
            'Health Issue',
            'Car Trouble',
            'Personal Emergency',
          ],
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
        child:
            Consumer<CheckInOutProvider>(builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          Color buttonColor;
          String buttonText;
          VoidCallback? onTap;

          // Button logic based on shift status and allowed range
          if (provider.errorMessage == errorAllowRange) {
            showCustomSnackbar(
              context,
              message: errorAllowRange,
              backgroundColor: atvColor,
              icon: Icons.error,
            );
            // User is outside the allowed range, show "Open Map"
            buttonColor = primaryColor;
            buttonText = 'Open Map';
            onTap = _openMap;
          } else {
            // User is within the allowed range, show "Check In" or "Check Out"
            switch (provider.shiftStatus) {
              case 'checkIn':
                buttonColor = checkIn;
                buttonText = 'Check In';
                onTap = () => _showReasonCheckIn(context);
                break;
              case 'checkOut':
                buttonColor = checkOut;
                buttonText = 'Check Out';
                onTap = () => _showReasonCheckOut(context);
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
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Display shift details and other widgets
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
              const SizedBox(height: defaultPadding),

              // Display the button based on the current state
              if (provider.shiftStatus != 'disabled')
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: provider.errorMessage == errorAllowRange
                          ? backgroundColor
                          : buttonColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        provider.errorMessage == errorAllowRange
                            ? const BoxShadow(color: Colors.transparent)
                            : shadowLg
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          textAlign: TextAlign.center,
                          buttonText,
                          style: provider.errorMessage == errorAllowRange
                              ? getSubTitle().copyWith(color: primaryColor)
                              : getWhiteSubTitle(),
                        ),
                        if (provider.errorMessage != errorAllowRange)
                          const DigitalClock(),
                      ],
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}
