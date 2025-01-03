import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher
import 'package:usea_staff_test/constant/constant.dart';
import '../../Components/custom_appbar_widget.dart';
import '../../provider/memeber_provider.dart';

class MemberScreen extends StatefulWidget {
  const MemberScreen({super.key});

  @override
  _MemberScreenState createState() => _MemberScreenState();
}

class _MemberScreenState extends State<MemberScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final String _smart = 'assets/icon/smart.png';
  final String _cellcard = 'assets/icon/cellcard.png';
  final String _metfone = 'assets/icon/metfone.png';

  @override
  void initState() {
    super.initState();
    Provider.of<MemberProvider>(context, listen: false).fetchMembers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Method to trigger a phone call
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch phone dialer')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(title: 'Members'),
      body: Column(
        children: [
          //* Search Bar
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: TextField(
              cursorColor: primaryColor,
              autocorrect: true,
              cursorRadius: const Radius.circular(roundedCornerMD),
              style: getBody(),
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by Name...',
                hintStyle: getBody().copyWith(color: placeholderColor),
                prefixIcon: Image.asset('assets/icon/search.png', scale: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(roundedCornerSM),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: secondaryColor,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();
                });
              },
            ),
          ),

          //* Member List
          Expanded(
            child: Consumer<MemberProvider>(
              builder: (context, memberProvider, child) {
                if (memberProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (memberProvider.errorMessage != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        memberProvider.errorMessage!,
                        style: getSubTitle().copyWith(color: uAtvColor),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final filteredMembers = memberProvider.members
                    .where((member) => member.name
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                    .toList();

                if (filteredMembers.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(defaultPadding),
                      child: Text(
                        'No matching members found.',
                        style: getSubTitle(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: filteredMembers.length,
                  itemBuilder: (context, index) {
                    final member = filteredMembers[index];
                    return GestureDetector(
                      onTap: () {
                        _makePhoneCall('+855${member.phoneNumber}');
                      },
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: mdPadding),
                        child: Card(
                          color: secondaryColor,
                          elevation: 1,
                          shape: RoundedRectangleBorder(
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
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 4.0),
                                      child: CircleAvatar(
                                        radius: 23.5,
                                        backgroundColor: primaryColor,
                                        child: Image.asset(
                                          'assets/img/avator.png',
                                          scale: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: mdMargin),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(member.name, style: getSubTitle()),
                                        const SizedBox(height: smMargin),
                                        Text(member.position, style: getBody()),
                                        Text(member.department,
                                            style: getBody()),
                                        Text(member.company, style: getBody()),
                                        const SizedBox(height: mdMargin),
                                        Row(
                                          children: [
                                            Image.asset(
                                              member.phoneNumberService ==
                                                      "smart"
                                                  ? _smart
                                                  : member.phoneNumberService ==
                                                          "metfone"
                                                      ? _metfone
                                                      : _cellcard,
                                              scale: 12,
                                            ),
                                            const SizedBox(width: smPadding),
                                            Text('+855 ${member.phoneNumber}',
                                                style: getBody()),
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
                      ),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: mdMargin),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
