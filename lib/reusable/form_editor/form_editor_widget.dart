import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:smallbusiness/reusable/form_editor/bloc/form_editor_bloc.dart';
import 'package:smallbusiness/reusable/loader.dart';
import 'package:smallbusiness/reusable/responsive_body.dart';
import 'package:smallbusiness/reusable/utils.dart';

typedef FormFieldsBuilder = List<Widget> Function(
    BuildContext context,
    Map<String, dynamic> values,
    GlobalKey<FormBuilderState> formKey,
    FormEditorInitialized state,
    Function()? execDefaultAction);

String? valueTrimmer(String? value) => value?.trim();
String? valueUpperCase(String? value) => value?.toUpperCase();

class FormEditorAction {
  final String actionTitle;
  final Widget? icon;
  final FormFieldsBuilder? confirmFieldsBuilder;
  final Map<String, dynamic> Function(Map<String, dynamic> formValues)?
      initialValuesCreator;
  final FormEditorEvent event;
  final Function(FormEditorInitialized state)? buildWhen;

  FormEditorAction(this.actionTitle, this.event,
      {this.confirmFieldsBuilder,
      this.initialValuesCreator,
      this.buildWhen,
      this.icon});
}

class FormEditorWidget<C extends FormEditorBloc> extends StatelessWidget {
  final FormFieldsBuilder formFieldsBuilder;

  final String editorTitle;
  final C Function(BuildContext context) cubitCreator;

  final FormEditorAction defaultAction;
  final List<FormEditorAction> Function(
      BuildContext context, FormEditorState state)? additionalActionsBuilder;
  final Function(BuildContext context, FormEditorDone state)? popHandler;
  final Function(BuildContext context, FormEditorState state)? stateListener;
  final List<FormEditorAction>? appBarActions;

