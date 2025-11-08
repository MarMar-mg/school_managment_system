import 'package:equatable/equatable.dart';
import 'package:school_management_system/commons/utils.dart';
import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

class DateManager extends Equatable {
  final Jalali jalali;
  final int hour;
  final int minute;
  final int second;

  int get unixTime {
    final gregorian = jalali.toGregorian();
    return DateTime(gregorian.year, gregorian.month, gregorian.day, hour, minute, second).millisecondsSinceEpoch;
  }

  const DateManager({
    required this.jalali,
    this.hour = 0,
    this.minute = 0,
    this.second = 0,
  });

  factory DateManager.now() {
    return DateManager(
      jalali: Jalali.now(),
      hour: DateTime.now().hour,
      minute: DateTime.now().minute,
      second: DateTime.now().second,
    );
  }

  factory DateManager.fromString(String jalaliOrGregorianString, {int hour = 0, int minute = 0, int second = 0}) {
    final localJalaliOrGregorianString = jalaliOrGregorianString.replaceAll('/', '-').trim();
    if (localJalaliOrGregorianString.split('-').length != 3) {
      return DateManager.now();
    } else if (int.parse(localJalaliOrGregorianString.split('-')[0]) < 1900) {
      return DateManager(jalali: convertStringToJalali(localJalaliOrGregorianString), hour: hour, minute: minute, second: second);
    } else {
      return DateManager(
          jalali: convertGregorianToJalali(convertStringToGregorian(localJalaliOrGregorianString)),
          hour: hour,
          minute: minute,
          second: second);
    }
  }

  factory DateManager.fromIso8601(String iso8601String) {
    final dateTime = DateTime.parse(iso8601String);
    return DateManager.fromDateTime(dateTime);
  }

  factory DateManager.fromDateTime(DateTime dateTime) {
    return DateManager.fromString('${dateTime.toLocal().year}-${dateTime.toLocal().month}-${dateTime.toLocal().day}',
        hour: dateTime.toLocal().hour, minute: dateTime.toLocal().minute, second: dateTime.toLocal().second);
  }

  int distanceFrom(DateManager dateManager) {
    return jalali.distanceFrom(dateManager.jalali);
  }

  DateManager addDay(int numberOfDays) {
    return DateManager(jalali: jalali + numberOfDays);
  }

  DateManager addDuration(Duration duration) {
    return DateManager.fromDateTime(toDateTime.add(duration));
  }

  String get jalaliString => convertJalaliToString(jalali);

  String get gregorianString => convertGregorianToString(convertJalaliToGregorian(jalali));

  TimeOfDay get timeOfDay => TimeOfDay(hour: hour, minute: minute);

  String get niceStringJalaliDate {
    final dateFormatter = jalali.formatter;
    return '${dateFormatter.wN}  ${dateFormatter.d}  ${dateFormatter.mN}  ${dateFormatter.yyyy}';
  }

  String get weekName {
    final dateFormatter = jalali.formatter;
    return dateFormatter.wN;
  }

  String get briefStringJalaliDate {
    final dateFormatter = jalali.formatter;
    return '${dateFormatter.d} ${dateFormatter.mN} ${dateFormatter.yyyy}';
  }

  String get computerStringJalaliDate {
    final dateFormatter = jalali.formatter;
    return '${dateFormatter.yyyy}/${dateFormatter.mm}/${dateFormatter.dd}';
  }

  String get briefStringGeorgianDate {
    final dateFormatter = jalali.toGregorian().formatter;
    return '${dateFormatter.yyyy}-${dateFormatter.mm}-${dateFormatter.dd}';
  }

  DateTime get toDateTime {
    return jalali.toDateTime();
  }

  String get niceStringJalaliDateTime {
    return '$niceStringJalaliDate $hour:$minute';
  }

  @override
  List<Object> get props => [jalaliString];
}
