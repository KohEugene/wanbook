// 사용자 독서 패턴 분석 화면
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanbook/provider/user_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wanbook/shared/openai_shared.dart';
import 'package:wanbook/screen/profile/analyze_chart.dart';
import 'package:wanbook/screen/profile/analyze_value.dart';

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
  bool _showRadarDetails = false;

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
      final loadedBooks = await AnalyzeValue.loadBooks(context);
      _books
        ..clear()
        ..addAll(loadedBooks);

      final m = await AnalyzeValue.loadMetrics(
        context: context,
        selectedBookId: _selectedBookId,
        books: _books,
        rangeDays: widget.rangeDays,
      );
      _applyMetrics(m);

      final avgs = await AnalyzeValue.loadBookAverages(
        context: context,
        books: _books,
        rangeDays: widget.rangeDays,
      );
      _bookAverages = avgs.map((r) => _BookAvgRow(
        bookId: r.bookId,
        title: r.title,
        avgSecs: r.avgSecs,
        activeDays: r.activeDays,
        totalSecs: r.totalSecs,
      )).toList();

      _refreshCoachNote();
    } catch (e) {
      debugPrint('Analyze bootstrap error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyMetrics(AnalyzeMetrics m) {
    _totalSecs = m.totalSecs;
    _activeDays = m.activeDays;
    _sessionCount = m.sessionCount;
    _streak = m.streak;
    _hours = m.hours;
    _dwell = m.dwell;
    _clickByRoute = m.clickByRoute;
    _clickByEntry = m.clickByEntry;
  }

  // reading_metrics 합산
  Future<void> _loadMetricsFor(String? bookId) async {
    final m = await AnalyzeValue.loadMetrics(
      context: context,
      selectedBookId: bookId,
      books: _books,
      rangeDays: widget.rangeDays,
    );
    _applyMetrics(m);
  }

  // 오각형 레이더 계산
  List<double> _buildHabitScores() {
    return AnalyzeValue.buildHabitScores(
      m: AnalyzeMetrics(
        totalSecs: _totalSecs,
        activeDays: _activeDays,
        sessionCount: _sessionCount,
        streak: _streak,
        hours: _hours,
        dwell: _dwell,
        clickByRoute: _clickByRoute,
        clickByEntry: _clickByEntry,
      ),
      rangeDays: widget.rangeDays,
    );
  }

  // 오각형 설명 텍스트
  List<HabitDetail> _buildHabitDetails() {
    return AnalyzeValue.buildHabitDetails(
      m: AnalyzeMetrics(
        totalSecs: _totalSecs,
        activeDays: _activeDays,
        sessionCount: _sessionCount,
        streak: _streak,
        hours: _hours,
        dwell: _dwell,
        clickByRoute: _clickByRoute,
        clickByEntry: _clickByEntry,
      ),
      rangeDays: widget.rangeDays,
    );
  }

  String _formatHms(int secs) {
    return AnalyzeValue.formatHms(secs);
  }

  // 책멍이 코멘트 프롬포트
  void _refreshCoachNote() {
    final title = _selectedBookId == null
        ? '전체(모든 책)'
        : (_books[_selectedBookId] ?? '선택한 책');

    final radar = _buildHabitScores();
    final prompt = AnalyzeValue.buildCoachPrompt(
      title: title,
      rangeDays: widget.rangeDays,
      m: AnalyzeMetrics(
        totalSecs: _totalSecs,
        activeDays: _activeDays,
        sessionCount: _sessionCount,
        streak: _streak,
        hours: _hours,
        dwell: _dwell,
        clickByRoute: _clickByRoute,
        clickByEntry: _clickByEntry,
      ),
      radar: radar,
      hours: _hours,
      dwell: _dwell,
    );

    _coachFuture = OpenAIShared.chatWithBook(
      bookTitle: title,
      userPrompt: prompt,
      allowRecommendations: false,
      temperature: 0.2,
    ).then((r) => r.reply);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final avgPerActiveDay =
        _activeDays == 0 ? 0 : (_totalSecs ~/ _activeDays);
    final radarScores = _buildHabitScores();
    final details = _buildHabitDetails();

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
                valueColor: const AlwaysStoppedAnimation(Color(0xff0077FF)),
                backgroundColor: const Color(0xffCCE4FF),
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
                      HabitRadarChart(scores: radarScores),
                      const SizedBox(height: 8),
                      _radarLegend(radarScores),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () => setState(() => _showRadarDetails = !_showRadarDetails),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xff777777),
                            textStyle: const TextStyle(fontSize: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ).copyWith(
                            overlayColor: WidgetStateProperty.all(Colors.transparent),
                            splashFactory: NoSplash.splashFactory,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_showRadarDetails ? '자세한 설명 접기' : '자세한 설명 보기'),
                              const SizedBox(width: 4),
                              Icon(_showRadarDetails ? Icons.chevron_left_rounded : Icons.chevron_right_rounded, size: 12,),
                            ],
                          ),
                        ),
                      ),
                      AnimatedCrossFade(
                        crossFadeState: _showRadarDetails ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                        duration: const Duration(milliseconds: 180),
                        firstChild: _radarDetails(details),
                        secondChild: const SizedBox.shrink(),
                      ),
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
                Text('하루 평균 독서 시간: ${AnalyzeValue.formatHms(row.avgSecs)}'),
                const SizedBox(height: 2),
                Text('독서한 날: ${row.activeDays}일 · 총 ${AnalyzeValue.formatHms(row.totalSecs)}',
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
                        decoration: const BoxDecoration(
                          color: Color(0xff0077FF),
                          shape: BoxShape.circle,
                        ),
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
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xff0077FF)),
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

  // 5-1. 오각형 레이더
  Widget _radarLegend(List<double> scores) {
    final s = scores.map((e) => e.toStringAsFixed(0)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LegendLine(label: '꾸준', value: s[0], desc: '얼마나 꾸준히 읽었는지'),
        const SizedBox(height: 6),
        _LegendLine(label: '집중', value: s[1], desc: '읽는 동안 집중을 잘 유지했는지'),
        const SizedBox(height: 6),
        _LegendLine(label: '안정', value: s[2], desc: '읽는 속도가 균일한지'),
        const SizedBox(height: 6),
        _LegendLine(label: '재독', value: s[3], desc: '같은 부분을 반복해서 읽는 성향이 있는지'),
        const SizedBox(height: 6),
        _LegendLine(label: '리듬', value: s[4], desc: '읽는 시간이 얼마나 고르게 분포했는지'),
      ],
    );
  }

  // 5-2. 오각형 상세 설명
  Widget _radarDetails(List<HabitDetail> details) {
    const labelStyle = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 14,
      color: Colors.black,
    );
    const descStyle = TextStyle(
      fontSize: 12,
      color: Color(0xff777777),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final d in details) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d.label, style: labelStyle),
                const SizedBox(height: 6),
                Text(d.methodText, style: descStyle),
              ],
            ),
          ),
        ],
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

// 오각형 레이더용 클래스
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