  FormEditorWidget(
      {Key? key,
      required this.editorTitle,
      required this.cubitCreator,
      required this.formFieldsBuilder,
      FormFieldsBuilder? primaryConfirmFieldsBuilder,
      Function(FormEditorInitialized state)? primaryBuildWhen,
      String primaryActionTitle = "Speichern",
      this.additionalActionsBuilder,
      this.popHandler,
      this.stateListener,
      this.appBarActions})
      : defaultAction = FormEditorAction(
            primaryActionTitle, FormEditorSaveEvent(formValues: const {}),
            buildWhen: primaryBuildWhen,
            confirmFieldsBuilder: primaryConfirmFieldsBuilder),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<C>(
      create: cubitCreator,
      child: BlocConsumer<C, FormEditorState>(
        listener: (context, state) {
          if (state is FormEditorDone) {
            handleEditorDone(context, state);
          } else if (state is FormEditorError) {
            handleEditorError(context, state);
          } else if (stateListener != null) {
            stateListener!(context, state);
          }
        },
        builder: (BuildContext context, FormEditorState state) =>
            _buildScaffold(context, state),
      ),
    );
  }

  handleEditorDone(BuildContext context, FormEditorDone state) {
    if (popHandler != null) {
      popHandler!(context, state);
    } else {
      if (state.actionResult.message != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(state.actionResult.message!)));
      }
      Navigator.pop(context, state.actionResult);
    }
  }

  handleEditorError(BuildContext context, FormEditorError state) async {
    await showErrorMessage(context, state.errorMessage);
    context.read<C>().add(FormEditorClearErrorEvent());
  }

  Widget _createConfirmDialog(
      BuildContext context,
      FormEditorAction formEditorAction,
      Map<String, dynamic> mainFormFields,
      FormEditorInitialized state) {
    GlobalKey<FormBuilderState> additionFormKey = GlobalKey();
    Map<String, dynamic> initialValue =
        formEditorAction.initialValuesCreator != null
            ? formEditorAction.initialValuesCreator!(mainFormFields)
            : {};
    return AlertDialog(
      scrollable: true,
//  does not make sense to repeat that    title: Text(formEditorAction.actionTitle),
      content: FormBuilder(
        key: additionFormKey,
        initialValue: initialValue,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: formEditorAction.confirmFieldsBuilder!(
              context, initialValue, additionFormKey, state, () {
            if (true == additionFormKey.currentState?.saveAndValidate()) {
              Navigator.pop(context, additionFormKey.currentState!.value);
            }
          }),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Abbrechen"),
        ),
        ElevatedButton(
          onPressed: () {
            if (true == additionFormKey.currentState?.saveAndValidate()) {
              Navigator.pop(context, additionFormKey.currentState!.value);
            }
          },
          child: Text(
            formEditorAction.actionTitle,
          ),
        )
      ],
    );
  }

  _handleAction(BuildContext context, FormEditorInitialized state,
      FormEditorAction formEditorAction) async {
    if (true == state.formKey.currentState?.saveAndValidate()) {
      // merge initial values with form values. workaround for missing hidden fields
      Map<String, dynamic> mainFormValues = Map.from(state.formValues);
      mainFormValues.addEntries(state.formKey.currentState!.value.entries);
      if (formEditorAction.confirmFieldsBuilder != null &&
          (formEditorAction.buildWhen == null ||
              formEditorAction.buildWhen!(state))) {
        Map<String, dynamic> result = await showDialog(
          context: context,
          builder: (context) => _createConfirmDialog(
              context, formEditorAction, mainFormValues, state),
        );
        if (result != null) {
          context.read<C>().add(formEditorAction.event
              .withValues(formValues: mainFormValues, confirmValues: result));
        }
      } else {
        context
            .read<C>()
            .add(formEditorAction.event.withValues(formValues: mainFormValues));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Formular unvollständig. Bitte Eingaben prüfen."),
      ));
    }
  }

  Widget _buildMainScreen(BuildContext context, FormEditorInitialized state) {
    return SafeArea(
      child: ResponsiveBody(
        child: FormBuilder(
          key: state.formKey,
          initialValue: state.formValues,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...formFieldsBuilder(
                  context,
                  state.formValues,
                  state.formKey,
                  state,
                  state.editable
                      ? () {
                          _handleAction(context, state, defaultAction);
                        }
                      : null),
              ButtonBar(
                alignment: MainAxisAlignment.end,
                children: [
                  if (additionalActionsBuilder != null)
                    ...additionalActionsBuilder!(context, state).map(
                      (FormEditorAction action) => action.icon != null
                          ? TextButton.icon(
                              onPressed: () {
                                _handleAction(context, state, action);
                              },
                              icon: action.icon!,
                              label: Text(action.confirmFieldsBuilder != null
                                  ? "${action.actionTitle}..."
                                  : action.actionTitle),
                            )
                          : TextButton(
                              onPressed: () {
                                _handleAction(context, state, action);
                              },
                              child: Text(action.confirmFieldsBuilder != null
                                  ? "${action.actionTitle}..."
                                  : action.actionTitle),
                            ),
                    ),
                  if (state.editable)
                    ElevatedButton(
                      onPressed: () {
                        _handleAction(context, state, defaultAction);
                      },
                      child: Text(defaultAction.confirmFieldsBuilder != null
                          ? "${defaultAction.actionTitle}..."
                          : defaultAction.actionTitle),
                    )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  List<Widget>? _buildActions(
      BuildContext context, FormEditorInitialized state) {
    return appBarActions
        ?.map((e) => IconButton(
            onPressed: () {
              _handleAction(context, state, e);
            },
            tooltip: e.actionTitle,
            icon: e.icon!))
        .toList();
  }

  Scaffold _buildScaffold(BuildContext context, FormEditorState state) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          editorTitle,
          overflow: TextOverflow.fade,
        ),
        actions: state is FormEditorInitialized
            ? _buildActions(context, state)
            : null,
      ),
      body: state is FormEditorInitialized
          ? _buildMainScreen(context, state)
          : LoadingAnimationScreen(),
    );
  }
}
