import 'package:equatable/equatable.dart';
import 'package:staff_app/features/campus_networks/domain/entities/campus_network_entity.dart';

abstract class CampusNetworkState extends Equatable {
  const CampusNetworkState();

  @override
  List<Object?> get props => [];
}

class CampusNetworkInitial extends CampusNetworkState {
  const CampusNetworkInitial();
}

class CampusNetworkLoading extends CampusNetworkState {
  const CampusNetworkLoading();
}

class CampusNetworkLoaded extends CampusNetworkState {
  const CampusNetworkLoaded({
    required this.networks,
    this.currentNetwork,
    this.isDetectingCurrentNetwork = false,
    this.searchQuery = '',
    this.statusFilter = 'ALL',
    this.actionMessage,
  });

  final List<CampusNetworkEntity> networks;
  final CurrentNetworkInfoEntity? currentNetwork;
  final bool isDetectingCurrentNetwork;
  final String searchQuery;
  final String statusFilter;
  final String? actionMessage;

  int get totalCount => networks.length;
  int get activeCount => networks.where((n) => n.isActive).length;
  bool get isArmorActive => activeCount > 0;

  List<CampusNetworkEntity> get filteredNetworks {
    return networks.where((net) {
      final q = searchQuery.toLowerCase().trim();
      final matchesSearch = q.isEmpty ||
          net.label.toLowerCase().contains(q) ||
          net.publicIp.toLowerCase().contains(q) ||
          (net.location != null && net.location!.toLowerCase().contains(q)) ||
          (net.ipSubnet != null && net.ipSubnet!.toLowerCase().contains(q));

      final matchesStatus = statusFilter == 'ALL' ||
          (statusFilter == 'ACTIVE' && net.isActive) ||
          (statusFilter == 'INACTIVE' && !net.isActive);

      return matchesSearch && matchesStatus;
    }).toList();
  }

  CampusNetworkLoaded copyWith({
    List<CampusNetworkEntity>? networks,
    CurrentNetworkInfoEntity? currentNetwork,
    bool? isDetectingCurrentNetwork,
    String? searchQuery,
    String? statusFilter,
    String? actionMessage,
  }) {
    return CampusNetworkLoaded(
      networks: networks ?? this.networks,
      currentNetwork: currentNetwork ?? this.currentNetwork,
      isDetectingCurrentNetwork: isDetectingCurrentNetwork ?? this.isDetectingCurrentNetwork,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      actionMessage: actionMessage,
    );
  }

  @override
  List<Object?> get props => [
        networks,
        currentNetwork,
        isDetectingCurrentNetwork,
        searchQuery,
        statusFilter,
        actionMessage,
      ];
}

class CampusNetworkError extends CampusNetworkState {
  const CampusNetworkError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
