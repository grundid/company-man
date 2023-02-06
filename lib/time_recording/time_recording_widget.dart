import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:routemaster/routemaster.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/reusable/loader.dart';
import 'package:smallbusiness/reusable/responsive_body.dart';
import 'package:smallbusiness/reusable/state.dart';
import 'package:smallbusiness/reusable/utils.dart';
import 'package:smallbusiness/time_recording/form_builder_pause_editor_widget.dart';
import 'package:smallbusiness/time_recording/form_builder_time_editor.dart';
import 'package:smallbusiness/time_recording/time_recording_cubit.dart';
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
          create: (context) => TimeRecordingStatusCubit(),
        ),
        BlocProvider(
          create: (context) => TimeRecordingCubit(
              sbmContext, context.read<TimeRecordingStatusCubit>(),
              timeRecordingId: timeRecordingId),
        ),
      ],
      child: BlocConsumer<TimeRecordingCubit, TimeRecordingState>(
        listener: (context, state) {
          if (state is TimeRecordingDone) {
            Routemaster.of(context).pop(true);
          } else if (state is TimeRecordingInitialized &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          return state is TimeRecordingInitialized
              ? Scaffold(
                  appBar: AppBar(
                    title: Text(AppLocalizations.of(context)!.zeiterfassung),
                    actions: [
                      IconButton(
                          onPressed: () async {
                            if (state.formKey.currentState!.saveAndValidate()) {
                              if (WorkTimeState.fromFormValues(
                                      state.formKey.currentState!.value)
                                  .finishable) {
                                bool? result = await showQueryDialog(
                                    context,
                                    AppLocalizations.of(context)!.zeiterfassung,
                                    AppLocalizations.of(context)!
                                        .sollDieZeiterfassungAbgeschlossenWerden,
                                    yesNo: true);
                                if (true == result) {
                                  context.read<TimeRecordingCubit>().save(
                                      state.formKey.currentState!.value, true);
                                }
                              } else {
                                context.read<TimeRecordingCubit>().save(
                                    state.formKey.currentState!.value, false);
                              }
                            }
                          },
                          icon: Icon(Icons.check))
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
                          ButtonBar(
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
                                      context.read<TimeRecordingCubit>().reset(
                                          state.formKey.currentState!.value);
                                    }
                                  },
                                  child: Text(AppLocalizations.of(context)!
                                      .zuruecksetzen),
                                ),
                              if (sbmContext.user.isManager)
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
                                          .read<TimeRecordingCubit>()
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
                                    context.read<TimeRecordingCubit>().save(
                                        state.formKey.currentState!.value,
                                        false);
                                  } else {
                                    _showFormError(context);
                                  }
                                },
                                child: Text(
                                    AppLocalizations.of(context)!.speichern),
                              ),
                              BlocBuilder<TimeRecordingStatusCubit, AppState>(
                                builder: (context, statusState) {
                                  return ElevatedButton(
                                    onPressed: statusState
                                                is TimeRecordingStatusInitizalied &&
                                            statusState.canFinish
                                        ? () {
                                            if (state.formKey.currentState!
                                                .saveAndValidate()) {
                                              context
                                                  .read<TimeRecordingCubit>()
                                                  .save(
                                                      state.formKey
                                                          .currentState!.value,
                                                      true);
                                            } else {
                                              _showFormError(context);
                                            }
                                          }
                                        : null,
                                    child: Text(AppLocalizations.of(context)!
                                        .abschliessen),
                                  );
                                },
                              )
                            ],
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
