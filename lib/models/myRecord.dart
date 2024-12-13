import 'package:tabebi/models/appointment.dart';

import '../helper/constant.dart';
import 'attachement.dart';

class MyRecord {
  String? title;
  String? patientname;
  String? createdDate;
  String? drName;
  String? note;
  List<Attachment>? attachmentlist;
  Appointment? appointment;
  int? id;
  int? userID;
  int? status;
  
  

  MyRecord(
      {this.title,
      this.patientname,
      this.createdDate,
      this.drName,
      this.note,
      this.status,
      this.attachmentlist,
      this.appointment});

  MyRecord.fromMap(Map<String, dynamic> map) {
    title = map["title"] ?? "";
    userID = map["user_id"] ?? 0;
    id = map["id"] ?? 0;
    status = map["status"] ?? 0;
    patientname = map["name"] ?? "";
    if (patientname!.trim().isEmpty) {
      patientname = Constant.userdata!.name!;
    }
    createdDate = "${map['date']} ${map['time']}";
    drName = map['doctor_name'] ?? "";
    note = map['note'] ?? "";
    attachmentlist = [];
    if (map["files"] != null) {
      List attachment = map["files"];
      attachmentlist!
          .addAll(attachment.map((e) => Attachment.fromReportJson(e)).toList());
    }
  }
  MyRecord.fromAppointmentMap(Map<String, dynamic> map) {
    appointment = Appointment.fromDrJson(map);
    title = "";
    patientname = appointment!.displayName!;
    createdDate = "${appointment!.date} ${appointment!.time}";
    drName = Constant.session!.getCurrLangCode() == Constant.arabicLanguageCode
        ? appointment!.doctor!.nameAr!
        : appointment!.doctor!.nameEng!;
    attachmentlist = appointment!.attachmentlist!;
  }
}
