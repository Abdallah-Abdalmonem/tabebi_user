import 'package:tabebi/helper/constant.dart';
import 'package:tabebi/models/attachement.dart';
import 'package:tabebi/models/lab.dart';
import 'package:tabebi/models/labTest.dart';
import 'package:tabebi/models/review.dart';

import 'doctor.dart';

class Appointment {
  int? id;
  int? userId;
  int? doctorAddedId;
  int? doctorId;
  int? status;
  int? type;
  String? date;
  String? time;
  String? fees;
  int? behalfOf;
  String? patientName;
  String? patientPhone;
  String? displayName;
  String? displayPhone;
  Review? review;
  List<Attachment>? attachmentlist;
  Doctor? doctor;

  List<String>? testIds;
  List<LabTest>? testlist;

  //lab
  int? labId;
  Lab? lab;

  Appointment(
      {this.id,
      this.userId,
      this.doctorId,
      this.testIds,
      this.testlist,
      this.doctorAddedId,
      this.status,
      this.type,
      this.date,
      this.time,
      this.fees,
      this.behalfOf,
      this.patientName,
      this.patientPhone,
      this.review,
      this.attachmentlist,
      this.doctor,
      this.labId,
      this.lab});

  Appointment.fromDrJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    doctorId = json['doctor_id'];
    status = json['status'];
    type = json['type'];
    date = json['date'];
    time = json['time'];
    fees = (json['fees'] ?? 0).toString();
    behalfOf = json['behalf_of'];
    patientName = json['name'] ?? "";
    patientPhone = json['phone'] ?? "";
    displayName = behalfOf == 1 ? patientName : Constant.userdata!.name!;
    displayPhone = behalfOf == 1 ? patientPhone : Constant.userdata!.mobileno!;

    review = json.containsKey("review") && json['review'] != null
        ? Review.fromAppointment(json["review"])
        : null;
    attachmentlist = [];
    if (json["attachment"] != null) {
      List attachment = json["attachment"];
      attachmentlist!
          .addAll(attachment.map((e) => Attachment.fromJson(e)).toList());
    }
    doctor = json['doctor'] != null
        ? Doctor.fromAppointmentJson(json['doctor'])
        : null;
  }
  Appointment.fromLabJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    doctorId = json['doctor_id'];
    doctorAddedId = json['doctor_added_id'];
    status = json['status'];
    type = json['type'];
    testIds = json["test_id"].toString().split(",");
    date = json['date'];
    time = json['time'];
    fees = (json['fees'] ?? 0).toString();
    behalfOf = json['behalf_of'];
    patientName = json['name'] ?? "";
    patientPhone = json['phone'] ?? "";
    displayName = behalfOf == 1 ? patientName : Constant.userdata!.name!;
    displayPhone = behalfOf == 1 ? patientPhone : Constant.userdata!.mobileno!;

    review = json.containsKey("review") && json['review'] != null
        ? Review.fromAppointment(json["review"])
        : null;
    attachmentlist = [];
    if (json["attachment"] != null) {
      List attachment = json["attachment"];
      attachmentlist!
          .addAll(attachment.map((e) => Attachment.fromJson(e)).toList());
    }
    testlist = [];
    if (json["test_name"] != null) {
      List test = json["test_name"];
      testlist!.addAll(test.map((e) => LabTest.fromJson(e)).toList());
    }
    lab = json['lab'] != null ? Lab.fromAppointmentJson(json['lab']) : null;
  }
}
