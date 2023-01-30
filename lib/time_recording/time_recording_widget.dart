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
                    title: Text("Zeiterfassung"),
                    actions: [
                      IconButton(
                          onPressed: () async {
                            if (state.formKey.currentState!.saveAndValidate()) {
                              if (WorkTimeState.fromFormValues(
                                      state.formKey.currentState!.value)
                                  .finishable) {
                                bool? result = await showQueryDialog(
                                    context,
                                    "Zeiterfassung",
                                    "Soll die Zeiterfassung abgeschlossen werden?",
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
                            decoration: InputDecoration(label: Text("Datum")),
                          ),
                          FormBuilderTimeEditor(
                            name: "fromTime",
                            decoration: InputDecoration(labelText: "Gekommen"),
                            timeType: TimeType.from,
                          ),
                          BlocBuilder<TimeRecordingStatusCubit, AppState>(
                            builder: (context, statusState) {
                              return statusState
                                      is TimeRecordingStatusInitizalied
                                  ? FormBuilderPauseEditor(
                                      name: "pauses",
                                      startingDate:
                                          statusState.startingDateTime,
                                      decoration:
                                          InputDecoration(labelText: "Pausen"),
                                      validator: (value) {
                                        return WorkTimeState
                                                .fromFormBuilderState(
                                                    state.formKey.currentState!)
                                            .validatePauses();
                                      })
                                  : Container();
                            },
                          ),
                          FormBuilderTimeEditor(
                              name: "toTime",
                              decoration:
                                  InputDecoration(labelText: "Gegangen"),
                              timeType: TimeType.to,
                              validator: (value) {
                                return WorkTimeState.fromFormBuilderState(
                                        state.formKey.currentState!)
                                    .validateTo();
                              }),
                          BlocBuilder<TimeRecordingStatusCubit, AppState>(
                            builder: (context, state) {
                              return Text(
                                state is TimeRecordingStatusInitizalied
                                    ? state.workingLabel
                                    : "-",
                                style: Theme.of(context).textTheme.bodyMedium!,
                              );
                            },
                          ),
                          FormBuilderTextField(
                            name: "message",
                            decoration: InputDecoration(
                                label: Text(
                                  "Nachricht",
                                ),
                                helperMaxLines: 3,
                                helperText:
                                    "Diese Nachricht wird zusammen mit der Zeiterfassung an den Manager geschickt."),
                          ),
                          Visibility(
                            maintainState: true,
                            visible: sbmContext.user.isManager,
                            child: FormBuilderTextField(
                              name: "managerMessage",
                              decoration: InputDecoration(
                                  label: Text(
                                    "Manager-Nachricht",
                                  ),
                                  helperMaxLines: 3,
                                  helperText:
                                      "Diese Nachricht wird dem Mitarbeiter nach dem Zurücksetzen und in dem Export angezeigt."),
                            ),
                          ),
                          ButtonBar(
                            children: [
                              if (sbmContext.user.isManager)
                                TextButton(
                                  style: TextButton.styleFrom(
                                      foregroundColor: Colors.red),
                                  onPressed: () async {
                                    if (state.formKey.currentState!
                                        .saveAndValidate()) {
                                      bool? result = await showQueryDialog(
                                          context,
                                          "Erfassung zurücksetzen",
                                          "Nach dem Zurücksetzen kann der Mitarbeiter die Arbeitszeit korrigieren.");
                                      if (true == result) {
                                        context
                                            .read<TimeRecordingCubit>()
                                            .reset(state
                                                .formKey.currentState!.value);
                                      }
                                    }
                                  },
                                  child: Text("Zurücksetzen"),
                                ),
                              TextButton(
                                onPressed: () {
                                  if (state.formKey.currentState!
                                      .saveAndValidate()) {
                                    context.read<TimeRecordingCubit>().save(
                                        state.formKey.currentState!.value,
                                        false);
                                  }
                                },
                                child: Text("Speichern"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if (state.formKey.currentState!
                                      .saveAndValidate()) {
                                    context.read<TimeRecordingCubit>().save(
                                        state.formKey.currentState!.value,
                                        true);
                                  }
                                },
                                child: Text("Abschließen"),
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
}
