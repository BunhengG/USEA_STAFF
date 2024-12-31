import 'package:flutter/material.dart';
import 'package:get/get.dart';

//NOTE: COLOR
const primaryColor = Color(0xFF0063E4);
const secondaryColor = Color(0xFFFFFFFF);
const titlePrimaryColor = Color(0xFF0063E4);
const titleWhiteColor = Color(0xFFF5F5F5);
const titleColor = Color(0xFF313131);
const textColor = Color(0xFF575057);
const placeholderColor = Color(0xFFC5C5C7);

const backgroundColor = Color(0xFFECECEC);
const backgroundShape = Color(0xFFE5E5E5);
const hbdColor = Color(0xFF720000);
const anvColor = Color(0xFF004297);

//NOTE: ROUNDED CORNER
const roundedCornerXL = 26.0;
const roundedCornerLG = 20.0;
const roundedCornerMD = 16.0;
const roundedCornerSM = 12.0;

//NOTE: SHADOW
const shadow = BoxShadow(
  color: Color(0x409AAEC8),
  blurRadius: 4.0,
  offset: Offset(0, 2),
);

//NOTE: SIZE
const titleSize = 20.0;
const subtitleSize = 14.5;
const bodySize = 12.5;
const captionSize = 8.0;

//NOTE: WEIGHT
const titleWeight = FontWeight.bold;
const subtitleWeight = FontWeight.w600;
const bodyWeight = FontWeight.normal;
const captionWeight = FontWeight.normal;

//NOTE: FONT FAMILY
const ft_Eng = 'font_Poppins';
const ft_Kh_Title = 'Mool1';
const ft_Kh = 'Battambang';

//NOTE: MARGIN & PADDING
const defaultPadding = 16.0;
const mdPadding = 12.0;
const smPadding = 8.0;
const xsPadding = 4.0;

const defaultMargin = 16.0;
const mdMargin = 12.0;
const smMargin = 8.0;
const xsMargin = 4.0;

//NOTE: TEXT STYLE FUNCTION
TextStyle getTitle() {
  var locale = Get.locale?.languageCode;
  if (locale == 'km') {
    return const TextStyle(
      fontFamily: ft_Kh_Title,
      fontWeight: FontWeight.bold,
      fontSize: titleSize,
      color: titlePrimaryColor,
    );
  } else {
    return const TextStyle(
      fontFamily: ft_Eng,
      fontWeight: FontWeight.bold,
      fontSize: titleSize,
      color: titlePrimaryColor,
    );
  }
}

TextStyle getSubTitle() {
  var locale = Get.locale?.languageCode;
  if (locale == 'km') {
    return const TextStyle(
      fontFamily: ft_Kh,
      fontWeight: subtitleWeight,
      fontSize: subtitleSize,
      color: titleColor,
    );
  } else {
    return const TextStyle(
      fontFamily: ft_Eng,
      fontWeight: subtitleWeight,
      fontSize: subtitleSize,
      color: titleColor,
    );
  }
}

TextStyle getWhiteSubTitle() {
  var locale = Get.locale?.languageCode;
  if (locale == 'km') {
    return const TextStyle(
      fontFamily: ft_Kh,
      fontWeight: subtitleWeight,
      fontSize: subtitleSize,
      color: titleWhiteColor,
    );
  } else {
    return const TextStyle(
      fontFamily: ft_Eng,
      fontWeight: subtitleWeight,
      fontSize: subtitleSize,
      color: titleWhiteColor,
    );
  }
}

TextStyle getBody() {
  var locale = Get.locale?.languageCode;
  if (locale == 'km') {
    return const TextStyle(
      fontFamily: ft_Kh,
      fontWeight: bodyWeight,
      fontSize: bodySize,
      color: textColor,
    );
  } else {
    return const TextStyle(
      fontFamily: ft_Eng,
      fontWeight: bodyWeight,
      fontSize: bodySize,
      color: textColor,
    );
  }
}

TextStyle getWhiteBody() {
  var locale = Get.locale?.languageCode;
  if (locale == 'km') {
    return const TextStyle(
      fontFamily: ft_Kh,
      fontWeight: bodyWeight,
      fontSize: bodySize,
      color: titleWhiteColor,
    );
  } else {
    return const TextStyle(
      fontFamily: ft_Eng,
      fontWeight: bodyWeight,
      fontSize: bodySize,
      color: titleWhiteColor,
    );
  }
}

TextStyle getCaption() {
  var locale = Get.locale?.languageCode;
  if (locale == 'km') {
    return const TextStyle(
      fontFamily: ft_Kh,
      fontWeight: bodyWeight,
      fontSize: captionSize,
      color: textColor,
    );
  } else {
    return const TextStyle(
      fontFamily: ft_Eng,
      fontWeight: bodyWeight,
      fontSize: captionSize,
      color: textColor,
    );
  }
}

class CustomPageRoute extends PageRouteBuilder {
  final Widget child;

  CustomPageRoute({required this.child})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}
