import 'package:flutter/material.dart';
import 'package:usea_staff_test/Components/custom_appbar_widget.dart';
import 'package:usea_staff_test/constant/constant.dart';
import 'package:provider/provider.dart';
import '../../Components/custom_snackbar.dart';
import '../../helper/shared_pref_helper.dart';
import '../../provider/check_in_out_provider.dart';
import 'scanQr_screen.dart';
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

  void _showReasonBottomSheet(
      BuildContext context, Function(String) onReasonSubmitted) {
    final TextEditingController reasonController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Reason for being late',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Enter reason',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final reason = reasonController.text.trim();
                    if (reason.isNotEmpty) {
                      Navigator.pop(context);
                      onReasonSubmitted(reason);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reason cannot be empty')),
                      );
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleCheckInOut(BuildContext context) {
    // NOTE: Show the bottom sheet to get the reason
    _showReasonBottomSheet(context, (reason) {
      // Navigate to the QR scan screen first
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckInOutQRScreen(reason: reason),
        ),
      ).then((qrCode) {
        // After the QR code is scanned, check its validity
        if (qrCode != null) {
          // Proceed to call checkInOut only after scanning
          final provider =
              Provider.of<CheckInOutProvider>(context, listen: false);
          provider.checkInOut(qrCode, reason: reason);
        } else {
          const CustomSnackbar(
            message: 'Invalid QR code format.',
            backgroundColor: hbdColor,
            icon: Icons.warning,
          );
        }
      });
    });
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
              buttonColor = const Color(0xFF4CD964);
              buttonText = 'Check In';
              onTap = () => _handleCheckInOut(context);
              break;
            case 'checkOut':
              buttonColor = Colors.orange;
              buttonText = 'Check Out';
              onTap = () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CheckInOutQRScreen(reason: ''),
                  ),
                );
              };
              break;
            case 'disabled':
              buttonColor = Colors.grey;
              buttonText = 'Disabled';
              onTap = null;
              break;
            default:
              buttonColor = Colors.blue;
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
            ],
          );
        }),
      ),
    );
  }
}
