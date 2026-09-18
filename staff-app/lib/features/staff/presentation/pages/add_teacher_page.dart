import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/core/widgets/executive_top_header.dart';
import 'package:staff_app/features/staff/domain/entities/teacher_directory_entity.dart';
import 'package:staff_app/features/staff/presentation/widgets/staff_documents_section.dart';
import 'package:staff_app/features/students/presentation/widgets/admission/admission_photo_card.dart';
import 'package:staff_app/features/students/presentation/widgets/admission/admission_section_card.dart';
import 'package:staff_app/features/students/presentation/widgets/admission/admission_text_field.dart';

class _PostOfficeArea {
  const _PostOfficeArea({
    required this.name,
    required this.block,
    required this.district,
    required this.state,
  });

  final String name;
  final String block;
  final String district;
  final String state;
}

/// Ultra-Luxury Screen for Staff & Faculty Onboarding (< 450 lines).
/// Strictly mirrors all fields from the Enterprise Web ERP AddTeacherForm.
class AddTeacherPage extends StatefulWidget {
  const AddTeacherPage({
    super.key,
    this.initialTeacher,
    this.isEditMode = false,
  });

  final TeacherDirectoryEntity? initialTeacher;
  final bool isEditMode;

  @override
  State<AddTeacherPage> createState() => _AddTeacherPageState();
}

class _AddTeacherPageState extends State<AddTeacherPage> {
  // Photo
  String? _photoPath;

  // Controllers — Personal Identity
  final _nameEnController = TextEditingController();
  final _nameUrController = TextEditingController();
  final _fatherEnController = TextEditingController();
  final _fatherUrController = TextEditingController();
  final _dobController = TextEditingController();
  DateTime? _selectedDob;
  String _selectedGender = 'Male';
  final _aadharController = TextEditingController();
  final _rfidController = TextEditingController();

  // Controllers — Contact & Address
  final _phoneController = TextEditingController();
  final _familyPhoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  // Pincode Fast Helper State
  final _pincodeController = TextEditingController();
  bool _isFetchingPincode = false;
  List<_PostOfficeArea> _postOffices = [];
  String? _selectedPostOfficeName;
  String _lastSearchedPincode = '';

  // Submitted Documents State
  final Set<String> _selectedDocs = {};
  final TextEditingController _otherDocController = TextEditingController();

  // Controllers & State — Professional & Academic
  String _selectedQualification = 'Fazilat';
  String _selectedDesignation = 'Senior Ustad';
  final _departmentController = TextEditingController();
  final _experienceController = TextEditingController();
  DateTime _joiningDate = DateTime.now();
  final _joiningDateController = TextEditingController();
  String _dutyMode = 'Hostel Resident';

  // Controllers — Financial & Banking
  final _salaryController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNoController = TextEditingController();
  final _ifscController = TextEditingController();

  // State — Status (Edit Mode)
  String _staffStatus = 'Active';

  // Validation Errors Map
  final Map<String, String> _errors = {};

  static const List<String> kQualifications = [
    'Mufti & Fazilat',
    'Fazilat',
    'Alimiat',
    'Qirat Sab’ah & Hafiz',
    'Hafiz',
    'M.A. Arabic / Islamic Studies',
    'Ph.D. Islamic Studies',
    'B.Ed / M.Ed',
    'Graduate / B.A.',
    'High School / Matric',
  ];

  static const List<String> kDesignations = [
    'Principal / Muhtamim',
    'Vice Principal / Naib Muhtamim',
    'Senior Ustad',
    'Head Qari / Nazim-e-Hifz',
    'Mudarris (Secondary)',
    'Mudarris (Primary)',
    'Nazim-e-Taleem',
    'Accountant / Cashier',
    'Clerk / Office Assistant',
  ];

  @override
  void initState() {
    super.initState();
    _populateFields();
  }

