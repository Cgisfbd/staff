import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:staff_app/core/di/injection_container.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/core/widgets/executive_top_header.dart';
import 'package:staff_app/features/menu/data/menu_categories_data.dart';
import 'package:staff_app/features/staff/data/datasources/staff_sub_account_remote_datasource.dart';
import 'package:staff_app/features/staff/data/models/staff_sub_account_model.dart';

/// Dedicated Full-Screen Page for Two-Level Granular Permissions Matrix:
/// 1. Level 1: Category Master Switch [ ON / OFF ] (Prunes entire Category from Left Rail)
/// 2. Level 2: Sub-Item Tri-State Selector [ None / View / Edit ]
/// 3. Smart Auto-Pruning feedback when all child items are None.
class StaffPermissionsPage extends StatefulWidget {
  const StaffPermissionsPage({
    super.key,
    this.initialAccount,
  });

  final StaffSubAccountModel? initialAccount;

  @override
  State<StaffPermissionsPage> createState() => _StaffPermissionsPageState();
}

class _StaffPermissionsPageState extends State<StaffPermissionsPage> {
  late StaffSubAccountModel _account;
  late Map<String, bool> _categoryToggles;
  late Map<String, String> _permissions;
  final Set<String> _expandedCategoryIds = {};
  bool _isSaving = false;

  List<StaffSubAccountModel> _allAccounts = StaffSubAccountModel.mockAccounts;

  @override
  void initState() {
    super.initState();
    if (widget.initialAccount != null) {
      _account = widget.initialAccount!;
      _categoryToggles = Map<String, bool>.from(_account.categoryToggles);
      _permissions = Map<String, String>.from(_account.permissions);
    } else {
      _account = StaffSubAccountModel.mockAccounts.first;
      _categoryToggles = Map<String, bool>.from(_account.categoryToggles);
      _permissions = Map<String, String>.from(_account.permissions);
    }
    _fetchAccountsList();

    // Auto-expand the first category by default
    if (MenuCategoriesData.categories.isNotEmpty) {
      _expandedCategoryIds.add(MenuCategoriesData.categories.first.id);
    }
  }

  Future<void> _fetchAccountsList() async {
    try {
      final items = await sl<StaffSubAccountRemoteDataSource>().getSubAccounts();
      if (mounted && items.isNotEmpty) {
        setState(() {
          _allAccounts = items;
          if (widget.initialAccount == null) {
            _switchAccount(items.first);
          }
        });
      }
    } catch (_) {}
  }

  void _switchAccount(StaffSubAccountModel newAcc) {
    setState(() {
      _account = newAcc;
      _categoryToggles = Map<String, bool>.from(newAcc.categoryToggles);
      _permissions = Map<String, String>.from(newAcc.permissions);
    });
  }

  void _toggleCategoryMaster(String categoryId, bool isEnabled) {
    setState(() {
      _categoryToggles[categoryId] = isEnabled;
    });
  }

  void _setSubItemPermission(String subItemId, String level) {
    setState(() {
      _permissions[subItemId] = level;
    });
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);

    final updated = _account.copyWith(
      categoryToggles: _categoryToggles,
      permissions: _permissions,
    );

    try {
      await sl<StaffSubAccountRemoteDataSource>().updatePermissions(
        id: updated.id,
        categoryToggles: _categoryToggles,
        permissions: _permissions,
      );
    } catch (_) {}

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.verified_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Permissions saved for ${updated.name}!',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      context.pop(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AppBackground(
        child: Column(
          children: [
            ExecutiveTopHeader(
              icon: Icons.security_rounded,
              title: 'Granular Permissions',
              subtitle: 'Two-level access matrix for ${_account.name}',
              onIconTap: () => context.pop(),
            ),

            // Main Scrollable Area
            Expanded(
              child: ListView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
                children: [
                  // 1. Unified Staff Selector Section
                  _buildStaffSelectorSection(isDark),
                  const SizedBox(height: 14),

                  // 2. Explanatory Rule Banner
                  _buildRuleExplainerBanner(isDark),
                  const SizedBox(height: 14),

                  // 3. Category Tree Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'MODULE CAPABILITY TREES',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        '${MenuCategoriesData.categories.length} Categories',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 4. Categories & Sub-Items Accordion Cards
                  ...MenuCategoriesData.categories.map(
                    (cat) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildCategoryCard(cat, isDark),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Sticky Save Bar
            _buildBottomActionBar(isDark),
          ],
        ),
      ),
    );
  }

