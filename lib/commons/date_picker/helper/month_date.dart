import 'day_date.dart';
import 'package:shamsi_date/shamsi_date.dart';

class MonthDate {
  final int month; //start from 1
  final int year;

  MonthDate({required this.month, required this.year});

  factory MonthDate.fromId(String id) => MonthDate(year: int.parse(id.split('-')[0]), month: int.parse(id.split("-")[1]));

  String get id => "$year-${month.toString().padLeft(2, '0')}";

  int get weekDayOfLastDay => (weekDayOfFirstDay + numberOfDay - 1) % 7;

  bool get isCurrentMonth => Jalali.now().year == year && Jalali.now().month == month;

  String get monthName => jalaliMonth.formatter.mN;

  bool get isFuture => !isCurrentMonth && (Jalali.now().year < year || (Jalali.now().year == year && Jalali.now().month < month));

  bool get isPast => !isCurrentMonth && (Jalali.now().year > year || (Jalali.now().year == year && Jalali.now().month > month));

  int get numberOfDayFromNewYearTillThisMonth {
    int numberOfMonthFromNewYearTillThisMonth = int.parse(jalaliMonth.formatter.m);
    int days = 0;
    for (int i = 1; i < numberOfMonthFromNewYearTillThisMonth; i++) {
      if (i <= 6) {
        days += 31;
        continue;
      }
      if (i <= 11) {
        days += 30;
        continue;
      }
    }
    return days;
  }

  Jalali get jalaliMonth => Jalali(year, month);

  int get numberOfDay => jalaliMonth.monthLength;

  int get weekDayOfFirstDay => jalaliMonth.weekDay;

  List<DayDate> get days => List.generate(numberOfDay, (index) => DayDate(monthDate: this, dayOfMonth: index + 1));
}
