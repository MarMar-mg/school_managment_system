import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';



class ShamsiDatePickerDialog extends StatefulWidget {
  final Jalali initialDate;
  final Jalali firstDate;
  final Jalali lastDate;

  const ShamsiDatePickerDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<ShamsiDatePickerDialog> createState() => _ShamsiDatePickerDialogState();
}

class _ShamsiDatePickerDialogState extends State<ShamsiDatePickerDialog> {

  late Jalali _currentMonth;
  late Jalali _selectedDate;

  final List<String> _monthNames = [
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'مرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند',
  ];

  final List<String> _dayNames = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];

  @override
  void initState() {
    super.initState();
    _currentMonth = Jalali(widget.initialDate.year, widget.initialDate.month, 1);
    _selectedDate = widget.initialDate;
  }

  void _previousMonth() {
    setState(() {
      if (_currentMonth.month == 1) {
        _currentMonth = Jalali(_currentMonth.year - 1, 12, 1);
      } else {
        _currentMonth = Jalali(_currentMonth.year, _currentMonth.month - 1, 1);
      }
    });
  }

  void _nextMonth() {
    setState(() {
      if (_currentMonth.month == 12) {
        _currentMonth = Jalali(_currentMonth.year + 1, 1, 1);
      } else {
        _currentMonth = Jalali(_currentMonth.year, _currentMonth.month + 1, 1);
      }
    });
  }

  int _getDaysInMonth(int month, int year) {
    if (month <= 6) return 31;
    if (month <= 11) return 30;
    return Jalali(year, 12, 1).isLeapYear() ?  30: 29;
  }

  List<int?> _getCalendarDays() {
    final daysInMonth = _getDaysInMonth(_currentMonth.month, _currentMonth.year);
    final firstDay = Jalali(_currentMonth.year, _currentMonth.month, 1);
    final startingWeekday = firstDay.weekDay; // 0 = Saturday, 6 = Friday

    final days = <int?>[];

    // Add empty slots for days before the month starts
    for (int i = 0; i < startingWeekday; i++) {
      days.add(null);
    }

    // Add days of the month
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(i);
    }

    return days;
  }

  @override
  Widget build(BuildContext context) {
    final days = _getCalendarDays();

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Month and Year Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _nextMonth,
                ),
                Text(
                  '${_monthNames[_currentMonth.month - 1]} ${_currentMonth.year}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _previousMonth,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Day names header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _dayNames
                  .map((day) => Expanded(
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
              ))
                  .toList(),
            ),
            const SizedBox(height: 8),

            // Calendar grid
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              children: days.map((day) {
                if (day == null) {
                  return const SizedBox();
                }

                final date = Jalali(_currentMonth.year, _currentMonth.month, day);
                final isSelected = _selectedDate.year == date.year &&
                    _selectedDate.month == date.month &&
                    _selectedDate.day == date.day;

                return InkWell(
                  onTap: () {
                    setState(() => _selectedDate = date);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF7C3AED) : null,
                      borderRadius: BorderRadius.circular(8),
                      border: !isSelected
                          ? Border.all(color: Colors.grey.shade300)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      day.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'انصراف',
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, _selectedDate),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'تأیید',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}