import 'package:tabebi/models/hospital.dart';
import 'package:tabebi/models/schedule.dart';
import 'package:tabebi/models/speciality.dart';
import 'package:tabebi/models/totalExperience.dart';

import '../helper/constant.dart';

class Doctor {
  int? id;
  String? nameEng;
  String? name;
  String? searchSubText;
  String? nameAr;
  String? fname;
  String? lname;
  String? fnameAr;
  String? lnameAr;
  String? image;
  String? totalAppointments;
  String? totalReviews;
  String? rates;
  String? drInfoEng;
  String? drInfoAr;
  String? drAddress;
  String? drFees;
  String? qualification;
  //String? drWaitingTime;
  String? phone;
  TotalExperience? totalExperience;
  Hospital? hospital;
  List<String>? subspecialties = [];
  List<String>? subspecialityIds = [];
  int? specialityId;
  Speciality? speciality;
  List<Schedule>? schedulelist;
  bool? isFavourite;
  //
  String? patientName;
  String? patientPhoneNumber;
  String? appointmentDateTime;
  String? hospitalName;
  String? status;
  bool? isReviewAdded;
  String? directionInfo;

  //
  Doctor(
      {this.id,
      this.isFavourite,
      this.nameEng,
      this.image,
      this.totalAppointments,
      this.totalReviews,
      this.rates,
      this.drInfoEng,
      this.drAddress,
      this.drFees,
      this.nameAr,
      //this.drWaitingTime,
      this.hospital,
      this.subspecialties,
      this.patientName,
      this.fname,
      this.totalExperience,
      this.lname,
      this.specialityId,
      this.speciality,
      this.phone,
      this.subspecialityIds,
      this.fnameAr,
      this.lnameAr,
      this.drInfoAr,
      this.schedulelist,
      this.qualification});

  Doctor.fromAppointmentJson(Map<String, dynamic> map) {
    id = map['id'] ?? 0;
    fname = map['first_name'];
    lname = map['last_name'];
    fnameAr = map['first_name1'];
    lnameAr = map['last_name1'];
    nameEng = "$fname $lname";
    nameAr = "$fnameAr $lnameAr";
    image =
        map['profile'] != null && map['profile'].toString().trim().isNotEmpty
            ? Constant.doctorImagePath + map['profile']
            : "";

    hospital = map.containsKey("hospital") && map["hospital"] != null
        ? Hospital.fromDrJsonfromJson(map["hospital"])
        : null;
    name = Constant.session!.getCurrLangCode() == Constant.arabicLanguageCode
        ? nameAr
        : nameEng;
  }

  Doctor.fromFavJson(Map<String, dynamic> map) {
    id = map['id'] ?? 0;
    phone = map['phone'];
    totalAppointments = (map['appointment_count'] ?? 0).toString();
    totalReviews = (map['reviews'] ?? 0).toString();
    rates = (map['rating'] ?? 0.0).toString();
    fname = map['first_name'];
    lname = map['last_name'];
    fnameAr = map['first_name1'];
    lnameAr = map['last_name1'];
    nameEng = "$fname $lname";
    nameAr = "$fnameAr $lnameAr";
    image =
        map['profile'] != null && map['profile'].toString().trim().isNotEmpty
            ? Constant.doctorImagePath + map['profile']
            : "";
    name = Constant.session!.getCurrLangCode() == Constant.arabicLanguageCode
        ? nameAr
        : nameEng;
  }

