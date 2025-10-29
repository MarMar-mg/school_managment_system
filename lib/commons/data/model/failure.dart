import 'package:equatable/equatable.dart';
import 'package:school_managment_system/commons/failures.dart';



class Failure extends Equatable {
  final FailureType failureType;
  final String message;

  Failure(String message, {this.failureType = FailureType.other}) : message = convertMessageToPersian(message);

  factory Failure.notRegistered() {
    return Failure("ابتدا وارد شوید", failureType: FailureType.authentication);
  }

  factory Failure.build(String message, {FailureType failureType = FailureType.authentication}) {
    return Failure(convertMessageToPersian(message), failureType: failureType);
  }

  @override
  List<Object> get props => [message, failureType.toString()];
}

String convertMessageToPersian(String message) {
  switch (message.trim()) {
    case 'Invalid login credentials':
      return "نام کاربری یا کلمه عبور اشتباه است";
    case 'Email not confirmed':
      return "ایمیل شما هنوز تایید نشده";
    case 'HandshakeException: Connection terminated during handshake':
    case 'XMLHttpRequest error.':
      return "ظاهرا شما به اینترنت متصل نیستید";
    default:
      return message;
  }
}

