class SlotData {
  int? id;
  int? doctorId;
  String? day;
  String? startTime;
  String? endTime;
  int? waitingTime;
  List<String>? slot;
  List<String>? allSlot;
  List<String>? bookedSlot;

  SlotData(
      {id, doctorId, day, startTime, endTime, waitingTime, slot, bookedSlot});

  SlotData.fromJson(Map<String, dynamic> map) {
    id = map['id'];
    doctorId = map['doctor_id'];
    day = map['day'];
    startTime = map['start_time'];
    endTime = map['end_time'];
    waitingTime = map['waiting_time'];
    slot = [];
    bookedSlot = [];
    allSlot = [];

    allSlot = (map['slot'] as List).map((item) => item as String).toList();
    bookedSlot = (map['booked'] as List).map((item) => item as String).toList();
    slot = allSlot!.where((item) => !bookedSlot!.contains(item)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['doctor_id'] = doctorId;
    data['day'] = day;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    data['waiting_time'] = waitingTime;
    data['slot'] = slot;
    return data;
  }
}
