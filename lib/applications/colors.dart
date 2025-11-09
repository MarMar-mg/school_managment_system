import 'package:flutter/material.dart';

class AppColor {

  static const Color backgroundColor = Color(0xFFF8F9FF);
  static const Color teacherBaseColor = Color(0xCC1E90FF);
  static const Color teacherSecondColor = Color(0xCC00C2CB);
  static const Color adminBaseColor =  Color(0xCCFF6B9D);
  static const Color adminSecondColor = Color(0xCCFF8FA3);
  static const Color studentBaseColor = Color(0xCC6A5AE0);
  static const Color studentSecondColor = Color(0xCC8B78FF);



  static const Color baliHai = Color(0xff8D98AF);

  static const Color blue = Color(0xff38B7FE);
  static const Color purple = Color(0xFF6A5AE0);
  static const Color lightPurple = Color(0xFF8B78FF);
  static const Color indigo = Color(0xff0085FE);
  static const Color shimmerColor = Color(0xffF0F0F0);

  static const Color gray = Color(0xff374151);
  static const Color primary = Color(0xFF6C5CE7);
  static const Color lightGray = Color(0xff6B7280);
  static const Color textGray = Color(0xff4B5563);
  static const Color borderGray = Color(0xffE5E7EB);
  static const Color darkOrange = Color(0xffCC7A00);
  static const Color textBlack = Color(0xff111827);
  static const Color portalGray = Color(0xff6B7280);
  static const Color shadowGray = Color(0xffF2F2F2);
  static const Color drawerRed = Color(0xffEF4444);
  static const Color lightYellow = Color(0xFFFFF8E1);
  static const Color darkText = Color(0xFF1A1A2E);
  static const Color lightBackColor = Color(0x4da1c4d1);


  static const Color mehrAlborzBlue = Color(0xff294D82);
  static const Color asstSystemBlue2 = Color(0xff749EAC);
  static const Color asstSystemBlue = Color(0xffB9D5D5);
  static const Color teachSystemGreen2 = Color(0xa397ad82);
  static const Color teachSystemBackground = Color(0x28b7d29c);
  static const Color teachSystemBackground2 = Color(0x49b7d29c);
  static const Color asstSystemBackground = Color(0x1fd9d9d9);
  static const Color asstSystemBackground2 = Color(0x35d9d9d9);
  static const Color asstSystemBackground3 = Color(0x62d9d9d9);
  static const Color stuSystemBlue2 = Color(0xff3C7DA3);
  static const Color stuSystemBackground = Color(0x1a9cbbd2);
  static const Color stuSystemBackground2 = Color(0x3f9cbbd2);
  static const Color mehrAlborzBlue2 = Color(0x80294d82);
  static const Color mehrAlborzOrange = Color(0xffFF9800);

  static Color grey(bool isThemeLight, int volume, {int extraVolumeForDark = 0}) {
    if (volume <= 10) volume = volume * 100;
    if (isThemeLight) {
      switch (volume) {
        case 0:
          return const Color(0xffffffff);
        case 100:
          return const Color(0xffF3F4F6);
        case 200:
          return const Color(0xffE5E7EB);
        case 300:
          return const Color(0xffD1D5DB);
        case 400:
          return const Color(0xff9CA3AF);
        case 500:
          return const Color(0xffD4DBE1);
        case 600:
          return const Color(0xffB0B7C3);
        case 700:
          return const Color(0xff374151);
        case 800:
          return const Color(0xff343D5C);
        case 900:
          return const Color(0xff081131);
        case 1000:
          return const Color(0xff000000);
      }
      return Color.lerp(grey(isThemeLight, volume ~/ 100), grey(isThemeLight, (volume ~/ 100) + 1), (volume % 100) / 100)!;
    } else {
      return grey(true, 1000 - (volume + extraVolumeForDark));
    }
  }

  static Color blackBase(bool isThemeLight, int volume) {
    if (isThemeLight) {
      switch (volume) {
        case 2:
        case 200:
          return const Color(0xffF4F5F6);
        case 3:
        case 300:
          return const Color(0xffE6E8EC);
        case 4:
        case 400:
          return const Color(0xffB1B5C3);
        case 5:
        case 500:
          return const Color(0xff777E90);
        case 600:
          return Color.lerp(blackBase(isThemeLight, 500), blackBase(isThemeLight, 700), 0.5)!;
        case 7:
        case 700:
          return const Color(0xff23262F);
        case 8:
        case 800:
          return const Color(0xff141416);
      }
    } else {
      switch (volume) {
        case 2:
        case 200:
          return const Color(0xffE5E5E5);
        case 3:
        case 300:
          return const Color(0xffE3E3E3);
        case 4:
        case 400:
          return const Color(0xffD7D7D7);
        case 5:
        case 500:
          return const Color(0xffBFBFBF);
        case 7:
        case 700:
          return const Color(0xffF4F5F6);
        case 8:
        case 800:
          return const Color(0xffE6E8EC);
      }
    }
    return Colors.white;
  }

  static Color colorLight(bool isThemeLight, int volume) {
    if (isThemeLight) {
      switch (volume) {
        case 1:
          return const Color(0xff212B36);
        case 2:
          return const Color(0xff637381);
      }
    } else {
      switch (volume) {
        case 1:
          return const Color(0xffFFFFFF);
        case 2:
          return const Color(0xffE6E8EC);
      }
    }
    return Colors.white;
  }

  static secondary(bool isThemeLight) {
    if (isThemeLight) {
      return const Color(0xff979797);
    } else {
      return const Color(0xff3f3f3f);
    }
  }

  static shadow(bool isThemeLight) {
    if (isThemeLight) {
      return Colors.grey;
    } else {
      return Colors.black;
    }
  }
}
