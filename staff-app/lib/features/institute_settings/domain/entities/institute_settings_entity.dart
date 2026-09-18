import 'package:equatable/equatable.dart';

class MultilingualParagraphEntity extends Equatable {
  const MultilingualParagraphEntity({
    this.en = '',
    this.ur = '',
    this.hi = '',
  });

  final String en;
  final String ur;
  final String hi;

  @override
  List<Object?> get props => [en, ur, hi];
}

class InstituteSettingsEntity extends Equatable {
  const InstituteSettingsEntity({
    this.id = '',
    this.nameEn = 'TaleemOne ERP',
    this.nameUr = 'جامعہ / ادارہ',
    this.nameHi = 'शैक्षणिक पोर्टल',
    this.taglineEn = 'School & College Management Portal',
    this.taglineUr = 'تعلیمی و تربیتی پورٹل',
    this.taglineHi = 'शैक्षणिक पोर्टल',
    this.quotesMain = 'طَلَبُ الْعِلْمِ فَرِيضَةٌ عَلَى كُلِّ مُسْلِمٍ',
    this.quotesTranslation = 'Acquiring knowledge is an obligation upon every Muslim.',
    this.quotesUr = 'طلبِ علم ہر مسلمان پر فرض ہے۔',
    this.quotesAr = 'طَلَبُ الْعِلْمِ فَرِيضَةٌ عَلَى كُلِّ مُسْلِمٍ',
    this.instituteType = 'MADARSA',
    this.affiliationNumber = '',
    this.logoUrl = '/uploads/branding/logo.png',
    this.bannerUrl = '/uploads/branding/banner.png',
    this.contactPhones = const [],
    this.contactEmail = '',
    this.websiteUrl = '',
    this.whatsappNumber = '',
    this.addressEn = '',
    this.addressUr = '',
    this.addressHi = '',
    this.whatsappChannelUrl = '',
    this.youtubeUrl = '',
    this.telegramUrl = '',
    this.instagramUrl = '',
    this.xUrl = '',
    this.currencyCode = 'INR',
    this.currencySymbol = '₹',
    this.timezone = 'Asia/Kolkata',
    this.dateFormat = 'DD MMM YYYY',
    this.aboutUs = const [],
    this.instituteIntroduction = const [],
    this.founderMessage = const [],
    this.studentRules = const [],
    this.parentRules = const [],
    this.staffRules = const [],
    this.privacyPolicy = const [],
  });

  final String id;
  final String nameEn;
  final String nameUr;
  final String nameHi;
  final String taglineEn;
  final String taglineUr;
  final String taglineHi;
  final String quotesMain;
  final String quotesTranslation;
  final String quotesUr;
  final String quotesAr;
  final String instituteType;
  final String affiliationNumber;
  final String logoUrl;
  final String bannerUrl;
  final List<String> contactPhones;
  final String contactEmail;
  final String websiteUrl;
  final String whatsappNumber;
  final String addressEn;
  final String addressUr;
  final String addressHi;
  final String whatsappChannelUrl;
  final String youtubeUrl;
  final String telegramUrl;
  final String instagramUrl;
  final String xUrl;
  final String currencyCode;
  final String currencySymbol;
  final String timezone;
  final String dateFormat;
  final List<MultilingualParagraphEntity> aboutUs;
  final List<MultilingualParagraphEntity> instituteIntroduction;
  final List<MultilingualParagraphEntity> founderMessage;
  final List<MultilingualParagraphEntity> studentRules;
  final List<MultilingualParagraphEntity> parentRules;
  final List<MultilingualParagraphEntity> staffRules;
  final List<MultilingualParagraphEntity> privacyPolicy;

  @override
  List<Object?> get props => [
        id,
        nameEn,
        nameUr,
        nameHi,
        taglineEn,
        taglineUr,
        taglineHi,
        quotesMain,
        quotesTranslation,
        quotesUr,
        quotesAr,
        instituteType,
        affiliationNumber,
        logoUrl,
        bannerUrl,
        contactPhones,
        contactEmail,
        websiteUrl,
        whatsappNumber,
        addressEn,
        addressUr,
        addressHi,
        whatsappChannelUrl,
        youtubeUrl,
        telegramUrl,
        instagramUrl,
        xUrl,
        currencyCode,
        currencySymbol,
        timezone,
        dateFormat,
        aboutUs,
        instituteIntroduction,
        founderMessage,
        studentRules,
        parentRules,
        staffRules,
        privacyPolicy,
      ];
}
