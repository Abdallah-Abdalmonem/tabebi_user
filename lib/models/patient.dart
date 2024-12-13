import '../helper/constant.dart';

class Patient {
  int? id;
  String? name;
  String? image;
  String? phone;

  Patient({this.id, this.name, this.image, this.phone});

  Patient.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['first_name'] ?? "";
    phone = json['phone'] ?? "";
    image =
        json['profile'] != null && json['profile'].toString().trim().isNotEmpty
            ? Constant.patientImagePath + json['profile']
            : "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['first_name'] = name;
    data['profile'] = image;
    return data;
  }
}
