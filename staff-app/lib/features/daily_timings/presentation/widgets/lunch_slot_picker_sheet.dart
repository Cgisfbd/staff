import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';

class LunchSlotOption {
  const LunchSlotOption({required this.value, required this.label});
  final int value;
  final String label;
}

class LunchSlotPickerSheet extends StatefulWidget {
  const LunchSlotPickerSheet({
    super.key,
    required this.currentSlot,
    required this.currentDuration,
    required this.onSlotSelected,
    required this.onDurationChanged,
  });

  final int currentSlot;
  final int currentDuration;
  final ValueChanged<int> onSlotSelected;
  final ValueChanged<int> onDurationChanged;

  static const List<LunchSlotOption> options = [
    LunchSlotOption(value: 1, label: 'After Period 1'),
    LunchSlotOption(value: 2, label: 'After Period 2'),
    LunchSlotOption(value: 3, label: 'After Period 3'),
    LunchSlotOption(value: 4, label: 'After Period 4 (Standard)'),
    LunchSlotOption(value: 5, label: 'After Period 5'),
    LunchSlotOption(value: 6, label: 'After Period 6'),
    LunchSlotOption(value: 7, label: 'After Period 7'),
    LunchSlotOption(value: 0, label: 'No Lunch Break (Disabled)'),
  ];

  static const List<int> durationChips = [10, 15, 20, 30, 45, 60];

  @override
  State<LunchSlotPickerSheet> createState() => _LunchSlotPickerSheetState();
}

class _LunchSlotPickerSheetState extends State<LunchSlotPickerSheet> {
  late int _selectedSlot;
  late int _duration;

  @override
  void initState() {
    super.initState();
    _selectedSlot = widget.currentSlot;
    _duration = widget.currentDuration;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.only(top: 14, left: 16, right: 16, bottom: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161A23) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.goldPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.restaurant_rounded,
                  color: AppColors.goldPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configure Lunch Break & Recess',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.textLightPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Choose period placement and recess duration',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.black45,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Duration Stepper & Quick Chips (only if lunch enabled)
          if (_selectedSlot > 0) ...[
            Text(
              'LUNCH DURATION (MINUTES)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
            const SizedBox(height: 8),

            // Stepper + Chips Row
            Row(
              children: [
                // Stepper
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        icon: const Icon(Icons.remove, size: 16),
                        onPressed: _duration > 5
                            ? () {
                                setState(() => _duration = (_duration - 5).clamp(5, 120));
                                widget.onDurationChanged(_duration);
                              }
                            : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '$_duration min',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'monospace',
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        icon: const Icon(Icons.add, size: 16),
                        onPressed: _duration < 120
                            ? () {
                                setState(() => _duration = (_duration + 5).clamp(5, 120));
                                widget.onDurationChanged(_duration);
                              }
                            : null,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Quick Chips
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: LunchSlotPickerSheet.durationChips.map((m) {
                        final isChipSelected = _duration == m;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              setState(() => _duration = m);
                              widget.onDurationChanged(m);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: isChipSelected
                                    ? AppColors.goldPrimary
                                    : (isDark
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : Colors.black.withValues(alpha: 0.04)),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isChipSelected
                                      ? AppColors.goldPrimary
                                      : (isDark ? Colors.white10 : Colors.black12),
                                ),
                              ),
                              child: Text(
                                '${m}m',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isChipSelected
                                      ? Colors.white
                                      : (isDark ? Colors.white70 : Colors.black87),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
          ],

          // Slot Options List
          Text(
            'INSERT LUNCH RECESS AFTER',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          const SizedBox(height: 8),

          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: LunchSlotPickerSheet.options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final opt = LunchSlotPickerSheet.options[index];
                final isSelected = _selectedSlot == opt.value;

                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setState(() => _selectedSlot = opt.value);
                    widget.onSlotSelected(opt.value);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.goldPrimary.withValues(alpha: isDark ? 0.18 : 0.1)
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.03)
                              : Colors.black.withValues(alpha: 0.02)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.goldPrimary
                            : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06)),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          opt.value == 0
                              ? Icons.block_rounded
                              : Icons.schedule_rounded,
                          size: 16,
                          color: isSelected
                              ? AppColors.goldPrimary
                              : (isDark ? Colors.white54 : Colors.black45),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            opt.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected
                                  ? (isDark ? AppColors.goldChampagne : AppColors.goldDark)
                                  : (isDark ? Colors.white : Colors.black87),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: AppColors.goldPrimary,
                          ),
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
  }
}
