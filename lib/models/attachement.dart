import '../helper/constant.dart';

class Attachment {
  int? id;
  int? appointmentId;
  String? file;
  String? fileLength;
  String? createdAt;
  String? updatedAt;
  int? reportId;

  Attachment(
      {this.id,
      this.appointmentId,
      this.file,
      this.createdAt,
      this.updatedAt,
      this.fileLength});

  Attachment.fromJson(Map<String, dynamic> map) {
    id = map['id'] ?? 0;
    appointmentId = map["appointment_id"] ?? 0;
    createdAt = map["created_at"];
    updatedAt = map["updated_at"];
    fileLength = "";
    file = map["file"] != null && map["file"].toString().trim().isNotEmpty
        ? Constant.prescriptionImagePath + map["file"]
        : "";
  }
  Attachment.fromReportJson(Map<String, dynamic> map) {
    fileLength = "";
    id = map['id'] ?? 0;
    reportId = map["report_id"] ?? 0;
    file = map["file"] != null && map["file"].toString().trim().isNotEmpty
        ? Constant.reportImagePath + map["file"]
        : "";
    reportId = map["report_id"] ?? 0;
  }
}
