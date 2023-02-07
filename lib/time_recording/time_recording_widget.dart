import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/reusable/loader.dart';
import 'package:smallbusiness/reusable/responsive_body.dart';
import 'package:smallbusiness/reusable/state.dart';
import 'package:smallbusiness/reusable/utils.dart';
import 'package:smallbusiness/time_recording/form_builder_pause_editor_widget.dart';
import 'package:smallbusiness/time_recording/form_builder_time_editor.dart';
import 'package:smallbusiness/time_recording/models.dart';
import 'package:smallbusiness/time_recording/time_recording_cubit.dart';
import 'package:smallbusiness/time_recording/time_recording_save_cubit.dart';
import 'package:smallbusiness/time_recording/time_recording_status_cubit.dart';
import 'package:smallbusiness/time_recording/utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TimeRecordingWidget extends StatelessWidget {
  final SbmContext sbmContext;
  final String? timeRecordingId;

  TimeRecordingWidget(
      {Key? key, required this.sbmContext, this.timeRecordingId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              TimeRecordingCubit(sbmContext, timeRecordingId: timeRecordingId),
        ),
        BlocProvider(
          create: (context) =>
              TimeRecordingStatusCubit(context.read<TimeRecordingCubit>()),
        ),
        BlocProvider(
          create: (context) => TimeRecordingSaveCubit(
              sbmContext, context.read<TimeRecordingCubit>()),
        ),
      ],
      child: BlocBuilder<TimeRecordingCubit, AppState>(
        builder: (context, state) {
          return state is TimeRecordingInitialized
              ? Scaffold(
                  appBar: AppBar(
                    title: Text(AppLocalizations.of(context)!.zeiterfassung),
                    actions: [
                      BlocBuilder<TimeRecordingSaveCubit, AppState>(
                        builder: (context, actionState) {
                          return IconButton(
                              onPressed: actionState is Initialized
                                  ? () async {
                                      if (state.formKey.currentState!
                                          .saveAndValidate()) {
                                        if (WorkTimeState.fromFormValues(state
                                                .formKey.currentState!.value)
                                            .finishable) {
                                          bool? result = await showQueryDialog(
                                              context,
                                              AppLocalizations.of(context)!
                                                  .zeiterfassung,
                                              AppLocalizations.of(context)!
                                                  .sollDieZeiterfassungAbgeschlossenWerden,
                                              yesNo: true);
                                          if (true == result) {
                                            context
                                                .read<TimeRecordingSaveCubit>()
                                                .save(
                                                    state.formKey.currentState!
                                                        .value,
                                                    true);
                                          }
                                        } else {
                                          context
                                              .read<TimeRecordingSaveCubit>()
                                              .save(
                                                  state.formKey.currentState!
                                                      .value,
                                                  false);
                                        }
                                      }
                                    }
                                  : null,
                              icon: Icon(Icons.check));
                        },
                      )
                    ],
                  ),
                  body: ResponsiveBody(
                    child: FormBuilder(
                      key: state.formKey,
                      autovalidateMode: AutovalidateMode.always,
                      initialValue: state.formValues,
                      onChanged: () {
                        context.read<TimeRecordingStatusCubit>().update(
                            WorkTimeState.fromFormBuilderState(
                                state.formKey.currentState!));
                      },
                      child: Column(
                        children: [
                          FormBuilderDateTimePicker(
                            name: "fromDate",
                            format: DateFormat.yMMMMEEEEd(),
                            inputType: InputType.date,
                            decoration: InputDecoration(
                                label:
                                    Text(AppLocalizations.of(context)!.datum)),
                          ),
                          FormBuilderTimeEditor(
                            name: "fromTime",
                            decoration: InputDecoration(
                                labelText:
                                    AppLocalizations.of(context)!.gekommen),
                            timeType: TimeType.from,
                          ),
                          BlocBuilder<TimeRecordingStatusCubit, AppState>(
                            builder: (context, statusState) {
                              return statusState
                                      is TimeRecordingStatusInitizalied
                                  ? FormBuilderPauseEditor(
                                      name: "pauses",
                                      workStartDate:
                                          statusState.startingDateTime,
                                      decoration: InputDecoration(
                                          labelText:
                                              AppLocalizations.of(context)!
                                                  .pausen),
                                      validator: (value) {
                                        return WorkTimeState
                                                .fromFormBuilderState(
                                                    state.formKey.currentState!)
                                            .validatePauses(context);
                                      })
                                  : Container();
                            },
                          ),
                          FormBuilderTimeEditor(
                              name: "toTime",
                              decoration: InputDecoration(
                                  labelText:
                                      AppLocalizations.of(context)!.gegangen),
                              timeType: TimeType.to,
                              validator: (value) {
                                return WorkTimeState.fromFormBuilderState(
                                        state.formKey.currentState!)
                                    .validateTo(context);
                              }),
                          BlocBuilder<TimeRecordingStatusCubit, AppState>(
                            builder: (context, state) {
                              return Text(
                                state is TimeRecordingStatusInitizalied
                                    ? AppLocalizations.of(context)!
                                        .arbeitszeitPause(
                                            state.pauseTime, state.workingTime)
                                    : "-",
                                style: Theme.of(context).textTheme.bodyMedium!,
                              );
                            },
                          ),
                          FormBuilderTextField(
                            name: "message",
                            decoration: InputDecoration(
                                label: Text(
                                  AppLocalizations.of(context)!.nachricht,
                                ),
                                helperMaxLines: 3,
                                helperText: AppLocalizations.of(context)!
                                    .dieseNachrichtWirdZusammenMitDerZeiterfassungAnDenManagerGeschickt),
                          ),
                          Visibility(
                            maintainState: true,
                            visible: sbmContext.user.isManager,
                            child: FormBuilderTextField(
                              name: "managerMessage",
                              decoration: InputDecoration(
                                  label: Text(
                                    AppLocalizations.of(context)!
                                        .managerNachricht,
                                  ),
                                  helperMaxLines: 3,
                                  helperText: AppLocalizations.of(context)!
                                      .dieseNachrichtWirdDemMitarbeiterNachDemZuruecksetzenUndInDemExportangezeigt),
                            ),
                          ),
                          ActionBlocConsumer<TimeRecordingSaveCubit>(
                            errorBuilder: (context, state) {
                              if (state is TimeRecordingOverlappingError) {
                                TimeRecording knownTimeRecording =
                                    state.overlappingTimeRecording;
                                DateFormat dateFormat =
                                    DateFormat.yMd().add_Hm();

                                String dateTimeRange = knownTimeRecording.to !=
                                        null
                                    ? "${dateFormat.format(knownTimeRecording.from)} - ${dateFormat.format(knownTimeRecording.to!)}"
                                    : dateFormat
                                        .format(knownTimeRecording.from);
                                return AppLocalizations.of(context)!
                                    .dieArbeitszeitUeberlapptSichMitBereitsErfassterArbeitszeit(
                                        dateTimeRange);
                              }
                              return null;
                            },
                            builder: (context, actionState) {
                              return ButtonBar(
                                children: [
                                  if (sbmContext.user.isManager)
                                    TextButton(
                                      style: TextButton.styleFrom(
                                          foregroundColor: Colors.red),
                                      onPressed: () async {
                                        bool? result = await showQueryDialog(
                                            context,
                                            AppLocalizations.of(context)!
                                                .erfassungZuruecksetzen,
                                            AppLocalizations.of(context)!
                                                .nachDemZuruecksetzenKannDerMitarbeiterDieArbeitszeitKorrigieren);
                                        if (true == result) {
                                          state.formKey.currentState!.save();
                                          context
                                              .read<TimeRecordingSaveCubit>()
                                              .reset(state
                                                  .formKey.currentState!.value);
                                        }
                                      },
                                      child: Text(AppLocalizations.of(context)!
                                          .zuruecksetzen),
                                    ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                        foregroundColor: Colors.red),
                                    onPressed: () async {
                                      bool? result = await showQueryDialog(
                                          context,
                                          AppLocalizations.of(context)!
                                              .erfassungLoeschen,
                                          AppLocalizations.of(context)!
                                              .sollDieErfassteZeitFuerDenMitarbeiterGeloeschtWerden);
                                      if (true == result) {
                                        context
                                            .read<TimeRecordingSaveCubit>()
                                            .delete();
                                      }
                                    },
                                    child: Text(
                                        AppLocalizations.of(context)!.loeschen),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      if (state.formKey.currentState!
                                          .saveAndValidate()) {
                                        context
                                            .read<TimeRecordingSaveCubit>()
                                            .save(
                                                state.formKey.currentState!
                                                    .value,
                                                false);
                                      } else {
                                        _showFormError(context);
                                      }
                                    },
                                    child: Text(AppLocalizations.of(context)!
                                        .speichern),
                                  ),
                                  BlocBuilder<TimeRecordingStatusCubit,
                                      AppState>(
                                    builder: (context, statusState) {
                                      return ElevatedButton(
                                        onPressed: statusState
                                                    is TimeRecordingStatusInitizalied &&
                                                statusState.canFinish
                                            ? () {
                                                if (state.formKey.currentState!
                                                    .saveAndValidate()) {
                                                  context
                                                      .read<
                                                          TimeRecordingSaveCubit>()
                                                      .save(
                                                          state
                                                              .formKey
                                                              .currentState!
                                                              .value,
                                                          true);
                                                } else {
                                                  _showFormError(context);
                                                }
                                              }
                                            : null,
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .abschliessen),
                                      );
                                    },
                                  )
                                ],
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                )
              : LoadingAnimationScaffold();
        },
      ),
    );
  }

  void _showFormError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Formular enthält Fehler. Bitte korrigieren.")));
  }
}
