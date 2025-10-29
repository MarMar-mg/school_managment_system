import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:school_managment_system/applications/constants.dart';
import 'package:school_managment_system/commons/failures.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../../utils.dart';
import '../model/server_failures.dart';
import 'remote_data_source.dart';

class RemoteDataSourceImpl implements RemoteDataSource {
  final http.Client client;
  final Function isInternetEnable;
  final String Function(String key) readDataFromLocal;
  final void Function(String key, String value) writeDataToLocal;

  RemoteDataSourceImpl(
      {required this.client, required this.isInternetEnable, required this.readDataFromLocal, required this.writeDataToLocal});

  Map<String, String> get publicHeader {
    return {
      'Accept': 'application/json',
    };
  }

  Map<String, String> get authenticateHeader {
    var output = publicHeader;
    String token = getTokenFromLocal();
    if (token.isNotEmpty) {
      String preFix = '';
      output['Authorization'] = '$preFix$token';
    }
    return output;
  }

  Map<String, String> getHeader(bool isTokenNeed) => isTokenNeed ? authenticateHeader : publicHeader;

  bool isExpireDateArrived(Duration expireDateLocalKey, String localKey) =>
      expireDateLocalKey.inSeconds < (DateTime.now().millisecondsSinceEpoch - (GetStorage().read<int>('modifyAt-$localKey') ?? 0) / 1000);

  @override
  Future<Either<FailureForCustom, T>> postToServer<T>({
    required String url,
    required Map<String, dynamic> params,
    required T Function(Map<String, dynamic> success) mapSuccess,
    bool isTokenNeed = true,
    String? localKey,
  }) async {
    if (!await isInternetEnable()) {
      return Left(noNetFailure);
    }
    final response = await _callFunctionOfServer(
      response: client.post(Uri.parse(url), body: params, headers: getHeader(isTokenNeed)),
      params: params,
      url: url,
      isTokenNeed: isTokenNeed,
      methodName: 'post',
    );
    return response.fold(
      (l) => Left(l),
      (data) {
        if (data == 'null') {
          throw Exception();
        }
        if (localKey != null) {
          GetStorage().write(localKey, data);
          GetStorage().write('modifyAt-$localKey', DateTime.now().millisecondsSinceEpoch);
        }
        return Right(convertStringToSuccessData(data, (success) => mapSuccess(success)));
      },
    );
  }

  @override
  Future<Either<FailureForCustom, T>> putToServer<T>(
      {required String url,
      required Map<String, dynamic> params,
      required T Function(Map<String, dynamic> success) mapSuccess,
      bool isTokenNeed = true,
      String? localKey}) async {
    if (!await isInternetEnable()) return Left(noNetFailure);
    final response = await _callFunctionOfServer(
      response: client.put(Uri.parse(url), body: params, headers: getHeader(isTokenNeed)),
      params: params,
      url: url,
      isTokenNeed: isTokenNeed,
      methodName: 'put',
    );
    return response.fold(
      (l) => Left(l),
      (data) {
        if (localKey != null) {
          GetStorage().write(localKey, data);
          GetStorage().write('modifyAt-$localKey', DateTime.now().millisecondsSinceEpoch);
        }
        return Right(convertStringToSuccessData(data, (success) => mapSuccess(success)));
      },
    );
  }

  @override
  Future<Either<FailureForCustom, T>> patchToServer<T>(
      {required String url,
      required Map<String, dynamic> params,
      required T Function(Map<String, dynamic> success) mapSuccess,
      bool isTokenNeed = true,
      String? localKey}) async {
    if (!await isInternetEnable()) return Left(noNetFailure);
    final response = await _callFunctionOfServer(
      response: client.patch(Uri.parse(url), body: params, headers: getHeader(isTokenNeed)),
      params: params,
      url: url,
      isTokenNeed: isTokenNeed,
      methodName: 'patch',
    );
    return response.fold(
      (l) => Left(l),
      (data) {
        if (localKey != null) {
          GetStorage().write(localKey, data);
          GetStorage().write('modifyAt-$localKey', DateTime.now().millisecondsSinceEpoch);
        }
        return Right(convertStringToSuccessData(data, (success) => mapSuccess(success)));
      },
    );
  }

