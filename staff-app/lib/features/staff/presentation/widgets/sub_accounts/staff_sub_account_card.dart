import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:staff_app/core/di/injection_container.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/staff/data/datasources/staff_sub_account_remote_datasource.dart';
import 'package:staff_app/features/staff/data/models/staff_sub_account_model.dart';

/// Translucent Liquid Crystal Card representing a single Staff Sub-Account.
/// Strictly decoupled from permissions matrix. Allows direct Super Admin password & PIN resets.
/// Zero-Overflow Protected (Rule 12 compliant).
class StaffSubAccountCard extends StatelessWidget {
  const StaffSubAccountCard({
    super.key,
    required this.account,
    this.onTap,
    required this.onToggleStatus,
    required this.onAccountUpdated,
  });

  final StaffSubAccountModel account;
  final VoidCallback? onTap;
  final ValueChanged<bool> onToggleStatus;
  final ValueChanged<StaffSubAccountModel> onAccountUpdated;

  static String _generateRandomPassword() {
    const chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789!@#%*';
    final rand = Random.secure();
    final pass = List.generate(9, (_) => chars[rand.nextInt(chars.length)]).join();
    return 'Taleem#$pass';
  }

  static String _generateRandomPin() {
    final rand = Random.secure();
    return (100000 + rand.nextInt(900000)).toString();
  }

