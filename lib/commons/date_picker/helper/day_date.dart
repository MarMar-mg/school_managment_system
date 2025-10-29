import 'package:shamsi_date/shamsi_date.dart';

import 'month_date.dart';

class DayDate {
  final int dayOfMonth;
  final MonthDate monthDate;

  DayDate({required this.monthDate, required this.dayOfMonth});

  factory DayDate.fromId(String id) {
    return DayDate(
        dayOfMonth: int.parse(id.split('-')[2]), monthDate: MonthDate(year: int.parse(id.split('-')[0]), month: int.parse(id.split('-')[1])));
  }

  factory DayDate.today() => DayDate.fromId('${Jalali.now().formatter.yyyy}-${Jalali.now().formatter.mm}-${Jalali.now().formatter.dd}');

  Jalali get day => Jalali(monthDate.year, monthDate.month, dayOfMonth);

  DayDate get startOfWeek => addDays(-(weekDay - 1));

  int get weekDay => day.weekDay;

  int get milliSecondSinceEpoch => day.toDateTime().millisecondsSinceEpoch;

  bool get isToday => fullName == '${Jalali.now().formatter.yyyy}-${Jalali.now().formatter.mm}-${Jalali.now().formatter.dd}';

  bool get isPast =>
      !isToday &&
      day.toDateTime().millisecondsSinceEpoch < Jalali(Jalali.now().year, Jalali.now().month, Jalali.now().day).toDateTime().millisecondsSinceEpoch;

  bool get isFuture =>
      !isToday &&
      day.toDateTime().millisecondsSinceEpoch > Jalali(Jalali.now().year, Jalali.now().month, Jalali.now().day).toDateTime().millisecondsSinceEpoch;

  String get id => fullName;

  String get name => dayOfMonth.toString().padLeft(2, '0');

  String get fullName => '${day.formatter.yyyy}-${day.formatter.mm}-${day.formatter.dd}';

  String get niceName => '${day.formatter.dd} ${day.formatter.mN}';

  String get fullNameGregorian => '${day.toGregorian().formatter.yyyy}-${day.toGregorian().formatter.mm}-${day.toGregorian().formatter.dd}';

  DateTime get dateTime => day.toDateTime();

  int get dayOfYear => monthDate.numberOfDayFromNewYearTillThisMonth + dayOfMonth;

  DayDate addDays(int addDays) {
    final newDayFormatter = day.addDays(addDays).formatter;
    return DayDate.fromId("${newDayFormatter.yyyy}-${newDayFormatter.mm}-${newDayFormatter.dd}");
  }
}
