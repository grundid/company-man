import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/company/models.dart';
import 'package:smallbusiness/reusable/formatters.dart';
import 'package:smallbusiness/reusable/user_actions/models.dart';
import 'package:smallbusiness/user_actions/wage_delete.dart';
import 'package:smallbusiness/user_actions/wage_save.dart';

part 'employee_wage_list_state.dart';

class EmployeeWageListCubit extends Cubit<EmployeeWageListState> {
  final SbmContext sbmContext;
  final DocumentReference<DynamicMap> employeeRef;

  EmployeeWageListCubit(this.sbmContext, String employeeId)
      : employeeRef = sbmContext.queryBuilder
            .employeeRef(sbmContext.companyRef!, employeeId),
        super(EmployeeWageListInProgress()) {
    _init();
  }

  _init() async {
    emit(EmployeeWageListInProgress());

    final wagesSnapshots = await sbmContext.queryBuilder
        .wagesCollection(employeeRef)
        .get(GetOptions(source: Source.server));

    List<Wage> wages =
        wagesSnapshots.docs.map((e) => Wage.fromSnapshot(e)).toList();

    wages.sort((w1, w2) => w2.validFrom.compareTo(w1.validFrom));

    Wage? last = wages.isNotEmpty ? wages.first : null;
    DateTime? firstDate = last == null
        ? null
        : DateTime(
                last.validFrom.year, last.validFrom.month, last.validFrom.day)
            .add(Duration(days: 1));
    DateTime initialDate = DateTime(DateTime.now().year);
    if (firstDate != null && initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    }
    Wage? previousWage = wages.length > 1 ? wages[1] : null;

    emit(EmployeeWageListInitialized(
        wages, firstDate, initialDate, last, previousWage));
  }

  refresh() {
    _init();
  }

  save(Wage? lastWage, DynamicMap formValues) async {
    emit(EmployeeWageListInProgress());

    Wage wage = Wage(
        companyRef: sbmContext.companyRef!,
        validFrom: formValues["validFrom"],
        wageInCent: userInputToCent(formValues["wageInCent"])!);

    WageSaveModel model = WageSaveModel(employeeRef, lastWage?.wageRef, wage);

    WageSaveAction action =
        WageSaveAction(sbmContext.firestore, sbmContext.userRef);
    await action.performAction(model);
    _init();
  }

  delete(Wage wage, Wage? previous) async {
    emit(EmployeeWageListInProgress());

    WageDeleteModel model = WageDeleteModel(wage.wageRef!, previous?.wageRef);

    WageDeleteAction action =
        WageDeleteAction(sbmContext.firestore, sbmContext.userRef);
    await action.performAction(model);
    _init();
  }
}
