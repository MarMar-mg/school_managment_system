
import 'package:shamsi_date/shamsi_date.dart';

class DateFormatManager {
  static String formatDate(dynamic date) {
    if (date == null) return '';
    final dateStr = date.toString().trim();
    if (dateStr.length >= 8) {
      final year = dateStr.substring(0, 4);
      final month = dateStr.substring(5, 7);
      final day = dateStr.substring(8, 10);
      return '$year/$month/$day';
    }
    return dateStr;
  }

  static DateTime convertToDateTime(String jalaliDate) {
    final parts = jalaliDate.split("-");
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);

    final jalali = Jalali(year, month, day);
    final gregorian = jalali.toGregorian();

    return DateTime(gregorian.year, gregorian.month, gregorian.day);
  }

}