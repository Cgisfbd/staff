import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:staff_app/core/theme/app_colors.dart';

class PolicyCardStudentLeave extends StatefulWidget {
  const PolicyCardStudentLeave({
    super.key,
    required this.quotaDays,
    required this.onChanged,
  });

  final int quotaDays;
  final ValueChanged<int> onChanged;

  static const List<int> presets = [7, 10, 14, 21, 30];

  @override
  State<PolicyCardStudentLeave> createState() => _PolicyCardStudentLeaveState();
}

class _PolicyCardStudentLeaveState extends State<PolicyCardStudentLeave> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.quotaDays}');
  }

  @override
  void didUpdateWidget(covariant PolicyCardStudentLeave oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quotaDays != widget.quotaDays &&
        _controller.text != '${widget.quotaDays}') {
      _controller.text = '${widget.quotaDays}';
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
                        color: const Color(0xFFEA580C).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        size: 16,
                        color: Color(0xFFEA580C),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Student Leave Quota',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AppColors.charcoalDark,
                            ),
                          ),
                          Text(
                            'Annual Sanctioned Limit',
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
                  color: const Color(0xFFEA580C).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEA580C).withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${widget.quotaDays}d / Year',
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFEA580C),
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
                  'Days / Year',
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
              children: PolicyCardStudentLeave.presets.map((l) {
                final isSelected = widget.quotaDays == l;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _controller.text = '$l';
                      widget.onChanged(l);
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
                        '${l}d',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontFamily: 'monospace',
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFFEA580C)
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
              const Icon(Icons.info_outline, size: 12, color: Color(0xFFEA580C)),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Allows students up to ${widget.quotaDays} days of sanctioned leave per session.',
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
