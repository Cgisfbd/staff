import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/core/widgets/executive_top_header.dart';
import 'package:staff_app/features/attendance/data/datasources/student_attendance_datasource.dart';
import 'package:staff_app/features/examination/domain/models/academic_filter_model.dart';
import 'package:staff_app/features/students/domain/entities/student_directory_entity.dart';
import 'package:staff_app/features/students/presentation/widgets/admission/admission_documents_section.dart';
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

/// Ultra-Luxury Screen Orchestrator for Student Admission Registration (< 450 lines).
/// Strictly mirrors all 24 fields from the Enterprise Web ERP Admission Form.
class StudentAdmissionPage extends StatefulWidget {
  const StudentAdmissionPage({
    super.key,
    this.initialStudent,
    this.isEditMode = false,
  });

  final StudentDirectoryEntity? initialStudent;
  final bool isEditMode;

  @override
  State<StudentAdmissionPage> createState() => _StudentAdmissionPageState();
}

class _StudentAdmissionPageState extends State<StudentAdmissionPage> {
  // Photo
  String? _photoPath;

  // Controllers — Student Identity
  final _nameEnController = TextEditingController();
  final _nameUrController = TextEditingController();
  final _dobController = TextEditingController();
  DateTime? _selectedDob;
  String _selectedGender = 'Female';
  final _casteController = TextEditingController();
  final _aadharController = TextEditingController();
  final _rfidController = TextEditingController();

  // Controllers — Parents Information
  final _fatherEnController = TextEditingController();
  final _fatherUrController = TextEditingController();
  final _fatherOccController = TextEditingController();
  final _motherEnController = TextEditingController();
  final _motherUrController = TextEditingController();
  final _motherOccController = TextEditingController();

  // Controllers — Contact & Address
  final _mobileController = TextEditingController();
  final _altMobileController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _addressController = TextEditingController();

  // Controllers & State — Academic
  CourseEntity? _selectedCourse;
  ClassEntity? _selectedClass;
  DateTime _admissionDate = DateTime.now();
  final _admissionDateController = TextEditingController();
  String _modeOfStudy = 'Offline';
  String _hostelFacility = 'Yes';
  final _prevSchoolNameController = TextEditingController();
  final _prevSchoolAddressController = TextEditingController();

  // Edit mode extra state
  String _accountStatus = 'Active';
  int? _assignedRollNo;

  // Submitted Documents State
  final Set<String> _selectedDocs = {};
  final _otherDocController = TextEditingController();

  // Field validation errors map
  final Map<String, String> _errors = {};

  // Pincode Fast Helper State
  bool _isFetchingPincode = false;
  List<_PostOfficeArea> _postOffices = [];
  String? _selectedPostOfficeName;
  String _lastSearchedPincode = '';

  final List<CourseEntity> _courses = StudentAttendanceDatasource.courses;
  final List<ClassEntity> _allClasses = StudentAttendanceDatasource.classes;

  List<ClassEntity> get _availableClasses {
    if (_selectedCourse == null) return const [];
    return _allClasses.where((c) => c.courseId == _selectedCourse!.id).toList();
  }

