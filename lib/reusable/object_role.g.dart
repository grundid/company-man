// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'object_role.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ObjectRole _$ObjectRoleFromJson(Map<String, dynamic> json) => ObjectRole(
      companyRef: refConverter(json['companyRef']),
      objectRef: refConverter(json['objectRef']),
      employeeRef: refConverter(json['employeeRef']),
      manager: json['manager'] as bool,
      employee: json['employee'] as bool,
    );

Map<String, dynamic> _$ObjectRoleToJson(ObjectRole instance) =>
    <String, dynamic>{
      'companyRef': refConverter(instance.companyRef),
      'objectRef': refConverter(instance.objectRef),
      'employeeRef': refConverter(instance.employeeRef),
      'manager': instance.manager,
      'employee': instance.employee,
    };
