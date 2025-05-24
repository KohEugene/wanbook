// 사용자의 독서 상태 저장 모델 정의
class UserBookModel {
  final String title;
  final String author;
  final String? imagePath;
  final String? percent;
  final String? lastReadTime;

  UserBookModel({
    required this.title,
    required this.author,
    this.imagePath,
    this.percent,
    this.lastReadTime,
  });
}