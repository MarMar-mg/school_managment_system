import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:get_storage/get_storage.dart';
import 'package:school_managment_system/commons/data/model/json_parser.dart';

enum RemoteConfigItems {
  aboutUsDescription,
  aboutUsSubTitle,
  aboutUsTitle,
  chatEmptyError,
  chatTextHint,
  contactUsPhoneNumber,
  errorLimitKidDescription,
  errorLimitKidTitle,
  errorNoInternetTitle,
  evaluationIntroductionTitle,
  evaluationIntroductionVideoUrl,
  evaluationIntroductionThumbnailUrl,
  feedbackUserGuide,
  signQuizIntroductionTitle,
  signQuizIntroductionVideoUrl,
  signQuizIntroductionThumbnailUrl,
  faqListDescription,
  faqListTitle,
  jobRequestDescription,
  jobRequestPhoneNumber,
  jobRequestTitle,
  justOneElixirWarningStart,
  justOneElixirWarningEnd,
  loginBeforeFillQuizInElixir,
  mainPageIntroductionButton,
  mainPageIntroductionTitle,
  middleSignUpDescription,
  middleSignUpTitle,
  onBoardingDescriptions,
  onBoardingTitles,
  oneElixirIsAlreadyActive,
  operatorPhoneNumber,
  otpSubTitle,
  quizEvaluationDescriptionError,
  quizEvaluationTitleError,
  refundDescription,
  refundPhoneNumber,
  refundTitle,
  splashScreenSubtitle,
  subscriptionDescription,
  subscriptionFeatures1,
  subscriptionFeatures2,
  subscriptionTitle,
  termOfService,
}

void saveRemoteConfigToLocal(Map<String, dynamic> remoteConfigJson) {
  GetStorage().write('remoteConfigText', jsonEncode(remoteConfigJson));
}

String loadRemoteConfigItem(RemoteConfigItems remoteConfigItems) {
  if (!hasRemoteConfigInLocal()) {
    return '';
  }
  final items = JsonParser.listParser(jsonDecode(GetStorage().read<String>('remoteConfigText')!), ['items']);
  final text = JsonParser.stringParser(
      items.firstWhereOrNull((element) => JsonParser.stringParser(element, ['key']) == remoteConfigItems.name), ['value']);
  // if (GetIt.instance<LoginApi>().getActiveKid() != null) {
  //   return text
  //       .replaceAll('آرمیتا', GetIt.instance<LoginApi>().getActiveKid()!.name)
  //       .replaceAll('ارمیتا', GetIt.instance<LoginApi>().getActiveKid()!.name);
  // }
  return text;
}

bool hasRemoteConfigInLocal() {
  return GetStorage().hasData('remoteConfigText');
}
