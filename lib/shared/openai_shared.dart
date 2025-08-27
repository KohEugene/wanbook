// ChatGPT API
import 'dart:convert';
import 'package:http/http.dart' as http;

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

  // 책멍이와 대화
  static Future<String> chatWithBook({
    required String bookTitle,
    required String userPrompt,
    double temperature = 0.7,
  }) async {
    final system = '''
당신은 독서 도우미 AI입니다.
지금 사용자가 대화하는 도서 제목은 "$bookTitle" 입니다.
- 사용자가 책 제목을 명시하지 않아도 기본적으로 "$bookTitle"을 기준으로 답하세요.
- 가능한 한 책의 핵심 주제/인물/챕터 구조/핵심 문장/메시지/배경지식 중심으로 자세하게 답하세요.
- 한국어로 친절하게 답하세요.
''';

    final data = await _postChat([
      {'role': 'system', 'content': system},
      {'role': 'user', 'content': userPrompt},
    ], temperature: temperature);

    final reply = (data['choices']?[0]?['message']?['content'] as String?)?.trim() ?? '';
    return reply.isEmpty ? '답변을 생성하지 못했습니다.' : reply;
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
