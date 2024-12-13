import 'package:flutter/material.dart';
import 'package:tabebi/helper/constant.dart';
import 'package:tabebi/helper/generaWidgets.dart';
import 'package:tabebi/helper/generalMethods.dart';
import '../../app/routes.dart';
import '../../cubits/appointment/drAppointmentCubit.dart';
import '../../cubits/appointment/labAppointmentCubit.dart';
import '../../helper/colors.dart';
import '../../helper/designConfig.dart';
import '../../helper/stringLables.dart';

class NoAppointmentWidget extends StatelessWidget {
  final Map<String, String>? apiparams;
  final DoctorAppointmentCubit? doctorAppointmentCubit;
  final LabAppointmentCubit? labAppointmentCubit;
  const NoAppointmentWidget(
      {Key? key,
      this.apiparams,
      this.doctorAppointmentCubit,
      this.labAppointmentCubit})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GeneralWidgets.setSvg("noAppointment"),
          Text(
            getLables(lblNoAppointments),
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .apply(color: primaryColor),
          ),
          const SizedBox(
            height: 20,
          ),
          OutlinedButton(
            child: Text(
              getLables(
                  Constant.session!.isUserLoggedIn() ? lblBookNow : lblLogin),
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsetsDirectional.symmetric(horizontal: 5),
              shape: DesignConfig.setRoundedBorder(5, false),
              side: BorderSide(color: primaryColor),
              fixedSize: Size(MediaQuery.of(context).size.width / 2, 45.0),
            ),
            onPressed: () {
              if (Constant.session!.isUserLoggedIn()) {
                if (doctorAppointmentCubit != null) {
                  GeneralMethods.goToNextPage(
                      Routes.specialitylistpage, context, false);
                } else if (labAppointmentCubit != null) {
                  GeneralMethods.goToNextPage(
                      Routes.lablistpage, context, false);
                }
              } else {
                GeneralMethods.openLoginScreen();
              }
            },
          ),
          if (Constant.session!.isUserLoggedIn())
            TextButton(
                onPressed: () {
                  if (doctorAppointmentCubit != null) {
                    doctorAppointmentCubit!
                        .loadPosts(context, apiparams!, isSetInitial: true);
                  } else if (labAppointmentCubit != null) {
                    labAppointmentCubit!
                        .loadPosts(context, apiparams!, isSetInitial: true);
                  }
                },
                child: Text(
                  getLables(lblTryAgain),
                  style: TextStyle(decoration: TextDecoration.underline),
                ))
        ],
      ),
    );
  }
}
