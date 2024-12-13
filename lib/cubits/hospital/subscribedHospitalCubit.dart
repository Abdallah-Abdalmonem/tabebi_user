import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabebi/helper/sessionManager.dart';

import '../../helper/api.dart';
import '../../helper/apiParams.dart';
import '../../helper/constant.dart';
import '../../helper/customException.dart';
import '../../helper/generalMethods.dart';
import '../../helper/stringLables.dart';
import '../../models/hospital.dart';

abstract class SubscribeHospitalState {}

class SubscribeHospitalInitial extends SubscribeHospitalState {}

class SubscribeHospitalProgress extends SubscribeHospitalState {
  final List<Hospital> oldHospitalList;
  final bool isFirstFetch;
  final int currOffset;
  final int currPage;
  SubscribeHospitalProgress(
      this.oldHospitalList, this.currOffset, this.currPage,
      {this.isFirstFetch = false});
}

class SubscribeHospitalSuccess extends SubscribeHospitalState {
  List<Hospital> hospitalList;
  final int currOffset;
  final int currPage;
  SubscribeHospitalSuccess(
      {required this.hospitalList,
      required this.currOffset,
      required this.currPage});
}

class SubscribeHospitalLocalSuccess extends SubscribeHospitalState {
  List<Hospital> hospitalList;

  SubscribeHospitalLocalSuccess({
    required this.hospitalList,
  });
}

class SubscribeHospitalFailure extends SubscribeHospitalState {
  final String errorMessage;
  SubscribeHospitalFailure(this.errorMessage);
}

class SubscribeHospitalCubit extends Cubit<SubscribeHospitalState> {
  SubscribeHospitalCubit() : super(SubscribeHospitalInitial());
  int page = 1;
  int offset = 0;
  bool isLoadmore = true;

  setInitialState() {
    page = 1;
    offset = 0;
    isLoadmore = true;
    emit(SubscribeHospitalInitial());
  }

  setOldList(int offsetval, int pageno, List<Hospital> splist) {
    print("emptry-search--seltold==${splist.length}");
    page = pageno;
    offset = offsetval;
    isLoadmore = true;

    emit(SubscribeHospitalSuccess(
        hospitalList: splist, currOffset: offset, currPage: page));
  }

  loadHospitalFromLocal() {
    String localdata = Constant.session!.getData(
        SessionManager.subscribeHospitalData +
            "${Constant.session!.getData(SessionManager.keyCityId)}");
    if (localdata.trim().isNotEmpty) {
      List data = json.decode(localdata);
      List<Hospital> favlist = [];
      favlist.addAll(data.map((e) => Hospital.fromJson(e)).toList());
      emit(SubscribeHospitalLocalSuccess(hospitalList: favlist));
    }
  }

  loadPosts(BuildContext context, Map<String, String?> parameter,
      {bool isloadlocal = false, bool setInitial = false}) {
    if (setInitial) {
      setInitialState();
    }

    if (!isloadlocal && state is SubscribeHospitalLocalSuccess && offset == 0) {
      setInitialState();
    }
    if (isloadlocal) {
      loadHospitalFromLocal();
    }
    print("pageno*==$state===$offset==Size==$isLoadmore");
    if (state is SubscribeHospitalProgress || !isLoadmore) return;

    final currentState = state;

    var oldPosts = <Hospital>[];
    if (currentState is SubscribeHospitalSuccess) {
      oldPosts = currentState.hospitalList;
      print(
          "pageno==${currentState.currOffset}===$offset==Size==${oldPosts.length}");
    }
    if (currentState is! SubscribeHospitalLocalSuccess)
      emit(SubscribeHospitalProgress(oldPosts, offset, page,
          isFirstFetch: offset == 0));

    parameter[ApiParams.page] = page.toString();
    parameter[ApiParams.offset] = offset.toString();
    parameter[ApiParams.limit] = Constant.fetchLimit.toString();
    parameter[ApiParams.isSubscribe] = "1";

    fetchHospitalByPage(parameter, context).then((newPosts) {
      List<Hospital> posts = [];
      //if (page != 1) {
      if (offset != 0 && state is SubscribeHospitalProgress) {
        posts = (state as SubscribeHospitalProgress).oldHospitalList;
      }
      posts.addAll(newPosts["list"]);
      //int currpage = page;
      int currpage = page;
      int curroffset = offset;

      if (newPosts["total"] > posts.length) {
        page++;
        offset = offset + Constant.fetchLimit;
        isLoadmore = true;
      } else {
        isLoadmore = false;
      }

//set in locale
      if (isloadlocal) saveInLocale(posts);
//
      emit(SubscribeHospitalSuccess(
          hospitalList: posts, currOffset: curroffset, currPage: currpage));
    }).catchError((e) {
      isLoadmore = false;
      if (offset == 0) emit(SubscribeHospitalFailure(e.toString()));
    });
  }

  saveInLocale(List<Hospital> posts) {
    print("savelocal==");
    try {
      Constant.session!.setData(
          SessionManager.subscribeHospitalData +
              "${Constant.session!.getData(SessionManager.keyCityId)}",
          json.encode(posts.map((x) => x.toMap()).toList()));
    } catch (e) {
      print("savelocal==*err*==${e.toString()}");
    }
    print("savelocal==**==");
  }

  Future<Map> fetchHospitalByPage(
      Map<String, String?> parameter, BuildContext context) async {
    bool checkinternet = await GeneralMethods.checkInternet();
    if (!checkinternet) {
      throw CustomException(getLables(noInternetErrorMessage));
    } else {
      var response = await Api.sendApiRequest(
          ApiParams.apiGetHospital, parameter, true, context);
      if (response == null) {
        throw CustomException(getLables(dataNotFoundErrorMessage));
      } else {
        var getdata = json.decode(response);
        if (getdata[ApiParams.error]) {
          throw CustomException(getdata[ApiParams.message]);
        } else {
          List data = getdata['data'];
          List<Hospital> favlist = [];

          favlist.addAll(data.map((e) => Hospital.fromJson(e)).toList());
          return {"list": favlist, "total": getdata["total"]};
        }
      }
    }
  }
}