  DateTime? _parseAnyDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final str = raw.trim();
    try {
      return DateTime.parse(str);
    } catch (_) {}
    try {
      return DateFormat('dd MMM yyyy').parse(str);
    } catch (_) {}
    try {
      return DateFormat('d MMM yyyy').parse(str);
    } catch (_) {}
    try {
      return DateFormat('dd-MM-yyyy').parse(str);
    } catch (_) {}
    try {
      return DateFormat('dd/MM/yyyy').parse(str);
    } catch (_) {}
    try {
      return DateFormat('yyyy-MM-dd').parse(str);
    } catch (_) {}
    try {
      return DateFormat('yyyy/MM/dd').parse(str);
    } catch (_) {}
    return null;
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    if (widget.isEditMode && widget.initialStudent != null) {
      final s = widget.initialStudent!;
      _nameEnController.text = s.fullNameEn;
      _nameUrController.text = s.nameUrdu;

      _selectedDob = _parseAnyDate(s.dob) ?? DateTime(now.year - 14, now.month, now.day);
      _dobController.text = DateFormat('dd MMM yyyy').format(_selectedDob!);

      _selectedGender = s.gender.isNotEmpty ? s.gender : 'Male';
      _casteController.text = s.caste;
      _aadharController.text = s.aadharNo;
      _rfidController.text = s.rfidNo;
      _fatherEnController.text = s.fatherNameEn;
      _fatherUrController.text = s.fatherNameUr;
      _fatherOccController.text = s.fatherOccupation;
      _motherEnController.text = s.motherNameEn;
      _mobileController.text = s.mobile;
      _altMobileController.text = s.altMobile;
      _addressController.text = s.fullAddress;
      _modeOfStudy = s.modeOfStudy;
      _hostelFacility = s.hostelFacility;
      _prevSchoolNameController.text = s.prevSchoolName;
      _prevSchoolAddressController.text = s.prevSchoolAddress;
      _photoPath = s.photoUrl;
      _accountStatus = s.status;
      _assignedRollNo = s.rollNo;

      _admissionDate = _parseAnyDate(s.admissionDate) ?? now;
      _admissionDateController.text = DateFormat('dd MMM yyyy').format(_admissionDate);

      // Populate Submitted Documents
      final initialDocs = s.submittedDocs;
      if (initialDocs.isNotEmpty) {
        for (final doc in initialDocs) {
          final lower = doc.toLowerCase();
          if (lower.contains('student') && lower.contains('aadhar')) {
            _selectedDocs.add('studentAadhar');
          } else if (lower.contains('father') && lower.contains('aadhar')) {
            _selectedDocs.add('fatherAadhar');
          } else if (lower.contains('mother') && lower.contains('aadhar')) {
            _selectedDocs.add('motherAadhar');
          } else if (lower.contains('photo')) {
            _selectedDocs.add('studentPhotos');
          } else if (lower.contains('tc') || lower.contains('mark')) {
            _selectedDocs.add('tcCertificate');
          } else if (lower.contains('character')) {
            _selectedDocs.add('characterCert');
          } else {
            _selectedDocs.add('otherDoc');
            if (_otherDocController.text.isEmpty) {
              _otherDocController.text = doc;
            }
          }
        }
      } else {
        _selectedDocs.addAll(['studentAadhar', 'fatherAadhar', 'studentPhotos']);
      }

      if (_courses.isNotEmpty) {
        _selectedCourse = _courses.firstWhere(
          (c) => c.nameEnglish.toLowerCase() == s.courseName.toLowerCase(),
          orElse: () => _courses.first,
        );
        final avail = _availableClasses;
        if (avail.isNotEmpty) {
          _selectedClass = avail.firstWhere(
            (cl) => cl.nameEnglish.toLowerCase() == s.className.toLowerCase(),
            orElse: () => avail.first,
          );
        }
      }
    } else {
      // Default DOB (14 years ago) and Admission Date (Today) formatted as dd MMM yyyy
      final now = DateTime.now();
      _selectedDob = DateTime(now.year - 14, now.month, now.day);
      _dobController.text = DateFormat('dd MMM yyyy').format(_selectedDob!);
      _admissionDateController.text = DateFormat('dd MMM yyyy').format(_admissionDate);
      _selectedDocs.addAll(['studentAadhar', 'fatherAadhar', 'studentPhotos']);

      if (_courses.isNotEmpty) {
        _selectedCourse = _courses.first;
        final avail = _availableClasses;
        if (avail.isNotEmpty) _selectedClass = avail.first;
      }
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

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameUrController.dispose();
    _dobController.dispose();
    _casteController.dispose();
    _aadharController.dispose();
    _rfidController.dispose();
    _fatherEnController.dispose();
    _fatherUrController.dispose();
    _fatherOccController.dispose();
    _motherEnController.dispose();
    _motherUrController.dispose();
    _motherOccController.dispose();
    _mobileController.dispose();
    _altMobileController.dispose();
    _pincodeController.dispose();
    _addressController.dispose();
    _admissionDateController.dispose();
    _prevSchoolNameController.dispose();
    _prevSchoolAddressController.dispose();
    _otherDocController.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(now.year - 14, now.month, now.day),
      firstDate: DateTime(1990),
      lastDate: now,
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

  Future<void> _pickAdmissionDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _admissionDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 2),
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
        _admissionDate = picked;
        _admissionDateController.text = DateFormat('dd MMM yyyy').format(picked);
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