  Future<Either<FailureForCustom, String>> _callFunctionOfServer<T>({
    required String methodName,
    required Future<http.Response> response,
    required String url,
    required dynamic params,
    required isTokenNeed,
  }) async {
    try {
      Logger().v('$methodName===> url ===> $url \n\nbodyParameters ===> $params\n\ndefaultHeader ===> ${getHeader(isTokenNeed)}');
      http.Response finalResponse = await response;
      Logger().d('$methodName===> response.statusCode==> ${finalResponse.statusCode}  for  $url');
      if (isSuccessfulHttp(finalResponse)) {
        Logger().i('$methodName===>$url $params \n response is===>${finalResponse.body}');
        return Right(finalResponse.body);
      } else {
        Logger().e('$methodName===> response.error ===> params=>$params \n ${finalResponse.statusCode}  ${finalResponse.body}');
        handleGlobalErrorInServer(finalResponse);
        return Left(FailureForCustom.serverFailure(finalResponse));
      }
    } on Exception catch (exception) {
      Logger().wtf("$methodName===> crash ===> ${exception.toString()}  for  $url");
      return Left(FailureForCustom.serverCrash(exception));
    }
  }

  T convertStringToSuccessData<T>(String data, T Function(Map<String, dynamic> success) mapSuccess) => mapSuccess(jsonDecode(data));

  void handleGlobalErrorInServer(http.Response response) {
    if (response.statusCode == 401) _removeTokenBecauseIfExpire(response);
  }

  void _removeTokenBecauseIfExpire(http.Response response) {
    writeDataToLocal(LocalKeys.tttoken.name, "");
  }

  @override
  Future<Either<FailureForCustom, T>> deleteToServer<T>({
    required String url,
    required Map<String, dynamic> params,
    required T Function(Map<String, dynamic> success) mapSuccess,
    bool isTokenNeed = true,
  }) async {
    if (!await isInternetEnable()) return Left(noNetFailure);
    final response = await _callFunctionOfServer(
      response: client.delete(Uri.parse(url), body: jsonEncode(params), headers: getHeader(isTokenNeed)),
      params: params,
      url: url,
      isTokenNeed: isTokenNeed,
      methodName: "delete",
    );
    return response.fold(
      (l) => Left(l),
      (data) => Right(convertStringToSuccessData(data, (success) => mapSuccess(success))),
    );
  }

  @override
  Future<Either<FailureForCustom, T>> getFromServer<T>({
    required String url,
    required Map<String, dynamic> params,
    required T Function(Map<String, dynamic> success) mapSuccess,
    String? localKey,
    bool isTokenNeed = true,
    Duration? expireDateLocalKey = const Duration(hours: 1),
  }) async {
    if (localKey != null && GetStorage().hasData(localKey)) {
      if (expireDateLocalKey != null && isExpireDateArrived(expireDateLocalKey, localKey)) {
        GetStorage().remove(localKey);
        GetStorage().remove('modifyAt-$localKey');
      } else {
        return Right(convertStringToSuccessData(GetStorage().read<String>(localKey)!, (success) => mapSuccess(success)));
      }
    }
    if (!await isInternetEnable()) return Left(noNetFailure);
    String paramsString = params.entries.map((entry) => '${entry.key}=${entry.value}').toList().join('&');
    if (paramsString.isNotEmpty) {
      paramsString = '?$paramsString';
    }
    final finalUri = Uri.parse('$url$paramsString');
    final response = await _callFunctionOfServer(
      response: client.get(finalUri, headers: getHeader(isTokenNeed)),
      params: params,
      url: url,
      isTokenNeed: isTokenNeed,
      methodName: 'get',
    );
    return response.fold(
      (l) => Left(l),
      (data) {
        if (localKey != null) {
          GetStorage().write(localKey, data);
          GetStorage().write('modifyAt-$localKey', DateTime.now().millisecondsSinceEpoch);
        }
        return Right(convertStringToSuccessData(data, (success) => mapSuccess(success)));
      },
    );
  }

