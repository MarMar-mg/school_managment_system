// ignore_for_file: constant_identifier_names

import 'package:school_managment_system/commons/utils.dart';
import 'package:url_launcher/url_launcher.dart';

const String FONT_IRAN_SANS = 'iranSans';
const String FONT_IRAN_YEKAN = 'iranYekan';
const LaunchMode launchMode = LaunchMode.platformDefault;

const CRM_BASE_URL = 'https://mehralborz.ac.ir/wp-json/wp/v2/';
 const BASE_URL = 'https://mehralborz.ac.ir/wp-json/wp/v2/';
 const PORTAL_URL = 'https://lcms.mehralborz.ac.ir/webservice/rest/';

 const String BASE_URL_API = BASE_URL;
 const String PORTAL_URL_API = PORTAL_URL;

const String DEFAULT_ERROR = "خطای ناشناخته";


enum LocalKeys {
 ignoreVersion,
 tttoken,
 userInfo,
 users,
 activeUserId,
 activeUserIdd,
 themeMode,
 onBoarding,
}

const NumberLanguageType numberLanguageDefault = NumberLanguageType.persian;

const List<String> monthNames = ["فروردین", "اردیبهشت", "خرداد", "تیر", "مرداد", "شهریور", "مهر", "آبان", "آذر", "دی", "بهمن", "اسفند"];

