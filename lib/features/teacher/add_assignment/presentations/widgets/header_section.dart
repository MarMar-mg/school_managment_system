import 'package:flutter/material.dart';

class HeaderSection extends StatelessWidget {
  final VoidCallback onAdd;

  const HeaderSection({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: const [
            Text('مدیریت تمرین‌ها',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                textDirection: TextDirection.rtl),
            Text('ایجاد و مدیریت تمرین‌های کلاسی',
                style: TextStyle(color: Colors.grey, fontSize: 12),
                textDirection: TextDirection.rtl),
          ],
        ),
        GestureDetector(
          onTap: onAdd,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.purple, Colors.deepPurple]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.add, color: Colors.white),
                SizedBox(width: 4),
                Text('تمرین جدید', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
