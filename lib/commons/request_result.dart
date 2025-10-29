import 'package:dartz/dartz.dart';
import 'failures.dart';

class RequestResult {
  final bool isSuccess;
  final FailureForCustom? failure;

  const RequestResult({required this.isSuccess, required this.failure});

  factory RequestResult.success() => const RequestResult(isSuccess: true, failure: null);

  factory RequestResult.failure(FailureForCustom failure) => RequestResult(isSuccess: false, failure: failure);

  factory RequestResult.fromEither(Either<FailureForCustom, dynamic> input) => input.fold((l) => RequestResult.failure(l), (r) => RequestResult.success());

  void fold(void Function(FailureForCustom failure) failure, void Function() success) {
    if (isSuccess) {
      return success();
    } else {
      return failure(this.failure!);
    }
  }
}
