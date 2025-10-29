import 'dart:io';
import 'dart:math';

import 'package:school_managment_system/applications/colors.dart';
import 'package:school_managment_system/commons/date_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:url_launcher/url_launcher.dart';

bool isSuccessfulHttp(Response response) {
  return isSuccessfulStatusCode(response.statusCode);
}

String extractNumberInLargeText(String message, int numberOFDigit) {
  final regexp = RegExp(List.generate(numberOFDigit, (index) => '[0-9]').join(''));
  final match = regexp.firstMatch(message);
  final matchedText = match?.group(0);
  return matchedText ?? '';
}

void unFocus(BuildContext context) {
  final currentFocus = FocusScope.of(context);
  currentFocus.unfocus();
}

Color calculateBestColorText(Color backgroundColor) {
  return backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
}

void callToPhoneNumber(BuildContext context, String phoneNumber) async {
  await launchUrl(Uri(scheme: 'tel', path: phoneNumber));
}

void fixRtlFlutterBug(TextEditingController controller) {
  if (controller.selection == TextSelection.fromPosition(TextPosition(offset: controller.text.length - 1))) {
    controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
  } else if (controller.text.endsWith('لا') &&
      controller.selection == TextSelection.fromPosition(TextPosition(offset: controller.text.length - 2))) {
    controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
  }
}

List<BoxShadow> simpleShadow({Color? color}) {
  return [
    BoxShadow(
      color: (color ?? AppColor.shadow(true)).withOpacity(0.3),
      spreadRadius: 1,
      blurRadius: 7,
      offset: const Offset(1, 1),
    )
  ];
}

bool isWebPlatform() => kIsWeb;

bool isSuccessfulStatusCode(int statusCode) {
  return statusCode >= 200 && statusCode <= 300;
}

String replaceFarsiNumber(String farsiNumber) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const farsi = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  for (int i = 0; i < english.length; i++) {
    farsiNumber = farsiNumber.replaceAll(farsi[i], english[i]);
  }
  return farsiNumber;
}

String replaceEnglishNumber(String englishNumber) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const farsi = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  for (int i = 0; i < english.length; i++) {
    englishNumber = englishNumber.replaceAll(english[i], farsi[i]);
  }
  return englishNumber;
}

String? getPhoneNumber(String phoneNumber) {
  String englishNumber = replaceFarsiNumber(phoneNumber.trim().replaceAll(' ', ''));
  if (englishNumber.length < 10) return null;
  if (englishNumber.length == 10) return englishNumber;
  if (englishNumber.length == 11 && englishNumber.startsWith('0')) return englishNumber.substring(1);
  if (englishNumber.length == 12 && englishNumber.startsWith('98')) return englishNumber.substring(2);
  if (englishNumber.length == 13 && englishNumber.startsWith('+98')) return englishNumber.substring(3);
  if (englishNumber.length == 14 && englishNumber.startsWith('+980')) return englishNumber.substring(4);
  if (englishNumber.length == 14 && englishNumber.startsWith('+9898')) return englishNumber.substring(5);
  if (englishNumber.length == 16 && englishNumber.startsWith('+98+98')) return englishNumber.substring(6);
  return null;
}

bool validatePhoneNumber(String? phoneNumber) {
  if (phoneNumber == null) {
    return false;
  }
  return getPhoneNumber(phoneNumber) != null && getPhoneNumber(phoneNumber)!.startsWith('9');
}

enum NumberLanguageType {
  persian('fa_ir'),
  english('en_us');

  final String code;

  const NumberLanguageType(this.code);
}

String niceShowMoneyValue(int input, {NumberLanguageType numberLanguageType = NumberLanguageType.persian}) {
  return NumberFormat.decimalPattern(numberLanguageType.code).format(input);
}

String extractIdFromUrl(String value) {
  String localValue = value;
  if (localValue.contains('/')) {
    localValue = localValue.substring(localValue.lastIndexOf('/') + 1);
  }
  if (localValue.contains('?')) {
    localValue = localValue.substring(0, localValue.indexOf('?'));
  }
  return localValue;
}

bool isFlutterWebRunOnAndroid() {
  return kIsWeb && defaultTargetPlatform == TargetPlatform.android;
}

bool isTextHtml(String text) {
  return text.startsWith("<");
}

bool isFlutterWebRunOnDesktop() {
  return kIsWeb && (defaultTargetPlatform != TargetPlatform.iOS && defaultTargetPlatform != TargetPlatform.android);
}

TargetPlatform getDefaultTargetPlatform() {
  return defaultTargetPlatform;
}

bool isRunInAndroid() {
  return defaultTargetPlatform == TargetPlatform.android || Platform.isAndroid;
}

bool isRunInIOS() {
  return defaultTargetPlatform == TargetPlatform.iOS || Platform.isIOS;
}

