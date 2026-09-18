import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/features/campus_networks/domain/repositories/campus_network_repository.dart';
import 'package:staff_app/features/campus_networks/presentation/bloc/campus_network_event.dart';
import 'package:staff_app/features/campus_networks/presentation/bloc/campus_network_state.dart';

class CampusNetworkBloc extends Bloc<CampusNetworkEvent, CampusNetworkState> {
  CampusNetworkBloc({required this.repository}) : super(const CampusNetworkInitial()) {
    on<LoadCampusNetworksEvent>(_onLoadCampusNetworks);
    on<DetectCurrentNetworkEvent>(_onDetectCurrentNetwork);
    on<FilterCampusNetworksEvent>(_onFilterCampusNetworks);
    on<ToggleCampusNetworkStatusEvent>(_onToggleCampusNetworkStatus);
    on<CreateCampusNetworkEvent>(_onCreateCampusNetwork);
    on<UpdateCampusNetworkEvent>(_onUpdateCampusNetwork);
    on<DeleteCampusNetworkEvent>(_onDeleteCampusNetwork);
  }

  final CampusNetworkRepository repository;

  Future<void> _onLoadCampusNetworks(
    LoadCampusNetworksEvent event,
    Emitter<CampusNetworkState> emit,
  ) async {
    if (!event.refresh && state is! CampusNetworkLoaded) {
      emit(const CampusNetworkLoading());
    }

    final result = await repository.getCampusNetworks();
    await result.fold(
      (failure) async {
        emit(CampusNetworkError(failure.message));
      },
      (networks) async {
        final curState = state;
        final query = curState is CampusNetworkLoaded ? curState.searchQuery : '';
        final filter = curState is CampusNetworkLoaded ? curState.statusFilter : 'ALL';

        emit(CampusNetworkLoaded(
          networks: networks,
          searchQuery: query,
          statusFilter: filter,
          isDetectingCurrentNetwork: true,
        ));

        // Auto-detect current network
        add(const DetectCurrentNetworkEvent());
      },
    );
  }

  Future<void> _onDetectCurrentNetwork(
    DetectCurrentNetworkEvent event,
    Emitter<CampusNetworkState> emit,
  ) async {
    final curState = state;
    if (curState is! CampusNetworkLoaded) return;

    emit(curState.copyWith(isDetectingCurrentNetwork: true));

    final result = await repository.detectCurrentNetwork();
    result.fold(
      (failure) {
        emit(curState.copyWith(isDetectingCurrentNetwork: false));
      },
      (currentNetwork) {
        emit(curState.copyWith(
          currentNetwork: currentNetwork,
          isDetectingCurrentNetwork: false,
        ));
      },
    );
  }

  void _onFilterCampusNetworks(
    FilterCampusNetworksEvent event,
    Emitter<CampusNetworkState> emit,
  ) {
    final curState = state;
    if (curState is! CampusNetworkLoaded) return;

    emit(curState.copyWith(
      searchQuery: event.searchQuery ?? curState.searchQuery,
      statusFilter: event.statusFilter ?? curState.statusFilter,
    ));
  }

  Future<void> _onToggleCampusNetworkStatus(
    ToggleCampusNetworkStatusEvent event,
    Emitter<CampusNetworkState> emit,
  ) async {
    final curState = state;
    if (curState is! CampusNetworkLoaded) return;

    // Optimistic toggle
    final updatedList = curState.networks.map((n) {
      if (n.id == event.id) {
        return n.copyWith(isActive: event.isActive);
      }
      return n;
    }).toList();

    emit(curState.copyWith(networks: updatedList));

    final result = await repository.toggleNetworkStatus(
      id: event.id,
      isActive: event.isActive,
    );

    result.fold(
      (failure) {
        // Revert on failure
        emit(curState);
      },
      (updated) {
        final confirmedList = curState.networks.map((n) {
          if (n.id == updated.id) {
            return updated;
          }
          return n;
        }).toList();

        emit(curState.copyWith(
          networks: confirmedList,
          actionMessage: '"${updated.label}" is now ${updated.isActive ? 'ACTIVE' : 'DISABLED'}',
        ));
        add(const DetectCurrentNetworkEvent());
      },
    );
  }

  Future<void> _onCreateCampusNetwork(
    CreateCampusNetworkEvent event,
    Emitter<CampusNetworkState> emit,
  ) async {
    final curState = state;
    if (curState is! CampusNetworkLoaded) return;

    final result = await repository.createCampusNetwork(
      label: event.label,
      publicIp: event.publicIp,
      ipSubnet: event.ipSubnet,
      location: event.location,
      isActive: event.isActive,
    );

    result.fold(
      (failure) {
        emit(CampusNetworkError(failure.message));
      },
      (created) {
        final updatedList = [created, ...curState.networks];
        emit(curState.copyWith(
          networks: updatedList,
          actionMessage: 'Router "${created.label}" registered successfully',
        ));
        add(const DetectCurrentNetworkEvent());
      },
    );
  }

  Future<void> _onUpdateCampusNetwork(
    UpdateCampusNetworkEvent event,
    Emitter<CampusNetworkState> emit,
  ) async {
    final curState = state;
    if (curState is! CampusNetworkLoaded) return;

    final result = await repository.updateCampusNetwork(
      id: event.id,
      label: event.label,
      publicIp: event.publicIp,
      ipSubnet: event.ipSubnet,
      location: event.location,
      isActive: event.isActive,
    );

    result.fold(
      (failure) {
        emit(CampusNetworkError(failure.message));
      },
      (updated) {
        final updatedList = curState.networks.map((n) {
          if (n.id == updated.id) return updated;
          return n;
        }).toList();

        emit(curState.copyWith(
          networks: updatedList,
          actionMessage: 'Router "${updated.label}" updated successfully',
        ));
        add(const DetectCurrentNetworkEvent());
      },
    );
  }

  Future<void> _onDeleteCampusNetwork(
    DeleteCampusNetworkEvent event,
    Emitter<CampusNetworkState> emit,
  ) async {
    final curState = state;
    if (curState is! CampusNetworkLoaded) return;

    final target = curState.networks.firstWhere(
      (n) => n.id == event.id,
      orElse: () => curState.networks.first,
    );

    final updatedList = curState.networks.where((n) => n.id != event.id).toList();
    emit(curState.copyWith(networks: updatedList));

    final result = await repository.deleteCampusNetwork(event.id);
    result.fold(
      (failure) {
        // Revert on error
        emit(curState);
      },
      (_) {
        emit(curState.copyWith(
          networks: updatedList,
          actionMessage: 'Router "${target.label}" removed',
        ));
        add(const DetectCurrentNetworkEvent());
      },
    );
  }
}
