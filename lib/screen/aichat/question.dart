// 책 별 질문

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<void> uploadAllBooksQuestions() async {
  final db = FirebaseFirestore.instance;
  final batch = db.batch();

  // ───────────────── 데미안 ─────────────────
  final demian = <String, Map<String, dynamic>>{
    'Q1':  {'questionText': '이 책의 주제', 'level': 1},
    'Q2':  {'questionText': '헤르만 헤세에 대해', 'level': 1},
    'Q3':  {'questionText': '줄거리 한 단락 요약', 'level': 1},
    'Q4':  {'questionText': '주인공 싱클레어의 내적 변화 과정', 'level': 2},
    'Q5':  {'questionText': '데미안이 싱클레어에게 주는 영향', 'level': 2},
    'Q6':  {'questionText': '크로머 사건과 주인공의 연관 관계', 'level': 2},
    'Q7':  {'questionText': '아브락사스의 의미', 'level': 3},
    'Q8':  {'questionText': '등장인물들이 전달하고자 하는 메세지', 'level': 3},
    'Q9':  {'questionText': '책의 주제를 알려주는 대사 한 줄', 'level': 3},
  };

  // ──────────────── 노인과 바다 ────────────────
  final oldManSea = <String, Map<String, dynamic>>{
    'Q1':  {'questionText': '이 책의 주제', 'level': 1},
    'Q2':  {'questionText': '헤밍웨이에 대해', 'level': 1},
    'Q3':  {'questionText': '줄거리 한 단락 요약', 'level': 1},
    'Q4':  {'questionText': '산티아고와 마놀린의 관계', 'level': 2},
    'Q5':  {'questionText': '바다와 거대한 청새치가 상징하는 것', 'level': 2},
    'Q6':  {'questionText': '상어들과의 싸움 장면이 전달하는 메시지', 'level': 2},
    'Q7':  {'questionText': '“패배했으나 패배하지 않았다”는 의미', 'level': 3},
    'Q8':  {'questionText': '바다, 손의 상처, 사자 꿈의 의미 비교', 'level': 3},
    'Q9':  {'questionText': '책의 주제를 알려주는 대사 한 줄', 'level': 3},
  };

  // ───────────────── 변신(카프카) ─────────────────
  final metamorphosis = <String, Map<String, dynamic>>{
    'Q1':  {'questionText': '이 책의 주제', 'level': 1},
    'Q2':  {'questionText': '프란츠 카프카에 대해', 'level': 1},
    'Q3':  {'questionText': '줄거리 한 단락 요약', 'level': 1},
    'Q4':  {'questionText': '그레고르가 벌레로 변한 설정의 의미', 'level': 2},
    'Q5':  {'questionText': '가족들의 태도 변화가 의미하는 것', 'level': 2},
    'Q6':  {'questionText': '사무장 방문 장면이 비판하는 제도나 가치관', 'level': 2},
    'Q7':  {'questionText': '여동생 그레테의 역할 변화의 의미', 'level': 3},
    'Q8':  {'questionText': '책의 주제를 알려주는 대사 한 줄', 'level': 3},
    'Q9':  {'questionText': '문, 음식, 방/문턱의 의미', 'level': 3},
  };

  // ───────────────── 이방인(카뮈) ─────────────────
  final stranger = <String, Map<String, dynamic>>{
    'Q1':  {'questionText': '이 책의 주제', 'level': 1},
    'Q2':  {'questionText': '알베르 카뮈에 대해', 'level': 1},
    'Q3':  {'questionText': '줄거리 한 단락 요약', 'level': 1},
    'Q4':  {'questionText': '뫼르소의 성격과 태도와 사회 규범의 관계', 'level': 2},
    'Q5':  {'questionText': '장례식/태양/바다가 의미하는 것', 'level': 2},
    'Q6':  {'questionText': '재판 장면에서 “사실”과 “규범적 기대”의 의미', 'level': 2},
    'Q7':  {'questionText': '뫼르소와 종교(신부)의 대립에 대해 설명', 'level': 3},
    'Q8':  {'questionText': '마리와의 관계가 드러내는 뫼르소의 세계관', 'level': 3},
    'Q9':  {'questionText': '책의 주제를 알려주는 대사 한 줄', 'level': 3},
  };

  // ──────────────── 인간 실격(다자이 오사무) ────────────────
  final noLongerHuman = <String, Map<String, dynamic>>{
    'Q1':  {'questionText': '이 책의 주제', 'level': 1},
    'Q2':  {'questionText': '다자이 오사무에 대해', 'level': 1},
    'Q3':  {'questionText': '줄거리 한 단락 요약', 'level': 1},
    'Q4':  {'questionText': '요조가 “가면(익살)”을 쓰는 이유', 'level': 2},
    'Q5':  {'questionText': '여성들과의 관계가 요조의 자기인식에 미친 영향', 'level': 2},
    'Q6':  {'questionText': '전후 일본 사회의 분위기와 작품의 연관성', 'level': 2},
    'Q7':  {'questionText': '사진/수기 형식과 신뢰성 문제의 연관', 'level': 3},
    'Q8':  {'questionText': '책의 주제를 알려주는 대사 한 줄', 'level': 3},
    'Q9':  {'questionText': '“실격”, “타인”의 의미 변주', 'level': 3},
  };

  final books = <String, Map<String, Map<String, dynamic>>>{
    '데미안': demian,
    '노인과 바다': oldManSea,
    '변신': metamorphosis,
    '이방인': stranger,
    '인간 실격': noLongerHuman,
  };

  books.forEach((title, items) {
    final ref = db.collection('questions').doc(title);
    batch.set(ref, {'items': items}, SetOptions(merge: true));
  });

  await batch.commit();
}