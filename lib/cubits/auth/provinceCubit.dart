import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabebi/models/province.dart';
import '../../helper/api.dart';
import '../../helper/apiParams.dart';
import '../../helper/customException.dart';
import '../../helper/generalMethods.dart';
import '../../helper/stringLables.dart';

abstract class ProvinceState {}

class ProvinceInitial extends ProvinceState {}

class ProvinceProgress extends ProvinceState {
  ProvinceProgress();
}

class ProvinceSuccess extends ProvinceState {
  List<Province> provinceList;
  ProvinceSuccess({required this.provinceList});
}

class ProvinceFailure extends ProvinceState {
  final String errorMessage;
  ProvinceFailure(this.errorMessage);
}

class ProvinceCubit extends Cubit<ProvinceState> {
  ProvinceCubit() : super(ProvinceInitial());

  getProvinceList(
    BuildContext context,
    Map<String, String?> parameter,
  ) {
    emit(ProvinceProgress());
    getProcess(context, parameter).then((value) {
      print("state-len-${value.length}");
      emit(ProvinceSuccess(provinceList: value));
    }).catchError((e) {
      emit(ProvinceFailure(e.toString()));
    });
  }

  Future<List<Province>> getProcess(
      BuildContext context, Map<String, String?> parameter) async {
    bool checkinternet = await GeneralMethods.checkInternet();
    if (!checkinternet) {
      throw CustomException(getLables(noInternetErrorMessage));
    } else {
      var response = await Api.sendApiRequest(
          ApiParams.apiGetProvince, parameter, true, context);
      
      if (response == null) {
        throw CustomException(getLables(dataNotFoundErrorMessage));
      } else {
        var getdata = json.decode(response);
        if (getdata[ApiParams.error]) {
          throw CustomException(getdata[ApiParams.message]);
        } else {
          //int total = getdata["total"];
          List data = getdata['data'];
          List<Province> listProvince = [];
          listProvince.addAll(data.map((e) => Province.fromJson(e)).toList());
          return listProvince;
        }
      }
    }
  }
}
