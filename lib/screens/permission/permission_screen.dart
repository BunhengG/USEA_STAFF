import 'package:flutter/material.dart';
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
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: permissionProvider.permissions.length,
                    itemBuilder: (context, index) {
                      final permission = permissionProvider.permissions[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Card(
                          color: secondaryColor,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16.0),
                            leading: const Icon(
                              Icons.access_alarm,
                              color: Colors.blueAccent,
                            ),
                            title: Text(
                              '${permission.username} - ${permission.reason}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${permission.date.toLocal().toString().split(' ')[0]} - PMD ${permission.permissionDay}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                  ),
                  const SizedBox(height: defaultPadding),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
