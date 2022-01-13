import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/company/models.dart';
import 'package:smallbusiness/reusable/user_actions/models.dart';

part 'employee_menu_state.dart';

class EmployeeMenuCubit extends Cubit<EmployeeMenuState> {
  final SbmContext sbmContext;
  final String employeeId;

  EmployeeMenuCubit(this.sbmContext, this.employeeId)
      : super(EmployeeMenuInProgress()) {
    _init();
  }

  _init() async {
    emit(EmployeeMenuInProgress());
    DocumentSnapshot<DynamicMap> snapshot = await sbmContext.queryBuilder
        .employeeRef(sbmContext.companyRef!, employeeId)
        .get();
    Employee employee = Employee.fromSnapshot(snapshot);
    emit(EmployeeMenuInitialized(employee));
  }

  void refresh() {
    _init();
  }
}
