import 'package:staff_app/features/fee_structure/data/datasources/fee_structure_remote_datasource.dart';
import 'package:staff_app/features/fee_structure/domain/entities/fee_structure_entity.dart';
import 'package:staff_app/features/fee_structure/domain/repositories/fee_structure_repository.dart';

class FeeStructureRepositoryImpl implements FeeStructureRepository {
  FeeStructureRepositoryImpl({required this.remoteDataSource});

  final FeeStructureRemoteDataSource remoteDataSource;

  @override
  Future<List<FeeStructureEntity>> getFees({String? courseId}) async {
    return remoteDataSource.getFees(courseId: courseId);
  }

  @override
  Future<FeeStructureEntity?> getFeeByClass(String classId) async {
    return remoteDataSource.getFeeByClass(classId);
  }

  @override
  Future<FeeStructureEntity> saveFeeStructure({
    required String classId,
    required String className,
    String? id,
    int? tuitionFee,
    int? hostelFee,
    int? admissionFeeHostel,
    int? admissionFeeNonHostel,
    int? admissionRenewalFee,
    int? examFee,
    int? onlineFee,
    int? onlineAdmissionFee,
  }) async {
    if (id != null && id.isNotEmpty && !id.startsWith('local-')) {
      return remoteDataSource.updateFee(
        id: id,
        tuitionFee: tuitionFee,
        hostelFee: hostelFee,
        admissionFeeHostel: admissionFeeHostel,
        admissionFeeNonHostel: admissionFeeNonHostel,
        admissionRenewalFee: admissionRenewalFee,
        examFee: examFee,
        onlineFee: onlineFee,
        onlineAdmissionFee: onlineAdmissionFee,
      );
    } else {
      return remoteDataSource.createFee(
        classId: classId,
        className: className,
        tuitionFee: tuitionFee,
        hostelFee: hostelFee,
        admissionFeeHostel: admissionFeeHostel,
        admissionFeeNonHostel: admissionFeeNonHostel,
        admissionRenewalFee: admissionRenewalFee,
        examFee: examFee,
        onlineFee: onlineFee,
        onlineAdmissionFee: onlineAdmissionFee,
      );
    }
  }

  @override
  Future<void> deleteFeeStructure(String id) async {
    return remoteDataSource.deleteFee(id);
  }
}
