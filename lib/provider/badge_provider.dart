// 업적 provider
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../model/user_book_model.dart';

// 업적 배지
class BadgeItem {
  final String id;  
  final String title;  
  final String asset;   
  final bool unlocked;   
  final String tag;     
  final int threshold;

  const BadgeItem({
    required this.id,
    required this.title,
    required this.asset,
    required this.unlocked,
    required this.tag,
    required this.threshold,
  });

  BadgeItem copyWith({bool? unlocked}) => BadgeItem(
        id: id,
        title: title,
        asset: asset,
        unlocked: unlocked ?? this.unlocked,
        tag: tag,
        threshold: threshold,
      );
}

// 월간 기록
class MonthlyRecordItem {
  final int month;    
  final int count;      
  final int achieved;   
  final bool unlocked; 
  final String? asset;  

  const MonthlyRecordItem({
    required this.month,
    required this.count,
    required this.achieved,
    required this.unlocked,
    required this.asset,
  });

  String get title => '${month}월';
}

class BadgeProvider with ChangeNotifier {
  static const Map<String, Map<String, String>> tagToPrefix = {
    "한국소설": {"prefix": "korea", "label": "한국소설"},
    "세계의 소설": {"prefix": "world", "label": "세계소설"},
    "추리/미스터리소설": {"prefix": "reasoning", "label": "추리/미스터리"},
    "판타지/환상문학": {"prefix": "fantasy", "label": "판타지"},
    "역사소설": {"prefix": "history", "label": "역사소설"},
    "과학소설": {"prefix": "science", "label": "과학소설"},
    "호러.공포소설": {"prefix": "horror", "label": "호러/공포"},
    "무협소설": {"prefix": "martial", "label": "무협소설"},
    "액션/스릴러소설": {"prefix": "action", "label": "액션/스릴러"},
    "로맨스소설": {"prefix": "romance", "label": "로맨스"},
  };

  // 업적 배지 단계 (1권: 입문자, 5권: 베테랑, 10권: 정복자)
  static const List<int> thresholds = [1, 5, 10];

  /// 월간 기록 단계 (5권, 10권 ...)
  static const List<int> monthlySteps = [5, 10, 15, 20, 25, 30];

  // 제목 정규화 (태그 손쉽게 찾기 위함)
  String _normalizeTitle(String input) {
    var s = input.trim();
    s = s.replaceAll(RegExp(r'\s*\(.*?\)\s*'), '');
    s = s.replaceAll(RegExp(r'\s*\[.*?\]\s*'), '');
    s = s.replaceAll(RegExp(r'\s+'), ' ');
    return s;
  }

  // 태그 배열화
  List<String> _extractTags(dynamic raw) {
    if (raw is List) {
      return List<String>.from(raw.whereType<String>())
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } else if (raw is String && raw.trim().isNotEmpty) {
      return [raw.trim()];
    }
    return const [];
  }

  // 정규화한 태그 제목과 매칭 과정
  Future<int> _backfillTagsFromBooks(String userId) async {
    final fs = FirebaseFirestore.instance;
    final rbRef = fs.collection('users').doc(userId).collection('reading_books');
    final booksRef = fs.collection('books');

    final rbSnap = await rbRef.get();
    int updated = 0;

    for (final doc in rbSnap.docs) {
      final data = doc.data();
      final current = _extractTags(data['tags']);
      if (current.isNotEmpty) continue;

      final bookIdOrTitle = (data['book_id'] ?? '').toString().trim();
      if (bookIdOrTitle.isEmpty) continue;

      final normalizedKey = _normalizeTitle(bookIdOrTitle);

      DocumentSnapshot<Map<String, dynamic>>? bookDoc =
          await booksRef.doc(bookIdOrTitle).get();

      if (bookDoc == null || !bookDoc.exists) {
        final q = await booksRef.where('title', isEqualTo: bookIdOrTitle).limit(1).get();
        if (q.docs.isNotEmpty) bookDoc = q.docs.first;
      }

      if (bookDoc == null || !bookDoc.exists) {
        final all = await booksRef.limit(500).get();
        for (final b in all.docs) {
          final t = (b.data()['title'] ?? '').toString();
          if (_normalizeTitle(t) == normalizedKey) {
            bookDoc = b;
            break;
          }
        }
      }

      String? tag;
      if (bookDoc != null && bookDoc.exists) {
        final b = bookDoc.data()!;
        if (b['tag'] is String && (b['tag'] as String).trim().isNotEmpty) {
          tag = (b['tag'] as String).trim();
        } else if (b['tags'] is List && (b['tags'] as List).isNotEmpty) {
          tag = (b['tags'] as List).first.toString().trim();
        }
      }

      if (tag != null && tag.isNotEmpty) {
        await doc.reference.set({'tags': [tag]}, SetOptions(merge: true));
        updated++;
      }
    }
    return updated;
  }

