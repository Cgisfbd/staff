import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/campus_networks/domain/entities/campus_network_entity.dart';

abstract class CampusNetworkRepository {
  Future<Either<Failure, List<CampusNetworkEntity>>> getCampusNetworks();

  Future<Either<Failure, CurrentNetworkInfoEntity>> detectCurrentNetwork();

  Future<Either<Failure, CampusNetworkEntity>> createCampusNetwork({
    required String label,
    required String publicIp,
    String? ipSubnet,
    String? location,
    bool isActive = true,
  });

  Future<Either<Failure, CampusNetworkEntity>> updateCampusNetwork({
    required String id,
    String? label,
    String? publicIp,
    String? ipSubnet,
    String? location,
    bool? isActive,
  });

  Future<Either<Failure, bool>> deleteCampusNetwork(String id);

  Future<Either<Failure, CampusNetworkEntity>> toggleNetworkStatus({
    required String id,
    required bool isActive,
  });
}
