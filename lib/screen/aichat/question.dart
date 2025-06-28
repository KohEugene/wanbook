import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> uploadDemianQuestionsToField() async {
  final Map<String, dynamic> items = {
    'Q1': {
      'questionText': '주인공 싱클레어는 어떤 사람이야?',
      'level': 1,
    },
    'Q2': {
      'questionText': '데미안은 어떤 인물로 등장해?',
      'level': 1,
    },
    'Q3': {
      'questionText': '초반 줄거리 간단히 알려줘',
      'level': 1,
    },
    'Q4': {
      'questionText': '데미안이 싱클레어에게 준 영향은 뭐야?',
      'level': 2,
    },
    'Q5': {
      'questionText': '크로머 사건은 왜 중요할까?',
      'level': 2,
    },
    'Q6': {
      'questionText': '브라울라는 누구고, 어떤 존재야?',
      'level': 2,
    },
    'Q7': {
      'questionText': '아브락사스는 어떤 철학을 담고 있을까?',
      'level': 3,
    },
    'Q8': {
      'questionText': '이 소설은 어떻게 자아를 탐구할까?',
      'level': 3,
    },
    'Q9': {
      'questionText': '선과 악의 경계를 작가는 어떻게 그려?',
      'level': 3,
    },
    'Q10': {
      'questionText': '싱클레어의 성장은 어떤 메시지를 줄까?',
      'level': 3,
    },
  };

  await FirebaseFirestore.instance
      .collection('questions')
      .doc('데미안')
      .set({'items': items});
}