  // reading_books에 비어있는 도서의 tag 채우는 코드
  Future<int> _backfillTagsFromAssets(
    String userId, {
    String assetPath = 'assets/book.json',
  }) async {
    final fs = FirebaseFirestore.instance;
    final rbRef = fs.collection('users').doc(userId).collection('reading_books');

    final jsonStr = await rootBundle.loadString(assetPath);
    final dynamic parsed = json.decode(jsonStr);

    final Map<String, String> normTitleToTag = {};
    Iterable<Map<String, dynamic>> items = const [];

    if (parsed is List) {
      items = parsed.cast<Map<String, dynamic>>();
    } else if (parsed is Map && parsed['books'] is List) {
      items = (parsed['books'] as List).cast<Map<String, dynamic>>();
    }

    for (final e in items) {
      final title = (e['title'] ?? '').toString();
      final tag = (e['tag'] ?? '').toString().trim();
      final key = _normalizeTitle(title);
      if (key.isNotEmpty && tag.isNotEmpty) {
        normTitleToTag[key] = tag;
      }
    }

    final rbSnap = await rbRef.get();
    int updated = 0;

    for (final doc in rbSnap.docs) {
      final data = doc.data();
      final current = _extractTags(data['tags']);
      if (current.isNotEmpty) continue;

      final key = _normalizeTitle((data['book_id'] ?? '').toString());
      if (key.isEmpty) continue;

      final tag = normTitleToTag[key];
      if (tag != null && tag.isNotEmpty) {
        await doc.reference.set({'tags': [tag]}, SetOptions(merge: true));
        updated++;
      }
    }
    return updated;
  }

