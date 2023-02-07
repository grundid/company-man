import 'package:flutter_test/flutter_test.dart';
import 'package:smallbusiness/reusable/model_utils.dart';
import 'package:smallbusiness/time_recording/models.dart';
import 'package:smallbusiness/time_recording/utils.dart';

class DummyTimeRecording extends TimeRecordingDuration {
  @override
  final DateTime from;
  @override
  final DateTime? to;

  DummyTimeRecording(this.from, this.to);

  @override
  List<Pause> get pauses => [];
}

void main() {
  DummyTimeRecording tr(int fromHour, int? toHour) {
    return DummyTimeRecording(DateTime(2023, 2, 6, fromHour),
        toHour != null ? DateTime(2023, 2, 6, toHour) : null);
  }

  test("isOverlapping - open end", () {
    DummyTimeRecording tr1 = tr(10, null);
    expect(isOverlapping(tr1, tr1), true);
  });
  test("isOverlapping", () {
    expect(isOverlapping(tr(10, 18), tr(10, null)), true);
    expect(isOverlapping(tr(10, 18), tr(11, null)), true);
    expect(isOverlapping(tr(10, 18), tr(10, 18)), true);
    expect(isOverlapping(tr(10, 18), tr(9, 18)), true);
    expect(isOverlapping(tr(10, 18), tr(9, 17)), true);
    expect(isOverlapping(tr(10, 18), tr(11, 17)), true);
    expect(isOverlapping(tr(10, 18), tr(11, 19)), true);
    expect(isOverlapping(tr(12, null), tr(11, 19)), true);
  });

  test("isOverlapping false", () {
    expect(isOverlapping(tr(10, 18), tr(18, null)), false);
    expect(isOverlapping(tr(10, 18), tr(18, 19)), false);
    expect(isOverlapping(tr(10, 18), tr(9, 10)), false);
  });
}