  void _onSelectPostOffice(String? poName) {
    if (poName == null) return;
    final po = _postOffices.firstWhere((p) => p.name == poName, orElse: () => _postOffices.first);
    setState(() {
      _selectedPostOfficeName = po.name;
      final code = _pincodeController.text.trim();
      final addr = '${po.name}, ${po.block}, ${po.district}, ${po.state} - $code';
      _addressController.text = addr;
      _errors.remove('address');
    });
  }

  bool _validateForm() {
    final errs = <String, String>{};

    if (_nameEnController.text.trim().isEmpty) {
      errs['nameEn'] = context.tr('admission_fill_required');
    }
    if (_nameUrController.text.trim().isEmpty) {
      errs['nameUr'] = context.tr('admission_fill_required');
    }
    if (_selectedDob == null) {
      errs['dob'] = context.tr('admission_fill_required');
    }
    if (_fatherEnController.text.trim().isEmpty) {
      errs['fatherEn'] = context.tr('admission_fill_required');
    }
    if (_fatherUrController.text.trim().isEmpty) {
      errs['fatherUr'] = context.tr('admission_fill_required');
    }
    if (_motherEnController.text.trim().isEmpty) {
      errs['motherEn'] = context.tr('admission_fill_required');
    }
    if (_motherUrController.text.trim().isEmpty) {
      errs['motherUr'] = context.tr('admission_fill_required');
    }
    if (_mobileController.text.trim().length < 10) {
      errs['mobile'] = '10 digits required';
    }
    if (_addressController.text.trim().isEmpty) {
      errs['address'] = context.tr('admission_fill_required');
    }
    if (_selectedCourse == null) {
      errs['course'] = context.tr('admission_fill_required');
    }

    setState(() {
      _errors.clear();
      _errors.addAll(errs);
    });

    return errs.isEmpty;
  }

