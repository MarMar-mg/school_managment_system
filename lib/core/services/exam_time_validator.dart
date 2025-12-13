import 'package:shamsi_date/shamsi_date.dart';

class ExamTimeValidator {
  /// Check if current time is within exam window
  /// Returns: 'before_start', 'during', 'after_end', or 'invalid'
  static String getExamStatus({
    required String examDate, // "1403-09-20"
    required String startTime, // "10:30"
    required String endTime, // "12:30"
  }) {
    try {
      final now = DateTime.now();

      // Parse exam date (Jalali format)
      final dateParts = examDate.split('-');
      if (dateParts.length != 3) return 'invalid';

      final jalaliYear = int.parse(dateParts[0]);
      final jalaliMonth = int.parse(dateParts[1]);
      final jalaliDay = int.parse(dateParts[2]);

      // Parse times
      final startTimeParts = startTime.split(':');
      final endTimeParts = endTime.split(':');

      if (startTimeParts.length != 2 || endTimeParts.length != 2) {
        return 'invalid';
      }

      final startHour = int.parse(startTimeParts[0]);
      final startMinute = int.parse(startTimeParts[1]);
      final endHour = int.parse(endTimeParts[0]);
      final endMinute = int.parse(endTimeParts[1]);

      // Convert Jalali to Gregorian
      final jalaliDate = Jalali(jalaliYear, jalaliMonth, jalaliDay);
      final gregorianDate = jalaliDate.toGregorian();

      // Create DateTime objects
      final examStart = DateTime(
        gregorianDate.year,
        gregorianDate.month,
        gregorianDate.day,
        startHour,
        startMinute,
      );

      final examEnd = DateTime(
        gregorianDate.year,
        gregorianDate.month,
        gregorianDate.day,
        endHour,
        endMinute,
      );

      // Compare with current time
      if (now.isBefore(examStart)) {
        return 'before_start';
      } else if (now.isAfter(examEnd)) {
        return 'after_end';
      } else {
        return 'during';
      }
    } catch (e) {
      print('Error validating exam time: $e');
      return 'invalid';
    }
  }

  /// Get remaining time in minutes until exam ends
  /// Returns -1 if exam hasn't started or already ended
  static int getRemainingMinutes({
    required String examDate,
    required String startTime,
    required String endTime,
  }) {
    try {
      final now = DateTime.now();

      final dateParts = examDate.split('-');
      if (dateParts.length != 3) return -1;

      final jalaliYear = int.parse(dateParts[0]);
      final jalaliMonth = int.parse(dateParts[1]);
      final jalaliDay = int.parse(dateParts[2]);

      final endTimeParts = endTime.split(':');
      if (endTimeParts.length != 2) return -1;

      final endHour = int.parse(endTimeParts[0]);
      final endMinute = int.parse(endTimeParts[1]);

      final jalaliDate = Jalali(jalaliYear, jalaliMonth, jalaliDay);
      final gregorianDate = jalaliDate.toGregorian();

      final examEnd = DateTime(
        gregorianDate.year,
        gregorianDate.month,
        gregorianDate.day,
        endHour,
        endMinute,
      );

      final remaining = examEnd.difference(now).inMinutes;
      return remaining > 0 ? remaining : -1;
    } catch (e) {
      return -1;
    }
  }

  /// Get time until exam starts in minutes
  /// Returns -1 if exam has already started
  static int getMinutesUntilStart({
    required String examDate,
    required String startTime,
  }) {
    try {
      final now = DateTime.now();

      final dateParts = examDate.split('-');
      if (dateParts.length != 3) return -1;

      final jalaliYear = int.parse(dateParts[0]);
      final jalaliMonth = int.parse(dateParts[1]);
      final jalaliDay = int.parse(dateParts[2]);

      final startTimeParts = startTime.split(':');
      if (startTimeParts.length != 2) return -1;

      final startHour = int.parse(startTimeParts[0]);
      final startMinute = int.parse(startTimeParts[1]);

      final jalaliDate = Jalali(jalaliYear, jalaliMonth, jalaliDay);
      final gregorianDate = jalaliDate.toGregorian();

      final examStart = DateTime(
        gregorianDate.year,
        gregorianDate.month,
        gregorianDate.day,
        startHour,
        startMinute,
      );

      final minutesUntil = examStart.difference(now).inMinutes;
      return minutesUntil > 0 ? minutesUntil : -1;
    } catch (e) {
      return -1;
    }
  }

  /// Get formatted error message for submission
  static String getTimeErrorMessage(String status) {
    switch (status) {
      case 'before_start':
        return 'امتحان هنوز شروع نشده‌است. لطفا تا زمان شروع صبر کنید.';
      case 'after_end':
        return 'زمان تحویل امتحان به پایان رسیده است. دیگر نمی‌توانید پاسخ ارسال کنید.';
      case 'invalid':
        return 'خطا در بررسی زمان امتحان. لطفا بعدا تلاش کنید.';
      default:
        return 'خطای نامشخص در بررسی زمان.';
    }
  }
}
