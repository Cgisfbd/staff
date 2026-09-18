import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:staff_app/core/di/injection_container.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/core/widgets/executive_top_header.dart';
import 'package:staff_app/features/staff/data/datasources/audit_trail_remote_datasource.dart';
import 'package:staff_app/features/staff/data/models/audit_log_model.dart';
import 'package:staff_app/features/staff/presentation/widgets/audit/audit_export_dialog.dart';

/// Master Executive Screen for System Audit Trail (Institutional Forensic Logbook).
/// Answers the 7 Core Forensic Questions:
/// 1. WHO — Operator identity and role
/// 2. WHOSE RECORD — Target Student, Staff or Receipt
/// 3. WHAT — Action executed
/// 4. WHAT CHANGED — Precise old values vs new values diff
/// 5. WHEN — Exact timestamp (UTC & Asia/Kolkata IST)
/// 6. WHERE/FROM — IP address, Device, Platform & Session
/// 7. INTEGRITY — Cryptographic hash chain & verification seal
/// Strictly Read-Only (Tamper-Evident).
class SystemAuditTrailPage extends StatefulWidget {
  const SystemAuditTrailPage({super.key});

  @override
  State<SystemAuditTrailPage> createState() => _SystemAuditTrailPageState();
}

class _SystemAuditTrailPageState extends State<SystemAuditTrailPage> {
  final _searchController = TextEditingController();

  String _selectedTimeRange = 'TODAY'; // 'TODAY' | '3_DAYS' | '7_DAYS' | '10_DAYS' | '30_DAYS' | '6_MONTHS' | '1_YEAR' | 'LIFETIME' | 'CUSTOM'
  String _selectedCategory = 'ALL';    // 'ALL' | 'FINANCE' | 'STUDENTS' | 'ATTENDANCE' | 'SECURITY' | 'EXAMS'
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  bool _isLoading = true;
  List<AuditLogModel> _logs = [];
  AuditSummaryModel? _summary;

