import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';

class DeleteNetworkDialog extends StatelessWidget {
  const DeleteNetworkDialog({
    super.key,
    required this.routerLabel,
    required this.onConfirm,
  });

  final String routerLabel;
  final VoidCallback onConfirm;

  static Future<void> show(
    BuildContext context, {
    required String routerLabel,
    required VoidCallback onConfirm,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => DeleteNetworkDialog(
        routerLabel: routerLabel,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: AppColors.rosePrimary.withValues(alpha: isDark ? 0.4 : 0.25),
          width: 1,
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.rosePrimary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.delete_forever_rounded,
              color: AppColors.rosePrimary,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'REMOVE ROUTER?',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isDark ? Colors.white : AppColors.charcoalDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Are you sure you want to remove "$routerLabel"? Devices connected to this router will no longer be considered on campus.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? Colors.white70 : AppColors.charcoalDark,
                    side: BorderSide(
                      color: isDark ? Colors.white24 : Colors.black12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onConfirm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.rosePrimary,
                    foregroundColor: Colors.white,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
