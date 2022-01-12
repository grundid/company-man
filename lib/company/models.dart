import 'package:json_annotation/json_annotation.dart';
import 'package:smallbusiness/reusable/user_actions/models.dart';

part 'models.g.dart';

@JsonSerializable()
class Company {
  final String companyLabel;

  Company({required this.companyLabel});

  DynamicMap toMap() {
    return _$CompanyToJson(this);
  }
}
