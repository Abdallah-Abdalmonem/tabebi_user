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
abstract class DoctorAppointmentState {}

class DoctorAppointmentInitial extends DoctorAppointmentState {}

class DoctorAppointmentLoaded extends DoctorAppointmentState {
  final List<Appointment> appointmentList;
  final int currPage;
  final int currOffset;

  DoctorAppointmentLoaded(
      {required this.appointmentList,
      required this.currOffset,
      required this.currPage});
}

class DoctorAppointmentLoading extends DoctorAppointmentState {
  final List<Appointment> oldAppointmentList;
  final bool isFirstFetch;
  final int currOffset;
  final int currPage;
  DoctorAppointmentLoading(
      this.oldAppointmentList, this.currOffset, this.currPage,
      {this.isFirstFetch = false});
}

class DoctorAppointmentFailure extends DoctorAppointmentState {
  final String errorMessage;
  DoctorAppointmentFailure(this.errorMessage);
}

class DoctorAppointmentCubit extends Cubit<DoctorAppointmentState> {
  DoctorAppointmentCubit() : super(DoctorAppointmentInitial());

  int page = 1;
  int offset = 0;
  bool isLoadmore = true;

  setInitialState() {
    page = 1;
    offset = 0;
    isLoadmore = true;
    emit(DoctorAppointmentInitial());
  }

  setOldList(int offsetval, int pageno, List<Appointment> drlist) {
    print("emptry-search--seltold==${drlist.length}");
    page = pageno;
    offset = offsetval;
    isLoadmore = true;
    //emit(DoctorInitial());
    emit(DoctorAppointmentLoaded(
        appointmentList: drlist, currOffset: offsetval, currPage: pageno));
  }

  loadPosts(BuildContext context, Map<String, String?> parameter,
      {bool isSetInitial = false}) {
    if (isSetInitial) {
      setInitialState();
    }

    if (state is DoctorAppointmentLoading || !isLoadmore) return;

    final currentState = state;

    var oldPosts = <Appointment>[];
    if (currentState is DoctorAppointmentLoaded) {
      oldPosts = currentState.appointmentList;
    }

    emit(DoctorAppointmentLoading(oldPosts, offset, page,
        isFirstFetch: offset == 0));
    parameter[ApiParams.page] = page.toString();
    parameter[ApiParams.offset] = offset.toString();
    parameter[ApiParams.limit] = Constant.fetchLimit.toString();

    fetchDoctors(parameter, context).then((newPosts) {
    
      List<Appointment> posts = [];
      //if (page != 1) {
      if (offset != 0 && state is DoctorAppointmentLoading) {
        posts = (state as DoctorAppointmentLoading).oldAppointmentList;
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
      emit(DoctorAppointmentLoaded(
          currOffset: curroffset, currPage: currpage, appointmentList: posts));
    }).catchError((e) {
      isLoadmore = false;
      if (offset == 0) emit(DoctorAppointmentFailure(e.toString()));
      //if (page == 1) emit(DoctorAppointmentFailure(e.toString()));
    });
  }

  Future<Map> fetchDoctors(
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
          favlist.addAll(data.map((e) => Appointment.fromDrJson(e)).toList());
          return {"list": favlist, "total": getdata["total"]};
        }
      }
      /*String url =
          "https://protocoderspoint.com/jsondata/superheros.json?limit=${Constant.fetchLimit}&page=${parameter[ApiParams.page]}";
      if (parameter.containsKey(ApiParams.search)) {
        url = url + "&${ApiParams.search}=${parameter[ApiParams.search]}";
      }

      var response = await Api.sendApiRequest(url, parameter, true, context);
      
      if (response == null) {
        throw CustomException(getLables(dataNotFoundErrorMessage));
      } else {
        var getdata = json.decode(response);

        print("state-get-${getdata == null}");

        if (getdata != null) {
          List data = getdata["superheros"];
          print("state-get-data---${data.length}");
          List<Doctor> drlist = [];
          drlist
              .addAll(data.map((e) => Doctor.fromAppointmentJson(e)).toList());
          bool isloadnext = drlist.isNotEmpty;
          print("state-get-data-dr--${drlist.length}");
          return {"list": drlist, "isloadnext": isloadnext};
        } else {
          print("state-get-else");
          throw CustomException(getdata[ApiParams.message]);
        }
      }*/
    }
  }
}
