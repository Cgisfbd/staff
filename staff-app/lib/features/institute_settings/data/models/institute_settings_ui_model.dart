import 'package:staff_app/features/institute_settings/domain/entities/institute_settings_entity.dart';

class MultilingualParagraph extends MultilingualParagraphEntity {
  const MultilingualParagraph({
    super.en = '',
    super.ur = '',
    super.hi = '',
  });

  factory MultilingualParagraph.fromJson(Map<String, dynamic> json) {
    return MultilingualParagraph(
      en: json['en']?.toString() ?? '',
      ur: json['ur']?.toString() ?? '',
      hi: json['hi']?.toString() ?? '',
    );
  }

  factory MultilingualParagraph.fromEntity(MultilingualParagraphEntity entity) {
    return MultilingualParagraph(
      en: entity.en,
      ur: entity.ur,
      hi: entity.hi,
    );
  }

  Map<String, dynamic> toJson() => {
    'en': en,
    'ur': ur,
    'hi': hi,
  };

  MultilingualParagraph copyWith({String? en, String? ur, String? hi}) {
    return MultilingualParagraph(
      en: en ?? this.en,
      ur: ur ?? this.ur,
      hi: hi ?? this.hi,
    );
  }
}

class InstituteSettingsUiModel extends InstituteSettingsEntity {
  const InstituteSettingsUiModel({
    super.id = '',
    super.nameEn = 'TaleemOne ERP',
    super.nameUr = 'جامعہ / ادارہ',
    super.nameHi = 'शैक्षणिक पोर्टल',
    super.taglineEn = 'School & College Management Portal',
    super.taglineUr = 'تعلیمی و تربیتی پورٹل',
    super.taglineHi = 'शैक्षणिक पोर्टल',
    super.quotesMain = 'طَلَبُ الْعِلْمِ فَرِيضَةٌ عَلَى كُلِّ مُسْلِمٍ',
    super.quotesTranslation = 'Acquiring knowledge is an obligation upon every Muslim.',
    super.quotesUr = 'طلبِ علم ہر مسلمان پر فرض ہے۔',
    super.quotesAr = 'طَلَبُ الْعِلْمِ فَرِيضَةٌ عَلَى كُلِّ مُسْلِمٍ',
    super.instituteType = 'MADARSA',
    super.affiliationNumber = '',
    super.logoUrl = '/uploads/branding/logo.png',
    super.bannerUrl = '/uploads/branding/banner.png',
    super.contactPhones = const [],
    super.contactEmail = '',
    super.websiteUrl = '',
    super.whatsappNumber = '',
    super.addressEn = '',
    super.addressUr = '',
    super.addressHi = '',
    super.whatsappChannelUrl = '',
    super.youtubeUrl = '',
    super.telegramUrl = '',
    super.instagramUrl = '',
    super.xUrl = '',
    super.currencyCode = 'INR',
    super.currencySymbol = '₹',
    super.timezone = 'Asia/Kolkata',
    super.dateFormat = 'DD MMM YYYY',
    super.aboutUs = const [],
    super.instituteIntroduction = const [],
    super.founderMessage = const [],
    super.studentRules = const [],
    super.parentRules = const [],
    super.staffRules = const [],
    super.privacyPolicy = const [],
  });

