import 'package:flutter/material.dart';
import '../commons/text_style.dart';
import '../commons/untils.dart';
import 'colors.dart';

class OurNavigationDrawer extends StatefulWidget {
  final int activeMenuId;
  final bool isTeacher;

  const OurNavigationDrawer(
      {required this.activeMenuId, Key? key, required this.isTeacher})
      : super(key: key);

  @override
  State<OurNavigationDrawer> createState() => _OurNavigationDrawerState();
}

class _OurNavigationDrawerState extends State<OurNavigationDrawer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.isTeacher
          ? AppColor.teachSystemGreen2
          : AppColor.asstSystemBlue2,
      padding: const EdgeInsets.all(10.0),
      child: SafeArea(
        child: !widget.isTeacher
            ? Stack(
                children: [
                  Drawer(
                    backgroundColor: widget.isTeacher
                        ? AppColor.teachSystemGreen2
                        : AppColor.asstSystemBlue2,
                    elevation: 0.0,
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              child: IconButton(
                                icon: Icon(Icons.close,
                                    color: AppColor.grey(true, 900),
                                    size: 17.0),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                        const SizedBox(height: 36.0),
                        createDrawerBodyItem(
                          context: context,
                          title: 'ثبت اموال',
                          onClick: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: (context) => const EquAssPage()),
                            // );
                          },
                        ),

                        const Divider(
                            height: 1,
                            thickness: 1.3,
                            color: Color(0xfff0f0f0),
                            indent: 12,
                            endIndent: 12),
                        const SizedBox(
                          height: 40,
                        ),
                        // createDrawerBodyItem(
                        //   context: context,
                        //   title: 'مدیریت اموال',
                        //   onClick: () {},
                        //   // => Navigator.push(
                        //   //   context,
                        //   //   MaterialPageRoute(
                        //   //       builder: (context) => LoginPage.wrappedRoute(const PortalMainPage(), isBack : true)),
                        //   // ),
                        // ),
                        // const Divider(height: 1, thickness: 1.3, color: Color(0xfff0f0f0),indent: 12,endIndent: 12),
                        // const SizedBox(height: 40,),

                        birthDayPicker(),
                        
                        const Divider(
                            height: 1,
                            thickness: 1.3,
                            color: Color(0xfff0f0f0),
                            indent: 12,
                            endIndent: 12),
                        const SizedBox(
                          height: 40,
                        ),
                        createDrawerBodyItem(
                          context: context,
                          title: 'مشاهده‌ی رویداد‌های تقویم',
                          onClick: () {
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => const ViewEventPage(
                            //               isTeacher: false, isStudent: false, studentid: ''
                            //             )));
                          },
                        ),

                        const Divider(
                            height: 1,
                            thickness: 1.3,
                            color: Color(0xfff0f0f0),
                            indent: 12,
                            endIndent: 12),
                        const SizedBox(
                          height: 40,
                        ),
                        createDrawerBodyItem(
                          context: context,
                          title: 'ثبت اخبار',
                          onClick: () {
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) =>
                            //             const CreateNewsPage()));
                          },
                        ),

                        const Divider(
                            height: 1,
                            thickness: 1.3,
                            color: Color(0xfff0f0f0),
                            indent: 12,
                            endIndent: 12),
                        const SizedBox(
                          height: 40,
                        ),
                        createDrawerBodyItem(
                          context: context,
                          title: 'مشاهده اخبار',
                          onClick: () {
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => NewsPage(
                            //               isTeacher: widget.isTeacher, isStudent: false, studentid: '',
                            //             )));
                          },
                          // => Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (context) => LoginPage.wrappedRoute(const PortalMainPage(), isBack : true)),
                          // ),
                        ),
                        const Divider(
                            height: 1,
                            thickness: 1.3,
                            color: Color(0xfff0f0f0),
                            indent: 12,
                            endIndent: 12),
                        const Spacer(),
                      ],
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 700),
                    reverseDuration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeInOutCirc,
                    transitionBuilder: (child, animation) {
                      const begin = Offset(0.0, 1.0);
                      const end = Offset.zero;
                      final tween = Tween(begin: begin, end: end);
                      final offsetAnimation = animation.drive(tween);
                      return SlideTransition(
                          position: offsetAnimation, child: child);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 300, right: 300),
                      child: dateWidget,
                    ),
                  ),
                ],
              )
            : Drawer(
                backgroundColor: widget.isTeacher
                    ? AppColor.teachSystemGreen2
                    : AppColor.asstSystemBlue2,
                elevation: 0.0,
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.close,
                                color: AppColor.grey(true, 900), size: 17.0),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    const SizedBox(height: 36.0),
                    createDrawerBodyItem(
                      context: context,
                      title: 'مشاهده‌ی رویداد‌های تقویم',
                      onClick: () {
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => const ViewEventPage(
                        //               isTeacher: true, isStudent: false, studentid: '',
                        //             )));
                      },
                    ),
                    const Divider(
                        height: 1,
                        thickness: 1.3,
                        color: Color(0xfff0f0f0),
                        indent: 12,
                        endIndent: 12),
                    const SizedBox(
                      height: 40,
                    ),
                    createDrawerBodyItem(
                      context: context,
                      title: 'مشاهده اخبار',
                      onClick: () {
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => NewsPage(
                        //               isTeacher: widget.isTeacher, isStudent: false, studentid: '',
                        //             )));
                      },
                      // => Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => LoginPage.wrappedRoute(const PortalMainPage(), isBack : true)),
                      // ),
                    ),
                    const Divider(
                        height: 1,
                        thickness: 1.3,
                        color: Color(0xfff0f0f0),
                        indent: 12,
                        endIndent: 12),
                    const Spacer(),
                  ],
                ),
              ),
      ),
    );
  }

  DateTime? pickedDate;

  // TextEditingController birthDateController = TextEditingController();
  bool isDatePickerOpened = false;
  late Widget dateWidget = const SizedBox();
  TextEditingController eventDateController = TextEditingController();

  Widget birthDayPicker() {
    return Expanded(
      child: SizedBox(
        height: 50,
        child: GestureDetector(
          onTap: () async {
            unFocus(context);
            isDatePickerOpened = true;
            print('jjjjjjjjjjjjjjjjjjjjjj');
            setState(
              () => dateWidget = SafeArea(
                child: Column(
                  children: [
                    Container(
                        color: Theme.of(context).colorScheme.surface,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            const Spacer(),
                            Text(
                              '    انتخاب تاریخ رویداد',
                              style: defaultTextStyle(context, StyleText.blwd2)
                                  .s(18)
                                  .w(7),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward_ios_rounded,
                                  color: Colors.black, size: 25.0),
                              onPressed: () async {
                                isDatePickerOpened = false;
                                dateWidget = const SizedBox();
                                setState(() {});
                              },
                            ),
                          ],
                        )),
                    // Expanded(
                    //   child: DayPickerWidget(
                    //     onSelectedDay: (dayDate) {
                    //       showAnimatedDialog(
                    //         context: context,
                    //         barrierDismissible: true,
                    //         builder: (BuildContext dialogContext) {
                    //           return DialogEventWidget(
                    //             onPositivePressed: () {},
                    //             date: pickedDate!.microsecondsSinceEpoch,
                    //           );
                    //         },
                    //         animationType:
                    //             DialogTransitionType.slideFromBottomFade,
                    //         curve: Curves.fastOutSlowIn,
                    //         duration: const Duration(milliseconds: 500),
                    //       );
                    //       pickedDate = dayDate.dateTime;
                    //       eventDateController.text =
                    //           DateManager.fromDateTime(pickedDate!)
                    //               .niceStringJalaliDate;
                    //       isDatePickerOpened = false;
                    //       dateWidget = const SizedBox();
                    //       setState(() {});
                    //     },
                    //     colorQube: AppColor.asstSystemBlue,
                    //     activeColorQube: Theme.of(context).primaryColor,
                    //     startEnableDate:
                    //     DateTime.now().subtract(const Duration(days: 30 * 365)),
                    //     initialDate: pickedDate ?? DateTime.now(),
                    //     endEnableDate:
                    //     DateTime.now().add(const Duration(days: 365 * 10)),
                    //   ),
                    // ),
                  ],
                ),
              ),
            );
          },
          child: AbsorbPointer(
            child: createDrawerBodyItem(
              context: context,
              title: 'ثبت رویدادهای تقویم',
              onClick: () {},
            ),
          ),
        ),
      ),
    );
  }
}

Widget createDrawerBodyItem({
  required BuildContext context,
  required String title,
  required void Function() onClick,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: GestureDetector(
      onTap: () => onClick(),
      child: Container(
        width: double.infinity,
        height: 60,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 15.0),
        decoration: const BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 15,
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: defaultTextStyle(context, StyleText.bb2)
                  .c(Colors.white)
                  .s(14)
                  .w(4),
            ),
          ],
        ),
      ),
    ),
  );
}
