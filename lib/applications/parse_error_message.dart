import 'dart:convert';
import 'package:school_managment_system/commons/data/model/json_parser.dart';

String parseErrorMessage(String errorBody) {
  final text1 = JsonParser.stringParser(JsonParser.firstElementOfListParser(jsonDecode(errorBody), ['errors']), ['message']);
  if (text1.isNotEmpty) return text1;
  final text2 = JsonParser.stringParser(jsonDecode(errorBody), ['message']);
  if (text2.isNotEmpty) return text2;
  return "بروز مشکل ناشناخته";
}
