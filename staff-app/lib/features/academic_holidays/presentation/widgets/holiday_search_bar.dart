import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';

class HolidaySearchBar extends StatefulWidget {
  const HolidaySearchBar({
    super.key,
    required this.searchQuery,
    required this.onQueryChanged,
  });

  final String searchQuery;
  final ValueChanged<String> onQueryChanged;

  @override
  State<HolidaySearchBar> createState() => _HolidaySearchBarState();
}

class _HolidaySearchBarState extends State<HolidaySearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant HolidaySearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery &&
        _controller.text != widget.searchQuery) {
      _controller.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGlassSurface : AppColors.lightGlassSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 18,
            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onQueryChanged,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search holidays...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _controller.clear();
                widget.onQueryChanged('');
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
