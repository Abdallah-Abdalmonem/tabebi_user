import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tabebi/helper/stringLables.dart';
import '../../helper/sessionManager.dart';
import '../app/appLocalization.dart';
import '../models/doctor.dart';
import '../models/hospital.dart';
import '../models/lab.dart';
import '../models/totalExperience.dart';
import '../screens/auth/loginScreen.dart';
import 'colors.dart';
import 'constant.dart';
import 'generaWidgets.dart';

getLables(String labelKey, {BuildContext? context}) {
  return (AppLocalization.of(context ?? Constant.navigatorKey.currentContext!)!
          .getTranslatedValues(labelKey) ??
      labelKey);
}

class GeneralMethods {
  static killPreviousPages(BuildContext context, var nextpage, {var args}) {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(nextpage, (route) => false, arguments: args);
  }

  static goToNextPage(var nextpage, BuildContext bcontext, bool isreplace,
      {var args}) {
    if (isreplace) {
      Navigator.of(bcontext).pushReplacementNamed(nextpage, arguments: args);
    } else {
      Navigator.of(bcontext).pushNamed(nextpage, arguments: args);
    }
  }

  static Future<bool> checkInternet() async {
    bool check = false;

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      check = true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      check = true;
    }
    return true;
  }

  static String getFileSizeString({required int bytes, int decimals = 0}) {
    if (bytes <= 0) return "0 Bytes";
    const suffixes = [" Bytes", "KB", "MB", "GB", "TB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + suffixes[i];
  }

  static showSnackBarMsg(BuildContext? context, String msg,
      {int msgduration = 1, Color? bgcolor, Color? textcolor}) {
    ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
      content: Text(
        msg,
        style: TextStyle(color: textcolor),
      ),
      duration: Duration(seconds: msgduration),
      backgroundColor: bgcolor,
    ));
  }

