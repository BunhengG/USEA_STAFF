import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:usea_staff_test/constant/constant.dart';
import 'package:usea_staff_test/provider/permission_provider.dart';

import '../../Components/custom_appbar_widget.dart';
import 'widget/permission_card_widget.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  _PermissionScreenState createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch permission data when the screen loads
    Provider.of<PermissionProvider>(context, listen: false).fetchPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(
        title: 'Permission',
        backgroundColor: primaryColor,
        subtitle: getWhiteSubTitle(),
        iconPath: 'assets/icon/custom_icon.png',
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.2,
            decoration: const BoxDecoration(
              color: primaryColor,
            ),
          ),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Consumer<PermissionProvider>(
                builder: (context, permissionProvider, child) {
              // Show loading indicator
              if (permissionProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // Show error message if any
              if (permissionProvider.errorMessage != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      permissionProvider.errorMessage!,
                      style: getSubTitle().copyWith(color: uAtvColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              // Show no records found if the list is empty
              if (permissionProvider.permissions.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No permission records found.',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              // Display the permission card at the top
              return Column(
                children: [
                  // Use the imported widget to display the card
                  PermissionCardWidget(
                    permissions: permissionProvider.permissions,
                  ),

                  // Display the list of permissions
                  Container(
                    color: backgroundColor,
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: permissionProvider.permissions.length,
                      itemBuilder: (context, index) {
                        final permission =
                            permissionProvider.permissions[index];
                        return Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: mdPadding),
                          child: Container(
                            decoration: BoxDecoration(
                              color: secondaryColor,
                              borderRadius:
                                  BorderRadius.circular(roundedCornerSM),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(mdPadding),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'PD ${permission.permissionDay}',
                                        style: getTitle(),
                                      ),

                                      //* Vertical Divider
                                      Container(
                                        height: 50,
                                        width: 3,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(
                                              roundedCornerSM),
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                        ),
                                      ),

                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Permission Details',
                                            style: getSubTitle(),
                                          ),
                                          const SizedBox(height: smPadding),
                                          Row(
                                            children: [
                                              const FaIcon(
                                                FontAwesomeIcons.thumbtack,
                                                size: 16,
                                                color: uAtvShape,
                                              ),
                                              const SizedBox(width: smPadding),
                                              Text(
                                                permission.reason,
                                                style: getBody(),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: smPadding),
                                          Row(
                                            children: [
                                              const FaIcon(
                                                FontAwesomeIcons.calendar,
                                                size: 16,
                                                color: uAtvShape,
                                              ),
                                              const SizedBox(width: smPadding),
                                              Text(
                                                permission.date
                                                    .toLocal()
                                                    .toString()
                                                    .split(' ')[0],
                                                style: getBody(),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
