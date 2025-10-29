import 'package:equatable/equatable.dart';
import 'package:school_managment_system/commons/data/model/json_parser.dart';


class PaginateList<T> extends Equatable {
  final List<T> list;
  final int currentPage;
  final int totalPage;
  final int perPage;

  const PaginateList({
    required this.list,
    required this.currentPage,
    required this.totalPage,
    required this.perPage,
  });

  factory PaginateList.fromJson(Map<String, dynamic> json, Function makeObject) {
    final output = PaginateList(
      list: (json['data'] as List).map((e) => (makeObject(e) as T)).toList(),
      totalPage: JsonParser.intTryParser(json, ['last_page']) ?? 1,
      currentPage: JsonParser.intTryParser(json, ['current_page']) ?? 1,
      perPage: JsonParser.intTryParser(json, ['per_page']) ?? 1000,
    );
    return output;
  }

  PaginateList<T> copyWith({
    List<T>? list,
    int? currentPage,
    int? totalPage,
    int? perPage,
  }) {
    return PaginateList(
      list: list ?? this.list,
      currentPage: currentPage ?? this.currentPage,
      totalPage: totalPage ?? this.totalPage,
      perPage: perPage ?? this.perPage,
    );
  }

  bool get isLastPage => currentPage >= totalPage;

  @override
  List<Object> get props => [currentPage, totalPage, perPage, list];
}
