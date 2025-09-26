// 값 계산
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanbook/provider/user_provider.dart';
import 'package:wanbook/provider/user_book_provider.dart';
import 'package:wanbook/model/book_model.dart';
import 'package:wanbook/model/user_book_model.dart';

extension NumToDoubleClamp on num {
  double clampAsDouble(num lower, num upper) => clamp(lower, upper).toDouble();
}

class AnalyzeMetrics {
  final int totalSecs;
  final int activeDays;
  final int sessionCount;
  final int streak;
  final List<int> hours; 
  final List<int> dwell;  
  final Map<String, int> clickByRoute;
  final Map<String, int> clickByEntry;

  AnalyzeMetrics({
    required this.totalSecs,
    required this.activeDays,
    required this.sessionCount,
    required this.streak,
    required this.hours,
    required this.dwell,
    required this.clickByRoute,
    required this.clickByEntry,
  });
}

class BookAvgRow {
  final String bookId;
  final String title;
  final int avgSecs;
  final int activeDays;
  final int totalSecs;

  BookAvgRow({
    required this.bookId,
    required this.title,
    required this.avgSecs,
    required this.activeDays,
    required this.totalSecs,
  });
}

class HabitDetail {
  final String label;   
  final double score;     
  final String rawText;   
  final String methodText;
  HabitDetail(this.label, this.score, this.rawText, this.methodText);
}

// 책 목록
class AnalyzeValue {
  static Future<Map<String, String>> loadBooks(BuildContext context) async {
    final map = <String, String>{};
    final list =
        await context.read<UserBookProvider>().fetchReadingBooks(context);

    for (final m in list) {
      final book = m['book'] as BookModel;
      final userBook = m['userBook'] as UserBookModel;
      map[userBook.bookId] = book.title;
    }
    if (map.isEmpty) {
      final uid = _uid(context);
      final snap = await FirebaseFirestore.instance
          .collection('users').doc(uid)
          .collection('reading_books').get();
      for (final d in snap.docs) {
        map[d.id] = (d.data()['title'] ?? d.id).toString();
      }
    }
    return map;
  }