  factory InstituteSettingsUiModel.fromJson(Map<String, dynamic> json) {
    final nameMap = json['name'] is Map ? json['name'] as Map<String, dynamic> : <String, dynamic>{};
    final taglineMap = json['tagline'] is Map ? json['tagline'] as Map<String, dynamic> : <String, dynamic>{};
    final quotesMap = json['quotes'] is Map ? json['quotes'] as Map<String, dynamic> : <String, dynamic>{};
    final addressMap = json['address'] is Map ? json['address'] as Map<String, dynamic> : <String, dynamic>{};

    List<String> parsedPhones = [];
    if (json['contactPhones'] is List) {
      parsedPhones = (json['contactPhones'] as List)
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList();
    }

    return InstituteSettingsUiModel(
      id: json['id']?.toString() ?? '',
      nameEn: nameMap['en']?.toString() ?? 'TaleemOne ERP',
      nameUr: nameMap['ur']?.toString() ?? 'جامعہ / ادارہ',
      nameHi: nameMap['hi']?.toString() ?? '',
      taglineEn: taglineMap['en']?.toString() ?? 'School & College Management Portal',
      taglineUr: taglineMap['ur']?.toString() ?? '',
      taglineHi: taglineMap['hi']?.toString() ?? '',
      quotesMain: quotesMap['main']?.toString() ?? quotesMap['ar']?.toString() ?? 'طَلَبُ الْعِلْمِ فَرِيضَةٌ عَلَى كُلِّ مُسْلِمٍ',
      quotesTranslation: quotesMap['translation']?.toString() ?? '',
      quotesUr: quotesMap['ur']?.toString() ?? 'طلبِ علم ہر مسلمان پر فرض ہے۔',
      quotesAr: quotesMap['ar']?.toString() ?? '',
      instituteType: json['instituteType']?.toString() ?? 'MADARSA',
      affiliationNumber: json['affiliationNumber']?.toString() ?? '',
      logoUrl: json['logoUrl']?.toString() ?? '/uploads/branding/logo.png',
      bannerUrl: json['bannerUrl']?.toString() ?? '/uploads/branding/banner.png',
      contactPhones: parsedPhones,
      contactEmail: json['contactEmail']?.toString() ?? '',
      websiteUrl: json['websiteUrl']?.toString() ?? '',
      whatsappNumber: json['whatsappNumber']?.toString() ?? '',
      addressEn: addressMap['en']?.toString() ?? '',
      addressUr: addressMap['ur']?.toString() ?? '',
      addressHi: addressMap['hi']?.toString() ?? '',
      whatsappChannelUrl: json['whatsappChannelUrl']?.toString() ?? '',
      youtubeUrl: json['youtubeUrl']?.toString() ?? '',
      telegramUrl: json['telegramUrl']?.toString() ?? '',
      instagramUrl: json['instagramUrl']?.toString() ?? '',
      xUrl: json['xUrl']?.toString() ?? '',
      currencyCode: json['currencyCode']?.toString() ?? 'INR',
      currencySymbol: json['currencySymbol']?.toString() ?? '₹',
      timezone: json['timezone']?.toString() ?? 'Asia/Kolkata',
      dateFormat: json['dateFormat']?.toString() ?? 'DD MMM YYYY',
      aboutUs: _parseParagraphs(json['aboutUs']),
      instituteIntroduction: _parseParagraphs(json['instituteIntroduction']),
      founderMessage: _parseParagraphs(json['founderMessage']),
      studentRules: _parseParagraphs(json['studentRules']),
      parentRules: _parseParagraphs(json['parentRules']),
      staffRules: _parseParagraphs(json['staffRules']),
      privacyPolicy: _parseParagraphs(json['privacyPolicy']),
    );
  }

  factory InstituteSettingsUiModel.fromEntity(InstituteSettingsEntity entity) {
    if (entity is InstituteSettingsUiModel) {
      return entity;
    }
    return InstituteSettingsUiModel(
      id: entity.id,
      nameEn: entity.nameEn,
      nameUr: entity.nameUr,
      nameHi: entity.nameHi,
      taglineEn: entity.taglineEn,
      taglineUr: entity.taglineUr,
      taglineHi: entity.taglineHi,
      quotesMain: entity.quotesMain,
      quotesTranslation: entity.quotesTranslation,
      quotesUr: entity.quotesUr,
      quotesAr: entity.quotesAr,
      instituteType: entity.instituteType,
      affiliationNumber: entity.affiliationNumber,
      logoUrl: entity.logoUrl,
      bannerUrl: entity.bannerUrl,
      contactPhones: entity.contactPhones,
      contactEmail: entity.contactEmail,
      websiteUrl: entity.websiteUrl,
      whatsappNumber: entity.whatsappNumber,
      addressEn: entity.addressEn,
      addressUr: entity.addressUr,
      addressHi: entity.addressHi,
      whatsappChannelUrl: entity.whatsappChannelUrl,
      youtubeUrl: entity.youtubeUrl,
      telegramUrl: entity.telegramUrl,
      instagramUrl: entity.instagramUrl,
      xUrl: entity.xUrl,
      currencyCode: entity.currencyCode,
      currencySymbol: entity.currencySymbol,
      timezone: entity.timezone,
      dateFormat: entity.dateFormat,
      aboutUs: entity.aboutUs.map((e) => MultilingualParagraph.fromEntity(e)).toList(),
      instituteIntroduction: entity.instituteIntroduction.map((e) => MultilingualParagraph.fromEntity(e)).toList(),
      founderMessage: entity.founderMessage.map((e) => MultilingualParagraph.fromEntity(e)).toList(),
      studentRules: entity.studentRules.map((e) => MultilingualParagraph.fromEntity(e)).toList(),
      parentRules: entity.parentRules.map((e) => MultilingualParagraph.fromEntity(e)).toList(),
      staffRules: entity.staffRules.map((e) => MultilingualParagraph.fromEntity(e)).toList(),
      privacyPolicy: entity.privacyPolicy.map((e) => MultilingualParagraph.fromEntity(e)).toList(),
    );
  }

  static List<MultilingualParagraph> _parseParagraphs(dynamic list) {
    if (list is List) {
      return list.map((item) {
        if (item is Map) {
          return MultilingualParagraph.fromJson(Map<String, dynamic>.from(item));
        }
        return const MultilingualParagraph();
      }).toList();
    }
    return [];
  }

