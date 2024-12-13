import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tabebi/helper/colors.dart';
import 'package:tabebi/helper/constant.dart';
import 'package:tabebi/models/userdata.dart';
import '../../helper/api.dart';
import '../../helper/apiParams.dart';
import '../../helper/generaWidgets.dart';
import '../../helper/generalMethods.dart';
import '../../helper/sessionManager.dart';
import '../../helper/stringLables.dart';
import '../../helper/validator.dart';

class EditProfilePage extends StatefulWidget {
  final bool? isBackIfSuccess;
  const EditProfilePage({Key? key, this.isBackIfSuccess = false})
      : super(key: key);

  @override
  EditProfilePageState createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage> {
  File? fileUserimg;
  var _formKey = GlobalKey<FormState>();
  TextEditingController edtName = TextEditingController();
  TextEditingController edtEmail = TextEditingController();
  TextEditingController edtPhone = TextEditingController();
  @override
  void initState() {
    super.initState();

    if (Constant.userdata == null) {
      Constant.userdata = UserData.fromJson(
          json.decode(Constant.session!.getData(SessionManager.keyUserData)));
    }
    edtName.text = Constant.userdata!.name!;
    edtEmail.text = Constant.userdata!.email!;
    edtPhone.text = Constant.userdata!.mobileno!;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (Constant.session!.getData(SessionManager.keyName).trim().isEmpty) {
          GeneralMethods.showSnackBarMsg(context, getLables(lblEditProfile));
          return Future.value(false);
        } else {
          return Future.value(true);
        }
      },
      child: Scaffold(
        appBar: GeneralWidgets.setAppbar(getLables(lblEditProfile), context),
        body: ListView(children: [
          const SizedBox(height: 40),
          profileWidget(),
          const SizedBox(height: 30),
          Divider(
            thickness: 2,
            color: lightGrey,
          ),
          formWidget(),
          const SizedBox(height: 20),
          Padding(
              padding: EdgeInsetsDirectional.symmetric(horizontal: 20),
              child: GeneralWidgets.btnWidget(context, getLables(lblUpdate),
                  callback: () {
                uploadProcess();
              }))
        ]),
      ),
    );
  }

  uploadProcess() async {
    if (_formKey.currentState!.validate()) {
      bool checkinternet = await GeneralMethods.checkInternet();
      if (!checkinternet) {
        GeneralMethods.showSnackBarMsg(
            context, getLables(noInternetErrorMessage));
        return;
      }
      Map<String, String> filelist = {};
      if (fileUserimg != null) {
        filelist = {"00==${ApiParams.profile}==": fileUserimg!.path};
      }
      Map<String, String> parameter = {
        ApiParams.firstName: edtName.text,
        ApiParams.phone: edtPhone.text.trim(),
      };
      if (edtEmail.text.trim().isNotEmpty) {
        parameter[ApiParams.email] = edtEmail.text;
      }
      try {
        GeneralWidgets.showLoader(context);
        var response;
        if (filelist.isNotEmpty) {
          response = await Api.postApiFile(
              ApiParams.apiUpdateProfile, filelist, context, parameter);
        } else {
          response = await Api.sendApiRequest(
              ApiParams.apiUpdateProfile, parameter, true, context);
        }
        GeneralWidgets.hideLoder(context);
        if (response == null) return;
        var getdata = json.decode(response);

        if (!getdata[ApiParams.error]) {
          // await setUserSession(getdata['data'], context);
          Constant.userdata = UserData.fromJson(getdata["data"]);
          Constant.session!
              .setData(SessionManager.keyName, Constant.userdata!.name!);
          Constant.session!
              .setData(SessionManager.keyEmail, Constant.userdata!.email!);
          Constant.session!
              .setData(SessionManager.keyUserData, Constant.userdata!.toJson());
          if (widget.isBackIfSuccess!) {
            Future.delayed(Duration(milliseconds: 500), () {
              Navigator.of(context).pop();
            });
          }
        }

        GeneralMethods.showSnackBarMsg(context, getdata["message"]);
      } catch (e) {
        GeneralWidgets.hideLoder(context);
      }
    }
  }

  formWidget() {
    return Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 20, vertical: 12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            headerWidget(lblFullName),
            textFieldWidget(
                edtName, getLables(lblFullName), getLables(lblFullName)),
            headerWidget(lblEmailaddress),
            textFieldWidget(edtEmail, getLables(lblEmailaddress),
                getLables(lblEmailaddress),
                textInputType: TextInputType.emailAddress),
            headerWidget(lblPhonenumber),
            textFieldWidget(
                edtPhone, getLables(lblPhonenumber), getLables(lblPhonenumber),
                textInputType: TextInputType.phone, isRead: true),
          ]),
        ));
  }

  textFieldWidget(
      TextEditingController editingController, String lbl, String errmsg,
      {TextInputType? textInputType = TextInputType.text,
      bool isRead = false}) {
    return GeneralWidgets.cardBoxWidget(
      celevation: 0,
      cardcolor: lightBg,
      cmargin: EdgeInsetsDirectional.symmetric(vertical: 5),
      childWidget: GeneralWidgets.textFieldWidget(context, editingController,
          keyboardtyp: textInputType,
          maxLines: textInputType == TextInputType.multiline ? null : 1,
          minline: textInputType == TextInputType.multiline ? 5 : 1,
          isSetValidator: true,
          isReadonly: isRead,
          errmsg: errmsg,
          textStyle: Theme.of(context).textTheme.bodyMedium,
          validationmsg: textInputType == TextInputType.emailAddress
              ? (value) {
                  if (value.toString().trim().isEmpty)
                    return null;
                  else
                    return Validator.validateEmail(value);
                }
              : null,
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

  headerWidget(String lbl) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 15),
      child: Text(
        getLables(lbl),
        style: Theme.of(context).textTheme.titleMedium!,
      ),
    );
  }

  profileWidget() {
    return GestureDetector(
        onTap: () async {
          fileUserimg = await GeneralWidgets.showPicker(
            context,
          );
          setState(() {});
        },
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Container(
              height: 110,
              width: 110,
              margin: EdgeInsetsDirectional.only(bottom: 10),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: white, width: 2)),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: pageBackgroundColor,
                child: ClipOval(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: fileUserimg != null
                      ? GeneralWidgets.fileImg(
                          fileUserimg!,
                          height: 100,
                          width: 100,
                          boxFit: BoxFit.fill,
                        )
                      : GeneralWidgets.circularImage(Constant.userdata!.image,
                          height: 100, width: 100, boxfit: BoxFit.fill),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: CircleAvatar(
                radius: 17,
                backgroundColor: white,
                child: Icon(
                  Icons.image,
                  color: primaryColor,
                ),
              ),
            )
          ],
        ));
  }
}
