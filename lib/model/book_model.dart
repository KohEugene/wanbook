// 책 모델 정의
import 'package:cloud_firestore/cloud_firestore.dart';

class BookModel {
  final String title;
  final String author;
  final String? tag;
  final String? imagePath;
  final String? description;

  BookModel({
    required this.title,
    required this.author,
    this.tag,
    this.imagePath,
    this.description,
  });

  factory BookModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookModel(
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      tag: data['tag'],
      imagePath: data['imagePath'],
      description: data['description'],
    );
  }

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      tag: json['tag'],
      imagePath: json['imagePath'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'tag': tag,
      'imagePath': imagePath,
      'description': description,
    };
  }
}