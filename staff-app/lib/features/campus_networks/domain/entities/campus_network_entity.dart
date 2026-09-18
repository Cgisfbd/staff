import 'package:equatable/equatable.dart';

/// Domain entity representing an authorized campus Wi-Fi network / router.
class CampusNetworkEntity extends Equatable {
  const CampusNetworkEntity({
    required this.id,
    required this.label,
    required this.publicIp,
    this.ipSubnet,
    this.location,
    required this.isActive,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String label;
  final String publicIp;
  final String? ipSubnet;
  final String? location;
  final bool isActive;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CampusNetworkEntity copyWith({
    String? id,
    String? label,
    String? publicIp,
    String? ipSubnet,
    String? location,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CampusNetworkEntity(
      id: id ?? this.id,
      label: label ?? this.label,
      publicIp: publicIp ?? this.publicIp,
      ipSubnet: ipSubnet ?? this.ipSubnet,
      location: location ?? this.location,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        label,
        publicIp,
        ipSubnet,
        location,
        isActive,
        createdBy,
        createdAt,
        updatedAt,
      ];
}

/// Domain entity representing real-time detection of client's connected network.
class CurrentNetworkInfoEntity extends Equatable {
  const CurrentNetworkInfoEntity({
    required this.clientIp,
    required this.isAuthorized,
    this.matchedNetwork,
    this.connectionType = 'WIFI',
  });

  final String clientIp;
  final bool isAuthorized;
  final CampusNetworkEntity? matchedNetwork;
  final String connectionType;

  @override
  List<Object?> get props => [
        clientIp,
        isAuthorized,
        matchedNetwork,
        connectionType,
      ];
}
