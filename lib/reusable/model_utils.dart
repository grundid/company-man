import 'package:smallbusiness/time_recording/models.dart';

abstract class WageHolder {
  int get wageInCent;
}

abstract class TimeRecordingDuration {
  DateTime get from;
  DateTime? get to;
  List<Pause> get pauses;

  Duration? get presenceDuration => to != null ? to!.difference(from) : null;

  Duration? get duration =>
      to != null ? (to!.difference(from) - pauseDuration) : null;

  Duration get pauseDuration => pauses.fold(Duration(minutes: 0),
      (previousValue, element) => previousValue + element.duration);
}

abstract class TimeRecordingHolder extends TimeRecordingDuration {
  String get timeRecordingId;
  String? get message;
  bool get finalized;
  DateTime get created;
  DateTime? get finalizedDate;
}
