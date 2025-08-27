// 개인 맞춤형 힌트 책멍이용 하트비트
// 하트비트 = 일정 간격으로 돌아오는 점검 루프 (상태를 주기적으로 샘플링/보고)
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

// 데베 저장 구조(로컬 날짜 기준, 하루에 문서 1개):
// users/{userId}/reading_books/{bookId}/reading_metrics/{YYYY-MM-DD}
// ├─ 필드:
// │   • hour_histogram: 길이 24짜리 숫자 배열
// │     → "이 시간대(0~23시)에 몇 분이나 읽었는지"를 1분마다 +1 해둡니다.
// │   • dwell_seconds_by_bucket: 길이 100짜리 숫자 배열
// │     → "진행률 0~99% 구간에서 얼마나 머물렀는지(초단위)" 누적 저장.
// │   • hint_count: 오늘 힌트가 몇 번 떠줬는지.
// │   • last_heartbeat_at: 마지막으로 하트비트가 찍힌 서버시간.
// │   • updated_at: 문서 갱신 서버시간.
// ├─ 하위 컬렉션:
// │   • sessions: 한 번 앱을 켰다 끌 때마다 요약 한 줄 저장
// │     - start_at, end_at, avg_speed(평균 진행속도), total_active_seconds, last_progress
// │   • hint_events: 힌트가 실제로 뜬 순간들 기록
// │     - ts, progress(그때 진행률)
//
// 설정은 두 군데에서 가져옵니다(실시간 반영):
//  • 전역: users/{userId}/reading_settings/hint_config
//  • 책별: users/{userId}/reading_books/{bookId} 문서의 hint_config 필드
//
// BookScreen 쪽에서는
//  • 진행률, UI 보이는지 여부만 알려주면 되고,
//  • 힌트를 띄워야 하는 타이밍이면 onHintShouldShow()를 불러 줍니다.
// ────────────────────────────────────────────────────────────────────────

// 힌트 기준값들
class HintConfig {
  final int stallSecondsPeak;     // 피크시간(보통 자주 읽는 시간대)에서 멈춘 걸로 볼 기준(초)
  final int stallSecondsOff;      // 피크시간이 아닐 때 멈춘 걸로 볼 기준(초)
  final double speedDropRatio;    // 최근 속도가 세션 평균의 이 비율보다 느려지면 "속도 저하"
  final double rereadMultiplier;  // 같은 구간에 평균보다 이 배수만큼 오래 머무르면 "재독"
  final int milestoneBonus;       // 25%, 50% 같은 분기점 근처면 점수 가산
  final int baseThreshold;        // 힌트를 띄우기 위한 최종 점수 기준
  final int cooldownMinutes;      // 힌트 띄운 뒤, 다시 뜨기까지 최소 대기시간(분)
  final bool enable;              // 힌트 전체 ON/OFF
  final List<double> milestones;  // 분기점 위치들(0~1)

  const HintConfig({
    this.stallSecondsPeak = 20,
    this.stallSecondsOff = 45,
    this.speedDropRatio = 0.5,
    this.rereadMultiplier = 1.5,
    this.milestoneBonus = 10,
    this.baseThreshold = 60,
    this.cooldownMinutes = 5,
    this.enable = true,
    this.milestones = const [0.25, 0.5, 0.75],
  });

  // Firestore에서 읽어온 Map을 안전하게 HintConfig로 변환
  static HintConfig fromMap(Map<String, dynamic>? m) {
    if (m == null) return const HintConfig();
    return HintConfig(
      stallSecondsPeak: (m['stall_seconds_peak'] ?? 20) is int ? m['stall_seconds_peak'] : 20,
      stallSecondsOff : (m['stall_seconds_off']  ?? 45) is int ? m['stall_seconds_off']  : 45,
      speedDropRatio  : (m['speed_drop_ratio']   ?? 0.5).toDouble(),
      rereadMultiplier: (m['reread_multiplier']  ?? 1.5).toDouble(),
      milestoneBonus  : (m['milestone_bonus']    ?? 10) is int ? m['milestone_bonus'] : 10,
      baseThreshold   : (m['base_threshold']     ?? 60) is int ? m['base_threshold'] : 60,
      cooldownMinutes : (m['cooldown_minutes']   ?? 5)  is int ? m['cooldown_minutes'] : 5,
      enable          : (m['enable'] ?? true) == true,
      milestones      : (m['milestones'] is List
                          ? List<double>.from((m['milestones'] as List).map((e) => (e as num).toDouble()))
                          : const [0.25, 0.5, 0.75]),
    );
  }