  Doctor.fromJson(Map<String, dynamic> map) {
    id = map['id'] ?? 0;
    specialityId = map['speciality_id'] ?? 0;
    speciality = map['speciality'] == null
        ? null
        : Speciality.fromJson(map["speciality"]);
    qualification = map['qualification'] ?? "";
    fname = map['first_name'];
    lname = map['last_name'];
    fnameAr = map['first_name1'];
    lnameAr = map['last_name1'];
    nameEng = "$fname $lname";
    nameAr = "$fnameAr $lnameAr";
    drInfoEng = map['description'] ?? "";
    drInfoAr = map['description1'] ?? "";
    image =
        map['profile'] != null && map['profile'].toString().trim().isNotEmpty
            ? Constant.doctorImagePath + map['profile']
            : "";
    totalAppointments = (map['appointment_count'] ?? 0).toString();
    totalReviews = (map['reviews'] ?? 0).toString();
    rates = (map['rating'] ?? 0.0).toString();
    hospital = map.containsKey("hospital") && map["hospital"] != null
        ? Hospital.fromDrJsonfromJson(map["hospital"])
        : null;
    drAddress = hospital == null ? "" : hospital!.city!.name!;

    drFees = (map['fees'] ?? 0).toString();

    //drWaitingTime = (map['waiting_time'] ?? 0).toString();

    subspecialties = map['subspeciality'] == null ||
            map['subspeciality'].toString().trim().isEmpty
        ? []
        : map['subspeciality'].toString().split(",");
    subspecialityIds = map['subspeciality_id'] == null ||
            map['subspeciality_id'].toString().trim().isEmpty
        ? []
        : map['subspeciality_id'].toString().split(",");

    schedulelist = [];
    if (map.containsKey("schedule") && map["schedule"] != null) {
      List data = map["schedule"];
      schedulelist!.addAll(data.map((e) => Schedule.fromJson(e)));
    }
    if (map.containsKey("total_experience") &&
        map["total_experience"] != null) {
      totalExperience = TotalExperience.fromJson(map["total_experience"]);
    }
    isFavourite = (map["favourite"] ?? 0) == 1;
    name = Constant.session!.getCurrLangCode() == Constant.arabicLanguageCode
        ? nameAr
        : nameEng;
  }

  Doctor.fromSearchJson(Map<String, dynamic> map) {
    id = map['id'] ?? 0;
    specialityId = map['speciality_id'] ?? 0;
    speciality = map['speciality'] == null
        ? null
        : Speciality.fromJson(map["speciality"]);
    fname = map['first_name'];
    lname = map['last_name'];
    fnameAr = map['first_name1'];
    lnameAr = map['last_name1'];
    nameEng = "$fname $lname";
    nameAr = "$fnameAr $lnameAr";
    subspecialties = map['subspeciality'] == null ||
            map['subspeciality'].toString().trim().isEmpty
        ? []
        : map['subspeciality'].toString().split(",");
    subspecialityIds = map['subspeciality_id'] == null ||
            map['subspeciality_id'].toString().trim().isEmpty
        ? []
        : map['subspeciality_id'].toString().split(",");
    image =
        map['profile'] != null && map['profile'].toString().trim().isNotEmpty
            ? Constant.doctorImagePath + map['profile']
            : "";
    name = Constant.session!.getCurrLangCode() == Constant.arabicLanguageCode
        ? nameAr
        : nameEng;
    searchSubText = "${speciality!.name}, ${subspecialties!.join(", ")}";
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'qualification': qualification ?? "",
      'favourite': (isFavourite ?? false) ? 1 : 0,
      'speciality_id': specialityId,
      'speciality': speciality!.toMap(),
      'first_name': fname,
      'last_name': lname,
      'first_name1': fnameAr,
      'last_name1': lnameAr,
      'profile': image!.replaceAll(Constant.doctorImagePath, ""),
      'description': drInfoEng,
      'description1': drInfoAr,
      'appointment_count': totalAppointments,
      'reviews': totalReviews,
      'rating': rates,
      'hospital': hospital == null ? null : hospital!.toMap(),
      'fees': drFees,
      //'waiting_time': drWaitingTime,
      'subspeciality': subspecialties,
      'subspeciality_id': subspecialityIds,
      'schedule': schedulelist == null
          ? null
          : schedulelist!.map((x) => x.toJson()).toList(),
      'total_experience':
          totalExperience == null ? null : totalExperience?.toJson(),
    };
  }
}
