// 출석체크
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final DateTime date;
  final bool checked;

  AttendanceModel({required this.date, required this.checked});

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      date: (map['date'] as Timestamp).toDate(),
      checked: map['checked'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'checked': checked,
    };
  }
}