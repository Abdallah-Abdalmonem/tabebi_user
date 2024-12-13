import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../helper/api.dart';
import '../helper/apiParams.dart';
import '../helper/constant.dart';
import '../helper/customException.dart';
import '../helper/generalMethods.dart';
import '../helper/sessionManager.dart';
import '../helper/stringLables.dart';
import '../models/speciality.dart';

abstract class SpecialityState {}

class SpecialityInitial extends SpecialityState {}

class SpecialityProgress extends SpecialityState {
  final List<Speciality> oldSpecialityList;
  final bool isFirstFetch;
  final int currOffset;
  final int currPage;
  SpecialityProgress(this.oldSpecialityList, this.currOffset, this.currPage,
      {this.isFirstFetch = false});
}

class SpecialitySuccess extends SpecialityState {
  List<Speciality> specialityList;
  final int currOffset;
  final int currPage;
  SpecialitySuccess(
      {required this.specialityList,
      required this.currOffset,
      required this.currPage});
}

class SpecialityLocalSuccess extends SpecialityState {
  List<Speciality> specialityList;

  SpecialityLocalSuccess({
    required this.specialityList,
  });
}

class SpecialityFailure extends SpecialityState {
  final String errorMessage;
  SpecialityFailure(this.errorMessage);
}

class SpecialityCubit extends Cubit<SpecialityState> {
  SpecialityCubit() : super(SpecialityInitial());
  int page = 1;
  int offset = 0;
  bool isLoadmore = true;

  setInitialState() {
    page = 1;
    offset = 0;
    isLoadmore = true;
    emit(SpecialityInitial());
  }

  setOldList(int offsetval, int pageno, List<Speciality> splist) {
    print("emptry-search--seltold==${splist.length}");
    page = pageno;
    offset = offsetval;
    isLoadmore = true;

    emit(SpecialitySuccess(
        specialityList: splist, currOffset: offset, currPage: page));
  }

  loadSpecialityFromLocal() {
    String localdata = Constant.session!.getData(SessionManager.specialityData);
    if (localdata.trim().isNotEmpty) {
      List data = json.decode(localdata);
      List<Speciality> favlist = [];
      favlist.addAll(data.map((e) => Speciality.fromJson(e)).toList());
      emit(SpecialityLocalSuccess(specialityList: favlist));
    }
  }

  loadPosts(BuildContext context, Map<String, String?> parameter,
      {bool isloadlocal = false}) {
    print(
        "sp-pageno*==$state===$offset==Size==$isLoadmore==isloadlocal=$isloadlocal");

    if (!isloadlocal && state is SpecialityLocalSuccess && offset == 0) {
      setInitialState();
    }

    if (isloadlocal) {
      loadSpecialityFromLocal();
    }
    if (state is SpecialityProgress || !isLoadmore) return;

    final currentState = state;

    var oldPosts = <Speciality>[];
    if (currentState is SpecialitySuccess) {
      oldPosts = currentState.specialityList;
      print(
          "pageno==${currentState.currOffset}===$offset==Size==${oldPosts.length}");
    }

    //emit(SpecialityProgress(oldPosts, page, isFirstFetch: page == 1));
    //parameter[ApiParams.page] = page.toString();
    if (currentState is! SpecialityLocalSuccess)
      emit(SpecialityProgress(oldPosts, offset, page,
          isFirstFetch: offset == 0));

    parameter[ApiParams.page] = page.toString();
    parameter[ApiParams.offset] = offset.toString();
    parameter[ApiParams.limit] = Constant.specialityFetchLimit.toString();

    fetchSpecialityByPage(parameter, context).then((newPosts) {
      List<Speciality> posts = [];
      //if (page != 1) {
      if (offset != 0 && state is SpecialityProgress) {
        posts = (state as SpecialityProgress).oldSpecialityList;
      }
      posts.addAll(newPosts["list"]);
      //int currpage = page;
      int currpage = page;
      int curroffset = offset;
      
      if (newPosts["total"] > posts.length) {
        page++;
        offset = offset + Constant.specialityFetchLimit;
        isLoadmore = true;
      } else {
        isLoadmore = false;
      }
      //set in locale
      if (isloadlocal) saveInLocale(posts);
//
      emit(SpecialitySuccess(
          specialityList: posts, currOffset: curroffset, currPage: currpage));
      //emit(SpecialitySuccess(specialityList: posts, currPage: currpage));
    }).catchError((e) {
      isLoadmore = false;
      if (offset == 0) emit(SpecialityFailure(e.toString()));
      //if (page == 1) emit(SpecialityFailure(e.toString()));
    });
  }

  saveInLocale(List<Speciality> posts) {
    print("savelocalSpeciality==");
    try {
      Constant.session!.setData(SessionManager.specialityData,
          json.encode(posts.map((x) => x.toMap()).toList()));
    } catch (e) {
      print("savelocalSpeciality==*err*==${e.toString()}");
    }
    print("savelocalSpeciality==**==");
  }

  Future<Map> fetchSpecialityByPage(
      Map<String, String?> parameter, BuildContext context) async {
    bool checkinternet = await GeneralMethods.checkInternet();
    if (!checkinternet) {
      throw CustomException(getLables(noInternetErrorMessage));
    } else {
      var response = await Api.sendApiRequest(
          ApiParams.apiGetSpeciality, parameter, true, context);
    
      if (response == null) {
        throw CustomException(getLables(dataNotFoundErrorMessage));
      } else {
        var getdata = json.decode(response);
        if (getdata[ApiParams.error]) {
          throw CustomException(getdata[ApiParams.message]);
        } else {
          List data = getdata['data'];
          List<Speciality> favlist = [];
          favlist.addAll(data.map((e) => Speciality.fromJson(e)).toList());
          return {"list": favlist, "total": getdata["total"]};
        }
      }
    }
  }
}
