import 'package:flutter/material.dart';

extension OurText on TextStyle {
  TextStyle s(double h) {
    return copyWith(fontSize: h);
  }

  TextStyle c(Color color) {
    return copyWith(color: color);
  }

  TextStyle h(double height) {
    return copyWith(height: height);
  }

  TextStyle f(String fontFamily) {
    return copyWith(fontFamily: fontFamily);
  }

  TextStyle w(int weight) {
    switch (weight) {
      case 100:
      case 1:
        return copyWith(fontWeight: FontWeight.w100);
      case 200:
      case 2:
        return copyWith(fontWeight: FontWeight.w200);
      case 300:
      case 3:
        return copyWith(fontWeight: FontWeight.w300);
      case 400:
      case 4:
        return copyWith(fontWeight: FontWeight.w400);
      case 500:
      case 5:
        return copyWith(fontWeight: FontWeight.w500);
      case 600:
      case 6:
        return copyWith(fontWeight: FontWeight.w600);
      case 700:
      case 7:
        return copyWith(fontWeight: FontWeight.w700);
      case 800:
      case 8:
        return copyWith(fontWeight: FontWeight.w800);
      case 900:
      case 9:
        return copyWith(fontWeight: FontWeight.w900);
    }
    return copyWith(fontWeight: FontWeight.w500);
  }
}

TextStyle defaultTextStyle(BuildContext context, StyleText styleText) {
  switch (styleText) {
    case StyleText.blwd1:
      return Theme.of(context).textTheme.displayLarge!;
    case StyleText.blwd2:
      return Theme.of(context).textTheme.displayMedium!;
    case StyleText.blwd3:
      return Theme.of(context).textTheme.displaySmall!;
    case StyleText.wlbd1:
      return Theme.of(context).textTheme.headlineLarge!;
    case StyleText.wlbd2:
      return Theme.of(context).textTheme.headlineMedium!;
    case StyleText.wlbd3:
      return Theme.of(context).textTheme.headlineSmall!;
    case StyleText.wb1:
      return Theme.of(context).textTheme.titleLarge!;
    case StyleText.wb2:
      return Theme.of(context).textTheme.titleMedium!;
    case StyleText.wb3:
      return Theme.of(context).textTheme.titleSmall!;
    case StyleText.pb1:
      return Theme.of(context).textTheme.labelLarge!;
    case StyleText.pb2:
      return Theme.of(context).textTheme.labelMedium!;
    case StyleText.pb3:
      return Theme.of(context).textTheme.labelSmall!;
    case StyleText.bb1:
      return Theme.of(context).textTheme.bodyLarge!;
    case StyleText.bb2:
      return Theme.of(context).textTheme.bodyMedium!;
    case StyleText.bb3:
      return Theme.of(context).textTheme.bodySmall!;
  }
}

enum StyleText { blwd1, blwd2, blwd3, wlbd1, wlbd2, wlbd3, wb3, wb2, wb1, bb1, bb2, bb3, pb1, pb2, pb3 }
