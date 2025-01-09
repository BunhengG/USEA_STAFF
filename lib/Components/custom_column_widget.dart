import 'dart:ui';

import 'package:flutter/material.dart';

import '../constant/constant.dart';

void showColumnSelectDialog(
    BuildContext context, Function(int) onColumnSelected) {
  showDialog<int>(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(roundedCornerLG),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(roundedCornerLG),
                    ),
                    color: backgroundColor,
                  ),
                ),
              ),
            ),
            // Dialog content
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: mdPadding),
                    child: Text(
                      'Custom GridItems',
                      style: getTitle(),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: smPadding),
                    child: Divider(thickness: 0.6),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context, 2);
                        },
                        child: Column(
                          children: [
                            Text(
                              'Two',
                              style: getSubTitle(),
                            ),
                            const SizedBox(height: smPadding),
                            Container(
                              padding: const EdgeInsets.all(mdPadding),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(roundedCornerSM),
                                color: secondaryColor,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsetsDirectional.all(
                                        mdPadding),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          roundedCornerSM - 6),
                                      color: primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: smMargin),
                                  Container(
                                    padding: const EdgeInsetsDirectional.all(
                                        mdPadding),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          roundedCornerSM - 6),
                                      color: primaryColor,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: defaultPadding),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context, 3);
                        },
                        child: Column(
                          children: [
                            Text(
                              'Three',
                              style: getSubTitle(),
                            ),
                            const SizedBox(height: smPadding),
                            Container(
                              padding: const EdgeInsets.all(mdPadding),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(roundedCornerSM),
                                color: secondaryColor,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsetsDirectional.all(
                                        mdPadding),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          roundedCornerSM - 6),
                                      color: primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: smMargin),
                                  Container(
                                    padding: const EdgeInsetsDirectional.all(
                                        mdPadding),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          roundedCornerSM - 6),
                                      color: primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: smMargin),
                                  Container(
                                    padding: const EdgeInsetsDirectional.all(
                                        mdPadding),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          roundedCornerSM - 6),
                                      color: primaryColor,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  ).then((value) {
    if (value != null) {
      onColumnSelected(value);
    }
  });
}
