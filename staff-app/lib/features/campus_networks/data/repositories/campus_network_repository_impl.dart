import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/campus_networks/data/datasources/campus_network_remote_datasource.dart';
import 'package:staff_app/features/campus_networks/domain/entities/campus_network_entity.dart';
import 'package:staff_app/features/campus_networks/domain/repositories/campus_network_repository.dart';

class CampusNetworkRepositoryImpl implements CampusNetworkRepository {
  CampusNetworkRepositoryImpl({required this.remoteDataSource});

  final CampusNetworkRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<CampusNetworkEntity>>> getCampusNetworks() async {
    try {
      final list = await remoteDataSource.getCampusNetworks();
      return Right(list);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CurrentNetworkInfoEntity>> detectCurrentNetwork() async {
    try {
      final info = await remoteDataSource.detectCurrentNetwork();
      return Right(info);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CampusNetworkEntity>> createCampusNetwork({
    required String label,
    required String publicIp,
    String? ipSubnet,
    String? location,
    bool isActive = true,
  }) async {
    try {
      final created = await remoteDataSource.createCampusNetwork(
        label: label,
        publicIp: publicIp,
        ipSubnet: ipSubnet,
        location: location,
        isActive: isActive,
      );
      return Right(created);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CampusNetworkEntity>> updateCampusNetwork({
    required String id,
    String? label,
    String? publicIp,
    String? ipSubnet,
    String? location,
    bool? isActive,
  }) async {
    try {
      final updated = await remoteDataSource.updateCampusNetwork(
        id: id,
        label: label,
        publicIp: publicIp,
        ipSubnet: ipSubnet,
        location: location,
        isActive: isActive,
      );
      return Right(updated);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteCampusNetwork(String id) async {
    try {
      await remoteDataSource.deleteCampusNetwork(id);
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CampusNetworkEntity>> toggleNetworkStatus({
    required String id,
    required bool isActive,
  }) async {
    try {
      final toggled = await remoteDataSource.toggleNetworkStatus(
        id: id,
        isActive: isActive,
      );
      return Right(toggled);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