  void _showBlockConfirmation(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final willBlock = account.isActive;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              willBlock ? Icons.block_rounded : Icons.check_circle_outline_rounded,
              color: willBlock ? const Color(0xFFE11D48) : const Color(0xFF059669),
              size: 22,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                willBlock ? 'Block Sub-Account?' : 'Activate Sub-Account?',
                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: Text(
          willBlock
              ? 'Are you sure you want to block ${account.name}? The staff member will immediately be logged out and prohibited from logging into TaleemOne ERP.'
              : 'Are you sure you want to activate ${account.name}? Login and assigned institutional access will be restored immediately.',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onToggleStatus(!willBlock);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: willBlock ? const Color(0xFFE11D48) : const Color(0xFF059669),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              willBlock ? 'Yes, Block Account' : 'Yes, Activate Account',
              style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Super Admin Dialog to directly reset Password without needing the old password
  void _showResetPasswordDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final passwordController = TextEditingController(text: _generateRandomPassword());
    bool isPasswordVisible = false;
    bool isSubmitting = false;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.goldPrimary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.lock_reset_rounded, color: AppColors.goldPrimary, size: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Reset Staff Password',
                        style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'Operator: ${account.name} (@${account.username})',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF059669).withValues(alpha: 0.3), width: 0.7),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_user_outlined, size: 14, color: Color(0xFF059669)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Super Admin Authority — No previous password required.',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : const Color(0xFF065F46),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'New Temporary Password',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            passwordController.text = _generateRandomPassword();
                          });
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.autorenew_rounded, size: 12, color: AppColors.goldPrimary),
                            SizedBox(width: 4),
                            Text(
                              'Auto-Generate',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.goldPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: passwordController,
                    obscureText: !isPasswordVisible,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter new password',
                      prefixIcon: const Icon(Icons.key_rounded, size: 16, color: AppColors.goldPrimary),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 16,
                          color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                        ),
                        onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12, width: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting ? null : () => Navigator.of(ctx).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        final newPass = passwordController.text.trim();
                        if (newPass.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password must be at least 6 characters')),
                          );
                          return;
                        }

                        setState(() => isSubmitting = true);
                        try {
                          final updated = await sl<StaffSubAccountRemoteDataSource>().resetPassword(
                            id: account.id,
                            newPassword: newPass,
                          );

                          // Copy to clipboard for WhatsApp
                          final credText = '''
*TaleemOne ERP — Staff Password Reset*
Institute: TaleemOne Institutional Ecosystem
Operator: ${account.name}
Login ID: ${account.username}
New Password: $newPass

_Please login and change your password._
''';
                          await Clipboard.setData(ClipboardData(text: credText));

                          if (context.mounted) {
                            Navigator.of(ctx).pop();
                            onAccountUpdated(updated);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Password reset for ${account.name}! Copied for WhatsApp.',
                                        style: const TextStyle(fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: const Color(0xFF059669),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          }
                        } catch (_) {
                          if (ctx.mounted) {
                            setState(() => isSubmitting = false);
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: isSubmitting
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text(
                        'Reset & Copy Password',
                        style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 12),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Super Admin Dialog to directly reset 6-Digit PIN without needing the old PIN
  void _showResetPinDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pinController = TextEditingController(text: _generateRandomPin());
    bool isSubmitting = false;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.pin_outlined, color: Color(0xFF0284C7), size: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Reset 6-Digit PIN',
                        style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'Operator: ${account.name} (@${account.username})',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.3), width: 0.7),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.security_rounded, size: 14, color: Color(0xFF0284C7)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Super Admin Authority — No previous PIN required.',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : const Color(0xFF075985),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'New 6-Digit Security PIN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            pinController.text = _generateRandomPin();
                          });
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.autorenew_rounded, size: 12, color: Color(0xFF0284C7)),
                            SizedBox(width: 4),
                            Text(
                              'Auto-Generate',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0284C7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: pinController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 6,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '••••••',
                      prefixIcon: const Icon(Icons.password_rounded, size: 16, color: Color(0xFF0284C7)),
                      filled: true,
                      fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12, width: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting ? null : () => Navigator.of(ctx).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        final newPin = pinController.text.trim();
                        if (newPin.length != 6 || int.tryParse(newPin) == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('PIN must be exactly 6 numeric digits')),
                          );
                          return;
                        }

                        setState(() => isSubmitting = true);
                        try {
                          final updated = await sl<StaffSubAccountRemoteDataSource>().resetPin(
                            id: account.id,
                            newPin: newPin,
                          );

                          // Copy to clipboard
                          final pinMsg = '''
*TaleemOne ERP — Staff Security PIN Reset*
Operator: ${account.name}
Username: ${account.username}
New 6-Digit PIN: $newPin
''';
                          await Clipboard.setData(ClipboardData(text: pinMsg));

                          if (context.mounted) {
                            Navigator.of(ctx).pop();
                            onAccountUpdated(updated);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'PIN reset for ${account.name}! Copied for WhatsApp.',
                                        style: const TextStyle(fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: const Color(0xFF059669),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          }
                        } catch (_) {
                          if (ctx.mounted) {
                            setState(() => isSubmitting = false);
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: isSubmitting
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text(
                        'Reset & Copy PIN',
                        style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 12),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = account.isActive ? const Color(0xFF059669) : const Color(0xFFE11D48);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.white.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: account.isActive
                  ? (isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08))
                  : const Color(0xFFE11D48).withValues(alpha: 0.35),
              width: 0.85,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Identity Section: Avatar + Name + Username + Status Pill (Tappable to Edit)
              InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Monogram Avatar with Status Ring
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: account.isAdmin
                                ? [AppColors.goldPrimary, AppColors.goldDark]
                                : (isDark
                                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                                    : [const Color(0xFFE2E8F0), const Color(0xFFCBD5E1)]),
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(color: statusColor, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withValues(alpha: 0.35),
                              blurRadius: 6,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            account.name.isNotEmpty ? account.name[0].toUpperCase() : 'U',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: account.isAdmin ? Colors.white : (isDark ? Colors.white : AppColors.charcoalDark),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 11),

                      // Name, Role & Username (Spacious layout, Zero Truncation)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    account.name,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                                      height: 1.25,
                                    ),
                                    maxLines: 2,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Status Pill & Tap to Edit indicator
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(alpha: 0.14),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: statusColor.withValues(alpha: 0.4), width: 0.8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 5,
                                            height: 5,
                                            decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            account.isActive ? 'ACTIVE' : 'BLOCKED',
                                            style: TextStyle(
                                              fontSize: 8.5,
                                              fontWeight: FontWeight.w900,
                                              color: statusColor,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.edit_note_rounded,
                                          size: 13,
                                          color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          'Tap to edit',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                                          ),
                                        ),
                                        Icon(
                                          Icons.chevron_right_rounded,
                                          size: 12,
                                          color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: account.isAdmin
                                        ? AppColors.goldPrimary.withValues(alpha: 0.15)
                                        : const Color(0xFF0284C7).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    account.role,
                                    style: TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w800,
                                      color: account.isAdmin ? AppColors.goldPrimary : const Color(0xFF0284C7),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '@${account.username}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                                  ),
                                ),
                              ],
                            ),
                            if (account.email.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                account.email,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 0.6),
              const SizedBox(height: 10),

              // Action Buttons: Two spacious rows to eliminate all ellipsis ("...")
              // Row 1: [ 🔑 Reset Password ] & [ 🔢 Reset PIN ]
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _showResetPasswordDialog(context),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.15 : 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.35), width: 0.8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_reset_rounded,
                              size: 15,
                              color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Reset Password',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () => _showResetPinDialog(context),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7).withValues(alpha: isDark ? 0.15 : 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.35), width: 0.8),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.pin_outlined,
                              size: 15,
                              color: Color(0xFF0284C7),
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Reset PIN',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0284C7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),

              // Row 2: Status Toggle Button [ ⛔ Block Sub-Account ] / [ ✅ Activate Sub-Account ]
              InkWell(
                onTap: () => _showBlockConfirmation(context),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 7.5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: statusColor.withValues(alpha: 0.35), width: 0.8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        account.isActive ? Icons.block_rounded : Icons.check_circle_rounded,
                        size: 13,
                        color: statusColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        account.isActive ? 'Block Sub-Account' : 'Activate Sub-Account',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
