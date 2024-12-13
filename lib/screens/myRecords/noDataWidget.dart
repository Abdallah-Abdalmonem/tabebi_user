import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../helper/colors.dart';
import '../../helper/constant.dart';
import '../../helper/generaWidgets.dart';
import '../../helper/generalMethods.dart';
import '../../helper/stringLables.dart';

noDataWidget(bool isMyReportpage, BuildContext context, Function? goToAddReport,
    Function? loadPage) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GeneralWidgets.setSvg("filesImage"),
        const SizedBox(
          height: 10,
        ),
        Text(
          getLables(isMyReportpage ? lblAddReportTitle : lblConsultDoctorTitle),
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .apply(color: primaryColor),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
            getLables(isMyReportpage
                ? lblAddReportSubTitle
                : lblConsultDoctorSubTitle),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall!.apply(color: grey)),
        const SizedBox(
          height: 20,
        ),
        GeneralWidgets.btnWidget(
          context,
          getLables(!Constant.session!.isUserLoggedIn()
              ? lblLogin
              : isMyReportpage
                  ? lblAddReports
                  : lblConsultDoctor),
          bwidth: MediaQuery.of(context).size.width / 1.5,
          callback: () {
            if (Constant.session!.isUserLoggedIn()) {
              if (isMyReportpage) {
                goToAddReport!();
              } else {
                GeneralMethods.goToNextPage(
                    Routes.specialitylistpage, context, false);
              }
            } else {
              GeneralMethods.openLoginScreen();
            }
          },
        ),
        if (Constant.session!.isUserLoggedIn())
          TextButton(
              onPressed: () {
                loadPage!(isSetInitial: true);
              },
              child: Text(
                getLables(lblTryAgain),
                style: TextStyle(decoration: TextDecoration.underline),
              ))
      ],
    ),
  );
}
