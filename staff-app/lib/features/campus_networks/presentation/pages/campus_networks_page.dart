import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/core/di/injection_container.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/core/widgets/app_snack_bar.dart';
import 'package:staff_app/core/widgets/executive_top_header.dart';
import 'package:staff_app/features/campus_networks/domain/entities/campus_network_entity.dart';
import 'package:staff_app/features/campus_networks/presentation/bloc/campus_network_bloc.dart';
import 'package:staff_app/features/campus_networks/presentation/bloc/campus_network_event.dart';
import 'package:staff_app/features/campus_networks/presentation/bloc/campus_network_state.dart';
import 'package:staff_app/features/campus_networks/presentation/widgets/add_edit_campus_network_sheet.dart';
import 'package:staff_app/features/campus_networks/presentation/widgets/campus_network_card.dart';
import 'package:staff_app/features/campus_networks/presentation/widgets/campus_network_stat_cards.dart';
import 'package:staff_app/features/campus_networks/presentation/widgets/current_network_banner.dart';
import 'package:staff_app/features/campus_networks/presentation/widgets/delete_network_dialog.dart';

class CampusNetworksPage extends StatefulWidget {
  const CampusNetworksPage({super.key});

  @override
  State<CampusNetworksPage> createState() => _CampusNetworksPageState();
}

