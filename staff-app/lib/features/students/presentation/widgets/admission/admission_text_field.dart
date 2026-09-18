import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';

/// Standardized Luxury Input Field for Admission Forms.
class AdmissionTextField extends StatelessWidget {
  const AdmissionTextField({
    super.key,
    required this.label,
    this.isRequired = false,
    required this.controller,
    this.hint,
    this.isRtl = false,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.errorText,
    this.onChanged,
  });

  final String label;
  final bool isRequired;
  final TextEditingController controller;
  final String? hint;
  final bool isRtl;
  final TextInputType keyboardType;
  final int? maxLength;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label Row
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                  letterSpacing: 0.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  color: AppColors.statusAbsent,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 5),

        // Text Field Container
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0x1F0F172A)
                : const Color(0x52F8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null
                  ? AppColors.statusAbsent
                  : (isDark ? Colors.white12 : Colors.black12),
              width: 0.9,
            ),
          ),
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            onChanged: onChanged,
            keyboardType: keyboardType,
            maxLength: maxLength,
            maxLines: maxLines,
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w400,
                color: isDark ? Colors.white30 : Colors.black38,
              ),
              hintTextDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              counterText: '',
              border: InputBorder.none,
              suffixIcon: suffixIcon,
            ),
          ),
        ),

        // Error message if any
        if (errorText != null) ...[
          const SizedBox(height: 3),
          Text(
            errorText!,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.statusAbsent,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
