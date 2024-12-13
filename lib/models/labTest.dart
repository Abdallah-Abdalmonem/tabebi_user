import 'dart:convert';

class LabTest {
  int? id;
  int? testId;
  String? test;
  double? labAmount, adminAmount;
  double? offerprice;
  LabTest({
    this.id,
    this.test,
    this.labAmount,
    this.adminAmount,
    this.offerprice,
    this.testId,
  });
  LabTest.fromJson(Map<String, dynamic> map) {
    offerprice = 0;
    id = map['id'] ?? 0;

    if (map.containsKey("test")) {
      testId = map['test_id'] ?? 0;
      test = map['test']['name'] ?? "";
      adminAmount = double.parse((map['test']['lab_price'] ?? 0).toString());
      labAmount = double.parse((map['lab_price'] ?? 0).toString());
      if (labAmount! < adminAmount!) {
        offerprice = adminAmount!;
      }
    } else {
      testId = map['id'] ?? 0;
      test = map['name'] ?? "";
      adminAmount = double.parse((map['lab_price'] ?? 0).toString());
      labAmount = adminAmount;
    }
    /* if (isByLab) {
      id = map['id'] ?? 0;
      testId = map['test_id'] ?? 0;
      test = map['test']['name'] ?? "";
      adminAmount = double.parse((map['test']['lab_price'] ?? 0).toString());
      labAmount = double.parse((map['lab_price'] ?? 0).toString());
      if (labAmount! < adminAmount!) {
        offerprice = adminAmount!;
      }
    } else {
      id = map['id'] ?? 0;
      testId = map['id'] ?? 0;
      test = map['name'] ?? "";
      adminAmount = double.parse((map['lab_price'] ?? 0).toString());
      labAmount = adminAmount;
    } */
  }
}