class _CampusNetworksPageState extends State<CampusNetworksPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddEditSheet(
    BuildContext context, {
    CampusNetworkEntity? networkToEdit,
    String? initialIp,
  }) {
    final bloc = context.read<CampusNetworkBloc>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    AddEditCampusNetworkSheet.show(
      context,
      networkToEdit: networkToEdit,
      initialIp: initialIp,
      isDark: isDark,
      onAutoDetectIp: () async {
        final state = bloc.state;
        if (state is CampusNetworkLoaded && state.currentNetwork != null) {
          return state.currentNetwork!.clientIp;
        }
        final info = await bloc.repository.detectCurrentNetwork();
        return info.fold((_) => '127.0.0.1', (c) => c.clientIp);
      },
      onSave: ({
        required String label,
        required String publicIp,
        String? ipSubnet,
        String? location,
        required bool isActive,
      }) async {
        if (networkToEdit != null) {
          bloc.add(UpdateCampusNetworkEvent(
            id: networkToEdit.id,
            label: label,
            publicIp: publicIp,
            ipSubnet: ipSubnet,
            location: location,
            isActive: isActive,
          ));
        } else {
          bloc.add(CreateCampusNetworkEvent(
            label: label,
            publicIp: publicIp,
            ipSubnet: ipSubnet,
            location: location,
            isActive: isActive,
          ));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider<CampusNetworkBloc>(
      create: (_) => sl<CampusNetworkBloc>()..add(const LoadCampusNetworksEvent()),
      child: Scaffold(
        body: AppBackground(
          useSafeArea: false,
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Executive Top Header matching Mega Menu
                Builder(
                  builder: (ctx) {
                    return ExecutiveTopHeader(
                      icon: Icons.wifi_tethering_rounded,
                      title: 'Campus Wi-Fi Networks',
                      subtitle: 'Authorized campus routers & geofence armor',
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              ctx.read<CampusNetworkBloc>().add(
                                    const LoadCampusNetworksEvent(refresh: true),
                                  );
                              AppSnackBar.showSuccess(
                                  ctx, 'Refreshing network status...');
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 20),
                            tooltip: 'Refresh Status',
                            color: isDark ? Colors.white70 : AppColors.charcoalDark,
                          ),
                          IconButton(
                            onPressed: () => _openAddEditSheet(ctx),
                            icon: const Icon(Icons.add_circle_outline_rounded,
                                size: 22),
                            tooltip: 'Add Router',
                            color: const Color(0xFF0284C7),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // 2. Main Content Body
                Expanded(
                  child: BlocConsumer<CampusNetworkBloc, CampusNetworkState>(
                    listener: (context, state) {
                      if (state is CampusNetworkLoaded &&
                          state.actionMessage != null) {
                        AppSnackBar.showSuccess(context, state.actionMessage!);
                      }
                      if (state is CampusNetworkError) {
                        AppSnackBar.showError(context, state.message);
                      }
                    },
                    builder: (context, state) {
                      if (state is CampusNetworkLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF0284C7),
                            strokeWidth: 2,
                          ),
                        );
                      }

                      if (state is CampusNetworkError &&
                          state.message.isNotEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.wifi_off_rounded,
                                  size: 44,
                                  color: AppColors.rosePrimary,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  state.message,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () => context
                                      .read<CampusNetworkBloc>()
                                      .add(const LoadCampusNetworksEvent(
                                          refresh: true)),
                                  icon: const Icon(Icons.refresh_rounded,
                                      size: 16),
                                  label: const Text('Retry'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0284C7),
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (state is CampusNetworkLoaded) {
                        final filtered = state.filteredNetworks;
                        final activeCount = state.activeCount;
                        final inactiveCount =
                            state.totalCount - state.activeCount;

                        return RefreshIndicator(
                          color: const Color(0xFF0284C7),
                          onRefresh: () async {
                            context.read<CampusNetworkBloc>().add(
                                  const LoadCampusNetworksEvent(refresh: true),
                                );
                          },
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: ClampingScrollPhysics(),
                            ),
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
                            children: [
                              // Top 3 Stat Cards
                              CampusNetworkStatCards(
                                isDark: isDark,
                                totalCount: state.totalCount,
                                activeCount: state.activeCount,
                                isArmorActive: state.isArmorActive,
                              ),

                              const SizedBox(height: 14),

                              // Live Current Network Banner
                              CurrentNetworkBanner(
                                isDark: isDark,
                                currentNetwork: state.currentNetwork,
                                isDetecting: state.isDetectingCurrentNetwork,
                                onAutoCaptureRegister: () {
                                  _openAddEditSheet(
                                    context,
                                    initialIp: state.currentNetwork?.clientIp,
                                  );
                                },
                                onAddManual: () => _openAddEditSheet(context),
                              ),

                              const SizedBox(height: 14),

                              // Search & Status Filter Bar
                              _buildSearchAndFilterBar(
                                context: context,
                                isDark: isDark,
                                currentFilter: state.statusFilter,
                                totalCount: state.totalCount,
                                activeCount: activeCount,
                                inactiveCount: inactiveCount,
                              ),

                              const SizedBox(height: 14),

                              // Section Header
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'REGISTERED CAMPUS ROUTERS',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.8,
                                          color: isDark
                                              ? AppColors.goldChampagne
                                              : AppColors.goldDark,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2.5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0284C7)
                                          .withValues(alpha: isDark ? 0.2 : 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: const Color(0xFF0284C7)
                                            .withValues(alpha: 0.35),
                                        width: 0.6,
                                      ),
                                    ),
                                    child: Text(
                                      '${filtered.length} Routers',
                                      style: const TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF0284C7),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // Routers List
                              if (filtered.isEmpty)
                                _buildEmptyState(
                                  isDark: isDark,
                                  onAddTap: () => _openAddEditSheet(context),
                                )
                              else
                                ...filtered.map((network) {
                                  return CampusNetworkCard(
                                    network: network,
                                    isDark: isDark,
                                    onToggleStatus: (val) {
                                      context.read<CampusNetworkBloc>().add(
                                            ToggleCampusNetworkStatusEvent(
                                              id: network.id,
                                              isActive: val,
                                            ),
                                          );
                                    },
                                    onEdit: () => _openAddEditSheet(
                                      context,
                                      networkToEdit: network,
                                    ),
                                    onDelete: () {
                                      DeleteNetworkDialog.show(
                                        context,
                                        routerLabel: network.label,
                                        onConfirm: () {
                                          context.read<CampusNetworkBloc>().add(
                                                DeleteCampusNetworkEvent(
                                                    network.id),
                                              );
                                        },
                                      );
                                    },
                                  );
                                }),
                            ],
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterBar({
    required BuildContext context,
    required bool isDark,
    required String currentFilter,
    required int totalCount,
    required int activeCount,
    required int inactiveCount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Input
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: (isDark ? const Color(0x331E293B) : Colors.white).withValues(
              alpha: isDark ? 0.45 : 0.94,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
              width: 0.8,
            ),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (query) {
              context.read<CampusNetworkBloc>().add(
                    FilterCampusNetworksEvent(searchQuery: query),
                  );
            },
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.charcoalDark,
            ),
            decoration: InputDecoration(
              hintText: 'Search router, IP, location or subnet...',
              hintStyle: TextStyle(
                fontSize: 11.5,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
              prefixIcon: const Icon(Icons.search_rounded, size: 18),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 16),
                      onPressed: () {
                        _searchController.clear();
                        context.read<CampusNetworkBloc>().add(
                              const FilterCampusNetworksEvent(searchQuery: ''),
                            );
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Status Filter Buttons
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildFilterPill(
                context: context,
                label: 'All ($totalCount)',
                value: 'ALL',
                selectedValue: currentFilter,
                isDark: isDark,
              ),
              const SizedBox(width: 6),
              _buildFilterPill(
                context: context,
                label: 'Active ($activeCount)',
                value: 'ACTIVE',
                selectedValue: currentFilter,
                isDark: isDark,
                accentColor: AppColors.emeraldPrimary,
              ),
              const SizedBox(width: 6),
              _buildFilterPill(
                context: context,
                label: 'Standby ($inactiveCount)',
                value: 'INACTIVE',
                selectedValue: currentFilter,
                isDark: isDark,
                accentColor: const Color(0xFF64748B),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterPill({
    required BuildContext context,
    required String label,
    required String value,
    required String selectedValue,
    required bool isDark,
    Color? accentColor,
  }) {
    final isSelected = value == selectedValue;
    final color = accentColor ?? const Color(0xFF0284C7);

    return InkWell(
      onTap: () {
        context.read<CampusNetworkBloc>().add(
              FilterCampusNetworksEvent(statusFilter: value),
            );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? color
              : (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : AppColors.charcoalDark),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required bool isDark,
    required VoidCallback onAddTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(28),
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0x331E293B) : Colors.white).withValues(
          alpha: isDark ? 0.35 : 0.9,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
          width: 0.8,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0284C7).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wifi_find_rounded,
              size: 32,
              color: Color(0xFF0284C7),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No Routers Found',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.charcoalDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Register campus Wi-Fi access points to enforce physical attendance geofencing.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: onAddTap,
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text(
              'Add Campus Router',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
