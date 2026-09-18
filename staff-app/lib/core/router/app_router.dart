import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:staff_app/core/router/route_names.dart';
import 'package:staff_app/core/widgets/main_navigation_shell.dart';
import 'package:staff_app/features/academic_holidays/presentation/pages/academic_holidays_page.dart';
import 'package:staff_app/features/academic_sessions/presentation/pages/academic_sessions_page.dart';
import 'package:staff_app/features/attendance/presentation/pages/attendance_page.dart';
import 'package:staff_app/features/attendance/presentation/pages/qr_attendance_page.dart';
import 'package:staff_app/features/attendance/presentation/pages/staff_attendance_history_page.dart';
import 'package:staff_app/features/attendance_policies/presentation/pages/attendance_policies_page.dart';
import 'package:staff_app/features/auth/presentation/pages/login_page.dart';
import 'package:staff_app/features/books/presentation/pages/books_page.dart';
import 'package:staff_app/features/campus_networks/presentation/pages/campus_networks_page.dart';
import 'package:staff_app/features/classes/presentation/pages/classes_page.dart';
import 'package:staff_app/features/courses/presentation/pages/courses_page.dart';
import 'package:staff_app/features/daily_timings/presentation/pages/daily_timings_page.dart';
import 'package:staff_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:staff_app/features/exam_settings/presentation/pages/exam_settings_page.dart';
import 'package:staff_app/features/examination/presentation/pages/examination_results_page.dart';
import 'package:staff_app/features/examination/presentation/pages/question_upload_page.dart';
import 'package:staff_app/features/examination/presentation/pages/student_marks_entry_page.dart';
import 'package:staff_app/features/fee_structure/presentation/pages/fee_structure_page.dart';
import 'package:staff_app/features/fees_counter/presentation/pages/fees_counter_page.dart';
import 'package:staff_app/features/institute_settings/presentation/pages/institute_settings_page.dart';
import 'package:staff_app/features/menu/presentation/pages/menu_page.dart';
import 'package:staff_app/features/notifications/presentation/pages/notifications_page.dart';
import 'package:staff_app/features/salary/presentation/pages/staff_salary_page.dart';
import 'package:staff_app/features/salary_counter/presentation/pages/salary_counter_page.dart';
import 'package:staff_app/features/search/presentation/pages/search_page.dart';
import 'package:staff_app/features/settings/presentation/pages/settings_page.dart';
import 'package:staff_app/features/splash/presentation/pages/splash_page.dart';
import 'package:staff_app/features/staff/data/models/staff_sub_account_model.dart';
import 'package:staff_app/features/staff/presentation/pages/add_teacher_page.dart';
import 'package:staff_app/features/staff/presentation/pages/all_teachers_page.dart';
import 'package:staff_app/features/staff/presentation/pages/apply_leave_page.dart';
import 'package:staff_app/features/staff/presentation/pages/create_sub_account_page.dart';
import 'package:staff_app/features/staff/presentation/pages/duty_allocations_page.dart';
import 'package:staff_app/features/staff/presentation/pages/staff_leaves_page.dart';
import 'package:staff_app/features/staff/presentation/pages/staff_permissions_page.dart';
import 'package:staff_app/features/staff/presentation/pages/staff_sub_accounts_page.dart';
import 'package:staff_app/features/staff/presentation/pages/system_audit_trail_page.dart';
import 'package:staff_app/features/staff_attendance/presentation/pages/staff_manual_attendance_page.dart';
import 'package:staff_app/features/students/presentation/pages/all_students_page.dart';
import 'package:staff_app/features/students/presentation/pages/student_admission_page.dart';
import 'package:staff_app/features/students/presentation/pages/students_page.dart';
import 'package:staff_app/features/subjects/presentation/pages/subjects_page.dart';
import 'package:staff_app/features/visitors/presentation/pages/visitor_scanner_page.dart';

