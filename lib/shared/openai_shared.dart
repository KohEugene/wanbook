// ChatGPT API
import 'dart:convert';
import 'package:http/http.dart' as http;

class GuardOutcome {
  final String blockMsg;
  final String category;
  final bool relatedToBook;
  final String guardReason;
  final String otherBookHint;
  const GuardOutcome({
    this.blockMsg = '',
    this.category = 'on_topic',
    this.relatedToBook = true,
    this.guardReason = '',
    this.otherBookHint = '',
  });
  bool get isBlocked => blockMsg.isNotEmpty;
}

class ChatResult {
  final String reply;
  final GuardOutcome meta;
  const ChatResult({required this.reply, required this.meta});
}

class OpenAIShared {
  static const String _apiKey = '';
  static const String _endpoint = 'https://api.openai.com/v1/chat/completions';
  static const String _model = 'gpt-3.5-turbo';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      };

  static Future<Map<String, dynamic>> _postChat(
    List<Map<String, String>> messages, {
    double temperature = 0.7,
  }) async {
    final body = json.encode({
      'model': _model,
      'messages': messages,
      'temperature': temperature,
    });

    final res = await http.post(Uri.parse(_endpoint), headers: _headers, body: body);
    if (res.statusCode == 200) {
      return json.decode(res.body) as Map<String, dynamic>;
    }
    throw Exception('OpenAI error: HTTP ${res.statusCode} ${res.reasonPhrase} | ${res.body}');
  }

  static GuardOutcome classifyPrompt(
    String prompt,
    String bookTitle,
    List<String> bookKeywords,
    bool allowRecommendations,
  ) {
    final p = prompt.trim();
    final lower = p.toLowerCase();
    final current = bookTitle.toLowerCase();

    // 칭찬/격려
    if (_looksLikePraiseOrEncouragement(lower)) {
      return const GuardOutcome(
        category: 'praise',
        relatedToBook: false,
        guardReason: 'praise_or_encouragement',
      );
    }

    // 무조건 허용: 현재 책 직접 언급 or 지시어
    if (lower.contains(current) || _mentionsCurrentBookByDeixis(lower)) {
      if (_mentionsComparisonOrRelation(lower)) return const GuardOutcome(category: 'compare');
      if (allowRecommendations && _looksLikeRelatedRecommendation(lower)) {
        return const GuardOutcome(category: 'recommendation');
      }
      if (_isMetaAboutCurrentBook(lower)) return const GuardOutcome(category: 'meta');
      return const GuardOutcome(category: 'on_topic');
    }

    // 우선 허용
    if (_isMetaAboutCurrentBook(lower)) return const GuardOutcome(category: 'meta');
    if (_mentionsBookKeywords(lower, bookKeywords)) return const GuardOutcome(category: 'on_topic');
    if (_mentionsComparisonOrRelation(lower)) return const GuardOutcome(category: 'compare');
    if (_looksLikeCurrentVsOtherComparison(p, bookTitle)) return const GuardOutcome(category: 'compare');

    // ‘책’ 맥락 없는 일반 "추천"은 무시
    if (allowRecommendations && _looksLikeRelatedRecommendation(lower)) {
      return const GuardOutcome(category: 'recommendation');
    }

    // 느슨한 다른 책 감지 (따옴표 없이도 "X에 대해 알려줘/요약" 등)
    final looseOther = _extractOtherTitleHintLoose(p, current);
    if (looseOther.isNotEmpty) {
      return GuardOutcome(
        blockMsg: '현재 "$bookTitle"에 대한 대화를 하고 있어요! 해당 책과 관련된 내용만 질문해주세요!',
        category: 'guard_block',
        relatedToBook: false,
        guardReason: 'other_book_only_loose',
        otherBookHint: looseOther,
      );
    }

    // "…라는 책" / 따옴표 제목 등 명시적 다른 책
    if (_mentionsExplicitOtherTitleButNotCurrentContext(p, current)) {
      final hint = _extractOtherTitleHint(p);
      return GuardOutcome(
        blockMsg: '현재 "$bookTitle"에 대한 대화를 하고 있어요! 해당 책과 관련된 내용만 질문해주세요!',
        category: 'guard_block',
        relatedToBook: false,
        guardReason: 'other_book_only',
        otherBookHint: hint,
      );
    }

    // 맥락 없음
    return const GuardOutcome(
      category: 'off_topic',
      relatedToBook: false,
      guardReason: 'no_context',
    );
  }

  // 책멍이와 대화
  static Future<ChatResult> chatWithBook({
    required String bookTitle,
    required String userPrompt,
    List<String> bookKeywords = const [],
    bool allowRecommendations = true,
    double temperature = 0.7,
  }) async {
    final outcome = classifyPrompt(userPrompt, bookTitle, bookKeywords, allowRecommendations);
    if (outcome.isBlocked) {
      return ChatResult(reply: outcome.blockMsg, meta: outcome);
    }

    // 추천/비교 힌트
    final forceRecHint = (allowRecommendations && outcome.category == 'recommendation')
        ? '\n[중요] 사용자가 "$bookTitle"을 기준으로 비슷한/연관 도서를 요청했습니다. 반드시 2~3권 추천을 제공하고, 이유를 한 줄로 설명하세요.'
        : '';
    final forceCompareHint = (outcome.category == 'compare')
        ? '\n[중요] 사용자가 "$bookTitle"과 다른 작품의 비교/차이/공통점을 요청했습니다. "$bookTitle"을 중심으로 2~3개 핵심 포인트만 간결히 제시하세요.'
        : '';

    // 시스템 프롬프트
    final system = '''
  당신은 독서 도우미 AI "책멍이"입니다.
  현재 대화 대상 도서 제목은 "$bookTitle" 입니다.$forceRecHint$forceCompareHint

  # 응답 원칙
  1) "$bookTitle"에 관한 질문만 답변합니다. 단, 아래는 모두 "$bookTitle" 관련으로 간주하여 **허용**합니다.
    - 메타: 작가/저자/출간/번역/판본/장르/배경/챕터/등장인물/주제/상징/메시지/해석/인용/문장/구절/요약/결말(요청 시)
    - 내부 개념·키워드: 책 특유 개념/인물/장소/상징/유명 문장
    - 단어/문장 의미: 해당 표현이 책에서 어떻게 쓰였는지
    - **연관 질의 전반**: 비교/대조/차이·공통점/영향/오마주/패러디/원작-리메이크/시퀄·프리퀄/세계관/영화화/동시대 작품과의 관계/같은 작가의 다른 작품과 비교
    - **연관 추천**: "$bookTitle"과 비슷한 책, 같은 작가의 다른 작품, 유사 주제 도서

  2) 다른 책을 **주제로 한 독립 질문**( "$bookTitle"과의 연관·비교 없음 )에는 아래 고정 문구로만 답변합니다.
    현재 "$bookTitle"에 대한 대화를 하고 있어요! 해당 책과 관련된 내용만 질문해주세요!

  3) 단어/문장 질문:
    - 먼저 "$bookTitle"에 실제로 등장/핵심인지 조용히 판단(출력 금지)
    - 등장/핵심이면 맥락·의미·상징·메시지 연결 설명
    - 아니면:
      그 표현은 "$bookTitle"에 나오지 않아요. "$bookTitle"과 관련된 내용만 질문해주세요!

  4) 비교/연관 답변:
    - "$bookTitle"을 중심축으로 2~3개 핵심 대비 포인트만 간결히.
    - 타 작품 상세 줄거리·스포일러는 피하고 필요한 만큼만.

  5) 칭찬/격려를 받았을 때만:
    - 따뜻한 감사 1~2문장 + "$bookTitle"에 대한 질문이 더 있다면 책멍이가 언제든지 답변해드릴게요!

  6) 스타일:
    - 한국어, 친절·따뜻. 추측 금지, 책에서 확인 가능한 범위 내.
    - 스포일러는 요청 시 필요한 만큼만.

  # 책제목에만 따옴표 넣고 나머지는 넣지 마세요.
  ''';

    final data = await _postChat([
      {'role': 'system', 'content': system},
      {'role': 'user', 'content': userPrompt},
    ], temperature: temperature);

    final reply = (data['choices']?[0]?['message']?['content'] as String?)?.trim() ?? '';
    final safeReply = reply.isEmpty ? '답변을 생성하지 못했습니다.' : reply;

    return ChatResult(reply: safeReply, meta: outcome);
  }

  // 서브루틴
  static bool _isMetaAboutCurrentBook(String lower) {
    const meta = [
      '작가','저자','author','지은이','출간','출판','번역','판본','isbn','장르','배경',
      '챕터','장 ','목차','등장인물','캐릭터','인물','주제','메시지','상징','모티프','해석',
      '인용','문장','구절','요약','결말','스포','의미','감상','비평','평','논지','사상','테마'
    ];
    return meta.any((k) => lower.contains(k));
  }

  static bool _mentionsBookKeywords(String lower, List<String> keywords) {
    for (final k in keywords) {
      final t = k.trim().toLowerCase();
      if (t.isNotEmpty && lower.contains(t)) return true;
    }
    return false;
  }

  static bool _looksLikeShortConceptQuery(String raw) {
    final s = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    final wc = s.isEmpty ? 0 : s.split(' ').length;
    if (wc <= 5) return true;
    if (s.endsWith('?') && wc <= 7) return true;
    return false;
  }

  static bool _hasBookContext(String lower) {
    const ctx = ['책', '도서', '작품', '소설', '이 책', '이 작품', '같은 작가', '저자', '작가'];
    return ctx.any((k) => lower.contains(k));
  }

  static bool _looksLikeRelatedRecommendation(String lower) {
    if (!_hasBookContext(lower)) return false;

    const rec = [
      '비슷한 책','비슷한 작품','유사한 책','유사한 작품',
      '같은 작가','다른 작품','읽을 만한','더 읽을','후속 읽기','확장 독서',
      '추천','추천해','추천해줘','추천 좀','추천 부탁','리커멘드','recommend',
      '비슷한 주제','유사한 주제','비슷한 분위기','비슷한 메시지','비슷한 느낌'
    ];
    if (lower.contains('이 책과') && (lower.contains('비슷') || lower.contains('유사'))) return true;
    return rec.any((k) => lower.contains(k));
  }

  static bool _mentionsComparisonOrRelation(String lower) {
    const rel = [
      '비교','대비','대조','차이','차이점','다른 점','차별점',
      '공통','공통점','유사','유사점','비슷','비슷한 점','닮','닮은점',
      '관련','연관','관계','연결','참고','영향','영향받','오마주','패러디',
      '원작','리메이크','영화화','시퀄','프리퀄','세계관','같은 세계관','vs','비견','견줄'
    ];
    return rel.any((k) => lower.contains(k));
  }

  static bool _mentionsCurrentBookByDeixis(String lower) {
    const deictic = ['이 책','이 작품','해당 책','본서','현 작품','현재 책','이 소설'];
    return deictic.any((k) => lower.contains(k));
  }

  static bool _looksLikeCurrentVsOtherComparison(String prompt, String bookTitle) {
    final lower = prompt.toLowerCase();
    final current = bookTitle.toLowerCase();
    if (lower.contains(current) && _mentionsComparisonOrRelation(lower)) return true;
    final hasDeixis = _mentionsCurrentBookByDeixis(lower);
    final hasCompare = _mentionsComparisonOrRelation(lower);
    final otherTitleQuoted = RegExp(r'["“”][^"“”]+["“”]\s*(책|소설|시리즈)?', caseSensitive: false).hasMatch(prompt);
    if (hasDeixis && hasCompare && otherTitleQuoted) return true;
    if (hasDeixis && hasCompare && RegExp(r'(과|와|랑|하고)\s*[^ ]+', caseSensitive: false).hasMatch(lower)) return true;
    return false;
  }

  static bool _mentionsExplicitOtherTitleButNotCurrentContext(String prompt, String currentTitleLower) {
    final lower = prompt.toLowerCase();
    if (lower.contains(currentTitleLower)) return false;
    if (_mentionsCurrentBookByDeixis(lower)) return false;
    if (_mentionsComparisonOrRelation(lower)) return false;
    if (_looksLikeRelatedRecommendation(lower)) return false;
    if (_looksLikeCurrentVsOtherComparison(prompt, currentTitleLower)) return false;

    final patterns = [
      RegExp(r'["“”](.+?)["“”]\s*(라는|이란)?\s*책', caseSensitive: false),
      RegExp(r'["“”](.+?)["“”]\s*(소설|시리즈)', caseSensitive: false),
      RegExp(r'(.+?)\s*(책|소설|시리즈)\s*(어때|어떤|요약|내용|결말|해석|의미)', caseSensitive: false),
    ];
    for (final p in patterns) {
      final m = p.firstMatch(prompt);
      if (m != null) {
        final candidates = [
          for (var i = 1; i <= m.groupCount; i++) (m.group(i) ?? '').trim().toLowerCase()
        ]..removeWhere((e) => e.isEmpty);
        if (candidates.isEmpty) continue;
        final mentioned = candidates.reduce((a, b) => a.length >= b.length ? a : b);
        if (mentioned.isNotEmpty && !currentTitleLower.contains(mentioned)) return true;
      }
    }
    return false;
  }

  static String _extractOtherTitleHint(String text) {
    final m = RegExp(r'["“”]([^"“”]+)["“”]').firstMatch(text);
    if (m != null) return m.group(1)?.trim() ?? '';
    final m2 = RegExp(r'(.+?)\s*(라는|이란)?\s*책').firstMatch(text);
    if (m2 != null) return m2.group(1)?.trim() ?? '';
    return '';
  }

  // 느슨한 “다른 책” 제목 추정 (따옴표 없음)
  static String _extractOtherTitleHintLoose(String text, String currentLower) {
    final lower = text.toLowerCase();

    const stopwords = [
      '주제','등장인물','결말','상징','배경','작가','저자','인용','문장','구절','챕터','장','목차',
      '해석','요약','메시지','세계관','영화화','리메이크','비교','차이','공통점'
    ];

    final m = RegExp(
      r'([\uAC00-\uD7A3A-Za-z0-9\s]{2,20})\s*(에 대해|에대한|에 관해|에관해)\s*(알려줘|설명|요약|정리|무엇|뭐야|가 뭐야)',
      caseSensitive: false,
    ).firstMatch(text);

    if (m != null) {
      final cand = (m.group(1) ?? '').trim();
      if (cand.isEmpty) return '';
      final candLower = cand.toLowerCase();
      if (currentLower.contains(candLower)) return '';
      if (stopwords.any((s) => candLower.contains(s))) return '';
      if (cand.replaceAll(' ', '').length < 2) return '';
      return cand;
    }

    return '';
  }

  static bool _looksLikePraiseOrEncouragement(String lower) {
    const ks = ['고마워','감사','좋아요','잘했','대단','멋지','최고','굿','똑똑','유용','helpful','thanks','thank you','appreciate'];
    return ks.any(lower.contains);
  }

  // 사전지식 요약
  static Future<String> fetchTopicSummary({
    required String bookTitle,
    required String purpose,
    required String topic,
    double temperature = 0.7,
  }) async {
    final system = '''
당신은 독서 도우미 AI입니다.
현재 사용자가 읽는 책 제목은 "$bookTitle" 입니다.
목적은 "$purpose" 입니다.
지금 사용자가 궁금해하는 사전 지식 주제는 "$topic" 입니다.
- "$bookTitle"을 중심으로, "$topic"과 관련된 배경지식/핵심정보를 알려주세요.
- 한국어로 친절하게 답하세요.
''';
    final data = await _postChat([
      {'role': 'system', 'content': system},
      {'role': 'user', 'content': "이 책과 관련된 '$topic' 정보를 알려줘."},
    ], temperature: temperature);
    final reply = (data['choices']?[0]?['message']?['content'] as String?)?.trim() ?? '';
    return reply.isEmpty ? '해당 주제에 대한 정보를 준비하지 못했습니다.' : reply;
  }
}
