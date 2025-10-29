import 'package:school_managment_system/commons/date_manager.dart';
import 'package:school_managment_system/commons/date_picker/date_picker_config.dart';

import 'helper/day_date.dart';
import 'widgets/year_widget.dart';
import 'helper/year_date.dart';
import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

class DayPickerWidget extends StatefulWidget {
  final Widget? Function(DayDate)? customWidget;
  final DateTime? startEnableDate;
  final DateTime? endEnableDate;
  final DateTime? initialDate;
  final void Function(DayDate) onSelectedDay;
  final Color colorQube;
  final Color activeColorQube;

  const DayPickerWidget(
      {required this.onSelectedDay,
      this.customWidget,
      required this.colorQube,
      required this.activeColorQube,
      this.startEnableDate,
      this.endEnableDate,
      this.initialDate,
      Key? key})
      : super(key: key);

  @override
  State<DayPickerWidget> createState() => _DayPickerWidgetState();
}

class _DayPickerWidgetState extends State<DayPickerWidget> {
  late int year;

  @override
  void initState() {
    year = widget.initialDate == null ? Jalali.now().year - 6 : DateManager.fromDateTime(widget.initialDate!).jalali.year;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DatePickerConfig(
      customWidget: widget.customWidget,
      onSelectedDay: widget.onSelectedDay,
      endEnableDate: widget.endEnableDate,
      startEnableDate: widget.startEnableDate,
      initialDate: widget.initialDate,
      colorQube: widget.colorQube,
      activeColorQube: widget.activeColorQube,
      child: _buildWidget(context),
    );
  }

  Widget _buildWidget(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 6.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  RotatedBox(
                    quarterTurns: 75,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_circle_down_sharp, color: Colors.grey, size: 32.0),
                      onPressed: () => setState(() => year--),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {},
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        year.toString(),
                        style: Theme.of(context).textTheme.displayLarge!.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  RotatedBox(
                    quarterTurns: 75,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_circle_up_sharp, color: Colors.grey, size: 32.0),
                      onPressed: () => setState(() => year++),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: YearWidget(yearDate: YearDate(year)))
          ],
        ),
      ),
    );
  }
}
