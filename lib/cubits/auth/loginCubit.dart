import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../helper/apiParams.dart';
import '../../helper/constant.dart';
import '../../helper/sessionManager.dart';
import '../../models/userdata.dart';
import 'authRepository.dart';

abstract class LogInState {}

class LogInInitial extends LogInState {}

class LogInProgress extends LogInState {
  LogInProgress();
}

class ResendInProgress extends LogInState {
  ResendInProgress();
}

class LogoutSuccess extends LogInState {
  LogoutSuccess();
}

class LogInOtpGetSuccess extends LogInState {
  final bool otpSent;
  final String otpVerificationId;
  final int? otpResendToken;

  LogInOtpGetSuccess({
    required this.otpSent,
    required this.otpVerificationId,
    required this.otpResendToken,
  });
}

class ReSendOtpSuccess extends LogInState {
  final bool otpSent;
  final String otpVerificationId;
  final int? otpResendToken;

  ReSendOtpSuccess({
    required this.otpSent,
    required this.otpVerificationId,
    required this.otpResendToken,
  });
}

class LogInSuccess extends LogInState {
  UserData user;
  String token;
  User firebaseuser;
  String message;
  LogInSuccess(
      {required this.user,
      required this.token,
      required this.firebaseuser,
      required this.message});
}

class ReSendFailure extends LogInState {
  final String errorMessage;

  ReSendFailure(this.errorMessage);
}

class LogInFailure extends LogInState {
  final String errorMessage;

  LogInFailure(this.errorMessage);
}

class LogInCubit extends Cubit<LogInState> {
  final AuthRepository _authRepository;
  LogInCubit(
    this._authRepository,
  ) : super(LogInInitial());

  setLogout() {
    Constant.session!.logoutUser(Constant.navigatorKey.currentContext!);
    emit(LogoutSuccess());
  }

  getFirebaseOtp(String phonenumber) {
    emit(LogInProgress());
    _authRepository
        .getOtpProcess(phonenumber, getOtpSuccess, getOtpFailure)
        .catchError((e) {
      emit(LogInFailure(e.toString()));
    });
  }

  reSendFirebaseOtp(String phonenumber, int? resendtoken) {
    emit(ResendInProgress());
    _authRepository
        .reSendOtp(phonenumber, resendtoken, getOtpSuccess, getOtpFailure)
        .catchError((e) {
      emit(ReSendFailure(e.toString()));
    });
  }

  getOtpFailure(String msg, bool isResend) {
    if (isResend) {
      emit(ReSendFailure(msg));
    } else {
      emit(LogInFailure(msg));
    }
  }

  getOtpSuccess(String vid, int? resendToken, bool isResend) {
    if (isResend) {
      emit(ReSendOtpSuccess(
          otpSent: true, otpVerificationId: vid, otpResendToken: resendToken));
    } else {
      emit(LogInOtpGetSuccess(
          otpSent: true, otpVerificationId: vid, otpResendToken: resendToken));
    }
  }

  loginWithFirebase(String vid, String otp, BuildContext context) {
    emit(LogInProgress());
    //context.read<UserDetailsCubit>().emitUserProgressState();
    _authRepository.firebaseLoginProcess(vid, otp).then((value) async {
      User firebaseuser = value["fuser"];
      //bool isNewUser = value["isNewUser"];
      /*Constant.session!.setBoolData(SessionManager.isUserLogin, true);
      Constant.session!.setData(SessionManager.keyId, "1");
      Constant.session!
          .setData(SessionManager.keyMobileNumber, firebaseuser.phoneNumber!);
      Constant.session!
          .setData(SessionManager.keyName, firebaseuser.displayName ?? "test");
      Constant.userdata = UserData(
          id: 1,
          name: "test",
          mobileno: firebaseuser.phoneNumber,
          image: "",
          email: "");
      emit(LogInSuccess(
          user: Constant.userdata!, firebaseuser: firebaseuser, token: ""));*/

      Map<String, String> body = {
        ApiParams.phone: firebaseuser.phoneNumber!,
        ApiParams.firebaseId: firebaseuser.uid,
      };
      _authRepository
          .loginWithDb(context, body, firebaseuser.uid)
          .then((lvalue) {
        Constant.session!.setBoolData(SessionManager.isUserLogin, true);
        Constant.session!.setData(SessionManager.keyId, "1");
        Constant.session!
            .setData(SessionManager.keyMobileNumber, firebaseuser.phoneNumber!);
        Constant.session!
            .setData(SessionManager.keyName, lvalue["userData"].name ?? "");
        Constant.session!
            .setData(SessionManager.keyToken, lvalue["userData"].token!);
        Constant.userdata = lvalue["userData"];
        Constant.session!
            .setData(SessionManager.keyUserData, Constant.userdata!.toJson());
        emit(LogInSuccess(
            user: lvalue["userData"],
            firebaseuser: firebaseuser,
            token: lvalue["userData"].token!,
            message: lvalue["message"]));
      }).catchError((e) {
        emit(LogInFailure(e.toString()));
      });
    }).catchError((e) {
      emit(LogInFailure(e.toString()));
    });
  }
}
