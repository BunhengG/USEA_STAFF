import 'package:flutter/material.dart';
import 'package:usea_staff_test/Components/custom_appbar_widget.dart';
import 'package:usea_staff_test/constant/constant.dart';
import 'package:provider/provider.dart';
import '../../helper/shared_pref_helper.dart';
import '../../provider/check_in_out_provider.dart';
import 'OpenMap.dart';
import 'scanQr_screen.dart';
import 'widget/bottom_sheet_reason.dart';
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

          if (provider.errorMessage != null) {
            return Center(
              child: Text(
                provider.errorMessage!,
                style: const TextStyle(color: uAtvColor, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            );
          }

          Color buttonColor;
          String buttonText;
          VoidCallback? onTap;

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
                child: Stack(
                  children: [
                    const ShiftDetailsWidget(),
                    const SizedBox(height: defaultPadding),
                    if (provider.shiftStatus != 'disabled')
                      Positioned(
                        top: smMargin - 6,
                        right: smMargin - 6,
                        child: GestureDetector(
                          onTap: onTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: mdMargin + 4,
                              vertical: mdPadding,
                            ),
                            decoration: BoxDecoration(
                              color: buttonColor,
                              borderRadius:
                                  BorderRadius.circular(roundedCornerSM - 2),
                            ),
                            child: Text(buttonText, style: getWhiteSubTitle()),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: defaultPadding),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OpenMap(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: mdPadding),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(roundedCornerSM),
                  ),
                  child: Text(
                    textAlign: TextAlign.center,
                    'Open Map',
                    style: getWhiteSubTitle(),
                  ),
                ),
              )
            ],
          );
        }),
      ),
    );
  }
}
