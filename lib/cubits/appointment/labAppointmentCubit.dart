import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabebi/helper/apiParams.dart';
import 'package:tabebi/models/appointment.dart';
import '../../helper/api.dart';
import '../../helper/constant.dart';
import '../../helper/customException.dart';
import '../../helper/generalMethods.dart';
import '../../helper/stringLables.dart';

@immutable
abstract class LabAppointmentState {}

class LabAppointmentInitial extends LabAppointmentState {}

class LabAppointmentLoaded extends LabAppointmentState {
  final List<Appointment> labList;
  final int currPage;
  final int currOffset;

  LabAppointmentLoaded(
      {required this.labList,
      required this.currOffset,
      required this.currPage});
}

class LabAppointmentLoading extends LabAppointmentState {
  final List<Appointment> oldLabList;
  final bool isFirstFetch;
  final int currOffset;
  final int currPage;
  LabAppointmentLoading(this.oldLabList, this.currOffset, this.currPage,
      {this.isFirstFetch = false});
}

class LabAppointmentFailure extends LabAppointmentState {
  final String errorMessage;
  LabAppointmentFailure(this.errorMessage);
}

class LabAppointmentCubit extends Cubit<LabAppointmentState> {
  LabAppointmentCubit() : super(LabAppointmentInitial());

  int page = 1;
  int offset = 0;
  bool isLoadmore = true;

  setInitialState() {
    page = 1;
    offset = 0;
    isLoadmore = true;
    emit(LabAppointmentInitial());
  }

  setOldList(int offsetval, int pageno, List<Appointment> drlist) {
    print("emptry-search--seltold==${drlist.length}");
    page = pageno;
    offset = offsetval;
    isLoadmore = true;
    //emit(LabInitial());
    emit(LabAppointmentLoaded(
        labList: drlist, currOffset: offsetval, currPage: pageno));
  }

  loadPosts(BuildContext context, Map<String, String?> parameter,
      {bool isSetInitial = false}) {
    if (isSetInitial) {
      setInitialState();
    }

    if (state is LabAppointmentLoading || !isLoadmore) return;

    final currentState = state;

    var oldPosts = <Appointment>[];
    if (currentState is LabAppointmentLoaded) {
      oldPosts = currentState.labList;
    }

    emit(LabAppointmentLoading(oldPosts, offset, page,
        isFirstFetch: offset == 0));
    parameter[ApiParams.page] = page.toString();
    parameter[ApiParams.offset] = offset.toString();
    parameter[ApiParams.limit] = Constant.fetchLimit.toString();

    fetchLabs(parameter, context).then((newPosts) {
      List<Appointment> posts = [];
      if (offset != 1 && state is LabAppointmentLoading) {
        posts = (state as LabAppointmentLoading).oldLabList;
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
      emit(LabAppointmentLoaded(
          labList: posts, currOffset: curroffset, currPage: currpage));
    }).catchError((e) {
      isLoadmore = false;

      if (offset == 0) emit(LabAppointmentFailure(e.toString()));
    });
  }

  Future<Map> fetchLabs(
      Map<String, String?> parameter, BuildContext context) async {
    bool checkinternet = await GeneralMethods.checkInternet();
    if (!checkinternet) {
      throw CustomException(getLables(noInternetErrorMessage));
    } else {
      var response = await Api.sendApiRequest(
          ApiParams.apiGetAppointment, parameter, true, context);
      
      if (response == null) {
        throw CustomException(getLables(dataNotFoundErrorMessage));
      } else {
        var getdata = json.decode(response);
        if (getdata[ApiParams.error]) {
          throw CustomException(getdata[ApiParams.message]);
        } else {
          List data = getdata['data'];
          List<Appointment> favlist = [];
          favlist.addAll(data.map((e) => Appointment.fromLabJson(e)).toList());
          return {"list": favlist, "total": getdata["total"]};
        }
      }
    }
  }
}
