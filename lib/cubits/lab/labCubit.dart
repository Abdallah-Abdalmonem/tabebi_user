import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabebi/helper/apiParams.dart';
import '../../helper/api.dart';
import '../../helper/constant.dart';
import '../../helper/customException.dart';
import '../../helper/generalMethods.dart';
import '../../helper/stringLables.dart';
import '../../models/favouriteData.dart';
import '../../models/lab.dart';

@immutable
abstract class LabState {}

class LabInitial extends LabState {}

class LabLoaded extends LabState {
  final List<Lab> labList;
  final int currPage;
  final int currOffset;

  LabLoaded(
      {required this.labList,
      required this.currOffset,
      required this.currPage});
}

class LabLoading extends LabState {
  final List<Lab> oldLabList;
  final bool isFirstFetch;
  final int currOffset;
  final int currPage;
  LabLoading(this.oldLabList, this.currOffset, this.currPage,
      {this.isFirstFetch = false});
}

class LabFailure extends LabState {
  final String errorMessage;
  LabFailure(this.errorMessage);
}

class LabCubit extends Cubit<LabState> {
  LabCubit() : super(LabInitial());

  int page = 1;
  int offset = 0;
  bool isLoadmore = true;

  setInitialState() {
    page = 1;
    offset = 0;
    isLoadmore = true;
    emit(LabInitial());
  }

  setOldList(int offsetval, int pageno, List<Lab> lablist) {
    print("emptry-search--seltold==${lablist.length}");
    page = pageno;
    offset = offsetval;
    isLoadmore = true;
    //emit(LabInitial());
    emit(LabLoaded(labList: lablist, currOffset: offset, currPage: page));
  }

  loadPosts(BuildContext context, Map<String, String?> parameter,
      {bool isSetInitial = false}) {
    if (isSetInitial) {
      setInitialState();
    }

    if (state is LabLoading || !isLoadmore) return;

    final currentState = state;

    var oldPosts = <Lab>[];
    if (currentState is LabLoaded) {
      oldPosts = currentState.labList;
    }

    emit(LabLoading(oldPosts, offset, page, isFirstFetch: offset == 0));
    parameter[ApiParams.page] = page.toString();
    parameter[ApiParams.offset] = offset.toString();
    parameter[ApiParams.limit] = Constant.fetchLimit.toString();

    fetchLabs(parameter, context).then((newPosts) {
      
      List<Lab> posts = [];
      if (offset != 0 && state is LabLoading) {
        posts = (state as LabLoading).oldLabList;
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
      emit(LabLoaded(
          labList: posts, currOffset: curroffset, currPage: currpage));
    }).catchError((e) {
      isLoadmore = false;
      if (offset == 0) emit(LabFailure(e.toString()));
    });
  }

  Future<Map> fetchLabs(
      Map<String, String?> parameter, BuildContext context) async {
    bool checkinternet = await GeneralMethods.checkInternet();
    if (!checkinternet) {
      throw CustomException(getLables(noInternetErrorMessage));
    } else {
      var response = await Api.sendApiRequest(
          ApiParams.apiGetLab, parameter, true, context);
      if (response == null) {
        throw CustomException(getLables(dataNotFoundErrorMessage));
      } else {
        var getdata = json.decode(response);
        if (getdata[ApiParams.error]) {
          throw CustomException(getdata[ApiParams.message]);
        } else {
          List data = getdata['data'];
          List<Lab> favlist = [];
          favlist.addAll(data.map((e) => Lab.fromJson(e)).toList());
          return {"list": favlist, "total": getdata["total"]};
        }
      }
    }
  }

  Future<FavouriteData?> favUnfavDoctor(
      String labid, String favunfavval, BuildContext context) async {
    bool checkinternet = await GeneralMethods.checkInternet();
    if (!checkinternet) {
      throw CustomException(getLables(noInternetErrorMessage));
    } else {
      var response = await Api.sendApiRequest(
          ApiParams.apiFavourite,
          {
            ApiParams.id: labid,
            ApiParams.status: favunfavval,
            ApiParams.apiType: ApiParams.set,
            ApiParams.type: Constant.appointmentLab
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
