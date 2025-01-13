import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constant/constant.dart';
import '../../../provider/mycard_provider.dart';

class WorkingPeriodSection extends StatefulWidget {
  const WorkingPeriodSection({super.key});

  @override
  State<WorkingPeriodSection> createState() => _WorkingPeriodSectionState();
}

class _WorkingPeriodSectionState extends State<WorkingPeriodSection> {
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
        builder: (context, workPeriodProvider, child) {
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

          return Container(
            decoration: BoxDecoration(
              color: backgroundShape,
              borderRadius: BorderRadius.circular(roundedCornerMD),
            ),
            padding: const EdgeInsets.all(smPadding - 2),
            child: Container(
              padding: const EdgeInsets.all(mdPadding),
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.circular(roundedCornerSM + 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Working period'.toUpperCase(), style: getSubTitle()),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: workPeriodProvider.cards.length,
                    itemBuilder: (context, index) {
                      final period = workPeriodProvider.cards[index];
                      return Padding(
                        padding: const EdgeInsets.all(mdPadding),
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
                        const SizedBox(height: 10),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              contentTitle,
              style: getBody(),
            ),
          ),
          Text(
            ' : ',
            style: getBody(),
          ),
          Expanded(
            flex: 3,
            child: Text(
              contentValue,
              style: getBody(),
            ),
          ),
        ],
      ),
    );
  }
}
