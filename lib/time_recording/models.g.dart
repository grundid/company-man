// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pause _$PauseFromJson(Map<String, dynamic> json) => Pause(
      from: fromTimeStamp(json['from']),
      to: fromTimeStamp(json['to']),
    );

Map<String, dynamic> _$PauseToJson(Pause instance) => <String, dynamic>{
      'from': toTimeStamp(instance.from),
      'to': toTimeStamp(instance.to),
    };

TimeRecording _$TimeRecordingFromJson(Map<String, dynamic> json) =>
    TimeRecording(
      employeeRef: refConverter(json['employeeRef']),
      companyRef: refConverter(json['companyRef']),
      from: fromTimeStamp(json['from']),
      to: fromTimeStamp(json['to']),
      pauses: (json['pauses'] as List<dynamic>)
          .map((e) => Pause.fromJson(e as Map<String, dynamic>))
          .toList(),
      message: json['message'] as String?,
      managerMessage: json['managerMessage'] as String?,
      finalized: json['finalized'] as bool,
      created: fromTimeStamp(json['created']),
      finalizedDate: fromTimeStamp(json['finalizedDate']),
    );

Map<String, dynamic> _$TimeRecordingToJson(TimeRecording instance) =>
    <String, dynamic>{
      'employeeRef': refConverter(instance.employeeRef),
      'companyRef': refConverter(instance.companyRef),
      'from': toTimeStamp(instance.from),
      'to': toTimeStamp(instance.to),
      'pauses': instance.pauses.map((e) => e.toJson()).toList(),
      'message': instance.message,
      'managerMessage': instance.managerMessage,
      'finalized': instance.finalized,
      'created': toTimeStamp(instance.created),
      'finalizedDate': toTimeStamp(instance.finalizedDate),
    };
