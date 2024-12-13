import 'package:tabebi/helper/stringLables.dart';

import 'constant.dart';
import 'generalMethods.dart';

class Validator {
  static String emailPattern =
      r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)"
      r"*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+"
      r"[a-z0-9](?:[a-z0-9-]*[a-z0-9])?";
  static String passwordPattern =
      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~%^&]).{8,}$';
  //static String passwordPattern =r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';

  static validateEmail(String? email) {
    if ((email ??= "").trim().isEmpty) {
      return getLables(emptyEmailMessage);
    } else if (!RegExp(emailPattern).hasMatch(email)) {
      return getLables(invalidEmailMessage);
    } else {
      return null;
    }
  }

//'Please enter some text'
  static emptyValueValidation(String? value, {String? errmsg}) {
    errmsg ??= getLables(emptyValueMessage);
    return (value ??= "").trim().isEmpty ? errmsg : null;
  }

  static validatePhoneNumber(String? value, {bool isShowSnackbar = false}) {
    final pattern =
        RegExp(r"^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}");
    String? validatemsg;
    if ((value ??= "").trim().isEmpty || !pattern.hasMatch(value)) {
      validatemsg = getLables(invalidPhoneMessage);
      //return getLables(invalidPhoneMessage;
    }
    if (validatemsg != null && isShowSnackbar) {
      GeneralMethods.showSnackBarMsg(
          Constant.navigatorKey.currentContext, validatemsg);
    }
    return validatemsg;
  }
}
