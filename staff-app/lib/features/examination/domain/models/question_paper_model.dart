/// Immutable Domain Entity representing an institutional examination question
class QuestionPaperItem {
  const QuestionPaperItem({
    required this.id,
    required this.bookId,
    required this.bookName,
    required this.questionText,
    required this.marks,
    required this.pageNo,
    required this.createdAt,
  }) : assert(marks == 10 || marks == 15 || marks == 20, 'Marks must strictly be 10, 15, or 20'),
       assert(pageNo >= 1 && pageNo <= 1000, 'Page number must strictly be between 1 and 1000');

  final String id;
  final String bookId;
  final String bookName;
  final String questionText;
  final int marks; // strictly 10, 15, or 20
  final int pageNo; // max 1000
  final DateTime createdAt;

  QuestionPaperItem copyWith({
    String? id,
    String? bookId,
    String? bookName,
    String? questionText,
    int? marks,
    int? pageNo,
    DateTime? createdAt,
  }) {
    return QuestionPaperItem(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      bookName: bookName ?? this.bookName,
      questionText: questionText ?? this.questionText,
      marks: marks ?? this.marks,
      pageNo: pageNo ?? this.pageNo,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
