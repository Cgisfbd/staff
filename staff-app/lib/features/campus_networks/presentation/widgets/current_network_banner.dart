import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/campus_networks/domain/entities/campus_network_entity.dart';

class CurrentNetworkBanner extends StatelessWidget {
  const CurrentNetworkBanner({
    super.key,
    required this.isDark,
    this.currentNetwork,
    required this.isDetecting,
    required this.onAutoCaptureRegister,
    required this.onAddManual,
  });

  final bool isDark;
  final CurrentNetworkInfoEntity? currentNetwork;
  final bool isDetecting;
  final VoidCallback onAutoCaptureRegister;
  final VoidCallback onAddManual;

  @override
  Widget build(BuildContext context) {
    final isAuthorized = currentNetwork?.isAuthorized ?? false;
    final clientIp = isDetecting
        ? 'Detecting IP...'
        : (currentNetwork?.clientIp ?? '127.0.0.1');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0x331E293B) : Colors.white).withValues(
          alpha: isDark ? 0.5 : 0.95,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isAuthorized
              ? AppColors.emeraldLight.withValues(alpha: isDark ? 0.4 : 0.35)
              : const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.4 : 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isAuthorized ? AppColors.emeraldLight : const Color(0xFFF59E0B))
                .withValues(alpha: isDark ? 0.12 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Pulse Wi-Fi Sphere
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isAuthorized
                        ? const [Color(0xFF047857), AppColors.emeraldPrimary]
                        : const [Color(0xFFD97706), Color(0xFFF59E0B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: (isAuthorized
                              ? AppColors.emeraldPrimary
                              : const Color(0xFFF59E0B))
                          .withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.wifi_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),

              // Status Header & IP
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'CURRENT CONNECTED NETWORK',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.6,
                                color: isDark
                                    ? AppColors.goldChampagne
                                    : AppColors.goldDark,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: (isAuthorized
                                    ? AppColors.emeraldLight
                                    : const Color(0xFFF59E0B))
                                .withValues(alpha: isDark ? 0.2 : 0.14),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: (isAuthorized
                                      ? AppColors.emeraldLight
                                      : const Color(0xFFF59E0B))
                                  .withValues(alpha: 0.35),
                              width: 0.6,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isAuthorized
                                    ? Icons.check_circle_rounded
                                    : Icons.warning_amber_rounded,
                                size: 9,
                                color: isAuthorized
                                    ? AppColors.emeraldLight
                                    : const Color(0xFFF59E0B),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                isAuthorized ? 'Authorized' : 'Unregistered',
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                  color: isAuthorized
                                      ? AppColors.emeraldLight
                                      : const Color(0xFFF59E0B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'IP: $clientIp',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Courier',
                              color: isDark ? Colors.white : AppColors.charcoalDark,
                            ),
                          ),
                        ),
                        if (currentNetwork?.matchedNetwork != null) ...[
                          const SizedBox(width: 6),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                currentNetwork!.matchedNetwork!.label,
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0284C7),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Action Buttons: Auto-Capture vs Manual Add
          Row(
            children: [
              if (!isAuthorized) ...[
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: ElevatedButton.icon(
                      onPressed: onAutoCaptureRegister,
                      icon: const Icon(Icons.bolt_rounded, size: 16),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Auto-Capture & Register',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emeraldPrimary,
                        foregroundColor: Colors.white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: OutlinedButton.icon(
                    onPressed: onAddManual,
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Add Router Manually',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.white : AppColors.charcoalDark,
                      side: BorderSide(
                        color: isDark ? Colors.white24 : Colors.black12,
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
