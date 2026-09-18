import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:staff_app/core/di/injection_container.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/router/route_names.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/core/widgets/executive_top_header.dart';
import 'package:staff_app/features/staff/data/datasources/staff_sub_account_remote_datasource.dart';
import 'package:staff_app/features/staff/data/models/staff_sub_account_model.dart';
import 'package:staff_app/features/staff/presentation/widgets/sub_accounts/staff_sub_account_card.dart';

/// Master Executive Screen for Staff Sub-Accounts & Operator Delegation Hub.
/// Liquid Crystal Glassmorphism, Rule 12 Zero-Overflow Armor, full credentials & permissions control.
class StaffSubAccountsPage extends StatefulWidget {
  const StaffSubAccountsPage({super.key});

  @override
  State<StaffSubAccountsPage> createState() => _StaffSubAccountsPageState();
}

class _StaffSubAccountsPageState extends State<StaffSubAccountsPage> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'ALL';
  bool _isLoading = true;

  List<StaffSubAccountModel> _accounts = [];

  @override
  void initState() {
    super.initState();
    _loadSubAccounts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSubAccounts() async {
    setState(() => _isLoading = true);
    try {
      final items = await sl<StaffSubAccountRemoteDataSource>().getSubAccounts();
      if (mounted) {
        setState(() {
          _accounts = items;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _accounts = StaffSubAccountModel.mockAccounts;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openCreateAccountPage() async {
    final newAccount = await context.push<StaffSubAccountModel>(RouteNames.createSubAccount);
    if (newAccount != null && mounted) {
      setState(() {
        _accounts.insert(0, newAccount);
      });
    }
  }

  Future<void> _openEditAccountPage(StaffSubAccountModel account) async {
    final updatedAccount = await context.push<StaffSubAccountModel>(
      RouteNames.createSubAccount,
      extra: account,
    );
    if (updatedAccount != null && mounted) {
      _handleAccountUpdated(updatedAccount);
    }
  }

  Future<void> _handleToggleStatus(StaffSubAccountModel account, bool newStatus) async {
    final oldStatus = account.isActive;
    setState(() {
      final idx = _accounts.indexWhere((a) => a.id == account.id);
      if (idx != -1) {
        _accounts[idx] = account.copyWith(isActive: newStatus);
      }
    });

    try {
      await sl<StaffSubAccountRemoteDataSource>().toggleAccountStatus(id: account.id, isActive: newStatus);
    } catch (_) {
      // Revert on failure
      if (mounted) {
        setState(() {
          final idx = _accounts.indexWhere((a) => a.id == account.id);
          if (idx != -1) {
            _accounts[idx] = account.copyWith(isActive: oldStatus);
          }
        });
      }
    }
  }

  void _handleAccountUpdated(StaffSubAccountModel updatedAccount) {
    setState(() {
      final idx = _accounts.indexWhere((a) => a.id == updatedAccount.id);
      if (idx != -1) {
        _accounts[idx] = updatedAccount;
      }
    });
  }

  List<StaffSubAccountModel> get _filteredAccounts {
    final query = _searchController.text.trim().toLowerCase();
    return _accounts.where((acc) {
      // 1. Search Query
      if (query.isNotEmpty) {
        final matchesQuery = acc.name.toLowerCase().contains(query) ||
            acc.username.toLowerCase().contains(query) ||
            acc.email.toLowerCase().contains(query);
        if (!matchesQuery) return false;
      }

      // 2. Filter Chip
      switch (_selectedFilter) {
        case 'ACTIVE':
          return acc.isActive;
        case 'BLOCKED':
          return !acc.isActive;
        case 'ADMIN':
          return acc.isAdmin;
        case 'STAFF':
          return !acc.isAdmin;
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalAccounts = _accounts.length;
    final activeCount = _accounts.where((a) => a.isActive).length;
    final blockedCount = _accounts.where((a) => !a.isActive).length;
    final filtered = _filteredAccounts;

    return Scaffold(
      body: AppBackground(
        child: Column(
          children: [
            ExecutiveTopHeader(
              icon: Icons.manage_accounts_rounded,
              title: context.tr('menu_sub_delegated_accounts_title'),
              subtitle: 'Institutional credentials & granular access control',
              onIconTap: () => context.pop(),
              trailing: InkWell(
                onTap: _openCreateAccountPage,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.goldPrimary, AppColors.goldDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.goldPrimary.withValues(alpha: 0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Generate',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 2. Scrollable Body
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.goldPrimary),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadSubAccounts,
                      color: AppColors.goldPrimary,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
                        children: [
                          // A. KPI Medallion (Total, Active, Blocked)
                          _buildKpiMedallion(
                            isDark: isDark,
                            total: totalAccounts,
                            active: activeCount,
                            blocked: blockedCount,
                          ),
                          const SizedBox(height: 14),

                          // B. Search Bar
                          _buildSearchBar(isDark),
                          const SizedBox(height: 10),

                          // C. Filter Chips Row
                          _buildFilterChips(isDark),
                          const SizedBox(height: 14),

                          // D. Section Header with count
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'STAFF OPERATORS DIRECTORY',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                      color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${filtered.length} Accounts',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // E. Accounts List or Empty State
                          if (filtered.isEmpty)
                            _buildEmptyState(isDark)
                          else
                            ...filtered.map(
                              (acc) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: StaffSubAccountCard(
                                  account: acc,
                                  onTap: () => _openEditAccountPage(acc),
                                  onToggleStatus: (val) => _handleToggleStatus(acc, val),
                                  onAccountUpdated: _handleAccountUpdated,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Frosted KPI Medallion displaying high-level security stats
  Widget _buildKpiMedallion({
    required bool isDark,
    required int total,
    required int active,
    required int blocked,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08),
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              _buildKpiPod(
                title: 'Total Operators',
                value: '$total',
                icon: Icons.groups_rounded,
                color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                isDark: isDark,
              ),
              Container(height: 28, width: 0.8, color: isDark ? Colors.white12 : Colors.black12),
              _buildKpiPod(
                title: 'Active Access',
                value: '$active',
                icon: Icons.check_circle_rounded,
                color: const Color(0xFF059669),
                isDark: isDark,
              ),
              Container(height: 28, width: 0.8, color: isDark ? Colors.white12 : Colors.black12),
              _buildKpiPod(
                title: 'Suspended',
                value: '$blocked',
                icon: Icons.block_rounded,
                color: const Color(0xFFE11D48),
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiPod({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 12.5, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.black12,
              width: 0.8,
            ),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Search by name, username or email',
              hintStyle: TextStyle(fontSize: 11.5, color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
              prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.goldPrimary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 16),
                      onPressed: () => setState(() => _searchController.clear()),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    final filters = ['ALL', 'ACTIVE', 'BLOCKED', 'STAFF', 'ADMIN'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              onTap: () => setState(() => _selectedFilter = f),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? AppColors.goldDark : AppColors.goldPrimary)
                      : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04)),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.goldPrimary : Colors.transparent,
                    width: 0.8,
                  ),
                ),
                child: Text(
                  f,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.01),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12, width: 0.8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_search_rounded, size: 36, color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
          const SizedBox(height: 10),
          Text(
            'No Sub-Accounts Found',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'No staff members match the current search or filter criteria.',
            style: TextStyle(fontSize: 11, color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
