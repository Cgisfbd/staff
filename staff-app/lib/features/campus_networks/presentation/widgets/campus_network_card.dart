import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/widgets/app_snack_bar.dart';
import 'package:staff_app/features/campus_networks/domain/entities/campus_network_entity.dart';

class CampusNetworkCard extends StatelessWidget {
  const CampusNetworkCard({
    super.key,
    required this.network,
    required this.isDark,
    required this.onToggleStatus,
    required this.onEdit,
    required this.onDelete,
  });

  final CampusNetworkEntity network;
  final bool isDark;
  final ValueChanged<bool> onToggleStatus;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final formattedDate = network.createdAt != null
        ? DateFormat('dd MMM yyyy').format(network.createdAt!)
        : '—';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0x331E293B) : Colors.white).withValues(
          alpha: isDark ? (network.isActive ? 0.45 : 0.25) : (network.isActive ? 0.95 : 0.8),
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: network.isActive
              ? const Color(0xFF0284C7).withValues(alpha: isDark ? 0.35 : 0.25)
              : (isDark ? Colors.white12 : Colors.black12),
          width: 0.9,
        ),
        boxShadow: [
          BoxShadow(
            color: network.isActive
                ? const Color(0xFF0284C7).withValues(alpha: isDark ? 0.10 : 0.05)
                : Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header: Wi-Fi Icon, Label, Location & Active Switch
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: network.isActive
                          ? const [Color(0xFF0284C7), Color(0xFF2563EB)]
                          : const [Color(0xFF64748B), Color(0xFF475569)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.router_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),

                // Label & Location
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        network.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : AppColors.charcoalDark,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 11,
                            color: network.isActive
                                ? const Color(0xFF0284C7)
                                : (isDark ? Colors.white38 : Colors.black38),
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              network.location?.isNotEmpty == true
                                  ? network.location!
                                  : 'General Campus Area',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: isDark
                                    ? AppColors.textDarkMuted
                                    : AppColors.textLightMuted,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 6),

                // Active Switch
                Transform.scale(
                  scale: 0.75,
                  child: Switch.adaptive(
                    value: network.isActive,
                    activeTrackColor: AppColors.emeraldPrimary,
                    onChanged: onToggleStatus,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 2. IP Address & Subnet Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                  width: 0.7,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PUBLIC IP ADDRESS',
                          style: TextStyle(
                            fontSize: 7.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                network.publicIp,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Courier',
                                  color: isDark ? Colors.white : AppColors.charcoalDark,
                                ),
                              ),
                            ),
                            if (network.ipSubnet != null &&
                                network.ipSubnet!.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8B5CF6)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  network.ipSubnet!,
                                  style: const TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'Courier',
                                    color: Color(0xFF8B5CF6),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Copy IP Button
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: network.publicIp));
                      AppSnackBar.showSuccess(
                        context,
                        'IP ${network.publicIp} copied to clipboard',
                      );
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7)
                            .withValues(alpha: isDark ? 0.2 : 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.copy_rounded,
                            size: 11,
                            color: Color(0xFF0284C7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Copy',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? const Color(0xFF38BDF8)
                                  : const Color(0xFF0284C7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 3. Footer: Date & Actions (Edit / Delete)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.event_outlined,
                      size: 11,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Added: $formattedDate',
                      style: TextStyle(
                        fontSize: 9.5,
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    // Edit Button
                    InkWell(
                      onTap: onEdit,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.goldPrimary
                              .withValues(alpha: isDark ? 0.18 : 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.edit_note_rounded,
                              size: 14,
                              color: AppColors.goldPrimary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Edit',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppColors.goldChampagne
                                    : AppColors.goldDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Delete Button
                    InkWell(
                      onTap: onDelete,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: AppColors.rosePrimary
                              .withValues(alpha: isDark ? 0.18 : 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          size: 14,
                          color: AppColors.rosePrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
