// 도서 질문 목록 provider

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QuestionProvider with ChangeNotifier {
  Future<List<String>> fetchQuestionsByLevel(String bookTitle, int level) async {
    final doc = await FirebaseFirestore.instance
        .collection('questions')
        .doc(bookTitle)
        .get();

    final data = doc.data();
    if (data == null) return [];

    final items = data['items'];
    if (items is! Map) return [];

    final List<String> result = [];

    items.forEach((key, value) {
      if (value is Map) {
        final itemLevel = value['level'];
        final questionText = value['questionText']?.toString();
        final int? asInt =
            (itemLevel is int) ? itemLevel : int.tryParse(itemLevel?.toString() ?? '');

        if (asInt == level && questionText != null) {
          result.add(questionText);
        }
      }
    });

    return result;
  }
}




