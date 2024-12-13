import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tabebi/models/lab.dart';
import 'package:file_picker/file_picker.dart';
import 'package:tabebi/screens/labAppointment/labListPage.dart';
import '../../app/routes.dart';
import '../../cubits/doctor/bookAppointmentCubit.dart';
import '../../helper/apiParams.dart';
import '../../helper/colors.dart';
import '../../helper/constant.dart';
import '../../helper/dashedRect.dart';
import '../../helper/designConfig.dart';
import '../../helper/generaWidgets.dart';
import '../../helper/generalMethods.dart';
import '../../helper/stringLables.dart';

class ConfirmLabAppointment extends StatefulWidget {
  final Lab? labInfo;
  final DateTime? slotDateTime;
  final String? waitingtime;
  const ConfirmLabAppointment(
      {Key? key,
      required this.slotDateTime,
      required this.labInfo,
      required this.waitingtime})
      : super(key: key);

  @override
  _ConfirmLabAppointmentState createState() => _ConfirmLabAppointmentState();
}

class _ConfirmLabAppointmentState extends State<ConfirmLabAppointment> {
  List<File> attachmentList = [];
  bool isoversize = false;
  TextEditingController edtname = TextEditingController();
  TextEditingController edtcountrycode =
      TextEditingController(text: Constant.defaultCountry.phoneCode);
  TextEditingController edtphonenumber = TextEditingController();
  bool isBookingForOthers = false;
  bool isTestVisible = false;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GeneralWidgets.setAppbar(getLables(lblConfirmation), context),
      bottomNavigationBar: bottomBtnWidget(),
      body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          children: [
            GeneralWidgets.labProfileWidget(
                widget.labInfo!, context, isTestVisible, () {
              setState(() {
                isTestVisible = !isTestVisible;
              });
            }),
            patientDetailWidget(),
            attachementWidget(),
            appointmentDateTimeWidget(),
            appointmentLocation(),
          ]),
    );
  }

  attachementWidget() {
    return Column(
      children: [
        Container(
          height: 150,
          decoration: DesignConfig.boxDecoration(pageBackgroundColor, 10),
          width: double.maxFinite,
          margin: EdgeInsetsDirectional.symmetric(vertical: 10, horizontal: 5),
          child: CustomPaint(
            foregroundPainter:
                DashRectPainter(gap: 8, color: grey, strokeWidth: 1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload,
                  color: primaryColor,
                  size: 50,
                ),
                Text(
                  getLables(attachmentuploadinfo),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(letterSpacing: 0.5),
                ),
                if (Constant.documentSize > 0)
                  Text(
                    "${getLables(docsizetbl)} : ${Constant.documentSize} ${Constant.documentSizeFormat}",
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(letterSpacing: 0.5),
                  ),
                if (Constant.uploadReportTypes.isNotEmpty)
                  Text(
                    "${getLables(doctypestbl)} : ${Constant.uploadReportTypes.join(", ")}",
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(letterSpacing: 0.5),
                  ),
                const SizedBox(height: 8),
                Flexible(
                  child: OutlinedButton(
                      onPressed: () async {
                        FilePickerResult? result;
                        if (Constant.uploadReportTypes.isEmpty) {
                          result = await FilePicker.platform.pickFiles(
                            allowMultiple: true,
                          );
                        } else {
                          result = await FilePicker.platform.pickFiles(
                              allowMultiple: true,
                              type: FileType.custom,
                              allowedExtensions: Constant.uploadReportTypes);
                        }
                        if (result != null) {
                          List<File> files =
                              result.paths.map((path) => File(path!)).toList();
                          attachmentList.addAll(files);
                          isoversize = false;
                          setState(() {});
                        }
                      },
                      style: OutlinedButton.styleFrom(
                          shape: DesignConfig.setRoundedBorder(20, true)),
                      child: Text(getLables(lblUploadAttachment))),
                ),
              ],
            ),
          ),
        ),
        if (attachmentList.isNotEmpty)
          GeneralWidgets.cardBoxWidget(
            cpadding:
                EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 12),
            childWidget: Wrap(
              children: List.generate(attachmentList.length, (index) {
                if (index == 0) {
                  isoversize = false;
                }

                String filesize = GeneralMethods.getFileSizeString(
                        bytes: attachmentList[index].lengthSync())
                    .toLowerCase();
                bool isfileoversize = false;
                if (Constant.documentSize > 0 &&
                    filesize
                        .contains(Constant.documentSizeFormat.toLowerCase())) {
                  double filelen = double.parse(filesize.replaceAll(
                      Constant.documentSizeFormat.toLowerCase(), ""));

                  if (filelen > Constant.documentSize) {
                    isfileoversize = true;
                    isoversize = true;
                  }
                }
                return Row(
                  children: [
                    const SizedBox(width: 8),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          attachmentList[index].path.split("/").last,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          filesize,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .apply(color: isfileoversize ? redcolor : grey),
                        ),
                      ],
                    )),
                    IconButton(
                        onPressed: () {
                          isoversize = false;
                          setState(() {
                            attachmentList.removeAt(index);
                          });
                        },
                        icon: Icon(
                          Icons.clear,
                          color: primaryColor,
                        )),
                  ],
                );
              }),
            ),
          )
      ],
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
                  "type": Constant.appointmentLab,
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

  appointmentLocation() {
    return GeneralWidgets.cardBoxWidget(
        cpadding: EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 15),
        childWidget: Column(children: [
          headerWidget(getLables(lblAppointmentLocation), Icons.location_on),
          const SizedBox(height: 10),
          textFieldWidget(
              TextEditingController(text: widget.labInfo!.labAddress), "", "",
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

  bookingProcess() {
    /* if (attachmentList.isEmpty) {
      GeneralMethods.showSnackBarMsg(context, getLables(reportUploadInfo));
      return;
    } */
    if (attachmentList.isNotEmpty && isoversize) {
      GeneralMethods.showSnackBarMsg(context,
          "${getLables(docsizetbl)} : ${Constant.documentSize} ${Constant.documentSizeFormat}");
      return;
    }
    if (Constant.session!.isUserLoggedIn()) {
      Map<String, String> parameter = {
        ApiParams.doctorId: widget.labInfo!.id!.toString(),
        ApiParams.date: Constant.backendDateFormat.format(widget.slotDateTime!),
        ApiParams.time: DateFormat("HH:mm").format(widget.slotDateTime!),
        ApiParams.behalfOf: isBookingForOthers ? "1" : "0",
        ApiParams.type: Constant.appointmentLab,
        ApiParams.testId: selectedTestIds.keys.join(","),
        ApiParams.waitingTime: widget.waitingtime!,
      };
      if (isBookingForOthers) {
        parameter[ApiParams.name] = edtname.text;
        parameter[ApiParams.phone] = edtphonenumber.text;
      }
      Map<String, String> filelist = {};
      for (int i = 0; i < attachmentList.length; i++) {
        print("filelent->===$i==${attachmentList[i].path}");
        filelist["0$i==${ApiParams.file}=="] = attachmentList[i].path;
      }
      context
          .read<BookAppointmentCubit>()
          .bookAppointment(context, parameter, filelist: filelist);
    } else {
      GeneralMethods.openLoginScreen();
    }
  }
}