String convertNumberToPersianOrder(int number) {
  switch (number) {
    case 0:
      return "صفرم";
    case 1:
      return "اول";
    case 2:
      return "دوم";
    case 3:
      return "سوم";
    case 4:
      return "چهارم";
    case 5:
      return "پنجم";
    case 6:
      return "ششم";
    case 7:
      return "هفتم";
    case 8:
      return "هشتم";
    case 9:
      return "نهم";
    case 10:
      return "دهم";
    case 11:
      return "یازدهم";
    case 12:
      return "دوزادهم";
    case 13:
      return "سیزدهم";
    case 14:
      return "چهاردهم";
    case 15:
      return "پانزدهم";
    case 16:
      return "شانزدهم";
    case 17:
      return "هفدهم";
    case 18:
      return "هیجدهم";
    case 19:
      return "نوزدهم";
    case 20:
      return "بیستم";
  }
  return "صفرم";
}

String persianToLowerCase(String input) {
  String output = input.replaceAll("آ", "ا");
  return output;
}

String convertJsonItemToString(Map<String, dynamic> json, String key, {String defaultValue = ""}) {
  return convertDynamicToString(json[key]);
}

String convertDynamicToString(dynamic item, {String defaultValue = ""}) {
  try {
    return (item ?? defaultValue).toString().trim();
  } on Exception {
    return defaultValue;
  }
}

int convertDynamicToInt(dynamic item, {int defaultValue = 0}) {
  return int.parse(convertDynamicToString(item, defaultValue: defaultValue.toString()));
}

bool convertDynamicToBool(dynamic item, {bool defaultValue = false}) {
  final output = convertDynamicToString(item, defaultValue: defaultValue.toString());
  return output == "1" || output == "true";
}

bool isUrlValid(String url) {
  try {
    return Uri.tryParse(url)?.hasAbsolutePath ?? false;
  } on Exception {
    return false;
  }
}

String persianToUpperCase(String input) {
  String output = input.replaceAll("ا", "آ");
  return output;
}

String convertSecondToTimeFormat(int seconds) {
  var d = Duration(days: 0, hours: 0, minutes: 0, seconds: seconds, microseconds: 0);
  String fullTime = d.toString().split('.').first.padLeft(8, "0");
  if (d.inHours > 0) {
    return fullTime;
  } else {
    return fullTime.substring(3);
  }
}

String _dateSplitter = "/";

String convertDateTimeToFormat(DateTime dateTime) {
  final dateFormat = DateFormat('EEE MMM dd yyyy HH:mm:ss');
  var AlborzFormat =
      '${dateFormat.format(dateTime)} GMT${dateTime.timeZoneOffset > Duration.zero ? '+' : '-'}${dateTime.timeZoneOffset.toBriefString().replaceAll(':', '')} (${dateTime.timeZoneName})';
  return AlborzFormat;
}

DateTime convertFormatToDateTime(String format) {
  String standardFormat = format.split('(').first.replaceAll('GMT', '').trim();
  final plainDateTime = DateFormat("EEE MMM dd yyyy HH:mm:ss").parse(standardFormat);
  final timeZoneString = format.split('GMT')[1].substring(0, 5);
  final timeZoneOffset = Duration(hours: timeZoneString.substring(1, 3).toInt(), minutes: timeZoneString.substring(3, 5).toInt());
  final utcDateTime = plainDateTime.add(timeZoneString[0] == '+' ? -timeZoneOffset : timeZoneOffset);
  final localDateTime = DateFormat('yyyy-mm-dd hh:mm:ss.SSS').parse(utcDateTime.toString(), true).toLocal();
  return localDateTime;
}

String convertJalaliToString(Jalali input) {
  final inputFormatter = input.formatter;
  return "${inputFormatter.yyyy}$_dateSplitter${inputFormatter.mm}$_dateSplitter${inputFormatter.dd}";
}

Jalali convertStringToJalali(String input) {
  String splitter = input.contains("-") ? "-" : "/";
  return Jalali(int.parse(input.split(splitter)[0]), int.parse(input.split(splitter)[1]), int.parse(input.split(splitter)[2]));
}

String convertGregorianToString(Gregorian input) {
  final inputFormatter = input.formatter;
  return "${inputFormatter.yyyy}$_dateSplitter${inputFormatter.mm}$_dateSplitter${inputFormatter.dd}";
}

Gregorian convertStringToGregorian(String input) {
  String splitter = input.contains("-") ? "-" : "/";
  return Gregorian(int.parse(input.split(splitter)[0]), int.parse(input.split(splitter)[1]), int.parse(input.split(splitter)[2]));
}

Gregorian convertJalaliToGregorian(Jalali input) {
  return Gregorian.fromJalali(input);
}

Jalali convertGregorianToJalali(Gregorian input) {
  return Jalali.fromGregorian(input);
}

int _lastTimerCall = 0;

