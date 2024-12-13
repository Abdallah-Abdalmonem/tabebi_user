class Schedule {
  int? id;
  int? doctorId;
  String? startTime;
  String? endTime;
  String? day;
  int? waitingTime;

  Schedule(
      {this.id,
      this.doctorId,
      this.startTime,
      this.endTime,
      this.day,
      this.waitingTime});

  Schedule.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    doctorId = json['doctor_id'];
    startTime = json['start_time'] ?? "";
    endTime = json['end_time'] ?? "";
    day = json['day'] ?? "";
    waitingTime = json['waiting_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['doctor_id'] = doctorId;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    data['waiting_time'] = waitingTime;
    data['day'] = day;
    return data;
  }
}
