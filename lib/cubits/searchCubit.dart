import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabebi/models/doctor.dart';
import 'package:tabebi/models/hospital.dart';
import 'package:tabebi/models/lab.dart';
import '../../helper/api.dart';
import '../../helper/apiParams.dart';
import '../../helper/customException.dart';
import '../../helper/generalMethods.dart';
import '../../helper/stringLables.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchProgress extends SearchState {
  SearchProgress();
}

class SearchSuccess extends SearchState {
  List<Doctor> drlist = [];
  List<Lab> lablist = [];
  List<Hospital> hospitallist = [], cliniclist = [], centerlist = [];

  SearchSuccess(
      {required this.drlist,
      required this.lablist,
      required this.hospitallist,
      required this.cliniclist,
      required this.centerlist});
}

class SearchFailure extends SearchState {
  final String errorMessage;
  SearchFailure(this.errorMessage);
}

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchInitial());
  setEmptyList() {
    emit(SearchSuccess(
        drlist: [],
        lablist: [],
        hospitallist: [],
        cliniclist: [],
        centerlist: []));
  }

  getSearchList(
    BuildContext context,
    Map<String, String?> parameter,
  ) {
    emit(SearchProgress());
    getProcess(context, parameter).then((value) {
      print("state-len-${value.length}");
      emit(SearchSuccess(
          drlist: value["drlist"],
          lablist: value["lablist"],
          hospitallist: value["hospitallist"],
          cliniclist: value["cliniclist"],
          centerlist: value["centerlist"]));
    }).catchError((e) {
      emit(SearchFailure(e.toString()));
    });
  }

  Future<Map> getProcess(
      BuildContext context, Map<String, String?> parameter) async {
    bool checkinternet = await GeneralMethods.checkInternet();
    if (!checkinternet) {
      throw CustomException(getLables(noInternetErrorMessage));
    } else {
      var response = await Api.sendApiRequest(
          ApiParams.apiSearch, parameter, true, context);
     
      if (response == null) {
        throw CustomException(getLables(dataNotFoundErrorMessage));
      } else {
        var getdata = json.decode(response);
        if (getdata[ApiParams.error]) {
          throw CustomException(getdata[ApiParams.message] ??
              getLables(dataNotFoundErrorMessage));
        } else {
          List<Doctor> drlist = [];
          List<Lab> lablist = [];
          List<Hospital> hospitallist = [], cliniclist = [], centerlist = [];
          print("search:en->${(getdata["clinic"] as List).length}");
          drlist.addAll((getdata["doctor"] as List)
              .map((e) => Doctor.fromSearchJson(e))
              .toList());
          hospitallist.addAll((getdata["hospital"] as List)
              .map((e) => Hospital.fromDrJsonfromJson(e))
              .toList());
          cliniclist.addAll((getdata["clinic"] as List)
              .map((e) => Hospital.fromDrJsonfromJson(e))
              .toList());
          centerlist.addAll((getdata["center"] as List)
              .map((e) => Hospital.fromDrJsonfromJson(e))
              .toList());
          lablist.addAll((getdata["lab"] as List)
              .map((e) => Lab.fromSearchJson(e))
              .toList());

          return {
            "drlist": drlist,
            "hospitallist": hospitallist,
            "cliniclist": cliniclist,
            "centerlist": centerlist,
            "lablist": lablist,
          };
        }
      }
    }
  }
}
