import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:wanbook/provider/user_provider.dart';

class BadgeProvider with ChangeNotifier {
  Future<Map<String, List<String>>> getUserAchievements(BuildContext context, String userId) async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final firestore = FirebaseFirestore.instance;

    // 1. 유저가 읽은 책 불러오기
    final readLogSnapshot = await firestore
        .collection('users')
        .doc(user?.userId)
        .collection('reading_books')
        .get();

    // 2. 태그별 책 수 세기
    Map<String, int> tagCount = {};

    for (var doc in readLogSnapshot.docs) {
      final tags = List<String>.from(doc['tags']);
      for (var tag in tags) {
        tagCount[tag] = (tagCount[tag] ?? 0) + 1;
      }
    }

    // 3. 업적 조건 정의 -> 업적명 이름 어떻게 할까?? 고민 필요,,,
    final Map<String, List<Map<String, dynamic>>> achievementRules = {
      "판타지/환상문학": [
        {"count": 5, "achievement": "판타지 입문자"},
        {"count": 10, "achievement": "판타지 마스터"},
      ],
      "호러.공포소설": [
        {"count": 5, "achievement": "공포 입문자"},
        {"count": 10, "achievement": "공포 즐겜러"},
      ],
    };

    // 4. 업적 달성 여부 확인 (수정 필요)
    Map<String, List<String>> achieved = {};

    for (var tag in tagCount.keys) {
      final readCount = tagCount[tag]!;
      final rules = achievementRules[tag] ?? [];

      for (var rule in rules) {
        if (readCount >= rule['count']) {
          achieved.putIfAbsent(tag, () => []).add(rule['achievement']);
        }
      }
    }

    return achieved;
  }
}