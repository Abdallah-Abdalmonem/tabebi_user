import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tabebi/app/routes.dart';
import 'package:tabebi/cubits/appointment/labAppointmentCubit.dart';
import 'package:tabebi/helper/colors.dart';
import 'package:tabebi/helper/constant.dart';

import '../../cubits/appointment/drAppointmentCubit.dart';
import '../../helper/apiParams.dart';
import '../../helper/generaWidgets.dart';
import '../../helper/generalMethods.dart';
import '../../helper/stringLables.dart';
import '../mainHome/mainPage.dart';

class AddBookingResponsePage extends StatefulWidget {
  final DateTime? slotDateTime;
  final String? message;
  final String? type;
  const AddBookingResponsePage(
      {Key? key,
      required this.slotDateTime,
      required this.message,
      required this.type})
      : super(key: key);

  @override
  AddBookingResponsePageState createState() => AddBookingResponsePageState();
}

class AddBookingResponsePageState extends State<AddBookingResponsePage> {
  @override
  void initState() {
    super.initState();
    loadAppointment();
  }

  loadAppointment() {
    if (widget.type == Constant.appointmentDoctor) {
      context.read<DoctorAppointmentCubit>().loadPosts(
          context,
          {
            ApiParams.time: ApiParams.current,
            ApiParams.type: Constant.appointmentDoctor
          },
          isSetInitial: true);
    } else {
      context.read<LabAppointmentCubit>().loadPosts(
          context,
          {
            ApiParams.time: ApiParams.current,
            ApiParams.type: Constant.appointmentLab
          },
          isSetInitial: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        //if (widget.type == Constant.appointmentDoctor) {
        print("booktype==>${widget.type}");
        myAppointmentSelectedtype = widget.type!;
        myAppointmentInitialTab = 0;
        GeneralMethods.killPreviousPages(context, Routes.mainPage,
            args: "appointment==${widget.type}");
        return Future.value(false);
        /*} else {
          return Future.value(true);
        }*/
      },
      child: Scaffold(
        appBar: GeneralWidgets.setAppbar(getLables(lblConfirmation), context),
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                getLables(lblSuccessful),
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .apply(color: primaryColor),
              ),
              const SizedBox(height: 15),
              Text(
                  widget
                      .message!, //"Your appointment booking has successfully completed."
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium!),
              const SizedBox(height: 15),
              Text(
                  DateFormat("dd MMM, yyyy EEEE hh:mm a",
                          Constant.session!.getCurrLangCode())
                      .format(widget.slotDateTime!),
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .apply(color: primaryColor)),
            ]),
      ),
    );
  }
}
