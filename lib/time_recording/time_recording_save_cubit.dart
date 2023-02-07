import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/reusable/state.dart';
import 'package:smallbusiness/reusable/user_actions/models.dart';
import 'package:smallbusiness/time_recording/models.dart';
import 'package:smallbusiness/time_recording/time_recording_cubit.dart';
import 'package:smallbusiness/time_recording/utils.dart';
import 'package:smallbusiness/user_actions/time_recording_delete.dart';
import 'package:smallbusiness/user_actions/time_recording_save.dart';

class TimeRecordingOverlappingError extends ActionError {
  final TimeRecording overlappingTimeRecording;

  TimeRecordingOverlappingError(
      {required this.overlappingTimeRecording, super.fatal});
}

class TimeRecordingSaveCubit extends AppCubit {
  final SbmContext sbmContext;
  StreamSubscription? streamSubscription;
  TimeRecording? initializedTimeRecording;

  TimeRecordingSaveCubit(this.sbmContext, TimeRecordingCubit cubit)
      : super(InProgress()) {
    streamSubscription = cubit.stream.listen(onDependentStateChanged);
    onDependentStateChanged(cubit.state);
  }

  onDependentStateChanged(AppState state) {
    if (state is TimeRecordingInitialized) {
      initializedTimeRecording = state.initializedTimeRecording;
      emit(Initialized());
    }
  }

  @override
  void resetAfterError() {
    emit(Initialized());
  }

  @override
  Future<void> close() async {
    await streamSubscription?.cancel();
    return super.close();
  }

  TimeRecording _prepareTimeRecording(
      Map<String, dynamic> formValues, bool finalized) {
    TimeRecording timeRecording = TimeRecording(
        companyRef: sbmContext.companyRef!,
        employeeRef:
            initializedTimeRecording?.employeeRef ?? sbmContext.employeeRef!,
        from: createFrom(formValues["fromDate"], formValues["fromTime"]),
        to: createTo(formValues["fromDate"], formValues["fromTime"],
            formValues["toTime"]),
        pauses: formValues["pauses"] ?? [],
        message: formValues["message"],
        managerMessage: formValues["managerMessage"] ??
            initializedTimeRecording?.managerMessage,
        finalized: finalized,
        created: DateTime.now(),
        finalizedDate: finalized ? DateTime.now() : null);
    return timeRecording;
  }

  save(Map<String, dynamic> formValues, bool finalized) async {
    try {
      emit(InProgress());
      TimeRecording timeRecording =
          _prepareTimeRecording(formValues, finalized);
      // check if this time overlaps other time recordings
      DateTime fromBefore24 = timeRecording.from.subtract(Duration(hours: 24));
      DateTime to = timeRecording.to ?? DateTime.now();

      QuerySnapshot<DynamicMap> snapshots = await sbmContext.queryBuilder
          .timeRecordingForEmployeeRef(
              companyRef: timeRecording.companyRef,
              employeeRef: timeRecording.employeeRef,
              fromIsGreaterThanOrEqualTo: fromBefore24,
              fromIsLessThan: to)
          .get(GetOptions(source: Source.server));
      for (QueryDocumentSnapshot<DynamicMap> snapshot in snapshots.docs) {
        if (snapshot.reference != initializedTimeRecording?.timeRecordingRef) {
          TimeRecording knownTimeRecording =
              TimeRecording.fromSnapshot(snapshot.reference, snapshot.data());
          if (isOverlapping(timeRecording, knownTimeRecording)) {
            emit(TimeRecordingOverlappingError(
                overlappingTimeRecording: knownTimeRecording, fatal: false));
            return;
          }
        }
      }

      TimeRecordingSaveModel model = TimeRecordingSaveModel(
          initializedTimeRecording?.timeRecordingRef, timeRecording);

      TimeRecordingSaveAction action =
          TimeRecordingSaveAction(sbmContext.firestore, sbmContext.userRef);

      await action.performAction(model);
      emit(ActionDone());
    } on Exception catch (e) {
      emit(ActionError(errorMessage: "Fehler! ($e)"));
    }
  }

  void reset(Map<String, dynamic> formValues) async {
    try {
      emit(InProgress());
      TimeRecording timeRecording = _prepareTimeRecording(formValues, false);
      TimeRecordingSaveModel model = TimeRecordingSaveModel(
          initializedTimeRecording!.timeRecordingRef, timeRecording);

      TimeRecordingSaveAction action =
          TimeRecordingSaveAction(sbmContext.firestore, sbmContext.userRef);

      await action.performAction(model);
      emit(ActionDone());
    } on Exception catch (e) {
      emit(ActionError(errorMessage: "Fehler! ($e)"));
    }
  }

  void delete() async {
    try {
      emit(InProgress());
      TimeRecordingDeleteModel model =
          TimeRecordingDeleteModel(initializedTimeRecording!.timeRecordingRef!);

      TimeRecordingDeleteAction action =
          TimeRecordingDeleteAction(sbmContext.firestore, sbmContext.userRef);

      await action.performAction(model);
      emit(ActionDone());
    } on Exception catch (e) {
      emit(ActionError(errorMessage: "Fehler! ($e)"));
    }
  }
}
