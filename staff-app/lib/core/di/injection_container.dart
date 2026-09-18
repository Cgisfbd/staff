import 'package:get_it/get_it.dart';
import 'package:staff_app/core/l10n/locale_cubit.dart';
import 'package:staff_app/core/network/api_client.dart';
import 'package:staff_app/core/network/circuit_breaker.dart';
import 'package:staff_app/core/security/secure_storage_service.dart';
import 'package:staff_app/core/storage/hive_service.dart';
import 'package:staff_app/core/storage/offline_sync_queue.dart';
import 'package:staff_app/core/theme/theme_cubit.dart';
import 'package:staff_app/core/utils/app_logger.dart';
import 'package:staff_app/features/academic_holidays/data/datasources/academic_holidays_remote_datasource.dart';
import 'package:staff_app/features/academic_holidays/data/repositories/academic_holidays_repository_impl.dart';
import 'package:staff_app/features/academic_holidays/domain/repositories/academic_holidays_repository.dart';
import 'package:staff_app/features/academic_holidays/presentation/bloc/academic_holidays_bloc.dart';
import 'package:staff_app/features/academic_sessions/data/datasources/academic_session_remote_datasource.dart';
import 'package:staff_app/features/academic_sessions/data/repositories/academic_session_repository_impl.dart';
import 'package:staff_app/features/academic_sessions/domain/repositories/academic_session_repository.dart';
import 'package:staff_app/features/academic_sessions/domain/usecases/create_academic_session_usecase.dart';
import 'package:staff_app/features/academic_sessions/domain/usecases/get_academic_sessions_usecase.dart';
import 'package:staff_app/features/academic_sessions/domain/usecases/get_next_session_info_usecase.dart';
import 'package:staff_app/features/academic_sessions/domain/usecases/lock_academic_session_usecase.dart';
import 'package:staff_app/features/academic_sessions/presentation/bloc/academic_session_bloc.dart';
import 'package:staff_app/features/attendance_policies/data/datasources/attendance_policies_remote_datasource.dart';
import 'package:staff_app/features/attendance_policies/data/repositories/attendance_policies_repository_impl.dart';
import 'package:staff_app/features/attendance_policies/domain/repositories/attendance_policies_repository.dart';
import 'package:staff_app/features/attendance_policies/presentation/bloc/attendance_policies_bloc.dart';
import 'package:staff_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:staff_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:staff_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:staff_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:staff_app/features/auth/domain/usecases/verify_2fa_usecase.dart';
import 'package:staff_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:staff_app/features/books/data/datasources/book_remote_datasource.dart';
import 'package:staff_app/features/books/data/repositories/book_repository_impl.dart';
import 'package:staff_app/features/books/domain/repositories/book_repository.dart';
import 'package:staff_app/features/books/domain/usecases/book_usecases.dart';
import 'package:staff_app/features/books/presentation/bloc/book_bloc.dart';
import 'package:staff_app/features/campus_networks/data/datasources/campus_network_remote_datasource.dart';
import 'package:staff_app/features/campus_networks/data/repositories/campus_network_repository_impl.dart';
import 'package:staff_app/features/campus_networks/domain/repositories/campus_network_repository.dart';
import 'package:staff_app/features/campus_networks/presentation/bloc/campus_network_bloc.dart';
import 'package:staff_app/features/classes/data/datasources/class_remote_datasource.dart';
import 'package:staff_app/features/classes/data/repositories/class_repository_impl.dart';
import 'package:staff_app/features/classes/domain/repositories/class_repository.dart';
import 'package:staff_app/features/classes/domain/usecases/create_class_usecase.dart';
import 'package:staff_app/features/classes/domain/usecases/delete_class_usecase.dart';
import 'package:staff_app/features/classes/domain/usecases/get_classes_usecase.dart';
import 'package:staff_app/features/classes/domain/usecases/update_class_usecase.dart';
import 'package:staff_app/features/classes/presentation/bloc/class_bloc.dart';
import 'package:staff_app/features/courses/data/datasources/course_remote_datasource.dart';
import 'package:staff_app/features/courses/data/repositories/course_repository_impl.dart';
import 'package:staff_app/features/courses/domain/repositories/course_repository.dart';
import 'package:staff_app/features/courses/domain/usecases/create_course_usecase.dart';
import 'package:staff_app/features/courses/domain/usecases/delete_course_usecase.dart';
import 'package:staff_app/features/courses/domain/usecases/get_courses_usecase.dart';
import 'package:staff_app/features/courses/domain/usecases/update_course_usecase.dart';
import 'package:staff_app/features/courses/presentation/bloc/course_bloc.dart';
import 'package:staff_app/features/daily_timings/data/datasources/daily_timings_remote_datasource.dart';
import 'package:staff_app/features/daily_timings/data/repositories/daily_timings_repository_impl.dart';
import 'package:staff_app/features/daily_timings/domain/repositories/daily_timings_repository.dart';
import 'package:staff_app/features/daily_timings/presentation/bloc/daily_timings_bloc.dart';
import 'package:staff_app/features/exam_settings/presentation/bloc/exam_settings_bloc.dart';
import 'package:staff_app/features/fee_structure/data/datasources/fee_structure_remote_datasource.dart';
import 'package:staff_app/features/fee_structure/data/repositories/fee_structure_repository_impl.dart';
import 'package:staff_app/features/fee_structure/domain/repositories/fee_structure_repository.dart';
import 'package:staff_app/features/fee_structure/presentation/bloc/fee_structure_bloc.dart';
import 'package:staff_app/features/fees_counter/data/datasources/fees_counter_remote_datasource.dart';
import 'package:staff_app/features/fees_counter/data/repositories/fees_counter_repository_impl.dart';
import 'package:staff_app/features/fees_counter/domain/repositories/fees_counter_repository.dart';
import 'package:staff_app/features/fees_counter/domain/usecases/fees_counter_usecases.dart';
import 'package:staff_app/features/fees_counter/presentation/bloc/fees_counter_bloc.dart';
import 'package:staff_app/features/institute_settings/data/datasources/institute_settings_local_datasource.dart';
import 'package:staff_app/features/institute_settings/data/datasources/institute_settings_remote_datasource.dart';
import 'package:staff_app/features/institute_settings/data/repositories/institute_settings_repository_impl.dart';
import 'package:staff_app/features/institute_settings/domain/repositories/institute_settings_repository.dart';
import 'package:staff_app/features/institute_settings/domain/usecases/get_institute_settings_usecase.dart';
import 'package:staff_app/features/institute_settings/domain/usecases/update_institute_settings_usecase.dart';
import 'package:staff_app/features/institute_settings/domain/usecases/upload_branding_asset_usecase.dart';
import 'package:staff_app/features/institute_settings/presentation/bloc/institute_settings_bloc.dart';
import 'package:staff_app/features/salary_counter/data/datasources/salary_counter_remote_datasource.dart';
import 'package:staff_app/features/salary_counter/data/repositories/salary_counter_repository_impl.dart';
import 'package:staff_app/features/salary_counter/domain/repositories/salary_counter_repository.dart';
import 'package:staff_app/features/salary_counter/domain/usecases/salary_counter_usecases.dart';
import 'package:staff_app/features/salary_counter/presentation/bloc/salary_counter_bloc.dart';
import 'package:staff_app/features/settings/data/datasources/profile_remote_datasource.dart';
import 'package:staff_app/features/settings/data/repositories/profile_repository_impl.dart';
import 'package:staff_app/features/settings/domain/repositories/profile_repository.dart';
import 'package:staff_app/features/settings/presentation/cubit/app_lock_cubit.dart';
import 'package:staff_app/features/settings/presentation/cubit/profile_cubit.dart';
import 'package:staff_app/features/splash/data/repositories/splash_repository_impl.dart';
import 'package:staff_app/features/splash/domain/repositories/splash_repository.dart';
import 'package:staff_app/features/splash/domain/usecases/init_app_usecase.dart';
import 'package:staff_app/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:staff_app/features/staff/data/datasources/audit_trail_remote_datasource.dart';
import 'package:staff_app/features/staff/data/datasources/staff_duty_remote_datasource.dart';
import 'package:staff_app/features/staff/data/datasources/staff_leave_remote_datasource.dart';
import 'package:staff_app/features/staff/data/datasources/staff_sub_account_remote_datasource.dart';
import 'package:staff_app/features/staff/data/datasources/teacher_directory_remote_datasource.dart';
import 'package:staff_app/features/staff/data/repositories/staff_duty_repository_impl.dart';
import 'package:staff_app/features/staff/data/repositories/staff_leave_repository_impl.dart';
import 'package:staff_app/features/staff/data/repositories/teacher_directory_repository_impl.dart';
import 'package:staff_app/features/staff/domain/repositories/staff_duty_repository.dart';
import 'package:staff_app/features/staff/domain/repositories/teacher_directory_repository.dart';
import 'package:staff_app/features/staff/presentation/bloc/staff_duty_bloc.dart';
import 'package:staff_app/features/staff/presentation/bloc/staff_leave_bloc.dart';
import 'package:staff_app/features/staff/presentation/bloc/teacher_directory_bloc.dart';
import 'package:staff_app/features/staff_attendance/data/datasources/staff_manual_attendance_remote_datasource.dart';
import 'package:staff_app/features/staff_attendance/data/repositories/staff_attendance_repository_impl.dart';
import 'package:staff_app/features/staff_attendance/domain/repositories/staff_attendance_repository.dart';
import 'package:staff_app/features/staff_attendance/domain/usecases/get_staff_attendance_list_usecase.dart';
import 'package:staff_app/features/staff_attendance/domain/usecases/save_staff_attendance_batch_usecase.dart';
import 'package:staff_app/features/staff_attendance/presentation/bloc/staff_manual_attendance_bloc.dart';
import 'package:staff_app/features/students/data/datasources/student_directory_remote_datasource.dart';
import 'package:staff_app/features/students/data/repositories/student_directory_repository_impl.dart';
import 'package:staff_app/features/students/domain/repositories/student_directory_repository.dart';
import 'package:staff_app/features/students/domain/usecases/get_student_stats_usecase.dart';
import 'package:staff_app/features/students/domain/usecases/get_students_usecase.dart';
import 'package:staff_app/features/students/presentation/bloc/student_directory_bloc.dart';
import 'package:staff_app/features/subjects/data/datasources/subject_remote_datasource.dart';
import 'package:staff_app/features/subjects/data/repositories/subject_repository_impl.dart';
import 'package:staff_app/features/subjects/domain/repositories/subject_repository.dart';
import 'package:staff_app/features/subjects/domain/usecases/subject_usecases.dart';
import 'package:staff_app/features/subjects/presentation/bloc/subject_bloc.dart';

