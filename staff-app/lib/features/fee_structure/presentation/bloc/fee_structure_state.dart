import 'package:equatable/equatable.dart';
import 'package:staff_app/features/classes/domain/entities/class_entity.dart';
import 'package:staff_app/features/courses/domain/entities/course_entity.dart';
import 'package:staff_app/features/fee_structure/domain/entities/fee_structure_entity.dart';

abstract class FeeStructureState extends Equatable {
  const FeeStructureState();

  @override
  List<Object?> get props => [];
}

class FeeStructureInitial extends FeeStructureState {
  const FeeStructureInitial();
}

class FeeStructureLoading extends FeeStructureState {
  const FeeStructureLoading();
}

class FeeStructureLoaded extends FeeStructureState {
  const FeeStructureLoaded({
    required this.fees,
    required this.classes,
    required this.courses,
    this.selectedCourseId = 'ALL',
    this.searchQuery = '',
    this.statusMessage,
  });

  final List<FeeStructureEntity> fees;
  final List<ClassEntity> classes;
  final List<CourseEntity> courses;
  final String selectedCourseId;
  final String searchQuery;
  final String? statusMessage;

  List<ClassEntity> get filteredClasses {
    return classes.where((c) {
      final matchesCourse = selectedCourseId == 'ALL' || c.courseId == selectedCourseId;
      final matchesQuery = searchQuery.isEmpty ||
          c.nameEnglish.toLowerCase().contains(searchQuery.toLowerCase()) ||
          (c.nameUrdu ?? '').toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCourse && matchesQuery;
    }).toList();
  }

  List<FeeStructureEntity> get filteredFees {
    if (selectedCourseId == 'ALL') return fees;
    return fees.where((f) {
      final clazz = classes.where((c) => c.id == f.classId).firstOrNull;
      return clazz != null && clazz.courseId == selectedCourseId;
    }).toList();
  }

  List<ClassEntity> get classesWithoutFee {
    var list = classes.where((c) => !fees.any((f) => f.classId == c.id)).toList();
    if (selectedCourseId != 'ALL') {
      list = list.where((c) => c.courseId == selectedCourseId).toList();
    }
    return list;
  }

  FeeStructureEntity? getFeeForClass(String classId) {
    try {
      return fees.firstWhere((f) => f.classId == classId);
    } catch (_) {
      return null;
    }
  }

  FeeStructureLoaded copyWith({
    List<FeeStructureEntity>? fees,
    List<ClassEntity>? classes,
    List<CourseEntity>? courses,
    String? selectedCourseId,
    String? searchQuery,
    String? statusMessage,
  }) {
    return FeeStructureLoaded(
      fees: fees ?? this.fees,
      classes: classes ?? this.classes,
      courses: courses ?? this.courses,
      selectedCourseId: selectedCourseId ?? this.selectedCourseId,
      searchQuery: searchQuery ?? this.searchQuery,
      statusMessage: statusMessage,
    );
  }

  @override
  List<Object?> get props => [
        fees,
        classes,
        courses,
        selectedCourseId,
        searchQuery,
        statusMessage,
      ];
}

class FeeStructureError extends FeeStructureState {
  const FeeStructureError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
