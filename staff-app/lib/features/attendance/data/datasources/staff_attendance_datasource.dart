import 'package:staff_app/features/attendance/domain/models/staff_attendance_record.dart';

/// Datasource providing staff member's personal attendance history logs.
class StaffAttendanceDatasource {
  const StaffAttendanceDatasource();

  List<StaffAttendanceRecord> getMonthlyRecords({required int year, required int month}) {
    // Generate realistic logs for the selected month
    final List<StaffAttendanceRecord> records = [];
    final daysInMonth = DateTime(year, month + 1, 0).day;

    for (int day = daysInMonth; day >= 1; day--) {
      final date = DateTime(year, month, day);

      // Sunday = Weekly Holiday
      if (date.weekday == DateTime.sunday) {
        records.add(StaffAttendanceRecord(
          id: 'att_${year}_${month}_$day',
          date: date,
          status: StaffAttendanceStatus.holiday,
          notes: 'Weekly Institutional Holiday',
        ));
        continue;
      }

      // 4th and 18th = Leaves
      if (day == 4 || day == 18) {
        records.add(StaffAttendanceRecord(
          id: 'att_${year}_${month}_$day',
          date: date,
          status: StaffAttendanceStatus.leave,
          leaveType: day == 4 ? 'Casual Leave' : 'Medical Leave',
          notes: 'Approved by Administration',
        ));
        continue;
      }

      // 9th = Absent
      if (day == 9) {
        records.add(StaffAttendanceRecord(
          id: 'att_${year}_${month}_$day',
          date: date,
          status: StaffAttendanceStatus.absent,
          notes: 'Unannounced Absence',
        ));
        continue;
      }

      // Other weekdays = Present with realistic punch in/out
      final inMinutes = (day * 3) % 25; // 08:30 to 08:55
      final outMinutes = (day * 4) % 30; // 05:00 to 05:30
      final inTimeStr = '08:${inMinutes.toString().padLeft(2, '0')} AM';
      final outTimeStr = '05:${outMinutes.toString().padLeft(2, '0')} PM';

      records.add(StaffAttendanceRecord(
        id: 'att_${year}_${month}_$day',
        date: date,
        status: StaffAttendanceStatus.present,
        inTime: inTimeStr,
        outTime: outTimeStr,
        workingHours: '8h 35m',
      ));
    }

    return records;
  }
}
