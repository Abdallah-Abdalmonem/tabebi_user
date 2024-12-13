import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../helper/api.dart';
import '../helper/apiParams.dart';
import '../helper/constant.dart';
import '../helper/customException.dart';
import '../helper/generalMethods.dart';
import '../helper/stringLables.dart';
import '../models/myRecord.dart';

abstract class MyRecordState {}

class MyRecordInitial extends MyRecordState {}

class MyRecordProgress extends MyRecordState {
  final List<MyRecord> oldMyRecordList;
  final bool isFirstFetch;
  final int currOffset;
  final int currPage;
  MyRecordProgress(this.oldMyRecordList, this.currOffset, this.currPage,
      {this.isFirstFetch = false});
}

class MyRecordSuccess extends MyRecordState {
  List<MyRecord> myyRecordList;
  final int currOffset;
  final int currPage;
  MyRecordSuccess(
      {required this.myyRecordList,
      required this.currOffset,
      required this.currPage});
}

class MyRecordFailure extends MyRecordState {
  final String errorMessage;
  MyRecordFailure(this.errorMessage);
}

class MyRecordCubit extends Cubit<MyRecordState> {
  MyRecordCubit() : super(MyRecordInitial());
  int page = 1;
  int offset = 0;
  bool isLoadmore = true;

  setInitialState() {
    page = 1;
    offset = 0;
    isLoadmore = true;
    emit(MyRecordInitial());
  }

  setReportItem({MyRecord? recordData, int? removeindex}) {
    final currentState = state;
    print("favdridlist=*currentState*$currentState");
    var oldPosts = <MyRecord>[];
    if (currentState is MyRecordSuccess) {
      oldPosts = currentState.myyRecordList;
    }
    if (recordData != null) {
      oldPosts.insert(0, recordData);
    } else {
      oldPosts.removeAt(removeindex!);
    }
    print("favdridlist=*oldPosts*====${oldPosts.length}");
    if (oldPosts.length == 0)
      emit(MyRecordFailure(getLables(dataNotFoundErrorMessage)));
    else
      emit(MyRecordSuccess(
          myyRecordList: oldPosts, currOffset: offset, currPage: page));
  }

  setOldList(int offsetval, int pageno, List<MyRecord> splist) {
    print("emptry-search--seltold==${splist.length}");
    page = pageno;
    offset = offsetval;
    isLoadmore = true;

    emit(MyRecordSuccess(
        myyRecordList: splist, currOffset: offset, currPage: page));
  }

  loadPosts(String url, BuildContext context, Map<String, String?> parameter,
      {bool isSetInitial = false}) {
    if (isSetInitial) {
      setInitialState();
    }
    print("pageno*==$state===$offset==Size==$isLoadmore");
    if (state is MyRecordProgress || !isLoadmore) return;

    final currentState = state;

    var oldPosts = <MyRecord>[];
    if (currentState is MyRecordSuccess) {
      oldPosts = currentState.myyRecordList;
      print(
          "pageno==${currentState.currOffset}===$offset==Size==${oldPosts.length}");
    }

    //emit(MyRecordProgress(oldPosts, page, isFirstFetch: page == 1));
    //parameter[ApiParams.page] = page.toString();
    emit(MyRecordProgress(oldPosts, offset, page, isFirstFetch: offset == 0));

    parameter[ApiParams.page] = page.toString();
    parameter[ApiParams.offset] = offset.toString();
    parameter[ApiParams.limit] = Constant.fetchLimit.toString();

    fetchMyRecordByPage(url, parameter, context).then((newPosts) {
     
      List<MyRecord> posts = [];
      //if (page != 1) {
      if (offset != 0 && state is MyRecordProgress) {
        posts = (state as MyRecordProgress).oldMyRecordList;
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
      emit(MyRecordSuccess(
          myyRecordList: posts, currOffset: curroffset, currPage: currpage));
      //emit(MyRecordSuccess(MyRecordList: posts, currPage: currpage));
    }).catchError((e) {
      isLoadmore = false;
      if (offset == 0) emit(MyRecordFailure(e.toString()));
      //if (page == 1) emit(MyRecordFailure(e.toString()));
    });
  }

  Future<Map> fetchMyRecordByPage(
      String url, Map<String, String?> parameter, BuildContext context) async {
    bool checkinternet = await GeneralMethods.checkInternet();
    if (!checkinternet) {
      throw CustomException(getLables(noInternetErrorMessage));
    } else {
      var response = await Api.sendApiRequest(url, parameter, true, context);
     
      if (response == null) {
        throw CustomException(getLables(dataNotFoundErrorMessage));
      } else {
        var getdata = json.decode(response);
        if (getdata[ApiParams.error]) {
          throw CustomException(getdata[ApiParams.message]);
        } else {
          List data = getdata['data'];
          List<MyRecord> favlist = [];
          print("getlist=parameter=${parameter["from"]}");
          if (parameter["from"] == "1") {
            favlist.addAll(
                data.map((e) => MyRecord.fromAppointmentMap(e)).toList());
          } else {
            favlist.addAll(data.map((e) => MyRecord.fromMap(e)).toList());
          }

          return {"list": favlist, "total": getdata["total"]};
        }
      }
    }
  }
}
