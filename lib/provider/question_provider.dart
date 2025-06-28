// 도서 질문 목록 provider

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QuestionProvider with ChangeNotifier {
  Future<List<String>> fetchQuestionsByLevel(String bookTitle, int level) async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('questions')
        .doc(bookTitle)
        .get();

    final data = docSnapshot.data();
    final items = data?['items'];

    final filteredQuestions = <String>[];

    items.forEach((key, value) {
      final itemLevel = value['level'];
      final questionText = value['questionText'];

      if ((itemLevel is int && itemLevel == level) ||
          (itemLevel is String && int.tryParse(itemLevel) == level)) {
        filteredQuestions.add(questionText);
      }
    });

    return filteredQuestions;
  }
}