  InstituteSettingsUiModel copyWith({
    String? id,
    String? nameEn,
    String? nameUr,
    String? nameHi,
    String? taglineEn,
    String? taglineUr,
    String? taglineHi,
    String? quotesMain,
    String? quotesTranslation,
    String? quotesUr,
    String? quotesAr,
    String? instituteType,
    String? affiliationNumber,
    String? logoUrl,
    String? bannerUrl,
    List<String>? contactPhones,
    String? contactEmail,
    String? websiteUrl,
    String? whatsappNumber,
    String? addressEn,
    String? addressUr,
    String? addressHi,
    String? whatsappChannelUrl,
    String? youtubeUrl,
    String? telegramUrl,
    String? instagramUrl,
    String? xUrl,
    String? currencyCode,
    String? currencySymbol,
    String? timezone,
    String? dateFormat,
    List<MultilingualParagraphEntity>? aboutUs,
    List<MultilingualParagraphEntity>? instituteIntroduction,
    List<MultilingualParagraphEntity>? founderMessage,
    List<MultilingualParagraphEntity>? studentRules,
    List<MultilingualParagraphEntity>? parentRules,
    List<MultilingualParagraphEntity>? staffRules,
    List<MultilingualParagraphEntity>? privacyPolicy,
  }) {
    return InstituteSettingsUiModel(
      id: id ?? this.id,
      nameEn: nameEn ?? this.nameEn,
      nameUr: nameUr ?? this.nameUr,
      nameHi: nameHi ?? this.nameHi,
      taglineEn: taglineEn ?? this.taglineEn,
      taglineUr: taglineUr ?? this.taglineUr,
      taglineHi: taglineHi ?? this.taglineHi,
      quotesMain: quotesMain ?? this.quotesMain,
      quotesTranslation: quotesTranslation ?? this.quotesTranslation,
      quotesUr: quotesUr ?? this.quotesUr,
      quotesAr: quotesAr ?? this.quotesAr,
      instituteType: instituteType ?? this.instituteType,
      affiliationNumber: affiliationNumber ?? this.affiliationNumber,
      logoUrl: logoUrl ?? this.logoUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      contactPhones: contactPhones ?? this.contactPhones,
      contactEmail: contactEmail ?? this.contactEmail,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      addressEn: addressEn ?? this.addressEn,
      addressUr: addressUr ?? this.addressUr,
      addressHi: addressHi ?? this.addressHi,
      whatsappChannelUrl: whatsappChannelUrl ?? this.whatsappChannelUrl,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      telegramUrl: telegramUrl ?? this.telegramUrl,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      xUrl: xUrl ?? this.xUrl,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      timezone: timezone ?? this.timezone,
      dateFormat: dateFormat ?? this.dateFormat,
      aboutUs: aboutUs ?? this.aboutUs,
      instituteIntroduction: instituteIntroduction ?? this.instituteIntroduction,
      founderMessage: founderMessage ?? this.founderMessage,
      studentRules: studentRules ?? this.studentRules,
      parentRules: parentRules ?? this.parentRules,
      staffRules: staffRules ?? this.staffRules,
      privacyPolicy: privacyPolicy ?? this.privacyPolicy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': {
        'en': nameEn,
        'ur': nameUr,
        'hi': nameHi,
      },
      'tagline': {
        'en': taglineEn,
        'ur': taglineUr,
        'hi': taglineHi,
      },
      'quotes': {
        'main': quotesMain,
        'translation': quotesTranslation,
        'ur': quotesUr,
        'ar': quotesAr,
      },
      'address': {
        'en': addressEn,
        'ur': addressUr,
        'hi': addressHi,
      },
      'instituteType': instituteType,
      'affiliationNumber': affiliationNumber,
      'logoUrl': logoUrl,
      'bannerUrl': bannerUrl,
      'contactPhones': contactPhones,
      'contactEmail': contactEmail,
      'websiteUrl': websiteUrl,
      'whatsappNumber': whatsappNumber,
      'whatsappChannelUrl': whatsappChannelUrl,
      'youtubeUrl': youtubeUrl,
      'telegramUrl': telegramUrl,
      'instagramUrl': instagramUrl,
      'xUrl': xUrl,
      'currencyCode': currencyCode,
      'currencySymbol': currencySymbol,
      'timezone': timezone,
      'dateFormat': dateFormat,
      'aboutUs': aboutUs.map((e) => {'en': e.en, 'ur': e.ur, 'hi': e.hi}).toList(),
      'instituteIntroduction': instituteIntroduction.map((e) => {'en': e.en, 'ur': e.ur, 'hi': e.hi}).toList(),
      'founderMessage': founderMessage.map((e) => {'en': e.en, 'ur': e.ur, 'hi': e.hi}).toList(),
      'studentRules': studentRules.map((e) => {'en': e.en, 'ur': e.ur, 'hi': e.hi}).toList(),
      'parentRules': parentRules.map((e) => {'en': e.en, 'ur': e.ur, 'hi': e.hi}).toList(),
      'staffRules': staffRules.map((e) => {'en': e.en, 'ur': e.ur, 'hi': e.hi}).toList(),
      'privacyPolicy': privacyPolicy.map((e) => {'en': e.en, 'ur': e.ur, 'hi': e.hi}).toList(),
    };
  }
}
