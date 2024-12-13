import '../helper/constant.dart';

class Speciality {
  int? id;
  String? name;
  String? image;

  Speciality({this.id, this.name, this.image});

  Speciality.fromJson(Map<String, dynamic> map) {
    id = map['id'] ?? 0;
    name = map["speciality"];
    image = map["image"] != null && map["image"].toString().trim().isNotEmpty
        ? Constant.specialityImagePath + map["image"]
        : "";
  }

  @override
  String toString() => '$name';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'speciality': name,
      'image': image!.replaceAll(Constant.specialityImagePath, ""),
    };
  }
}
