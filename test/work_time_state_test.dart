import 'package:flutter_test/flutter_test.dart';
import 'package:smallbusiness/time_recording/models.dart';
import 'package:smallbusiness/time_recording/utils.dart';

void main() {
  test("work time state validation", () {
    WorkTimeState state = WorkTimeState(
        from: DateTime(2023, 1, 31, 15),
        to: DateTime(2023, 1, 31, 14),
        pauses: [],
        now: DateTime(2023, 1, 31, 14, 30));

    expect(state.validateTo(),
        "Die Arbeitszeit darf nicht weniger als 1 Minute betragen.");
  });

  test("work time state validation - pause without to time", () {
    WorkTimeState state = WorkTimeState(
        from: DateTime(2023, 1, 31, 15),
        to: null,
        pauses: [
          Pause(
              from: DateTime(2023, 1, 31, 17),
              to: DateTime(2023, 1, 31, 17, 15))
        ],
        now: DateTime(2023, 1, 31, 1, 30));

    expect(state.validatePauses(), null);
  });

  test("work time state validation - pause after day change", () {
    WorkTimeState state = WorkTimeState(
        from: DateTime(2023, 1, 31, 22),
        to: null,
        pauses: [
          Pause(from: DateTime(2023, 2, 1, 2), to: DateTime(2023, 2, 1, 2, 15))
        ],
        now: DateTime(2023, 2, 1, 2, 30));

    expect(state.validatePauses(), null);
  });

  test("work time state validation - less or equal 6h ", () {
    WorkTimeState state = WorkTimeState(
        from: DateTime(2023, 1, 31, 8),
        to: DateTime(2023, 1, 31, 14),
        pauses: [],
        now: DateTime(2023, 1, 31, 14, 30));

    expect(state.validatePauses(), null);
  });

  test("work time state validation - more than 6h", () {
    WorkTimeState state = WorkTimeState(
        from: DateTime(2023, 1, 31, 8),
        to: DateTime(2023, 1, 31, 14, 30),
        pauses: [],
        now: DateTime(2023, 1, 31, 14, 30));

    expect(state.validatePauses(),
        "Nach 6h Arbeit müssen mindestens 30 Minuten Pause erfasst werden.");
  });

  test("work time state validation - more than 9h", () {
    WorkTimeState state = WorkTimeState(
        from: DateTime(2023, 1, 31, 8),
        to: DateTime(2023, 1, 31, 17, 30),
        pauses: [],
        now: DateTime(2023, 1, 31, 17, 30));

    expect(state.validatePauses(),
        "Nach 9h Arbeit müssen mindestens 45 Minuten Pause erfasst werden.");
  });

  test("work time state validation - more than 9h with pause", () {
    WorkTimeState state = WorkTimeState(
        from: DateTime(2023, 1, 31, 8),
        to: DateTime(2023, 1, 31, 18, 30),
        pauses: [
          Pause(from: DateTime(2023, 1, 31, 12), to: DateTime(2023, 1, 31, 13))
        ],
        now: DateTime(2023, 1, 31, 18, 30));

    expect(state.validatePauses(), null);
  });
}
