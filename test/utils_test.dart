import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smallbusiness/time_recording/utils.dart';

void main() {
  test("createFrom", () {
    expect(
        createFrom(DateTime(2023, 1, 31, 22), TimeOfDay(hour: 1, minute: 15))
            .toIso8601String(),
        "2023-02-01T01:15:00.000");
    expect(
        createFrom(DateTime(2023, 1, 31, 22), TimeOfDay(hour: 23, minute: 15))
            .toIso8601String(),
        "2023-01-31T23:15:00.000");
    expect(
        createFrom(DateTime(2023, 1, 31, 0, 0), TimeOfDay(hour: 15, minute: 15))
            .toIso8601String(),
        "2023-01-31T15:15:00.000");
  });
}
