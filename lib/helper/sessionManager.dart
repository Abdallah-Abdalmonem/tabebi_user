import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app/routes.dart';
import 'constant.dart';
import 'generalMethods.dart';

class SessionManager {
  static const String isUserLogin = "isuserlogin";
  static const String keyToken = "keytoken";
  static const String keyId = "keyid";
  static const String keyMobileNumber = "keyMobileNumber";
  static const String keyName = "keyName";
  static const String keyEmail = "keyEmail";
  static const String keyFcmToken = "fcmtoken";
  static const String keyUserData = "userdata";

  static const String keyProvinceId = "provinceid";
  static const String keyCityId = "cityid";
  static const String keyProvinceName = "provincename";
  static const String keyCityName = "cityname";
  static const String keyLangId = "selectedlanguageid";
  static const String keyLangName = "selectedlanguagename";
  static const String keyLangCode = "selectedlanguagecode";
  static const String keyLangData = "languagedata";
  static const String langCodeList = "langCodeList";
  static const String countedDrIds = "countedDrIds";
  static const String countedLabIds = "countedLabIds";
  static const String hospitalData = "hospitalData";
  static const String subscribeHospitalData = "subscribeHospitalData";
  static const String specialityData = "specialityData";
  static const String drFavIds = "drFavIds";
  static const String labFavIds = "labFavIds";
  static const String recentDr = "recentDr";
  static const String recentHospital = "recentHospital";
  //static const String recentClinic = "recentClinic";
  //static const String recentCenter = "recentCenter";
  static const String recentLab = "recentLab";

  late SharedPreferences prefs;

  SessionManager({
    required this.prefs,
  });

  String getData(String id) {
    return prefs.getString(id) ?? "";
  }

  setStringListData(String id, List<String> list) {
    prefs.setStringList(id, list);
  }

  List<String> getStringListData(String id) {
    List<String> items = prefs.getStringList(id) ?? [];
    return items;
  }

  void setData(String id, String val) {
    prefs.setString(id, val);
  }

  bool getBoolData(String key) {
    return prefs.getBool(key) ?? false;
  }

  void setBoolData(String key, bool value) {
    prefs.setBool(key, value);
  }

  bool isUserLoggedIn() {
    if (prefs.getBool(isUserLogin) == null) {
      return false;
    } else {
      return prefs.getBool(isUserLogin) ?? false;
    }
  }

  void logoutUser(BuildContext context) async {
    /* try {
      await Api.sendApiRequest(ApiParams.apiDriverLogout,
          {ApiParams.fcmId: getData(keyFcmToken)}, true, context);
    } catch (e) {}*/
    setBoolData(isUserLogin, false);
    setData(keyToken, "");
    setData(keyId, "");
    setData(keyUserData, "");
    setData(keyName, "");
    setData(keyEmail, "");
    Constant.userdata = null;
    GeneralMethods.killPreviousPages(context, Routes.mainPage, args: "logout");
  }

  String getCurrLangCode() {
    String langcode = getData(SessionManager.keyLangCode);
    if (langcode.trim().isEmpty) {
      langcode = GeneralMethods.getDefaultLangCode();
    }
    return langcode;
  }
}