void timerAction({required Function startAction, required Function endAction, required int milliSecondWait, int? rightNow}) async {
  int localRightNow = rightNow ?? DateTime.now().millisecondsSinceEpoch;
  _lastTimerCall = localRightNow;
  startAction();
  await Future.delayed(Duration(milliseconds: milliSecondWait));
  if (localRightNow == _lastTimerCall) endAction();
}

dynamic jsonFiledParserDynamic(Map<String, dynamic> json, List<String> filedNames) {
  dynamic innerJson = json;
  for (int i = 0; i < filedNames.length; i++) {
    if (innerJson[filedNames[i]] == null) {
      return null;
    }
    innerJson = innerJson[filedNames[i]];
  }
  return innerJson;
}

String jsonFiledParserString(Map<String, dynamic> json, List<String> filedNames) {
  final result = jsonFiledParserDynamic(json, filedNames);
  return result == null ? "" : result.toString().trim();
}

int? jsonFiledParserInt(Map<String, dynamic> json, List<String> filedNames) {
  final result = jsonFiledParserString(json, filedNames);
  return result.isEmpty ? null : int.parse(result);
}

bool jsonFiledParserBool(Map<String, dynamic> json, List<String> filedNames) {
  final result = jsonFiledParserString(json, filedNames).toLowerCase();
  return result.isEmpty ? false : result == "1" || result == "true";
}

String getPersianOrderName(int number) {
  switch (number) {
    case 1:
      return "اول";
    case 2:
      return "دوم";
    case 3:
      return "سوم";
    case 4:
      return "چهارم";
    case 5:
      return "پنجم";
    case 6:
      return "ششم";
    case 7:
      return "هفتم";
    case 8:
      return "هشتم";
    case 9:
      return "نهم";
    case 10:
      return "دهم";
  }
  return "دیگر";
}

extension NewProperty on Duration {
  int days() {
    String output = toString();
    output = output.substring(0, output.indexOf('.'));
    List<String> times = output.split(':');
    return int.parse(times[0]) ~/ 24;
  }

  int hour() {
    String output = toString();
    output = output.substring(0, output.indexOf('.'));
    List<String> times = output.split(':');
    return int.parse(times[0]) % 24;
  }

  int minute() {
    String output = toString();
    output = output.substring(0, output.indexOf('.'));
    List<String> times = output.split(':');
    return int.parse(times[1]);
  }

  String toBriefString() {
    return '${hour().toString().padLeft(2, '0')}:${minute().toString().padLeft(2, '0')}';
  }

  int second() {
    String output = toString();
    output = output.substring(0, output.indexOf('.'));
    List<String> times = output.split(':');
    return int.parse(times[2]);
  }
}

extension ExtensionString on String {
  bool toBool() {
    return this == "true" || this == "1";
  }

  int toInt() {
    return int.parse(this);
  }

  int? toMaybeInt() {
    return int.tryParse(this);
  }

  String getFirstNSentence(int n) {
    final wordList = split(' ');
    return wordList.sublist(0, min(n, wordList.length)).join(' ');
  }
}

extension Show on DateTime {
  DateManager toDateManager() {
    return DateManager.fromDateTime(this);
  }

  bool inSameDay(DateTime dateTime) => printNiceJalali() == dateTime.printNiceJalali();

  DateTime startOfToday() {
    final dateManager = DateManager.fromDateTime(this);
    return DateManager.fromString(dateManager.briefStringGeorgianDate, hour: 0, minute: 0, second: 0).toDateTime;
  }

  DateTime endOfToday() {
    final dateManager = DateManager.fromDateTime(this);
    return DateManager.fromString(dateManager.briefStringGeorgianDate, hour: 23, minute: 59, second: 59).toDateTime;
  }

  String printNiceJalali() {
    return toDateManager().niceStringJalaliDate;
  }

  DateTime jumpToNextTime(TimeOfDay timeOfDay) {
    var output = copyWith(second: 0, microsecond: 0);
    while (output.minute != timeOfDay.minute) {
      output = output.add(const Duration(minutes: 1));
    }
    while (output.hour != timeOfDay.hour) {
      output = output.add(const Duration(hours: 1));
    }
    return output;
  }
}

extension Add on TimeOfDay {
  TimeOfDay addMinute(int addMinute) {
    return TimeOfDay(
        hour: (minute + addMinute) >= 60
            ? hour == 23
                ? 0
                : hour + 1
            : hour,
        minute: (minute + addMinute) % 60);
  }

  int minuteIndex() {
    return hour * 60 + minute;
  }

  String convertToString() {
    return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
  }
}

TimeOfDay convertStringToTimeOfDay(String timeOfDay) {
  return TimeOfDay(hour: timeOfDay.split(':').first.toInt(), minute: timeOfDay.split(':').last.toInt());
}

TextAlign makeAlignJustify() {
  return kIsWeb ? TextAlign.justify : TextAlign.justify;
}
