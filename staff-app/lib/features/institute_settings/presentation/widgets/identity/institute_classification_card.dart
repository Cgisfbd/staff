import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';

class InstituteClassificationCard extends StatelessWidget {
  const InstituteClassificationCard({
    super.key,
    required this.selectedType,
    required this.affiliationCtrl,
    required this.onTypeChanged,
    required this.onAffiliationChanged,
  });

  final String selectedType;
  final TextEditingController affiliationCtrl;
  final ValueChanged<String> onTypeChanged;
  final VoidCallback onAffiliationChanged;

  static const List<String> instituteTypes = [
    'MADARSA',
    'MAKTAB',
    'SCHOOL',
    'COLLEGE',
    'UNIVERSITY',
    'ACADEMY',
    'JAMIA',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Institute Classification Type *',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white70 : AppColors.textLightSecondary,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: instituteTypes.map((type) {
              final isSelected = selectedType.toUpperCase() == type.toUpperCase();
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(
                    type,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? Colors.black : (isDark ? Colors.white70 : AppColors.charcoalDark),
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.goldPrimary,
                  backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
                  side: BorderSide(
                    color: isSelected ? AppColors.goldPrimary : (isDark ? Colors.white12 : Colors.black12),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  onSelected: (val) {
                    if (val) onTypeChanged(type);
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 10, right: 6),
                child: Icon(Icons.military_tech_rounded, size: 16, color: Colors.indigoAccent),
              ),
              Expanded(
                child: TextField(
                  controller: affiliationCtrl,
                  style: TextStyle(fontSize: 12, color: isDark ? Colors.white : AppColors.charcoalDark),
                  decoration: InputDecoration(
                    hintText: 'e.g. CBSE/2026/8941 or Waqf Reg 104',
                    hintStyle: TextStyle(fontSize: 11, color: isDark ? Colors.white30 : Colors.black26),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                    isDense: true,
                    border: InputBorder.none,
                  ),
                  onChanged: (_) => onAffiliationChanged(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
