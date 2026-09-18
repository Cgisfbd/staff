import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';

class InstituteSupportContactsCard extends StatelessWidget {
  const InstituteSupportContactsCard({
    super.key,
    required this.emailCtrl,
    required this.websiteCtrl,
    required this.whatsappCtrl,
    required this.onChanged,
  });

  final TextEditingController emailCtrl;
  final TextEditingController websiteCtrl;
  final TextEditingController whatsappCtrl;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputField(
          controller: emailCtrl,
          label: 'Official Support Email *',
          placeholder: 'info@institute.org',
          icon: Icons.email_rounded,
          iconColor: Colors.cyan,
          isDark: isDark,
        ),
        const SizedBox(height: 10),
        _buildInputField(
          controller: websiteCtrl,
          label: 'Official Website Domain *',
          placeholder: 'https://institute.org',
          icon: Icons.language_rounded,
          iconColor: Colors.blueAccent,
          isDark: isDark,
        ),
        const SizedBox(height: 10),
        _buildInputField(
          controller: whatsappCtrl,
          label: 'Official WhatsApp Number',
          placeholder: '+91 9876543210',
          icon: Icons.chat_rounded,
          iconColor: AppColors.emeraldPrimary,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white70 : AppColors.textLightSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 6),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: TextStyle(fontSize: 12, color: isDark ? Colors.white : AppColors.charcoalDark),
                  decoration: InputDecoration(
                    hintText: placeholder,
                    hintStyle: TextStyle(fontSize: 11, color: isDark ? Colors.white30 : Colors.black26),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                    isDense: true,
                    border: InputBorder.none,
                  ),
                  onChanged: (_) => onChanged(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
