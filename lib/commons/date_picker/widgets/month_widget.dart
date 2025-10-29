import 'package:school_managment_system/commons/date_manager.dart';
import 'package:school_managment_system/commons/date_picker/date_picker_config.dart';

import '../helper/constants.dart';
import '../helper/day_date.dart';
import '../helper/month_date.dart';
import 'package:flutter/material.dart';

class MonthWidget extends StatelessWidget {
  final MonthDate monthDate;

  const MonthWidget({required this.monthDate, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Text(
            monthDate.monthName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xff000000),
            ),
          ),
        ),
        const SizedBox(height: 4.0),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            daysWidget(context).length ~/ 7,
            (index) => Row(
              children: daysWidget(context).sublist(index * 7, (index + 1) * 7).map((e) => Expanded(child: Center(child: e))).toList(),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> daysWidget(BuildContext context) {
    return [
      ...List.generate(
        monthDate.weekDayOfFirstDay - 1,
        (index) => emptyQubeWidget(),
      ),
      ...monthDate.days.map((e) => dayWidget(context: context, dayDate: e)).toList(),
      ...List.generate(
        7 - monthDate.weekDayOfLastDay,
        (index) => emptyQubeWidget(),
      ),
    ];
  }

  bool isEnableThisDay(BuildContext context, DayDate dayDate) {
    if (DatePickerConfig.of(context).startEnableDate != null &&
        dayDate.dateTime.millisecondsSinceEpoch < (DatePickerConfig.of(context).startEnableDate!.millisecondsSinceEpoch)) {
      return false;
    }
    if (DatePickerConfig.of(context).endEnableDate != null &&
        dayDate.dateTime.millisecondsSinceEpoch > (DatePickerConfig.of(context).endEnableDate!.millisecondsSinceEpoch)) {
      return false;
    }
    return true;
  }

  Widget dayWidget({required BuildContext context, required DayDate dayDate}) {
    return GestureDetector(
      onTap: () {
        if (!isEnableThisDay(context, dayDate)) {
          return;
        }
        DatePickerConfig.of(context).onSelectedDay(dayDate);
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: AspectRatio(
            aspectRatio: 1.0,
            child: Opacity(
              opacity: isEnableThisDay(context, dayDate) ? 1.0 : 0.5,
              child: DatePickerConfig.of(context).customWidget != null && DatePickerConfig.of(context).customWidget!(dayDate) != null
                  ? DatePickerConfig.of(context).customWidget!(dayDate)
                  : _defaultWidget(context, dayDate),
            )),
      ),
    );
  }

  Container _defaultWidget(BuildContext context, DayDate dayDate) {
    bool isActiveDay=DatePickerConfig.of(context).initialDate!=null&&DateManager.fromDateTime(dayDate.dateTime).niceStringJalaliDate == DateManager.fromDateTime(DatePickerConfig.of(context).initialDate!).niceStringJalaliDate;
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isActiveDay
            ? DatePickerConfig.of(context).activeColorQube
            : DatePickerConfig.of(context).colorQube,
        shape: BoxShape.rectangle,
        border: dayDate.isToday ? Border.all(color: Colors.transparent, width: 2) : null,
        borderRadius: const BorderRadius.all(Radius.circular(7)),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: dayDate.isToday ? 0.0 : 4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(dayDate.name,
                style: isActiveDay
                    ? Theme.of(context).textTheme.headlineMedium!.copyWith(fontSize: 14, fontWeight: FontWeight.bold)
                    : Theme.of(context).textTheme.displayMedium!.copyWith(fontSize: 14, fontWeight: FontWeight.bold)),
            if (dayDate.isToday)
              Text("امروز", style: Theme.of(context).textTheme.displayMedium!.copyWith(fontSize: 8, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget emptyQubeWidget() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: AspectRatio(
          aspectRatio: 1.0,
          child: Container(
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: emptyQubeColor,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(7)),
            ),
          )),
    );
  }
}
