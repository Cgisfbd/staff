import 'package:staff_app/features/fee_structure/domain/entities/fee_structure_entity.dart';

abstract class FeeStructureRepository {
  Future<List<FeeStructureEntity>> getFees({String? courseId});
  Future<FeeStructureEntity?> getFeeByClass(String classId);
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
  });
  Future<void> deleteFeeStructure(String id);
}
