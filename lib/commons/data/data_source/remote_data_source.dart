import 'package:dartz/dartz.dart';
import 'package:school_managment_system/commons/failures.dart';

import '../model/server_failures.dart';

abstract class RemoteDataSource {
  Future<Either<FailureForCustom, T>> putToServer<T>({
    required String url,
    required Map<String, dynamic> params,
    required T Function(Map<String, dynamic> success) mapSuccess,
    bool isTokenNeed = true,
    String? localKey,
  });

  Future<Either<FailureForCustom, T>> patchToServer<T>({
    required String url,
    required Map<String, dynamic> params,
    required T Function(Map<String, dynamic> success) mapSuccess,
    bool isTokenNeed = true,
    String? localKey,
  });

  Future<Either<FailureForCustom, T>> postToServer<T>({
    required String url,
    required Map<String, dynamic> params,
    required T Function(Map<String, dynamic> success) mapSuccess,
    bool isTokenNeed = true,
    String? localKey,
  });

  Future<Either<ServerFailure, List<T>>> postListToServer<T>({
    required String url,
    required dynamic params,
    required List<T> Function(List<dynamic> success) mapSuccess,
    bool isTokenNeed = true,
    String? localKey,
  });

  Future<Either<FailureForCustom, T>> deleteToServer<T>({
    required String url,
    required Map<String, dynamic> params,
    required T Function(Map<String, dynamic> success) mapSuccess,
    bool isTokenNeed = true,
  });

  Future<Either<FailureForCustom, T>> getFromServer<T>({
    required String url,
    required Map<String, dynamic> params,
    required T Function(Map<String, dynamic> success) mapSuccess,
    bool isTokenNeed = true,
    String? localKey,
    Duration? expireDateLocalKey,
  });

  Future<Either<ServerFailure, List<T>>> getListFromServer<T>({
    required String url,
    required Map<String,dynamic> params,
    required List<T> Function(List<dynamic> success) mapSuccess,
    bool isTokenNeed = true,
    String? localKey,
    Duration? expireDateLocalKey,
    bool isForceRefresh = false,
  });

}


