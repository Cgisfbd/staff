import 'package:uuid/uuid.dart';

/// Offline mutation item with idempotency and audit metadata.
class SyncQueueItem {
  const SyncQueueItem({
    required this.id,
    required this.idempotencyKey,
    required this.endpoint,
    required this.method,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
    this.status = 'pending',
    this.lastAttemptAt,
    this.lastError,
    this.conflictResolution = 'LAST_WRITE_WINS',
  });

  factory SyncQueueItem.fromMap(Map<dynamic, dynamic> map) {
    return SyncQueueItem(
      id: map['id']?.toString() ?? const Uuid().v4(),
      idempotencyKey: map['idempotencyKey']?.toString() ?? const Uuid().v4(),
      endpoint: map['endpoint']?.toString() ?? '',
      method: map['method']?.toString() ?? 'POST',
      payload: Map<String, dynamic>.from(map['payload'] as Map? ?? {}),
      createdAt: map['createdAt']?.toString() ?? DateTime.now().toUtc().toIso8601String(),
      retryCount: (map['retryCount'] as num?)?.toInt() ?? 0,
      status: map['status']?.toString() ?? 'pending',
      lastAttemptAt: map['lastAttemptAt']?.toString(),
      lastError: map['lastError']?.toString(),
      conflictResolution: map['conflictResolution']?.toString() ?? 'LAST_WRITE_WINS',
    );
  }

  final String id;
  final String idempotencyKey;
  final String endpoint;
  final String method;
  final Map<String, dynamic> payload;
  final String createdAt;
  final int retryCount;
  final String status; // 'pending' | 'failed_dlq'
  final String? lastAttemptAt;
  final String? lastError;
  final String conflictResolution;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idempotencyKey': idempotencyKey,
      'endpoint': endpoint,
      'method': method,
      'payload': payload,
      'createdAt': createdAt,
      'retryCount': retryCount,
      'status': status,
      'lastAttemptAt': lastAttemptAt,
      'lastError': lastError,
      'conflictResolution': conflictResolution,
    };
  }

  SyncQueueItem copyWith({
    int? retryCount,
    String? status,
    String? lastAttemptAt,
    String? lastError,
  }) {
    return SyncQueueItem(
      id: id,
      idempotencyKey: idempotencyKey,
      endpoint: endpoint,
      method: method,
      payload: payload,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
      status: status ?? this.status,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      lastError: lastError ?? this.lastError,
      conflictResolution: conflictResolution,
    );
  }
}
