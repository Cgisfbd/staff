import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:staff_app/core/theme/app_colors.dart';

class PolicyCardAutoDropout extends StatefulWidget {
  const PolicyCardAutoDropout({
    super.key,
    required this.dropoutDays,
    required this.onChanged,
  });

  final int dropoutDays;
  final ValueChanged<int> onChanged;

  static const List<int> presets = [7, 10, 15, 30, 45];

  @override
  State<PolicyCardAutoDropout> createState() => _PolicyCardAutoDropoutState();
}

class _PolicyCardAutoDropoutState extends State<PolicyCardAutoDropout> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.dropoutDays}');
  }

  @override
  void didUpdateWidget(covariant PolicyCardAutoDropout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dropoutDays != widget.dropoutDays &&
        _controller.text != '${widget.dropoutDays}') {
      _controller.text = '${widget.dropoutDays}';
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGlassSurface : AppColors.lightGlassSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.rosePrimary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: AppColors.rosePrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Auto-Dropout Trigger',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AppColors.charcoalDark,
                            ),
                          ),
                          Text(
                            'Consecutive Absence Limit',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 9.5,
                              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.rosePrimary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.rosePrimary.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${widget.dropoutDays}d Limit',
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w800,
                    color: AppColors.rosePrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Integrated Embedded Suffix Input
          Container(
            height: 38,
            decoration: BoxDecoration(
              color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    onChanged: (val) {
                      final n = int.tryParse(val) ?? 0;
                      widget.onChanged(n);
                    },
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.charcoalDark,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Text(
                  'Consecutive Days',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Segmented Presets
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: PolicyCardAutoDropout.presets.map((d) {
                final isSelected = widget.dropoutDays == d;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _controller.text = '$d';
                      widget.onChanged(d);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? const Color(0xFF262C36) : Colors.white)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 4,
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${d}d',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontFamily: 'monospace',
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? AppColors.rosePrimary
                              : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Dynamic Policy Impact Note
          Row(
            children: [
              const Icon(Icons.info_outline, size: 12, color: AppColors.rosePrimary),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Auto-dropout triggers after ${widget.dropoutDays} consecutive unexcused absences.',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
