import 'package:intl/intl.dart';
import 'package:tabebi/models/patient.dart';

import '../helper/constant.dart';
import '../helper/generalMethods.dart';
import '../helper/stringLables.dart';

class Review {
  String? name;
  String? image;
  String? createdDate;
  String? rate;
  String? comment;
  String? displaydays;
  Patient? patient;
  //
  int? id;
  String? appointmentId;
  int? userId;
  int? doctorId;
  double? rating;
  String? review;
  String? createdAt;
  String? updatedAt;
  int? days;
  Review({
    this.name,
    this.image,
    this.createdDate,
    this.rate,
    this.comment,
  });

  Review.fromMap(Map<String, dynamic> map) {
    createdDate = map['created_at'] ?? "";
    days = map['days'] ?? 0;
    rate = (map['rating'] ?? 0.0).toString();
    comment = map['review'] ?? "";

    displaydays = "";

    if (days! > 0) {
      displaydays = "$days ${getLables(lblDayAgo)}";
      if (days! > 1) {
        displaydays = "$days ${getLables(lblDaysAgo)}";
      }
    } else if (createdDate!.trim().isNotEmpty) {
      displaydays = DateFormat.jm(Constant.session!.getCurrLangCode())
          .format(Constant.timeParserSecond.parse(createdDate!));
    }
    name = "";
    image = "";
    if (map.containsKey("patient") && map["patient"] != null) {
      patient = Patient.fromJson(map["patient"]);
      name = patient!.name;
      image = patient!.image;
    }
  }
  Review.fromAppointment(Map<String, dynamic> json) {
    id = json['id'];
    appointmentId = (json['appointment_id'] ?? 0).toString();
    userId = json['user_id'];
    doctorId = json['doctor_id'];
    rating = double.parse((json['rating'] ?? Constant.defaultRate).toString());
    review = json['review'] ?? "";
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    days = json['days'];
  }
}
