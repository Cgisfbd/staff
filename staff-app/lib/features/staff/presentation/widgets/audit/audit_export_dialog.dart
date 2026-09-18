import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:staff_app/core/di/injection_container.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/staff/data/datasources/audit_trail_remote_datasource.dart';
import 'package:staff_app/features/staff/data/models/audit_log_model.dart';

/// Executive Export Dialog for System Audit Trail with multi-horizon & custom date filtering.
/// Exclusively dedicated to Excel / CSV forensic exports.
class AuditExportDialog extends StatefulWidget {
  const AuditExportDialog({
    super.key,
    required this.logs,
    required this.timeRange,
    required this.categoryFilter,
    required this.summary,
    this.startDate,
    this.endDate,
  });

  final List<AuditLogModel> logs;
  final String timeRange;
  final String categoryFilter;
  final AuditSummaryModel? summary;
  final DateTime? startDate;
  final DateTime? endDate;

  static void show(
    BuildContext context, {
    required List<AuditLogModel> logs,
    required String timeRange,
    required String categoryFilter,
    required AuditSummaryModel? summary,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AuditExportDialog(
        logs: logs,
        timeRange: timeRange,
        categoryFilter: categoryFilter,
        summary: summary,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  @override
  State<AuditExportDialog> createState() => _AuditExportDialogState();
}

class _AuditExportDialogState extends State<AuditExportDialog> {
  bool _isExportingCsv = false;
  bool _isLoadingScope = false;

  late String _activeTimeRange;
  DateTime? _activeStartDate;
  DateTime? _activeEndDate;
  late List<AuditLogModel> _activeLogs;

  @override
  void initState() {
    super.initState();
    _activeTimeRange = widget.timeRange;
    _activeStartDate = widget.startDate;
    _activeEndDate = widget.endDate;
    _activeLogs = List.from(widget.logs);
  }

  Future<void> _updateScopeRange(String newRange) async {
    setState(() {
      _activeTimeRange = newRange;
      _activeStartDate = null;
      _activeEndDate = null;
      _isLoadingScope = true;
    });
    try {
      final ds = sl<AuditTrailRemoteDataSource>();
      final logs = await ds.getAuditLogs(
        timeRange: newRange,
        category: widget.categoryFilter,
      );
      if (mounted) {
        setState(() {
          _activeLogs = logs;
          _isLoadingScope = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingScope = false);
    }
  }

  Future<void> _pickDialogDateRange(bool isDark) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now.add(const Duration(days: 1)),
      initialDateRange: _activeStartDate != null && _activeEndDate != null
          ? DateTimeRange(start: _activeStartDate!, end: _activeEndDate!)
          : DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.goldPrimary,
              onPrimary: Colors.white,
              surface: isDark ? const Color(0xFF0F172A) : Colors.white,
              onSurface: isDark ? Colors.white : Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _activeTimeRange = 'CUSTOM';
        _activeStartDate = picked.start;
        _activeEndDate = picked.end;
        _isLoadingScope = true;
      });
      try {
        final ds = sl<AuditTrailRemoteDataSource>();
        final logs = await ds.getAuditLogs(
          timeRange: 'CUSTOM',
          category: widget.categoryFilter,
          startDate: picked.start,
          endDate: picked.end,
        );
        if (mounted) {
          setState(() {
            _activeLogs = logs;
            _isLoadingScope = false;
          });
        }
      } catch (_) {
        if (mounted) setState(() => _isLoadingScope = false);
      }
    }
  }

  String _formatScopeTitle() {
    if (_activeTimeRange == 'CUSTOM' && _activeStartDate != null && _activeEndDate != null) {
      return '${DateFormat("dd MMM yyyy").format(_activeStartDate!)} to ${DateFormat("dd MMM yyyy").format(_activeEndDate!)}';
    }
    switch (_activeTimeRange.toUpperCase()) {
      case 'TODAY':
        return 'Today';
      case '3_DAYS':
      case '3DAYS':
        return 'Last 3 Days';
      case '7_DAYS':
      case '7DAYS':
      case 'WEEK':
        return 'Last 7 Days';
      case '10_DAYS':
      case '10DAYS':
        return 'Last 10 Days';
      case '30_DAYS':
      case '30DAYS':
      case 'MONTH':
        return 'Last 30 Days';
      case '6_MONTHS':
      case '6MONTHS':
        return 'Last 6 Months';
      case '1_YEAR':
      case '1YEAR':
        return 'Last 1 Year';
      case 'ALL':
      case 'LIFETIME':
      default:
        return 'Full / All Records';
    }
  }

  /// Generate RFC 4180 CSV with UTF-8 BOM containing all forensic receipt fields
  String _generateCSV() {
    final buffer = StringBuffer();
    // UTF-8 BOM for Microsoft Excel auto-detection
    buffer.write('\uFEFF');

    // Header Row (Full Forensic Receipt Columns)
    buffer.writeln(
      [
        'Audit_ID',
        'Timestamp_IST',
        'Timestamp_UTC',
        'Operator_Name',
        'Operator_Role',
        'Operator_User_ID',
        'Target_Entity_Name',
        'Target_Type',
        'Target_ID',
        'Receipt_Voucher_Number',
        'Category',
        'Action_Executed',
        'Action_Readable_Name',
        'Previous_Values_Readable',
        'Previous_Values_JSON',
        'New_Applied_Values_Readable',
        'New_Applied_Values_JSON',
        'Client_IP_Address',
        'Client_Device_Name',
        'Client_Platform',
        'App_Version',
        'Session_ID',
        'Previous_Block_Hash',
        'Current_Record_SHA256_Hash',
        'Tamper_Verification_Status',
      ].map((f) => '"$f"').join(','),
    );

    // Data Rows
    for (final l in _activeLogs) {
      final ist = l.timestampIst;
      final tIst = '${ist.day.toString().padLeft(2, '0')}-${ist.month.toString().padLeft(2, '0')}-${ist.year} ${ist.hour.toString().padLeft(2, '0')}:${ist.minute.toString().padLeft(2, '0')}:${ist.second.toString().padLeft(2, '0')}';
      final actionTitle = l.action.replaceAll('_', ' ');

      final oldReadable = _formatValuesReadable(l.oldValues);
      final oldJson = l.oldValues != null ? jsonEncode(l.oldValues) : '';

      final newReadable = _formatValuesReadable(l.newValues);
      final newJson = l.newValues != null ? jsonEncode(l.newValues) : '';

      buffer.writeln([
        l.auditId,
        tIst,
        '${l.timestampUtc.toIso8601String()}Z',
        _sanitizeForCsv(l.actorName),
        l.actorRole,
        l.actorId,
        _sanitizeForCsv(l.targetName),
        l.targetType,
        l.targetId,
        l.receiptNumber ?? '',
        l.category,
        l.action,
        _sanitizeForCsv(actionTitle),
        _sanitizeForCsv(oldReadable),
        _sanitizeForCsv(oldJson),
        _sanitizeForCsv(newReadable),
        _sanitizeForCsv(newJson),
        l.ipAddress ?? 'N/A',
        _sanitizeForCsv(l.deviceName ?? 'N/A'),
        l.platform ?? 'N/A',
        l.appVersion ?? 'N/A',
        l.sessionId ?? 'N/A',
        l.previousHash ?? '0x0000000000000000000000000000000000000000000000000000000000000000',
        l.currentHash ?? '0x0000000000000000000000000000000000000000000000000000000000000000',
        l.integrityVerified ? 'VALID & UNALTERED' : 'UNVERIFIED / FLAGGED',
      ].map((v) => '"$v"').join(','));
    }

    return buffer.toString();
  }

  String _formatValuesReadable(Map<String, dynamic>? values) {
    if (values == null || values.isEmpty) return 'None (Initial State)';
    return values.entries.map((e) => '${e.key}: ${e.value}').join('; ');
  }

  String _sanitizeForCsv(String value) {
    return value.replaceAll('"', '""').replaceAll('\n', ' ').replaceAll('\r', '');
  }

  Future<void> _handleCsvExport() async {
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    setState(() => _isExportingCsv = true);
    try {
      final csvContent = _generateCSV();
      final fileName = 'TaleemOne_System_Audit_${_activeTimeRange}_${DateTime.now().millisecondsSinceEpoch}.csv';

      // 1. Save locally to app documents / cache
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(csvContent, encoding: utf8);

      if (mounted) nav.pop();

      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Excel file for ${_activeLogs.length} records ready! Opening share dialog...',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      // 2. Open native Share Sheet so user can send via WhatsApp, Email, Drive or open in Excel
      try {
        await Printing.sharePdf(
          bytes: Uint8List.fromList(utf8.encode(csvContent)),
          filename: fileName,
          subject: 'TaleemOne ERP System Audit Trail Excel Export',
        );
      } catch (_) {}
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Excel Export error: $e'), backgroundColor: const Color(0xFFE11D48)),
      );
    } finally {
      if (mounted) setState(() => _isExportingCsv = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12, width: 0.8),
      ),
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Grab Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.table_view_rounded, color: Color(0xFF0284C7), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Export Forensic Audit to Excel',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      'Scope: ${_formatScopeTitle()} • ${widget.categoryFilter}',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // SECTION: Scope & Time Horizon Selection
          Text(
            'SELECT EXPORT DATE RANGE',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
            ),
          ),
          const SizedBox(height: 8),