  void _populateFields() {
    final t = widget.initialTeacher;
    if (widget.isEditMode && t != null) {
      _photoPath = t.photoUrl;
      _nameEnController.text = t.fullNameEn;
      _nameUrController.text = t.nameUrdu;
      _fatherEnController.text = t.fatherNameEn;
      _fatherUrController.text = t.fatherNameUr;
      _dobController.text = _formatAnyDate(t.dob);
      _selectedGender = t.gender.isNotEmpty ? t.gender : 'Male';
      _aadharController.text = t.aadharNo;
      _rfidController.text = t.rfidNo;

      _phoneController.text = t.phone;
      _familyPhoneController.text = t.familyPhone;
      _emailController.text = t.email;
      _addressController.text = t.fullAddress;
      _pincodeController.text = t.pincode;

      // Populate Submitted Documents
      _selectedDocs.clear();
      final initialDocs = t.submittedDocs;
      if (initialDocs.isNotEmpty) {
        for (final doc in initialDocs) {
          final lower = doc.toLowerCase();
          if (lower.contains('aadhar') || lower.contains('aadhaar')) {
            _selectedDocs.add('aadharCopy');
          } else if (lower.contains('sanad') || lower.contains('degree')) {
            _selectedDocs.add('sanadDegree');
          } else if (lower.contains('passbook') || lower.contains('bank')) {
            _selectedDocs.add('bankPassbook');
          } else if (lower.contains('exp') || lower.contains('experience')) {
            _selectedDocs.add('expCertificate');
          } else if (lower.contains('photo')) {
            _selectedDocs.add('passportPhotos');
          } else {
            _selectedDocs.add('otherDoc');
            if (_otherDocController.text.isEmpty) {
              _otherDocController.text = doc;
            }
          }
        }
      }

      _selectedQualification = kQualifications.contains(t.qualification)
          ? t.qualification
          : kQualifications.first;
      _selectedDesignation = kDesignations.contains(t.designation)
          ? t.designation
          : kDesignations.first;
      _departmentController.text = t.department;
      _experienceController.text = t.experienceYears > 0 ? t.experienceYears.toString() : '';
      _joiningDateController.text = _formatAnyDate(t.joiningDate);
      _dutyMode = t.dutyMode.isNotEmpty ? t.dutyMode : 'Hostel Resident';

      _salaryController.text = t.monthlySalary > 0 ? t.monthlySalary.toStringAsFixed(0) : '';
      _bankNameController.text = t.bankName;
      _accountNoController.text = t.bankAccountNo;
      _ifscController.text = t.bankIfsc;

      _staffStatus = t.status.isNotEmpty ? t.status : 'Active';
    } else {
      // Default Joining Date = Today, Default DOB = 28 years ago
      final now = DateTime.now();
      _selectedDob = DateTime(now.year - 28, now.month, now.day);
      _dobController.text = DateFormat('dd MMM yyyy').format(_selectedDob!);
      _joiningDateController.text = DateFormat('dd MMM yyyy').format(now);
      _departmentController.text = 'Hadith & Islamic Jurisprudence';
      _experienceController.text = '5';
      _salaryController.text = '32000';

      // Default Standard Documents for New Staff
      _selectedDocs.addAll([
        'aadharCopy',
        'sanadDegree',
        'bankPassbook',
        'passportPhotos',
      ]);
    }
  }

