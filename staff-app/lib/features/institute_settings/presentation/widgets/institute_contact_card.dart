import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/institute_settings/data/models/institute_settings_ui_model.dart';
import 'package:staff_app/features/institute_settings/presentation/widgets/contact/institute_phone_manager_card.dart';
import 'package:staff_app/features/institute_settings/presentation/widgets/contact/institute_social_links_card.dart';
import 'package:staff_app/features/institute_settings/presentation/widgets/contact/institute_support_contacts_card.dart';

class InstituteContactCard extends StatefulWidget {
  const InstituteContactCard({
    super.key,
    required this.model,
    required this.onChanged,
  });

  final InstituteSettingsUiModel model;
  final ValueChanged<InstituteSettingsUiModel> onChanged;

  @override
  State<InstituteContactCard> createState() => _InstituteContactCardState();
}

class _InstituteContactCardState extends State<InstituteContactCard> {
  late TextEditingController _emailCtrl;
  late TextEditingController _websiteCtrl;
  late TextEditingController _whatsappCtrl;
  late TextEditingController _whatsappChannelCtrl;
  late TextEditingController _instagramCtrl;
  late TextEditingController _xCtrl;
  late TextEditingController _telegramCtrl;
  late TextEditingController _youtubeCtrl;
  late List<String> _phones;

  @override
  void initState() {
    super.initState();
    _phones = List<String>.from(widget.model.contactPhones);
    _emailCtrl = TextEditingController(text: widget.model.contactEmail);
    _websiteCtrl = TextEditingController(text: widget.model.websiteUrl);
    _whatsappCtrl = TextEditingController(text: widget.model.whatsappNumber);
    _whatsappChannelCtrl = TextEditingController(text: widget.model.whatsappChannelUrl);
    _instagramCtrl = TextEditingController(text: widget.model.instagramUrl);
    _xCtrl = TextEditingController(text: widget.model.xUrl);
    _telegramCtrl = TextEditingController(text: widget.model.telegramUrl);
    _youtubeCtrl = TextEditingController(text: widget.model.youtubeUrl);
  }

  @override
  void didUpdateWidget(covariant InstituteContactCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.model.id != widget.model.id) {
      _phones = List<String>.from(widget.model.contactPhones);
      _emailCtrl.text = widget.model.contactEmail;
      _websiteCtrl.text = widget.model.websiteUrl;
      _whatsappCtrl.text = widget.model.whatsappNumber;
      _whatsappChannelCtrl.text = widget.model.whatsappChannelUrl;
      _instagramCtrl.text = widget.model.instagramUrl;
      _xCtrl.text = widget.model.xUrl;
      _telegramCtrl.text = widget.model.telegramUrl;
      _youtubeCtrl.text = widget.model.youtubeUrl;
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _websiteCtrl.dispose();
    _whatsappCtrl.dispose();
    _whatsappChannelCtrl.dispose();
    _instagramCtrl.dispose();
    _xCtrl.dispose();
    _telegramCtrl.dispose();
    _youtubeCtrl.dispose();
    super.dispose();
  }

  void _notifyChange() {
    widget.onChanged(
      widget.model.copyWith(
        contactPhones: _phones,
        contactEmail: _emailCtrl.text,
        websiteUrl: _websiteCtrl.text,
        whatsappNumber: _whatsappCtrl.text,
        whatsappChannelUrl: _whatsappChannelCtrl.text,
        instagramUrl: _instagramCtrl.text,
        xUrl: _xCtrl.text,
        telegramUrl: _telegramCtrl.text,
        youtubeUrl: _youtubeCtrl.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGlassSurface : AppColors.lightGlassSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.perm_phone_msg_rounded, size: 18, color: AppColors.emeraldPrimary),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'HELPLINES & SOCIAL CHANNELS',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: isDark ? Colors.white : AppColors.charcoalDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InstitutePhoneManagerCard(
            phones: _phones,
            onChanged: (updated) {
              setState(() => _phones = updated);
              _notifyChange();
            },
          ),
          const SizedBox(height: 16),
          InstituteSupportContactsCard(
            emailCtrl: _emailCtrl,
            websiteCtrl: _websiteCtrl,
            whatsappCtrl: _whatsappCtrl,
            onChanged: _notifyChange,
          ),
          const SizedBox(height: 16),
          InstituteSocialLinksCard(
            whatsappChannelCtrl: _whatsappChannelCtrl,
            instagramCtrl: _instagramCtrl,
            xCtrl: _xCtrl,
            telegramCtrl: _telegramCtrl,
            youtubeCtrl: _youtubeCtrl,
            onChanged: _notifyChange,
          ),
        ],
      ),
    );
  }
}
