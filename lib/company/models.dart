import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:smallbusiness/reusable/user_actions/models.dart';

part 'models.g.dart';

@JsonSerializable(explicitToJson: true)
class Company {
  final String companyLabel;

  Company({required this.companyLabel});

  factory Company.fromMap(DynamicMap data) {
    return _$CompanyFromJson(data);
  }

  Map<String, dynamic> toMap() {
    return _$CompanyToJson(this);
  }
}

@JsonSerializable(explicitToJson: true)
class Person {
  final String? gender;
  final String firstName;
  final String lastName;

  Person({
    this.gender,
    required this.firstName,
    required this.lastName,
  });

  factory Person.fromJson(DynamicMap data) => _$PersonFromJson(data);
  DynamicMap toJson() => _$PersonToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Address {
  final String? street;
  final String? additional;
  final String? no;
  final String? postalCode;
  final String? city;
  Address({
    required this.street,
    this.additional,
    required this.no,
    required this.postalCode,
    required this.city,
  });

  factory Address.fromJson(DynamicMap data) => _$AddressFromJson(data);
  DynamicMap toJson() => _$AddressToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Employee {
  @JsonKey(ignore: true)
  DocumentReference? employeeRef;
  final String employeeNo;
  final Person person;
  final Address address;
  final String? email;
  final String? phone;

  Employee({
    this.employeeRef,
    required this.employeeNo,
    required this.person,
    required this.address,
    this.email,
    this.phone,
  });

  factory Employee.fromSnapshot(DocumentSnapshot<DynamicMap> snapshot) {
    Employee employee = _$EmployeeFromJson(snapshot.data()!);
    employee.employeeRef = snapshot.reference;
    return employee;
  }

  factory Employee.fromJson(DynamicMap data) => _$EmployeeFromJson(data);

  DynamicMap toJson() => _$EmployeeToJson(this);
}
