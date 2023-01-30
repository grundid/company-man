import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smallbusiness/company/models.dart';
import 'package:smallbusiness/reusable/model_utils.dart';
import 'package:smallbusiness/share/export_utils.dart';
import 'package:smallbusiness/share/share_widget.dart';
import 'package:smallbusiness/time_recording/models.dart';
import 'package:smallbusiness/time_recording/time_recording_list_employee_cubit.dart';

class DummyWage extends WageHolder {
  @override
  final int wageInCent;

  DummyWage(this.wageInCent);
}

class DummyTimeRecording extends TimeRecordingHolder {
  @override
  final DateTime created = DateTime.now();

  @override
  final bool finalized;

  @override
  final DateTime? finalizedDate;

  @override
  final DateTime from;

  @override
  final String? message;

  @override
  final List<Pause> pauses;

  @override
  final DateTime? to;
  DummyTimeRecording({
    this.finalized = true,
    this.finalizedDate,
    required this.from,
    required this.to,
    required this.pauses,
    this.message,
  });
}

void main() {
  test("export", () {
    List<List<String>> csvExport = createEmployeeExport([
      TimeRecordingWithWage(
          DummyTimeRecording(
              from: DateTime(2023, 1, 30, 8),
              to: DateTime(2023, 1, 30, 18),
              pauses: [
                Pause(
                    from: DateTime(2023, 1, 31, 12),
                    to: DateTime(2023, 1, 31, 12, 30)),
                Pause(
                    from: DateTime(2023, 1, 31, 16),
                    to: DateTime(2023, 1, 31, 16, 15)),
              ]),
          DummyWage(2000))
    ]);
    List<String> employeeLine = csvExport.last;

    expect(employeeLine[3], "9h 15m");
    expect(employeeLine[4], "0h 45m");
    expect(employeeLine[5], "12:00-12:30, 16:00-16:15");
  });

  test("export - no pause", () {
    List<List<String>> csvExport = createEmployeeExport([
      TimeRecordingWithWage(
          DummyTimeRecording(
              from: DateTime(2023, 1, 30, 8),
              to: DateTime(2023, 1, 30, 18),
              pauses: []),
          DummyWage(2000))
    ]);
    List<String> employeeLine = csvExport.last;

    expect(employeeLine[3], "10h");
    expect(employeeLine[4], "0h");
    expect(employeeLine[5], "");
  });
}
