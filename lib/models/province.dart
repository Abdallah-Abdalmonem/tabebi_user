class Province {
  int? id;
  int? provinceId;
  String? name;
  String? latitude;
  String? longitude;

  Province({this.id, this.name, this.latitude, this.longitude});

  Province.fromJson(Map<String, dynamic> map) {
    print("state-get-map");
    id = map['id'];
    name = map['province'];
    latitude = map['latitude'];
    longitude = map['longitude'];
  }
  Province.fromCityJson(Map<String, dynamic> map) {
    id = map['id'];
    name = map['city'];
    latitude = map['latitude'];
    longitude = map['longitude'];
    provinceId = map['province_id'] ?? 0;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'province_id': provinceId,
      'city': name,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
