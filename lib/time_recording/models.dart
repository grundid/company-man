import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:smallbusiness/reusable/converter.dart';
import 'package:smallbusiness/reusable/user_actions/models.dart';

part 'models.g.dart';

@JsonSerializable(explicitToJson: true)
class Pause implements Comparable<Pause> {
  @JsonKey(toJson: toTimeStamp, fromJson: fromTimeStamp)
  DateTime from;
  @JsonKey(toJson: toTimeStamp, fromJson: fromTimeStamp)
  DateTime to;
  Pause({
    required this.from,
    required this.to,
  });

  factory Pause.fromJson(DynamicMap data) {
    return _$PauseFromJson(data);
  }

  DynamicMap toJson() {
    return _$PauseToJson(this);
  }

  Duration get duration => to.difference(from);

  @override
  int compareTo(Pause other) {
    return from.compareTo(other.from);
  }
}

@JsonSerializable(explicitToJson: true)
class TimeRecording {
  @JsonKey(ignore: true)
  DocumentReference<DynamicMap>? timeRecordingRef;
  @JsonKey(toJson: refConverter, fromJson: refConverter)
  final DocumentReference<DynamicMap> employeeRef;
  @JsonKey(toJson: refConverter, fromJson: refConverter)
  final DocumentReference<DynamicMap> companyRef;
  @JsonKey(toJson: toTimeStamp, fromJson: fromTimeStamp)
  DateTime from;
  @JsonKey(toJson: toTimeStamp, fromJson: fromTimeStamp)
  DateTime? to;
  List<Pause> pauses;
  String? message;
  bool finalized;
  @JsonKey(toJson: toTimeStamp, fromJson: fromTimeStamp)
  late DateTime created;
  @JsonKey(toJson: toTimeStamp, fromJson: fromTimeStamp)
  DateTime? finalizedDate;
  TimeRecording({
    required this.employeeRef,
    required this.companyRef,
    required this.from,
    required this.to,
    required this.pauses,
    required this.message,
    required this.finalized,
    required this.created,
    required this.finalizedDate,
  });

  factory TimeRecording.fromSnapshot(
      DocumentReference<DynamicMap> timeRecordingRef, DynamicMap data) {
    TimeRecording result = _$TimeRecordingFromJson(data);
    result.timeRecordingRef = timeRecordingRef;
    return result;
  }

  DynamicMap toJson() {
    return _$TimeRecordingToJson(this);
  }

  Duration? get duration =>
      to != null ? (to!.difference(from) - pauseDuration) : null;

  Duration get pauseDuration => pauses.fold(Duration(minutes: 0),
      (previousValue, element) => previousValue + element.duration);
}
