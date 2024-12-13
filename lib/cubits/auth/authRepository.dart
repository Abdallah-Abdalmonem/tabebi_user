import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tabebi/helper/generalMethods.dart';
import 'package:tabebi/helper/stringLables.dart';
import '../../helper/api.dart';

import '../../helper/apiParams.dart';
import '../../helper/constant.dart';
import '../../helper/customException.dart';
import '../../models/userdata.dart';

class AuthRepository {
  Future<void> getOtpProcess(
      String phonenumber, Function? callback, Function failureCallback) async {
    try {
      await FirebaseAuth.instance
          .verifyPhoneNumber(
        timeout: Duration(seconds: Constant.otpTimeOutSecond),
        phoneNumber: phonenumber,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          failureCallback(e.message ?? getLables(somethingwentwrong), false);
          //throw CustomException(e.message);
        },
        codeSent: (String verificationId, int? resendToken) {
          if (callback != null) {
            callback(verificationId, resendToken, false);
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // if (mounted) Navigator.of(context).pop();
        },
      )
          .catchError((e) {
        failureCallback(e.toString(), false);
        //throw CustomException(e.toString());
      });
    } on FirebaseAuthException catch (e) {
      failureCallback(e.message, false);
      // throw CustomException(e.message);
    } catch (e) {
      failureCallback(e.toString(), false);
      //throw CustomException(e.toString());
    }
    //return {"isOtpSent": otpsent, "otpVerificationId": vid};
  }

  Future<void> reSendOtp(String phonenumber, int? resendtoken,
      Function? callback, Function failureCallbac) async {
    try {
      await FirebaseAuth.instance
          .verifyPhoneNumber(
        timeout: Duration(seconds: Constant.otpTimeOutSecond),
        phoneNumber: phonenumber,
        forceResendingToken: resendtoken,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          failureCallbac(e.message, true);
          //throw CustomException(e.message);
        },
        codeSent: (String verificationId, int? resendToken) {
          if (callback != null) {
            callback(verificationId, resendToken, true);
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // if (mounted) Navigator.of(context).pop();
        },
      )
          .catchError((e) {
        failureCallbac(e.toString(), true);
        //throw CustomException(e.toString());
      });
      //return {"isOtpSent": otpsent, "otpVerificationId": vid};
    } on FirebaseAuthException catch (e) {
      failureCallbac(e.message, true);
      //throw CustomException(e.message);
    } catch (e) {
      failureCallbac(e.toString(), true);
      //throw CustomException(e.toString());
    }
  }

  Future<Map<String, dynamic>> firebaseLoginProcess(
      String vid, String otp) async {
    try {
      User? user;
      bool? isNewUser;
      PhoneAuthCredential credential =
          PhoneAuthProvider.credential(verificationId: vid, smsCode: otp);

      /*  await FirebaseAuth.instance
          .signInWithCredential(credential)
          .then((value) {
        user = value.user!;
        isNewUser = value.additionalUserInfo!.isNewUser;
        //backendApiProcess(user);
      }).catchError((e) {
        print("otperr->1->${e.toString()}");
        throw CustomException(e.toString());
      }); */
      UserCredential value =
          await FirebaseAuth.instance.signInWithCredential(credential);
      if (value.user != null) {
        user = value.user;
        isNewUser = value.additionalUserInfo!.isNewUser;
      }
      return {"fuser": user!, "isNewUser": isNewUser};
    } on FirebaseAuthException catch (e) {
      print("otperr->2->${e.code}");
      print("otperr->2*->${e.message}");

      throw CustomException(e.message);
    } catch (e) {
      print("otperr->3->${e.toString()}");
      throw CustomException(e.toString());
    }
  }

  Future<Map> loginWithDb(
      BuildContext context, Map<String, String> body, String firebaseid) async {
    try {
      var response =
          await Api.sendApiRequest(ApiParams.apiLogin, body, true, context);

      if (response != null) {
        Map getdata = json.decode(response);
        if (!getdata[ApiParams.error]) {
          UserData userData = UserData.fromJson(getdata["data"]);
          return {"userData": userData, "message": getdata[ApiParams.message]};
        } else {
          throw CustomException(getdata[ApiParams.message]);
        }
      } else {
        throw CustomException(getLables(dataNotFoundErrorMessage));
      }
    } on FirebaseAuthException catch (e) {
      throw CustomException(e.message);
    } on Exception catch (e) {
      throw CustomException(e.toString());
    } catch (e) {
      throw CustomException(e.toString());
    }
  }
  /*Future<String> deleteAccount(BuildContext context) async {
    String message = '';
    if (FirebaseAuth.instance.currentUser != null) {
      try {
        await FirebaseAuth.instance.currentUser!.delete();
        var response = await Api.sendApiRequest(
            ApiParams.deleteAccount,
            {
              ApiParams.token:
                  Constant.session!.getData(SessionManager.keyToken)
            },
            true,
            context,
            passUserid: false);

        if (response != null) {
          var getdata = json.decode(response);
          if (getdata[ApiParams.error]) {
            throw CustomException(getdata[ApiParams.message]);
          } else {
            Constant.session!.logoutUser(context);
            // message = getdata[ApiParams.message];
            return 'Account deleted successfully';
          }
        } else {
          throw CustomException(StringRes.defaultErrorMessage);
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          throw CustomException(StringRes.userDeleteErrorMessage);
        }
      }
    }
    return StringRes.userDeleteErrorMessage;
  }*/
}
