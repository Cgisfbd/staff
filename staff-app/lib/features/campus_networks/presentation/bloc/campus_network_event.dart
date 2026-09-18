import 'package:equatable/equatable.dart';

abstract class CampusNetworkEvent extends Equatable {
  const CampusNetworkEvent();

  @override
  List<Object?> get props => [];
}

class LoadCampusNetworksEvent extends CampusNetworkEvent {
  const LoadCampusNetworksEvent({this.refresh = false});

  final bool refresh;

  @override
  List<Object?> get props => [refresh];
}

class DetectCurrentNetworkEvent extends CampusNetworkEvent {
  const DetectCurrentNetworkEvent();
}

class FilterCampusNetworksEvent extends CampusNetworkEvent {
  const FilterCampusNetworksEvent({
    this.searchQuery,
    this.statusFilter,
  });

  final String? searchQuery;
  final String? statusFilter; // 'ALL', 'ACTIVE', 'INACTIVE'

  @override
  List<Object?> get props => [searchQuery, statusFilter];
}

class ToggleCampusNetworkStatusEvent extends CampusNetworkEvent {
  const ToggleCampusNetworkStatusEvent({
    required this.id,
    required this.isActive,
  });

  final String id;
  final bool isActive;

  @override
  List<Object?> get props => [id, isActive];
}

class CreateCampusNetworkEvent extends CampusNetworkEvent {
  const CreateCampusNetworkEvent({
    required this.label,
    required this.publicIp,
    this.ipSubnet,
    this.location,
    this.isActive = true,
  });

  final String label;
  final String publicIp;
  final String? ipSubnet;
  final String? location;
  final bool isActive;

  @override
  List<Object?> get props => [label, publicIp, ipSubnet, location, isActive];
}

class UpdateCampusNetworkEvent extends CampusNetworkEvent {
  const UpdateCampusNetworkEvent({
    required this.id,
    this.label,
    this.publicIp,
    this.ipSubnet,
    this.location,
    this.isActive,
  });

  final String id;
  final String? label;
  final String? publicIp;
  final String? ipSubnet;
  final String? location;
  final bool? isActive;

  @override
  List<Object?> get props => [id, label, publicIp, ipSubnet, location, isActive];
}

class DeleteCampusNetworkEvent extends CampusNetworkEvent {
  const DeleteCampusNetworkEvent(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
