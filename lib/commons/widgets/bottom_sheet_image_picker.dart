import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<XFile?> showBottomSheetFilePicker(BuildContext context) async {
  final selected=await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (dialogContext) => Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.fromLTRB(18, 60, 18, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(Radius.circular(13)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          GestureDetector(
            child: Icon(Icons.camera_alt, color: Theme.of(context).primaryColor, size: 65.0),
            onTap: () async {
              final selected = await ImagePicker().pickImage(source: ImageSource.camera);
              await Future.delayed(const Duration(milliseconds: 600), () => "1");
              Navigator.pop(dialogContext,selected);
            },
          ),
          GestureDetector(
            child: Icon(Icons.image, color: Theme.of(context).primaryColor, size: 65.0),
            onTap: () async {
              final selected = await ImagePicker().pickImage(source: ImageSource.gallery);
              await Future.delayed(const Duration(milliseconds: 600), () => "1");
              Navigator.pop(dialogContext,selected);
            },
          ),
        ],
      ),
    ),
  ) as XFile?;
  return selected;
}
