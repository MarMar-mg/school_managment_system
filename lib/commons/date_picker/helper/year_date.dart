import 'day_date.dart';
import 'week_date.dart';

import 'month_date.dart';
import 'package:shamsi_date/shamsi_date.dart';

final Jalali epoch = Jalali(1401);
final int epochMilliseconds = epoch.toDateTime().millisecondsSinceEpoch;

class YearDate {
  final int year;

  YearDate(this.year);

  String get id => year.toString();

  DayDate get firstDay => months[0].days[0];

  String get name => "سال ${year.toString()} خورشیدی";

  bool get isCurrentYear => Jalali.now().year == year;

  bool get isFuture => !isCurrentYear && Jalali.now().year < year;

  bool get isPast => !isCurrentYear && Jalali.now().year > year;

  List<MonthDate> get months => List.generate(12, (index) => MonthDate(year: year, month: index + 1));

  List<WeekDate> get weeks {
    List<WeekDate> output = [];
    DayDate currentDay = firstDay;
    while (currentDay.day.year <= year) {
      output.add(WeekDate(currentDay.startOfWeek));
      currentDay = currentDay.addDays(7);
    }
    return output;
  }
}
