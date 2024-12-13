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

@immutable
abstract class FavDoctorState {}

class FavDoctorInitial extends FavDoctorState {}

class FavDoctorLoaded extends FavDoctorState {
  final List<FavouriteData> favDoctorList;
  final int currOffset;
  final int currPage;

  FavDoctorLoaded(
      {required this.favDoctorList,
      required this.currOffset,
      required this.currPage});
}

class FavDoctorLoading extends FavDoctorState {
  final List<FavouriteData> oldDrList;
  final bool isFirstFetch;
  final int currOffset;
  final int currPage;
  FavDoctorLoading(this.oldDrList, this.currOffset, this.currPage,
      {this.isFirstFetch = false});
}

class FavDoctorFailure extends FavDoctorState {
  final String errorMessage;
  FavDoctorFailure(this.errorMessage);
}

class FavDoctorCubit extends Cubit<FavDoctorState> {
  FavDoctorCubit() : super(FavDoctorInitial());
  int page = 1;
  int offset = 0;
  bool isLoadmore = true;

  setInitialState() {
    page = 1;
    offset = 0;
    isLoadmore = true;
    emit(FavDoctorInitial());
  }

  setOldList(int offsetval, int pageno, List<FavouriteData> drlist) {
    print("emptry-search--seltold==${drlist.length}");
    page = pageno;
    offset = offsetval;
    isLoadmore = true;

    emit(FavDoctorLoaded(
        favDoctorList: drlist, currOffset: offset, currPage: page));
  }

  setFavUnFavItem({FavouriteData? favouriteData, int? removeindex}) {
    final currentState = state;
    print("favdridlist=*currentState*$currentState");
    var oldPosts = <FavouriteData>[];
    if (currentState is FavDoctorLoaded) {
      oldPosts = currentState.favDoctorList;
    }
    print(
        "favdridlist=*oldPosts*${oldPosts.length}===${removeindex == null}==$removeindex");
    if (favouriteData != null) {
      oldPosts.insert(0, favouriteData);
    } else {
      oldPosts.removeAt(removeindex!);
    }
    print("favdridlist=*oldPosts*====${oldPosts.length}");
    if (oldPosts.length == 0)
      emit(FavDoctorFailure(getLables(dataNotFoundErrorMessage)));
    else
      emit(FavDoctorLoaded(
          favDoctorList: oldPosts, currOffset: offset, currPage: page));
  }

  loadPosts(BuildContext context, Map<String, String?> parameter,
      {bool isSetInitial = false}) {
    if (isSetInitial) {
      setInitialState();
    }

    if (state is FavDoctorLoading || !isLoadmore) return;

    final currentState = state;

    var oldPosts = <FavouriteData>[];
    if (currentState is FavDoctorLoaded) {
      oldPosts = currentState.favDoctorList;
    }

    emit(FavDoctorLoading(oldPosts, offset, page, isFirstFetch: offset == 0));
    parameter[ApiParams.page] = page.toString();
    parameter[ApiParams.offset] = offset.toString();
    parameter[ApiParams.limit] = Constant.specialityFetchLimit.toString();
    parameter[ApiParams.apiType] = ApiParams.get;

    fetchFavDoctors(parameter, context).then((newPosts) {
     
      List<FavouriteData> posts = [];
      if (offset != 0 && state is FavDoctorLoading) {
        posts = (state as FavDoctorLoading).oldDrList;
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
      emit(FavDoctorLoaded(
          favDoctorList: posts, currOffset: curroffset, currPage: currpage));
    }).catchError((e) {
      isLoadmore = false;
      if (offset == 0) emit(FavDoctorFailure(e.toString()));
    });
  }

  Future<Map> fetchFavDoctors(
      Map<String, String?> parameter, BuildContext context) async {
    bool checkinternet = await GeneralMethods.checkInternet();
    if (!checkinternet) {
      throw CustomException(getLables(noInternetErrorMessage));
    } else {
      var response = await Api.sendApiRequest(
          ApiParams.apiFavourite, parameter, true, context);
      
      if (response == null) {
        throw CustomException(getLables(dataNotFoundErrorMessage));
      } else {
        var getdata = json.decode(response);
        print("state-err-${getdata[ApiParams.error]}");
        if (getdata[ApiParams.error]) {
          throw CustomException(getdata[ApiParams.message]);
        } else {
          List data = getdata['data'];
          List<FavouriteData> favlist = [];
          print("state-data-${data.length}");
          favlist.addAll(data.map((e) => FavouriteData.fromJson(e)).toList());
          print("state-favlist-${favlist.length}");
          return {"list": favlist, "total": getdata["total"]};
        }
      }
    }
  }

  Future<Map> favUnfavDoctor(String drid, String favunfavval,
      BuildContext context, String type) async {
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
            ApiParams.type: type
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
          return {"favid": getdata};
        }
      }
    }
  }
}
