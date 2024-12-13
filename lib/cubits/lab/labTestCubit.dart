import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabebi/models/labTest.dart';
import '../../helper/api.dart';
import '../../helper/apiParams.dart';
import '../../helper/constant.dart';
import '../../helper/customException.dart';
import '../../helper/generalMethods.dart';
import '../../helper/stringLables.dart';

abstract class LabTestState {}

class LabTestInitial extends LabTestState {}

class LabTestProgress extends LabTestState {
  List<LabTest> labTestList;
  final bool isFirstFetch;
  final int currOffset;
  final int currPage;
  LabTestProgress(
      {required this.labTestList,
      required this.currOffset,
      required this.currPage,
      this.isFirstFetch = false});
}

class LabTestSuccess extends LabTestState {
  List<LabTest> labTestList;
  final int currOffset;
  final int currPage;
  LabTestSuccess(
      {required this.labTestList,
      required this.currOffset,
      required this.currPage});
}

class LabTestFailure extends LabTestState {
  final String errorMessage;
  LabTestFailure(this.errorMessage);
}

class LabTestCubit extends Cubit<LabTestState> {
  LabTestCubit() : super(LabTestInitial());
  int page = 1;
  int offset = 0;
  bool isLoadmore = true;

  setInitialState() {
    page = 1;
    offset = 0;
    isLoadmore = true;
    emit(LabTestInitial());
  }

  setOldList(int offsetval, int pageno, List<LabTest> splist) {
    print("emptry-search--seltold==${splist.length}");
    page = pageno;
    offset = offsetval;
    isLoadmore = true;

    emit(LabTestSuccess(
        labTestList: splist, currOffset: offset, currPage: page));
  }

  getLabTestList(BuildContext context, Map<String, String?> parameter,
      {bool isSetInitial = false}) {
    if (isSetInitial) {
      setInitialState();
    }
    print("detailpage--labtest=$state==");
    if (state is LabTestProgress || !isLoadmore) return;

    final currentState = state;

    var oldPosts = <LabTest>[];
    if (currentState is LabTestSuccess) {
      oldPosts = currentState.labTestList;
      print(
          "pageno==${currentState.currOffset}===$offset==Size==${oldPosts.length}");
    }
    print("detailpage--labtest=$state==LabTestProgress");
    emit(LabTestProgress(
        labTestList: oldPosts,
        currOffset: offset,
        currPage: page,
        isFirstFetch: offset == 0));

    parameter[ApiParams.page] = page.toString();
    parameter[ApiParams.offset] = offset.toString();
    parameter[ApiParams.limit] = Constant.specialityFetchLimit.toString();
    print("detailpage--labtest=$state==fetchSpecialityByPage");
    fetchSpecialityByPage(parameter, context).then((newPosts) {
      List<LabTest> posts = [];
      //if (page != 1) {
      if (offset != 0 && state is LabTestProgress) {
        posts = (state as LabTestProgress).labTestList;
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

      emit(LabTestSuccess(
          labTestList: posts, currOffset: curroffset, currPage: currpage));
      //emit(SpecialitySuccess(specialityList: posts, currPage: currpage));
    }).catchError((e) {
      isLoadmore = false;
      if (offset == 0) emit(LabTestFailure(e.toString()));
      //if (page == 1) emit(SpecialityFailure(e.toString()));
    });
  }

  Future<Map> fetchSpecialityByPage(
      Map<String, String?> parameter, BuildContext context) async {
    bool checkinternet = await GeneralMethods.checkInternet();
    if (!checkinternet) {
      throw CustomException(getLables(noInternetErrorMessage));
    } else {
      var response = await Api.sendApiRequest(
          ApiParams.apiGetLabTest, parameter, true, context);
     
      if (response == null) {
        throw CustomException(getLables(dataNotFoundErrorMessage));
      } else {
        var getdata = json.decode(response);
        if (getdata[ApiParams.error]) {
          throw CustomException(getdata[ApiParams.message]);
        } else {
          List data = getdata['data'];
          List<LabTest> favlist = [];
          favlist.addAll(data
              .map((e) => LabTest.fromJson(
                    e,
                  ))
              .toList());

          return {"list": favlist, "total": getdata["total"]};
        }
      }
    }
  }
}
