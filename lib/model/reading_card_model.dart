import 'book_model.dart';

class ReadingCardModel {
  final BookModel? longestReadBook;
  final Duration? longestReadDuration;
  final BookModel? shortestReadBook;
  final Duration? shortestReadDuration;

  ReadingCardModel({
    required this.longestReadBook,
    required this.longestReadDuration,
    required this.shortestReadBook,
    required this.shortestReadDuration,
  });
}