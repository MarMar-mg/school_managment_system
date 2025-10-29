import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingWidget extends StatelessWidget {
  Color color;
  double size;
  bool back;

  LoadingWidget({this.color = Colors.grey, this.size = 100, this.back = false, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return back? Container(
      width: double.infinity,
      height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Center(child: LoadingAnimationWidget.waveDots(color: color, size: size)))
        : Center(child: LoadingAnimationWidget.waveDots(color: color, size: size));
  }
}