  // 전역 기본값과 책별 값 합치기
  static HintConfig merge(HintConfig base, HintConfig override) {
    final d = const HintConfig();
    return HintConfig(
      stallSecondsPeak: override.stallSecondsPeak != d.stallSecondsPeak ? override.stallSecondsPeak : base.stallSecondsPeak,
      stallSecondsOff : override.stallSecondsOff  != d.stallSecondsOff  ? override.stallSecondsOff  : base.stallSecondsOff,
      speedDropRatio  : override.speedDropRatio   != d.speedDropRatio   ? override.speedDropRatio   : base.speedDropRatio,
      rereadMultiplier: override.rereadMultiplier != d.rereadMultiplier ? override.rereadMultiplier : base.rereadMultiplier,
      milestoneBonus  : override.milestoneBonus   != d.milestoneBonus   ? override.milestoneBonus   : base.milestoneBonus,
      baseThreshold   : override.baseThreshold    != d.baseThreshold    ? override.baseThreshold    : base.baseThreshold,
      cooldownMinutes : override.cooldownMinutes  != d.cooldownMinutes  ? override.cooldownMinutes  : base.cooldownMinutes,
      enable          : override.enable           != d.enable           ? override.enable           : base.enable,
      milestones      : override.milestones != d.milestones ? override.milestones : base.milestones,
    );
  }
}

// 하트비트 서비스
class ReadingHeartbeat {
  final FirebaseFirestore firestore;
  final String userId;
  final String bookId;
  final double Function() getProgress; // 현재 진행률(0~1)
  final bool Function() isUIVisible;   // UI가 보이는 중이면 힌트는 띄우지 않음
  final void Function() onHintShouldShow; // 힌트를 실제로 띄우라고 알리는 콜백

  Timer? _timer;
  DateTime _lastMoveAt = DateTime.now(); // 마지막으로 스크롤/진행률이 바뀐 시각
  double _lastProgressForStall = 0.0;    // 이전 체크 때의 진행률(속도/정체 비교용)
  final Map<int, double> _dwellSecondsByBucket = {}; // 각 진행률 구간(0~99%)에서 머문 시간(초)
  int _currentBucket = 0;                // 지금 사용자가 있는 진행률 구간
  final List<int> _hourHistogram = List.filled(24, 0);  // 시간대별(0~23시) 읽은 "분" 카운트
  final List<double> _recentProgressDeltas = [];        // 최근 120초 동안의 진행률 변화량 모음
  DateTime _lastHintShownAt = DateTime.fromMillisecondsSinceEpoch(0); // 마지막 힌트 시각(쿨다운용)
  DateTime _sessionStart = DateTime.now(); // 이번 세션 시작 시간
  String _dayKey = _makeDayKey(DateTime.now()); // 오늘 날짜(YYYY-MM-DD)

  HintConfig _hintConfig = const HintConfig();
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _globalCfgSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _bookCfgSub;

  ReadingHeartbeat({
    required this.firestore,
    required this.userId,
    required this.bookId,
    required this.getProgress,
    required this.isUIVisible,
    required this.onHintShouldShow,
  });

  // 마지막 움직임 갱신
  void onUserProgressChanged(double progress) {
    _lastMoveAt = DateTime.now();
    _currentBucket = (progress * 100).clamp(0, 99).toInt();

    final delta = (progress - _lastProgressForStall).abs();
    _recentProgressDeltas.add(delta);
    if (_recentProgressDeltas.length > 120) _recentProgressDeltas.removeAt(0); // 최근 120초만 보관
    _lastProgressForStall = progress;
  }

