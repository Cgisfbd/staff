import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';

/// Docked Liquid Crystal Glass Top Bar for Instant Search (< 140 lines).
class SearchTopBar extends StatelessWidget {
  const SearchTopBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    required this.onBack,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusBarHeight = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: statusBarHeight > 0 ? statusBarHeight + 6 : 12,
              bottom: 12,
              left: 14,
              right: 14,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [const Color(0xF21E293B), const Color(0xF20F172A)]
                    : [const Color(0xFAFBF7EE), const Color(0xF5FFFFFF)],
              ),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0x33FFFFFF) : const Color(0x1F000000),
                  width: 1.0,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Frosted Back Button
                _buildBackButton(context, isDark),
                const SizedBox(width: 10),

                // Search Input Field Container
                Expanded(
                  child: _buildInputField(context, isDark),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, bool isDark) {
    return InkWell(
      onTap: onBack,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? const Color(0x380F172A) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.07),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: isDark ? AppColors.goldLight : AppColors.charcoalDark,
        ),
      ),
    );
  }

  Widget _buildInputField(BuildContext context, bool isDark) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isDark ? const Color(0x380F172A) : Colors.white,
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.07),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(
            Icons.search_rounded,
            size: 20,
            color: AppColors.goldPrimary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              cursorColor: AppColors.goldPrimary,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
              ),
              decoration: InputDecoration(
                hintText: context.tr('search_hint'),
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                ),
                isDense: true,
                filled: false,
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox(width: 10);
              return IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                splashRadius: 18,
                onPressed: onClear,
              );
            },
          ),
        ],
      ),
    );
  }
}
