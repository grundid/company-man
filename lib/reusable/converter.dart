import 'package:cloud_firestore/cloud_firestore.dart';

dynamic refConverter(dynamic value) => value;

dynamic toTimeStamp(dynamic value) =>
    value != null ? Timestamp.fromDate(value) : null;

dynamic fromTimeStamp(dynamic value) => value?.toDate();