  @override
  Future<Either<ServerFailure, List<T>>> getListFromServer<T>({
    required String url,
    required Map<String, dynamic> params,
    required List<T> Function(List<dynamic> success) mapSuccess,
    String? localKey,
    Duration? expireDateLocalKey,
    bool isTokenNeed = true,
    bool isForceRefresh = false,
  }) async {
    String methodName = "getList";
    if (localKey != null && GetStorage().hasData(localKey) && !isForceRefresh) {
      if (expireDateLocalKey != null && isExpireDateArrived(expireDateLocalKey, localKey)) {
        GetStorage().remove(localKey);
        GetStorage().remove("modifyAt-$localKey");
      } else {
        return Right(mapSuccess((jsonDecode(GetStorage().read(localKey)) as List)));
      }
    }
    if (!await isInternetEnable()) return Left(ServerFailure.noInternet());
    try {
      Logger().v("$methodName===> url ===> $url \n\nbodyParameters ===> $params\n\ndefaultHeader ===> ${getHeader(isTokenNeed)}");
      final finalUri = params.isNotEmpty ? Uri.parse(url).replace(queryParameters: params) : Uri.parse(url);
      http.Response finalResponse = await client.get(finalUri, headers: getHeader(isTokenNeed));
      Logger().d("$methodName===> response.statusCode==> ${finalResponse.statusCode}  for  $url");
      if (isSuccessfulHttp(finalResponse)) {
        Logger().i("$methodName===>$url response is===>${finalResponse.body}");
        if (localKey != null) {
          GetStorage().write(localKey, finalResponse.body);
          GetStorage().write("modifyAt-$localKey", DateTime.now().millisecondsSinceEpoch);
        }
        return Right(mapSuccess((jsonDecode(finalResponse.body) as List)));
      } else {
        Logger().e("$methodName===> response.error ===> ${finalResponse.body}");
        handleGlobalErrorInServer(finalResponse);
        return Left(ServerFailure.fromServer(finalResponse));
      }
    } on Exception catch (e) {
      Logger().wtf("$methodName===> crash ===> ${e.toString()}  for  $url");
      if (e.toString().contains('Failed host lookup')) return Left(ServerFailure.noInternet());
      return Left(ServerFailure.crash());
    }
  }

  String getTokenFromLocal() {
    Logger().i("info=> ${GetStorage().read<String>(LocalKeys.tttoken.name)} ");
    return GetStorage().read<String>(LocalKeys.tttoken.name) ?? '';
  }

  @override
  Future<Either<ServerFailure, List<T>>> postListToServer<T>(
      {required String url,
      required params,
      required List<T> Function(List<dynamic> success) mapSuccess,
      bool isTokenNeed = true,
      String? localKey}) async {
    String methodName = "postList";
    if (!await isInternetEnable()) return Left(ServerFailure.noInternet());
    try {
      Logger().v("$methodName===> url ===> $url \n\nbodyParameters ===> $params\n\ndefaultHeader ===> ${getHeader(isTokenNeed)}");
      final response = await client.post(Uri.parse(url), body: params, headers: getHeader(isTokenNeed));
      Logger().d("$methodName===> response.statusCode==> ${response.statusCode}  for  $url");
      if (isSuccessfulHttp(response)) {
        Logger().i("$methodName===>$url response is===>${response.body}");
        if (localKey != null) {
          GetStorage().write(localKey, response.body);
          GetStorage().write("modifyAt-$localKey", DateTime.now().millisecondsSinceEpoch);
        }
        return Right(mapSuccess((jsonDecode(response.body) as List)));
      } else {
        Logger().e("$methodName===> response.error ===> ${response.body}");
        handleGlobalErrorInServer(response);
        return Left(ServerFailure.fromServer(response));
      }
    } on Exception catch (e) {
      Logger().wtf("$methodName===> crash ===> ${e.toString()}  for  $url");
      if (e.toString().contains('Failed host lookup')) return Left(ServerFailure.noInternet());
      return Left(ServerFailure.crash());
    }
  }
// client.post(Uri.parse(url),
// body: params, headers: getHeader(isTokenNeed)),
// params: params,
// url: url,
// isTokenNeed: isTokenNeed,
// methodName: 'post',
}
