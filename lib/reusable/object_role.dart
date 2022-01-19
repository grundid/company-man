import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:smallbusiness/reusable/converter.dart';
import 'package:smallbusiness/reusable/user_actions/models.dart';

part 'object_role.g.dart';

@JsonSerializable()
class ObjectRole {
  @JsonKey(toJson: refConverter, fromJson: refConverter)
  final DocumentReference<DynamicMap> companyRef;
  @JsonKey(toJson: refConverter, fromJson: refConverter)
  final DocumentReference<DynamicMap> objectRef;
  @JsonKey(toJson: refConverter, fromJson: refConverter)
  final DocumentReference<DynamicMap> employeeRef;
  bool manager;
  bool employee;

  ObjectRole({
    required this.companyRef,
    required this.objectRef,
    required this.employeeRef,
    required this.manager,
    required this.employee,
  });

  factory ObjectRole.fromJson(DynamicMap data) => _$ObjectRoleFromJson(data);
  DynamicMap toJson() => _$ObjectRoleToJson(this);
}
