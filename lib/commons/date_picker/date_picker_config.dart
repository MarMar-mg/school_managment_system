import 'package:flutter/cupertino.dart';
import 'package:school_management_system/commons/date_picker/helper/day_date.dart';

class DatePickerConfig extends InheritedWidget {
  final Widget? Function(DayDate)? customWidget;
  final DateTime? startEnableDate;
  final DateTime? endEnableDate;
  final DateTime? initialDate;
  final Color colorQube;
  final Color activeColorQube;
  final void Function(DayDate) onSelectedDay;

  const DatePickerConfig({
    required this.customWidget,
    required this.colorQube,
    required this.activeColorQube,
    required this.onSelectedDay,
    this.startEnableDate,
    this.endEnableDate,
    this.initialDate,
    required Widget child,
    Key? key,
  }) : super(key: key, child: child);

  static DatePickerConfig of(BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType<DatePickerConfig>())!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }
}
