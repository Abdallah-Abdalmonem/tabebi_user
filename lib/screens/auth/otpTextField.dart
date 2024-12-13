import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../helper/colors.dart';
import '../../helper/constant.dart';
import '../../helper/designConfig.dart';

class OtpTextField extends StatefulWidget {
  OtpTextField({super.key});
  final OtpTextFieldState otpField = OtpTextFieldState();

  String getOTP() {
    return otpField.getOtp();
  }

  clearOTP() {
    otpField.clearOtp();
  }

  @override
  State<OtpTextField> createState() => otpField;
}

class OtpTextFieldState extends State<OtpTextField> {
  List<TextEditingController> controllers = [];
  List<FocusNode> _focusNodes = [];

  List<Widget> list = [];
  int focusIndex = 0;
  @override
  void initState() {
    super.initState();
    setTextFields();
  }

  setTextFields() {
    controllers = [];
    _focusNodes = [];
    list = [];
    focusIndex = 0;
    for (int i = 0; i < Constant.otpLength; i++) {
      final controller = TextEditingController();
      final focusNode = FocusNode();
      controllers.add(controller);
      _focusNodes.add(focusNode);
    }

    Future.delayed(Duration.zero, () {
      list =
          List.generate(Constant.otpLength, (index) => createTextField(index));
      listenotp();
    });
  }

  getOtp() {
    String otp = "";
    for (var element in controllers) {
      otp = otp + element.text;
    }
    return otp;
  }

  clearOtp() {
    for (var element in controllers) {
      element.clear();
    }
    if (mounted) setState(() {});
  }

  listenotp() {
    final SmsAutoFill _autoFill = SmsAutoFill();
    _autoFill.code.listen((event) {
      Future.delayed(Duration.zero, () {
        for (int i = 0; i < controllers.length; i++) {
          controllers[i].text = event[i];
        }

        _focusNodes[focusIndex].unfocus();
        if (mounted) setState(() {});
      });
    });
  }

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }

    for (final fNode in _focusNodes) {
      fNode.dispose();
    }

    SmsAutoFill().unregisterListener();

    super.dispose();
  }

  Widget createTextField(int index) {
    return Container(
      // width: 50,
      height: 50,
      margin: EdgeInsetsDirectional.only(
          top: 25,
          start: index == 0 ? 0 : 3,
          end: index == (Constant.otpLength - 1) ? 0 : 3),
      alignment: AlignmentDirectional.center,
      decoration: DesignConfig.boxDecorationBorder(
        Theme.of(context).colorScheme.background,
        8,
        /* bcolor: _focusNodes[index].hasFocus
              ? Theme.of(context).colorScheme.primary
              : lightGrey*/
      ),
      child: buildTextField(index),
    );
  }

  TextFormField buildTextField(int index) {
    return TextFormField(
      cursorColor: Theme.of(context).colorScheme.primary,
      controller: controllers[index],
      focusNode: _focusNodes[index],
      maxLength: 1,
      textInputAction: TextInputAction.done,
      style: TextStyle(
        color: _focusNodes[index].hasFocus
            ? Theme.of(context).colorScheme.primary
            : Colors.black,
        fontWeight: FontWeight.w600,
      ),
      keyboardType: TextInputType.number,
      autofocus: index == 0 ? true : false,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: '0',
        counterText: '',
        hintStyle: TextStyle(color: lightGrey),
        border: InputBorder.none,
      ),
      onTap: () {
        setState(() {
          focusIndex = index;
        });
      },
      onChanged: (val) {
        _focusNodes[index].unfocus();
        if (val.isNotEmpty && index < Constant.otpLength - 1) {
          setState(() {
            focusIndex = index + 1;
          });
          FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
        }
        if (val == '' && index > 0) {
          setState(() {
            focusIndex = index - 1;
          });
          FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: [
          /* Wrap(
            spacing: 4,
            children: List.generate(
                Constant.otpLength, (index) => createTextField(index)),
          ), */
          Row(
            children: List.generate(Constant.otpLength,
                (index) => Expanded(child: createTextField(index))),
          ),
          PinFieldAutoFill(
            decoration: UnderlineDecoration(
              textStyle: TextStyle(fontSize: 20, color: Colors.transparent),
              colorBuilder: FixedColorBuilder(Colors.transparent),
            ),
            currentCode: "",
            onCodeSubmitted: (code) {},
            onCodeChanged: (code) {},
          ),
        ],
      ),
    );
  }
}