/*   static getLangCodeList() {
    List<Locale> langcodelist = [];
    List<String> codelist =
        Constant.session!.getStringListData(SessionManager.langCodeList);
    for (int i = 0; i < codelist.length; i++) {
      langcodelist.add(Locale(codelist[i].toLowerCase()));
    }
    if (langcodelist.isEmpty) {
      langcodelist.add(Locale(Constant.defaultLanguageCode));
    }
    print("supported->$langcodelist");

    return langcodelist;
  } */

  static Locale getLocaleFromLanguageCode(String languageCode) {
    if (languageCode.trim().isEmpty) {
      //languageCode = Constant.defaultLanguageCode;
      languageCode = getDefaultLangCode();
    }
    List<String> result = languageCode.split("-");
    return result.length == 1
        ? Locale(result.first)
        : Locale(result.first, result.last);
  }

  static getDefaultLangCode() {
    String langcode = "";
    Locale devicelocal = ui.PlatformDispatcher.instance.locale;
    langcode = devicelocal.languageCode;
    if (langcode != Constant.englishLanguageCode &&
        langcode != Constant.arabicLanguageCode) {
      langcode = Constant.defaultLanguageCode;
    }
    return langcode;
  }

  static Future<bool?> storageCheckpermission() async {
    var status = await Permission.storage.status;
    print("permissionstatus->$status");
    if (status != PermissionStatus.granted) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.photos,
        Permission.videos,
        Permission.audio,
        // Permission.storage,
      ].request();

      print("permissionstatus->//$statuses==");
      /* if (statuses[Permission.storage] == PermissionStatus.granted) {*/
      //final status = await Permission.storage.request();

      if (!statuses.containsValue(PermissionStatus.denied) &&
          !statuses.containsValue(PermissionStatus.permanentlyDenied) &&
          !statuses.containsValue(PermissionStatus.restricted)) {
        // if (status == PermissionStatus.granted) {
        GeneralMethods.fileDirectoryPrepare();
        return true;
      } else {
        return false;
      }
    } else {
      GeneralMethods.fileDirectoryPrepare();
      return true;
    }
    // print("permission==${permissionStatus.toString()}");
  }

  static String datePrefixNum(int number) {
    if (number < 10) {
      return "0$number";
    } else {
      return number.toString();
    }
  }

  static selectDate(BuildContext context,
      {DateTime? selectedDate,
      bool hidePreviousDate = false,
      bool hidenextdate = false}) async {
    selectedDate ??= DateTime.now();

    final DateTime? picked = await showDatePicker(
      locale: getLocalForDatePicker(),
      context: context,
      initialDate: selectedDate,
      firstDate: hidePreviousDate ? DateTime.now() : DateTime(1950),
      lastDate: hidenextdate ? DateTime.now() : DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: primaryColor,
            colorScheme: ColorScheme.light(primary: primaryColor),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    return picked;
  }

  static Locale getLocalForDatePicker() {
    String localcode = Constant.session!.getData(SessionManager.keyLangCode);
    if (localcode.trim().isEmpty) {
      localcode = Constant.defaultLanguageCode;
    }
    return Locale(localcode.toLowerCase());
  }

  static selectTime(
    BuildContext context, {
    TimeOfDay? selectedTime,
  }) async {
    selectedTime = selectedTime ??= TimeOfDay.now();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    return picked;
  }

  static Future<String> fileDirectoryPrepare() async {
    String filepath = "";
    if (Platform.isAndroid) {
      filepath = '/storage/emulated/0/Download/Tabebi';
    } else if (Platform.isIOS) {
      filepath = (await getApplicationDocumentsDirectory()).absolute.path;
    }

    final savedDir = Directory(filepath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    Constant.filePath = filepath;
    return filepath;
  }

  static getTimeInfo(int hours) {
    print("hr->$hours");
    String greeting = "";
    String icon = "";
    if (hours >= 1 && hours < 12) {
      greeting = getLables(lblMorning);
      icon = "morning";
    } else if (hours >= 12 && hours < 16) {
      greeting = getLables(lblAfternoon);
      icon = "afternoon";
    } else if (hours >= 16 && hours < 21) {
      greeting = getLables(lblEvening);
      icon = "evening";
    } else if (hours >= 21 && hours <= 24) {
      greeting = getLables(lblNight);
      icon = "night";
    }
    return {"text": greeting, "icon": icon};
  }

  static openLoginScreen() {
    GeneralWidgets.showBottomSheet(
            context: Constant.navigatorKey.currentContext!,
            btmchild: LoginScreen()
            /*  btmchild: BlocProvider(
        create: (context) => LogInCubit(AuthRepository()),
        child: LoginScreen(),
      ), */
            )
        .then((value) {
      print("islogin->=$value=${Constant.session!.isUserLoggedIn()}");
    });
  }

  static calcExperence(TotalExperience totalExperience) {
    String value = "";
    int years = totalExperience.y!;
    int months = totalExperience.m!;
    int days = totalExperience.d!;

    //int days = totalExperience.d!;
    /*if (years > 0) {
      value = "$value $years ${getLables(lblYears)}";
    }
    if (months > 0) {
      value = "$value $months ${getLables(lblMonths)}";
    } else if (days > 0) {
      value = "$value $days ${getLables(lblDays)}";
    }*/

    value = years.toString();
    if (months > 0) {
      value = "$value.$months";
    }

    if (value == "0" && days > 0) {
      value = "$days ${getLables(lblDays)}";
    } else {
      value = "$value ${getLables(lblYears)}";
    }

    return value;
  }

  static setRecentList() async {
    Constant.recentDrlist = [];
    Constant.recentLablist = [];
    Constant.recentHospitallist = [];
    //Constant.recentCliniclist = [];
    //  Constant.recentCenterlist = [];
    //
    Constant.recentDrlist.addAll(await getRecentList(SessionManager.recentDr));
    Constant.recentLablist
        .addAll(await getRecentList(SessionManager.recentLab));
    Constant.recentHospitallist
        .addAll(await getRecentList(SessionManager.recentHospital));
    /* Constant.recentCliniclist
        .addAll(await getRecentList(SessionManager.recentHospital));
    Constant.recentCenterlist
        .addAll(await getRecentList(SessionManager.recentHospital));*/
  }

  static clearRecentHistory() {
    Constant.session!.setData(SessionManager.recentDr, "");
    Constant.session!.setData(SessionManager.recentHospital, "");
    Constant.session!.setData(SessionManager.recentLab, "");
    Constant.recentDrlist.clear();
    Constant.recentHospitallist.clear();
    Constant.recentLablist.clear();
  }

  static getRecentList(String sessionkey) {
    String list = Constant.session!.getData(sessionkey);
    List data = [];
    if (list.isNotEmpty) {
      data = json.decode(list);
    }
    return data;
  }

  static addRecentData(List listitems, int id, String sessionkey,
      Map<String, dynamic> mapitem) async {
    var existingItem = null;

    for (int i = 0; i < listitems.length; i++) {
      Map<String, dynamic> itemToCheck = listitems[i];
      if (itemToCheck["id"] == id) {
        existingItem = itemToCheck;

        break;
      }
    }

    if (existingItem == null) {
      listitems.add(mapitem);
      Constant.session!.setData(sessionkey, json.encode(listitems));
    }
    return existingItem;
  }
}