  void _submitAdmission() {
    if (!_validateForm()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr('admission_fill_required'),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          backgroundColor: AppColors.statusAbsent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (widget.isEditMode) {
      final updatedStudent = StudentDirectoryEntity(
        id: widget.initialStudent?.id ?? 'stu-${DateTime.now().millisecondsSinceEpoch}',
        rollNo: _assignedRollNo ?? widget.initialStudent?.rollNo ?? 1001,
        status: _accountStatus,
        fullNameEn: _nameEnController.text.trim(),
        nameUrdu: _nameUrController.text.trim(),
        fatherNameEn: _fatherEnController.text.trim(),
        fatherNameUr: _fatherUrController.text.trim(),
        fatherOccupation: _fatherOccController.text.trim(),
        motherNameEn: _motherEnController.text.trim(),
        dob: _dobController.text.trim(),
        gender: _selectedGender,
        caste: _casteController.text.trim(),
        aadharNo: _aadharController.text.trim(),
        rfidNo: _rfidController.text.trim().isNotEmpty
            ? _rfidController.text.trim()
            : (widget.initialStudent?.rfidNo ?? 'RF-99201'),
        photoUrl: _photoPath ?? widget.initialStudent?.photoUrl,
        mobile: _mobileController.text.trim(),
        altMobile: _altMobileController.text.trim(),
        fullAddress: _addressController.text.trim(),
        courseName: _selectedCourse?.nameEnglish ?? widget.initialStudent?.courseName ?? '',
        className: _selectedClass?.nameEnglish ?? widget.initialStudent?.className ?? '',
        modeOfStudy: _modeOfStudy,
        hostelFacility: _hostelFacility,
        prevSchoolName: _prevSchoolNameController.text.trim(),
        prevSchoolAddress: _prevSchoolAddressController.text.trim(),
        admissionDate: _admissionDateController.text.trim(),
        submittedDocs: [
          if (_selectedDocs.contains('studentAadhar')) "Student's Aadhaar",
          if (_selectedDocs.contains('fatherAadhar')) "Father's Aadhaar",
          if (_selectedDocs.contains('motherAadhar')) "Mother's Aadhaar",
          if (_selectedDocs.contains('studentPhotos')) '3 Photos',
          if (_selectedDocs.contains('tcCertificate')) 'TC / Marksheet',
          if (_selectedDocs.contains('characterCert')) 'Character Certificate',
          if (_selectedDocs.contains('otherDoc'))
            _otherDocController.text.trim().isNotEmpty
                ? _otherDocController.text.trim()
                : 'Other Document',
        ],
      );

      Navigator.of(context).pop(updatedStudent);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Updated student details for ${updatedStudent.fullNameEn}',
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
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF131A26) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.statusPresent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, size: 36, color: AppColors.statusPresent),
              ),
              const SizedBox(height: 14),
              Text(
                context.tr('admission_success_msg'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_nameEnController.text.trim()} (${_selectedClass?.localizedName(false, null, context) ?? ''})',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(context.tr('common_close')),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AppBackground(
        useSafeArea: false,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 1. Executive Top Header
              ExecutiveTopHeader(
                icon: widget.isEditMode ? Icons.edit_note_rounded : Icons.person_add_alt_1_rounded,
                title: widget.isEditMode ? 'Edit Student Bio Record' : context.tr('admission_top_title'),
                subtitle: widget.isEditMode
                    ? 'Update student bio records, academic allocation & status'
                    : context.tr('admission_top_subtitle'),
                onIconTap: widget.isEditMode ? () => Navigator.of(context).maybePop() : null,
              ),

              // 2. Scrollable Form Content
              Expanded(
                child: ListView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
                  children: [
                    // Edit Mode Top Banner
                    if (widget.isEditMode) _buildEditModeBanner(isDark),

                    // Section 1: Student Identity & Photo
                    _buildIdentitySection(isDark),

                    // Section 2: Parents Information
                    _buildFamilySection(isDark),

                    // Section 3: Contact & Permanent Address
                    _buildContactAddressSection(isDark),

                    // Section 4: Academic Enrollment
                    _buildAcademicSection(isDark),

                    // Section 5: Submitted Documents (Active in both Add & Edit)
                    AdmissionDocumentsSection(
                      selectedDocIds: _selectedDocs,
                      onToggleDoc: (id) {
                        setState(() {
                          if (_selectedDocs.contains(id)) {
                            _selectedDocs.remove(id);
                          } else {
                            _selectedDocs.add(id);
                          }
                        });
                      },
                      otherDocController: _otherDocController,
                      sectionNumber: '5',
                    ),

                    // Section 6: Office Records & Status (Edit Mode Exclusive)
                    if (widget.isEditMode) _buildEditOfficeSection(isDark),

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
  // SECTION 1: ACADEMIC ENROLLMENT
  // -------------------------------------------------------------
  Widget _buildAcademicSection(bool isDark) {
    return AdmissionSectionCard(
      icon: Icons.school_rounded,
      title: context.tr('admission_sec_academic'),
      subtitle: context.tr('admission_sec_academic_sub'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Dropdown
          Text(
            '${context.tr('admission_field_course')} *',
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
              child: DropdownButton<CourseEntity>(
                value: _selectedCourse,
                isExpanded: true,
                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                items: _courses.map((c) {
                  return DropdownMenuItem(
                    value: c,
                    child: Text(
                      c.localizedName(false, null, context),
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (newCourse) {
                  setState(() {
                    _selectedCourse = newCourse;
                    final avail = _availableClasses;
                    _selectedClass = avail.isNotEmpty ? avail.first : null;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Class Dropdown
          Text(
            '${context.tr('admission_field_class')} *',
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
              child: DropdownButton<ClassEntity>(
                value: _selectedClass,
                isExpanded: true,
                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                items: _availableClasses.map((cls) {
                  return DropdownMenuItem(
                    value: cls,
                    child: Text(
                      cls.localizedName(false, null, context),
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (newClass) => setState(() => _selectedClass = newClass),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Date of Admission (Identical in both Add & Edit Mode)
          AdmissionTextField(
            label: context.tr('admission_field_adm_date'),
            isRequired: true,
            controller: _admissionDateController,
            readOnly: true,
            onTap: _pickAdmissionDate,
            hint: 'DD MMM YYYY (e.g. 15 Jul 2024)',
            suffixIcon: const Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: AppColors.goldPrimary,
            ),
          ),

          const SizedBox(height: 12),

          // Mode of Study (Offline / Online)
          _buildSegmentRow(
            label: context.tr('admission_field_mode'),
            options: [
              ('Offline', context.tr('admission_opt_offline')),
              ('Online', context.tr('admission_opt_online')),
            ],
            selectedValue: _modeOfStudy,
            onSelected: (val) {
              setState(() {
                _modeOfStudy = val;
                if (val == 'Online') {
                  _hostelFacility = 'No';
                } else {
                  _hostelFacility = 'Yes';
                }
              });
            },
            isDark: isDark,
          ),

          const SizedBox(height: 12),

          // Hostel Facility (Resident / Non-Resident) — Strictly disabled/locked when modeOfStudy is Online
          _buildHostelFacilityRow(isDark),

          const SizedBox(height: 12),

          // Previous School Name
          AdmissionTextField(
            label: context.tr('admission_field_prev_school'),
            controller: _prevSchoolNameController,
            hint: 'e.g. Madrasa Arabia / High School',
          ),

          const SizedBox(height: 12),

          // Previous School Address
          AdmissionTextField(
            label: context.tr('admission_field_prev_address'),
            controller: _prevSchoolAddressController,
            hint: 'City / District of previous institute',
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // SECTION 2: STUDENT IDENTITY & PHOTO
  // -------------------------------------------------------------
  Widget _buildIdentitySection(bool isDark) {
    return AdmissionSectionCard(
      icon: Icons.person_rounded,
      title: context.tr('admission_sec_identity'),
      subtitle: context.tr('admission_sec_identity_sub'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo Picker
          AdmissionPhotoCard(
            photoPath: _photoPath,
            onPhotoSelected: (p) => setState(() => _photoPath = p),
            onPhotoRemoved: () => setState(() => _photoPath = null),
          ),

          const SizedBox(height: 16),

          // Full Name English
          AdmissionTextField(
            label: context.tr('admission_field_name_en'),
            isRequired: true,
            controller: _nameEnController,
            hint: 'e.g. Mohammad Zaid',
            errorText: _errors['nameEn'],
          ),

          const SizedBox(height: 12),

          // Full Name Urdu
          AdmissionTextField(
            label: context.tr('admission_field_name_ur'),
            isRequired: true,
            controller: _nameUrController,
            isRtl: true,
            hint: 'اردو: محمد زید',
            errorText: _errors['nameUr'],
          ),

          const SizedBox(height: 12),

          // Date of Birth
          AdmissionTextField(
            label: context.tr('admission_field_dob'),
            isRequired: true,
            controller: _dobController,
            readOnly: true,
            onTap: _pickDob,
            hint: 'DD MMM YYYY (e.g. 15 Jan 2008)',
            suffixIcon: const Icon(Icons.cake_rounded, size: 16, color: AppColors.goldPrimary),
            errorText: _errors['dob'],
          ),

          const SizedBox(height: 12),

          // Gender (Default Female)
          _buildSegmentRow(
            label: context.tr('admission_field_gender'),
            options: [
              ('Female', context.tr('admission_opt_female')),
              ('Male', context.tr('admission_opt_male')),
            ],
            selectedValue: _selectedGender,
            onSelected: (val) => setState(() => _selectedGender = val),
            isDark: isDark,
          ),

          const SizedBox(height: 12),

          // Caste / Biradri
          AdmissionTextField(
            label: context.tr('admission_field_caste'),
            controller: _casteController,
            hint: 'e.g. Ansari, Qureshi, Siddiqui...',
          ),

          const SizedBox(height: 12),

          // Aadhar Number
          AdmissionTextField(
            label: context.tr('admission_field_aadhar'),
            controller: _aadharController,
            keyboardType: TextInputType.number,
            maxLength: 12,
            hint: '12-digit UIDAI number',
          ),

          const SizedBox(height: 12),

          // RFID Tag
          AdmissionTextField(
            label: context.tr('admission_field_rfid'),
            controller: _rfidController,
            hint: 'RFID-10023...',
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // SECTION 3: PARENTS INFORMATION
  // -------------------------------------------------------------
  Widget _buildFamilySection(bool isDark) {
    return AdmissionSectionCard(
      icon: Icons.family_restroom_rounded,
      title: context.tr('admission_sec_family'),
      subtitle: context.tr('admission_sec_family_sub'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Father Name English
          AdmissionTextField(
            label: context.tr('admission_field_father_en'),
            isRequired: true,
            controller: _fatherEnController,
            hint: 'e.g. Tariq Ahmad',
            errorText: _errors['fatherEn'],
          ),

          const SizedBox(height: 12),

          // Father Name Urdu
          AdmissionTextField(
            label: context.tr('admission_field_father_ur'),
            isRequired: true,
            controller: _fatherUrController,
            isRtl: true,
            hint: 'اردو: طارق احمد',
            errorText: _errors['fatherUr'],
          ),

          const SizedBox(height: 12),

          // Father Occupation
          AdmissionTextField(
            label: context.tr('admission_field_father_occ'),
            controller: _fatherOccController,
            hint: 'e.g. Business / Agriculture',
          ),

          const SizedBox(height: 12),

          // Mother Name English
          AdmissionTextField(
            label: context.tr('admission_field_mother_en'),
            isRequired: true,
            controller: _motherEnController,
            hint: 'e.g. Parveen Begum',
            errorText: _errors['motherEn'],
          ),

          const SizedBox(height: 12),

          // Mother Name Urdu
          AdmissionTextField(
            label: context.tr('admission_field_mother_ur'),
            isRequired: true,
            controller: _motherUrController,
            isRtl: true,
            hint: 'اردو: پروین بیگم',
            errorText: _errors['motherUr'],
          ),

          const SizedBox(height: 12),

          // Mother Occupation
          AdmissionTextField(
            label: context.tr('admission_field_mother_occ'),
            controller: _motherOccController,
            hint: 'e.g. Homemaker',
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // SECTION 4: CONTACT & PERMANENT ADDRESS
  // -------------------------------------------------------------
  Widget _buildContactAddressSection(bool isDark) {
    return AdmissionSectionCard(
      icon: Icons.location_on_rounded,
      title: context.tr('admission_sec_contact'),
      subtitle: context.tr('admission_sec_contact_sub'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mobile Number
          AdmissionTextField(
            label: context.tr('admission_field_mobile'),
            isRequired: true,
            controller: _mobileController,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            hint: '10-digit mobile',
            errorText: _errors['mobile'],
          ),

          const SizedBox(height: 12),

          // Alternate Mobile Number
          AdmissionTextField(
            label: context.tr('admission_field_alt_mobile'),
            controller: _altMobileController,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            hint: 'Emergency / WhatsApp number',
          ),

          const SizedBox(height: 12),

          // 6-digit Pincode Fast Helper with Live API Lookup (Auto-hit on 6 digits)
          AdmissionTextField(
            label: context.tr('admission_field_pincode'),
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
            label: context.tr('admission_field_address'),
            isRequired: true,
            controller: _addressController,
            maxLines: 3,
            hint: 'Village / City, Post, District, State - PIN',
            errorText: _errors['address'],
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentRow({
    required String label,
    required List<(String, String)> options,
    required String selectedValue,
    required ValueChanged<String>? onSelected,
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
            final isEnabled = onSelected != null;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: InkWell(
                  onTap: isEnabled ? () => onSelected(opt.$1) : null,
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

  Widget _buildHostelFacilityRow(bool isDark) {
    final isOnline = _modeOfStudy == 'Online';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                context.tr('admission_field_hostel'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isOnline) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.statusAbsent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.statusAbsent.withValues(alpha: 0.3),
                    width: 0.7,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_rounded, size: 10, color: AppColors.statusAbsent),
                    SizedBox(width: 3),
                    Text(
                      'Blocked in Online',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.statusAbsent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            // Option 1: Resident (Only selectable if Offline)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: InkWell(
                  onTap: isOnline
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Hostel / Resident facility is only available in Offline mode!'),
                              backgroundColor: AppColors.statusAbsent,
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      : () => setState(() => _hostelFacility = 'Yes'),
                  borderRadius: BorderRadius.circular(10),
                  child: Opacity(
                    opacity: isOnline ? 0.35 : 1.0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: (!isOnline && _hostelFacility == 'Yes')
                            ? AppColors.goldPrimary
                            : (isDark ? const Color(0x1F0F172A) : const Color(0x52F8FAFC)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: (!isOnline && _hostelFacility == 'Yes')
                              ? AppColors.goldChampagne
                              : (isDark ? Colors.white12 : Colors.black12),
                          width: 0.9,
                        ),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isOnline) ...[
                              const Icon(Icons.lock_rounded, size: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                            ],
                            Flexible(
                              child: Text(
                                context.tr('admission_opt_resident'),
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: (!isOnline && _hostelFacility == 'Yes')
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: (!isOnline && _hostelFacility == 'Yes')
                                      ? Colors.white
                                      : (isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Option 2: Non-Resident (Always available; active in Online mode)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: InkWell(
                  onTap: () => setState(() => _hostelFacility = 'No'),
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: (isOnline || _hostelFacility == 'No')
                          ? AppColors.goldPrimary
                          : (isDark ? const Color(0x1F0F172A) : const Color(0x52F8FAFC)),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: (isOnline || _hostelFacility == 'No')
                            ? AppColors.goldChampagne
                            : (isDark ? Colors.white12 : Colors.black12),
                        width: 0.9,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        context.tr('admission_opt_non_resident'),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: (isOnline || _hostelFacility == 'No')
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: (isOnline || _hostelFacility == 'No')
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
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEditModeBanner(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
                    'EDITING: ${widget.initialStudent?.fullNameEn ?? ""}',
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
                        'Roll: ',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white70 : const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        '${widget.initialStudent?.rollNo ?? _assignedRollNo ?? 1001}',
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
                          color: (_accountStatus.toLowerCase() == 'active'
                                  ? AppColors.statusPresent
                                  : (_accountStatus.toLowerCase() == 'dropout'
                                      ? AppColors.statusAbsent
                                      : (_accountStatus.toLowerCase().startsWith('suspend')
                                          ? const Color(0xFFEA580C)
                                          : AppColors.statusLeave)))
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _accountStatus.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: _accountStatus.toLowerCase() == 'active'
                                ? AppColors.statusPresent
                                : (_accountStatus.toLowerCase() == 'dropout'
                                    ? AppColors.statusAbsent
                                    : (_accountStatus.toLowerCase().startsWith('suspend')
                                        ? const Color(0xFFEA580C)
                                        : AppColors.statusLeave)),
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

  // -------------------------------------------------------------
  // SECTION 6: STUDENT STATUS (EDIT MODE EXCLUSIVE)
  // -------------------------------------------------------------
  Widget _buildEditOfficeSection(bool isDark) {
    const statuses = ['Active', 'Dropout', 'Suspend', 'Graduate'];

    return AdmissionSectionCard(
      icon: Icons.shield_rounded,
      title: '6. Student Status',
      subtitle: 'Enrolment status across all institutional records',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enrolment Status *',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: statuses.map((status) {
              final isSelected = _accountStatus.toLowerCase() == status.toLowerCase() ||
                  (status == 'Suspend' && _accountStatus.toLowerCase() == 'suspended') ||
                  (status == 'Graduate' && _accountStatus.toLowerCase() == 'graduated');
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: InkWell(
                    onTap: () => setState(() => _accountStatus = status),
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (status == 'Active'
                                ? AppColors.statusPresent
                                : (status == 'Dropout'
                                    ? AppColors.statusAbsent
                                    : (status == 'Suspend'
                                        ? const Color(0xFFEA580C)
                                        : AppColors.statusLeave)))
                            : (isDark ? const Color(0x1F0F172A) : const Color(0x52F8FAFC)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : (isDark ? Colors.white12 : Colors.black12),
                          width: 0.9,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary),
                          ),
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
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _submitAdmission,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isEdit ? Icons.save_rounded : Icons.how_to_reg_rounded,
                  size: 20,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  isEdit ? 'Save Changes (ریکارڈ محفوظ کریں)' : context.tr('admission_btn_submit'),
                  style: const TextStyle(
                    fontSize: 14,
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
    );
  }
}
