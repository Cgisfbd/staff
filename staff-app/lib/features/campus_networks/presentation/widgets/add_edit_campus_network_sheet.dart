import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/widgets/app_snack_bar.dart';
import 'package:staff_app/features/campus_networks/domain/entities/campus_network_entity.dart';

class AddEditCampusNetworkSheet extends StatefulWidget {
  const AddEditCampusNetworkSheet({
    super.key,
    this.networkToEdit,
    this.initialIp,
    required this.isDark,
    required this.onAutoDetectIp,
    required this.onSave,
  });

  final CampusNetworkEntity? networkToEdit;
  final String? initialIp;
  final bool isDark;
  final Future<String> Function() onAutoDetectIp;
  final Future<void> Function({
    required String label,
    required String publicIp,
    String? ipSubnet,
    String? location,
    required bool isActive,
  }) onSave;

  static Future<void> show(
    BuildContext context, {
    CampusNetworkEntity? networkToEdit,
    String? initialIp,
    required bool isDark,
    required Future<String> Function() onAutoDetectIp,
    required Future<void> Function({
      required String label,
      required String publicIp,
      String? ipSubnet,
      String? location,
      required bool isActive,
    }) onSave,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddEditCampusNetworkSheet(
        networkToEdit: networkToEdit,
        initialIp: initialIp,
        isDark: isDark,
        onAutoDetectIp: onAutoDetectIp,
        onSave: onSave,
      ),
    );
  }

  @override
  State<AddEditCampusNetworkSheet> createState() =>
      _AddEditCampusNetworkSheetState();
}

class _AddEditCampusNetworkSheetState extends State<AddEditCampusNetworkSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;
  late final TextEditingController _ipController;
  late final TextEditingController _subnetController;
  late final TextEditingController _locationController;
  late bool _isActive;
  bool _isSaving = false;
  bool _isDetecting = false;

  @override
  void initState() {
    super.initState();
    final edit = widget.networkToEdit;
    _labelController = TextEditingController(text: edit?.label ?? '');
    _ipController = TextEditingController(
      text: edit?.publicIp ?? widget.initialIp ?? '',
    );
    _subnetController = TextEditingController(text: edit?.ipSubnet ?? '');
    _locationController = TextEditingController(text: edit?.location ?? '');
    _isActive = edit?.isActive ?? true;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _ipController.dispose();
    _subnetController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _handleAutoCapture() async {
    setState(() => _isDetecting = true);
    try {
      final ip = await widget.onAutoDetectIp();
      if (mounted) {
        setState(() {
          _ipController.text = ip;
          _isDetecting = false;
        });
        AppSnackBar.showSuccess(context, 'Public IP auto-captured: $ip');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isDetecting = false);
        AppSnackBar.showError(context, 'Could not auto-capture IP');
      }
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      await widget.onSave(
        label: _labelController.text.trim(),
        publicIp: _ipController.text.trim(),
        ipSubnet: _subnetController.text.trim().isNotEmpty
            ? _subnetController.text.trim()
            : null,
        location: _locationController.text.trim().isNotEmpty
            ? _locationController.text.trim()
            : null,
        isActive: _isActive,
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        AppSnackBar.showError(context, 'Error saving router: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final isEditing = widget.networkToEdit != null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.35 : 0.25),
          width: 1,
        ),
      ),
      padding: EdgeInsets.fromLTRB(18, 16, 18, bottomInset + 18),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0284C7), Color(0xFF2563EB)],
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
                      Text(
                        isEditing ? 'EDIT ROUTER' : 'ADD CAMPUS ROUTER',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: isDark ? Colors.white : AppColors.charcoalDark,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    visualDensity: VisualDensity.compact,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 1. Router Label Field
              Text(
                'ROUTER LABEL / NAME *',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                  color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: _labelController,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.charcoalDark,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. Admin Office Main AP',
                  hintStyle: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white30 : Colors.black26,
                  ),
                  prefixIcon: const Icon(Icons.label_outline_rounded, size: 18),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : const Color(0xFFF1F5F9),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a router label';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // 2. Public IP Field + Auto-Capture Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PUBLIC WAN IP ADDRESS *',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                      color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                    ),
                  ),
                  InkWell(
                    onTap: _isDetecting ? null : _handleAutoCapture,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.emeraldPrimary
                            .withValues(alpha: isDark ? 0.2 : 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.emeraldPrimary.withValues(alpha: 0.4),
                          width: 0.7,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isDetecting)
                            const SizedBox(
                              width: 10,
                              height: 10,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: AppColors.emeraldLight,
                              ),
                            )
                          else
                            const Icon(
                              Icons.bolt_rounded,
                              size: 13,
                              color: AppColors.emeraldLight,
                            ),
                          const SizedBox(width: 3),
                          Text(
                            _isDetecting ? 'Detecting...' : '⚡ Auto-Capture',
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.emeraldLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: _ipController,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Courier',
                  color: isDark ? Colors.white : AppColors.charcoalDark,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. 103.145.72.18',
                  hintStyle: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Courier',
                    color: isDark ? Colors.white30 : Colors.black26,
                  ),
                  prefixIcon: const Icon(Icons.language_rounded, size: 18),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : const Color(0xFFF1F5F9),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter or auto-capture public IP';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // 3. Subnet / CIDR (Optional)
              Text(
                'LOCAL SUBNET / CIDR (OPTIONAL)',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                  color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: _subnetController,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Courier',
                  color: isDark ? Colors.white : AppColors.charcoalDark,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. 192.168.1.0/24',
                  hintStyle: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Courier',
                    color: isDark ? Colors.white30 : Colors.black26,
                  ),
                  prefixIcon: const Icon(Icons.device_hub_rounded, size: 18),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : const Color(0xFFF1F5F9),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 4. Location Field (Optional)
              Text(
                'CAMPUS LOCATION (OPTIONAL)',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                  color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: _locationController,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.charcoalDark,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. Academic Block, 2nd Floor',
                  hintStyle: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white30 : Colors.black26,
                  ),
                  prefixIcon: const Icon(Icons.place_outlined, size: 18),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : const Color(0xFFF1F5F9),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // 5. Active Status Switch Tile
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ROUTER STATUS',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                            color: isDark
                                ? AppColors.goldChampagne
                                : AppColors.goldDark,
                          ),
                        ),
                        Text(
                          _isActive ? 'Active & Authorized' : 'Disabled / Standby',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: _isActive
                                ? AppColors.emeraldLight
                                : (isDark ? Colors.white54 : Colors.black45),
                          ),
                        ),
                      ],
                    ),
                    Switch.adaptive(
                      value: _isActive,
                      activeTrackColor: AppColors.emeraldPrimary,
                      onChanged: (val) => setState(() => _isActive = val),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 6. Submit Button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isEditing
                                  ? Icons.save_rounded
                                  : Icons.add_circle_outline_rounded,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isEditing
                                  ? 'SAVE ROUTER DETAILS'
                                  : 'REGISTER CAMPUS ROUTER',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.4,
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
