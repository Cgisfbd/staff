import 'package:equatable/equatable.dart';

/// Immutable Data Model representing a Tamper-Evident Institutional Audit Log Entry.
/// Conforms to Executive Institutional Forensic Security Standards:
/// Every record captures: WHO, WHOSE RECORD, WHAT, WHAT CHANGED, WHEN, WHERE/FROM, and INTEGRITY.
class AuditLogModel extends Equatable {
  const AuditLogModel({
    required this.auditId,
    required this.timestampUtc,
    required this.actorId,
    required this.actorName,
    required this.actorRole,
    required this.targetType,
    required this.targetId,
    required this.targetName,
    required this.category,
    required this.action,
    this.oldValues,
    this.newValues,
    this.metadata,
    this.ipAddress,
    this.deviceId,
    this.deviceName,
    this.platform,
    this.appVersion,
    this.sessionId,
    this.previousHash,
    this.currentHash,
    this.receiptNumber,
    this.integrityVerified = true,
  });

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      auditId: json['auditId'] as String? ?? json['id'] as String? ?? '',
      timestampUtc: json['timestampUtc'] != null
          ? DateTime.tryParse(json['timestampUtc'] as String) ?? DateTime.now().toUtc()
          : (json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now().toUtc()
              : DateTime.now().toUtc()),
      actorId: json['actorId'] as String? ?? '',
      actorName: json['actorName'] as String? ?? 'System Operator',
      actorRole: json['actorRole'] as String? ?? 'STAFF',
      targetType: json['targetType'] as String? ?? 'GENERAL',
      targetId: json['targetId'] as String? ?? '',
      targetName: json['targetName'] as String? ?? 'Institutional Record',
      category: (json['category'] as String? ?? 'SYSTEM').toUpperCase(),
      action: json['action'] as String? ?? 'OPERATION',
      oldValues: json['oldValues'] as Map<String, dynamic>?,
      newValues: json['newValues'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      ipAddress: json['ipAddress'] as String?,
      deviceId: json['deviceId'] as String?,
      deviceName: json['deviceName'] as String?,
      platform: json['platform'] as String?,
      appVersion: json['appVersion'] as String?,
      sessionId: json['sessionId'] as String?,
      previousHash: json['previousHash'] as String?,
      currentHash: json['currentHash'] as String?,
      receiptNumber: json['receiptNumber'] as String?,
      integrityVerified: json['integrityVerified'] as bool? ?? true,
    );
  }

  final String auditId;
  final DateTime timestampUtc;

  // Actor (WHO performed the action)
  final String actorId;
  final String actorName;
  final String actorRole;

  // Target (WHOSE record was affected)
  final String targetType; // 'STUDENT' | 'STAFF' | 'FEE_RECEIPT' | 'ATTENDANCE_BATCH' | 'SYSTEM'
  final String targetId;
  final String targetName;

  // Action (WHAT was performed)
  final String category; // 'FINANCE' | 'STUDENTS' | 'ATTENDANCE' | 'SECURITY' | 'EXAMS' | 'SYSTEM'
  final String action;   // e.g. 'FEE_COLLECTION', 'STUDENT_PROFILE_UPDATED', 'PASSWORD_RESET'

  // Forensic Diff (WHAT CHANGED)
  final Map<String, dynamic>? oldValues;
  final Map<String, dynamic>? newValues;

  // Extended Metadata
  final Map<String, dynamic>? metadata;

  // Network & Environment (WHERE / FROM)
  final String? ipAddress;
  final String? deviceId;
  final String? deviceName;
  final String? platform;
  final String? appVersion;
  final String? sessionId;

  // Cryptographic Hash Chain Seal (INTEGRITY)
  final String? previousHash;
  final String? currentHash;

  // Financial Linkage (if applicable)
  final String? receiptNumber;

  // Integrity Verification Status (Computed server-side / verified via HMAC)
  final bool integrityVerified;

  /// Display timestamp converted to IST (Asia/Kolkata) as per Temporal Rule
  DateTime get timestampIst => timestampUtc.toUtc().add(const Duration(hours: 5, minutes: 30));

  AuditLogModel copyWith({
    String? auditId,
    DateTime? timestampUtc,
    String? actorId,
    String? actorName,
    String? actorRole,
    String? targetType,
    String? targetId,
    String? targetName,
    String? category,
    String? action,
    Map<String, dynamic>? oldValues,
    Map<String, dynamic>? newValues,
    Map<String, dynamic>? metadata,
    String? ipAddress,
    String? deviceId,
    String? deviceName,
    String? platform,
    String? appVersion,
    String? sessionId,
    String? previousHash,
    String? currentHash,
    String? receiptNumber,
    bool? integrityVerified,
  }) {
    return AuditLogModel(
      auditId: auditId ?? this.auditId,
      timestampUtc: timestampUtc ?? this.timestampUtc,
      actorId: actorId ?? this.actorId,
      actorName: actorName ?? this.actorName,
      actorRole: actorRole ?? this.actorRole,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      targetName: targetName ?? this.targetName,
      category: category ?? this.category,
      action: action ?? this.action,
      oldValues: oldValues ?? this.oldValues,
      newValues: newValues ?? this.newValues,
      metadata: metadata ?? this.metadata,
      ipAddress: ipAddress ?? this.ipAddress,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      platform: platform ?? this.platform,
      appVersion: appVersion ?? this.appVersion,
      sessionId: sessionId ?? this.sessionId,
      previousHash: previousHash ?? this.previousHash,
      currentHash: currentHash ?? this.currentHash,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      integrityVerified: integrityVerified ?? this.integrityVerified,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'auditId': auditId,
      'timestampUtc': timestampUtc.toIso8601String(),
      'actorId': actorId,
      'actorName': actorName,
      'actorRole': actorRole,
      'targetType': targetType,
      'targetId': targetId,
      'targetName': targetName,
      'category': category,
      'action': action,
      if (oldValues != null) 'oldValues': oldValues,
      if (newValues != null) 'newValues': newValues,
      if (metadata != null) 'metadata': metadata,
      if (ipAddress != null) 'ipAddress': ipAddress,
      if (deviceId != null) 'deviceId': deviceId,
      if (deviceName != null) 'deviceName': deviceName,
      if (platform != null) 'platform': platform,
      if (appVersion != null) 'appVersion': appVersion,
      if (sessionId != null) 'sessionId': sessionId,
      if (previousHash != null) 'previousHash': previousHash,
      if (currentHash != null) 'currentHash': currentHash,
      if (receiptNumber != null) 'receiptNumber': receiptNumber,
      'integrityVerified': integrityVerified,
    };
  }

  @override
  List<Object?> get props => [
        auditId,
        timestampUtc,
        actorId,
        actorName,
        actorRole,
        targetType,
        targetId,
        targetName,
        category,
        action,
        oldValues,
        newValues,
        metadata,
        ipAddress,
        deviceId,
        deviceName,
        platform,
        appVersion,
        sessionId,
        previousHash,
        currentHash,
        receiptNumber,
        integrityVerified,
      ];
}

/// Aggregated metrics summary for the 3 time horizons: Today, This Week, Lifetime
class AuditSummaryModel extends Equatable {
  const AuditSummaryModel({
    required this.totalToday,
    required this.totalWeek,
    required this.totalLifetime,
    required this.categoryCountsToday,
    required this.categoryCountsWeek,
    required this.categoryCountsLifetime,
    required this.totalAmountToday,
    required this.totalAmountWeek,
    required this.totalAmountLifetime,
    required this.verifiedIntegrityCount,
  });

  final int totalToday;
  final int totalWeek;
  final int totalLifetime;

  final Map<String, int> categoryCountsToday;
  final Map<String, int> categoryCountsWeek;
  final Map<String, int> categoryCountsLifetime;

  final double totalAmountToday;
  final double totalAmountWeek;
  final double totalAmountLifetime;

  final int verifiedIntegrityCount;

  @override
  List<Object?> get props => [
        totalToday,
        totalWeek,
        totalLifetime,
        categoryCountsToday,
        categoryCountsWeek,
        categoryCountsLifetime,
        totalAmountToday,
        totalAmountWeek,
        totalAmountLifetime,
        verifiedIntegrityCount,
      ];
}
