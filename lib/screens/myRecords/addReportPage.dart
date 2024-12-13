import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tabebi/helper/constant.dart';
import 'package:tabebi/helper/generaWidgets.dart';
import 'package:tabebi/helper/generalMethods.dart';
import 'package:tabebi/helper/stringLables.dart';
import 'package:tabebi/models/myRecord.dart';
import '../../cubits/myRecordCubit.dart';
import '../../helper/api.dart';
import '../../helper/apiParams.dart';
import '../../helper/colors.dart';
import '../../helper/dashedRect.dart';
import '../../helper/designConfig.dart';

class AddReportPage extends StatefulWidget {
  final MyRecordCubit? myRecordCubit;
  const AddReportPage({Key? key, required this.myRecordCubit})
      : super(key: key);

  @override
  AddReportPageState createState() => AddReportPageState();
}

class AddReportPageState extends State<AddReportPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController edttitle = TextEditingController();
  TextEditingController edtDate = TextEditingController();
  TextEditingController edtTime = TextEditingController();
  TextEditingController edtDrName = TextEditingController();
  TextEditingController edtPatientName = TextEditingController();
  TextEditingController edtNotes = TextEditingController();
  DateTime? reportDateTime;
  List<File> attachmentList = [];
  bool isMyReport = false;
  bool isoversize = false;
  String backenddate = "", backendtime = "";
  @override
  void initState() {
    super.initState();
    reportDateTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GeneralWidgets.setAppbar(getLables(lblAddReports), context),
      body: ListView(
          padding:
              EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 10),
          children: [
            formWidgets(),
            uploadFileWidget(),
            const SizedBox(height: 20),
            GeneralWidgets.btnWidget(context, getLables(lblAddReports),
                callback: () => addReportProcess())
          ]),
    );
  }

  addReportProcess() {
    if (_formKey.currentState!.validate()) {
      if (attachmentList.isEmpty) {
        GeneralMethods.showSnackBarMsg(context, getLables(reportUploadInfo));
        return;
      }
      if (isoversize) {
        GeneralMethods.showSnackBarMsg(context,
            "${getLables(docsizetbl)} : ${Constant.documentSize} ${Constant.documentSizeFormat}");
        return;
      }
      Map<String, String> filelist = {};
      for (int i = 0; i < attachmentList.length; i++) {
        print("filelent->===$i==${attachmentList[i].path}");
        filelist["0$i==${ApiParams.file}=="] = attachmentList[i].path;
      }
      Map<String, String> parameter = {
        ApiParams.apiType: ApiParams.set,
        ApiParams.title: edttitle.text,
        ApiParams.date: backenddate,
        ApiParams.time: backendtime,
        ApiParams.name: isMyReport ? "" : edtPatientName.text,
        ApiParams.doctorName: edtDrName.text,
        ApiParams.note: edtNotes.text,
      };
      updateReportInfo(widget.myRecordCubit, context, parameter, filelist);
    }
  }

  static Future updateReportInfo(
      MyRecordCubit? myRecordCubit,
      BuildContext context,
      Map<String, String?> parameter,
      Map<String, String> filelist,
      {int? removeindex}) async {
    bool checkinternet = await GeneralMethods.checkInternet();
    if (!checkinternet) {
      GeneralMethods.showSnackBarMsg(
          context, getLables(noInternetErrorMessage));
    } else {
      GeneralWidgets.showLoader(context);
      var response;
      print("filelent->=filelist===******=${filelist.length}");
      if (filelist.isNotEmpty) {
        response = await Api.postApiFile(
            ApiParams.apiReport, filelist, context, parameter);
      } else {
        response = await Api.sendApiRequest(
            ApiParams.apiReport, parameter, true, context);
      }
      if (response == null) {
        GeneralMethods.showSnackBarMsg(
            context, getLables(dataNotFoundErrorMessage));
        return;
      }
      var getdata = json.decode(response);
      GeneralMethods.showSnackBarMsg(context, getdata["message"]);
      if (!getdata["error"] && myRecordCubit != null) {
        if (removeindex == null) {
          MyRecord myRecord = MyRecord.fromMap(getdata["data"]);

          myRecordCubit.setReportItem(recordData: myRecord);

          Future.delayed(Duration(milliseconds: 700), () {
            Navigator.of(context).pop();
          });
        } else {
          myRecordCubit.setReportItem(removeindex: removeindex);
        }
      }
      GeneralWidgets.hideLoder(context);
      return response;
    }
  }

  uploadFileWidget() {
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
                  getLables(reportUploadInfo),
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
                        // FilePickerResult? result;
                        // if (Constant.uploadReportTypes.isEmpty) {
                        //   result = await FilePicker.platform.pickFiles(
                        //     allowMultiple: true,
                        //   );
                        // } else {
                        //   result = await FilePicker.platform.pickFiles(
                        //       allowMultiple: true,
                        //       type: FileType.custom,
                        //       allowedExtensions: Constant.uploadReportTypes);
                        // }
                        //
                        // if (result != null) {
                        //   List<File> files =
                        //       result.paths.map((path) => File(path!)).toList();
                        //   attachmentList.addAll(files);
                        //   isoversize = false;
                        //   setState(() {});
                        // }
                      },
                      style: OutlinedButton.styleFrom(
                          shape: DesignConfig.setRoundedBorder(20, true)),
                      child: Text(getLables(lblBrowseFiles))),
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

  formWidgets() {
    return GeneralWidgets.cardBoxWidget(
      cpadding: EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 12),
      childWidget: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          headerWidget(lblReportTitle),
          textFieldWidget(
              edttitle, getLables(lblReportTitle), getLables(lblReportTitle)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: headerWidget(lblDate),
            ),
            Expanded(
              child: headerWidget(lblTime),
            ),
          ]),
          Row(children: [
            Expanded(
              child: textFieldWidget(
                  edtDate, getLables(lblDate), getLables(lblDate),
                  focusNode: AlwaysDisabledFocusNode(),
                  tapCallback: () => selectDate(context, DateTime.now()),
                  suffixwidget: Icon(
                    Icons.calendar_month,
                    color: primaryColor,
                  )),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: textFieldWidget(
                  edtTime, getLables(lblTime), getLables(lblTime),
                  focusNode: AlwaysDisabledFocusNode(), tapCallback: () {
                print('clicktime=>');
                selectTime(context);
              }, suffixwidget: Icon(Icons.schedule, color: primaryColor)),
            ),
          ]),
          const SizedBox(height: 10),
          headerWidget(lblDoctorName),
          textFieldWidget(
              edtDrName, getLables(lblDoctorName), getLables(lblDoctorName)),
          const SizedBox(height: 10),
          headerWidget(lblPatientName),
          textFieldWidget(edtPatientName, getLables(lblPatientName),
              getLables(lblPatientName),
              isreadonly: isMyReport),
          CheckboxListTile(
            value: isMyReport,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              getLables(lblUploadingMyReport),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            contentPadding: EdgeInsets.zero,
            activeColor: primaryColor,
            checkboxShape: DesignConfig.setRoundedBorder(5, false),
            dense: true,
            onChanged: (value) {
              isMyReport = value!;
              if (isMyReport) {
                edtPatientName.text = Constant.userdata!.name!;
              }
              setState(() {});
            },
          ),
          const SizedBox(height: 10),
          headerWidget(lblNotes),
          textFieldWidget(edtNotes, getLables(lblNotes), getLables(lblNotes),
              textInputType: TextInputType.multiline),
        ]),
      ),
    );
  }

  selectDate(BuildContext context, DateTime selectedDate) async {
    print("dateclick===");
    DateTime? picked = await GeneralMethods.selectDate(context,
        selectedDate: selectedDate, hidenextdate: true);
    if (picked != null) {
      setState(() {
        reportDateTime = picked;
        /*String dayStr = "", monthStr = "";
        dayStr = GeneralMethods.datePrefixNum(picked.day);
        monthStr = GeneralMethods.datePrefixNum(picked.month);
         String dateStr = "${picked.year}-$monthStr-$dayStr";*/
        backenddate = Constant.backendDateFormat.format(picked);

        edtDate.text =
            DateFormat("dd MMM yyyy", Constant.session!.getCurrLangCode())
                .format(picked);
        selectTime(context);
      });
    }
  }

  selectTime(BuildContext context) async {
    TimeOfDay? picked = await GeneralMethods.selectTime(context);

    if (picked != null) {
      setState(() {
        String hrsStr = "", minStr = "";
        reportDateTime = DateTime(reportDateTime!.year, reportDateTime!.month,
            reportDateTime!.day, picked.hour, picked.minute);
        hrsStr = GeneralMethods.datePrefixNum(picked.hour);
        minStr = GeneralMethods.datePrefixNum(picked.minute);
        DateTime currdate = DateTime.now();
        backendtime = DateFormat("HH:mm").format(new DateTime(currdate.year,
            currdate.month, currdate.day, picked.hour, picked.minute));
        String timeStr = "$hrsStr:$minStr";
        edtTime.text = timeStr;
        //dateTimeController.text = "$date $timeStr";
      });
    }
  }

  textFieldWidget(
      TextEditingController editingController, String lbl, String errmsg,
      {TextInputType? textInputType = TextInputType.text,
      FocusNode? focusNode,
      Widget? suffixwidget,
      VoidCallback? tapCallback,
      bool isreadonly = false}) {
    return GeneralWidgets.cardBoxWidget(
      celevation: 0,
      cardcolor: lightBg,
      cmargin: EdgeInsetsDirectional.symmetric(vertical: 5),
      childWidget: GeneralWidgets.textFieldWidget(context, editingController,
          keyboardtyp: textInputType,
          maxLines: textInputType == TextInputType.multiline ? null : 1,
          minline: textInputType == TextInputType.multiline ? 5 : 1,
          isSetValidator: true,
          isReadonly: isreadonly,
          errmsg: errmsg,
          textStyle: Theme.of(context).textTheme.bodyMedium,
          focusNode: focusNode,
          tapCallback: tapCallback,
          inputDecoration: InputDecoration(
            isDense: true,
            suffixIcon: suffixwidget,
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 15),
            border: InputBorder.none,
            fillColor: lightBg,
            hintText: lbl,
            hintStyle: TextStyle(color: grey),
            filled: true,
          )),
    );
  }

  headerWidget(String lbl) {
    return Text(
      getLables(lbl),
      style: Theme.of(context).textTheme.titleMedium!,
    );
  }
}
