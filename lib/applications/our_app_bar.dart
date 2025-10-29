import 'package:flutter/material.dart';
import '../commons/text_style.dart';

PreferredSize getNormalAppBar(
  BuildContext context,
) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(100),
    child: Container(
      width: double.infinity,
      height: double.infinity,
      margin: const EdgeInsets.only(right: 32, left: 32, top: 20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black, width: 1.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(width: 16,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'قثسیبل امنت',
                style: defaultTextStyle(
                  context,
                  StyleText.wb2,
                ).s(24).w(6).c(Colors.black),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => const GalleryPage()),
                  // );
                },
                child: Text(
                  'GALLERY',
                  style: defaultTextStyle(
                    context,
                    StyleText.wb2,
                  ).s(16).w(4).c(Colors.black),
                ),
              ),
              const SizedBox(width: 10,),
              TextButton(
                onPressed: () {},
                child: Text(
                  'ABOUT',
                  style: defaultTextStyle(
                    context,
                    StyleText.wb2,
                  ).s(16).w(4).c(Colors.black),
                ),
              ),
              const SizedBox(width: 10,),
              TextButton(
                onPressed: () {},
                child: Text(
                  'CONTACT',
                  style: defaultTextStyle(
                    context,
                    StyleText.wb2,
                  ).s(16).w(4).c(Colors.black),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8,),
        ],
      ),
    ),
  );
}
