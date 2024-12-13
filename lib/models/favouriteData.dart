import 'package:tabebi/helper/constant.dart';

class FavouriteData {
  int? id;
  int? userId;
  int? favouriteId;
  String? type;
  FavouriteData? favouriteData;
  //Doctor? doctor;
  String? phone;
  String? nameEng;
  String? nameAr;
  String? fname;
  String? lname;
  String? fnameAr;
  String? lnameAr;
  String? image;
  String? totalAppointments;
  String? totalReviews;
  String? rates;

  FavouriteData({this.id, this.userId, this.favouriteId, this.type});

  FavouriteData.fromJson(Map<String, dynamic> map) {
    id = map['id'] ?? 0;
    userId = map['user_id'] ?? 0;
    favouriteId = map["favourite_id"] ?? 0;
    type = map["type"].toString();
    /*  if (type == Constant.appointmentDoctor) {
      doctor = map['data'] != null ? Doctor.fromFavJson(map['data']) : null;
    } */

    favouriteData = map['data'] != null
        ? FavouriteData.fromFavJson(map['data'], type.toString())
        : null;
  }
  FavouriteData.fromFavJson(Map<String, dynamic> map, String type) {
    id = map['id'] ?? 0;
    phone = map['phone'];
    totalAppointments = (map['appointment_count'] ?? 0).toString();
    totalReviews = (map['reviews'] ?? 0).toString();
    rates = (map['rating'] ?? 0.0).toString();
    fname = map['first_name'] ?? "";
    lname = map['last_name'] ?? "";

    fnameAr = map['first_name1'] ?? "";
    lnameAr = map['last_name1'] ?? "";

    nameEng = "$fname $lname";
    nameAr = "$fnameAr $lnameAr";
    if (nameAr!.trim().isEmpty) {
      nameAr = nameEng;
    }
    if (type == Constant.appointmentDoctor) {
      image =
          map['profile'] != null && map['profile'].toString().trim().isNotEmpty
              ? Constant.doctorImagePath + map['profile']
              : "";
    } else {
      image =
          map['profile'] != null && map['profile'].toString().trim().isNotEmpty
              ? Constant.labImagePath + map['profile']
              : "";
    }
  }
}
