import 'dart:convert';

import 'package:tabebi/models/doctor.dart';
import 'package:tabebi/models/province.dart';
import 'package:tabebi/models/speciality.dart';

import '../helper/constant.dart';

class Hospital {
  int? id;
  String? name;
  String? image;
  int? noOfDoctor;
  int? noOfSpecialist;
  String? address;
  String? description;
  List<Speciality>? specialityList;
  List<Doctor>? doctorlist;
  String? totalrate;
  String? totalReviews;
  String? totalRatedUser;
  String? latitude;
  String? longitude;
  String? searchSubText;
  Province? city;

  Hospital(
      {this.id,
      this.latitude,
      this.longitude,
      this.name,
      this.image,
      this.noOfDoctor,
      this.noOfSpecialist,
      this.description,
      this.address,
      this.specialityList,
      this.totalrate,
      this.totalRatedUser,
      this.totalReviews,
      this.doctorlist,
      this.city});

  Hospital.fromDrJsonfromJson(Map<String, dynamic> map) {
    id = map['id'] ?? 0;
    name = map['first_name'] ?? map['name'] ?? "";
    image =
        map["profile"] != null && map["profile"].toString().trim().isNotEmpty
            ? Constant.hospitalImagePath + map["profile"]
            : "";
    address = map['address'] ?? "";
    searchSubText = map['address'] ?? "";
    longitude = map['longitude'] ?? "";
    latitude = map['latitude'] ?? "";
    if (map.containsKey("city") && map["city"] != null) {
      city = Province.fromCityJson(map["city"]);
    }
  }

  Hospital.fromJson(Map<String, dynamic> map) {
    id = map['id'] ?? 0;
    name = map['first_name'] ?? map['name'] ?? "";
    description = map['description'] ?? "";
    image =
        map["profile"] != null && map["profile"].toString().trim().isNotEmpty
            ? Constant.hospitalImagePath + map["profile"]
            : "";
    address = map['address'] ?? "";
    searchSubText = map['address'] ?? "";
    noOfDoctor = map['doctor_count'] ?? 0;
    noOfSpecialist = map['speciality_count'] ?? 0;
    totalrate = (map['rating'] ?? 0.0).toString();
    totalReviews = (map['reviews'] ?? 0).toString();
    totalRatedUser = (map['rating_count'] ?? 0).toString();
    specialityList = [];
    doctorlist = [];

    if (map.containsKey("speciality") && map["speciality"] != null) {
      List data = map["speciality"];
      specialityList!.addAll(data.map((e) => Speciality.fromJson(e)));
    }
    if (map.containsKey("city") && map["city"] != null) {
      city = Province.fromCityJson(map["city"]);
    }

    if (map.containsKey("doctor") && map["doctor"] != null) {
      List data = map["doctor"];
      doctorlist!.addAll(data.map((e) => Doctor.fromJson(e)));
    }
    longitude = map['longitude'] ?? "";
    latitude = map['latitude'] ?? "";
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': name,
      'latitude': latitude ?? "",
      'longitude': longitude ?? "",
      'profile': image!.replaceAll(Constant.hospitalImagePath, ""),
      'doctor_count': noOfDoctor,
      'speciality_count': noOfSpecialist,
      'address': address,
      'description': description,
      'speciality': specialityList == null
          ? null
          : specialityList!.map((x) => x.toMap()).toList(),
      'doctor': doctorlist == null
          ? null
          : doctorlist!.map((x) => x.toMap()).toList(),
      'rating': totalrate,
      'reviews': totalReviews,
      'rating_count': totalRatedUser,
      'city': city == null ? null : city!.toMap(),
    };
  }

  String toJson() => json.encode(toMap());
}
