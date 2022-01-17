import 'package:smallbusiness/reusable/user_actions/models.dart';

class Invitation {
  late String companyLabel;

  Invitation.fromJson(DynamicMap data) {
    companyLabel = data["companyLabel"];
  }
}
