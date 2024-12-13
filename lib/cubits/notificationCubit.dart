import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../helper/api.dart';
import '../helper/apiParams.dart';
import '../helper/constant.dart';
import '../helper/customException.dart';
import '../helper/generalMethods.dart';
import '../helper/stringLables.dart';
import '../models/notificationData.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationProgress extends NotificationState {
  final List<NotificationData> oldNotificationList;
  final bool isFirstFetch;
  final int currOffset;
  final int currPage;
  NotificationProgress(this.oldNotificationList, this.currOffset, this.currPage,
      {this.isFirstFetch = false});
}

class NotificationSuccess extends NotificationState {
  List<NotificationData> NotificationList;
  final int currOffset;
  final int currPage;
  NotificationSuccess(
      {required this.NotificationList,
      required this.currOffset,
      required this.currPage});
}

class NotificationFailure extends NotificationState {
  final String errorMessage;
  NotificationFailure(this.errorMessage);
}

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationInitial());
  int page = 1;
  int offset = 0;
  bool isLoadmore = true;

  setInitialState() {
    page = 1;
    offset = 0;
    isLoadmore = true;
    emit(NotificationInitial());
  }

  setOldList(int offsetval, int pageno, List<NotificationData> splist) {
    print("emptry-search--seltold==${splist.length}");
    page = pageno;
    offset = offsetval;
    isLoadmore = true;

    emit(NotificationSuccess(
        NotificationList: splist, currOffset: offset, currPage: page));
  }

  loadPosts(BuildContext context, Map<String, String?> parameter,
      {bool isSetInitial = false}) {
    if (isSetInitial) {
      setInitialState();
    }
    print("pageno*==$state===$offset==Size==$isLoadmore");
    if (state is NotificationProgress || !isLoadmore) return;

    final currentState = state;

    var oldPosts = <NotificationData>[];
    if (currentState is NotificationSuccess) {
      oldPosts = currentState.NotificationList;
      print(
          "pageno==${currentState.currOffset}===$offset==Size==${oldPosts.length}");
    }

    //emit(NotificationProgress(oldPosts, page, isFirstFetch: page == 1));
    //parameter[ApiParams.page] = page.toString();
    emit(NotificationProgress(oldPosts, offset, page,
        isFirstFetch: offset == 0));

    parameter[ApiParams.page] = page.toString();
    parameter[ApiParams.offset] = offset.toString();
    parameter[ApiParams.limit] = Constant.fetchLimit.toString();

    fetchNotificationByPage(parameter, context).then((newPosts) {
      List<NotificationData> posts = [];
      //if (page != 1) {
      if (offset != 0 && state is NotificationProgress) {
        posts = (state as NotificationProgress).oldNotificationList;
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
      emit(NotificationSuccess(
          NotificationList: posts, currOffset: curroffset, currPage: currpage));
      //emit(NotificationSuccess(NotificationList: posts, currPage: currpage));
    }).catchError((e) {
      isLoadmore = false;
      if (offset == 0) emit(NotificationFailure(e.toString()));
      //if (page == 1) emit(NotificationFailure(e.toString()));
    });
  }

  Future<Map> fetchNotificationByPage(
      Map<String, String?> parameter, BuildContext context) async {
    bool checkinternet = await GeneralMethods.checkInternet();
    if (!checkinternet) {
      throw CustomException(getLables(noInternetErrorMessage));
    } else {
      var response = await Api.sendApiRequest(
          ApiParams.apiGetNotification, parameter, true, context);
     
      if (response == null) {
        throw CustomException(getLables(dataNotFoundErrorMessage));
      } else {
        var getdata = json.decode(response);
        if (getdata[ApiParams.error]) {
          throw CustomException(getdata[ApiParams.message]);
        } else {
          List data = getdata['data'];
          List<NotificationData> favlist = [];
          favlist
              .addAll(data.map((e) => NotificationData.fromJson(e)).toList());
        
          return {"list": favlist, "total": getdata["total"]};
        }
      }
    }
  }
}
