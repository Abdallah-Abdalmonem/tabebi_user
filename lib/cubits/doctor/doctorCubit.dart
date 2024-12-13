import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabebi/helper/apiParams.dart';
import 'package:tabebi/models/doctor.dart';
import 'package:tabebi/models/favouriteData.dart';

import '../../helper/api.dart';
import '../../helper/constant.dart';
import '../../helper/customException.dart';
import '../../helper/generalMethods.dart';
import '../../helper/stringLables.dart';

@immutable
abstract class DoctorState {}

class DoctorInitial extends DoctorState {}

class DoctorLoaded extends DoctorState {
  final List<Doctor> doctorList;
  final int currOffset;
  final int currPage;

  DoctorLoaded(
      {required this.doctorList,
      required this.currOffset,
      required this.currPage});
}

class DoctorLoading extends DoctorState {
  final List<Doctor> oldDrList;
  final bool isFirstFetch;
  final int currOffset;
  final int currPage;
  DoctorLoading(this.oldDrList, this.currOffset, this.currPage,
      {this.isFirstFetch = false});
}

class DoctorFailure extends DoctorState {
  final String errorMessage;
  DoctorFailure(this.errorMessage);
}

class DoctorCubit extends Cubit<DoctorState> {
  DoctorCubit() : super(DoctorInitial());

  int page = 1;
  int offset = 0;
  bool isLoadmore = true;

  setInitialState() {
    page = 1;
    offset = 0;
    isLoadmore = true;
    emit(DoctorInitial());
  }

  setOldList(int offsetval, int pageno, List<Doctor> drlist) {
    print("emptry-search--seltold==${drlist.length}");
    page = pageno;
    offset = offsetval;
    isLoadmore = true;
    //emit(DoctorInitial());
    emit(DoctorLoaded(doctorList: drlist, currOffset: offset, currPage: page));
  }

  loadPosts(BuildContext context, Map<String, String?> parameter,
      {bool isSetInitial = false}) {
    if (isSetInitial) {
      setInitialState();
    }

    if (state is DoctorLoading || !isLoadmore) return;

    final currentState = state;

    var oldPosts = <Doctor>[];
    if (currentState is DoctorLoaded) {
      oldPosts = currentState.doctorList;
    }

    emit(DoctorLoading(oldPosts, offset, page, isFirstFetch: offset == 0));
    parameter[ApiParams.page] = page.toString();
    parameter[ApiParams.offset] = offset.toString();
    parameter[ApiParams.limit] = Constant.fetchLimit.toString();
   
    fetchDoctors(parameter, context).then((newPosts) {
     
      List<Doctor> posts = [];
      if (offset != 0 && state is DoctorLoading) {
        posts = (state as DoctorLoading).oldDrList;
      }
      posts.addAll(newPosts["list"]);
      int currpage = page;
      int curroffset = offset;
      
      if (newPosts["total"] > posts.length) {
        page++;
        offset = offset + Constant.fetchLimit;
        isLoadmore = true;
      } else {
        isLoadmore = false;
      }
      emit(DoctorLoaded(
          doctorList: posts, currOffset: curroffset, currPage: currpage));
    }).catchError((e) {
      isLoadmore = false;
      if (offset == 0) emit(DoctorFailure(e.toString()));
    });
  }

  Future<Map> fetchDoctors(
      Map<String, String?> parameter, BuildContext context) async {
    print("drparams->$parameter");
    bool checkinternet = await GeneralMethods.checkInternet();
    if (!checkinternet) {
      throw CustomException(getLables(noInternetErrorMessage));
    } else {
      var response = await Api.sendApiRequest(
          ApiParams.apiGetDoctor, parameter, true, context);
      if (response == null) {
        throw CustomException(getLables(dataNotFoundErrorMessage));
      } else {
        var getdata = json.decode(response);
        if (getdata[ApiParams.error]) {
          throw CustomException(getdata[ApiParams.message]);
        } else {
          List data = getdata['data'];
          List<Doctor> favlist = [];
          favlist.addAll(data.map((e) => Doctor.fromJson(e)).toList());
          return {"list": favlist, "total": getdata["total"]};
        }
      }
    }
  }

  Future<FavouriteData?> favUnfavDoctor(
      String drid, String favunfavval, BuildContext context) async {
    bool checkinternet = await GeneralMethods.checkInternet();
    if (!checkinternet) {
      throw CustomException(getLables(noInternetErrorMessage));
    } else {
      var response = await Api.sendApiRequest(
          ApiParams.apiFavourite,
          {
            ApiParams.id: drid,
            ApiParams.status: favunfavval,
            ApiParams.apiType: ApiParams.set,
            ApiParams.type: Constant.appointmentDoctor
          },
          true,
          context);
      if (response == null) {
        throw CustomException(getLables(dataNotFoundErrorMessage));
      } else {
        var getdata = json.decode(response);
        if (getdata[ApiParams.error]) {
          throw CustomException(getdata[ApiParams.message]);
        } else {
          FavouriteData? favouriteData;
          print("favdrid=favunfavval=**${favunfavval == "1"}");
          if (favunfavval == "1") {
            favouriteData = FavouriteData.fromJson(getdata["data"]);
          }
          return favouriteData;
        }
      }
    }
  }
}