/// Centralized GoRouter setup with 5-tab StatefulShellRoute (< 85 lines).
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RouteNames.splash,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.notifications,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: RouteNames.search,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        path: RouteNames.staffAttendanceHistory,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const StaffAttendanceHistoryPage(),
      ),
      GoRoute(
        path: RouteNames.staffSalary,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const StaffSalaryPage(),
      ),
      GoRoute(
        path: RouteNames.qrAttendance,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const QrAttendancePage(),
      ),
      GoRoute(
        path: RouteNames.questionUpload,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const QuestionUploadPage(),
      ),
      GoRoute(
        path: RouteNames.marksEntry,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const StudentMarksEntryPage(),
      ),
      GoRoute(
        path: RouteNames.visitorScanner,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const VisitorScannerPage(),
      ),
      GoRoute(
        path: RouteNames.examinationResults,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ExaminationResultsPage(),
      ),
      GoRoute(
        path: RouteNames.studentAdmission,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const StudentAdmissionPage(),
      ),
      GoRoute(
        path: RouteNames.allStudents,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AllStudentsPage(),
      ),
      GoRoute(
        path: RouteNames.allStaff,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AllTeachersPage(),
      ),
      GoRoute(
        path: RouteNames.addStaff,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AddTeacherPage(),
      ),
      GoRoute(
        path: RouteNames.dutyAllocation,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const DutyAllocationsPage(),
      ),
      GoRoute(
        path: RouteNames.staffLeaves,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const StaffLeavesPage(),
      ),
      GoRoute(
        path: RouteNames.applyLeave,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ApplyLeavePage(),
      ),
      GoRoute(
        path: RouteNames.staffSubAccounts,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _slideTransition(
          state.pageKey,
          const StaffSubAccountsPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.createSubAccount,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final account = state.extra as StaffSubAccountModel?;
          return _slideTransition(
            state.pageKey,
            CreateSubAccountPage(initialAccount: account),
          );
        },
      ),
      GoRoute(
        path: RouteNames.staffPermissions,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final account = state.extra as StaffSubAccountModel?;
          return _slideTransition(
            state.pageKey,
            StaffPermissionsPage(initialAccount: account),
          );
        },
      ),
      GoRoute(
        path: RouteNames.systemAuditTrail,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _slideTransition(
          state.pageKey,
          const SystemAuditTrailPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.academicSessions,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _slideTransition(
          state.pageKey,
          const AcademicSessionsPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.courses,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _slideTransition(
          state.pageKey,
          const CoursesPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.classes,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _slideTransition(
          state.pageKey,
          const ClassesPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.subjects,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _slideTransition(
          state.pageKey,
          const SubjectsPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.books,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _slideTransition(
          state.pageKey,
          BooksPage(
            initialSubjectId: state.uri.queryParameters['subjectId'],
          ),
        ),
      ),
      GoRoute(
        path: RouteNames.examSettings,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _slideTransition(
          state.pageKey,
          const ExamSettingsPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.feeStructure,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _slideTransition(
          state.pageKey,
          const FeeStructurePage(),
        ),
      ),
      GoRoute(
        path: RouteNames.feesCounter,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _slideTransition(
          state.pageKey,
          const FeesCounterPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.salaryCounter,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _slideTransition(
          state.pageKey,
          const SalaryCounterPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.campusNetworks,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _slideTransition(
          state.pageKey,
          const CampusNetworksPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.dailyTimings,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _slideTransition(
          state.pageKey,
          const DailyTimingsPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.academicHolidays,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _slideTransition(
          state.pageKey,
          const AcademicHolidaysPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.attendancePolicies,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _slideTransition(
          state.pageKey,
          const AttendancePoliciesPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.instituteSettings,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _slideTransition(
          state.pageKey,
          const InstituteSettingsPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.staffManualAttendance,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _slideTransition(
          state.pageKey,
          const StaffManualAttendancePage(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainNavigationShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.dashboard,
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.attendance,
                builder: (context, state) => const AttendancePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.students,
                builder: (context, state) => const StudentsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.menu,
                builder: (context, state) => const MenuPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.settings,
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  /// Smooth horizontal push transition (Right to Left), eliminating bottom-sliding sheets
  static Page<dynamic> _slideTransition(LocalKey key, Widget child) {
    return CustomTransitionPage<dynamic>(
      key: key,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeInOutCubic));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