  // 하트비트 시작 (오늘 문서(hour_histogram) 불러오기 → 이어서 쓰기)
  Future<void> start() async {
    await _loadDayHistogramFromDoc();
    _subscribeHintConfig();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  // 하트비트 종료 (타이머 멈추고, 누적된 통계 저장)
  Future<void> stop() async {
    _timer?.cancel();
    await _persistHourHistogramForDay();
    await _persistDwellAndSessionSummaryForDay();
    await _globalCfgSub?.cancel();
    await _bookCfgSub?.cancel();
  }

  // 말풍선에 넣을 간단 메시지(진행률만 보고 정함)
  String hintMessageFor(double progress) {
    if (progress < 0.05) return "시작이 반!\n이 책에 대해 미리 알아볼까요??";
    if (progress < 0.3)  return "이 부분 핵심만 추려볼까요?\n요약/키워드 추천!";
    if (progress < 0.7)  return "이제 중반부예요!\n인물/개념 관계 정리해드릴까요?";
    if (progress < 0.95) return "마무리 단계!\n놓친 포인트를 점검해볼까요?";
    return "완독 코앞!\n핵심만 빠르게 리마인드해드릴게요.";
  }

  // 1초마다 하는 일(_tick)
  // 1) 날짜가 바뀌었는지 확인 → 바뀌면 오늘 문서로 갈아타기
  // 2) 현재 진행률 구간에 머문 시간 1초 추가
  // 3) 매 분 00초마다, 현재 시(hour)에 +1 (hour_histogram 저장)
  // 4) 설정기준대로 점수 계산:
  //     - 오랫동안 안 움직였나(정체)?
  //     - 최근 속도가 평균보다 많이 느려졌나?
  //     - 같은 구간에 유난히 오래 머무나(재독)?
  //     - 분기점(25/50/75%) 근처인가?
  // 5) 점수가 기준 이상이고, 쿨다운 끝났고, UI가 숨겨져 있으면 → 힌트 띄우라고 콜백
  void _tick(Timer _) async {
    final now = DateTime.now();

    // 날짜 바뀌면 오늘 키로 교체 + 기존 값 이어받기
    final nowKey = _makeDayKey(now);
    if (nowKey != _dayKey) {
      _dayKey = nowKey;
      for (int i = 0; i < 24; i++) _hourHistogram[i] = 0;
      await _loadDayHistogramFromDoc();
    }

    // 현재 진행률 구간 체류 시간 1초 누적
    _dwellSecondsByBucket[_currentBucket] = (_dwellSecondsByBucket[_currentBucket] ?? 0) + 1;

    // 매 분 정각에 hour_histogram 1 증가 + 헬스비트 찍기
    if (now.second == 0) {
      _hourHistogram[now.hour] = _hourHistogram[now.hour] + 1;
      unawaited(_persistHourHistogramForDay());
      unawaited(_persistHeartbeatHealthForDay());
    }

    if (!_hintConfig.enable) return;

    final progress = getProgress();

    // 정체 판단(피크시간대면 더 빨리 힌트 고려)
    final isPeakHour = _isPeakHourNow();
    final stallSec = isPeakHour ? _hintConfig.stallSecondsPeak : _hintConfig.stallSecondsOff;
    final progressStalled = DateTime.now().difference(_lastMoveAt).inSeconds >= stallSec;

    // 속도 하락(최근 속도 < 세션 평균 * 비율)
    final recentAvg = _recentProgressDeltas.isEmpty
        ? 0.0
        : _recentProgressDeltas.reduce((a, b) => a + b) / _recentProgressDeltas.length;
    final sessionAvg = _estimateSessionAvgSpeed();
    final speedDrop = sessionAvg > 0 && recentAvg < sessionAvg * _hintConfig.speedDropRatio;

    // 재독(해당 구간 체류 시간이 평균보다 훨씬 김)
    final dwellAvg = _dwellSecondsByBucket.values.isEmpty
        ? 0.0
        : _dwellSecondsByBucket.values.reduce((a,b)=>a+b) / _dwellSecondsByBucket.length;
    final dwellHere = _dwellSecondsByBucket[_currentBucket] ?? 0.0;
    final rereadPattern = dwellAvg > 0 && dwellHere > dwellAvg * _hintConfig.rereadMultiplier;

    // 분기점 근처(±1%p)
    final nearMilestone = _hintConfig.milestones.any((m) => (progress - m).abs() < 0.01);

    // 점수 계산(가중치는 필요하면 조절 가능)
    int score = 0;
    if (progressStalled) score += 40;
    if (speedDrop)      score += 25;
    if (rereadPattern)  score += 25;
    if (nearMilestone)  score += _hintConfig.milestoneBonus;

    // 쿨다운이 끝났고, UI가 보이지 않을 때만 힌트 띄움
    final canShowCooldown =
        DateTime.now().difference(_lastHintShownAt).inMinutes >= _hintConfig.cooldownMinutes;
    final canShow = canShowCooldown && !isUIVisible();

    if (score >= _hintConfig.baseThreshold && canShow) {
      _lastHintShownAt = DateTime.now();
      onHintShouldShow();             
      unawaited(_logHintEventForDay(progress)); // 힌트 뜬 기록 남기기
    }
  }

  // 설정(전역/책별)을 실시간으로 받아오기
  void _subscribeHintConfig() {
    final globalRef = firestore
        .collection('users').doc(userId)
        .collection('reading_settings').doc('hint_config');

    final bookDocRef = firestore
        .collection('users').doc(userId)
        .collection('reading_books').doc(bookId);

    _globalCfgSub = globalRef.snapshots().listen((snap) {
      _hintConfig = HintConfig.fromMap(snap.data());
    });

    _bookCfgSub = bookDocRef.snapshots().listen((snap) {
      final data = snap.data();
      final override = HintConfig.fromMap(
        data != null ? (data['hint_config'] as Map<String, dynamic>?) : null,
      );
      _hintConfig = HintConfig.merge(_hintConfig, override);
    });
  }

  // 최근 120초의 진행률 변화 평균 → "대략적인 현재 속도"
  double _estimateSessionAvgSpeed() {
    if (_recentProgressDeltas.isEmpty) return 0.0;
    final sum = _recentProgressDeltas.fold<double>(0.0, (a,b)=>a+b);
    return sum / _recentProgressDeltas.length;
  }

  // 지금 시간이 "자주 읽는 시간대"인지 확인 (hour_histogram에서 가장 큰 시간대를 골라서, 그 시간대 ±1시간이면 피크로 봄)
  bool _isPeakHourNow() {
    int peakHour = 0, peakCount = -1;
    for (int h = 0; h < 24; h++) {
      if (_hourHistogram[h] > peakCount) {
        peakCount = _hourHistogram[h];
        peakHour = h;
      }
    }
    final nowH = DateTime.now().hour;
    return (nowH == peakHour) || (nowH == (peakHour + 23) % 24) || (nowH == (peakHour + 1) % 24);
  }

  // 날짜
  static String _makeDayKey(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  // 오늘 날짜 문서 가져오기
  DocumentReference<Map<String, dynamic>> _dayDocRef() {
    return firestore
      .collection('users').doc(userId)
      .collection('reading_books').doc(bookId)
      .collection('reading_metrics').doc(_dayKey);
  }

  // 오늘 문서에서 hour_histogram 있으면 읽어와 이어 쓰기
  Future<void> _loadDayHistogramFromDoc() async {
    try {
      final snap = await _dayDocRef().get();
      final data = snap.data();
      if (data != null && data['hour_histogram'] is List) {
        final arr = List<int>.from(data['hour_histogram']);
        for (int i = 0; i < 24 && i < arr.length; i++) {
          _hourHistogram[i] = arr[i];
        }
      }
    } catch (_) {}
  }

  // hour_histogram 저장(있으면 덮어쓰고, 없으면 만들기)
  Future<void> _persistHourHistogramForDay() async {
    try {
      await _dayDocRef().set({
        'hour_histogram': _hourHistogram,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  // "하트비트가 살아있다"는 표시(모니터링용)
  Future<void> _persistHeartbeatHealthForDay() async {
    try {
      await _dayDocRef().set({
        'last_heartbeat_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  // 앱을 닫거나 화면을 떠날 때 마지막으로 통계 정리 저장
  // dwell_seconds_by_bucket: 오늘 문서의 기존값과 "더해서" 저장
  // sessions: 이번 세션 요약 1줄 추가
  Future<void> _persistDwellAndSessionSummaryForDay() async {
    try {
      final ref = _dayDocRef();

      // 기존 dwell 가져오기(없으면 전부 0)
      final snap = await ref.get();
      List<int> prevDwell = List.filled(100, 0);
      if (snap.exists) {
        final data = snap.data();
        if (data != null && data['dwell_seconds_by_bucket'] is List) {
          final arr = List<num>.from(data['dwell_seconds_by_bucket']);
          for (int i = 0; i < 100 && i < arr.length; i++) {
            prevDwell[i] = arr[i].round();
          }
        }
      }

      // 이번 세션 dwell을 int 배열로
      final sessionDwell =
          List<int>.generate(100, (i) => (_dwellSecondsByBucket[i] ?? 0).round());

      // 기존 + 이번 = 합쳐서 저장
      final merged =
          List<int>.generate(100, (i) => prevDwell[i] + sessionDwell[i]);

      final avgSpeed = _estimateSessionAvgSpeed();
      final totalActiveSeconds = sessionDwell.fold<int>(0, (a, b) => a + b);

      await ref.set({
        'dwell_seconds_by_bucket': merged,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 세션 요약 한 줄 추가
      await ref.collection('sessions').add({
        'start_at': Timestamp.fromDate(_sessionStart),
        'end_at': FieldValue.serverTimestamp(),
        'avg_speed': double.parse(avgSpeed.toStringAsFixed(6)),
        'total_active_seconds': totalActiveSeconds,
        'last_progress': double.parse(getProgress().toStringAsFixed(4)),
      });
    } catch (_) {}
  }

  // 힌트가 실제로 떴을 때의 기록 남기기
  Future<void> _logHintEventForDay(double progress) async {
    try {
      final ref = _dayDocRef();
      await ref.collection('hint_events').add({
        'ts': FieldValue.serverTimestamp(),
        'progress': double.parse(progress.toStringAsFixed(4)),
      });
      await ref.set({'hint_count': FieldValue.increment(1)}, SetOptions(merge: true));
    } catch (_) {}
  }
}

//unawaited: 결과를 기다리지 않고 그냥 "던져놓는" 비동기 호출에 사용
void unawaited(Future<void> f) {}
