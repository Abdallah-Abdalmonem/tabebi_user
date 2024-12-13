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

abstract class HospitalState {}

class HospitalInitial extends HospitalState {}

class HospitalProgress extends HospitalState {
  final List<Hospital> oldHospitalList;
  final bool isFirstFetch;
  final int currOffset;
  final int currPage;
  HospitalProgress(this.oldHospitalList, this.currOffset, this.currPage,
      {this.isFirstFetch = false});
}

class HospitalSuccess extends HospitalState {
  List<Hospital> hospitalList;
  final int currOffset;
  final int currPage;
  HospitalSuccess(
      {required this.hospitalList,
      required this.currOffset,
      required this.currPage});
}

class HospitalLocalSuccess extends HospitalState {
  List<Hospital> hospitalList;

  HospitalLocalSuccess({
    required this.hospitalList,
  });
}

class HospitalFailure extends HospitalState {
  final String errorMessage;
  HospitalFailure(this.errorMessage);
}

class HospitalCubit extends Cubit<HospitalState> {
  HospitalCubit() : super(HospitalInitial());
  int page = 1;
  int offset = 0;
  bool isLoadmore = true;

  setInitialState() {
    page = 1;
    offset = 0;
    isLoadmore = true;
    emit(HospitalInitial());
  }

  setOldList(int offsetval, int pageno, List<Hospital> splist) {
    print("emptry-search--seltold==${splist.length}");
    page = pageno;
    offset = offsetval;
    isLoadmore = true;

    emit(HospitalSuccess(
        hospitalList: splist, currOffset: offset, currPage: page));
  }

  loadHospitalFromLocal() {
    String localdata = Constant.session!.getData(SessionManager.hospitalData +
        "${Constant.session!.getData(SessionManager.keyCityId)}");
    if (localdata.trim().isNotEmpty) {
      List data = json.decode(localdata);
      List<Hospital> favlist = [];
      favlist.addAll(data.map((e) => Hospital.fromJson(e)).toList());
      emit(HospitalLocalSuccess(hospitalList: favlist));
    }
  }

  loadPosts(BuildContext context, Map<String, String?> parameter,
      {bool isloadlocal = false, bool setInitial = false}) {
    if (setInitial) {
      setInitialState();
    }

    if (!isloadlocal && state is HospitalLocalSuccess && offset == 0) {
      setInitialState();
    }
    if (isloadlocal) {
      loadHospitalFromLocal();
    }
    print("pageno*==$state===$offset==Size==$isLoadmore");
    if (state is HospitalProgress || !isLoadmore) return;

    final currentState = state;

    var oldPosts = <Hospital>[];
    if (currentState is HospitalSuccess) {
      oldPosts = currentState.hospitalList;
      print(
          "pageno==${currentState.currOffset}===$offset==Size==${oldPosts.length}");
    }
    if (currentState is! HospitalLocalSuccess)
      emit(HospitalProgress(oldPosts, offset, page, isFirstFetch: offset == 0));

    parameter[ApiParams.page] = page.toString();
    parameter[ApiParams.offset] = offset.toString();
    parameter[ApiParams.limit] = Constant.fetchLimit.toString();

    fetchHospitalByPage(parameter, context).then((newPosts) {
      List<Hospital> posts = [];
      //if (page != 1) {
      if (offset != 0 && state is HospitalProgress) {
        posts = (state as HospitalProgress).oldHospitalList;
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
      emit(HospitalSuccess(
          hospitalList: posts, currOffset: curroffset, currPage: currpage));
    }).catchError((e) {
      isLoadmore = false;
      if (offset == 0) emit(HospitalFailure(e.toString()));
    });
  }

  saveInLocale(List<Hospital> posts) {
    print("savelocal==");
    try {
      Constant.session!.setData(
          SessionManager.hospitalData +
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
