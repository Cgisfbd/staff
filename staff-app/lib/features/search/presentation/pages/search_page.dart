import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/features/search/domain/models/search_result_item.dart';
import 'package:staff_app/features/search/presentation/widgets/search_filter_pills.dart';
import 'package:staff_app/features/search/presentation/widgets/search_result_card.dart';
import 'package:staff_app/features/search/presentation/widgets/search_top_bar.dart';
import 'package:staff_app/features/search/presentation/widgets/student_detail_bottom_sheet.dart';

/// Screen Orchestrator for Live & Submitted Search (< 145 lines).
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String _query = '';
  SearchCategory? _selectedCategory;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onItemTapped(SearchResultItem item) {
    if (item.category == SearchCategory.student) {
      StudentDetailBottomSheet.show(context, item);
    } else if (item.route != null && item.route!.isNotEmpty) {
      context.push(item.route!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final results = SearchResultItem.search(_query, _selectedCategory);

    return Scaffold(
      body: AppBackground(
        useSafeArea: false,
        child: Column(
          children: [
            // Docked Top Bar with Instant Search Field
            SearchTopBar(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: (val) => setState(() => _query = val),
              onSubmitted: (val) {
                setState(() => _query = val);
                _focusNode.unfocus();
              },
              onClear: () {
                _controller.clear();
                setState(() => _query = '');
              },
              onBack: () => context.pop(),
            ),
            const SizedBox(height: 10),

            // Category Filter Pills
            SearchFilterPills(
              selectedCategory: _selectedCategory,
              onCategorySelected: (cat) => setState(() => _selectedCategory = cat),
            ),
            const SizedBox(height: 8),

            // Live Search Results List
            Expanded(
              child: results.isEmpty
                  ? _buildEmptyState(isDark)
                  : ListView.builder(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final item = results[index];
                        return SearchResultCard(
                          item: item,
                          onTap: () => _onItemTapped(item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final hasQuery = _query.trim().isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isDark ? const Color(0x26000000) : Colors.white.withValues(alpha: 0.8),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(0x33FFFFFF) : const Color(0x1F000000),
                  width: 1.0,
                ),
              ),
              child: Icon(
                hasQuery ? Icons.search_off_rounded : Icons.search_rounded,
                size: 30,
                color: AppColors.goldPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hasQuery
                  ? context.tr('no_search_results')
                  : context.tr('search_type_prompt'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
