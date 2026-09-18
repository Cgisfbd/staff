import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/academic_sessions/domain/entities/academic_session_entity.dart';

class SessionFinanceGrid extends StatelessWidget {
  const SessionFinanceGrid({
    super.key,
    required this.stats,
  });

  final SessionFinanceStats stats;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(
            'FINANCIAL CYCLE & LEDGER',
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
              color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildTile(
                context,
                title: 'Fees Recv.',
                value: stats.feesReceived,
                icon: Icons.payments_rounded,
                color: AppColors.emeraldLight,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildTile(
                context,
                title: 'Salary Paid',
                value: stats.salaryPaid,
                icon: Icons.account_balance_wallet_rounded,
                color: AppColors.goldChampagne,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildTile(
                context,
                title: 'Expenses',
                value: stats.expenses,
                icon: Icons.receipt_long_rounded,
                color: AppColors.goldPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildTile(
                context,
                title: stats.isLoss ? 'Net Loss' : 'Net Profit',
                value: stats.profitOrLoss,
                icon: stats.isLoss ? Icons.trending_down_rounded : Icons.trending_up_rounded,
                color: stats.isLoss ? AppColors.rosePrimary : AppColors.emeraldLight,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: (isDark ? Colors.black : Colors.white).withValues(alpha: isDark ? 0.25 : 0.65),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.35 : 0.28),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(icon, size: 9, color: color),
              ),
              const SizedBox(width: 3),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.textLightPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
