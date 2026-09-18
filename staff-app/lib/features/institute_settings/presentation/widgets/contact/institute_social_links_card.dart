import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';

class InstituteSocialLinksCard extends StatelessWidget {
  const InstituteSocialLinksCard({
    super.key,
    required this.whatsappChannelCtrl,
    required this.instagramCtrl,
    required this.xCtrl,
    required this.telegramCtrl,
    required this.youtubeCtrl,
    required this.onChanged,
  });

  final TextEditingController whatsappChannelCtrl;
  final TextEditingController instagramCtrl;
  final TextEditingController xCtrl;
  final TextEditingController telegramCtrl;
  final TextEditingController youtubeCtrl;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.podcasts_rounded, size: 16, color: AppColors.goldPrimary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Broadcast & Social Channels',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.charcoalDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildInputField(
          controller: whatsappChannelCtrl,
          label: 'WhatsApp Broadcast Channel Link',
          placeholder: 'https://whatsapp.com/channel/...',
          icon: Icons.cell_tower_rounded,
          iconColor: AppColors.emeraldPrimary,
          isDark: isDark,
        ),
        const SizedBox(height: 8),
        _buildInputField(
          controller: instagramCtrl,
          label: 'Instagram Profile Link',
          placeholder: 'https://instagram.com/institute',
          icon: Icons.camera_alt_rounded,
          iconColor: Colors.pinkAccent,
          isDark: isDark,
        ),
        const SizedBox(height: 8),
        _buildInputField(
          controller: xCtrl,
          label: 'X (Twitter) Profile Link',
          placeholder: 'https://x.com/institute',
          icon: Icons.alternate_email_rounded,
          iconColor: Colors.lightBlueAccent,
          isDark: isDark,
        ),
        const SizedBox(height: 8),
        _buildInputField(
          controller: telegramCtrl,
          label: 'Telegram Channel Link',
          placeholder: 'https://t.me/institute',
          icon: Icons.send_rounded,
          iconColor: Colors.blueAccent,
          isDark: isDark,
        ),
        const SizedBox(height: 8),
        _buildInputField(
          controller: youtubeCtrl,
          label: 'YouTube Channel Link',
          placeholder: 'https://youtube.com/@institute',
          icon: Icons.smart_display_rounded,
          iconColor: Colors.redAccent,
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
