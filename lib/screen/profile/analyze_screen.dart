// 사용자 독서 패턴 분석 화면
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanbook/provider/user_provider.dart';
import 'package:wanbook/provider/user_book_provider.dart';
import 'package:wanbook/model/book_model.dart';
import 'package:wanbook/model/user_book_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wanbook/shared/openai_shared.dart';
import 'package:wanbook/screen/profile/analyze_chart.dart';

class AnalyzeScreen extends StatefulWidget {
  const AnalyzeScreen({
    super.key,
    this.initialBookId, // null이면 전체(모든 책)
    this.rangeDays = 30, // 통계 범위(최근 n일)
  });

  final String? initialBookId;
  final int rangeDays;

  @override
  State<AnalyzeScreen> createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends State<AnalyzeScreen> {
  bool _loading = true;
  final Map<String, String> _books = {};
  String? _selectedBookId;
  int _totalSecs = 0;         // 총 읽은 시간(초)
  int _activeDays = 0;        // 읽은 날 수
  int _sessionCount = 0;      // 세션 수(책을 펼친 횟수)
  int _streak = 0;            // 오늘부터 연속 읽은 일수

  List<int> _hours = List<int>.filled(24, 0);   // 시간대별 읽은 분
  List<int> _dwell = List<int>.filled(100, 0);  // 진행률 0~99% 정체한 초
  Map<String, int> _clickByRoute = {};
  Map<String, int> _clickByEntry = {};
  List<_BookAvgRow> _bookAverages = [];

  Future<String>? _coachFuture;

  @override
  void initState() {
    super.initState();
    _selectedBookId = widget.initialBookId;
    _bootstrap();
  }

  String _uid() => context.read<UserProvider>().user?.userId ?? '';

  Future<void> _bootstrap() async {
    setState(() => _loading = true);
    try {
      await _loadBooksFromLibrary();
      await _loadMetricsFor(_selectedBookId);
      await _loadBookAverages();
      _refreshCoachNote();
    } catch (e) {
      debugPrint('Analyze bootstrap error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // 책 목록 가져오기
  Future<void> _loadBooksFromLibrary() async {
    _books.clear();
    final list =
        await context.read<UserBookProvider>().fetchReadingBooks(context);

    for (final m in list) {
      final book = m['book'] as BookModel;
      final userBook = m['userBook'] as UserBookModel;
      _books[userBook.bookId] = book.title;
    }
    if (_books.isEmpty) {
      final uid = _uid();
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('reading_books')
          .get();
      for (final d in snap.docs) {
        _books[d.id] = (d.data()['title'] ?? d.id).toString();
      }
    }
  }

  // reading_metrics 합산
  Future<void> _loadMetricsFor(String? bookId) async {
    _totalSecs = 0;
    _activeDays = 0;
    _sessionCount = 0;
    _streak = 0;
    _hours = List<int>.filled(24, 0);
    _dwell = List<int>.filled(100, 0);
    _clickByRoute = {};
    _clickByEntry = {};

    final uid = _uid();
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: widget.rangeDays - 1));
    final dailyMap = <DateTime, int>{};
    final targetIds = bookId != null ? [bookId] : _books.keys.toList();

    for (final bId in targetIds) {
      final col = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('reading_books')
          .doc(bId)
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
        _sessionCount += sess.docs.length; 

        final y = int.parse(d.id.substring(0, 4));
        final m = int.parse(d.id.substring(5, 7));
        final dd = int.parse(d.id.substring(8, 10));
        final dayKey = DateTime(y, m, dd);

        // 활동 일자
        _totalSecs += daySum;
        if (daySum > 0) _activeDays++;
        dailyMap[dayKey] = (dailyMap[dayKey] ?? 0) + daySum;

        // 시간대 분포
        final arrHours =
            List<int>.from(d.data()['hour_histogram'] ?? List.filled(24, 0));
        for (int h = 0; h < 24; h++) {
          _hours[h] += (h < arrHours.length ? arrHours[h] : 0);
        }

        // 진행률 0~99% 정체
        final arrDwell = List<num>.from(
            d.data()['dwell_seconds_by_bucket'] ?? List.filled(100, 0));
        for (int i = 0; i < 100; i++) {
          _dwell[i] += (i < arrDwell.length ? arrDwell[i].round() : 0);
        }
      }
      await _loadChatbotClicksForBook(uid, bId, start);
    }
    _streak = _calcStreak(dailyMap, start, DateTime.now());
  }

  // chatbot_clicks 횟수
  Future<void> _loadChatbotClicksForBook(
      String uid, String bookId, DateTime start) async {
    try {
      final q = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('reading_books')
          .doc(bookId)
          .collection('chatbot_clicks')
          .where('ts', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .get();

      for (final c in q.docs) {
        final data = c.data();
        final route = (data['route'] ?? 'unknown').toString();
        final entry = (data['entry_id'] ?? 'unknown').toString();
        _clickByRoute[route] = (_clickByRoute[route] ?? 0) + 1;
        _clickByEntry[entry] = (_clickByEntry[entry] ?? 0) + 1;
      }
    } catch (e) {
      debugPrint('chatbot_clicks read error: $e');
    }
  }

  // 연속 읽은 일수 계산
  int _calcStreak(Map<DateTime, int> daily, DateTime start, DateTime now) {
    int streak = 0;
    DateTime cur = DateTime(now.year, now.month, now.day);
    for (int i = 0; i < widget.rangeDays; i++) {
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

  // 책별 평균
  Future<void> _loadBookAverages() async {
    _bookAverages = [];
    final uid = _uid();
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: widget.rangeDays - 1));

    for (final e in _books.entries) {
      final bId = e.key;
      final title = e.value;

      final col = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('reading_books')
          .doc(bId)
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
      _bookAverages.add(_BookAvgRow(
        bookId: bId,
        title: title,
        avgSecs: avgSecs,
        activeDays: activeDays,
        totalSecs: totalSecs,
      ));
    }

    _bookAverages.sort((a, b) => b.avgSecs.compareTo(a.avgSecs));
  }

  // 오각형 레이더 계산
  List<double> _buildHabitScores() {
    final days = widget.rangeDays.clamp(1, 365);
    final consist = (_activeDays / days) * 100.0;

    final copy = List<int>.from(_dwell)..sort((a, b) => b.compareTo(a));
    final top10 = copy.take(10).toList();
    final topAvg =
        top10.isEmpty ? 0.0 : top10.reduce((a, b) => a + b) / top10.length;
    final focus = (topAvg / 60.0 * 100).clamp(0, 100);

    final mean =
        _dwell.isEmpty ? 0.0 : _dwell.reduce((a, b) => a + b) / _dwell.length;
    final variance = _dwell.isEmpty
        ? 0.0
        : _dwell
                .map((x) => (x - mean) * (x - mean))
                .reduce((a, b) => a + b) /
            _dwell.length;
    final stddev = math.sqrt(variance);
    final cv = mean == 0 ? 1.0 : (stddev / mean);
    final stability = (100 * (1 - cv)).clamp(0, 100);

    final sum = _dwell.fold<int>(0, (a, b) => a + b);
    final top5Sum =
        copy.take((copy.length * 0.05).ceil()).fold<int>(0, (a, b) => a + b);
    final reread = sum == 0 ? 0.0 : (top5Sum / sum * 100.0);

    final totalMin = _hours.fold<int>(0, (a, b) => a + b);
    double entropy = 0;
    for (final m in _hours) {
      if (m <= 0) continue;
      final p = m / (totalMin == 0 ? 1 : totalMin);
      entropy += -p * (p == 0 ? 0 : math.log(p));
    }
    final maxH = math.log(24);
    final rhythm = maxH == 0 ? 0 : (entropy / maxH * 100);

    return [consist, focus, stability, reread, rhythm]
        .map((e) => e.clamp(0, 100).toDouble())
        .toList();
  }

  String _formatHms(int secs) {
    final h = secs ~/ 3600;
    final m = (secs % 3600) ~/ 60;
    final s = secs % 60;
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  // 책멍이 코멘트 프롬포트
  void _refreshCoachNote() {
    final title = _selectedBookId == null
        ? '전체(모든 책)'
        : (_books[_selectedBookId] ?? '선택한 책');

    final radar = _buildHabitScores();
    final prompt = '''
아래 데이터를 바탕으로 간결하고 정중한 한국어로 작성해주세요.

요청 형식(그대로 지켜주세요):
<분석 요약>
- (핵심 수치 위주로 3~4줄)

<책멍이 조언>
- (사용자에게 도움이 되는 전반적인 조언 2~3줄)
- "재독 성향"이 높을 경우에도 무조건 긍정으로 단정하지 말고, 이해가 어려워 멈췄을 수 있다는 가능성을 함께 언급해주세요.
- 마지막 문장은 "모르는 부분이 있으시면 책멍이에게 물어보시는 건 어떨까요?"로 끝내주세요.

데이터:
- 책: $title
- 기간: 최근 ${widget.rangeDays}일
- 총 읽은 시간: ${_formatHms(_totalSecs)}, 세션 수: $_sessionCount, 활동일: $_activeDays, 연속일: $_streak
- 시간대 분포(분): ${_hours.join(',')}
- 정체(버킷별 체류 초): ${_dwell.join(',')}
- 레이더 점수 [꾸준함, 집중 유지, 속도 안정, 재독 성향, 리듬 다양성]: ${radar.map((e)=>e.toStringAsFixed(0)).join(', ')}
''';

    _coachFuture = OpenAIShared.chatWithBook(
      bookTitle: title,
      userPrompt: prompt,
      allowRecommendations: false,
      temperature: 0.2,
    ).then((r) => r.reply);
    setState(() {}); // FutureBuilder 갱신
  }


  @override
  Widget build(BuildContext context) {
    final avgPerActiveDay =
        _activeDays == 0 ? 0 : (_totalSecs ~/ _activeDays);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('독서 패턴 분석'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left_rounded),
          color: Colors.black,
        ),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: const AlwaysStoppedAnimation(Color(0xff0077FF)), backgroundColor: const Color(0xffCCE4FF),                 
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _card('책 선택', _bookDropdown()),
                const SizedBox(height: 12),
                _bookAvgCard(),
                const SizedBox(height: 16),
                _card(
                  '최근 ${widget.rangeDays}일 요약',
                  _metricStrip([
                    ('전체 독서 시간', _formatHms(_totalSecs)),
                    ('하루 평균', _formatHms(avgPerActiveDay)),
                    ('책 펼친 횟수', '$_sessionCount'), 
                    ('독서한 날', '$_activeDays일'),
                    ('연속 독서', '$_streak일'),
                  ]),
                ),
                const SizedBox(height: 16),
                _card(
                  '시간대별 독서 시간',
                  HourBars(
                    values: _hours.map((m) => m.toDouble()).toList(),
                    barMax: 130,
                    barWidth: 18,
                    gap: 10,
                  ),
                ),
                const SizedBox(height: 16),
                _card(
                  '진행률 0~100% 정체 시간 분석',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DwellLineChart(
                        dwell: _dwell,
                        height: 160,
                        step: 6,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '정체 시간 상위 구간(Top 3)',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                      _topBuckets(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _card(
                  '나의 독서 습관 레이더',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HabitRadarChart(scores: _buildHabitScores()),
                      const SizedBox(height: 8),
                      _radarLegend(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _card(
                  '책멍이 코멘트',
                  _coachNote(),
                  titleWidget: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/images/main_Chaekmeong_1.svg',
                        width: 30,
                        height: 30,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '책멍이 코멘트',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // 회색 상자
  Widget _card(
    String title,
    Widget child, {
    Widget? titleWidget,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffF8F8F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleWidget ??
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // 1. 책 선택 드롭다운
  Widget _bookDropdown() {
    final options = <(String?, String)>[
      (null, '전체'),
      ..._books.entries.map<(String?, String)>((e) => (e.key, e.value)),
    ];

    return DropdownButtonFormField<String?>(
      value: _selectedBookId,
      isExpanded: true,
      dropdownColor: const Color(0xffCCE4FF),
      items: [
        for (final (value, label) in options)
          DropdownMenuItem<String?>(
            value: value,
            child: Text(label,
              style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14)),
          ),
      ],
      onChanged: (val) async {
        setState(() { _selectedBookId = val; _loading = true; });
        await _loadMetricsFor(val);
        _refreshCoachNote();
        if (mounted) setState(() => _loading = false);
      },
      decoration: InputDecoration(
        isDense: true,
        hintText: '책을 선택하세요',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xff0077FF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xff0077FF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xff0077FF), width: 2),
        ),
      ),
    );
  }

  // 2. 선택한 책 요약
  Widget _bookAvgCard() {
    if (_selectedBookId == null) {
      return _card('책별 하루 평균 분석 요약',
          const Text('도서 한 권을 선택하면 이곳에 평균이 표시됩니다.'));
    }
    final row = _bookAverages.firstWhere(
      (r) => r.bookId == _selectedBookId,
      orElse: () => _BookAvgRow(
        bookId: _selectedBookId!,
        title: _books[_selectedBookId] ?? '선택한 책',
        avgSecs: 0,
        activeDays: 0,
        totalSecs: 0,
      ),
    );

    return _card(
      '${row.title} 하루 평균 분석 요약',
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x11000000)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(row.title,
                  style: const TextStyle(color: Color(0xff0077FF), fontWeight: FontWeight.w600)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('하루 평균 독서 시간: ${_formatHms(row.avgSecs)}'),
                const SizedBox(height: 2),
                Text('독서한 날: ${row.activeDays}일 · 총 ${_formatHms(row.totalSecs)}',
                    style: const TextStyle(
                        color: Color(0xff777777), fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 3. 최근 30일 요약
  Widget _metricStrip(List<(String, String)> items) {
    return LayoutBuilder(
      builder: (context, c) {
        final gap = 12.0;
        final halfW = (c.maxWidth - gap) / 2; 
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final (label, value) in items)
              SizedBox(
                width: (items.length == 1 || label == '전체 독서 시간')
                    ? c.maxWidth
                    : halfW,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0x11000000)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration( color: Color(0xff0077FF), shape: BoxShape.circle,),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          label,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        value,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xff0077FF),),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // 4. 진행률 정체 구간 (TOP3)
  Widget _topBuckets() {
    final pairs = [
      for (int i = 0; i < 100; i++) {'b': i, 's': _dwell[i]}
    ]..sort((a, b) => (b['s'] as int).compareTo(a['s'] as int));
    final top = pairs.take(3).toList();
    if (top.isEmpty || (top.first['s'] as int) == 0) {
      return const Text('표시할 정체 구간이 없습니다.');
    }

    Widget rowItem(int bucket, int secs) {
      final minStr = '${(secs ~/ 60)}m ${(secs % 60)}s';
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x11000000)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$bucket~${(bucket + 1).clamp(0, 100)}% 구간',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            Text(minStr, style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 12, color: Color(0xff777777))),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final t in top) ...[
          rowItem(t['b'] as int, t['s'] as int),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  // 5. 오각형 레이더
  Widget _radarLegend() {
    final scores = _buildHabitScores().map((e) => e.toStringAsFixed(0)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LegendLine(label: '꾸준', value: scores[0], desc: '얼마나 꾸준히 읽었는지'),
        const SizedBox(height: 6),
        _LegendLine(label: '집중', value: scores[1], desc: '읽는 동안 집중을 잘 유지했는지'),
        const SizedBox(height: 6),
        _LegendLine(label: '안정', value: scores[2], desc: '읽는 속도가 균일한지'),
        const SizedBox(height: 6),
        _LegendLine(label: '재독', value: scores[3], desc: '같은 부분을 반복해서 읽는 성향이 있는지'),
        const SizedBox(height: 6),
        _LegendLine(label: '리듬', value: scores[4], desc: '읽는 시간이 얼마나 고르게 분포했는지'),
      ],
    );
  }

  // 6. 책멍이 코멘트
  Widget _coachNote() {
    if (_coachFuture == null) {
      return const Text('분석을 준비하고 있습니다…',
          style: TextStyle(color: Color(0xff777777)));
    }
    return FutureBuilder<String>(
      future: _coachFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Row(
            children: const [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Color(0xff0077FF)),
                ),
              ),
              SizedBox(width: 8),
              Text('책멍이가 분석 중이에요!'),
            ],
          );
        }
        if (snap.hasError) {
          return Text(
            '코멘트를 불러오지 못했어요.\n${snap.error}',
            style: const TextStyle(color: Color(0xff777777), fontSize: 13),
          );
        }

        final text = (snap.data ?? '').trim();
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xff0077FF), width: 1),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  decoration: const BoxDecoration(
                    color: Color(0xff0077FF),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: _buildCoachRich(
                      text.isEmpty ? '코멘트가 비어 있습니다.' : text,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 책멍이 코멘트 디자인용
  Widget _buildCoachRich(String text) {
    final lines = text.split('\n');
    final children = <Widget>[];

    for (final raw in lines) {
      final line = raw.trimRight();

      if (line.trim().isEmpty) {
        children.add(const SizedBox(height: 6));
        continue;
      }
      final trimmed = line.trim();
      if (RegExp(r'^<.*?>$').hasMatch(trimmed)) {
        final title = trimmed.replaceAll(RegExp(r'[<>]'), '');
        children.add(Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 6),
          child: const Text('',),
        ));
        children.removeLast();
        children.add(Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 6),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ));
        continue;
      }
      final m = RegExp(r'^\-\s*(.*)$').firstMatch(trimmed);
      if (m != null) {
        final body = m.group(1)!;
        children.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(top: 6),
                decoration: const BoxDecoration(
                  color: Color(0xff0077FF),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(
                body,
                style: const TextStyle(fontWeight: FontWeight.w400),)
              ),
            ],
          ),
        ));
        continue;
      }
      children.add(Text(line));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

// 오각형 레이더 설명용
class _LegendLine extends StatelessWidget {
  const _LegendLine({
    super.key,
    required this.label,
    required this.value,
    required this.desc,
  });

  final String label; 
  final String value; 
  final String desc;  

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 14,
    );
    const valueStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Color(0xff0077FF),
    );
    const descStyle = TextStyle(
      fontSize: 12,
      color: Color(0xff777777),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(width: 6),
        Text(value, style: valueStyle),
        const SizedBox(width: 12),
        Expanded(child: Text(desc, style: descStyle)),
      ],
    );
  }
}

// 데이터 모델
class _BookAvgRow {
  final String bookId;
  final String title;
  final int avgSecs;
  final int activeDays;
  final int totalSecs;

  _BookAvgRow({
    required this.bookId,
    required this.title,
    required this.avgSecs,
    required this.activeDays,
    required this.totalSecs,
  });
}
