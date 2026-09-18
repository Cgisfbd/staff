import 'package:flutter/material.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/router/route_names.dart';

/// Data model representing a sub-action/tab inside a menu category.
class MenuSubItem {
  const MenuSubItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.badgeText,
    this.route,
    this.isSuperAdminOnly = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final String? badgeText;
  final String? route;
  final bool isSuperAdminOnly;

  String localizedTitle(BuildContext context) {
    final trKey = 'menu_sub_${id}_title';
    final val = context.tr(trKey);
    return val != trKey ? val : title;
  }

  String localizedSubtitle(BuildContext context) {
    final trKey = 'menu_sub_${id}_sub';
    final val = context.tr(trKey);
    return val != trKey ? val : subtitle;
  }
}

/// Data model representing a sub-category section inside a primary menu category.
class MenuSection {
  const MenuSection({
    required this.id,
    required this.title,
    required this.icon,
    required this.items,
  });

  final String id;
  final String title;
  final IconData icon;
  final List<MenuSubItem> items;
}

/// Data model representing a primary ERP category in the Left Rail.
class MenuCategory {
  const MenuCategory({
    required this.id,
    required this.title,
    required this.shortLabel,
    required this.subtitle,
    required this.icon,
    required this.items,
    this.sections,
    this.badgeCount,
    this.isSuperAdminOnly = false,
  });

  final String id;
  final String title;
  final String shortLabel;
  final String subtitle;
  final IconData icon;
  final List<MenuSubItem> items;
  final List<MenuSection>? sections;
  final int? badgeCount;
  final bool isSuperAdminOnly;

  String localizedTitle(BuildContext context) {
    final trKey = 'menu_cat_${id}_title';
    final val = context.tr(trKey);
    return val != trKey ? val : title;
  }

  String localizedShortLabel(BuildContext context) {
    final trKey = 'menu_cat_${id}_short';
    final val = context.tr(trKey);
    return val != trKey ? val : shortLabel;
  }

  String localizedSubtitle(BuildContext context) {
    final trKey = 'menu_cat_${id}_sub';
    final val = context.tr(trKey);
    return val != trKey ? val : subtitle;
  }
}

/// Master repository of all 10 ERP Menu Categories and their respective sub-actions.
class MenuCategoriesData {
  MenuCategoriesData._();

