import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:staff_app/core/di/injection_container.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/security/secure_storage_service.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/core/widgets/executive_top_header.dart';
import 'package:staff_app/features/auth/presentation/widgets/language_selector_pills.dart';
import 'package:staff_app/features/menu/data/menu_categories_data.dart';
import 'package:staff_app/features/menu/presentation/widgets/menu_left_rail.dart';
import 'package:staff_app/features/menu/presentation/widgets/menu_right_content.dart';
import 'package:staff_app/features/menu/presentation/widgets/menu_search_bar.dart';
import 'package:staff_app/features/menu/presentation/widgets/menu_sub_card.dart';

/// Master Orchestrator for the Amazon-Style Split-View Mega Menu Hub.
class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String _selectedCategoryId = 'students';
  String _searchQuery = '';
  String _userRole = 'STAFF';
  Map<String, bool> _userCategoryToggles = {};
  Map<String, String> _userPermissions = {};

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profileStr = await sl<SecureStorageService>().getUserProfile();
      if (profileStr != null && profileStr.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(profileStr) as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _userRole = data['role']?.toString() ?? 'STAFF';
            if (data['categoryToggles'] is Map) {
              _userCategoryToggles = (data['categoryToggles'] as Map).map(
                (k, v) => MapEntry(k.toString(), v as bool),
              );
            }
            if (data['permissions'] is Map) {
              _userPermissions = (data['permissions'] as Map).map(
                (k, v) => MapEntry(k.toString(), v.toString()),
              );
            }
          });
        }
      }
    } catch (_) {}
  }

  MenuCategory _filterCategoryItems(MenuCategory cat) {
    final isSuperAdmin = _userRole == 'SUPER_ADMIN';
    final allowedItems = cat.items.where((item) {
      if (item.isSuperAdminOnly && !isSuperAdmin) {
        return false;
      }
      if (isSuperAdmin || _userPermissions.isEmpty) {
        return true;
      }
      final level = _userPermissions[item.id];
      return level != 'none';
    }).toList();

    return MenuCategory(
      id: cat.id,
      title: cat.title,
      shortLabel: cat.shortLabel,
      subtitle: cat.subtitle,
      icon: cat.icon,
      badgeCount: cat.badgeCount,
      isSuperAdminOnly: cat.isSuperAdminOnly,
      items: allowedItems,
      sections: cat.sections?.map((sec) {
        final filteredSecItems = sec.items.where((item) {
          if (item.isSuperAdminOnly && !isSuperAdmin) {
            return false;
          }
          if (isSuperAdmin || _userPermissions.isEmpty) {
            return true;
          }
          final level = _userPermissions[item.id];
          return level != 'none';
        }).toList();
        return MenuSection(
          id: sec.id,
          title: sec.title,
          icon: sec.icon,
          items: filteredSecItems,
        );
      }).where((sec) => sec.items.isNotEmpty).toList(),
    );
  }

  List<MenuCategory> get _filteredCategories {
    final isSuperAdmin = _userRole == 'SUPER_ADMIN';
    return MenuCategoriesData.categories
        .where((cat) {
          if (cat.isSuperAdminOnly && !isSuperAdmin) {
            return false;
          }
          // Level 1: Category Master Switch
          if (_userCategoryToggles[cat.id] == false) {
            return false;
          }
          // Level 2 Auto-pruning: If all child items are 'none', hide category
          if (_userPermissions.isNotEmpty && !isSuperAdmin) {
            final hasVisible = cat.items.any((item) => _userPermissions[item.id] != 'none');
            if (!hasVisible) {
              return false;
            }
          }
          return true;
        })
        .map(_filterCategoryItems)
        .toList();
  }

  MenuCategory get _currentCategory {
    final list = _filteredCategories;
    return list.firstWhere(
      (cat) => cat.id == _selectedCategoryId,
      orElse: () => list.isNotEmpty ? list.first : MenuCategoriesData.categories.first,
    );
  }

  List<MenuSubItem> get _searchResults {
    if (_searchQuery.trim().isEmpty) return const [];
    final q = _searchQuery.toLowerCase().trim();
    final results = <MenuSubItem>[];

    for (final cat in _filteredCategories) {
      final catTitle = cat.localizedTitle(context).toLowerCase();
      for (final item in cat.items) {
        final itemTitle = item.localizedTitle(context).toLowerCase();
        final itemSub = item.localizedSubtitle(context).toLowerCase();
        if (itemTitle.contains(q) ||
            itemSub.contains(q) ||
            catTitle.contains(q) ||
            item.title.toLowerCase().contains(q) ||
            cat.title.toLowerCase().contains(q)) {
          results.add(item);
        }
      }
    }
    return results;
  }

  void _showLanguageSelector() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131A26) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: AppColors.goldPrimary.withValues(alpha: 0.35),
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.translate_rounded,
                    size: 20,
                    color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.tr('menu_sub_language_locale_title'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Center(child: LanguageSelectorPills()),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _handleSubItemTap(MenuSubItem item) {
    if (item.id == 'language_locale') {
      _showLanguageSelector();
      return;
    }

    if (item.route != null && item.route!.isNotEmpty) {
      context.push(item.route!);
      return;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(item.icon, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${context.tr('menu_quick_opening')} ${item.localizedTitle(context)}...',
                style: const TextStyle(fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.charcoalDark,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = _filteredCategories;
    final currentCat = _currentCategory;
    final isSearching = _searchQuery.trim().isNotEmpty;

    return Scaffold(
      body: AppBackground(
        useSafeArea: false,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 1. Top Bar: Executive Header matching Settings & Search Bar
              ExecutiveTopHeader(
                icon: Icons.grid_view_rounded,
                title: context.tr('menu_header_title'),
                subtitle: context.tr('menu_header_subtitle'),
                bottom: MenuSearchBar(
                  searchQuery: _searchQuery,
                  totalModulesCount: categories.length,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  onClear: () => setState(() => _searchQuery = ''),
                ),
              ),

              // 2. Main Body: Split View (Left Rail + Right Viewport) or Search Grid
              Expanded(
                child: isSearching
                    ? _buildSearchResultsView()
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Rail: 10 Categories
                          MenuLeftRail(
                            categories: categories,
                            selectedCategoryId: currentCat.id,
                            onCategorySelected: (catId) {
                              setState(() => _selectedCategoryId = catId);
                            },
                          ),

                          // Right Viewport: Sub-Actions Grid with Animated Switcher
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                              child: MenuRightContent(
                                key: ValueKey(currentCat.id),
                                category: currentCat,
                                onSubItemTap: _handleSubItemTap,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResultsView() {
    final results = _searchResults;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: isDark ? AppColors.goldChampagne.withValues(alpha: 0.4) : AppColors.textLightMuted,
            ),
            const SizedBox(height: 12),
            Text(
              '${context.tr('menu_no_modules_found')} "$_searchQuery"',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        14,
        12,
        14,
        MediaQuery.of(context).padding.bottom + 85,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${context.tr('menu_search_results')} (${results.length})',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 360 ? 4 : 3;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: results.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 10,
                  mainAxisExtent: 96.0,
                ),
                itemBuilder: (context, index) {
                  return MenuSubCard(
                    item: results[index],
                    onTap: () => _handleSubItemTap(results[index]),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
