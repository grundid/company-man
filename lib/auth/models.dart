import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:smallbusiness/reusable/converter.dart';
import 'package:smallbusiness/reusable/user_actions/models.dart';

part 'models.g.dart';

@JsonSerializable(explicitToJson: true)
class SbmUserModel {
  @JsonKey(toJson: toTimeStamp, fromJson: fromTimeStamp)
  DateTime? anonReminder;
  SbmUserModel({
    this.anonReminder,
  });

  factory SbmUserModel.fromData(DynamicMap data) {
    return _$SbmUserModelFromJson(data);
  }
}
