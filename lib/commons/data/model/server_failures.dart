import 'package:school_managment_system/commons/failures.dart';
import 'package:http/http.dart';
import 'package:school_managment_system/applications/parse_error_message.dart';

const int AUTHENTICATION_IS_WRONG_STATUS_CODE = 401;
const int FORBIDDEN_STATUS_CODE = 403;

class ServerFailure extends FailureForCustom {
  final int statusCode;

  ServerFailure(Response response)
      : statusCode = response.statusCode,
        super(message: parseErrorMessage(response.body), failureType: FailureType.serverError);

  factory ServerFailure.fromServer(Response response) {
    if (response.statusCode == 504) return ServerFailure.badVpn();
    if (response.statusCode >= 500) return ServerFailure.somethingWentWrong();
    if (response.statusCode == AUTHENTICATION_IS_WRONG_STATUS_CODE) return ServerFailure.notLoggedInYet();
    if (response.statusCode == FORBIDDEN_STATUS_CODE) return ServerFailure.notPermission();
    return ServerFailure(response);
  }

  ServerFailure.noInternet()
      : statusCode = -1,
        super(message: "شما به اینترنت متصل نیستید", failureType: FailureType.noInternet);

  ServerFailure.badVpn()
      : statusCode = -1,
        super(message: "دسترسی به اینترنت ندارید در صورت روشن بودن فیلتر شکن آن را خاموش کنید", failureType: FailureType.noInternet);

  ServerFailure.crash()
      : statusCode = -1,
        super(message: "از اتصال دستگاه به اینترنت مطمئن شوید", failureType: FailureType.somethingWentWrong);

  ServerFailure.notPermission()
      : statusCode = -71,
        super(message: "شما دسترسی به این محتوا ندارید", failureType: FailureType.somethingWentWrong);

  ServerFailure.notLoggedInYet()
      : statusCode = AUTHENTICATION_IS_WRONG_STATUS_CODE,
        super(message: "لطفا ابتدا وارد شوید", failureType: FailureType.authentication);

  ServerFailure.somethingWentWrong()
      : statusCode = -2,
        super(message: "بروز مشکل ناشناخته در سرور", failureType: FailureType.somethingWentWrong);
}
