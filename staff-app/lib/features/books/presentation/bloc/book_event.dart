import 'package:equatable/equatable.dart';

abstract class BookEvent extends Equatable {
  const BookEvent();

  @override
  List<Object?> get props => [];
}

class LoadBooksEvent extends BookEvent {
  const LoadBooksEvent({
    this.subjectId,
    this.term,
    this.category,
  });

  final String? subjectId;
  final String? term;
  final String? category;

  @override
  List<Object?> get props => [subjectId, term, category];
}

class FilterSubjectSelectedEvent extends BookEvent {
  const FilterSubjectSelectedEvent(this.subjectId);

  final String subjectId;

  @override
  List<Object?> get props => [subjectId];
}

class FilterTermSelectedEvent extends BookEvent {
  const FilterTermSelectedEvent(this.term);

  final String term; // 'ALL', 'FULL_YEAR', 'TERM_1', 'TERM_2'

  @override
  List<Object?> get props => [term];
}

class FilterCategorySelectedEvent extends BookEvent {
  const FilterCategorySelectedEvent(this.category);

  final String category; // 'ALL', 'DEENI', 'ASRI'

  @override
  List<Object?> get props => [category];
}

class CreateBookEvent extends BookEvent {
  const CreateBookEvent({
    required this.subjectId,
    required this.nameEnglish,
    required this.nameUrdu,
    required this.category,
    required this.term,
    required this.maxMarks,
    required this.passMarks,
    required this.theoryMarks,
    required this.practicalMarks,
  });

  final String subjectId;
  final String nameEnglish;
  final String nameUrdu;
  final String category;
  final String term;
  final int maxMarks;
  final int passMarks;
  final int theoryMarks;
  final int practicalMarks;

  @override
  List<Object?> get props => [
        subjectId,
        nameEnglish,
        nameUrdu,
        category,
        term,
        maxMarks,
        passMarks,
        theoryMarks,
        practicalMarks,
      ];
}

class UpdateBookEvent extends BookEvent {
  const UpdateBookEvent({
    required this.id,
    required this.subjectId,
    required this.nameEnglish,
    required this.nameUrdu,
    required this.category,
    required this.term,
    required this.maxMarks,
    required this.passMarks,
    required this.theoryMarks,
    required this.practicalMarks,
  });

  final String id;
  final String subjectId;
  final String nameEnglish;
  final String nameUrdu;
  final String category;
  final String term;
  final int maxMarks;
  final int passMarks;
  final int theoryMarks;
  final int practicalMarks;

  @override
  List<Object?> get props => [
        id,
        subjectId,
        nameEnglish,
        nameUrdu,
        category,
        term,
        maxMarks,
        passMarks,
        theoryMarks,
        practicalMarks,
      ];
}

class DeleteBookEvent extends BookEvent {
  const DeleteBookEvent({
    required this.id,
    required this.pin,
  });

  final String id;
  final String pin;

  @override
  List<Object?> get props => [id, pin];
}

class SearchBooksEvent extends BookEvent {
  const SearchBooksEvent(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}
