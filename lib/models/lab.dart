import 'dart:convert';

import 'package:tabebi/models/attachement.dart';
import 'package:tabebi/models/review.dart';

import '../helper/constant.dart';
import 'labTest.dart';
import 'province.dart';
import 'schedule.dart';
import 'totalExperience.dart';

class Lab {
  int? id;
  String? name;
  String? image;
  List<Schedule>? schedulelist;
  double? offer;
  List<LabTest>? labTestlist = [];
  String? labAddress;
  String? labInfo;
  String? totalrate;
  String? totalReviews;
  String? totalVisitor;
  //String? waitingTime;
  //String? experience;
  bool? isFavourite;
  //
  double? totalTestAmt;
  double? totalTestOfferAmt;

  //
  String? patientName;
  String? patientPhoneNumber;
  String? appointmentDateTime;
  String? testlist;
  int? status;
  Review? review;
  List<Attachment>? attachmentlist;
  String? directionInfo;
  String? address;
  Province? city;
  String? latitude;
  String? longitude;
  String? searchSubText;
  TotalExperience? totalExperience;
  //
  Lab({
    this.id,
    this.name,
    this.image,
    this.offer,
    this.schedulelist,
    this.labInfo,
    this.labAddress,
    this.totalrate,
    this.totalVisitor,
    this.totalReviews,
   // this.waitingTime,
    this.totalExperience,
    this.labTestlist,
    this.address,
    this.city,
    this.latitude,
    this.longitude,
  });
  Lab.fromAppointmentJson(Map<String, dynamic> map) {
    id = map['id'] ?? 0;
    name = map['first_name'] ?? "";
    image =
        map["profile"] != null && map["profile"].toString().trim().isNotEmpty
            ? Constant.labImagePath + map["profile"]
            : "";
    labAddress = map['address'] ?? "";
    labInfo = map['description'] ?? "";
    totalVisitor = (map['counter'] ?? 0).toString();
    totalReviews = (map['reviews'] ?? 0).toString();
    longitude = map['longitude'] ?? "";
    latitude = map['latitude'] ?? "";
  }
  Lab.fromSearchJson(Map<String, dynamic> map) {
    id = map['id'] ?? 0;
    name = map['first_name'] ?? map['name'] ?? "";
    image =
        map["profile"] != null && map["profile"].toString().trim().isNotEmpty
            ? Constant.labImagePath + map["profile"]
            : "";
    address = map['address'] ?? "";
    searchSubText = map['address'] ?? "";
    if (map.containsKey("city") && map["city"] != null) {
      city = Province.fromCityJson(map["city"]);
    }
    longitude = map['longitude'] ?? "";
    latitude = map['latitude'] ?? "";
  }

  Lab.fromJson(Map<String, dynamic> map) {
    id = map['id'] ?? 0;
    name = map['first_name'] ?? "";
    image =
        map["profile"] != null && map["profile"].toString().trim().isNotEmpty
            ? Constant.labImagePath + map["profile"]
            : "";
    totalReviews = (map['reviews'] ?? 0).toString();
    totalrate = (map['rating'] ?? 0.0).toString();
    isFavourite = (map["favourite"] ?? 0) == 1;
    //waitingTime = (map['waiting_time'] ?? 0).toString();
    labTestlist = [];
    if (map.containsKey("labtest")) {
      List data = map["labtest"];
      labTestlist!.addAll(data.map((e) => LabTest.fromJson(e)));
    }
    schedulelist = [];
    if (map.containsKey("schedule")) {
      List data = map["schedule"];
      schedulelist!.addAll(data.map((e) => Schedule.fromJson(e)));
    }
    labInfo = map['description'] ?? "";
    offer = double.parse((map['discount'] ?? 0).toString());
    labAddress = map['address'] ?? "";
    //experience = (map['total_experience'] ?? 0).toString();
    if (map.containsKey("total_experience") &&
        map["total_experience"] != null) {
      totalExperience = TotalExperience.fromJson(map["total_experience"]);
    }
    totalVisitor = (map['counter'] ?? 0).toString();
    longitude = map['longitude'] ?? "";
    latitude = map['latitude'] ?? "";
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': name,
      'profile': image!.replaceAll(Constant.labImagePath, ""),
      'address': address,
      'city': city == null ? null : city?.toMap(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
