import 'dart:async';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabebi/helper/generaWidgets.dart';
import '../../app/routes.dart';
import '../../cubits/auth/loginCubit.dart';
import '../../helper/colors.dart';
import '../../helper/constant.dart';
import '../../helper/generalMethods.dart';
import '../../helper/stringLables.dart';
import '../../helper/validator.dart';
import 'otpTextField.dart';
import 'package:country_picker/src/utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  TextEditingController edtmobile = TextEditingController();
  Country selectedCountry = Constant.defaultCountry;
  String otpVerificationId = "", phoneWithCode = "";
  int? otpResendtoken;
  bool isOtpSent = false; //to swap between login & OTP screen
  Timer? timer;
  String err = "";
  int otpResendTime = Constant.otpResendSecond + 1;
  late OtpTextField otpTextField;

  @override
  void initState() {
    super.initState();
    otpTextField = OtpTextField();
    isOtpSent = false;
  }

  @override
  Widget build(BuildContext context) {
    return buildContent();
    /*return Scaffold(
     
       body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: WillPopScope(onWillPop: onBackPress, child: buildContent())),
  
    );*/
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }

    super.dispose();
  }

  Future<bool> onBackPress() {
    if (isOtpSent) {
      setState(() {
        isOtpSent = false;
      });
      return Future.value(false);
    }
    return Future.value(true);
  }

  buildContent() {
    return BlocConsumer<LogInCubit, LogInState>(
      bloc: context.read<LogInCubit>(),
      listener: (context, state) {
        if (state is LogInSuccess) {
          GeneralMethods.showSnackBarMsg(context, state.message);

          Navigator.of(context).pop();
          if (state.user.name!.trim().isEmpty) {
            GeneralMethods.goToNextPage(Routes.editProfilePage, context, false,
                args: true);
          }
        }

        if (state is LogInFailure) {
          print("err->${state.errorMessage}");
          GeneralMethods.showSnackBarMsg(context, state.errorMessage,
              msgduration: 3);
        }
        otpResendListener(state);
      },
      builder: (context, state) {
        print("build--1==$state");
        if (state is LogInOtpGetSuccess) {
          err = "";
          isOtpSent = state.otpSent;
          otpVerificationId = state.otpVerificationId;
          otpResendtoken = state.otpResendToken;
          // print("otpsent--${state.otpSent}===$isOtpSent");
        } else if (state is LogInFailure) {
          err = state.errorMessage;
        } else if (state is ReSendFailure) {
          err = state.errorMessage;
        }
        return SingleChildScrollView(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              headerWidget(),
              isOtpSent ? otpTextField : inputWidget(state),
              if (isOtpSent && err.trim().isNotEmpty)
                Padding(
                  padding: EdgeInsetsDirectional.symmetric(vertical: 8),
                  child: Text(
                    err,
                    style: TextStyle(color: redcolor),
                  ),
                ),
              bottomWidget(state),
              const SizedBox(height: 15),
            ],
          ),
        );
      },
    );
  }

  reSendOtpWidget(LogInState state) {
    // print("test---re==$isOtpSent==$state===>$phoneWithCode");
    if (state is ResendInProgress) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (state is LogInProgress) return const SizedBox.shrink();
    return timer == null || !timer!.isActive
        ? TextButton(
            onPressed: () {
              reSendOtp();
            },
            child: Text(getLables(resendCodeBtnLbl)))
        : resendOtpTimerWidget();
  }

  reSendOtp() async {
    try {
      err = "";
      otpTextField.clearOTP();
      context
          .read<LogInCubit>()
          .reSendFirebaseOtp(phoneWithCode, otpResendtoken);
    } on Exception catch (e) {
      GeneralMethods.showSnackBarMsg(context, e.toString());
    }
  }

  resendOtpTimerWidget() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: RichText(
          text: TextSpan(
              text: "${getLables(resendMessage)} ",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w400, letterSpacing: 0.5),
              children: <TextSpan>[
            TextSpan(
              text: otpResendTime.toString(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5),
            ),
            TextSpan(
              text: "${getLables(resendMessageDuration)}",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5),
            ),
          ])),
    );
  }

  bottomWidget(LogInState state) {
    print("build--bottom=$isOtpSent");
    if (isOtpSent) {
      return Column(mainAxisSize: MainAxisSize.min, children: [
        reSendOtpWidget(state),
        const SizedBox(height: 10),
        if (!(state is ResendInProgress)) btnWidget(state),
      ]);
    } else {
      return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Theme.of(context).colorScheme.onSecondary,
              letterSpacing: 0.5,
              height: 1.2,
              fontWeight: FontWeight.w400),
          text: getLables(loginTermsText),
          children: <TextSpan>[
            TextSpan(
                text: "\t${getLables(lblTermsOfService)}",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    GeneralMethods.goToNextPage(
                        Routes.policyPage, context, false, args: {
                      "title": lblTermsOfService,
                      "content": Constant.termsConditionsData
                    });
                  }),
            const TextSpan(
              text: "\n\n",
            ),
            TextSpan(
              text: "\t${getLables(lblAnd)}\t",
            ),
            TextSpan(
                text: getLables(lblPrivacyPolicy),
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    GeneralMethods.goToNextPage(
                        Routes.policyPage, context, false, args: {
                      "title": lblPrivacyPolicy,
                      "content": Constant.privacyPolicyData
                    });
                  }),
          ],
        ),
      );
    }
  }

  otpResendListener(LogInState state) {
    if (state is ReSendFailure) {
      GeneralMethods.showSnackBarMsg(context, state.errorMessage,
          msgduration: 5);
      if (timer != null && timer!.isActive) timer!.cancel();
    }
    if (state is ReSendOtpSuccess) {
      otpResendtoken = state.otpResendToken;
      otpVerificationId = state.otpVerificationId;
      GeneralMethods.showSnackBarMsg(
        context,
        getLables(otpsentsuccessflly),
      );
      startOtpTimer();
    }
  }

  startOtpTimer() {
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        setState(() {
          if (otpResendTime == 0) {
            timer.cancel();
            otpResendTime = Constant.otpResendSecond + 1;
          } else {
            otpResendTime--;
          }
        });
      },
    );
  }

  headerWidget() {
    return RichText(
        text: TextSpan(
            text: getLables(lblLogin),
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: Theme.of(context).colorScheme.secondary),
            children: [
          TextSpan(
            text: isOtpSent
                ? "\n\n\n${getLables(enterOTPInfo)}\n$phoneWithCode"
                : "\n\n\n${getLables(lblPhonenumber)}",
            style: Theme.of(context).textTheme.titleMedium!.merge(TextStyle(
                color: Theme.of(context).colorScheme.secondary, height: 1.5)),
          ),
          /* TextSpan(
              text:
                  "\n\n${isOtpSent ? "${StringRes.otpHeader3} $phoneWithCode" : StringRes.loginHeader3}",
              style: Theme.of(context)
                  .textTheme
                  .caption!
                  .copyWith(color: Theme.of(context).colorScheme.secondary)),*/
        ]));
  }

  inputWidget(LogInState state) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 25,
            ),
            GeneralWidgets.cardBoxWidget(
              celevation: 0,
              cardcolor: Theme.of(context).scaffoldBackgroundColor,
              childWidget: IntrinsicHeight(
                child: Row(
                  children: [
                    countryWidget(),
                    const SizedBox(width: 5),
                    VerticalDivider(
                      color: lightGrey,
                      endIndent: 10,
                      indent: 10,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                        child: TextFormField(
                      textAlign: Constant.session!.getCurrLangCode() ==
                              Constant.arabicLanguageCode
                          ? TextAlign.end
                          : TextAlign.start,
                      decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: "000 000 0000",
                          counterText: "",
                          hintStyle: TextStyle(color: grey)
                          //hintText: getLables(lblPhonenumber)
                          ),
                      maxLength: 12,
                      textAlignVertical: TextAlignVertical.center,
                      style: Theme.of(context).textTheme.titleMedium!,
                      keyboardType: TextInputType.phone,
                      controller: edtmobile,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    )),
                  ],
                ),
              ),
            ),
            if (err.trim().isNotEmpty)
              Padding(
                padding: EdgeInsetsDirectional.symmetric(vertical: 8),
                child: Text(
                  err,
                  style: TextStyle(color: redcolor),
                ),
              ),
            const SizedBox(
              height: 40,
            ),
            btnWidget(state),
            const SizedBox(height: 35),
          ]),
    );
  }

  countryWidget() {
    return GestureDetector(
      onTap: () {
        openCountryCodePicker();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _flagWidget(selectedCountry),
          Text(
            "+${selectedCountry.phoneCode}",
            style: Theme.of(context).textTheme.titleMedium!,
          )
        ]),
      ),
    );
  }

  btnWidget(LogInState state) {
    if (state is LogInProgress) {
      return const Center(child: CircularProgressIndicator());
    }

    return GeneralWidgets.btnWidget(
        context, isOtpSent ? getLables(lblLogin) : getLables(lblGetOtp),
        callback: isOtpSent ? firebaseMobileLogin : firebaseGetOtp);
  }

  firebaseMobileLogin() async {
    String otp = otpTextField.getOTP();
    print("OTP=>$otp");
    if (err.trim().isNotEmpty) {
      setState(() {
        err = "";
      });
    }
    if (otp.length < Constant.otpLength) {
      GeneralMethods.showSnackBarMsg(context, getLables(lblEnterOtp),
          msgduration: 2);
      err = getLables(lblEnterOtp);
      setState(() {});
      return;
    }
    bool checkinternet = await GeneralMethods.checkInternet();
    if (!checkinternet) {
      GeneralMethods.showSnackBarMsg(
          context, getLables(noInternetErrorMessage));
      err = getLables(noInternetErrorMessage);
      setState(() {});
      return;
    }
    context
        .read<LogInCubit>()
        .loginWithFirebase(otpVerificationId, otp, context);
  }

  firebaseGetOtp() async {
    if (err.trim().isNotEmpty) {
      setState(() {
        err = "";
      });
    }
    if (Validator.validatePhoneNumber(edtmobile.text, isShowSnackbar: true) !=
        null) {
      err = getLables(invalidPhoneMessage);
      setState(() {});
      return;
    }
    bool checkinternet = await GeneralMethods.checkInternet();
    if (!checkinternet) {
      GeneralMethods.showSnackBarMsg(
          context, getLables(noInternetErrorMessage));
      err = getLables(noInternetErrorMessage);
      setState(() {});
      return;
    }

    phoneWithCode = '+${selectedCountry.phoneCode}${edtmobile.text}';

    context.read<LogInCubit>().getFirebaseOtp(phoneWithCode);
  }

  openCountryCodePicker() {
    showCountryPicker(
      context: context,
      // favorite: <String>['+91', 'IN'],
      showPhoneCode: true,
      onSelect: (Country country) {
        selectedCountry = country;
        setState(() {});
      },
      countryListTheme: CountryListThemeData(
        bottomSheetHeight: MediaQuery.of(context).size.height / 1.3,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40.0),
          topRight: Radius.circular(40.0),
        ),
        inputDecoration: InputDecoration(
          labelText: getLables(lblSearch),
          hintText: getLables(lblSearch),
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            borderSide: BorderSide(
              color: const Color(0xFF8C98A8).withOpacity(0.2),
            ),
          ),
        ),
      ),
    );
  }

  _flagWidget(Country country) {
    return Container(
        width: 50,
        alignment: AlignmentDirectional.center,
        child: Text(
          country.iswWorldWide
              ? '\uD83C\uDF0D'
              : Utils.countryCodeToEmoji(country.countryCode),
          style: const TextStyle(
            fontSize: 25,
          ),
        ));
  }
}
