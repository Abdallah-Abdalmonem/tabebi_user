import 'dart:convert';

import 'package:tabebi/helper/sessionManager.dart';

import '../helper/constant.dart';

class UserData {
  int? id;
  String? name;
  String? mobileno;
  String? image;
  String? email;
  String? token;
  int? notification;
  UserData({
    this.id,
    this.name,
    this.mobileno,
    this.image,
    this.email,
    this.token,
    this.notification = 0,
  });

  UserData.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    name = json['first_name'] ?? "";
    mobileno = json['phone'] ?? "";
    image =
        json['profile'] != null && json['profile'].toString().trim().isNotEmpty
            ? Constant.patientImagePath + json['profile']
            : "";
    email = json['email'] ?? "";
    if (json.containsKey("token")) token = json['token'] ?? "";
    notification = json['notification'] ?? 0;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': name,
      'phone': mobileno,
      'profile': image!.trim().isEmpty
          ? image
          : image!.replaceAll(Constant.patientImagePath, ""),
      'email': email,
      'token': Constant.session!.getData(SessionManager.keyToken),
      'notification': notification,
    };
  }

  String toJson() => json.encode(toMap());
}
