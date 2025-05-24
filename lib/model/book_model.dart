// 책 모델 정의
import 'package:cloud_firestore/cloud_firestore.dart';

class BookModel {
  final String title;
  final String author;
  final String? imagePath;
  final int? totalPages;
  final String? description;

  BookModel({
    required this.title,
    required this.author,
    this.imagePath,
    this.totalPages,
    this.description,
  });

  factory BookModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookModel(
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      imagePath: data['imagePath'],
      totalPages: data['page_count'],
      description: data['description'],
    );
  }
}