  static const List<MenuCategory> categories = [
    // 1. Students
    MenuCategory(
      id: 'students',
      title: 'Student Management',
      shortLabel: 'Students',
      subtitle: 'Directory, admissions, promotions & records',
      icon: Icons.school_rounded,
      items: [
        MenuSubItem(
          id: 'all_students',
          title: 'All Students',
          subtitle: 'Complete student directory & bio records',
          icon: Icons.people_alt_rounded,
          badgeText: 'Directory',
          route: RouteNames.allStudents,
        ),
        MenuSubItem(
          id: 'admissions',
          title: 'Admission',
          subtitle: 'New student enrollment & verification',
          icon: Icons.person_add_alt_1_rounded,
          badgeText: 'New',
          route: RouteNames.studentAdmission,
        ),
        MenuSubItem(
          id: 'promotions',
          title: 'Class Promotions',
          subtitle: 'Yearly section upgrade & rollover',
          icon: Icons.upgrade_rounded,
        ),
        MenuSubItem(
          id: 'student_id_cards',
          title: 'ID Cards Generator',
          subtitle: 'Barcode & photo identity printing',
          icon: Icons.badge_outlined,
        ),
      ],
    ),

    // 2. Attendance
    MenuCategory(
      id: 'attendance',
      title: 'Attendance Hub',
      shortLabel: 'Attendance',
      subtitle: 'Daily roll call, staff registers & QR stream',
      icon: Icons.event_available_rounded,
      items: [
        MenuSubItem(
          id: 'staff_attendance',
          title: 'Staff Attendance',
          subtitle: 'Manual staff punch in/out & roll call',
          icon: Icons.how_to_reg_rounded,
          badgeText: 'Admin',
          isSuperAdminOnly: true,
          route: RouteNames.staffManualAttendance,
        ),
        MenuSubItem(
          id: 'monthly_register',
          title: 'Monthly Register',
          subtitle: 'Comprehensive monthly attendance sheet',
          icon: Icons.calendar_month_rounded,
        ),
        MenuSubItem(
          id: 'qr_attendance',
          title: 'QR Attendance',
          subtitle: 'High-speed camera & scanner ingestion',
          icon: Icons.qr_code_scanner_rounded,
          badgeText: 'Fast',
        ),
      ],
    ),

    // 3. Finance & Accounts
    MenuCategory(
      id: 'finance',
      title: 'Finance & Accounts',
      shortLabel: 'Finance',
      subtitle: 'Student fees, cash counters & staff payroll',
      icon: Icons.account_balance_wallet_rounded,
      items: [
        MenuSubItem(
          id: 'fees_counter',
          title: 'Fees Counter',
          subtitle: 'Instant receipt generation & dues check',
          icon: Icons.point_of_sale_rounded,
          badgeText: 'Counter',
          route: RouteNames.feesCounter,
        ),
        MenuSubItem(
          id: 'salary_counter',
          title: 'Salary Counter',
          subtitle: 'Faculty monthly payroll & disbursements',
          icon: Icons.payments_outlined,
          route: RouteNames.salaryCounter,
        ),
      ],
    ),

    // 4. Teachers & Staff
    MenuCategory(
      id: 'staff',
      title: 'Faculty & Staff',
      shortLabel: 'Staff',
      subtitle: 'Faculty directory & teacher profiles',
      icon: Icons.badge_rounded,
      items: [
        MenuSubItem(
          id: 'all_staff',
          title: 'All Teachers & Staff',
          subtitle: 'Faculty directory & academic portfolios',
          icon: Icons.groups_rounded,
          badgeText: 'Directory',
          route: RouteNames.allStaff,
        ),
        MenuSubItem(
          id: 'add_staff',
          title: 'Add New Staff',
          subtitle: 'Teacher onboarding & document records',
          icon: Icons.person_add_rounded,
          badgeText: 'Add',
          route: RouteNames.addStaff,
        ),
      ],
    ),

    // 5. Examination
    MenuCategory(
      id: 'exams',
      title: 'Examination & Results',
      shortLabel: 'Exams',
      subtitle: 'Exam schedules, question papers, marksheets & results',
      icon: Icons.assignment_rounded,
      items: [
        MenuSubItem(
          id: 'examination_results',
          title: 'Results & Topper Analytics',
          subtitle: 'Class, course & institute toppers gazette',
          icon: Icons.insights_rounded,
          badgeText: 'Toppers',
          route: RouteNames.examinationResults,
        ),
        MenuSubItem(
          id: 'question_paper',
          title: 'Question Paper Maker',
          subtitle: 'Create, manage & print exam question papers',
          icon: Icons.quiz_rounded,
          badgeText: 'Creator',
          route: RouteNames.questionUpload,
        ),
        MenuSubItem(
          id: 'marks_grading',
          title: 'Marks & Grading',
          subtitle: 'Score entry, position lists & remarks',
          icon: Icons.edit_note_rounded,
          route: RouteNames.marksEntry,
        ),
        MenuSubItem(
          id: 'admit_cards',
          title: 'Admit Cards Generator',
          subtitle: 'Print class & course student exam roll slips',
          icon: Icons.card_membership_rounded,
          badgeText: 'Print',
        ),
        MenuSubItem(
          id: 'date_sheets',
          title: 'Date Sheets',
          subtitle: 'Timetables, rooms & invigilator duties',
          icon: Icons.calendar_today_rounded,
          badgeText: 'Schedule',
        ),
        MenuSubItem(
          id: 'transcripts',
          title: 'Official Marksheets',
          subtitle: 'Generate & print bilingual report cards',
          icon: Icons.description_outlined,
        ),
        MenuSubItem(
          id: 'exam_setup',
          title: 'Exam Setup',
          subtitle: 'Configure term & annual examinations',
          icon: Icons.tune_rounded,
        ),
      ],
    ),

    // 6. Entrance Exam
    MenuCategory(
      id: 'entrance_exam',
      title: 'Entrance Examinations',
      shortLabel: 'Entrance',
      subtitle: 'Applicant registrations, question papers & merit',
      icon: Icons.fact_check_rounded,
      items: [
        MenuSubItem(
          id: 'candidates_register',
          title: 'Candidates Register',
          subtitle: 'Applicant roll numbers & registrations',
          icon: Icons.app_registration_rounded,
          badgeText: 'Applicants',
        ),
        MenuSubItem(
          id: 'entrance_question_paper',
          title: 'Entrance Question Papers',
          subtitle: 'Create & print entrance test papers',
          icon: Icons.quiz_rounded,
          badgeText: 'Print',
        ),
        MenuSubItem(
          id: 'result_evaluation',
          title: 'Candidate Results & Merit',
          subtitle: 'All candidate result evaluation & merit rankings',
          icon: Icons.military_tech_outlined,
          badgeText: 'Merit',
        ),
        MenuSubItem(
          id: 'course_exam_dates',
          title: 'Course Exam Dates',
          subtitle: 'Departmental testing slots & venues',
          icon: Icons.event_note_rounded,
        ),
      ],
    ),

    // 7. Smart Connect
    MenuCategory(
      id: 'smart_connect',
      title: 'Smart Connect Hub',
      shortLabel: 'Smart Connect',
      subtitle: 'Digital portal, broadcast & online services',
      icon: Icons.sensors_rounded,
      sections: [
        MenuSection(
          id: 'student_app',
          title: 'Student App',
          icon: Icons.school_rounded,
          items: [
            MenuSubItem(
              id: 'student_credentials',
              title: 'App Logins',
              subtitle: 'Generate, reset & lock student app accounts',
              icon: Icons.key_rounded,
            ),
            MenuSubItem(
              id: 'student_leaves',
              title: 'Leave Requests',
              subtitle: 'Review & approve student absence applications',
              icon: Icons.calendar_month_rounded,
              badgeText: 'Leaves',
            ),
            MenuSubItem(
              id: 'student_attendance_alerts',
              title: 'Attendance Alerts',
              subtitle: 'Low attendance warning push & SMS notifications',
              icon: Icons.notifications_active_rounded,
            ),
            MenuSubItem(
              id: 'student_fee_alerts',
              title: 'Fee Alerts',
              subtitle: 'Pending dues & installment reminder alerts',
              icon: Icons.account_balance_wallet_rounded,
            ),
          ],
        ),
        MenuSection(
          id: 'photo_approvals',
          title: 'Photo Approvals',
          icon: Icons.verified_user_rounded,
          items: [
            MenuSubItem(
              id: 'staff_photo_approvals',
              title: 'Staff Photos',
              subtitle: 'Security review & approval of teacher photos',
              icon: Icons.badge_rounded,
              badgeText: 'Staff',
            ),
            MenuSubItem(
              id: 'student_photo_approvals',
              title: 'Student Photos',
              subtitle: 'Verification of student admission & profile photos',
              icon: Icons.portrait_rounded,
              badgeText: 'Students',
            ),
          ],
        ),
        MenuSection(
          id: 'website_apps',
          title: 'Website and Apps',
          icon: Icons.language_rounded,
          items: [
            MenuSubItem(
              id: 'website_hero_banners',
              title: 'Hero Banners',
              subtitle: 'Public institute website top banners & slideshows',
              icon: Icons.view_carousel_outlined,
            ),
            MenuSubItem(
              id: 'website_news_releases',
              title: 'News & Releases',
              subtitle: 'Public announcements, press releases & news feed',
              icon: Icons.newspaper_rounded,
            ),
            MenuSubItem(
              id: 'website_admission_links',
              title: 'Admission Links',
              subtitle: 'Public admission portal links & submission tracking',
              icon: Icons.link_rounded,
            ),
            MenuSubItem(
              id: 'website_event_gallery',
              title: 'Photo Gallery',
              subtitle: 'Annual jalsas, convocations & campus photo albums',
              icon: Icons.photo_library_outlined,
            ),
            MenuSubItem(
              id: 'website_course_directory',
              title: 'Course Directory',
              subtitle: 'Public course offerings, curriculum overview & SEO',
              icon: Icons.travel_explore_rounded,
            ),
          ],
        ),
        MenuSection(
          id: 'notice_broadcast',
          title: 'Notice Broadcast',
          icon: Icons.campaign_rounded,
          items: [
            MenuSubItem(
              id: 'broadcast_compose',
              title: 'Compose Notice',
              subtitle: 'Draft multilingual announcements in Urdu, English & Hindi',
              icon: Icons.send_rounded,
              badgeText: 'Draft',
            ),
            MenuSubItem(
              id: 'broadcast_active',
              title: 'Active Notices',
              subtitle: 'Manage & view current live published notices',
              icon: Icons.campaign_rounded,
            ),
            MenuSubItem(
              id: 'broadcast_whatsapp_sms',
              title: 'WhatsApp & SMS',
              subtitle: 'Bulk SMS dispatch & WhatsApp alert credits',
              icon: Icons.chat_bubble_outline_rounded,
            ),
            MenuSubItem(
              id: 'broadcast_templates',
              title: 'Notice Templates',
              subtitle: 'Holiday, exam & fee standard message templates',
              icon: Icons.description_outlined,
            ),
            MenuSubItem(
              id: 'broadcast_logs',
              title: 'Broadcast Logs',
              subtitle: 'Delivery status, timestamps & message audit trail',
              icon: Icons.history_toggle_off_rounded,
            ),
          ],
        ),
        MenuSection(
          id: 'digital_books',
          title: 'Digital Books',
          icon: Icons.menu_book_rounded,
          items: [
            MenuSubItem(
              id: 'digital_books_library',
              title: 'Books Library',
              subtitle: 'Darse Nizami e-books, text library & PDF viewer',
              icon: Icons.menu_book_rounded,
              badgeText: 'E-Books',
            ),
            MenuSubItem(
              id: 'digital_books_upload',
              title: 'Upload Book',
              subtitle: 'Upload institutional large PDF books (up to 1000MB)',
              icon: Icons.upload_file_rounded,
            ),
          ],
        ),
        MenuSection(
          id: 'digital_classes',
          title: 'Digital Classes',
          icon: Icons.video_camera_front_rounded,
          items: [
            MenuSubItem(
              id: 'digital_class_pdfs',
              title: 'Class PDFs',
              subtitle: 'Daily class notes, study materials & syllabus PDFs',
              icon: Icons.folder_shared_outlined,
            ),
            MenuSubItem(
              id: 'digital_upload_class_pdf',
              title: 'Upload PDF',
              subtitle: 'Upload worksheets, dars notes & lesson materials',
              icon: Icons.note_add_outlined,
            ),
            MenuSubItem(
              id: 'digital_live_classes',
              title: 'Live Classes',
              subtitle: 'Live dars stream links, Zoom & scheduled lectures',
              icon: Icons.radio_rounded,
              badgeText: 'Live',
            ),
            MenuSubItem(
              id: 'digital_recorded_lectures',
              title: 'Recorded Dars',
              subtitle: 'Archived dars, audio & video lecture repository',
              icon: Icons.play_circle_outline_rounded,
            ),
            MenuSubItem(
              id: 'digital_schedule_class',
              title: 'Schedule Class',
              subtitle: 'Plan upcoming online classes & dars timetable',
              icon: Icons.event_available_rounded,
            ),
          ],
        ),
      ],
      items: [
        // --- Student App Services ---
        MenuSubItem(
          id: 'student_credentials',
          title: 'App Logins',
          subtitle: 'Generate, reset & lock student app accounts',
          icon: Icons.key_rounded,
        ),
        MenuSubItem(
          id: 'student_leaves',
          title: 'Leave Requests',
          subtitle: 'Review & approve student absence applications',
          icon: Icons.calendar_month_rounded,
          badgeText: 'Leaves',
        ),
        MenuSubItem(
          id: 'student_attendance_alerts',
          title: 'Attendance Alerts',
          subtitle: 'Low attendance warning push & SMS notifications',
          icon: Icons.notifications_active_rounded,
        ),
        MenuSubItem(
          id: 'student_fee_alerts',
          title: 'Fee Alerts',
          subtitle: 'Pending dues & installment reminder alerts',
          icon: Icons.account_balance_wallet_rounded,
        ),

        // --- Photo Approvals ---
        MenuSubItem(
          id: 'staff_photo_approvals',
          title: 'Staff Photos',
          subtitle: 'Security review & approval of teacher photos',
          icon: Icons.badge_rounded,
          badgeText: 'Staff',
        ),
        MenuSubItem(
          id: 'student_photo_approvals',
          title: 'Student Photos',
          subtitle: 'Verification of student admission & profile photos',
          icon: Icons.portrait_rounded,
          badgeText: 'Students',
        ),

        // --- Notice & SMS Broadcast ---
        MenuSubItem(
          id: 'broadcast_compose',
          title: 'Compose Notice',
          subtitle: 'Draft multilingual announcements in Urdu, English & Hindi',
          icon: Icons.send_rounded,
          badgeText: 'Draft',
        ),
        MenuSubItem(
          id: 'broadcast_active',
          title: 'Active Notices',
          subtitle: 'Manage & view current live published notices',
          icon: Icons.campaign_rounded,
        ),
        MenuSubItem(
          id: 'broadcast_whatsapp_sms',
          title: 'WhatsApp & SMS',
          subtitle: 'Bulk SMS dispatch & WhatsApp alert credits',
          icon: Icons.chat_bubble_outline_rounded,
        ),
        MenuSubItem(
          id: 'broadcast_templates',
          title: 'Notice Templates',
          subtitle: 'Holiday, exam & fee standard message templates',
          icon: Icons.description_outlined,
        ),
        MenuSubItem(
          id: 'broadcast_logs',
          title: 'Broadcast Logs',
          subtitle: 'Delivery status, timestamps & message audit trail',
          icon: Icons.history_toggle_off_rounded,
        ),

        // --- Digital Books ---
        MenuSubItem(
          id: 'digital_books_library',
          title: 'Books Library',
          subtitle: 'Darse Nizami e-books, text library & PDF viewer',
          icon: Icons.menu_book_rounded,
          badgeText: 'E-Books',
        ),
        MenuSubItem(
          id: 'digital_books_upload',
          title: 'Upload Book',
          subtitle: 'Upload institutional large PDF books (up to 1000MB)',
          icon: Icons.upload_file_rounded,
        ),

        // --- Digital Classes & Dars ---
        MenuSubItem(
          id: 'digital_class_pdfs',
          title: 'Class PDFs',
          subtitle: 'Daily class notes, study materials & syllabus PDFs',
          icon: Icons.folder_shared_outlined,
        ),
        MenuSubItem(
          id: 'digital_upload_class_pdf',
          title: 'Upload PDF',
          subtitle: 'Upload worksheets, dars notes & lesson materials',
          icon: Icons.note_add_outlined,
        ),
        MenuSubItem(
          id: 'digital_live_classes',
          title: 'Live Classes',
          subtitle: 'Live dars stream links, Zoom & scheduled lectures',
          icon: Icons.radio_rounded,
          badgeText: 'Live',
        ),
        MenuSubItem(
          id: 'digital_recorded_lectures',
          title: 'Recorded Dars',
          subtitle: 'Archived dars, audio & video lecture repository',
          icon: Icons.play_circle_outline_rounded,
        ),
        MenuSubItem(
          id: 'digital_schedule_class',
          title: 'Schedule Class',
          subtitle: 'Plan upcoming online classes & dars timetable',
          icon: Icons.event_available_rounded,
        ),

        // --- Website Management (Public Portal) ---
        MenuSubItem(
          id: 'website_hero_banners',
          title: 'Hero Banners',
          subtitle: 'Public institute website top banners & slideshows',
          icon: Icons.view_carousel_outlined,
        ),
        MenuSubItem(
          id: 'website_news_releases',
          title: 'News & Releases',
          subtitle: 'Public announcements, press releases & news feed',
          icon: Icons.newspaper_rounded,
        ),
        MenuSubItem(
          id: 'website_admission_links',
          title: 'Admission Links',
          subtitle: 'Public admission portal links & submission tracking',
          icon: Icons.link_rounded,
        ),
        MenuSubItem(
          id: 'website_event_gallery',
          title: 'Photo Gallery',
          subtitle: 'Annual jalsas, convocations & campus photo albums',
          icon: Icons.photo_library_outlined,
        ),
        MenuSubItem(
          id: 'website_course_directory',
          title: 'Course Directory',
          subtitle: 'Public course offerings, curriculum overview & SEO',
          icon: Icons.travel_explore_rounded,
        ),
      ],
    ),

    // 8. Sub-Accounts
    MenuCategory(
      id: 'sub_accounts',
      title: 'Sub-Accounts Delegation',
      shortLabel: 'Sub-Accounts',
      subtitle: 'Operator delegation & granular access controls',
      icon: Icons.manage_accounts_rounded,
      isSuperAdminOnly: true,
      items: [
        MenuSubItem(
          id: 'delegated_accounts',
          title: 'Staff Sub-Accounts',
          subtitle: 'Manage clerk, accountant & teacher logins',
          icon: Icons.manage_accounts_outlined,
          badgeText: 'Admin',
          route: RouteNames.staffSubAccounts,
        ),
        MenuSubItem(
          id: 'audit_logs',
          title: 'System Audit Trail',
          subtitle: 'Action timestamps & operator activity',
          icon: Icons.history_rounded,
          badgeText: 'Audit',
          route: RouteNames.systemAuditTrail,
        ),
      ],
    ),

    // 9. Admin Panel
    MenuCategory(
      id: 'admin_panel',
      title: 'Institutional Administration',
      shortLabel: 'Admin Panel',
      subtitle: 'Hierarchy, syllabus, courses & campus armor',
      icon: Icons.admin_panel_settings_rounded,
      isSuperAdminOnly: true,
      items: [
        MenuSubItem(
          id: 'institute_settings',
          title: 'Institute Settings',
          subtitle: 'Branding, Urdu logo, motto & contact',
          icon: Icons.account_balance_rounded,
          badgeText: 'Setup',
          route: RouteNames.instituteSettings,
        ),
        MenuSubItem(
          id: 'academic_years',
          title: 'Academic Sessions',
          subtitle: 'Configure current academic calendar',
          icon: Icons.date_range_rounded,
          route: RouteNames.academicSessions,
        ),
        MenuSubItem(
          id: 'courses',
          title: 'Courses & Depts',
          subtitle: 'Primary, Secondary, Hifz & Fazilat',
          icon: Icons.account_tree_outlined,
          route: RouteNames.courses,
        ),
        MenuSubItem(
          id: 'classes',
          title: 'Classes & Sections',
          subtitle: 'Student capacity & class allocations',
          icon: Icons.domain_rounded,
          route: RouteNames.classes,
        ),
        MenuSubItem(
          id: 'subjects',
          title: 'Subjects',
          subtitle: 'Curriculum definition & weightage',
          icon: Icons.book_outlined,
          route: RouteNames.subjects,
        ),
        MenuSubItem(
          id: 'books_master',
          title: 'Books',
          subtitle: 'Institute text library inventory',
          icon: Icons.collections_bookmark_outlined,
          route: RouteNames.books,
        ),
        MenuSubItem(
          id: 'exam_settings',
          title: 'Exam Settings',
          subtitle: 'Book marking rules, terms & practical setup',
          icon: Icons.tune_rounded,
          route: RouteNames.examSettings,
        ),
        MenuSubItem(
          id: 'fee_structure',
          title: 'Fee Structure',
          subtitle: 'Class-wise fee installments & discounts',
          icon: Icons.receipt_long_rounded,
          route: RouteNames.feeStructure,
        ),
        MenuSubItem(
          id: 'campus_networks',
          title: 'Campus Wi-Fi Networks',
          subtitle: 'Authorized routers & geofence armor',
          icon: Icons.wifi_tethering_rounded,
          badgeText: 'Armor',
          route: RouteNames.campusNetworks,
        ),
        MenuSubItem(
          id: 'daily_timings',
          title: 'Daily Class Timings',
          subtitle: 'Academic bell times, periods & recess',
          icon: Icons.schedule_rounded,
          badgeText: 'Timings',
          route: RouteNames.dailyTimings,
        ),
        MenuSubItem(
          id: 'academic_holidays',
          title: 'Holidays Calendar',
          subtitle: 'Official religious, national & term breaks',
          icon: Icons.event_available_rounded,
          badgeText: 'Holidays',
          route: RouteNames.academicHolidays,
        ),
        MenuSubItem(
          id: 'attendance_policies',
          title: 'Rules & Policies',
          subtitle: 'Leave quotas, dropout rules & weekly off',
          icon: Icons.verified_user_outlined,
          badgeText: 'Rules',
          route: RouteNames.attendancePolicies,
        ),
      ],
    ),
  ];
}
