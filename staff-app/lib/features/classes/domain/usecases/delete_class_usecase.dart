import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/classes/domain/repositories/class_repository.dart';

class DeleteClassUseCase {
  const DeleteClassUseCase(this.repository);

  final ClassRepository repository;

  Future<Either<Failure, void>> call({
    required String id,
    required String pin,
  }) {
    return repository.deleteClass(id: id, pin: pin);
  }
}
