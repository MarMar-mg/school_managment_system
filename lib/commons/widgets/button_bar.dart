import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/commons/text_style.dart';
import 'package:flutter/material.dart';

class ButtonsBar extends StatefulWidget {
  final List<String> titles;
  final String activeTitle;
  final bool isTeacher;
  final void Function(String title) onPressTitle;

  const ButtonsBar(
      {required this.titles,
      required this.activeTitle,
      required this.onPressTitle,
      Key? key,
      required this.isTeacher})
      : super(key: key);

  @override
  State<ButtonsBar> createState() => _ButtonsBarState();
}

class _ButtonsBarState extends State<ButtonsBar> {
  String activeTitle = "";

  @override
  void initState() {
    activeTitle = widget.activeTitle;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: widget.titles
              .map((title) => GestureDetector(
                    onTap: () {
                      widget.onPressTitle(title);
                      setState(() => activeTitle = title);
                    },
                    child: Container(
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: activeTitle == title
                            ? (widget.isTeacher
                                ? AppColor.teachSystemGreen2
                                : AppColor.stuSystemBlue2)
                            : Colors.transparent,
                        shape: BoxShape.rectangle,
                        border: Border.all(
                            color: activeTitle == title
                                ? (widget.isTeacher
                                    ? AppColor.teachSystemGreen2
                                    : AppColor.stuSystemBlue2)
                                : AppColor.grey(true, 300),
                            width: 1.5),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(50)),
                      ),
                      child: Text(
                        title,
                        style: defaultTextStyle(context, StyleText.bb2).c(
                            activeTitle == title
                                ? Colors.white
                                : AppColor.grey(true, 400)),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
