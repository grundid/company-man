import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/company/employee/employee_wage_list_cubit.dart';
import 'package:smallbusiness/company/models.dart';
import 'package:smallbusiness/reusable/formatters.dart';
import 'package:smallbusiness/reusable/loader.dart';
import 'package:smallbusiness/reusable/user_actions/models.dart';

class EmployeeWageListWidget extends StatelessWidget {
  final SbmContext sbmContext;
  final String employeeId;
  final DateFormat dateFormat = DateFormat.yMMMMd();
  EmployeeWageListWidget(
      {Key? key, required this.sbmContext, required this.employeeId})
      : super(key: key);

  _showNewWageForm(
    BuildContext context,
    DateTime? firstDate,
    DateTime initialDate,
    Wage? lastWage,
  ) async {
    _FormResult? result = await showDialog(
      context: context,
      builder: (context) => _WageFormWidget(
        validFrom: initialDate,
        firstDate: firstDate,
      ),
    );
    if (result != null && result.action == _FormAction.save) {
      context.read<EmployeeWageListCubit>().save(lastWage, result.formValues!);
    }
  }

  _showWageForm(BuildContext context, Wage wage, Wage? previousWage) async {
    _FormResult? result = await showDialog(
      context: context,
      builder: (context) => _WageFormWidget(
        validFrom: wage.validFrom,
        wageInCent: centToUserInput(wage.wageInCent),
      ),
    );
    if (result != null) {
      switch (result.action) {
        case _FormAction.save:
          // make sure user cannot change validFrom
          DynamicMap formValues = Map.from(result.formValues!);
          formValues["validFrom"] = wage.validFrom;
          context.read<EmployeeWageListCubit>().save(null, formValues);

          break;
        case _FormAction.delete:
          context.read<EmployeeWageListCubit>().delete(wage, previousWage);
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EmployeeWageListCubit(sbmContext, employeeId),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Vergütungen"),
        ),
        body: BlocBuilder<EmployeeWageListCubit, EmployeeWageListState>(
          builder: (context, state) => state is EmployeeWageListInitialized
              ? ListView.builder(
                  itemCount: state.wages.length,
                  itemBuilder: (context, index) {
                    Wage wage = state.wages[index];

                    String subtitle =
                        "Gültig ab ${dateFormat.format(wage.validFrom)}";
                    if (wage.validTo != null) {
                      subtitle += " bis ${dateFormat.format(wage.validTo!)}";
                    }
                    return ListTile(
                      title: Text(
                          "Stundensatz: ${centToUserOutput(wage.wageInCent)}"),
                      subtitle: Text(subtitle),
                      onTap: () {
                        if (wage.validTo != null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  "Stundensätze in der Vergangenheit können nicht mehr geändert werden.")));
                        } else {
                          _showWageForm(context, wage, state.previousWage);
                        }
                      },
                    );
                  },
                )
              : LoadingAnimationScreen(),
        ),
        floatingActionButton:
            BlocBuilder<EmployeeWageListCubit, EmployeeWageListState>(
          builder: (context, state) {
            return state is EmployeeWageListInitialized
                ? FloatingActionButton.extended(
                    onPressed: () {
                      _showNewWageForm(context, state.firstDate,
                          state.initialDate, state.lastWage);
                    },
                    label: Text("Neue Vergütung"),
                    icon: Icon(Icons.euro_symbol),
                  )
                : Container();
          },
        ),
      ),
    );
  }
}

enum _FormAction { save, delete }

class _FormResult {
  final DynamicMap? formValues;
  final _FormAction action;

  _FormResult(this.formValues, this.action);
}

class _WageFormWidget extends StatelessWidget {
  final String? wageInCent;
  final DateTime? firstDate;
  final DateTime validFrom;
  final GlobalKey<FormBuilderState> formKey = GlobalKey();

  _WageFormWidget({
    Key? key,
    this.wageInCent,
    this.firstDate,
    required this.validFrom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: FormBuilder(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (wageInCent == null)
              FormBuilderDateTimePicker(
                name: "validFrom",
                decoration: InputDecoration(
                    label: Text("Vergütung gültig ab"),
                    helperText:
                        "Legen Sie das Datum fest, ab wann die Vergütung gültig ist",
                    helperMaxLines: 2),
                inputType: InputType.date,
                initialValue: validFrom,
                firstDate: firstDate,
                validator: FormBuilderValidators.compose(
                    [FormBuilderValidators.required(context)]),
              ),
            FormBuilderTextField(
              name: "wageInCent",
              autofocus: true,
              initialValue: wageInCent,
              decoration: InputDecoration(
                  label: Text("Stundenlohn"), suffix: Text("€")),
              textAlign: TextAlign.end,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) => userInputToCent(value) == null
                  ? "Bitte einen Stundenlohn in EURO eingeben"
                  : null,
            )
          ],
        ),
      ),
      actions: [
        if (wageInCent != null)
          TextButton(
              onPressed: () {
                Navigator.pop(context, _FormResult(null, _FormAction.delete));
              },
              child: Text(
                "Löschen",
                style: TextStyle(color: Colors.red),
              )),
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Abbrechen")),
        ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.saveAndValidate()) {
                Navigator.pop(context,
                    _FormResult(formKey.currentState!.value, _FormAction.save));
              }
            },
            child: Text("Speichern"))
      ],
    );
  }
}
