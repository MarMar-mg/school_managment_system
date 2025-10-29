import 'day_date.dart';
import 'month_date.dart';

class WeekDate {
  final DayDate startWeekDay;

  WeekDate(this.startWeekDay);

  DayDate get lastWeekDay => startWeekDay.addDays(6);

  DayDate get firstDayAfterThisWeek => startWeekDay.addDays(7);

  MonthDate get monthDate => days[2].monthDate;

  bool get isCurrentWeek =>
      startWeekDay.milliSecondSinceEpoch <= DayDate.today().milliSecondSinceEpoch &&
      firstDayAfterThisWeek.milliSecondSinceEpoch > DayDate.today().milliSecondSinceEpoch;

  bool get isPast => !isCurrentWeek && DayDate.today().milliSecondSinceEpoch > startWeekDay.milliSecondSinceEpoch;

  bool get isFuture => !isCurrentWeek && DayDate.today().milliSecondSinceEpoch < lastWeekDay.milliSecondSinceEpoch;

  String get id => startWeekDay.id;

  String get name => "از ${startWeekDay.niceName}";

  List<DayDate> get days => [
        startWeekDay,
        startWeekDay.addDays(1),
        startWeekDay.addDays(2),
        startWeekDay.addDays(3),
        startWeekDay.addDays(4),
        startWeekDay.addDays(5),
        startWeekDay.addDays(6),
      ];
}