  @override
  void initState() {
    super.initState();
    _loadAuditData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAuditData() async {
    setState(() => _isLoading = true);
    try {
      final ds = sl<AuditTrailRemoteDataSource>();
      final summary = await ds.getAuditSummary();
      final items = await ds.getAuditLogs(
        timeRange: _selectedTimeRange,
        category: _selectedCategory,
        searchQuery: _searchController.text.trim(),
        startDate: _customStartDate,
        endDate: _customEndDate,
      );

      if (mounted) {
        setState(() {
          _summary = summary;
          _logs = items;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onTimeRangeChanged(String newRange) {
    if (_selectedTimeRange == newRange && newRange != 'CUSTOM') return;
    HapticFeedback.selectionClick();
    setState(() {
      _selectedTimeRange = newRange;
      if (newRange != 'CUSTOM') {
        _customStartDate = null;
        _customEndDate = null;
      }
    });
    _loadAuditData();
  }

  Future<void> _pickCustomDateRange(bool isDark) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now.add(const Duration(days: 1)),
      initialDateRange: _customStartDate != null && _customEndDate != null
          ? DateTimeRange(start: _customStartDate!, end: _customEndDate!)
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
      await HapticFeedback.selectionClick();
      setState(() {
        _selectedTimeRange = 'CUSTOM';
        _customStartDate = picked.start;
        _customEndDate = picked.end;
      });
      await _loadAuditData();
    }
  }

  void _onCategoryTapped(String cat) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedCategory == cat) {
        _selectedCategory = 'ALL';
      } else {
        _selectedCategory = cat;
      }
    });
    _loadAuditData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AppBackground(
        child: Column(
          children: [
            // Executive Header
            ExecutiveTopHeader(
              icon: Icons.history_edu_rounded,
              title: 'System Audit Trail',
              subtitle: 'Forensic institutional logbook & tamper-evident record',
              onIconTap: () => context.pop(),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => AuditExportDialog.show(
                        context,
                        logs: _logs,
                        timeRange: _selectedTimeRange,
                        categoryFilter: _selectedCategory,
                        summary: _summary,
                        startDate: _customStartDate,
                        endDate: _customEndDate,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.goldPrimary, AppColors.goldDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.goldPrimary.withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.download_rounded, size: 12, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'EXPORT',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.4,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF059669).withValues(alpha: 0.4), width: 0.8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_user_rounded, size: 12, color: Color(0xFF059669)),
                        SizedBox(width: 3),
                        Text(
                          'SEALED',
                          style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Color(0xFF059669)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Main Scrollable Body
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadAuditData,
                color: AppColors.goldPrimary,
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // LEVEL 1: Time Horizon Tabs (Today | This Week | Lifetime)
                      _buildTimeHorizonSelector(isDark),
                      const SizedBox(height: 12),

                      // LEVEL 2: Category Breakdown Mini-Cards
                      _buildCategoryDeck(isDark),
                      const SizedBox(height: 14),

                      // LEVEL 3: Search Bar & Forensic Register Feed
                      _buildSearchAndFilterBar(isDark),
                      const SizedBox(height: 12),

                      // Activity Feed Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.list_alt_rounded, size: 14, color: AppColors.goldPrimary),
                              const SizedBox(width: 6),
                              Text(
                                'FORENSIC AUDIT REGISTER',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                  color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () => AuditExportDialog.show(
                                  context,
                                  logs: _logs,
                                  timeRange: _selectedTimeRange,
                                  categoryFilter: _selectedCategory,
                                  summary: _summary,
                                  startDate: _customStartDate,
                                  endDate: _customEndDate,
                                ),
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                  decoration: BoxDecoration(
                                    color: AppColors.goldPrimary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: AppColors.goldPrimary.withValues(alpha: 0.35),
                                      width: 0.6,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.table_view_rounded,
                                        size: 11,
                                        color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        'Excel (.csv)',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${_logs.length} Records',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Audit Records List or Empty / Loading State
                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: CircularProgressIndicator(color: AppColors.goldPrimary, strokeWidth: 2),
                          ),
                        )
                      else if (_logs.isEmpty)
                        _buildEmptyState(isDark)
                      else
                        ..._logs.map((log) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _buildAuditRecordCard(log, isDark),
                            )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// LEVEL 1: Time Horizon Selector (Today | This Week | Lifetime)
  /// LEVEL 1: Time Horizon & Date Range Selector
  Widget _buildTimeHorizonSelector(bool isDark) {
    final ranges = [
      {'key': 'TODAY', 'title': 'Today'},
      {'key': '3_DAYS', 'title': '3 Days'},
      {'key': '7_DAYS', 'title': '7 Days'},
      {'key': '10_DAYS', 'title': '10 Days'},
      {'key': '30_DAYS', 'title': '30 Days'},
      {'key': '6_MONTHS', 'title': '6 Months'},
      {'key': '1_YEAR', 'title': '1 Year'},
      {'key': 'LIFETIME', 'title': 'Full / All'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 35,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              ...ranges.map((r) {
                final isSelected = _selectedTimeRange == r['key'];
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                    onTap: () => _onTimeRangeChanged(r['key']!),
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [AppColors.goldPrimary, AppColors.goldDark],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: isSelected
                            ? null
                            : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.goldPrimary
                              : (isDark ? Colors.white12 : Colors.black12),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        r['title']!,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                        ),
                      ),
                    ),
                  ),
                );
              }),
              // Custom Date Range Button
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: InkWell(
                  onTap: () => _pickCustomDateRange(isDark),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: _selectedTimeRange == 'CUSTOM'
                          ? AppColors.goldPrimary.withValues(alpha: 0.2)
                          : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04)),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _selectedTimeRange == 'CUSTOM'
                            ? AppColors.goldPrimary
                            : (isDark ? Colors.white12 : Colors.black12),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.date_range_rounded,
                          size: 13,
                          color: _selectedTimeRange == 'CUSTOM' ? AppColors.goldPrimary : (isDark ? Colors.white70 : Colors.black87),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _selectedTimeRange == 'CUSTOM' && _customStartDate != null && _customEndDate != null
                              ? '${DateFormat("dd MMM").format(_customStartDate!)} - ${DateFormat("dd MMM").format(_customEndDate!)}'
                              : 'Custom Dates',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: _selectedTimeRange == 'CUSTOM' ? AppColors.goldPrimary : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_selectedTimeRange == 'CUSTOM' && _customStartDate != null && _customEndDate != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.35), width: 0.7),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_month_rounded, size: 11, color: Color(0xFF0284C7)),
                    const SizedBox(width: 4),
                    Text(
                      '${DateFormat("dd MMM yyyy").format(_customStartDate!)}  ➔  ${DateFormat("dd MMM yyyy").format(_customEndDate!)}',
                      style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF0284C7)),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _selectedTimeRange = 'TODAY';
                          _customStartDate = null;
                          _customEndDate = null;
                        });
                        _loadAuditData();
                      },
                      child: const Icon(Icons.close_rounded, size: 12, color: Color(0xFF0284C7)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// LEVEL 2: Category Breakdown Mini-Cards Deck
  Widget _buildCategoryDeck(bool isDark) {
    Map<String, int> counts;
    if (_selectedTimeRange == 'TODAY') {
      counts = _summary?.categoryCountsToday ?? {};
    } else if (_selectedTimeRange == 'WEEK') {
      counts = _summary?.categoryCountsWeek ?? {};
    } else {
      counts = _summary?.categoryCountsLifetime ?? {};
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMiniCategoryCard(
                categoryKey: 'FINANCE',
                title: 'Finance & Accounts',
                count: counts['FINANCE'] ?? 0,
                subtitle: _formatCurrencySubtitle(),
                icon: Icons.account_balance_wallet_rounded,
                color: const Color(0xFF059669),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMiniCategoryCard(
                categoryKey: 'STUDENTS',
                title: 'Students & Admis.',
                count: counts['STUDENTS'] ?? 0,
                subtitle: 'Profiles & Records',
                icon: Icons.school_rounded,
                color: const Color(0xFF0284C7),
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildMiniCategoryCard(
                categoryKey: 'ATTENDANCE',
                title: 'Attendance',
                count: counts['ATTENDANCE'] ?? 0,
                subtitle: 'Daily & Batches',
                icon: Icons.fact_check_rounded,
                color: const Color(0xFFD97706),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMiniCategoryCard(
                categoryKey: 'SECURITY',
                title: 'Security & Access',
                count: counts['SECURITY'] ?? 0,
                subtitle: 'PIN/Pass/Blocks',
                icon: Icons.security_rounded,
                color: const Color(0xFFE11D48),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMiniCategoryCard(
                categoryKey: 'EXAMS',
                title: 'Exams & Marks',
                count: counts['EXAMS'] ?? 0,
                subtitle: 'Evaluations',
                icon: Icons.menu_book_rounded,
                color: const Color(0xFF8B5CF6),
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatCurrencySubtitle() {
    double amt;
    if (_selectedTimeRange == 'TODAY') {
      amt = _summary?.totalAmountToday ?? 0;
    } else if (_selectedTimeRange == 'WEEK') {
      amt = _summary?.totalAmountWeek ?? 0;
    } else {
      amt = _summary?.totalAmountLifetime ?? 0;
    }
    if (amt >= 100000) {
      return '₹${(amt / 100000).toStringAsFixed(2)} Lakh';
    } else if (amt > 0) {
      return '₹${amt.toInt()} Total';
    }
    return 'Transactions';
  }

  Widget _buildMiniCategoryCard({
    required String categoryKey,
    required String title,
    required int count,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    final isSelected = _selectedCategory == categoryKey;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: InkWell(
          onTap: () => _onCategoryTapped(categoryKey),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: isDark ? 0.25 : 0.16)
                  : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white.withValues(alpha: 0.75)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? color
                    : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08)),
                width: isSelected ? 1.4 : 0.8,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(icon, size: 13, color: color),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: isSelected ? color : color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          color: isSelected ? Colors.white : color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? color : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Search and Active Filter Indicator Bar
  Widget _buildSearchAndFilterBar(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white12 : Colors.black12, width: 0.8),
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, size: 17, color: AppColors.goldPrimary),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => _loadAuditData(),
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search by operator, student name, receipt # or action...',
                    hintStyle: TextStyle(
                      fontSize: 10.5,
                      color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 9),
                  ),
                ),
              ),
              if (_searchController.text.isNotEmpty)
                InkWell(
                  onTap: () {
                    _searchController.clear();
                    _loadAuditData();
                  },
                  child: const Icon(Icons.close_rounded, size: 16, color: Colors.grey),
                ),
            ],
          ),
        ),
        if (_selectedCategory != 'ALL') ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                'Filter Applied:',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () => _onCategoryTapped('ALL'),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.goldPrimary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.4), width: 0.7),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedCategory,
                        style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: AppColors.goldPrimary),
                      ),
                      const SizedBox(width: 3),
                      const Icon(Icons.close_rounded, size: 10, color: AppColors.goldPrimary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// LEVEL 3: Forensic Audit Record Card (Answers WHO, WHOSE, WHAT, WHAT CHANGED, WHEN, WHERE, INTEGRITY)
  Widget _buildAuditRecordCard(AuditLogModel log, bool isDark) {
    final catColor = _getCategoryColor(log.category);
    final formattedTime = _formatIstTime(log.timestampIst);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08),
              width: 0.85,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Ribbon: Timestamp (IST) + Category Badge + Integrity Seal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded, size: 12, color: isDark ? Colors.white60 : Colors.black54),
                      const SizedBox(width: 4),
                      Text(
                        formattedTime,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Category Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: catColor.withValues(alpha: 0.35), width: 0.7),
                        ),
                        child: Text(
                          log.category,
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: catColor,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Cryptographic Integrity Seal
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: log.integrityVerified
                              ? const Color(0xFF059669).withValues(alpha: 0.14)
                              : const Color(0xFFE11D48).withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              log.integrityVerified ? Icons.lock_outline_rounded : Icons.warning_rounded,
                              size: 10,
                              color: log.integrityVerified ? const Color(0xFF059669) : const Color(0xFFE11D48),
                            ),
                            const SizedBox(width: 2.5),
                            Text(
                              log.integrityVerified ? 'VERIFIED' : 'UNVERIFIED',
                              style: TextStyle(
                                fontSize: 7.5,
                                fontWeight: FontWeight.w900,
                                color: log.integrityVerified ? const Color(0xFF059669) : const Color(0xFFE11D48),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 2. Action Title
              Text(
                _formatActionTitle(log.action),
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                ),
              ),
              const SizedBox(height: 6),

              // 3. WHO (Actor) & WHOSE RECORD (Target) Box
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isDark ? Colors.white10 : Colors.black12, width: 0.6),
                ),
                child: Column(
                  children: [
                    // WHO (Kisne kiya)
                    Row(
                      children: [
                        const Icon(Icons.person_rounded, size: 13, color: AppColors.goldPrimary),
                        const SizedBox(width: 5),
                        Text(
                          'Operator: ',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${log.actorName} (${log.actorRole})',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // WHOSE (Kiska record)
                    Row(
                      children: [
                        Icon(Icons.trip_origin_rounded, size: 11, color: catColor),
                        const SizedBox(width: 6),
                        Text(
                          'Target: ',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            log.targetName,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 4. WHAT CHANGED (Diff summary if values present)
              if (log.newValues != null && log.newValues!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: catColor.withValues(alpha: 0.25), width: 0.6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.change_circle_rounded, size: 13, color: catColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _formatDiffSummary(log),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 8),

              // 5. WHERE / FROM (Device, IP & Session) + View Forensic Receipt Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${log.platform ?? "Platform"} • IP: ${log.ipAddress ?? "Internal"}',
                      style: TextStyle(
                        fontSize: 9,
                        color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _showForensicReceiptSheet(log, isDark),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: isDark ? Colors.white12 : Colors.black12, width: 0.7),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Forensic Receipt',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.goldPrimary),
                          ),
                          SizedBox(width: 2),
                          Icon(Icons.chevron_right_rounded, size: 12, color: AppColors.goldPrimary),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Full Forensic Receipt Bottom Sheet Modal displaying hash chains & raw diffs
  void _showForensicReceiptSheet(AuditLogModel log, bool isDark) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.82,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: isDark ? Colors.white12 : Colors.black12, width: 0.8),
        ),
        child: Column(
          children: [
            // Grab Bar
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 10, bottom: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Modal Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF059669), size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Forensic Audit Receipt',
                          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          'Audit ID: #${log.auditId}',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      AuditExportDialog.show(
                        context,
                        logs: [log],
                        timeRange: 'RECORD-${log.auditId}',
                        categoryFilter: log.category,
                        summary: _summary,
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.goldPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.4), width: 0.8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.file_download_outlined, size: 13, color: AppColors.goldPrimary),
                          SizedBox(width: 3),
                          Text(
                            'Export',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.goldPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            const Divider(height: 1, thickness: 0.6),

            // Detailed Forensic Fields (Read-Only)
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // A. Universal Timestamps (UTC & IST)
                    _buildReceiptRow('Timestamp (IST)', _formatIstTime(log.timestampIst), isDark),
                    _buildReceiptRow('Timestamp (UTC)', '${log.timestampUtc.toIso8601String()}Z', isDark),
                    const SizedBox(height: 12),

                    // B. WHO & WHOSE RECORD
                    _buildReceiptRow('Actor / Operator', '${log.actorName} (${log.actorRole})', isDark),
                    _buildReceiptRow('Actor User ID', log.actorId, isDark),
                    _buildReceiptRow('Target Entity', log.targetName, isDark),
                    _buildReceiptRow('Target Type / ID', '${log.targetType} [${log.targetId}]', isDark),
                    if (log.receiptNumber != null)
                      _buildReceiptRow('Receipt / Voucher', log.receiptNumber!, isDark),
                    const SizedBox(height: 12),

                    // C. WHAT CHANGED (Detailed Forensic Diffs)
                    Text(
                      'PRECISE FORENSIC DIFFS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (log.oldValues != null) ...[
                      Text(
                        'Previous Values (Before Change):',
                        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Colors.orange.shade700),
                      ),
                      const SizedBox(height: 2),
                      _buildCodeBox(log.oldValues.toString(), isDark),
                      const SizedBox(height: 8),
                    ],
                    const Text(
                      'New Applied Values (After Change):',
                      style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF059669)),
                    ),
                    const SizedBox(height: 2),
                    _buildCodeBox((log.newValues ?? {}).toString(), isDark),
                    const SizedBox(height: 12),

                    // D. WHERE / FROM (Device, Platform, Network)
                    Text(
                      'ORIGIN & NETWORK FOOTPRINT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildReceiptRow('Client IP Address', log.ipAddress ?? 'N/A', isDark),
                    _buildReceiptRow('Client Device', log.deviceName ?? 'N/A', isDark),
                    _buildReceiptRow('Client Platform', log.platform ?? 'N/A', isDark),
                    _buildReceiptRow('App Version', log.appVersion ?? 'N/A', isDark),
                    _buildReceiptRow('Session ID', log.sessionId ?? 'N/A', isDark),
                    const SizedBox(height: 12),

                    // E. Cryptographic Hash Chain Seal
                    Text(
                      'CRYPTOGRAPHIC INTEGRITY CHAIN',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildReceiptRow('Previous Block Hash', log.previousHash ?? '0x000...000', isDark),
                    _buildReceiptRow('Record Hash (SHA-256)', log.currentHash ?? '0x000...000', isDark),
                    _buildReceiptRow('Tamper Verification', log.integrityVerified ? 'VALID & UNALTERED' : 'FLAGGED', isDark),
                    const SizedBox(height: 16),

                    // Security Seal Footnote
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF059669).withValues(alpha: 0.3), width: 0.8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified_rounded, size: 18, color: Color(0xFF059669)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Immutable Record — Conforms to TaleemOne ERP tamper-evident forensic specifications. Editing or deletion is strictly prohibited.',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF059669)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeBox(String content, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12, width: 0.6),
      ),
      child: Text(
        content,
        style: TextStyle(
          fontSize: 9.5,
          fontFamily: 'monospace',
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36),
        child: Column(
          children: [
            Icon(Icons.content_paste_off_rounded, size: 44, color: isDark ? Colors.white24 : Colors.black26),
            const SizedBox(height: 10),
            Text(
              'No audit records match the selected criteria',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toUpperCase()) {
      case 'FINANCE':
        return const Color(0xFF059669);
      case 'STUDENTS':
        return const Color(0xFF0284C7);
      case 'ATTENDANCE':
        return const Color(0xFFD97706);
      case 'SECURITY':
        return const Color(0xFFE11D48);
      case 'EXAMS':
        return const Color(0xFF8B5CF6);
      default:
        return AppColors.goldPrimary;
    }
  }

  String _formatActionTitle(String action) {
    switch (action) {
      case 'FEE_COLLECTION':
        return '💳 Fee Payment Collected';
      case 'FEE_WAIVER_APPLIED':
        return '🎁 Fee Concession / Waiver Approved';
      case 'STUDENT_PROFILE_UPDATED':
        return '✏️ Student Profile Record Modified';
      case 'STUDENT_ADMISSION_REGISTERED':
        return '🎓 New Student Admission Provisioned';
      case 'STAFF_PIN_RESET':
        return '🔢 Staff Security PIN Force-Reset';
      case 'SUB_ACCOUNT_BLOCKED':
        return '⛔ Sub-Account Access Revoked / Blocked';
      case 'SUB_ACCOUNT_CREATED':
        return '👤 New Sub-Account Provisioned';
      case 'ATTENDANCE_BATCH_SUBMITTED':
        return '📋 Class Attendance Batch Marked';
      case 'MARKS_BATCH_ENTERED':
        return '📚 Quarterly Exam Marks Submitted';
      default:
        return action.replaceAll('_', ' ');
    }
  }

  String _formatDiffSummary(AuditLogModel log) {
    final n = log.newValues ?? {};
    if (log.action == 'FEE_COLLECTION') {
      final amt = n['paidAmount'] ?? 0;
      final mode = n['paymentMode'] ?? 'Cash';
      final rec = (n['receiptNo'] as String?) ?? '';
      return 'Paid: ₹$amt via $mode ${rec.isNotEmpty ? "($rec)" : ""}';
    } else if (log.action == 'FEE_WAIVER_APPLIED') {
      final disc = n['concessionAmount'] ?? 0;
      final reason = n['waiverCategory'] ?? 'Scholar Aid';
      return 'Concession: ₹$disc applied ($reason)';
    } else if (log.action == 'STUDENT_PROFILE_UPDATED') {
      final p = n['guardianPhone'];
      final r = n['hostelRoom'];
      return 'Updated: ${p != null ? "Phone: $p " : ""}${r != null ? "• Room: $r" : ""}';
    } else if (log.action == 'STAFF_PIN_RESET') {
      return '6-Digit PIN rotated with mandatory re-auth on next login';
    } else if (log.action == 'SUB_ACCOUNT_BLOCKED') {
      return 'Account suspended from all login endpoints';
    } else if (log.action == 'ATTENDANCE_BATCH_SUBMITTED') {
      final p = n['presentCount'] ?? 0;
      final a = n['absentCount'] ?? 0;
      return '$p Students Present, $a Absent';
    } else if (log.action == 'MARKS_BATCH_ENTERED') {
      final g = n['gradedCount'] ?? 0;
      final avg = n['averageScore'] ?? 0;
      return '$g Students Graded • Class Avg: $avg%';
    }
    return n.entries.map((e) => '${e.key}: ${e.value}').take(2).join(' • ');
  }

  String _formatIstTime(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final m = months[dt.month - 1];
    final d = dt.day.toString().padLeft(2, '0');
    final y = dt.year;

    int hour = dt.hour;
    final ampm = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    final min = dt.minute.toString().padLeft(2, '0');

    return '$d $m $y, $hour:$min $ampm';
  }
}