  // 메트릭 load
  static Future<AnalyzeMetrics> loadMetrics({
    required BuildContext context,
    required String? selectedBookId,
    required Map<String,String> books,
    required int rangeDays,
  }) async {
    int totalSecs = 0;
    int activeDays = 0;
    int sessionCount = 0;
    int streak = 0;
    List<int> hours = List<int>.filled(24, 0);
    List<int> dwell = List<int>.filled(100, 0);
    Map<String, int> clickByRoute = {};
    Map<String, int> clickByEntry = {};

    final uid = _uid(context);
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: rangeDays - 1));
    final dailyMap = <DateTime, int>{};
    final targetIds = selectedBookId != null ? [selectedBookId] : books.keys.toList();

    for (final bId in targetIds) {
      final col = FirebaseFirestore.instance
          .collection('users').doc(uid)
          .collection('reading_books').doc(bId)
          .collection('reading_metrics');

      final all = await col.get();

      final docs = all.docs.where((d) {
        final id = d.id;
        if (id.length < 10) return false;
        final y = int.tryParse(id.substring(0, 4));
        final m = int.tryParse(id.substring(5, 7));
        final dd = int.tryParse(id.substring(8, 10));
        if (y == null || m == null || dd == null) return false;
        final day = DateTime(y, m, dd);
        return !day.isBefore(start) && !day.isAfter(now);
      }).toList()
        ..sort((a, b) => a.id.compareTo(b.id));

      for (final d in docs) {
        final sess = await d.reference.collection('sessions').get();
        final daySum = sess.docs.fold<int>(
          0,
          (a, s) => a + ((s.data()['total_active_seconds'] ?? 0) as num).toInt(),
        );
        sessionCount += sess.docs.length;

        final y = int.parse(d.id.substring(0, 4));
        final m = int.parse(d.id.substring(5, 7));
        final dd = int.parse(d.id.substring(8, 10));
        final dayKey = DateTime(y, m, dd);

        totalSecs += daySum;
        if (daySum > 0) activeDays++;
        dailyMap[dayKey] = (dailyMap[dayKey] ?? 0) + daySum;

        final arrHours =
            List<int>.from(d.data()['hour_histogram'] ?? List.filled(24, 0));
        for (int h = 0; h < 24; h++) {
          hours[h] += (h < arrHours.length ? arrHours[h] : 0);
        }

        final arrDwell = List<num>.from(
            d.data()['dwell_seconds_by_bucket'] ?? List.filled(100, 0));
        for (int i = 0; i < 100; i++) {
          dwell[i] += (i < arrDwell.length ? arrDwell[i].round() : 0);
        }
      }
      try {
        final q = await FirebaseFirestore.instance
            .collection('users').doc(uid)
            .collection('reading_books').doc(bId)
            .collection('chatbot_clicks')
            .where('ts', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
            .get();

        for (final c in q.docs) {
          final data = c.data();
          final route = (data['route'] ?? 'unknown').toString();
          final entry = (data['entry_id'] ?? 'unknown').toString();
          clickByRoute[route] = (clickByRoute[route] ?? 0) + 1;
          clickByEntry[entry] = (clickByEntry[entry] ?? 0) + 1;
        }
      } catch (_) {}
    }
    streak = _calcStreak(dailyMap, rangeDays, DateTime.now());

    return AnalyzeMetrics(
      totalSecs: totalSecs,
      activeDays: activeDays,
      sessionCount: sessionCount,
      streak: streak,
      hours: hours,
      dwell: dwell,
      clickByRoute: clickByRoute,
      clickByEntry: clickByEntry,
    );
  }

  // 책별 평균
  static Future<List<BookAvgRow>> loadBookAverages({
    required BuildContext context,
    required Map<String,String> books,
    required int rangeDays,
  }) async {
    final rows = <BookAvgRow>[];
    final uid = _uid(context);
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: rangeDays - 1));

    for (final e in books.entries) {
      final bId = e.key;
      final title = e.value;

      final col = FirebaseFirestore.instance
          .collection('users').doc(uid)
          .collection('reading_books').doc(bId)
          .collection('reading_metrics');

      final all = await col.get();
      final docs = all.docs.where((d) {
        final id = d.id;
        if (id.length < 10) return false;
        final y = int.tryParse(id.substring(0, 4));
        final m = int.tryParse(id.substring(5, 7));
        final dd = int.tryParse(id.substring(8, 10));
        if (y == null || m == null || dd == null) return false;
        final day = DateTime(y, m, dd);
        return !day.isBefore(start) && !day.isAfter(now);
      });

      int totalSecs = 0;
      int activeDays = 0;

      for (final d in docs) {
        final sess = await d.reference.collection('sessions').get();
        final daySum = sess.docs.fold<int>(
          0,
          (a, s) => a + ((s.data()['total_active_seconds'] ?? 0) as num).toInt(),
        );
        totalSecs += daySum;
        if (daySum > 0) activeDays++;
      }

      final avgSecs = activeDays == 0 ? 0 : totalSecs ~/ activeDays;
      rows.add(BookAvgRow(
        bookId: bId,
        title: title,
        avgSecs: avgSecs,
        activeDays: activeDays,
        totalSecs: totalSecs,
      ));
    }

    rows.sort((a, b) => b.avgSecs.compareTo(a.avgSecs));
    return rows;
  }

  // 오각형 점수 계산
  static List<double> buildHabitScores({
    required AnalyzeMetrics m,
    required int rangeDays,
  }) {
    // 1) 꾸준함: 활동일/기간 → 백분율
    // '활동일 / 기간 일(day)', '최근 일 중 활동일 비율을 백분율로 환산'
    final days = rangeDays.clamp(1, 365);
    final consist = (m.activeDays / days) * 100.0;

    final totalDwell = m.dwell.fold<int>(0, (a, b) => a + b);
    final nzDwell = m.dwell.where((v) => v > 0).toList();

    // 지속성: 상위 80–95% 절사평균 정규화 → sqrt 스케일링
    double sustainScore = 0.0;
    if (nzDwell.length >= 10) {
      final sorted = [...nzDwell]..sort();
      double q(double p) {
        final i = ((sorted.length - 1) * p).clamp(0, sorted.length - 1).toDouble();
        final lo = i.floor();
        final hi = i.ceil();
        if (lo == hi) return sorted[lo].toDouble();
        final t = i - lo;
        return sorted[lo] * (1 - t) + sorted[hi] * t;
      }
      final p80 = q(0.80), p95 = q(0.95);
      final slice = sorted.where((x) => x >= p80 && x <= p95).toList();
      final trimmedMean = slice.isEmpty
          ? sorted.reduce((a, b) => a + b) / sorted.length
          : slice.reduce((a, b) => a + b) / slice.length;

      final norm = (trimmedMean / 90.0) * 100.0;
      sustainScore = math.sqrt(norm.clamp(0.0, 100.0) * 100.0) / 10.0;
    } else {
      sustainScore = 50.0;
    }

    // 2) 속도 안정: 0 제거 + 5~95% 윈저라이징 + CV 스케일링
    // '5–95% 구간에서 속도 변동계수(CV)를 계산, κ로 스케일링'
    const kappa = 2.0;
    const meanFloor = 3.0;
    double stability;
    if (nzDwell.length < 5) {
      stability = 50.0;
    } else {
      final vals = nzDwell.map((e) => e.toDouble()).toList()..sort();
      final n = vals.length;
      final loIdx = (n * 0.05).floor();
      final hiIdx = (n * 0.95).ceil() - 1;
      final lo = vals[loIdx];
      final hi = vals[hiIdx];
      final trimmed = vals.map((v) => v.clamp(lo, hi).toDouble()).toList();

      final mean = trimmed.reduce((a, b) => a + b) / trimmed.length;
      final denom = mean < meanFloor ? meanFloor : mean;
      double varSum = 0.0;
      for (final v in trimmed) {
        final d = v - mean;
        varSum += d * d;
      }
      final std = math.sqrt(varSum / trimmed.length);
      final cv = std / denom;

      final raw = 1.0 - (cv / kappa);
      stability = (100.0 * raw.clamp(0.05, 1.0));
    }

    // 3) 집중 유지: 지속성 × 안정의 기하평균
    // '지속성(상위 80–95% 절사평균 정규화) × 안정의 기하평균'
    final focus = math.sqrt(sustainScore * stability);

    // 4) 재독 성향: HHI 정규화
    // '진행률 분포의 쏠림(HHI)을 정규화하여 반복 읽기 성향 추정
    double reread = 0.0;
    if (totalDwell > 0) {
      double hhi = 0.0;
      for (final v in m.dwell) {
        if (v <= 0) continue;
        final p = v / totalDwell;
        hhi += p * p;
      }
      const hhiMin = 1.0 / 100.0;
      final normHHI = ((hhi - hhiMin) / (1.0 - hhiMin)).clamp(0.0, 1.0);
      reread = (math.sqrt(normHHI) * 0.8) * 100.0;
    }

    // 5) 리듬 다양성: 24시간대 엔트로피 정규화
    // '24시간대 분포의 엔트로피를 최대엔트로피로 나눠 정규화'
    final totalMin = m.hours.fold<int>(0, (a, b) => a + b);
    double entropy = 0;
    for (final mm in m.hours) {
      if (mm <= 0) continue;
      final p = mm / (totalMin == 0 ? 1 : totalMin);
      entropy += -p * (p == 0 ? 0 : math.log(p));
    }
    final maxH = math.log(24);
    final rhythm = maxH == 0 ? 0 : (entropy / maxH * 100);
    
    return [
      consist.clampAsDouble(0.0, 100.0),
      focus.clampAsDouble(0.0, 100.0),
      stability.clampAsDouble(0.0, 100.0),
      reread.clampAsDouble(0.0, 100.0),
      rhythm.clampAsDouble(0.0, 100.0),
    ];
  }

  // 상세 설명 텍스트
  static List<HabitDetail> buildHabitDetails({
    required AnalyzeMetrics m,
    required int rangeDays,
  }) {
    final scores = buildHabitScores(m: m, rangeDays: rangeDays);
    final consist = scores[0];
    final focus   = scores[1];
    final stability = scores[2];
    final reread  = scores[3];
    final rhythm  = scores[4];

    final explainConsist =
        '최근 $rangeDays일 동안 “책을 펼친 날이 얼마나 많았는지”를 보는 지표예요. '
        '오래 읽었는지와는 별개로, 짧게라도 자주 읽었으면 점수가 올라갑니다. '
        '즉, 습관처럼 꾸준히 책을 만졌는지를 보여줘요.';
    final explainFocus =
        '책을 한 번 펴면 얼마나 몰입해서 이어 갔는지를 보는 지표예요. '
        '잠깐 펼쳤다가 자주 끊기면 낮아지고, 한 번 시작하면 비교적 오래 읽거나 '
        '읽는 흐름이 일정할수록 높아집니다. 쉽게 말해 “끊김 없이 쭉 읽었나”를 봅니다.';
    final explainStability =
        '읽는 속도가 들쭉날쭉했는지를 보는 지표예요. 어떤 날은 훅 빨리, 또 어떤 날은 아주 느리면 낮아지고, '
        '대체로 비슷한 페이스로 읽으면 높아져요. 갑자기 멈춰 생각하거나 메모하느라 '
        '속도가 흔들리면 이 지표가 내려갈 수 있어요.';
    final explainReread =
        '같은 구간을 여러 번 다시 보거나 오래 머문 정도예요. '
        '중요해서 반복했을 수도 있고, 이해가 어려워서 되돌아갔을 수도 있어요. '
        '높다고 무조건 나쁜 건 아니지만, 같은 곳에서 자주 막히면 쉬운 책으로 속도를 내 보거나, '
        '요약/해설을 함께 보는 것도 도움이 됩니다.';
    final explainRhythm =
        '하루 24시간 중 언제 읽는지가 얼마나 고르게 퍼져 있는지를 봐요. '
        '특정 시간대(예: 자기 전)만 꾸준히 읽으면 점수는 낮아질 수 있지만, '
        '그 자체로 나쁜 건 아니에요. 반대로 출퇴근/점심/잠들기 전 등 다양한 시간대에 '
        '조금씩 나눠 읽으면 높게 나옵니다. 본인에게 맞는 루틴이면 그대로 유지해도 좋아요.';

    return [
      HabitDetail('꾸준',   consist,  '', explainConsist),
      HabitDetail('집중',   focus,    '', explainFocus),
      HabitDetail('안정',   stability,'', explainStability),
      HabitDetail('재독',   reread,   '', explainReread),
      HabitDetail('리듬',   rhythm,   '', explainRhythm),
    ];
  }

  // 책멍이 코멘트 프롬프트
  static String buildCoachPrompt({
    required String title,
    required int rangeDays,
    required AnalyzeMetrics m,
    required List<double> radar,
    required List<int> hours,
    required List<int> dwell,
  }) {
    return '''
아래 데이터를 바탕으로 간결하고 정중한 한국어로 작성해주세요.

요청 형식(그대로 지켜주세요):
<분석 요약>
- (핵심 수치 위주로 3~4줄)

<책멍이 조언>
- (사용자에게 도움이 되는 전반적인 조언 2~3줄)
- "재독 성향"이 높을 경우에도 무조건 긍정으로 단정하지 말고, 이해가 어려워 멈췄을 수 있다는 가능성을 함께 언급해주세요.

데이터:
- 책: $title
- 기간: 최근 $rangeDays일
- 총 읽은 시간: ${formatHms(m.totalSecs)}, 세션 수: ${m.sessionCount}, 활동일: ${m.activeDays}, 연속일: ${m.streak}
- 시간대 분포(분): ${hours.join(',')}
- 정체(버킷별 체류 초): ${dwell.join(',')}
- 레이더 점수 [꾸준함, 집중 유지, 속도 안정, 재독 성향, 리듬 다양성]: ${radar.map((e)=>e.toStringAsFixed(0)).join(', ')}
''';
  }

  // 포맷
  static String formatHms(int secs) {
    final h = secs ~/ 3600;
    final m = (secs % 3600) ~/ 60;
    final s = secs % 60;
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  // 내부 유틸
  static String _uid(BuildContext context) =>
      context.read<UserProvider>().user?.userId ?? '';

  static int _calcStreak(Map<DateTime, int> daily, int rangeDays, DateTime now) {
    int streak = 0;
    DateTime cur = DateTime(now.year, now.month, now.day);
    for (int i = 0; i < rangeDays; i++) {
      final key = DateTime(cur.year, cur.month, cur.day);
      final sum = daily[key] ?? 0;
      if (sum > 0) {
        streak++;
        cur = cur.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }
}
