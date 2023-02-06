import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/reusable/state.dart';
import 'package:smallbusiness/time_recording/models.dart';
import 'package:smallbusiness/time_recording/time_recording_list_employee_cubit.dart';

class EmployeeTimeRecodingsInitialized extends Initialized {
  final List<TimeRecordingWithWage> timeRecordings;

  EmployeeTimeRecodingsInitialized(this.timeRecordings);
}

class EmployeeTimeRecodingsCubit extends Cubit<AppState> {
  final SbmContext sbmContext;
  final DocumentReference employeeRef;
  final DateTime monthYear;

  StreamSubscription? subscription;

  EmployeeTimeRecodingsCubit(this.sbmContext, this.employeeRef, this.monthYear)
      : super(InProgress()) {
    _init();
  }

  _init() async {
    subscription = sbmContext.queryBuilder
        .timeRecordingForEmployeeRef(
            companyRef: sbmContext.companyRef!, employeeRef: employeeRef)
        .snapshots()
        .listen((querySnapshot) {
      List<TimeRecording> timeRecordings = querySnapshot.docs
          .map((e) => TimeRecording.fromSnapshot(e.reference, e.data()))
          .toList();
      timeRecordings.sort((t1, t2) => t2.from.compareTo(t1.from));
      emit(EmployeeTimeRecodingsInitialized(
          timeRecordings.map((e) => TimeRecordingWithWage(e, null)).toList()));
    });
  }

  @override
  Future<void> close() async {
    await subscription?.cancel();
    return super.close();
  }
}
