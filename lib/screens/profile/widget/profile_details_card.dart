import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constant/constant.dart';
import '../../../provider/profileDetails_provider.dart';

class WorkingPeriodSection extends StatefulWidget {
  const WorkingPeriodSection({super.key});

  @override
  State<WorkingPeriodSection> createState() => _WorkingPeriodSectionState();
}

class _WorkingPeriodSectionState extends State<WorkingPeriodSection>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500), // Adjust duration as needed
      vsync: this, // TickerProviderStateMixin provides vsync
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // Fetch Card data when the screen loads
    Provider.of<ProfileProvider>(context, listen: false).fetchCards();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Consumer<ProfileProvider>(
        builder: (context, workPeriodProvider, child) {
          // Start fade-in animation once the data is loaded
          if (!workPeriodProvider.isLoading) {
            _controller.forward();
          }

          // Show loading indicator
          if (workPeriodProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(backgroundColor),
              ),
            );
          }
          // Show error message if any
          if (workPeriodProvider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  workPeriodProvider.errorMessage!,
                  style: getSubTitle().copyWith(color: uAtvColor),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          // Show no records found if the list is empty
          if (workPeriodProvider.cards.isEmpty) {
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

          return FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              padding: const EdgeInsets.all(mdPadding),
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.circular(roundedCornerSM + 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Working period'.toUpperCase(), style: getTitle()),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: workPeriodProvider.cards.length,
                    itemBuilder: (context, index) {
                      final period = workPeriodProvider.cards[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 2,
                          vertical: mdPadding + 4,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBodyPeriod('Start Date', period.joinAt),
                            _buildBodyPeriod('End Date', period.endProbation),
                            _buildBodyPeriod(
                                'Anniversary', period.workAnniversary),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(height: mdPadding),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  _buildBodyPeriod(String contentTitle, String contentValue) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            contentTitle,
            style: getSubTitle().copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          ' : ',
          style: getSubTitle().copyWith(fontWeight: FontWeight.w500),
        ),
        Expanded(
          flex: 3,
          child: Text(
            contentValue,
            style: getSubTitle().copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
