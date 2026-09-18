import 'package:flutter/foundation.dart';

/// Pass status governing whether a visitor may enter campus.
enum VisitorPassStatus {
  active,
  exhausted,
  expired,
  blocked,
}

/// Immutable record of a single deducted visit on this pass.
@immutable
class VisitorLogEntry {
  const VisitorLogEntry({
    required this.id,
    required this.timestamp,
    required this.deductedBy,
    required this.gateLocation,
    required this.visitNumber,
    this.remarks,
  });

  final String id;
  final DateTime timestamp;
  final String deductedBy;
  final String gateLocation;
  final int visitNumber;
  final String? remarks;

  VisitorLogEntry copyWith({
    String? id,
    DateTime? timestamp,
    String? deductedBy,
    String? gateLocation,
    int? visitNumber,
    String? remarks,
  }) {
    return VisitorLogEntry(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      deductedBy: deductedBy ?? this.deductedBy,
      gateLocation: gateLocation ?? this.gateLocation,
      visitNumber: visitNumber ?? this.visitNumber,
      remarks: remarks ?? this.remarks,
    );
  }
}

/// Production Entity representing a Student Visitor / Mulaqat Pass.
@immutable
class VisitorPassEntity {
  const VisitorPassEntity({
    required this.cardId,
    required this.cardNumber,
    required this.visitorName,
    required this.visitorPhone,
    required this.relation,
    required this.cnicOrId,
    required this.studentId,
    required this.studentName,
    required this.studentRollNo,
    required this.studentClass,
    required this.hostelRoom,
    required this.totalAllowedVisits,
    required this.usedVisits,
    required this.remainingVisits,
    required this.status,
    this.avatarUrl,
    this.lastVisitedAt,
    this.visitLogs = const [],
  });

  final String cardId;
  final String cardNumber;
  final String visitorName;
  final String visitorPhone;
  final String relation; // 'father', 'mother', 'brother', 'guardian', 'uncle'
  final String cnicOrId;
  final String? avatarUrl;

  // Linked Student Identity
  final String studentId;
  final String studentName;
  final String studentRollNo;
  final String studentClass;
  final String hostelRoom;

  // Quota Architecture
  final int totalAllowedVisits;
  final int usedVisits;
  final int remainingVisits;
  final VisitorPassStatus status;
  final DateTime? lastVisitedAt;
  final List<VisitorLogEntry> visitLogs;

  bool get canDeductVisit => remainingVisits > 0 && status == VisitorPassStatus.active;

  VisitorPassEntity copyWith({
    String? cardId,
    String? cardNumber,
    String? visitorName,
    String? visitorPhone,
    String? relation,
    String? cnicOrId,
    String? avatarUrl,
    String? studentId,
    String? studentName,
    String? studentRollNo,
    String? studentClass,
    String? hostelRoom,
    int? totalAllowedVisits,
    int? usedVisits,
    int? remainingVisits,
    VisitorPassStatus? status,
    DateTime? lastVisitedAt,
    List<VisitorLogEntry>? visitLogs,
  }) {
    return VisitorPassEntity(
      cardId: cardId ?? this.cardId,
      cardNumber: cardNumber ?? this.cardNumber,
      visitorName: visitorName ?? this.visitorName,
      visitorPhone: visitorPhone ?? this.visitorPhone,
      relation: relation ?? this.relation,
      cnicOrId: cnicOrId ?? this.cnicOrId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentRollNo: studentRollNo ?? this.studentRollNo,
      studentClass: studentClass ?? this.studentClass,
      hostelRoom: hostelRoom ?? this.hostelRoom,
      totalAllowedVisits: totalAllowedVisits ?? this.totalAllowedVisits,
      usedVisits: usedVisits ?? this.usedVisits,
      remainingVisits: remainingVisits ?? this.remainingVisits,
      status: status ?? this.status,
      lastVisitedAt: lastVisitedAt ?? this.lastVisitedAt,
      visitLogs: visitLogs ?? this.visitLogs,
    );
  }
}
