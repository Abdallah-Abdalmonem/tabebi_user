import 'dart:convert';

import '../helper/constant.dart';

class NotificationData {
  int? id;
  String? title;
  String? message;
  int? userId;
  String? type;
  String? image;
  String? createdAt;
  Map<dynamic, dynamic>? data;
  NotificationData(
      {id, title, message, users, userId, type, image, createdAt, data});

  NotificationData.fromJson(Map<String, dynamic> map) {
    id = map['id'] ?? 0;
    title = map['title'] ?? "";
    message = map['body'] ?? "";
    userId = map['user_id'] ?? 0;
    type = map['type'] ?? "";
    image = map["image"] != null && map["image"].toString().trim().isNotEmpty
        ? Constant.notificationImagePath + map["image"]
        : "";
    createdAt = map['created_at'];
    data = {};

    if (map.containsKey("other_data") && map["other_data"] != null) {
      data = json.decode(map["other_data"]);
    }
  }
}