          // Presets Horizontal Scroller
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildScopeChip('ALL', 'All (Full)'),
                _buildScopeChip('TODAY', 'Today'),
                _buildScopeChip('3_DAYS', '3 Days'),
                _buildScopeChip('7_DAYS', '7 Days'),
                _buildScopeChip('10_DAYS', '10 Days'),
                _buildScopeChip('30_DAYS', '30 Days'),
                _buildScopeChip('6_MONTHS', '6 Months'),
                _buildScopeChip('1_YEAR', '1 Year'),
                _buildScopeCustomChip(isDark),
              ],
            ),
          ),

          // Custom Date Range Feedback Badge (if Custom chosen)
          if (_activeTimeRange == 'CUSTOM' && _activeStartDate != null && _activeEndDate != null) ...[
            const SizedBox(height: 7),
            InkWell(
              onTap: () => _pickDialogDateRange(isDark),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.35), width: 0.7),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.edit_calendar_rounded, size: 12, color: Color(0xFF0284C7)),
                    const SizedBox(width: 5),
                    Text(
                      'Dates: ${DateFormat("dd MMM yyyy").format(_activeStartDate!)}  ➔  ${DateFormat("dd MMM yyyy").format(_activeEndDate!)} (Tap to Change)',
                      style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF0284C7)),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 8),

          // Live Scope Status Pill
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF059669).withValues(alpha: 0.3), width: 0.6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isLoadingScope) ...[
                      const SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFF059669)),
                      ),
                      const SizedBox(width: 5),
                    ] else ...[
                      const Icon(Icons.check_circle_outline_rounded, size: 12, color: Color(0xFF059669)),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      'Target Dataset: ${_activeLogs.length} Records ready for Excel',
                      style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF059669)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 0.6),
          const SizedBox(height: 14),

          // PRIMARY ACTION: Generate & Share Excel File
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: InkWell(
                onTap: _isExportingCsv ? null : _handleCsvExport,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.table_view_rounded, size: 22, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Text(
                                  'Download Excel File (.csv)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  '• RFC 4180',
                                  style: TextStyle(fontSize: 9.5, color: Colors.white70, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '25 forensic columns with UTF-8 BOM formatted for Microsoft Excel, Tally & Google Sheets.',
                              style: TextStyle(
                                fontSize: 9.5,
                                color: Colors.white.withValues(alpha: 0.85),
                                height: 1.25,
                              ),
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_isExportingCsv)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      else
                        const Icon(Icons.download_rounded, size: 20, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScopeChip(String key, String label) {
    final isSelected = _activeTimeRange == key;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: () => _updateScopeRange(key),
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Colors.grey.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFF0284C7) : Colors.grey.withValues(alpha: 0.25),
              width: 0.8,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
              color: isSelected ? Colors.white : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScopeCustomChip(bool isDark) {
    final isSelected = _activeTimeRange == 'CUSTOM';
    return InkWell(
      onTap: () => _pickDialogDateRange(isDark),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0284C7).withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF0284C7) : Colors.grey.withValues(alpha: 0.25),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.date_range_rounded,
              size: 12,
              color: isSelected ? const Color(0xFF0284C7) : (isDark ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(width: 4),
            Text(
              'Custom Dates',
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                color: isSelected ? const Color(0xFF0284C7) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
