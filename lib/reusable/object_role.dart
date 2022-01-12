import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:smallbusiness/reusable/user_actions/models.dart';

part 'object_role.g.dart';

@JsonSerializable()
class ObjectRole {
  @JsonKey(toJson: refConverter, fromJson: refConverter)
  final DocumentReference companyRef;
  @JsonKey(toJson: refConverter, fromJson: refConverter)
  final DocumentReference objectRef;
  bool manager;
  bool employee;

  ObjectRole({
    required this.companyRef,
    required this.objectRef,
    required this.manager,
    required this.employee,
  });

  factory ObjectRole.fromMap(DynamicMap data) {
    return _$ObjectRoleFromJson(data);
  }

  DynamicMap toMap() {
    return _$ObjectRoleToJson(this);
  }
}

dynamic refConverter(dynamic value) => value;
