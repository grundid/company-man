import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/company/models.dart';
import 'package:smallbusiness/reusable/user_actions/models.dart';

part 'employee_list_state.dart';

class EmployeeListCubit extends Cubit<EmployeeListState> {
  final SbmContext sbmContext;
  EmployeeListCubit(this.sbmContext) : super(EmployeeListInProgress()) {
    _init();
  }

  _init() async {
    emit(EmployeeListInProgress());
    QuerySnapshot<DynamicMap> companySnapshots = await sbmContext.queryBuilder
        .employeesCollection(sbmContext.companyRef!)
        .get();

    List<Employee> employees = companySnapshots.docs
        .map((snapshot) => Employee.fromSnapshot(snapshot))
        .toList();

    employees.sort((e1, e2) => e1.compareTo(e2));

    emit(EmployeeListInitialized(employees));
  }

  refresh() {
    _init();
  }
}
