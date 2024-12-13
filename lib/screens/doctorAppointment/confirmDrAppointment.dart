import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tabebi/app/routes.dart';
import 'package:tabebi/cubits/doctor/bookAppointmentCubit.dart';
import 'package:tabebi/helper/apiParams.dart';
import 'package:tabebi/helper/designConfig.dart';
import 'package:tabebi/helper/generaWidgets.dart';
import 'package:tabebi/helper/generalMethods.dart';
import '../../helper/colors.dart';
import '../../helper/constant.dart';
import '../../helper/stringLables.dart';
import '../../models/doctor.dart';

class ConfirmDrAppointment extends StatefulWidget {
  final Doctor? doctorInfo;
  final DateTime? slotDateTime;
  final String? waitingtime;

  const ConfirmDrAppointment(
      {Key? key,
      required this.doctorInfo,
      required this.slotDateTime,
      required this.waitingtime})
      : super(key: key);

  @override
  ConfirmDrAppointmentState createState() => ConfirmDrAppointmentState();
}

class ConfirmDrAppointmentState extends State<ConfirmDrAppointment> {
  TextEditingController edtname = TextEditingController();
  TextEditingController edtcountrycode =
      TextEditingController(text: Constant.defaultCountry.phoneCode);
  TextEditingController edtphonenumber = TextEditingController();
  bool isBookingForOthers = false;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GeneralWidgets.setAppbar(getLables(lblConfirmation), context),
      bottomNavigationBar: bottomBtnWidget(),
      body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          children: [
            drProfileWidget(),
            patientDetailWidget(),
            appointmentDateTimeWidget(),
            appointmentLocation(),
          ]),
    );
  }

  bottomBtnWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: lightGrey, //New
              blurRadius: 25.0,
              offset: Offset(0, -10))
        ],
      ),
      child: BlocConsumer<BookAppointmentCubit, BookAppointmentState>(
        listener: (context, state) {
          if (state is BookAppointmentSuccess) {
            GeneralMethods.goToNextPage(
                Routes.bookingResponsePage, context, true,
                args: {
                  "message": state.message,
                  "type": Constant.appointmentDoctor,
                  "slotDateTime": widget.slotDateTime
                });
          } else if (state is BookAppointmentFailure) {
            GeneralMethods.showSnackBarMsg(context, state.errorMessage,
                msgduration: 3);
          }
        },
        builder: (context, state) {
          if (state is BookAppointmentProgress) {
            return Container(
                height: 45,
                alignment: AlignmentDirectional.center,
                child: CircularProgressIndicator());
          } else {
            return GeneralWidgets.btnWidget(
                context, getLables(lblConfirmBooking), callback: () {
              if (_formKey.currentState!.validate()) {
                bookingProcess();
              }
            });
          }
        },
      ),
    );
  }

  bookingProcess() {
    if (Constant.session!.isUserLoggedIn()) {
      Map<String, String> parameter = {
        ApiParams.doctorId: widget.doctorInfo!.id!.toString(),
        ApiParams.date: Constant.backendDateFormat.format(widget.slotDateTime!),
        ApiParams.time: DateFormat("HH:mm").format(widget.slotDateTime!),
        //ApiParams.fees: widget.doctorInfo!.drFees!,
        ApiParams.behalfOf: isBookingForOthers ? "1" : "0",
        ApiParams.type: Constant.appointmentDoctor,
        ApiParams.waitingTime: widget.waitingtime!,
      };
      if (isBookingForOthers) {
        parameter[ApiParams.name] = edtname.text;
        parameter[ApiParams.phone] = edtphonenumber.text;
      }
      context.read<BookAppointmentCubit>().bookAppointment(context, parameter);
    } else {
      GeneralMethods.openLoginScreen();
      /*   GeneralWidgets.showBottomSheet(
        context: Constant.navigatorKey.currentContext!,
        btmchild: BlocProvider(
          create: (context) => LogInCubit(AuthRepository()),
          child: LoginScreen(),
        ),
      ).then((value) {
        print("islogin->=$value=${Constant.session!.isUserLoggedIn()}");
      }); */
    }
  }

  appointmentLocation() {
    return GeneralWidgets.cardBoxWidget(
        cpadding: EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 15),
        childWidget: Column(children: [
          headerWidget(getLables(lblAppointmentLocation), Icons.location_on),
          const SizedBox(height: 10),
          textFieldWidget(
              TextEditingController(text: widget.doctorInfo!.hospital!.address),
              "",
              "",
              isReadonly: true)
        ]));
  }

  appointmentDateTimeWidget() {
    return GeneralWidgets.cardBoxWidget(
        cpadding: EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 15),
        childWidget: Column(children: [
          headerWidget(getLables(lblAppointmentDateTime), Icons.schedule),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
                child: textFieldWidget(
                    TextEditingController(
                        text: Constant.timeFormatter
                            .format(widget.slotDateTime!)),
                    "",
                    "",
                    isReadonly: true)),
            const SizedBox(width: 8),
            Expanded(
                child: textFieldWidget(
                    TextEditingController(
                        text: DateFormat('d MMM, EEEE',
                                Constant.session!.getCurrLangCode())
                            .format(widget.slotDateTime!)),
                    "",
                    "",
                    isReadonly: true)),
          ]),
        ]));
  }

  patientDetailWidget() {
    return Form(
        key: _formKey,
        child: GeneralWidgets.cardBoxWidget(
            cpadding:
                EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 15),
            childWidget: Column(
              children: [
                headerWidget(getLables(lblPatientDetails), Icons.person),
                const SizedBox(height: 10),
                textFieldWidget(
                    edtname, getLables(lblFullName), getLables(lblFullName)),
                const SizedBox(height: 5),
                Row(children: [
                  Expanded(
                      flex: 1,
                      child: textFieldWidget(edtcountrycode,
                          Constant.defaultCountry.countryCode, "")),
                  const SizedBox(width: 8),
                  Expanded(
                      flex: 3,
                      child: textFieldWidget(edtphonenumber,
                          getLables(lblPhonenumber), getLables(lblPhonenumber),
                          textInputType: TextInputType.phone)),
                ]),
                CheckboxListTile(
                  value: isBookingForOthers,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    getLables(lblBookBehalf),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  contentPadding: EdgeInsets.zero,
                  activeColor: primaryColor,
                  checkboxShape: DesignConfig.setRoundedBorder(5, false),
                  dense: true,
                  onChanged: (value) {
                    setState(() {
                      isBookingForOthers = value!;
                    });
                  },
                )
              ],
            )));
  }

  textFieldWidget(
      TextEditingController editingController, String lbl, String errmsg,
      {bool isReadonly = false,
      TextInputType? textInputType = TextInputType.text}) {
    return GeneralWidgets.cardBoxWidget(
      celevation: 0,
      cardcolor: lightBg,
      childWidget: GeneralWidgets.textFieldWidget(context, editingController,
          isReadonly: isReadonly,
          keyboardtyp: textInputType,
          isSetValidator: isBookingForOthers,
          errmsg: errmsg,
          textStyle: Theme.of(context).textTheme.bodyMedium,
          inputDecoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 15),
            border: InputBorder.none,
            fillColor: lightBg,
            hintText: lbl,
            hintStyle: TextStyle(color: grey),
            filled: true,
          )),
    );
  }

  headerWidget(String header, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: primaryColor),
        const SizedBox(width: 10),
        Text(
          header,
          style: Theme.of(context).textTheme.titleMedium!.merge(
              TextStyle(fontWeight: FontWeight.w500, letterSpacing: 0.5)),
        ),
      ],
    );
  }

  drProfileWidget() {
    return GeneralWidgets.cardBoxWidget(
      cpadding: EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 8),
      childWidget: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GeneralWidgets.circularImage(widget.doctorInfo!.image,
            height: 60, width: 60),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Constant.session!.getCurrLangCode() ==
                          Constant.arabicLanguageCode
                      ? widget.doctorInfo!.nameAr!
                      : widget.doctorInfo!.nameEng!,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .merge(TextStyle(fontWeight: FontWeight.normal)),
                ),
                const SizedBox(height: 5),
                Text(
                  Constant.session!.getCurrLangCode() ==
                          Constant.arabicLanguageCode
                      ? widget.doctorInfo!.drInfoAr!
                      : widget.doctorInfo!.drInfoEng!,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .apply(color: grey),
                ),
                const SizedBox(height: 8),
                RichText(
                    text: TextSpan(
                        text: "${getLables(lblFees)}:\t\t\t\t\t",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .apply(color: grey),
                        children: [
                      TextSpan(
                        text:
                            "${widget.doctorInfo!.drFees!} ${Constant.currencyCode}",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: primaryColor, fontWeight: FontWeight.w500),
                      ),
                    ]))
              ]),
        )
      ]),
    );
  }
}