final sl = GetIt.instance;

/// Central Dependency Injection Container (staffRULES.md Rule 2).
Future<void> initServiceLocator() async {
  AppLogger.info('Initializing Service Locator singletons and dependencies...');

  // 1. Core Security & Storage
  sl.registerLazySingleton<SecureStorageService>(() => SecureStorageService());
  sl.registerLazySingleton<HiveService>(() => HiveService(sl<SecureStorageService>()));
  sl.registerLazySingleton<OfflineSyncQueue>(() => OfflineSyncQueue(sl<HiveService>()));
  sl.registerLazySingleton<LocaleCubit>(
    () => LocaleCubit(secureStorage: sl<SecureStorageService>())..init(),
  );
  sl.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(secureStorage: sl<SecureStorageService>())..init(),
  );

  // 2. Core Network & Resilience Gateway
  sl.registerLazySingleton<CircuitBreaker>(() => CircuitBreaker());
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      secureStorage: sl<SecureStorageService>(),
      circuitBreaker: sl<CircuitBreaker>(),
    ),
  );

  // 3. Feature: Splash
  sl.registerLazySingleton<SplashRepository>(
    () => SplashRepositoryImpl(
      secureStorage: sl<SecureStorageService>(),
      hiveService: sl<HiveService>(),
    ),
  );
  sl.registerLazySingleton<InitAppUseCase>(() => InitAppUseCase(sl<SplashRepository>()));
  sl.registerFactory<SplashCubit>(() => SplashCubit(
        initAppUseCase: sl<InitAppUseCase>(),
        getInstituteSettingsUseCase: sl<GetInstituteSettingsUseCase>(),
      ));

  // 4. Feature: Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      apiClient: sl<ApiClient>(),
      secureStorage: sl<SecureStorageService>(),
    ),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl<AuthRemoteDataSource>()),
  );
  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton<Verify2FAUseCase>(() => Verify2FAUseCase(sl<AuthRepository>()));
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUseCase: sl<LoginUseCase>(),
      verify2faUseCase: sl<Verify2FAUseCase>(),
      authRepository: sl<AuthRepository>(),
    ),
  );

  // 5. Feature: Settings & Security Enclave
  sl.registerLazySingleton<AppLockCubit>(
    () => AppLockCubit(secureStorage: sl<SecureStorageService>()),
  );
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl<ProfileRemoteDataSource>()),
  );
  sl.registerFactory<ProfileCubit>(
    () => ProfileCubit(
      profileRepository: sl<ProfileRepository>(),
      secureStorage: sl<SecureStorageService>(),
    ),
  );

  // 6. Feature: Students Directory & Admissions
  sl.registerLazySingleton<StudentDirectoryRemoteDataSource>(
    () => StudentDirectoryRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<StudentDirectoryRepository>(
    () => StudentDirectoryRepositoryImpl(remoteDataSource: sl<StudentDirectoryRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetStudentsUseCase>(
    () => GetStudentsUseCase(sl<StudentDirectoryRepository>()),
  );
  sl.registerLazySingleton<GetStudentStatsUseCase>(
    () => GetStudentStatsUseCase(sl<StudentDirectoryRepository>()),
  );
  sl.registerFactory<StudentDirectoryBloc>(
    () => StudentDirectoryBloc(
      getStudentsUseCase: sl<GetStudentsUseCase>(),
      getStudentStatsUseCase: sl<GetStudentStatsUseCase>(),
    ),
  );

  // 12. Teachers & Staff Directory
  sl.registerLazySingleton<TeacherDirectoryRemoteDataSource>(
    () => TeacherDirectoryRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<TeacherDirectoryRepository>(
    () => TeacherDirectoryRepositoryImpl(remoteDataSource: sl<TeacherDirectoryRemoteDataSource>()),
  );
  sl.registerFactory<TeacherDirectoryBloc>(
    () => TeacherDirectoryBloc(repository: sl<TeacherDirectoryRepository>()),
  );

  // 13. Staff Academic Duty Allocations (Classes & Books)
  sl.registerLazySingleton<StaffDutyRemoteDataSource>(
    () => StaffDutyRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<StaffDutyRepository>(
    () => StaffDutyRepositoryImpl(remoteDataSource: sl<StaffDutyRemoteDataSource>()),
  );
  sl.registerFactory<StaffDutyBloc>(
    () => StaffDutyBloc(repository: sl<StaffDutyRepository>()),
  );

  // 14. Staff Leaves Management (Chhutti & Rukhsat)
  sl.registerLazySingleton<StaffLeaveRemoteDataSource>(
    () => StaffLeaveRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<StaffLeaveRepository>(
    () => StaffLeaveRepositoryImpl(remoteDataSource: sl<StaffLeaveRemoteDataSource>()),
  );
  sl.registerFactory<StaffLeaveBloc>(
    () => StaffLeaveBloc(repository: sl<StaffLeaveRepository>()),
  );

  // 14.B Super Admin Staff Manual Attendance & Punch Station
  sl.registerLazySingleton<StaffManualAttendanceRemoteDataSource>(
    () => StaffManualAttendanceRemoteDataSourceImpl(
      teacherDirectoryRepository: sl<TeacherDirectoryRepository>(),
      secureStorage: sl<SecureStorageService>(),
    ),
  );
  sl.registerLazySingleton<StaffAttendanceRepository>(
    () => StaffAttendanceRepositoryImpl(
      remoteDataSource: sl<StaffManualAttendanceRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton<GetStaffAttendanceListUseCase>(
    () => GetStaffAttendanceListUseCase(sl<StaffAttendanceRepository>()),
  );
  sl.registerLazySingleton<SaveStaffAttendanceBatchUseCase>(
    () => SaveStaffAttendanceBatchUseCase(sl<StaffAttendanceRepository>()),
  );
  sl.registerFactory<StaffManualAttendanceBloc>(
    () => StaffManualAttendanceBloc(
      getStaffAttendanceListUseCase: sl<GetStaffAttendanceListUseCase>(),
      saveStaffAttendanceBatchUseCase: sl<SaveStaffAttendanceBatchUseCase>(),
    ),
  );

  // 15. Staff Sub-Accounts & Delegation
  sl.registerLazySingleton<StaffSubAccountRemoteDataSource>(
    () => StaffSubAccountRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // 16. System Audit Trail (Forensic Logbook)
  sl.registerLazySingleton<AuditTrailRemoteDataSource>(
    () => AuditTrailRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // 17. Academic Sessions (Calendar & Fiscal Setup)
  sl.registerLazySingleton<AcademicSessionRemoteDataSource>(
    () => AcademicSessionRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<AcademicSessionRepository>(
    () => AcademicSessionRepositoryImpl(remoteDataSource: sl<AcademicSessionRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetAcademicSessionsUseCase>(
    () => GetAcademicSessionsUseCase(sl<AcademicSessionRepository>()),
  );
  sl.registerLazySingleton<GetNextSessionInfoUseCase>(
    () => GetNextSessionInfoUseCase(sl<AcademicSessionRepository>()),
  );
  sl.registerLazySingleton<CreateAcademicSessionUseCase>(
    () => CreateAcademicSessionUseCase(sl<AcademicSessionRepository>()),
  );
  sl.registerLazySingleton<LockAcademicSessionUseCase>(
    () => LockAcademicSessionUseCase(sl<AcademicSessionRepository>()),
  );
  sl.registerFactory<AcademicSessionBloc>(
    () => AcademicSessionBloc(
      getAcademicSessionsUseCase: sl<GetAcademicSessionsUseCase>(),
      getNextSessionInfoUseCase: sl<GetNextSessionInfoUseCase>(),
      createAcademicSessionUseCase: sl<CreateAcademicSessionUseCase>(),
      lockAcademicSessionUseCase: sl<LockAcademicSessionUseCase>(),
    ),
  );

  // 18. Courses & Departments (Hierarchy & Curriculum Streams)
  sl.registerLazySingleton<CourseRemoteDataSource>(
    () => CourseRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<CourseRepository>(
    () => CourseRepositoryImpl(remoteDataSource: sl<CourseRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetCoursesUseCase>(
    () => GetCoursesUseCase(sl<CourseRepository>()),
  );
  sl.registerLazySingleton<CreateCourseUseCase>(
    () => CreateCourseUseCase(sl<CourseRepository>()),
  );
  sl.registerLazySingleton<UpdateCourseUseCase>(
    () => UpdateCourseUseCase(sl<CourseRepository>()),
  );
  sl.registerLazySingleton<DeleteCourseUseCase>(
    () => DeleteCourseUseCase(sl<CourseRepository>()),
  );
  sl.registerFactory<CourseBloc>(
    () => CourseBloc(
      getCoursesUseCase: sl<GetCoursesUseCase>(),
      createCourseUseCase: sl<CreateCourseUseCase>(),
      updateCourseUseCase: sl<UpdateCourseUseCase>(),
      deleteCourseUseCase: sl<DeleteCourseUseCase>(),
    ),
  );

  // Classes & Sections
  sl.registerLazySingleton<ClassRemoteDataSource>(
    () => ClassRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<ClassRepository>(
    () => ClassRepositoryImpl(remoteDataSource: sl<ClassRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetClassesUseCase>(
    () => GetClassesUseCase(sl<ClassRepository>()),
  );
  sl.registerLazySingleton<CreateClassUseCase>(
    () => CreateClassUseCase(sl<ClassRepository>()),
  );
  sl.registerLazySingleton<UpdateClassUseCase>(
    () => UpdateClassUseCase(sl<ClassRepository>()),
  );
  sl.registerLazySingleton<DeleteClassUseCase>(
    () => DeleteClassUseCase(sl<ClassRepository>()),
  );
  sl.registerFactory<ClassBloc>(
    () => ClassBloc(
      getClassesUseCase: sl<GetClassesUseCase>(),
      getCoursesUseCase: sl<GetCoursesUseCase>(),
      createClassUseCase: sl<CreateClassUseCase>(),
      updateClassUseCase: sl<UpdateClassUseCase>(),
      deleteClassUseCase: sl<DeleteClassUseCase>(),
    ),
  );

  // Subjects & Syllabus
  sl.registerLazySingleton<SubjectRemoteDataSource>(
    () => SubjectRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<SubjectRepository>(
    () => SubjectRepositoryImpl(remoteDataSource: sl<SubjectRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetSubjectsUseCase>(
    () => GetSubjectsUseCase(sl<SubjectRepository>()),
  );
  sl.registerLazySingleton<CreateSubjectUseCase>(
    () => CreateSubjectUseCase(sl<SubjectRepository>()),
  );
  sl.registerLazySingleton<UpdateSubjectUseCase>(
    () => UpdateSubjectUseCase(sl<SubjectRepository>()),
  );
  sl.registerLazySingleton<DeleteSubjectUseCase>(
    () => DeleteSubjectUseCase(sl<SubjectRepository>()),
  );
  sl.registerFactory<SubjectBloc>(
    () => SubjectBloc(
      getSubjectsUseCase: sl<GetSubjectsUseCase>(),
      createSubjectUseCase: sl<CreateSubjectUseCase>(),
      updateSubjectUseCase: sl<UpdateSubjectUseCase>(),
      deleteSubjectUseCase: sl<DeleteSubjectUseCase>(),
      getCoursesUseCase: sl<GetCoursesUseCase>(),
      getClassesUseCase: sl<GetClassesUseCase>(),
    ),
  );

  // Books
  sl.registerLazySingleton<BookRemoteDataSource>(
    () => BookRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<BookRepository>(
    () => BookRepositoryImpl(remoteDataSource: sl<BookRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetBooksUseCase>(
    () => GetBooksUseCase(sl<BookRepository>()),
  );
  sl.registerLazySingleton<CreateBookUseCase>(
    () => CreateBookUseCase(sl<BookRepository>()),
  );
  sl.registerLazySingleton<UpdateBookUseCase>(
    () => UpdateBookUseCase(sl<BookRepository>()),
  );
  sl.registerLazySingleton<DeleteBookUseCase>(
    () => DeleteBookUseCase(sl<BookRepository>()),
  );
  sl.registerFactory<BookBloc>(
    () => BookBloc(
      getBooksUseCase: sl<GetBooksUseCase>(),
      createBookUseCase: sl<CreateBookUseCase>(),
      updateBookUseCase: sl<UpdateBookUseCase>(),
      deleteBookUseCase: sl<DeleteBookUseCase>(),
      getSubjectsUseCase: sl<GetSubjectsUseCase>(),
    ),
  );

  // Exam Settings
  sl.registerFactory<ExamSettingsBloc>(
    () => ExamSettingsBloc(
      getCoursesUseCase: sl<GetCoursesUseCase>(),
      getClassesUseCase: sl<GetClassesUseCase>(),
      getSubjectsUseCase: sl<GetSubjectsUseCase>(),
      getBooksUseCase: sl<GetBooksUseCase>(),
      updateBookUseCase: sl<UpdateBookUseCase>(),
    ),
  );

  // Fee Structure
  sl.registerLazySingleton<FeeStructureRemoteDataSource>(
    () => FeeStructureRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<FeeStructureRepository>(
    () => FeeStructureRepositoryImpl(remoteDataSource: sl<FeeStructureRemoteDataSource>()),
  );
  sl.registerFactory<FeeStructureBloc>(
    () => FeeStructureBloc(
      feeStructureRepository: sl<FeeStructureRepository>(),
      getCoursesUseCase: sl<GetCoursesUseCase>(),
      getClassesUseCase: sl<GetClassesUseCase>(),
    ),
  );

  // Campus Wi-Fi Networks
  sl.registerLazySingleton<CampusNetworkRemoteDataSource>(
    () => CampusNetworkRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<CampusNetworkRepository>(
    () => CampusNetworkRepositoryImpl(remoteDataSource: sl<CampusNetworkRemoteDataSource>()),
  );
  sl.registerFactory<CampusNetworkBloc>(
    () => CampusNetworkBloc(repository: sl<CampusNetworkRepository>()),
  );

  // Daily Class Timings (Academic Bell Times & Recess)
  sl.registerLazySingleton<DailyTimingsRemoteDataSource>(
    () => DailyTimingsRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<DailyTimingsRepository>(
    () => DailyTimingsRepositoryImpl(remoteDataSource: sl<DailyTimingsRemoteDataSource>()),
  );
  sl.registerFactory<DailyTimingsBloc>(
    () => DailyTimingsBloc(
      dailyTimingsRepository: sl<DailyTimingsRepository>(),
      academicSessionRepository: sl<AcademicSessionRepository>(),
    ),
  );

  // Academic Holidays (Calendar Setup)
  sl.registerLazySingleton<AcademicHolidaysRemoteDataSource>(
    () => AcademicHolidaysRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<AcademicHolidaysRepository>(
    () => AcademicHolidaysRepositoryImpl(remoteDataSource: sl<AcademicHolidaysRemoteDataSource>()),
  );
  sl.registerFactory<AcademicHolidaysBloc>(
    () => AcademicHolidaysBloc(
      academicHolidaysRepository: sl<AcademicHolidaysRepository>(),
      academicSessionRepository: sl<AcademicSessionRepository>(),
    ),
  );

  // Attendance Rules & Policies
  sl.registerLazySingleton<AttendancePoliciesRemoteDataSource>(
    () => AttendancePoliciesRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<AttendancePoliciesRepository>(
    () => AttendancePoliciesRepositoryImpl(remoteDataSource: sl<AttendancePoliciesRemoteDataSource>()),
  );
  sl.registerFactory<AttendancePoliciesBloc>(
    () => AttendancePoliciesBloc(
      attendancePoliciesRepository: sl<AttendancePoliciesRepository>(),
      academicSessionRepository: sl<AcademicSessionRepository>(),
    ),
  );

  // Institute Settings (Branding, Logo, Banner & Metadata)
  sl.registerLazySingleton<InstituteSettingsRemoteDataSource>(
    () => InstituteSettingsRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<InstituteSettingsLocalDataSource>(
    () => InstituteSettingsLocalDataSourceImpl(
      hiveService: sl<HiveService>(),
      offlineSyncQueue: sl<OfflineSyncQueue>(),
    ),
  );
  sl.registerLazySingleton<InstituteSettingsRepository>(
    () => InstituteSettingsRepositoryImpl(
      remoteDataSource: sl<InstituteSettingsRemoteDataSource>(),
      localDataSource: sl<InstituteSettingsLocalDataSource>(),
    ),
  );
  sl.registerLazySingleton<GetInstituteSettingsUseCase>(
    () => GetInstituteSettingsUseCase(sl<InstituteSettingsRepository>()),
  );
  sl.registerLazySingleton<UpdateInstituteSettingsUseCase>(
    () => UpdateInstituteSettingsUseCase(sl<InstituteSettingsRepository>()),
  );
  sl.registerLazySingleton<UploadBrandingAssetUseCase>(
    () => UploadBrandingAssetUseCase(sl<InstituteSettingsRepository>()),
  );
  sl.registerFactory<InstituteSettingsBloc>(
    () => InstituteSettingsBloc(
      getInstituteSettingsUseCase: sl<GetInstituteSettingsUseCase>(),
      updateInstituteSettingsUseCase: sl<UpdateInstituteSettingsUseCase>(),
      uploadBrandingAssetUseCase: sl<UploadBrandingAssetUseCase>(),
    ),
  );

  // Fees Counter (Live Cash Counter & 10-Month Matrix)
  sl.registerLazySingleton<FeesCounterRemoteDataSource>(
    () => FeesCounterRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<FeesCounterRepository>(
    () => FeesCounterRepositoryImpl(remoteDataSource: sl<FeesCounterRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetFeesKpiUseCase>(() => GetFeesKpiUseCase(sl<FeesCounterRepository>()));
  sl.registerLazySingleton<GetCoursesSummaryUseCase>(() => GetCoursesSummaryUseCase(sl<FeesCounterRepository>()));
  sl.registerLazySingleton<GetClassesForCourseUseCase>(() => GetClassesForCourseUseCase(sl<FeesCounterRepository>()));
  sl.registerLazySingleton<GetStudentsForClassUseCase>(() => GetStudentsForClassUseCase(sl<FeesCounterRepository>()));
  sl.registerLazySingleton<GetPaymentHistoryForStudentUseCase>(() => GetPaymentHistoryForStudentUseCase(sl<FeesCounterRepository>()));
  sl.registerLazySingleton<DepositFeeUseCase>(() => DepositFeeUseCase(sl<FeesCounterRepository>()));
  sl.registerLazySingleton<WaiveFeeUseCase>(() => WaiveFeeUseCase(sl<FeesCounterRepository>()));
  sl.registerFactory<FeesCounterBloc>(
    () => FeesCounterBloc(
      getFeesKpiUseCase: sl<GetFeesKpiUseCase>(),
      getCoursesSummaryUseCase: sl<GetCoursesSummaryUseCase>(),
      getClassesForCourseUseCase: sl<GetClassesForCourseUseCase>(),
      getStudentsForClassUseCase: sl<GetStudentsForClassUseCase>(),
      getPaymentHistoryForStudentUseCase: sl<GetPaymentHistoryForStudentUseCase>(),
      depositFeeUseCase: sl<DepositFeeUseCase>(),
      waiveFeeUseCase: sl<WaiveFeeUseCase>(),
    ),
  );

  // Salary Counter (Faculty Payroll & 11-Month Matrix)
  sl.registerLazySingleton<SalaryCounterRemoteDataSource>(
    () => SalaryCounterRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<SalaryCounterRepository>(
    () => SalaryCounterRepositoryImpl(remoteDataSource: sl<SalaryCounterRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetInstitutionalSalaryStatsUseCase>(() => GetInstitutionalSalaryStatsUseCase(sl<SalaryCounterRepository>()));
  sl.registerLazySingleton<GetFacultySalaryListUseCase>(() => GetFacultySalaryListUseCase(sl<SalaryCounterRepository>()));
  sl.registerLazySingleton<GetPaymentHistoryForFacultyUseCase>(() => GetPaymentHistoryForFacultyUseCase(sl<SalaryCounterRepository>()));
  sl.registerLazySingleton<DisburseSalaryUseCase>(() => DisburseSalaryUseCase(sl<SalaryCounterRepository>()));
  sl.registerFactory<SalaryCounterBloc>(
    () => SalaryCounterBloc(
      getInstitutionalSalaryStatsUseCase: sl<GetInstitutionalSalaryStatsUseCase>(),
      getFacultySalaryListUseCase: sl<GetFacultySalaryListUseCase>(),
      getPaymentHistoryForFacultyUseCase: sl<GetPaymentHistoryForFacultyUseCase>(),
      disburseSalaryUseCase: sl<DisburseSalaryUseCase>(),
    ),
  );

  AppLogger.info('Service Locator initialization complete.');
}
