import 'package:flutter/material.dart';
import 'package:usea_staff_test/Components/custom_appbar_widget.dart';
import 'package:usea_staff_test/constant/constant.dart';
import 'package:provider/provider.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(title: 'Check Record Details'),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child:
            Consumer<CheckInOutProvider>(builder: (context, provider, child) {
          // print('Status: >> ${provider.shiftStatus}');

          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Text(
                provider.errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
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
              onTap = () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CheckInOutQRScreen(),
                  ),
                );
              };
              break;
            case 'checkOut':
              buttonColor = Colors.orange;
              buttonText = 'Check Out';
              onTap = () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CheckInOutQRScreen(),
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
