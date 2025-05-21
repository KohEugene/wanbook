// 책 모델 정의
class BookModel {
  final String title;
  final String author;
  final String? imagePath;
  final String? percent;
  final String? lastReadTime;

  BookModel({
    required this.title,
    required this.author,
    this.imagePath,
    this.percent,
    this.lastReadTime,
  });
}