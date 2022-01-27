// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SbmUserModel _$SbmUserModelFromJson(Map<String, dynamic> json) => SbmUserModel(
      anonReminder: fromTimeStamp(json['anonReminder']),
    );

Map<String, dynamic> _$SbmUserModelToJson(SbmUserModel instance) =>
    <String, dynamic>{
      'anonReminder': toTimeStamp(instance.anonReminder),
    };
