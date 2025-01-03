import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constant/constant.dart';
import '../screens/profile/profile.dart';
import '../provider/mycard_provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  void initState() {
    super.initState();
    // Fetch Card data when the screen loads
    Provider.of<CardProvider>(context, listen: false).fetchCards();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Consumer<CardProvider>(
        builder: (context, profileProvider, child) {
          // Show loading indicator
          if (profileProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(backgroundColor),
              ),
            );
          }
          // Show error message if any
          if (profileProvider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  profileProvider.errorMessage!,
                  style: getSubTitle().copyWith(color: uAtvColor),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          // Show no records found if the list is empty
          if (profileProvider.cards.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No Card records found.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                CustomPageRoute(child: const ProfileScreen()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: profileProvider.cards.length,
                itemBuilder: (context, index) {
                  final profile = profileProvider.cards[index];
                  return Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: primaryColor,
                          child: CachedNetworkImage(
                            imageUrl: profile.image,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                            fit: BoxFit.cover,
                            scale: 12,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${profile.name}',
                            style: getSubTitle(),
                          ),
                          Text(
                            profile.position,
                            style: getBody(),
                          ),
                        ],
                      ),
                    ],
                  );
                },
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(height: 10),
              ),
            ),
          );
        },
      ),
    );
  }
}
