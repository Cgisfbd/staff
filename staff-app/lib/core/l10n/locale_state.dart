import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Immutable State for Application Locale, RTL direction, and Typography (< 45 lines).
class LocaleState extends Equatable {
  const LocaleState({
    required this.locale,
    required this.isRtl,
    this.fontFamily,
  });

  final Locale locale;
  final bool isRtl;
  final String? fontFamily;

  String get languageCode => locale.languageCode;

  @override
  List<Object?> get props => [locale, isRtl, fontFamily];
}
