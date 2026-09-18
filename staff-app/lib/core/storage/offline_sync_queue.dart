import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:staff_app/config/app_config.dart';
import 'package:staff_app/core/storage/hive_service.dart';
import 'package:staff_app/core/storage/sync_queue_item.dart';
import 'package:staff_app/core/utils/app_logger.dart';
import 'package:uuid/uuid.dart';

/// Classroom Resilience Engine (staffRULES.md Rule 5).
/// Persistent encrypted queue with exponential backoff, jitter, and Dead-Letter Queue (DLQ).
class OfflineSyncQueue {
  OfflineSyncQueue(this._hiveService) {
    _updatePendingCount();
  }

  final HiveService _hiveService;
  final ValueNotifier<int> pendingCountNotifier = ValueNotifier<int>(0);

  void _updatePendingCount() {
    try {
      final items = getPendingItems();
      pendingCountNotifier.value = items.length;
    } catch (_) {
      pendingCountNotifier.value = 0;
    }
  }

  /// Enqueues a mutating operation with a unique idempotency key.
  Future<void> enqueue({
    required String endpoint,
    required String method,
    required Map<String, dynamic> payload,
    String? idempotencyKey,
  }) async {
    final item = SyncQueueItem(
      id: const Uuid().v4(),
      idempotencyKey: idempotencyKey ?? const Uuid().v4(),
      endpoint: endpoint,
      method: method,
      payload: payload,
      createdAt: DateTime.now().toUtc().toIso8601String(),
    );

    await _hiveService.syncQueueBox.put(item.id, item.toMap());
    _updatePendingCount();
    AppLogger.info('Enqueued offline mutation: ${item.method} ${item.endpoint} (ID: ${item.id})');
  }

  /// Returns all active pending items that are not in Dead-Letter Queue.
  List<SyncQueueItem> getPendingItems() {
    final List<SyncQueueItem> result = [];
    for (final key in _hiveService.syncQueueBox.keys) {
      final raw = _hiveService.syncQueueBox.get(key);
      if (raw is Map) {
        final item = SyncQueueItem.fromMap(raw);
        if (item.status == 'pending') {
          result.add(item);
        }
      }
    }
    return result;
  }

  /// Returns items moved to Dead-Letter Queue after exceeding max retries.
  List<SyncQueueItem> getDlqItems() {
    final List<SyncQueueItem> result = [];
    for (final key in _hiveService.syncQueueBox.keys) {
      final raw = _hiveService.syncQueueBox.get(key);
      if (raw is Map) {
        final item = SyncQueueItem.fromMap(raw);
        if (item.status == 'failed_dlq') {
          result.add(item);
        }
      }
    }
    return result;
  }

  /// Removes an item upon successful sync confirmation.
  Future<void> markSuccess(String id) async {
    await _hiveService.syncQueueBox.delete(id);
    _updatePendingCount();
    AppLogger.info('Successfully synchronized and pruned queue item: $id');
  }

  /// Records a failure. Increments retry count and moves to DLQ if max retries exceeded.
  Future<void> recordFailure(String id, String errorMessage) async {
    final raw = _hiveService.syncQueueBox.get(id);
    if (raw is! Map) return;

    final item = SyncQueueItem.fromMap(raw);
    final newRetryCount = item.retryCount + 1;
    final isDlq = newRetryCount >= AppConfig.maxOfflineSyncRetries;

    final updated = item.copyWith(
      retryCount: newRetryCount,
      status: isDlq ? 'failed_dlq' : 'pending',
      lastAttemptAt: DateTime.now().toUtc().toIso8601String(),
      lastError: errorMessage,
    );

    await _hiveService.syncQueueBox.put(id, updated.toMap());
    _updatePendingCount();

    if (isDlq) {
      AppLogger.warn('Sync item $id exceeded max retries ($newRetryCount). Moved to Dead-Letter Queue.');
    } else {
      AppLogger.info('Sync item $id retry updated ($newRetryCount/${AppConfig.maxOfflineSyncRetries})');
    }
  }

  /// Computes exponential backoff delay with randomized jitter.
  Duration calculateNextBackoff(int retryCount) {
    // 2^retryCount seconds + jitter (0 - 500ms)
    final baseSeconds = pow(2, retryCount).toInt();
    final jitterMs = Random().nextInt(500);
    return Duration(seconds: baseSeconds) + Duration(milliseconds: jitterMs);
  }
}
