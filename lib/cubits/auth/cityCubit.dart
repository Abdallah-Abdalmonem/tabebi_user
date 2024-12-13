import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabebi/models/province.dart';
import '../../helper/api.dart';
import '../../helper/apiParams.dart';
import '../../helper/customException.dart';
import '../../helper/generalMethods.dart';
import '../../helper/stringLables.dart';

abstract class CityState {}

class CityInitial extends CityState {}

class CityProgress extends CityState {
  CityProgress();
}

class CitySuccess extends CityState {
  List<Province> cityList;
  CitySuccess({required this.cityList});
}

class CityFailure extends CityState {
  final String errorMessage;
  CityFailure(this.errorMessage);
}

class CityCubit extends Cubit<CityState> {
  CityCubit() : super(CityInitial());

  getCityList(
    BuildContext context,
    Map<String, String?> parameter,
  ) {
    emit(CityProgress());
    getProcess(context, parameter).then((value) {
      print("state-len-${value.length}");
      emit(CitySuccess(cityList: value));
    }).catchError((e) {
      emit(CityFailure(e.toString()));
    });
  }

  Future<List<Province>> getProcess(
      BuildContext context, Map<String, String?> parameter) async {
    bool checkinternet = await GeneralMethods.checkInternet();
    if (!checkinternet) {
      throw CustomException(getLables(noInternetErrorMessage));
    } else {
      var response = await Api.sendApiRequest(
          ApiParams.apiGetCity, parameter, true, context);
      
      if (response == null) {
        throw CustomException(getLables(dataNotFoundErrorMessage));
      } else {
        var getdata = json.decode(response);
        if (getdata[ApiParams.error]) {
          throw CustomException(getdata[ApiParams.message]);
        } else {
          //int total = getdata["total"];
          List data = getdata['data'];
          List<Province> listCity = [];
          listCity.addAll(data.map((e) {
            e[ApiParams.provinceId] =
                int.parse(parameter[ApiParams.provinceId] ?? "0");
            Province province = Province.fromCityJson(
              e,
            );
            return province;
          }).toList());
          return listCity;
        }
      }
    }
  }
}
