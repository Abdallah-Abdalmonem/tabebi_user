import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tabebi/helper/generaWidgets.dart';
import 'package:tabebi/helper/generalMethods.dart';
import 'package:tabebi/helper/sessionManager.dart';
import 'package:tabebi/helper/stringLables.dart';

import '../../app/routes.dart';
import '../../helper/api.dart';
import '../../helper/apiParams.dart';
import '../../helper/colors.dart';
import '../../helper/constant.dart';
import '../../models/userdata.dart';
import 'changeLanguageWidget.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  SettingPageState createState() => SettingPageState();
}

class SettingPageState extends State<SettingPage> {
  bool isNotificationEnable =
      Constant.userdata == null ? false : Constant.userdata!.notification == 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GeneralWidgets.setAppbar(getLables(lblSettings), context),
      body: ListView(
          padding:
              EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 15),
          children: [
            GeneralWidgets.setListtileMenu(getLables(lblChangeName), context,
                tilecolor: pageBackgroundColor, onClickAction: () {
              GeneralMethods.goToNextPage(
                  Routes.editProfilePage, context, false,args: false);
            }, leadingwidget: GeneralWidgets.setSvg("st_name", width: 20)),
            Divider(),
            GeneralWidgets.setListtileMenu(
                getLables(lblChangeLanguage), context,
                tilecolor: pageBackgroundColor, onClickAction: () {
              GeneralWidgets.showBottomSheet(
                  btmchild: const ChangeLanguageWidget(), context: context);
            }, leadingwidget: GeneralWidgets.setSvg("st_language", width: 20)),
            if (Constant.session!.isUserLoggedIn()) Divider(),
            if (Constant.session!.isUserLoggedIn())
              GeneralWidgets.setListtileMenu(
                  getLables(lblNotifications), context,
                  tilecolor: pageBackgroundColor, onClickAction: () {
                changeNotificationStatusProcess(!isNotificationEnable);
              },
                  leadingwidget:
                      GeneralWidgets.setSvg("st_notification", width: 20),
                  trailingwidget: GeneralWidgets.setSvg(
                      isNotificationEnable ? "toggleOn" : "toggleOff",
                      imgColor: isNotificationEnable ? primaryColor : grey,
                      height: 40,
                      width: 40)
                  /* trailingwidget: Icon(
                  isNotificationEnable ? Icons.toggle_on : Icons.toggle_off,
                  size: 45,
                  color: isNotificationEnable ? primaryColor : grey,
                ) */
                  ),
          ]),
    );
  }

  changeNotificationStatusProcess(bool enable) async {
    bool checkinternet = await GeneralMethods.checkInternet();
    if (!checkinternet) {
      GeneralMethods.showSnackBarMsg(
          context, getLables(noInternetErrorMessage));
      return;
    }

    Map<String, String> parameter = {
      ApiParams.notification: enable ? "1" : "0",
    };
    try {
      GeneralWidgets.showLoader(context);
      var response = await Api.sendApiRequest(
          ApiParams.apiUpdateProfile, parameter, true, context);
      GeneralWidgets.hideLoder(context);
      final getdata = json.decode(response);
      GeneralMethods.showSnackBarMsg(context, getdata[ApiParams.message]);

      if (!getdata[ApiParams.error]) {
        Constant.userdata = UserData.fromJson(getdata["data"]);
        Constant.session!
            .setData(SessionManager.keyUserData, Constant.userdata!.toJson());
        setState(() {
          isNotificationEnable = Constant.userdata == null
              ? false
              : Constant.userdata!.notification == 1;
        });
      }
    } catch (e) {
      GeneralWidgets.hideLoder(context);
    }
  }
}
