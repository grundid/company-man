import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:smallbusiness/reusable/converter.dart';

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
class Person implements Comparable<Person> {
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

  @override
  int compareTo(Person other) {
    int c = lastName.compareTo(other.lastName);
    if (c == 0) {
      c = firstName.compareTo(other.firstName);
    }
    return c;
  }
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
class Employee implements Comparable<Employee> {
  @JsonKey(ignore: true)
  DocumentReference? employeeRef;
  final int employeeNo;
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

  String displayName() => "${person.firstName} ${person.lastName}";

  @override
  int compareTo(Employee other) {
    int c = person.compareTo(other.person);
    if (c == 0) {
      c = employeeNo - other.employeeNo;
    }
    return c;
  }
}

@JsonSerializable(explicitToJson: true)
class Wage {
  @JsonKey(ignore: true)
  DocumentReference<DynamicMap>? wageRef;

  @JsonKey(toJson: refConverter, fromJson: refConverter)
  DocumentReference<DynamicMap> companyRef;
  @JsonKey(toJson: toTimeStamp, fromJson: fromTimeStamp)
  final DateTime validFrom;
  @JsonKey(toJson: toTimeStamp, fromJson: fromTimeStamp)
  final DateTime? validTo;
  final int wageInCent;

  Wage({
    required this.companyRef,
    required this.validFrom,
    required this.wageInCent,
    this.validTo,
  });

  factory Wage.fromSnapshot(DocumentSnapshot<DynamicMap> snapshot) {
    Wage wage = _$WageFromJson(snapshot.data()!);
    wage.wageRef = snapshot.reference;
    return wage;
  }
  factory Wage.fromJson(DynamicMap data) => _$WageFromJson(data);

  DynamicMap toJson() => _$WageToJson(this);
}
