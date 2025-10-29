import 'package:flutter/material.dart';

import '../helper/constants.dart';
import '../helper/year_date.dart';
import 'month_widget.dart';

class YearWidget extends StatelessWidget {
  final YearDate yearDate;

  const YearWidget({required this.yearDate, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 6.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
              children: weekNames
                  .map((e) => Expanded(
                      child: Center(
                          child: Text(e,
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium!
                                  .copyWith(fontSize: 10, fontWeight: FontWeight.bold,)))))
                  .toList()),
        ),
        const SizedBox(height: 8.0),
        const Divider(height: 1, thickness: 1.3, color: Color(0xfff0f0f0), indent: 6, endIndent: 6),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            itemCount: yearDate.months.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: MonthWidget(monthDate: yearDate.months[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}