  // 업적 계산
  Future<List<BadgeItem>> getUserAchievements(String userId) async {
    final fs = FirebaseFirestore.instance;
    final userRef = fs.collection('users').doc(userId);
    final achievementsRef = userRef.collection('achievements');

    await _backfillTagsFromBooks(userId);
    await _backfillTagsFromAssets(userId);

    final rbSnap = await userRef.collection('reading_books').get();
    final books = rbSnap.docs.map((d) => UserBookModel.fromDocument(d)).toList();

    // 태그별 카운트
    final Map<String, int> tagCount = {};
    for (final b in books) {
      for (final t in b.tags) {
        tagCount[t] = (tagCount[t] ?? 0) + 1;
      }
    }

    // 업적 생성 (1/5/10 → 입문자/베테랑/정복자)
    final List<BadgeItem> computed = [];
    for (final entry in tagToPrefix.entries) {
      final tagName = entry.key;
      final prefix  = entry.value['prefix']!;
      final label   = entry.value['label']!;
      final read    = tagCount[tagName] ?? 0;

      for (final th in thresholds) {
        final id = '${prefix}_$th';
        final stageName = (th == 1) ? '입문자' : (th == 5) ? '베테랑' : '정복자';
        computed.add(BadgeItem(
          id: id,
          title: '$label $stageName',
          asset: 'assets/images/records/record_${prefix}_$th.svg',
          unlocked: read >= th,
          tag: tagName,
          threshold: th,
        ));
      }
    }

    // 저장된 업적 병합
    final savedSnap = await achievementsRef.get();
    final Map<String, bool> savedUnlocked = {
      for (final d in savedSnap.docs) d.id: (d.data()['unlocked'] as bool? ?? true),
    };

    final batch = fs.batch();
    int writes = 0;
    for (final b in computed) {
      if (b.unlocked && !savedUnlocked.containsKey(b.id)) {
        batch.set(achievementsRef.doc(b.id), {
          'id': b.id,
          'title': b.title,
          'asset': b.asset,
          'tag': b.tag,
          'threshold': b.threshold,
          'unlocked': true,
          'unlockedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        writes++;
      }
    }
    if (writes > 0) await batch.commit();

    return computed
        .map((b) => b.copyWith(unlocked: b.unlocked || (savedUnlocked[b.id] ?? false)))
        .toList();
  }

  // 월간 기록: update_date 기준 월별로 count (일단 올해만 되도록 함)
  Future<List<MonthlyRecordItem>> getMonthlyRecords(
    String userId, {
    int? year, 
  }) async {
    final fs = FirebaseFirestore.instance;
    final rb = fs.collection('users').doc(userId).collection('reading_books');

    final snap = await rb.get();

    // 월별 카운트 초기화
    final Map<int, int> counter = {for (var m = 1; m <= 12; m++) m: 0};

    for (final d in snap.docs) {
      final data = d.data();
      if (data['update_date'] == null) continue;
      final ts = data['update_date'] as Timestamp;
      final dt = ts.toDate();

      if (year != null && dt.year != year) continue;
      counter[dt.month] = (counter[dt.month] ?? 0) + 1;
    }

    // 각 월 달성 단계 계산
    final List<MonthlyRecordItem> result = [];
    for (var m = 1; m <= 12; m++) {
      final c = counter[m] ?? 0;

      int achieved = 0;
      for (final step in monthlySteps.reversed) {
        if (c >= step) {
          achieved = step;
          break;
        }
      }

      final unlocked = achieved >= 5;
      final asset =
          achieved == 0 ? null : 'assets/images/records/record_$achieved.svg';

      result.add(MonthlyRecordItem(
        month: m,
        count: c,
        achieved: achieved,
        unlocked: unlocked,
        asset: asset,
      ));
    }

    return result;
  }

  // 월간 기록 분기별로 끊는 함수 (1-3/4-6/7-9/10-12)
  List<MonthlyRecordItem> getCurrentQuarterRecords(List<MonthlyRecordItem> allRecords) {
    final now = DateTime.now();
    final currentMonth = now.month;

    // 현재 월이 속한 분기 계산
    int startMonth = ((currentMonth - 1) ~/ 3) * 3 + 1;
    int endMonth = startMonth + 2;

    return allRecords
        .where((item) => item.month >= startMonth && item.month <= endMonth)
        .toList();
  }

  // 프로필 화면에서 보이는 뱃지
  Future<List<BadgeItem>> getRecentUnlockedBadgesSafe(
    String userId, {
    int limit = 3,
    bool newestFirst = true,
  }) async {
    final fs = FirebaseFirestore.instance;
    final achievementsRef =
        fs.collection('users').doc(userId).collection('achievements');

    await getUserAchievements(userId);

    // 자물쇠 없는 과거 문서
    final needBackfill = await achievementsRef
        .where('unlocked', isEqualTo: true)
        .where('unlockedAt', isNull: true)
        .get();
    if (needBackfill.docs.isNotEmpty) {
      final batch = fs.batch();
      for (final d in needBackfill.docs) {
        batch.set(d.reference, {'unlockedAt': FieldValue.serverTimestamp()},
            SetOptions(merge: true));
      }
      await batch.commit();
    }

    try {
      final snap = await achievementsRef
          .where('unlocked', isEqualTo: true)
          .orderBy('unlockedAt', descending: newestFirst) // 최신순으로 업뎃됨
          .limit(limit)
          .get();

      return snap.docs.map((d) {
        final m = d.data();
        return BadgeItem(
          id: (m['id'] as String?) ?? d.id,
          title: (m['title'] as String?) ?? '',
          asset: (m['asset'] as String?) ?? '',
          unlocked: true,
          tag: (m['tag'] as String?) ?? '',
          threshold: (m['threshold'] as num?)?.toInt() ?? 0,
        );
      }).toList();
    } catch (e) {
      final all = await achievementsRef.get();
      final unlocked = all.docs
          .map((d) => d.data())
          .where((m) => (m['unlocked'] as bool?) == true)
          .toList()
        ..sort((a, b) {
          final ta = (a['unlockedAt'] as Timestamp?);
          final tb = (b['unlockedAt'] as Timestamp?);
          int cmp;
          if (ta == null && tb == null) cmp = 0;
          else if (ta == null)         cmp = 1;
          else if (tb == null)         cmp = -1;
          else                         cmp = ta.compareTo(tb);
          return newestFirst ? -cmp : cmp;
        });

      return unlocked.take(limit).map((m) {
        return BadgeItem(
          id: (m['id'] as String?) ?? '',
          title: (m['title'] as String?) ?? '',
          asset: (m['asset'] as String?) ?? '',
          unlocked: true,
          tag: (m['tag'] as String?) ?? '',
          threshold: (m['threshold'] as num?)?.toInt() ?? 0,
        );
      }).toList();
    }
  }

}
