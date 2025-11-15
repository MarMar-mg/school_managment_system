
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
}