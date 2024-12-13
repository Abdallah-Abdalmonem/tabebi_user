import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../helper/api.dart';
import '../../helper/apiParams.dart';
import '../../helper/customException.dart';
import '../../helper/generalMethods.dart';
import '../../helper/stringLables.dart';

abstract class BookAppointmentState {}

class BookAppointmentInitial extends BookAppointmentState {}

class BookAppointmentProgress extends BookAppointmentState {
  BookAppointmentProgress();
}

class BookAppointmentSuccess extends BookAppointmentState {
  String message;
  BookAppointmentSuccess(this.message);
}

class BookAppointmentFailure extends BookAppointmentState {
  final String errorMessage;
  BookAppointmentFailure(this.errorMessage);
}

class BookAppointmentCubit extends Cubit<BookAppointmentState> {
  BookAppointmentCubit() : super(BookAppointmentInitial());

  bookAppointment(BuildContext context, Map<String, String?> parameter,
      {Map<String, String>? filelist}) {
    emit(BookAppointmentProgress());
    bookAppointmentProcess(context, parameter, filelist).then((value) {
      emit(BookAppointmentSuccess(value));
    }).catchError((e) {
      emit(BookAppointmentFailure(e.toString()));
    });
  }

  Future<String> bookAppointmentProcess(BuildContext context,
      Map<String, String?> parameter, Map<String, String>? filelist) async {
    bool checkinternet = await GeneralMethods.checkInternet();
    if (!checkinternet) {
      throw CustomException(getLables(noInternetErrorMessage));
    } else {
      var response;
      if (filelist == null || filelist.isEmpty) {
        response = await Api.sendApiRequest(
            ApiParams.apiBookAppointment, parameter, true, context);
      } else {
        response = await Api.postApiFile(
            ApiParams.apiBookAppointment, filelist, context, parameter);
      }
      if (response == "null" || response == null) {
        throw CustomException(getLables(dataNotFoundErrorMessage));
      } else {
        var getdata = json.decode(response);

        if (getdata[ApiParams.error]) {
          throw CustomException(getdata[ApiParams.message]);
        } else {
          return getdata[ApiParams.message];
        }
      }
    }
  }
}
