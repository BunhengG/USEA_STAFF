import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../constant/constant.dart';

class ReasonBottomSheet extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<String> reasons;
  final Function(String) onReasonSubmitted;

  const ReasonBottomSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.reasons,
    required this.onReasonSubmitted,
  });

  @override
  State<ReasonBottomSheet> createState() => _ReasonBottomSheetState();
}

class _ReasonBottomSheetState extends State<ReasonBottomSheet> {
  final TextEditingController reasonController = TextEditingController();
  bool _isSubmitEnabled = false;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();

    // Listen the text field
    reasonController.addListener(() {
      setState(() {
        _isSubmitEnabled = reasonController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // title
            _buildTitle(),
            // field
            _buildTextField('Tell reason...'),
            // reasons
            _buildReasons(),
            // expend
            if (widget.reasons.length > 2)
              _buildSeeMoreLessButton('See Less', 'See More'),
            // Submit
            _buildButtonSubmit('Submit'),
            const SizedBox(height: defaultPadding * 1.2),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: smPadding - 2),
      child: Column(
        children: [
          Text(
            widget.title,
            style: getSubTitle().copyWith(color: primaryColor),
          ),
          Text(widget.subtitle, style: getBody()),
        ],
      ),
    );
  }

  Widget _buildTextField(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: defaultPadding),
      child: TextField(
        controller: reasonController,
        decoration: InputDecoration(
          hintText: text,
          hintStyle: getBody(),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.all(mdPadding),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(roundedCornerSM)),
            borderSide: BorderSide(color: primaryColor, width: 1.5),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(roundedCornerSM)),
            borderSide: BorderSide(color: primaryColor, width: 2.0),
          ),
        ),
        maxLines: 3,
        keyboardType: TextInputType.multiline,
        textAlignVertical: TextAlignVertical.top,
      ),
    );
  }

  // Widget _buildReasons() {
  //   return AnimatedCrossFade(
  //     firstChild: Wrap(
  //       spacing: 8.0,
  //       runSpacing: 8.0,
  //       children: widget.reasons.take(3).map((reason) {
  //         return _buildReasonButton(reason);
  //       }).toList(),
  //     ),
  //     secondChild: Wrap(
  //       spacing: 8.0,
  //       runSpacing: 8.0,
  //       children: widget.reasons.map((reason) {
  //         return _buildReasonButton(reason);
  //       }).toList(),
  //     ),
  //     crossFadeState:
  //         _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
  //     duration: const Duration(milliseconds: 300),
  //   );
  // }

  Widget _buildReasons() {
    return AnimatedCrossFade(
      firstChild: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 2.5,
        ),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.reasons.take(3).length,
        itemBuilder: (context, index) {
          return _buildReasonButton(widget.reasons[index]);
        },
      ),
      secondChild: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 2.5,
        ),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.reasons.length,
        itemBuilder: (context, index) {
          return _buildReasonButton(widget.reasons[index]);
        },
      ),
      crossFadeState:
          _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 300),
    );
  }

  Widget _buildSeeMoreLessButton(String less, String more) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: smPadding),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          style: ButtonStyle(
            overlayColor: WidgetStateProperty.all(Colors.transparent),
          ),
          onPressed: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isExpanded ? less : more,
                style: getSubTitle().copyWith(
                  color: primaryColor,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 4),
              FaIcon(
                _isExpanded
                    ? FontAwesomeIcons.angleUp
                    : FontAwesomeIcons.angleDown,
                color: primaryColor,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtonSubmit(String title) {
    return GestureDetector(
      onTap: _isSubmitEnabled
          ? () {
              final reason = reasonController.text.trim();
              Navigator.pop(context);
              widget.onReasonSubmitted(reason);
            }
          : null,
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(mdPadding),
        decoration: BoxDecoration(
          color:
              _isSubmitEnabled ? primaryColor : primaryColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(roundedCornerSM - 4),
        ),
        child: Text(
          textAlign: TextAlign.center,
          title,
          style: getWhiteSubTitle(),
        ),
      ),
    );
  }

  Widget _buildReasonButton(String reason) {
    return GestureDetector(
      onTap: () {
        reasonController.text = reason;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: smPadding,
          horizontal: smPadding,
        ),
        decoration: BoxDecoration(
          color: uAtvShape,
          borderRadius: BorderRadius.circular(roundedCornerSM - 4),
        ),
        child: Center(
          child: Text(
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            reason,
            style: getSubTitle().copyWith(fontSize: 13),
          ),
        ),
      ),
    );
  }
}
