import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:staff_app/core/di/injection_container.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/core/widgets/executive_top_header.dart';
import 'package:staff_app/features/menu/data/menu_categories_data.dart';
import 'package:staff_app/features/staff/data/datasources/staff_sub_account_remote_datasource.dart';
import 'package:staff_app/features/staff/data/models/staff_sub_account_model.dart';
import 'package:staff_app/features/staff/domain/entities/teacher_directory_entity.dart';
import 'package:staff_app/features/staff/domain/repositories/teacher_directory_repository.dart';

/// Full-Page Executive Screen for creating and provisioning a new Staff Sub-Account.
/// Strictly enforces that sub-accounts can ONLY be generated for real, verified
/// faculty & staff members from the institutional staff directory.
class CreateSubAccountPage extends StatefulWidget {
  const CreateSubAccountPage({
    super.key,
    this.initialAccount,
  });

  final StaffSubAccountModel? initialAccount;

  @override
  State<CreateSubAccountPage> createState() => _CreateSubAccountPageState();
}

class _CreateSubAccountPageState extends State<CreateSubAccountPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _pinController = TextEditingController();

  String _selectedRole = 'STAFF';
  bool _isSubmitting = false;
  bool _isPasswordVisible = false;

  bool get isEditing => widget.initialAccount != null;

  // Granular permissions state (Configured right at creation time)
  final Map<String, bool> _categoryToggles = {};
  final Map<String, String> _permissions = {};
  final Set<String> _expandedCategoryIds = {};

  // Staff directory state
  List<TeacherDirectoryEntity> _teachers = [];
  List<StaffSubAccountModel> _existingAccounts = [];
  bool _isLoadingStaff = true;
  TeacherDirectoryEntity? _selectedTeacher;

  StaffSubAccountModel? _createdAccount;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final acc = widget.initialAccount!;
      _nameController.text = acc.name;
      _usernameController.text = acc.username;
      _emailController.text = acc.email;
      // In edit mode: keep password & PIN blank so existing DB Argon2/bcrypt hashes remain untouched
      _pinController.clear();
      _passwordController.clear();
      _selectedRole = acc.role;
      _categoryToggles.addAll(acc.categoryToggles);
      _permissions.addAll(acc.permissions);
      if (_categoryToggles.isEmpty) {
        _initializeDefaultPermissions(_selectedRole);
      }
    } else {
      _autoGeneratePassword();
      _autoGeneratePin();
      _initializeDefaultPermissions(_selectedRole);
    }
    if (MenuCategoriesData.categories.isNotEmpty) {
      _expandedCategoryIds.add(MenuCategoriesData.categories.first.id);
    }
    _loadStaffData();
  }

  void _initializeDefaultPermissions(String role) {
    final isRoleAdmin = role == 'ADMIN';
    for (final cat in MenuCategoriesData.categories) {
      if (isRoleAdmin) {
        _categoryToggles[cat.id] = true;
        for (final item in cat.items) {
          _permissions[item.id] = 'edit';
        }
      } else {
        final isRestricted = cat.isSuperAdminOnly || cat.id == 'admin_panel';
        _categoryToggles[cat.id] = !isRestricted;
        for (final item in cat.items) {
          _permissions[item.id] = isRestricted ? 'none' : 'view';
        }
      }
    }
  }

  void _applyPreset(String preset) {
    setState(() {
      for (final cat in MenuCategoriesData.categories) {
        if (preset == 'ADMIN') {
          _categoryToggles[cat.id] = true;
          for (final item in cat.items) {
            _permissions[item.id] = 'edit';
          }
        } else if (preset == 'VIEW_ONLY') {
          final isRestricted = cat.isSuperAdminOnly || cat.id == 'admin_panel';
          _categoryToggles[cat.id] = !isRestricted;
          for (final item in cat.items) {
            _permissions[item.id] = isRestricted ? 'none' : 'view';
          }
        } else if (preset == 'STANDARD') {
          final isRestricted = cat.isSuperAdminOnly || cat.id == 'admin_panel';
          _categoryToggles[cat.id] = !isRestricted;
          for (final item in cat.items) {
            _permissions[item.id] = isRestricted ? 'none' : 'edit';
          }
        } else if (preset == 'MINIMAL') {
          _categoryToggles[cat.id] = false;
          for (final item in cat.items) {
            _permissions[item.id] = 'none';
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _loadStaffData() async {
    try {
      final teachers = await sl<TeacherDirectoryRepository>().getTeachers();
      final accounts = await sl<StaffSubAccountRemoteDataSource>().getSubAccounts();
      if (mounted) {
        setState(() {
          _teachers = teachers;
          _existingAccounts = accounts;
          _isLoadingStaff = false;
          if (isEditing && _selectedTeacher == null) {
            final acc = widget.initialAccount!;
            try {
              _selectedTeacher = teachers.firstWhere(
                (t) =>
                    t.fullNameEn.toLowerCase() == acc.name.toLowerCase() ||
                    (acc.email.isNotEmpty && t.email.toLowerCase() == acc.email.toLowerCase()) ||
                    acc.username.toLowerCase().contains(t.staffCode.toString().toLowerCase()),
              );
            } catch (_) {
              final parsedCode = int.tryParse(acc.username.split('.').last) ?? 101;
              _selectedTeacher = TeacherDirectoryEntity(
                id: acc.id,
                staffCode: parsedCode,
                fullNameEn: acc.name,
                nameUrdu: '',
                fatherNameEn: '',
                fatherNameUr: '',
                dob: '',
                gender: 'MALE',
                phone: '',
                qualification: 'Graduate',
                designation: acc.role == 'ADMIN' ? 'Senior Administrator' : 'Staff Officer',
                department: 'Institutional Staff',
                email: acc.email,
                joiningDate: '',
                status: 'Active',
              );
            }
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingStaff = false;
          if (isEditing && _selectedTeacher == null) {
            final acc = widget.initialAccount!;
            final parsedCode = int.tryParse(acc.username.split('.').last) ?? 101;
            _selectedTeacher = TeacherDirectoryEntity(
              id: acc.id,
              staffCode: parsedCode,
              fullNameEn: acc.name,
              nameUrdu: '',
              fatherNameEn: '',
              fatherNameUr: '',
              dob: '',
              gender: 'MALE',
              phone: '',
              qualification: 'Graduate',
              designation: acc.role == 'ADMIN' ? 'Senior Administrator' : 'Staff Officer',
              department: 'Institutional Staff',
              email: acc.email,
              joiningDate: '',
              status: 'Active',
            );
          }
        });
      }
    }
  }

  /// When an official staff member is selected from the directory
  void _selectTeacher(TeacherDirectoryEntity teacher) {
    setState(() {
      _selectedTeacher = teacher;
      _nameController.text = teacher.fullNameEn;

      // Generate clean professional handle from name and staff code
      final base = teacher.fullNameEn
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]'), '.');
      final clean = base.replaceAll(RegExp(r'\.+'), '.');
      final prefix = clean.length > 10 ? clean.substring(0, 10).replaceAll(RegExp(r'\.$'), '') : clean;
      _usernameController.text = '$prefix.${teacher.staffCode}';

      // Auto-populate email if on record, else suggest domain email
      if (teacher.email.isNotEmpty) {
        _emailController.text = teacher.email.toLowerCase();
      } else {
        _emailController.text = '$prefix.${teacher.staffCode}@taleemone.in';
      }

      // Auto-suggest role based on designation
      final des = teacher.designation.toLowerCase();
      if (des.contains('principal') ||
          des.contains('muhtamim') ||
          des.contains('director') ||
          des.contains('vice') ||
          des.contains('head')) {
        _selectedRole = 'ADMIN';
      } else {
        _selectedRole = 'STAFF';
      }
    });
  }

  String _generateRandomPassword() {
    const chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789!@#%*';
    final rand = Random.secure();
    final pass = List.generate(9, (_) => chars[rand.nextInt(chars.length)]).join();
    return 'Taleem#$pass';
  }

  void _autoGeneratePassword() {
    setState(() {
      _passwordController.text = _generateRandomPassword();
    });
  }

  void _autoGeneratePin() {
    final rand = Random.secure();
    final pin = (100000 + rand.nextInt(900000)).toString();
    setState(() {
      _pinController.text = pin;
    });
  }

  Future<void> _handleSubmit() async {
    // 1. Enforce that an actual staff member must be selected
    if (_selectedTeacher == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Please select an institutional staff member first.',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFE11D48),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      _openStaffPicker(context, Theme.of(context).brightness == Brightness.dark);
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final name = _nameController.text.trim();
    final username = _usernameController.text.trim().toLowerCase();
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();
    final pin = _pinController.text.trim();

    if (isEditing) {
      try {
        final acc = widget.initialAccount!;
        final updated = await sl<StaffSubAccountRemoteDataSource>().updateSubAccount(
          id: acc.id,
          name: name,
          username: username,
          email: email,
          role: _selectedRole,
          password: password.isNotEmpty ? password : null,
          pin: pin.isNotEmpty ? pin : null,
          categoryToggles: _categoryToggles,
          permissions: _permissions,
        );

        if (mounted) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Account & permissions for "$name" updated successfully.',
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
          context.pop(updated);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update account: $e'),
              backgroundColor: const Color(0xFFE11D48),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
      return;
    }

    try {
      final account = await sl<StaffSubAccountRemoteDataSource>().createSubAccount(
        name: name,
        username: username,
        email: email,
        password: password,
        pin: pin,
        role: _selectedRole,
        categoryToggles: _categoryToggles,
        permissions: _permissions,
      );

      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _createdAccount = account;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _copyCredentialsToClipboard() {
    if (_createdAccount == null) return;
    final staffInfo = _selectedTeacher != null
        ? '\nStaff ID: #${_selectedTeacher!.staffCode}\nDesignation: ${_selectedTeacher!.designation}\nDepartment: ${_selectedTeacher!.department}'
        : '';
    final text = '''
*TaleemOne ERP — Staff Sub-Account Credentials*
Institute: TaleemOne Institutional Ecosystem
Operator: ${_createdAccount!.name}$staffInfo
Assigned Role: ${_createdAccount!.role}

Login ID / Username: ${_createdAccount!.username}
Email: ${_createdAccount!.email}
Temporary Password: ${_createdAccount!.temporaryPassword}
Security PIN: ${_createdAccount!.pin}

_Please change your password upon first login._
''';
    Clipboard.setData(ClipboardData(text: text));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Credentials copied to clipboard! Ready to paste in WhatsApp.',
                style: TextStyle(fontWeight: FontWeight.w700),
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

  void _resetFormForAnother() {
    setState(() {
      _createdAccount = null;
      _selectedTeacher = null;
      _nameController.clear();
      _usernameController.clear();
      _emailController.clear();
      _autoGeneratePassword();
      _autoGeneratePin();
    });
  }

  /// Open Searchable Bottom Sheet Picker with all Institutional Faculty & Staff
  void _openStaffPicker(BuildContext context, bool isDark) {
    String search = '';
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          final query = search.trim().toLowerCase();
          final filtered = _teachers.where((t) {
            if (query.isEmpty) return true;
            return t.fullNameEn.toLowerCase().contains(query) ||
                t.nameUrdu.contains(query) ||
                t.staffCode.toString().contains(query) ||
                t.designation.toLowerCase().contains(query) ||
                t.department.toLowerCase().contains(query);
          }).toList();

          return Container(
            height: MediaQuery.of(context).size.height * 0.80,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF131F17) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.black12,
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Faculty / Staff',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Choose verified personnel from institutional directory',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                              ),
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close_rounded, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? Colors.white12 : Colors.black12, width: 0.8),
                    ),
                    child: TextField(
                      autofocus: false,
                      onChanged: (val) => setModalState(() => search = val),
                      style: TextStyle(fontSize: 12.5, color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'Search staff by name, code or designation',
                        hintStyle: TextStyle(fontSize: 11.5, color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                        prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.goldPrimary),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, thickness: 0.6),

                // Staff List
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person_search_rounded, size: 36, color: isDark ? Colors.white24 : Colors.black26),
                              const SizedBox(height: 8),
                              Text(
                                'No matching staff member found',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (itemCtx, i) {
                            final teacher = filtered[i];
                            final isCurrentlySelected = _selectedTeacher?.id == teacher.id;

                            // Check if this teacher already has a provisioned sub-account
                            final existingAccount = _existingAccounts.cast<StaffSubAccountModel?>().firstWhere(
                              (a) =>
                                  a != null &&
                                  (a.name.toLowerCase() == teacher.fullNameEn.toLowerCase() ||
                                      a.username.contains('${teacher.staffCode}')),
                              orElse: () => null,
                            );

                            return InkWell(
                              onTap: () {
                                Navigator.of(ctx).pop();
                                _selectTeacher(teacher);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isCurrentlySelected
                                      ? AppColors.goldPrimary.withValues(alpha: isDark ? 0.2 : 0.12)
                                      : (isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02)),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isCurrentlySelected
                                        ? AppColors.goldPrimary
                                        : (isDark ? Colors.white10 : Colors.black12),
                                    width: isCurrentlySelected ? 1.4 : 0.7,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 19,
                                      backgroundColor: isCurrentlySelected
                                          ? AppColors.goldPrimary
                                          : (isDark ? Colors.white12 : Colors.black12),
                                      child: Text(
                                        teacher.fullNameEn.isNotEmpty ? teacher.fullNameEn[0].toUpperCase() : 'S',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                          color: isCurrentlySelected
                                              ? Colors.white
                                              : (isDark ? Colors.white70 : Colors.black87),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  teacher.fullNameEn,
                                                  style: TextStyle(
                                                    fontSize: 12.5,
                                                    fontWeight: FontWeight.w800,
                                                    color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                                                  ),
                                                  maxLines: 1,
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  '#${teacher.staffCode}',
                                                  style: TextStyle(
                                                    fontSize: 8.5,
                                                    fontWeight: FontWeight.w800,
                                                    color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '${teacher.designation} • ${teacher.department}',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                                  ),
                                                  maxLines: 1,
                                                ),
                                              ),
                                              if (existingAccount != null)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    '@${existingAccount.username}',
                                                    style: const TextStyle(
                                                      fontSize: 8,
                                                      fontWeight: FontWeight.w800,
                                                      color: Color(0xFF0284C7),
                                                    ),
                                                  ),
                                                )
                                              else
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF059669).withValues(alpha: 0.15),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: const Text(
                                                    'READY',
                                                    style: TextStyle(
                                                      fontSize: 8,
                                                      fontWeight: FontWeight.w800,
                                                      color: Color(0xFF059669),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      isCurrentlySelected
                                          ? Icons.check_circle_rounded
                                          : Icons.radio_button_unchecked_rounded,
                                      size: 18,
                                      color: isCurrentlySelected
                                          ? AppColors.goldPrimary
                                          : (isDark ? Colors.white24 : Colors.black26),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AppBackground(
        child: Column(
          children: [
            ExecutiveTopHeader(
              icon: isEditing ? Icons.manage_accounts_rounded : Icons.person_add_alt_1_rounded,
              title: isEditing ? 'Edit Sub-Account & Permissions' : 'Generate Sub-Account',
              subtitle: isEditing
                  ? 'Update institutional credentials and access control for ${widget.initialAccount!.name}'
                  : 'Provision institutional login credentials for staff',
              onIconTap: () => context.pop(_createdAccount),
            ),

            // Scrollable Content
            Expanded(
              child: _createdAccount != null
                  ? _buildSuccessView(isDark)
                  : SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Mandatory Institutional Staff Member Selection Section
                            _buildStaffSelectorSection(isDark),
                            const SizedBox(height: 12),

                            // 2. Role Selection Card
                            _buildGlassSection(
                              isDark: isDark,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.admin_panel_settings_rounded, size: 14, color: AppColors.goldPrimary),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'ASSIGN INSTITUTIONAL ROLE',
                                            style: TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.5,
                                              color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  _buildRoleSelector(isDark),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // 3. Personal & Login Details Card (Auto-populated from Staff Record)
                            _buildGlassSection(
                              isDark: isDark,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.badge_rounded, size: 14, color: AppColors.goldPrimary),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'STAFF DOSSIER & IDENTITY',
                                            style: TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.5,
                                              color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Full Name (Auto-linked from Selected Staff)
                                  _buildTextField(
                                    controller: _nameController,
                                    label: 'Full Name (Official Staff Name)',
                                    hint: _selectedTeacher == null
                                        ? 'Select staff member from above...'
                                        : _selectedTeacher!.fullNameEn,
                                    icon: Icons.person_rounded,
                                    isDark: isDark,
                                    readOnly: _selectedTeacher != null,
                                    suffixIcon: _selectedTeacher != null
                                        ? const Padding(
                                            padding: EdgeInsets.only(right: 10),
                                            child: Icon(Icons.verified_user_rounded, size: 16, color: Color(0xFF059669)),
                                          )
                                        : null,
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) return 'Please select a staff member';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),

                                  // Login Username (Full Width)
                                  _buildTextField(
                                    controller: _usernameController,
                                    label: 'Login Username',
                                    hint: 'e.g. salman.102',
                                    icon: Icons.alternate_email_rounded,
                                    isDark: isDark,
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) return 'Enter username';
                                      if (val.trim().length < 3) return 'Min 3 chars';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),

                                  // Email Address (Full Width)
                                  _buildTextField(
                                    controller: _emailController,
                                    label: 'Email Address',
                                    hint: 'e.g. staff@taleemone.in',
                                    icon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    isDark: isDark,
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) return 'Enter email';
                                      if (!val.contains('@')) return 'Invalid email';
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // 4. Security & Access Credentials Card
                            _buildGlassSection(
                              isDark: isDark,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.lock_rounded, size: 14, color: AppColors.goldPrimary),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            isEditing ? 'SECURITY PASSCODE & PIN (OPTIONAL)' : 'SECURITY PASSCODE & PIN',
                                            style: TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.5,
                                              color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Password Field with Auto-Generate
                                  _buildPasswordField(isDark),
                                  const SizedBox(height: 12),

                                  // PIN Field with Auto-Generate
                                  _buildPinField(isDark),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // 5. Granular Permissions & Capability Matrix Card
                            _buildPermissionsSection(isDark),
                            const SizedBox(height: 20),

                            // Submit Button
                            _buildSubmitButton(isDark),
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

  /// Dedicated Section for choosing which actual faculty / employee to provision
  Widget _buildStaffSelectorSection(bool isDark) {
    return _buildGlassSection(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.groups_rounded, size: 15, color: AppColors.goldPrimary),
              const SizedBox(width: 6),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'INSTITUTIONAL STAFF MEMBER',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                    ),
                  ),
                ),
              ),
              if (_selectedTeacher != null && !isEditing)
                InkWell(
                  onTap: () => _openStaffPicker(context, isDark),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.goldPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.35), width: 0.8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.swap_horiz_rounded, size: 12, color: AppColors.goldPrimary),
                        SizedBox(width: 3),
                        Text(
                          'Change',
                          style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.goldPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          if (_selectedTeacher == null) ...[
            // Main Tap to Pick Button
            InkWell(
              onTap: () => _openStaffPicker(context, isDark),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.08 : 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.35 : 0.28),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: AppColors.goldPrimary.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_search_rounded, color: AppColors.goldPrimary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tap to Select Staff Member',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isLoadingStaff
                                ? 'Loading staff records from database...'
                                : 'Choose from ${_teachers.length} verified institutional personnel',
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.goldPrimary, size: 20),
                  ],
                ),
              ),
            ),
          ] else
            _buildSelectedStaffCard(isDark),
        ],
      ),
    );
  }

  /// Highlighted Card for the Currently Selected Staff Member
  Widget _buildSelectedStaffCard(bool isDark) {
    final t = _selectedTeacher!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF059669).withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.goldPrimary, AppColors.goldDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                t.fullNameEn.isNotEmpty ? t.fullNameEn[0].toUpperCase() : 'S',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        t.fullNameEn,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                          height: 1.25,
                        ),
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF059669).withValues(alpha: 0.35), width: 0.7),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded, size: 10, color: Color(0xFF059669)),
                          SizedBox(width: 3),
                          Text(
                            'VERIFIED STAFF',
                            style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w900, color: Color(0xFF059669)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (t.nameUrdu.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    t.nameUrdu,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: AppColors.goldPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'ID: ${t.staffCode}',
                        style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: AppColors.goldPrimary),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${t.designation} • ${t.department}',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassSection({required bool isDark, required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08),
              width: 0.85,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildRoleSelector(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildRoleCard(
            role: 'STAFF',
            title: 'STAFF (Standard)',
            subtitle: 'Teacher, Clerk, Accountant',
            icon: Icons.badge_outlined,
            color: const Color(0xFF0284C7),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildRoleCard(
            role: 'ADMIN',
            title: 'ADMIN (Senior)',
            subtitle: 'Vice Principal, Naib Nazim',
            icon: Icons.admin_panel_settings_outlined,
            color: AppColors.goldPrimary,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleCard({
    required String role,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    final isSelected = _selectedRole == role;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedRole = role;
          _initializeDefaultPermissions(role);
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: isDark ? 0.2 : 0.12)
              : (isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : (isDark ? Colors.white10 : Colors.black12),
            width: isSelected ? 1.2 : 0.7,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? color : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? color : (isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 9,
                      color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    bool readOnly = false,
    Widget? suffixIcon,
    ValueChanged<String>? onChanged,
    FormFieldValidator<String>? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13.5, color: AppColors.goldPrimary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onChanged: onChanged,
          validator: validator,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 12, color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12, width: 0.8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12, width: 0.8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.goldPrimary, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isEditing ? 'New Password (Optional)' : 'Temporary Password',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
              ),
            ),
            InkWell(
              onTap: _autoGeneratePassword,
              child: Row(
                children: [
                  const Icon(Icons.autorenew_rounded, size: 12, color: AppColors.goldPrimary),
                  const SizedBox(width: 4),
                  Text(
                    isEditing ? 'Auto-Generate' : 'Regenerate',
                    style: const TextStyle(
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
        const SizedBox(height: 5),
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
          ),
          validator: (val) {
            if (!isEditing && (val == null || val.trim().isEmpty)) return 'Please provide password';
            if (val != null && val.trim().isNotEmpty && val.trim().length < 6) return 'Password must be at least 6 chars';
            return null;
          },
          decoration: InputDecoration(
            hintText: isEditing ? 'Leave blank to keep current password' : 'Taleem#Pass123',
            hintStyle: TextStyle(
              fontSize: 11.5,
              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
            ),
            prefixIcon: const Icon(Icons.key_rounded, size: 16, color: AppColors.goldPrimary),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 16,
                color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
              ),
              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
            filled: true,
            fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12, width: 0.8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12, width: 0.8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.goldPrimary, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPinField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isEditing ? 'New 6-Digit PIN (Optional)' : '6-Digit Security PIN',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
              ),
            ),
            InkWell(
              onTap: _autoGeneratePin,
              child: Row(
                children: [
                  const Icon(Icons.autorenew_rounded, size: 12, color: Color(0xFF0284C7)),
                  const SizedBox(width: 4),
                  Text(
                    isEditing ? 'Auto-Generate' : 'Regenerate',
                    style: const TextStyle(
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
        const SizedBox(height: 5),
        TextFormField(
          controller: _pinController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
          ),
          validator: (val) {
            if (!isEditing && (val == null || val.trim().isEmpty)) return 'Please provide 6-digit PIN';
            if (val != null && val.trim().isNotEmpty && val.trim().length != 6) return 'PIN must be exactly 6 digits';
            return null;
          },
          decoration: InputDecoration(
            hintText: isEditing ? 'Leave blank to keep current PIN' : '123456',
            hintStyle: TextStyle(
              fontSize: 11.5,
              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
            ),
            prefixIcon: const Icon(Icons.pin_outlined, size: 16, color: Color(0xFF0284C7)),
            filled: true,
            fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12, width: 0.8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12, width: 0.8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF0284C7), width: 1.2),
            ),
          ),
        ),
      ],
    );
  }

  /// Section 5: Granular Permissions & Capability Matrix
  Widget _buildPermissionsSection(bool isDark) {
    return _buildGlassSection(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.security_rounded, size: 14, color: AppColors.goldPrimary),
                  const SizedBox(width: 6),
                  Text(
                    'GRANULAR PERMISSIONS MATRIX',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.goldPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${_categoryToggles.values.where((v) => v).length} Active',
                  style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: AppColors.goldPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Configure access levels (None, View, Edit) granted upon account creation.',
            style: TextStyle(
              fontSize: 10,
              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
            ),
          ),
          const SizedBox(height: 10),

          // Preset Buttons Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildPresetChip('Standard Staff', 'STANDARD', Icons.shield_outlined, isDark),
                const SizedBox(width: 6),
                _buildPresetChip('Full Edit (Admin)', 'ADMIN', Icons.bolt_rounded, isDark),
                const SizedBox(width: 6),
                _buildPresetChip('View Only', 'VIEW_ONLY', Icons.visibility_outlined, isDark),
                const SizedBox(width: 6),
                _buildPresetChip('Strict Minimal', 'MINIMAL', Icons.lock_outline_rounded, isDark),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Categories & Sub-Items Accordion Cards
          ...MenuCategoriesData.categories.map(
            (cat) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildCategoryCard(cat, isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(String label, String presetKey, IconData icon, bool isDark) {
    return InkWell(
      onTap: () => _applyPreset(presetKey),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isDark ? Colors.white12 : Colors.black12, width: 0.7),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppColors.goldPrimary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(MenuCategory category, bool isDark) {
    final isMasterOn = _categoryToggles[category.id] ?? true;
    final isExpanded = _expandedCategoryIds.contains(category.id);

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? (isMasterOn ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.15))
            : (isMasterOn ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.02)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMasterOn
              ? (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08))
              : const Color(0xFFE11D48).withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedCategoryIds.remove(category.id);
                } else {
                  _expandedCategoryIds.add(category.id);
                }
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    category.icon,
                    size: 16,
                    color: isMasterOn
                        ? (isDark ? AppColors.goldChampagne : AppColors.goldDark)
                        : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          category.title,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: isMasterOn
                                ? (isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary)
                                : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          isMasterOn ? '${category.items.length} Sub-modules' : 'Disabled from Rail',
                          style: TextStyle(
                            fontSize: 9,
                            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Transform.scale(
                    scale: 0.7,
                    child: Switch.adaptive(
                      value: isMasterOn,
                      activeTrackColor: AppColors.goldPrimary,
                      onChanged: (val) {
                        setState(() {
                          _categoryToggles[category.id] = val;
                        });
                      },
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded && isMasterOn) ...[
            const Divider(height: 1, thickness: 0.5),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              itemCount: category.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 5),
              itemBuilder: (context, idx) {
                final subItem = category.items[idx];
                final currentLevel = _permissions[subItem.id] ?? 'none';
                return _buildSubItemRow(subItem, currentLevel, isDark);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubItemRow(MenuSubItem subItem, String currentLevel, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.015),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(subItem.icon, size: 13, color: isDark ? AppColors.goldChampagne : AppColors.goldDark),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  subItem.title,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: _buildTriStatePill(
                  label: 'None',
                  level: 'none',
                  current: currentLevel,
                  activeColor: const Color(0xFFE11D48),
                  isDark: isDark,
                  onTap: () => setState(() => _permissions[subItem.id] = 'none'),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildTriStatePill(
                  label: 'View',
                  level: 'view',
                  current: currentLevel,
                  activeColor: const Color(0xFF0284C7),
                  isDark: isDark,
                  onTap: () => setState(() => _permissions[subItem.id] = 'view'),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildTriStatePill(
                  label: 'Edit',
                  level: 'edit',
                  current: currentLevel,
                  activeColor: const Color(0xFF059669),
                  isDark: isDark,
                  onTap: () => setState(() => _permissions[subItem.id] = 'edit'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTriStatePill({
    required String label,
    required String level,
    required String current,
    required Color activeColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final isSelected = current == level;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: isDark ? 0.25 : 0.18)
              : (isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02)),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? activeColor : (isDark ? Colors.white10 : Colors.black12),
            width: isSelected ? 1 : 0.6,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              color: isSelected ? activeColor : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: InkWell(
        onTap: _isSubmitting ? null : _handleSubmit,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.goldPrimary, AppColors.goldDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.goldPrimary.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isEditing ? Icons.save_rounded : Icons.lock_person_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isEditing ? 'Save Changes & Update Permissions' : 'Generate & Provision Sub-Account',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  /// Full-Page Post-Creation Success View with WhatsApp Sharing
  Widget _buildSuccessView(bool isDark) {
    final acc = _createdAccount!;
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF059669).withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF059669).withValues(alpha: 0.4), width: 1.5),
            ),
            child: const Icon(Icons.verified_rounded, color: Color(0xFF059669), size: 44),
          ),
          const SizedBox(height: 16),
          Text(
            'Sub-Account Generated!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Institutional login credentials provisioned for ${acc.name}.',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Credentials Card
          _buildGlassSection(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCredRow('Official Name', acc.name, isDark),
                const Divider(height: 14, thickness: 0.6),
                _buildCredRow('Username / Login ID', '@${acc.username}', isDark),
                const Divider(height: 14, thickness: 0.6),
                _buildCredRow('Official Email', acc.email, isDark),
                const Divider(height: 14, thickness: 0.6),
                _buildCredRow('Temporary Password', acc.temporaryPassword ?? '—', isDark),
                const Divider(height: 14, thickness: 0.6),
                _buildCredRow('Security PIN', acc.pin, isDark),
                const Divider(height: 14, thickness: 0.6),
                _buildCredRow('Assigned Role', acc.role, isDark),
                const Divider(height: 14, thickness: 0.6),
                _buildCredRow(
                  'Access Permissions',
                  '${acc.categoryToggles.values.where((v) => v).length} Modules Provisioned',
                  isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // WhatsApp Copy / Share Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: InkWell(
              onTap: _copyCredentialsToClipboard,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF25D366).withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.content_copy_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Copy Credentials for WhatsApp',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Done & Return Button
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetFormForAnother,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    side: BorderSide(
                      color: isDark ? Colors.white24 : Colors.black26,
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    'Generate Another',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.pop(acc),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'Done / Return',
                    style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCredRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
          ),
        ),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
