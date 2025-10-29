import 'package:flutter/material.dart';

const double cardHeight = 120.0;

class ItemContainer extends StatelessWidget {
  final Widget child;
  final bool isCurrent;

  const ItemContainer({required this.child, required this.isCurrent, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: cardHeight,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        border: isCurrent ? Border.all(color: Colors.blue, width: 3) : null,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            spreadRadius: 3,
            blurRadius: 7,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
