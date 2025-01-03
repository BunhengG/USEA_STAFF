import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usea_staff_test/constant/constant.dart';
import 'package:usea_staff_test/provider/mycard_provider.dart';

import '../../Components/custom_appbar_widget.dart';

String simpleText =
    '1. Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.';

class CardScreen extends StatefulWidget {
  const CardScreen({super.key});

  @override
  _CardScreenState createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch Card data when the screen loads
    Provider.of<CardProvider>(context, listen: false).fetchCards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: CustomAppBar(
        title: 'My Card',
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
            child:
                Consumer<CardProvider>(builder: (context, cardProvider, child) {
              // Show loading indicator
              if (cardProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // Show error message if any
              if (cardProvider.errorMessage != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      cardProvider.errorMessage!,
                      style: getSubTitle().copyWith(color: uAtvColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              // Show no records found if the list is empty
              if (cardProvider.cards.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No Card records found.',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              // Display the Card card at the top
              return Column(
                children: [
                  // Display the list of Cards
                  Card(
                    color: secondaryColor,
                    margin: const EdgeInsets.all(mdPadding),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(roundedCornerMD),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cardProvider.cards.length,
                      itemBuilder: (context, index) {
                        final card = cardProvider.cards[index];
                        return Padding(
                          padding: const EdgeInsets.all(mdPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 32,
                                        backgroundColor: primaryColor,
                                        child: CachedNetworkImage(
                                          imageUrl: card.image,
                                          placeholder: (context, url) =>
                                              const CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                          fit: BoxFit.cover,
                                          scale: 9,
                                        ),
                                      ),
                                      const SizedBox(height: smPadding),
                                      Image.asset(
                                        'assets/img/dara.png',
                                        scale: 14,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: defaultMargin),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildTextDetails('Name : ', card.name),
                                      _buildTextDetails(
                                          'UserId : ', card.userId),
                                      _buildTextDetails(
                                          'Gender : ', card.gender),
                                      _buildTextDetails(
                                        'DOB : ',
                                        card.dob!
                                            .toLocal()
                                            .toString()
                                            .split(' ')[0],
                                      ),
                                      _buildTextDetails(
                                          'Position : ', card.position),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                    ),
                  ),
                  Container(
                    color: secondaryColor,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.center,
                            child: Opacity(
                              opacity: 0.2,
                              child: Image.asset(
                                'assets/img/usealogo.png',
                                scale: 3,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(mdPadding),
                          child: Column(
                            children: [
                              Text('Notice', style: getTitle()),
                              const SizedBox(height: smPadding),
                              Text(simpleText, style: getBody()),
                              const SizedBox(height: smPadding),
                              Text(simpleText, style: getBody()),
                              const SizedBox(height: smPadding),
                              Text(simpleText, style: getBody()),
                            ],
                          ),
                        ),
                      ],
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

  _buildTextDetails(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          Text(
            title,
            style: getSubTitle().copyWith(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: getSubTitle(),
          ),
        ],
      ),
    );
  }
}
