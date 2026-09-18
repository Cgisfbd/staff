import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/institute_settings/data/models/institute_settings_ui_model.dart';
import 'package:staff_app/features/institute_settings/presentation/widgets/identity/institute_classification_card.dart';
import 'package:staff_app/features/institute_settings/presentation/widgets/identity/institute_quotes_card.dart';
import 'package:staff_app/features/institute_settings/presentation/widgets/identity/institute_triad_field_card.dart';

class InstituteIdentityCard extends StatefulWidget {
  const InstituteIdentityCard({
    super.key,
    required this.model,
    required this.onChanged,
  });

  final InstituteSettingsUiModel model;
  final ValueChanged<InstituteSettingsUiModel> onChanged;

  @override
  State<InstituteIdentityCard> createState() => _InstituteIdentityCardState();
}

class _InstituteIdentityCardState extends State<InstituteIdentityCard> {
  late TextEditingController _nameEnCtrl;
  late TextEditingController _nameUrCtrl;
  late TextEditingController _nameHiCtrl;
  late TextEditingController _taglineEnCtrl;
  late TextEditingController _taglineUrCtrl;
  late TextEditingController _taglineHiCtrl;
  late TextEditingController _addressEnCtrl;
  late TextEditingController _addressUrCtrl;
  late TextEditingController _addressHiCtrl;
  late TextEditingController _quotesMainCtrl;
  late TextEditingController _quotesTranslationCtrl;
  late TextEditingController _affiliationCtrl;
  late String _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.model.instituteType.isNotEmpty ? widget.model.instituteType : 'MADARSA';
    _initControllers();
  }

  void _initControllers() {
    _nameEnCtrl = TextEditingController(text: widget.model.nameEn);
    _nameUrCtrl = TextEditingController(text: widget.model.nameUr);
    _nameHiCtrl = TextEditingController(text: widget.model.nameHi);
    _taglineEnCtrl = TextEditingController(text: widget.model.taglineEn);
    _taglineUrCtrl = TextEditingController(text: widget.model.taglineUr);
    _taglineHiCtrl = TextEditingController(text: widget.model.taglineHi);
    _addressEnCtrl = TextEditingController(text: widget.model.addressEn);
    _addressUrCtrl = TextEditingController(text: widget.model.addressUr);
    _addressHiCtrl = TextEditingController(text: widget.model.addressHi);
    _quotesMainCtrl = TextEditingController(text: widget.model.quotesMain);
    _quotesTranslationCtrl = TextEditingController(text: widget.model.quotesTranslation);
    _affiliationCtrl = TextEditingController(text: widget.model.affiliationNumber);
  }

  @override
  void didUpdateWidget(covariant InstituteIdentityCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.model.id != widget.model.id) {
      _selectedType = widget.model.instituteType.isNotEmpty ? widget.model.instituteType : 'MADARSA';
      _nameEnCtrl.text = widget.model.nameEn;
      _nameUrCtrl.text = widget.model.nameUr;
      _nameHiCtrl.text = widget.model.nameHi;
      _taglineEnCtrl.text = widget.model.taglineEn;
      _taglineUrCtrl.text = widget.model.taglineUr;
      _taglineHiCtrl.text = widget.model.taglineHi;
      _addressEnCtrl.text = widget.model.addressEn;
      _addressUrCtrl.text = widget.model.addressUr;
      _addressHiCtrl.text = widget.model.addressHi;
      _quotesMainCtrl.text = widget.model.quotesMain;
      _quotesTranslationCtrl.text = widget.model.quotesTranslation;
      _affiliationCtrl.text = widget.model.affiliationNumber;
    }
  }

  @override
  void dispose() {
    _nameEnCtrl.dispose();
    _nameUrCtrl.dispose();
    _nameHiCtrl.dispose();
    _taglineEnCtrl.dispose();
    _taglineUrCtrl.dispose();
    _taglineHiCtrl.dispose();
    _addressEnCtrl.dispose();
    _addressUrCtrl.dispose();
    _addressHiCtrl.dispose();
    _quotesMainCtrl.dispose();
    _quotesTranslationCtrl.dispose();
    _affiliationCtrl.dispose();
    super.dispose();
  }

  void _notifyChange() {
    widget.onChanged(
      widget.model.copyWith(
        instituteType: _selectedType,
        affiliationNumber: _affiliationCtrl.text,
        nameEn: _nameEnCtrl.text,
        nameUr: _nameUrCtrl.text,
        nameHi: _nameHiCtrl.text,
        taglineEn: _taglineEnCtrl.text,
        taglineUr: _taglineUrCtrl.text,
        taglineHi: _taglineHiCtrl.text,
        addressEn: _addressEnCtrl.text,
        addressUr: _addressUrCtrl.text,
        addressHi: _addressHiCtrl.text,
        quotesMain: _quotesMainCtrl.text,
        quotesTranslation: _quotesTranslationCtrl.text,
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
              const Icon(Icons.account_balance_rounded, size: 18, color: AppColors.goldPrimary),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'INSTITUTIONAL IDENTITY & QUOTES',
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
          InstituteClassificationCard(
            selectedType: _selectedType,
            affiliationCtrl: _affiliationCtrl,
            onTypeChanged: (type) {
              setState(() => _selectedType = type);
              _notifyChange();
            },
            onAffiliationChanged: _notifyChange,
          ),
          const SizedBox(height: 16),
          InstituteTriadFieldCard(
            title: 'Official Institute Name',
            icon: Icons.public_rounded,
            iconColor: AppColors.emeraldPrimary,
            isRequired: true,
            enCtrl: _nameEnCtrl,
            enPlaceholder: 'e.g. Jamia Darul Uloom',
            urCtrl: _nameUrCtrl,
            urPlaceholder: 'مثلاً: جامعہ دار العلوم',
            hiCtrl: _nameHiCtrl,
            hiPlaceholder: 'उदा. दारुल उलूम',
            onChanged: _notifyChange,
          ),
          const SizedBox(height: 16),
          InstituteTriadFieldCard(
            title: 'Motto / Tagline / Subtitle',
            icon: Icons.auto_awesome_rounded,
            iconColor: AppColors.goldPrimary,
            isRequired: false,
            enCtrl: _taglineEnCtrl,
            enPlaceholder: 'e.g. Center of Islamic & Modern Sciences',
            urCtrl: _taglineUrCtrl,
            urPlaceholder: 'مثلاً: مرکز علوم اسلامیہ و عصریہ',
            hiCtrl: _taglineHiCtrl,
            hiPlaceholder: 'उदा. उत्कृष्टता और ज्ञान का केंद्र',
            onChanged: _notifyChange,
          ),
          const SizedBox(height: 16),
          InstituteTriadFieldCard(
            title: 'Campus Physical Address',
            icon: Icons.location_on_rounded,
            iconColor: Colors.cyan,
            isRequired: false,
            enCtrl: _addressEnCtrl,
            enPlaceholder: 'e.g. Campus Main Gate, GT Road',
            urCtrl: _addressUrCtrl,
            urPlaceholder: 'کیمپس کا پتہ درج کریں',
            hiCtrl: _addressHiCtrl,
            hiPlaceholder: 'कैंपस का पता दर्ज करें',
            onChanged: _notifyChange,
          ),
          const SizedBox(height: 16),
          InstituteQuotesCard(
            quotesMainCtrl: _quotesMainCtrl,
            quotesTranslationCtrl: _quotesTranslationCtrl,
            onChanged: _notifyChange,
          ),
        ],
      ),
    );
  }
}
