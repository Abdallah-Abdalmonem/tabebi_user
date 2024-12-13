import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../helper/api.dart';
import '../../helper/apiParams.dart';
import '../../helper/customException.dart';
import '../../helper/generalMethods.dart';
import '../../helper/stringLables.dart';
import '../models/slotData.dart';

abstract class SlotState {}

class SlotInitial extends SlotState {}

class SlotProgress extends SlotState {
  SlotProgress();
}

class SlotSuccess extends SlotState {
  List<SlotData>? slotlist;
  bool allslotempty;
  SlotSuccess(this.slotlist, this.allslotempty);
}

class SlotSelect extends SlotState {
  List<SlotData>? slotlist;
  DateTime? selectedDate;
  DateTime? selectedTime;
  String? waitingtime;
  SlotSelect(this.slotlist, this.selectedDate, this.selectedTime,this.waitingtime);
}

class SlotFailure extends SlotState {
  final String errorMessage;
  SlotFailure(this.errorMessage);
}

class SlotCubit extends Cubit<SlotState> {
  SlotCubit() : super(SlotInitial());

  getSlotList(BuildContext context, Map<String, String?> parameter) {
    emit(SlotProgress());
    slotProcess(context, parameter).then((value) {
      emit(SlotSuccess(value["list"], value["allslotempty"]));
    }).catchError((e) {
      emit(SlotFailure(e.toString()));
    });
  }

  changeSlotTime(List<SlotData>? slotlist, DateTime? selectedDate,
      DateTime? selectedTime,String waitingtime) {
    emit(SlotSelect(slotlist, selectedDate, selectedTime,waitingtime));
  }

  Future<Map> slotProcess(
      BuildContext context, Map<String, String?> parameter) async {
    bool checkinternet = await GeneralMethods.checkInternet();
    if (!checkinternet) {
      throw CustomException(getLables(noInternetErrorMessage));
    } else {
      var response = await Api.sendApiRequest(
          ApiParams.apiGetSlot, parameter, true, context);

      if (response == "null" || response == null) {
        throw CustomException(getLables(dataNotFoundErrorMessage));
      } else {
        var getdata = json.decode(response);

        if (getdata[ApiParams.error]) {
          throw CustomException(getdata[ApiParams.message]);
        } else {
          List data = getdata['data'];
          List<SlotData> slotlist = [];
          bool allslotempty = true;
          slotlist.addAll(data.map((e) {
            SlotData slotData = SlotData.fromJson(e);
            if (allslotempty && slotData.allSlot!.isNotEmpty) {
              allslotempty = false;
            }
            return slotData;
          }).toList());
          return {"list": slotlist, "allslotempty": allslotempty};
        }
      }
    }
  }
}
