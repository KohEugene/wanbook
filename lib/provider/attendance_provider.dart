import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class AttendanceProvider with ChangeNotifier {
  List<bool> weeklyAttendance = List.filled(7, false);

  Future<void> markAttendance(String userId) async {
    final now = DateTime.now();
    final docId = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final docRef = FirebaseFirestore.instance.collection('users').doc(userId).collection('attendance').doc(docId);

    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      await docRef.set({
        'checked': true,
        'date': Timestamp.fromDate(now),
      });
    }
    await fetchThisWeekAttendance(userId);
  }

  Future<void> fetchThisWeekAttendance(String userId) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    final dates = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
    final updatedAttendance = List<bool>.filled(7, false);

    for (int i = 0; i < 7; i++) {
      final day = dates[i];
      final docId = "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).collection('attendance').doc(docId).get();
      if (doc.exists && doc['checked'] == true) {
        updatedAttendance[i] = true;
      }
    }

    weeklyAttendance = updatedAttendance;
    notifyListeners();
  }

  List<bool> get attendanceStatus => weeklyAttendance;
}