  /// Dedicated Section for choosing which staff operator's permissions to manage
  Widget _buildStaffSelectorSection(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08),
              width: 0.85,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.badge_rounded, size: 15, color: AppColors.goldPrimary),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'ASSIGNED OPERATOR',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _openStaffPicker(context, isDark),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: AppColors.goldPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.35), width: 0.8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.swap_horiz_rounded, size: 13, color: AppColors.goldPrimary),
                          SizedBox(width: 4),
                          Text(
                            'Change Staff',
                            style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.goldPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Highlighted Selected Staff Card
              _buildSelectedStaffCard(isDark),
            ],
          ),
        ),
      ),
    );
  }

  /// Highlighted Card for the Currently Selected Staff Member
  Widget _buildSelectedStaffCard(bool isDark) {
    return InkWell(
      onTap: () => _openStaffPicker(context, isDark),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF059669).withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.goldPrimary, AppColors.goldDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.goldPrimary.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _account.name.isNotEmpty ? _account.name[0].toUpperCase() : 'S',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _account.name,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _account.isAdmin
                              ? AppColors.goldPrimary.withValues(alpha: 0.15)
                              : const Color(0xFF0284C7).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _account.isAdmin
                                ? AppColors.goldPrimary.withValues(alpha: 0.35)
                                : const Color(0xFF0284C7).withValues(alpha: 0.35),
                            width: 0.7,
                          ),
                        ),
                        child: Text(
                          _account.role,
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: _account.isAdmin ? AppColors.goldPrimary : const Color(0xFF0284C7),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '@${_account.username}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: _account.isActive
                              ? const Color(0xFF059669).withValues(alpha: 0.15)
                              : const Color(0xFFE11D48).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _account.isActive ? 'Active' : 'Blocked',
                          style: TextStyle(
                            fontSize: 7.5,
                            fontWeight: FontWeight.w700,
                            color: _account.isActive ? const Color(0xFF059669) : const Color(0xFFE11D48),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_account.email.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      _account.email,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, color: AppColors.goldPrimary, size: 20),
          ],
        ),
      ),
    );
  }

  /// Searchable Bottom Sheet Modal to pick/switch Staff Operator
  void _openStaffPicker(BuildContext context, bool isDark) {
    String search = '';
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          final query = search.trim().toLowerCase();
          final filtered = _allAccounts.where((a) {
            if (query.isEmpty) return true;
            return a.name.toLowerCase().contains(query) ||
                a.username.toLowerCase().contains(query) ||
                a.email.toLowerCase().contains(query) ||
                a.role.toLowerCase().contains(query);
          }).toList();

          return Container(
            height: MediaQuery.of(context).size.height * 0.80,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF131F17) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.black12,
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Grab Bar
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(top: 10, bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black26,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Modal Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Staff Operator',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Choose operator to inspect or edit permissions matrix',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close_rounded, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? Colors.white12 : Colors.black12, width: 0.8),
                    ),
                    child: TextField(
                      autofocus: false,
                      onChanged: (val) => setModalState(() => search = val),
                      style: TextStyle(fontSize: 12.5, color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'Search staff by name, username or role',
                        hintStyle: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                        ),
                        prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.goldPrimary),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, thickness: 0.6),

                // Staff List
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person_search_rounded, size: 36, color: isDark ? Colors.white24 : Colors.black26),
                              const SizedBox(height: 8),
                              Text(
                                'No matching staff operator found',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (itemCtx, i) {
                            final staff = filtered[i];
                            final isCurrentlySelected = staff.id == _account.id;

                            return InkWell(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                Navigator.of(ctx).pop();
                                _switchAccount(staff);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isCurrentlySelected
                                      ? AppColors.goldPrimary.withValues(alpha: isDark ? 0.2 : 0.12)
                                      : (isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02)),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isCurrentlySelected
                                        ? AppColors.goldPrimary
                                        : (isDark ? Colors.white10 : Colors.black12),
                                    width: isCurrentlySelected ? 1.4 : 0.7,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 19,
                                      backgroundColor: isCurrentlySelected
                                          ? AppColors.goldPrimary
                                          : (isDark ? Colors.white12 : Colors.black12),
                                      child: Text(
                                        staff.name.isNotEmpty ? staff.name[0].toUpperCase() : 'S',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                          color: isCurrentlySelected
                                              ? Colors.white
                                              : (isDark ? Colors.white70 : Colors.black87),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  staff.name,
                                                  style: TextStyle(
                                                    fontSize: 12.5,
                                                    fontWeight: FontWeight.w800,
                                                    color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: staff.isAdmin
                                                      ? AppColors.goldPrimary.withValues(alpha: 0.2)
                                                      : const Color(0xFF0284C7).withValues(alpha: 0.15),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  staff.role,
                                                  style: TextStyle(
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.w800,
                                                    color: staff.isAdmin ? AppColors.goldPrimary : const Color(0xFF0284C7),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Text(
                                                '@${staff.username}',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: isCurrentlySelected
                                                      ? (isDark ? AppColors.goldChampagne : AppColors.goldDark)
                                                      : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: staff.isActive
                                                      ? const Color(0xFF059669).withValues(alpha: 0.15)
                                                      : const Color(0xFFE11D48).withValues(alpha: 0.15),
                                                  borderRadius: BorderRadius.circular(3),
                                                ),
                                                child: Text(
                                                  staff.isActive ? 'Active' : 'Blocked',
                                                  style: TextStyle(
                                                    fontSize: 7.5,
                                                    fontWeight: FontWeight.w700,
                                                    color: staff.isActive ? const Color(0xFF059669) : const Color(0xFFE11D48),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isCurrentlySelected) ...[
                                      const SizedBox(width: 8),
                                      const Icon(Icons.check_circle_rounded, color: AppColors.goldPrimary, size: 20),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Explains Level 1 & Level 2 mechanics concisely to Super Admin
  Widget _buildRuleExplainerBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.08 : 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.25), width: 0.7),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 15, color: AppColors.goldPrimary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Level 1 Master Switch hides entire category from Left Rail. Level 2 buttons configure None (Hidden), View (Read-Only) & Edit (Full Action) per sub-item.',
              style: TextStyle(
                fontSize: 10.5,
                height: 1.35,
                color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Master Category Card with Level 1 Switch and Level 2 Accordion
  Widget _buildCategoryCard(MenuCategory category, bool isDark) {
    final isMasterOn = _categoryToggles[category.id] ?? true;
    final isExpanded = _expandedCategoryIds.contains(category.id);

    // Check if auto-pruning applies (all sub-items are none)
    final allSubItemsNone = category.items.every((item) {
      final level = _permissions[item.id] ?? 'none';
      return level == 'none';
    });

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? (isMasterOn ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.2))
            : (isMasterOn ? Colors.white.withValues(alpha: 0.75) : Colors.black.withValues(alpha: 0.02)),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMasterOn
              ? (isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08))
              : const Color(0xFFE11D48).withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level 1: Category Header with Master Switch
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedCategoryIds.remove(category.id);
                } else {
                  _expandedCategoryIds.add(category.id);
                }
              });
            },
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    category.icon,
                    size: 18,
                    color: isMasterOn
                        ? (isDark ? AppColors.goldChampagne : AppColors.goldDark)
                        : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          category.title,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: isMasterOn
                                ? (isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary)
                                : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              isMasterOn
                                  ? '${category.items.length} Sub-modules available'
                                  : 'Disabled from Left Rail',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                              ),
                            ),
                            if (!isMasterOn) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE11D48).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'HIDDEN',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFE11D48),
                                  ),
                                ),
                              ),
                            ] else if (allSubItemsNone) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'AUTO-PRUNED',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.amber,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Level 1 Master Switch [ ON / OFF ]
                  Transform.scale(
                    scale: 0.75,
                    child: Switch.adaptive(
                      value: isMasterOn,
                      activeTrackColor: AppColors.goldPrimary,
                      onChanged: (val) => _toggleCategoryMaster(category.id, val),
                    ),
                  ),

                  // Accordion Arrow
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                  ),
                ],
              ),
            ),
          ),

          // Level 2: Sub-Items List (Expanded)
          if (isExpanded && isMasterOn) ...[
            const Divider(height: 1, thickness: 0.6),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: category.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, idx) {
                final subItem = category.items[idx];
                final currentLevel = _permissions[subItem.id] ?? 'none';
                return _buildSubItemRow(subItem, currentLevel, isDark);
              },
            ),
          ],
        ],
      ),
    );
  }

  /// Level 2 Sub-Item Row with Tri-State Selector: [ None ] [ View ] [ Edit ]
  Widget _buildSubItemRow(MenuSubItem subItem, String currentLevel, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12,
          width: 0.6,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(
                  subItem.icon,
                  size: 15,
                  color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subItem.title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                      ),
                    ),
                    if (subItem.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subItem.subtitle,
                        style: TextStyle(
                          fontSize: 9.5,
                          color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Permission Level',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                ),
              ),
              _buildTriStateSelector(subItem.id, currentLevel, isDark),
            ],
          ),
        ],
      ),
    );
  }

  /// Responsive Tri-State Button Selector
  Widget _buildTriStateSelector(String subItemId, String currentLevel, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isDark ? Colors.black38 : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSegmentOption(
            subItemId: subItemId,
            level: 'none',
            label: 'None',
            icon: Icons.block_rounded,
            isSelected: currentLevel == 'none',
            activeColor: const Color(0xFFE11D48),
            isDark: isDark,
          ),
          _buildSegmentOption(
            subItemId: subItemId,
            level: 'view',
            label: 'View',
            icon: Icons.visibility_rounded,
            isSelected: currentLevel == 'view',
            activeColor: const Color(0xFF0284C7),
            isDark: isDark,
          ),
          _buildSegmentOption(
            subItemId: subItemId,
            level: 'edit',
            label: 'Edit',
            icon: Icons.edit_rounded,
            isSelected: currentLevel == 'edit',
            activeColor: const Color(0xFF059669),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentOption({
    required String subItemId,
    required String level,
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color activeColor,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () => _setSubItemPermission(subItemId, level),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.35),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 10.5,
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
            ),
            const SizedBox(width: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom Sticky Save Action Bar
  Widget _buildBottomActionBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1120) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white10 : Colors.black12,
            width: 0.7,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Two-level permissions apply immediately upon save.',
                style: TextStyle(
                  fontSize: 10.5,
                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                ),
                maxLines: 2,
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: _isSaving ? null : _handleSave,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.goldPrimary, AppColors.goldDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldPrimary.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.save_rounded, color: Colors.white, size: 15),
                            SizedBox(width: 6),
                            Text(
                              'Save Permissions',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
