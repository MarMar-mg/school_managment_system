import 'package:equatable/equatable.dart';
import 'package:http/http.dart';
import 'package:school_managment_system/applications/parse_error_message.dart';
import 'package:school_managment_system/applications/remote_config_text.dart';

enum FailureType {
  noInternet,
  authentication,
  wrongInput,
  forbidden,
  serverError,
  somethingWentWrong,
  attachTooLong,
  other;
}

class FailureForCustom extends Equatable {
  final FailureType failureType;
  final String iconUrl;
  final String? bigImageUrl;
  final String message;
  final String? description;
  final String buttonText;
  final int? statusCode;
  final String? navigatePathAfterSubmit;
  final bool isClientGuilty;

  const FailureForCustom({
    required this.failureType,
    required this.message,
    this.buttonText = "",
    this.iconUrl = "",
    this.isClientGuilty = false,
    this.navigatePathAfterSubmit,
    this.bigImageUrl,
    this.description,
    this.statusCode,
  });

  factory FailureForCustom.serverFailure(Response response) {
    if (response.statusCode == 504) return badVpnFailure;
    if (response.statusCode == 502) return UpdateServerFailure;
    if (response.statusCode == 401) return notRegisteredFailure;
    if (response.statusCode == 403) return accessDeniedFailure;
    if (response.statusCode >= 500 || response.statusCode >= 404) {
      return FailureForCustom.simpleResponse(
          "بروز مشکل ناشناخته", response.statusCode, false);
    }
    return FailureForCustom.simpleResponse(
        parseErrorMessage(response.body), response.statusCode, true);
  }

  factory FailureForCustom.serverCrash(Exception exception) {
    if (exception.toString().contains('Failed host lookup'))
      return noNetFailure;
    return FailureForCustom.simpleResponse(
        "از بروز بودن نرم افزار اطمینان حاصل کنید", -1, true);
  }

  factory FailureForCustom.simpleResponse(
      String message, int statusCode, bool isClientGuilty) {
    return FailureForCustom(
      failureType: FailureType.other,
      message: message,
      buttonText: "تلاش مجدد",
      iconUrl: 'icons/error.svg',
      statusCode: statusCode,
      isClientGuilty: isClientGuilty,
    );
  }

  factory FailureForCustom.fromMessage(String message) {
    return FailureForCustom(
      failureType: FailureType.other,
      message: message,
      buttonText: "تلاش مجدد",
      iconUrl: 'icons/error.svg',
      isClientGuilty: true,
    );
  }

  @override
  List<Object> get props => [message];
}

const notRegisteredFailure = FailureForCustom(
  failureType: FailureType.authentication,
  message: "ابتدا وارد شوید",
  buttonText: "ورود مجدد",
  navigatePathAfterSubmit: '/login',
  iconUrl: 'icons/person.svg',
  statusCode: 401,
  isClientGuilty: true,
);

const accessDeniedFailure = FailureForCustom(
  failureType: FailureType.forbidden,
  message: "شما دسترسی به این محتوا ندارید",
  buttonText: "تلاش مجدد",
  iconUrl: 'icons/lock_access.svg',
  statusCode: 403,
  isClientGuilty: true,
);

const attachIsToLargeFailure = FailureForCustom(
  failureType: FailureType.attachTooLong,
  message: "حجم فایل بالاست",
  buttonText: "تلاش مجدد",
  iconUrl: 'icons/attachment.svg',
  isClientGuilty: true,
);

final badVpnFailure = FailureForCustom(
  failureType: FailureType.noInternet,
  message: loadRemoteConfigItem(RemoteConfigItems.errorNoInternetTitle),
  buttonText: "تلاش مجدد",
  iconUrl: 'icons/internet.svg',
  isClientGuilty: true,
);

const UpdateServerFailure = FailureForCustom(
  failureType: FailureType.other,
  message: "سرور در حال به روز رسانی است",
  buttonText: "تلاش مجدد",
  iconUrl: 'icons/update.svg',
  isClientGuilty: false,
);

final noNetFailure = FailureForCustom(
  failureType: FailureType.noInternet,
  message: loadRemoteConfigItem(RemoteConfigItems.errorNoInternetTitle),
  buttonText: "تلاش مجدد",
  iconUrl: 'icons/internet.svg',
  isClientGuilty: true,
);