  String _formatAnyDate(String raw) {
    if (raw.trim().isEmpty) return '';
    try {
      final parsed = DateTime.parse(raw);
      return DateFormat('dd MMM yyyy').format(parsed);
    } catch (_) {
      return raw;
    }
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameUrController.dispose();
    _fatherEnController.dispose();
    _fatherUrController.dispose();
    _dobController.dispose();
    _aadharController.dispose();
    _rfidController.dispose();
    _phoneController.dispose();
    _familyPhoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();
    _otherDocController.dispose();
    _departmentController.dispose();
    _experienceController.dispose();
    _joiningDateController.dispose();
    _salaryController.dispose();
    _bankNameController.dispose();
    _accountNoController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(now.year - 28, now.month, now.day),
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year - 18, now.month, now.day),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.goldPrimary,
              primary: AppColors.goldPrimary,
              brightness: Theme.of(context).brightness,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        _dobController.text = DateFormat('dd MMM yyyy').format(picked);
        _errors.remove('dob');
      });
    }
  }

  Future<void> _pickJoiningDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _joiningDate,
      firstDate: DateTime(1990),
      lastDate: DateTime(now.year + 1),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.goldPrimary,
              primary: AppColors.goldPrimary,
              brightness: Theme.of(context).brightness,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _joiningDate = picked;
        _joiningDateController.text = DateFormat('dd MMM yyyy').format(picked);
        _errors.remove('joiningDate');
      });
    }
  }

  void _onPincodeInput(String val) {
    final code = val.trim();
    if (code.length == 6) {
      if (code != _lastSearchedPincode) {
        _lookupPincode(code);
      }
    } else if (code.length < 6 && (_postOffices.isNotEmpty || _lastSearchedPincode.isNotEmpty)) {
      setState(() {
        _postOffices = [];
        _selectedPostOfficeName = null;
        _lastSearchedPincode = '';
      });
    }
  }

  Future<void> _lookupPincode(String code) async {
    final cleanCode = code.trim();
    if (cleanCode.length != 6) return;
    if (_isFetchingPincode) return;

    setState(() {
      _isFetchingPincode = true;
      _lastSearchedPincode = cleanCode;
    });

    try {
      final dio = Dio();
      final response = await dio.get<dynamic>(
        'https://api.postalpincode.in/pincode/$cleanCode',
        options: Options(
          responseType: ResponseType.json,
          receiveTimeout: const Duration(seconds: 8),
          sendTimeout: const Duration(seconds: 8),
        ),
      );

      dynamic data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      if (data is List && data.isNotEmpty) {
        final first = data[0];
        if (first is Map &&
            (first['Status']?.toString().toLowerCase() == 'success') &&
            first['PostOffice'] is List) {
          final rawList = first['PostOffice'] as List;
          final list = rawList.map((item) {
            final m = item as Map<String, dynamic>;
            return _PostOfficeArea(
              name: m['Name']?.toString() ?? '',
              block: (m['Block'] ?? m['Name'])?.toString() ?? '',
              district: m['District']?.toString() ?? '',
              state: m['State']?.toString() ?? '',
            );
          }).where((po) => po.name.isNotEmpty).toList();

          if (mounted && list.isNotEmpty) {
            final po = list.first;
            setState(() {
              _postOffices = list;
              _selectedPostOfficeName = po.name;
              _isFetchingPincode = false;
              _addressController.text =
                  '${po.name}, ${po.block}, ${po.district}, ${po.state} - $cleanCode';
              _errors.remove('address');
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pincode $cleanCode: Address Auto-Filled (${list.length} areas)',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.statusPresent,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
            return;
          }
        }
      }

      if (mounted) {
        setState(() {
          _isFetchingPincode = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pincode $cleanCode not found!'),
            backgroundColor: AppColors.statusAbsent,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isFetchingPincode = false;
        });
      }
    }
  }

  void _onSelectPostOffice(String? name) {
    if (name == null) return;
    final po = _postOffices.firstWhere((p) => p.name == name, orElse: () => _postOffices.first);
    final code = _pincodeController.text.trim();
    setState(() {
      _selectedPostOfficeName = po.name;
      _addressController.text =
          '${po.name}, ${po.block}, ${po.district}, ${po.state}${code.isNotEmpty ? ' - $code' : ''}';
      _errors.remove('address');
    });
  }

  void _toggleDoc(String docId) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedDocs.contains(docId)) {
        _selectedDocs.remove(docId);
      } else {
        _selectedDocs.add(docId);
      }
    });
  }

  bool _validateForm() {
    _errors.clear();
    if (_nameEnController.text.trim().isEmpty) {
      _errors['nameEn'] = 'Faculty full name in English is required';
    }
    if (_nameUrController.text.trim().isEmpty) {
      _errors['nameUr'] = 'Faculty full name in Urdu is required';
    }
    if (_fatherEnController.text.trim().isEmpty) {
      _errors['fatherEn'] = "Father's name in English is required";
    }
    if (_phoneController.text.trim().isEmpty) {
      _errors['phone'] = '10-digit primary phone is required';
    } else if (_phoneController.text.trim().length < 10) {
      _errors['phone'] = 'Phone must be at least 10 digits';
    }
    if (_addressController.text.trim().isEmpty) {
      _errors['address'] = 'Full permanent address is required';
    }
    if (_joiningDateController.text.trim().isEmpty) {
      _errors['joiningDate'] = 'Joining date is required';
    }

    setState(() {});
    return _errors.isEmpty;
  }

  void _submitForm() {
    HapticFeedback.mediumImpact();
    if (!_validateForm()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Please fill all required fields marked with * in red.',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.statusAbsent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final double salary = double.tryParse(_salaryController.text.trim()) ?? 0;
    final int experience = int.tryParse(_experienceController.text.trim()) ?? 0;

    final List<String> submittedDocsList = [
      if (_selectedDocs.contains('aadharCopy')) 'Aadhaar Card Copy',
      if (_selectedDocs.contains('sanadDegree')) 'Sanad / Degree Copy',
      if (_selectedDocs.contains('bankPassbook')) 'Bank Passbook Copy',
      if (_selectedDocs.contains('expCertificate')) 'Experience Certificate',
      if (_selectedDocs.contains('passportPhotos')) '4 Passport Photos',
      if (_selectedDocs.contains('otherDoc'))
        _otherDocController.text.trim().isNotEmpty
            ? _otherDocController.text.trim()
            : 'Other Document',
    ];

    final teacher = TeacherDirectoryEntity(
      id: widget.initialTeacher?.id ?? '',
      staffCode: widget.initialTeacher?.staffCode ?? 101,
      fullNameEn: _nameEnController.text.trim(),
      nameUrdu: _nameUrController.text.trim(),
      fatherNameEn: _fatherEnController.text.trim(),
      fatherNameUr: _fatherUrController.text.trim(),
      dob: _dobController.text.trim(),
      gender: _selectedGender,
      phone: _phoneController.text.trim(),
      familyPhone: _familyPhoneController.text.trim(),
      email: _emailController.text.trim(),
      aadharNo: _aadharController.text.trim(),
      rfidNo: _rfidController.text.trim().isNotEmpty
          ? _rfidController.text.trim()
          : (widget.initialTeacher?.rfidNo ?? 'RF-STF-101'),
      fullAddress: _addressController.text.trim(),
      pincode: _pincodeController.text.trim(),
      submittedDocs: submittedDocsList,
      photoUrl: _photoPath ?? widget.initialTeacher?.photoUrl,
      qualification: _selectedQualification,
      designation: _selectedDesignation,
      department: _departmentController.text.trim(),
      experienceYears: experience,
      joiningDate: _joiningDateController.text.trim(),
      dutyMode: _dutyMode,
      residenceStatus: _dutyMode,
      monthlySalary: salary,
      bankName: _bankNameController.text.trim(),
      bankAccountNo: _accountNoController.text.trim(),
      bankIfsc: _ifscController.text.trim().toUpperCase(),
      status: widget.isEditMode ? _staffStatus : 'Active',
      isActive: widget.isEditMode ? (_staffStatus.toLowerCase() == 'active') : true,
    );

    Navigator.of(context).pop(teacher);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.isEditMode
                    ? 'Faculty record updated for ${teacher.fullNameEn}'
                    : 'Faculty member ${teacher.fullNameEn} registered successfully!',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Executive Top Header
              ExecutiveTopHeader(
                icon: widget.isEditMode ? Icons.edit_note_rounded : Icons.person_add_rounded,
                title: widget.isEditMode ? 'Edit Faculty Record' : 'Teacher & Staff Onboarding',
                subtitle: widget.isEditMode
                    ? 'Update faculty credentials, duties & banking details'
                    : 'New faculty onboarding, identity & academic portfolio',
                onIconTap: () => Navigator.of(context).maybePop(),
              ),

              // Scrollable Form Body
              Expanded(
                child: ListView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
                  children: [
                    // Edit Mode Top Banner
                    if (widget.isEditMode) _buildEditModeBanner(isDark),

                    // Section 1: Faculty Identity & Photo
                    _buildIdentitySection(isDark),

                    // Section 2: Contact & Permanent Address
                    _buildContactSection(isDark),

                    // Section 3: Professional & Academic Allocation
                    _buildAcademicSection(isDark),

                    // Section 4: Financial & Banking
                    _buildBankSection(isDark),

                    // Section 5: Submitted Documents Deposit Section
                    StaffDocumentsSection(
                      selectedDocIds: _selectedDocs,
                      onToggleDoc: _toggleDoc,
                      otherDocController: _otherDocController,
                      sectionNumber: '5',
                    ),

                    // Section 6: Staff Status (Edit Mode Exclusive)
                    if (widget.isEditMode) _buildStatusSection(isDark),

                    const SizedBox(height: 16),

                    // Submit Action Button
                    _buildSubmitButton(isDark),

                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // SECTION 1: IDENTITY & PHOTO
  // -------------------------------------------------------------
  Widget _buildIdentitySection(bool isDark) {
    return AdmissionSectionCard(
      icon: Icons.person_rounded,
      title: '1. Faculty Identity & Photo',
      subtitle: 'Photo, dual script name, DOB, Aadhar & RFID',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdmissionPhotoCard(
            photoPath: _photoPath,
            onPhotoSelected: (p) => setState(() => _photoPath = p),
            onPhotoRemoved: () => setState(() => _photoPath = null),
          ),
          const SizedBox(height: 14),

          AdmissionTextField(
            label: 'Faculty Full Name (English)',
            isRequired: true,
            controller: _nameEnController,
            hint: 'e.g. Mufti Abdul Rahman Qasmi',
            errorText: _errors['nameEn'],
          ),
          const SizedBox(height: 12),

          AdmissionTextField(
            label: 'Faculty Full Name (Urdu)',
            isRequired: true,
            isRtl: true,
            controller: _nameUrController,
            hint: 'مثلاً: مفتی عبد الرحمن قاسمی',
            errorText: _errors['nameUr'],
          ),
          const SizedBox(height: 12),

          AdmissionTextField(
            label: "Father's Name (English)",
            isRequired: true,
            controller: _fatherEnController,
            hint: 'e.g. Maulana Hafizullah',
            errorText: _errors['fatherEn'],
          ),
          const SizedBox(height: 12),

          AdmissionTextField(
            label: "Father's Name (Urdu)",
            isRtl: true,
            controller: _fatherUrController,
            hint: 'مثلاً: مولانا حفیظ اللہ',
          ),
          const SizedBox(height: 12),

          AdmissionTextField(
            label: 'Date of Birth',
            isRequired: true,
            controller: _dobController,
            readOnly: true,
            onTap: _pickDob,
            hint: 'DD MMM YYYY (e.g. 15 Jul 1985)',
            suffixIcon: const Icon(Icons.cake_rounded, size: 16, color: AppColors.goldPrimary),
            errorText: _errors['dob'],
          ),
          const SizedBox(height: 12),

          _buildSegmentRow(
            label: 'Gender',
            options: [('Male', 'Male'), ('Female', 'Female')],
            selectedValue: _selectedGender,
            onSelected: (val) => setState(() => _selectedGender = val),
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          AdmissionTextField(
            label: 'Aadhar Card Number (12 Digits)',
            controller: _aadharController,
            keyboardType: TextInputType.number,
            maxLength: 12,
            hint: '12-digit UIDAI number',
          ),
          const SizedBox(height: 12),

          AdmissionTextField(
            label: 'RFID Smart Card ID',
            controller: _rfidController,
            hint: 'RF-STF-101...',
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // SECTION 2: CONTACT & ADDRESS
  // -------------------------------------------------------------
  Widget _buildContactSection(bool isDark) {
    return AdmissionSectionCard(
      icon: Icons.contact_mail_rounded,
      title: '2. Contact & Permanent Address',
      subtitle: 'Phone numbers, email and permanent residence',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdmissionTextField(
            label: 'Primary Phone / WhatsApp (10 Digits)',
            isRequired: true,
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            hint: 'e.g. 9876543210',
            errorText: _errors['phone'],
          ),
          const SizedBox(height: 12),

          AdmissionTextField(
            label: 'Family / Emergency Contact Phone',
            controller: _familyPhoneController,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            hint: 'Alternative contact number',
          ),
          const SizedBox(height: 12),

          AdmissionTextField(
            label: 'Email Address',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            hint: 'e.g. faculty@taleemone.in',
          ),
          const SizedBox(height: 12),

          // 6-digit Pincode Fast Helper with Live API Lookup (Auto-hit on 6 digits)
          AdmissionTextField(
            label: 'PIN Code (Postal Code)',
            controller: _pincodeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            hint: 'e.g. 244302 (Auto-detects address)',
            onChanged: _onPincodeInput,
            suffixIcon: _isFetchingPincode
                ? const Padding(
                    padding: EdgeInsets.all(11),
                    child: SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.goldPrimary,
                      ),
                    ),
                  )
                : (_postOffices.isNotEmpty
                    ? const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.statusPresent)
                    : const Icon(Icons.bolt_rounded, size: 18, color: AppColors.goldPrimary)),
          ),

          // Area Selection Dropdown if multiple post offices are found
          if (_postOffices.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                color: isDark ? const Color(0x330F172A) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.goldPrimary.withValues(alpha: 0.5),
                  width: 1.0,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPostOfficeName,
                  isExpanded: true,
                  hint: Text(
                    '-- Select Area (${_postOffices.length}) --',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                  ),
                  dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  items: _postOffices.map((po) {
                    return DropdownMenuItem<String>(
                      value: po.name,
                      child: Text(
                        '${po.name} (${po.block})',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: _onSelectPostOffice,
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Full Permanent Address
          AdmissionTextField(
            label: 'Permanent Address',
            isRequired: true,
            controller: _addressController,
            maxLines: 2,
            hint: 'House/Street, Post, District, State - PIN',
            errorText: _errors['address'],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // SECTION 3: ACADEMIC & PROFESSIONAL
  // -------------------------------------------------------------
  Widget _buildAcademicSection(bool isDark) {
    return AdmissionSectionCard(
      icon: Icons.school_rounded,
      title: '3. Professional & Academic Allocation',
      subtitle: 'Qualifications, designation, department & duty mode',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Qualification Dropdown
          Text(
            'Qualification *',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0x1F0F172A) : const Color(0x52F8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white12 : Colors.black12, width: 0.9),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedQualification,
                isExpanded: true,
                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                items: kQualifications.map((q) {
                  return DropdownMenuItem(
                    value: q,
                    child: Text(
                      q,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (newVal) {
                  if (newVal != null) setState(() => _selectedQualification = newVal);
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Designation Dropdown
          Text(
            'Designation / Role *',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0x1F0F172A) : const Color(0x52F8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white12 : Colors.black12, width: 0.9),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedDesignation,
                isExpanded: true,
                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                items: kDesignations.map((d) {
                  return DropdownMenuItem(
                    value: d,
                    child: Text(
                      d,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (newVal) {
                  if (newVal != null) setState(() => _selectedDesignation = newVal);
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          AdmissionTextField(
            label: 'Department / Teaching Subject',
            controller: _departmentController,
            hint: 'e.g. Hadith, Fiqh, Quranic Studies, Arabic...',
          ),
          const SizedBox(height: 12),

          AdmissionTextField(
            label: 'Teaching Experience (Years)',
            controller: _experienceController,
            keyboardType: TextInputType.number,
            hint: 'e.g. 8',
          ),
          const SizedBox(height: 12),

          AdmissionTextField(
            label: 'Date of Joining',
            isRequired: true,
            controller: _joiningDateController,
            readOnly: true,
            onTap: _pickJoiningDate,
            hint: 'DD MMM YYYY (e.g. 01 Jul 2020)',
            suffixIcon: const Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.goldPrimary),
            errorText: _errors['joiningDate'],
          ),
          const SizedBox(height: 12),

          _buildSegmentRow(
            label: 'Duty Mode / Residence Status',
            options: [
              ('Hostel Resident', 'Hostel Resident'),
              ('Day Scholar', 'Day Scholar'),
              ('Online', 'Online'),
            ],
            selectedValue: _dutyMode,
            onSelected: (val) => setState(() => _dutyMode = val),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // SECTION 4: FINANCIAL & BANKING
  // -------------------------------------------------------------
  Widget _buildBankSection(bool isDark) {
    return AdmissionSectionCard(
      icon: Icons.account_balance_rounded,
      title: '4. Financial & Banking Information',
      subtitle: 'Monthly remuneration, bank account and IFSC',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdmissionTextField(
            label: 'Monthly Salary (₹ INR)',
            controller: _salaryController,
            keyboardType: TextInputType.number,
            hint: 'e.g. 35000',
            suffixIcon: const Icon(Icons.currency_rupee_rounded, size: 16, color: AppColors.goldPrimary),
          ),
          const SizedBox(height: 12),

          AdmissionTextField(
            label: 'Bank Name',
            controller: _bankNameController,
            hint: 'e.g. State Bank of India',
          ),
          const SizedBox(height: 12),

          AdmissionTextField(
            label: 'Bank Account Number',
            controller: _accountNoController,
            keyboardType: TextInputType.number,
            hint: 'e.g. 30987654321',
          ),
          const SizedBox(height: 12),

          AdmissionTextField(
            label: 'IFSC Code',
            controller: _ifscController,
            hint: 'e.g. SBIN0001234',
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // SECTION 5: STAFF STATUS (EDIT MODE ONLY)
  // -------------------------------------------------------------
  Widget _buildStatusSection(bool isDark) {
    const statuses = ['Active', 'On Leave', 'Resigned', 'Terminated'];

    return AdmissionSectionCard(
      icon: Icons.shield_rounded,
      title: '5. Faculty Status',
      subtitle: 'Institutional employment record status',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Employment Status *',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: statuses.map((status) {
              final isSelected = _staffStatus.toLowerCase() == status.toLowerCase();
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.5),
                  child: InkWell(
                    onTap: () => setState(() => _staffStatus = status),
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (status == 'Active'
                                ? AppColors.statusPresent
                                : (status == 'On Leave'
                                    ? AppColors.statusLeave
                                    : AppColors.statusAbsent))
                            : (isDark ? const Color(0x1F0F172A) : const Color(0x52F8FAFC)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : (isDark ? Colors.white12 : Colors.black12),
                          width: 0.9,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // REUSABLE SEGMENT ROW (Matching Student Admission _buildSegmentRow)
  // -------------------------------------------------------------
  Widget _buildSegmentRow({
    required String label,
    required List<(String, String)> options,
    required String selectedValue,
    required ValueChanged<String> onSelected,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: options.map((opt) {
            final isSel = selectedValue == opt.$1;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: InkWell(
                  onTap: () => onSelected(opt.$1),
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSel
                          ? AppColors.goldPrimary
                          : (isDark ? const Color(0x1F0F172A) : const Color(0x52F8FAFC)),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSel ? AppColors.goldChampagne : (isDark ? Colors.white12 : Colors.black12),
                        width: 0.9,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        opt.$2,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                          color: isSel
                              ? Colors.white
                              : (isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEditModeBanner(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.edit_note_rounded, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EDITING: ${widget.initialTeacher?.fullNameEn ?? ""}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'Code: ',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white70 : const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        '${widget.initialTeacher?.staffCode ?? 101}',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFD97706),
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• Status: ',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white70 : const Color(0xFF64748B),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: (_staffStatus.toLowerCase() == 'active'
                                  ? AppColors.statusPresent
                                  : (_staffStatus.toLowerCase() == 'on leave'
                                      ? AppColors.statusLeave
                                      : AppColors.statusAbsent))
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _staffStatus.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: _staffStatus.toLowerCase() == 'active'
                                ? AppColors.statusPresent
                                : (_staffStatus.toLowerCase() == 'on leave'
                                    ? AppColors.statusLeave
                                    : AppColors.statusAbsent),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(bool isDark) {
    final isEdit = widget.isEditMode;
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isEdit
              ? const [
                  Color(0xFF059669),
                  Color(0xFF10B981),
                  Color(0xFF047857),
                ]
              : const [
                  AppColors.goldLight,
                  AppColors.goldPrimary,
                  AppColors.goldDark,
                ],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: (isEdit ? const Color(0xFF10B981) : AppColors.goldPrimary).withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _submitForm,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isEdit ? Icons.save_rounded : Icons.person_add_alt_1_rounded,
                  size: 20,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  isEdit ? 'Update Faculty Record' : 'Complete Staff Onboarding',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
