// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Company _$CompanyFromJson(Map<String, dynamic> json) => Company(
      companyLabel: json['companyLabel'] as String,
    );

Map<String, dynamic> _$CompanyToJson(Company instance) => <String, dynamic>{
      'companyLabel': instance.companyLabel,
    };

Person _$PersonFromJson(Map<String, dynamic> json) => Person(
      gender: json['gender'] as String?,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
    );

Map<String, dynamic> _$PersonToJson(Person instance) => <String, dynamic>{
      'gender': instance.gender,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
    };

Address _$AddressFromJson(Map<String, dynamic> json) => Address(
      street: json['street'] as String?,
      additional: json['additional'] as String?,
      no: json['no'] as String?,
      postalCode: json['postalCode'] as String?,
      city: json['city'] as String?,
    );

Map<String, dynamic> _$AddressToJson(Address instance) => <String, dynamic>{
      'street': instance.street,
      'additional': instance.additional,
      'no': instance.no,
      'postalCode': instance.postalCode,
      'city': instance.city,
    };

Employee _$EmployeeFromJson(Map<String, dynamic> json) => Employee(
      employeeNo: json['employeeNo'] as String,
      person: Person.fromJson(json['person'] as Map<String, dynamic>),
      address: Address.fromJson(json['address'] as Map<String, dynamic>),
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$EmployeeToJson(Employee instance) => <String, dynamic>{
      'employeeNo': instance.employeeNo,
      'person': instance.person.toJson(),
      'address': instance.address.toJson(),
      'email': instance.email,
      'phone': instance.phone,
    };

Wage _$WageFromJson(Map<String, dynamic> json) => Wage(
      validFrom: fromTimeStamp(json['validFrom']),
      validTo: fromTimeStamp(json['validTo']),
      wageInCent: json['wageInCent'] as int,
    );

Map<String, dynamic> _$WageToJson(Wage instance) => <String, dynamic>{
      'validFrom': toTimeStamp(instance.validFrom),
      'validTo': toTimeStamp(instance.validTo),
      'wageInCent': instance.wageInCent,
    };
