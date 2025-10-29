import 'package:intl/intl.dart';

class JsonParser {
  static dynamic parser(Map<String, dynamic> json, List<String> filedNames) {
    dynamic innerJson = json;
    for (int i = 0; i < filedNames.length; i++) {
      if (innerJson[filedNames[i]] == null) {
        if (innerJson['attributes'] == null) {
          return null;
        }
        if (innerJson['attributes'][filedNames[i]] == null) {
          return null;
        }
        innerJson = innerJson['attributes'][filedNames[i]];
        continue;
      }
      innerJson = innerJson[filedNames[i]];
    }
    return innerJson;
  }

  static Map<String, dynamic> parseJson(Map<String, dynamic> json, List<String> filedNames) {
    final result = parser(json, filedNames);
    return result == null ? {} : result as Map<String, dynamic>;
  }

  static List<Map<String, dynamic>> parseJsonValuesToList(Map<String, dynamic> json, List<String> filedNames) {
    final result = parseJson(json, filedNames);
    return result.values.map((e) => e as Map<String, dynamic>).toList();
  }

  static List<dynamic> listParser(Map<String, dynamic> json, List<String> filedNames) {
    final result = parser(json, filedNames);
    return result is List ? result : [];
  }

  static dynamic firstElementOfListParser(Map<String, dynamic> json, List<String> filedNames) {
    final result = listParser(json, filedNames);
    return result.isEmpty ? null : result[0];
  }

  static String? stringTryParser(Map<String, dynamic>? json, List<String> filedNames) {
    if (json == null) {
      return null;
    }
    final result = parser(json, filedNames);
    if (result == null) {
      return null;
    } else {
      return result.toString().trim();
    }
  }

  static String stringParser(Map<String, dynamic>? json, List<String> filedNames) => stringTryParser(json, filedNames) ?? '';

  static int? intTryParser(Map<String, dynamic>? json, List<String> filedNames) {
    if (json == null) {
      return null;
    }
    final result = stringParser(json, filedNames);
    return result.isEmpty ? null : int.tryParse(result);
  }

  static double? doubleTryParser(Map<String, dynamic>? json, List<String> filedNames) {
    if (json == null) {
      return null;
    }
    final result = stringParser(json, filedNames);
    return result.isEmpty ? null : double.tryParse(result);
  }

  static int intParser(Map<String, dynamic>? json, List<String> filedNames) => intTryParser(json, filedNames) ?? 0;

  static double doubleParser(Map<String, dynamic>? json, List<String> filedNames) => doubleTryParser(json, filedNames) ?? 0.0;

  static bool? boolTryParser(Map<String, dynamic>? json, List<String> filedNames) {
    if (json == null) {
      return null;
    }
    final result = stringParser(json, filedNames).toLowerCase();
    return result.isEmpty ? null : result == '1' || result == 'true';
  }

  static bool boolParser(Map<String, dynamic>? json, List<String> filedNames) => boolTryParser(json, filedNames) ?? false;

  static DateTime? dateTimeParser(Map<String, dynamic>? json, List<String> filedNames) {
    if (json == null) {
      return null;
    }
    final result = stringParser(json, filedNames).toLowerCase().split('.').first.replaceAll('t', ' ');
    return result.isEmpty ? null : DateFormat('yyyy-MM-dd HH:mm:ss').parse(result, true);
  }
  // static DateTime dateTimeParser(Map<String, dynamic>? json, List<String> filedNames) {
  //
  //   final result = stringParser(json, filedNames).toLowerCase().split('.').first.replaceAll('t', ' ');
  //   return DateFormat('yyyy-MM-dd HH:mm:ss').parse(result, true);
  // }
}
