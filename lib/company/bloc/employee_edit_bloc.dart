import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/company/models.dart';
import 'package:smallbusiness/reusable/form_editor/bloc/form_editor_bloc.dart';
import 'package:smallbusiness/reusable/user_actions/models.dart';
import 'package:smallbusiness/user_actions/employee_save.dart';

class EmployeeEditBloc extends FormEditorBloc {
  final SbmContext sbmContext;

  EmployeeEditBloc(
    this.sbmContext,
    DocumentReference<Map<String, dynamic>>? editingRef,
  ) : super(editingRef);

  @override
  Future<Map<String, dynamic>?> readFormData() async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await editingRef!.get();
    Employee employee = Employee.fromSnapshot(snapshot);
    DynamicMap result = {};
    result["employeeNo"] = employee.employeeNo;
    result["email"] = employee.email;
    result["phone"] = employee.phone;
    result["gender"] = employee.person.gender;
    result["firstName"] = employee.person.firstName;
    result["lastName"] = employee.person.lastName;
    result["street"] = employee.address.street;
    result["no"] = employee.address.no;
    result["additional"] = employee.address.additional;
    result["postalCode"] = employee.address.postalCode;
    result["city"] = employee.address.city;

    return result;
  }

  @override
  Future<ActionResult> performSave(Map<String, dynamic> value) async {
    EmployeeSaveAction saveAction =
        EmployeeSaveAction(sbmContext.firestore, sbmContext.userRef);
    Person person = Person(
        firstName: value["firstName"],
        lastName: value["lastName"],
        gender: value["gender"]);

    Address address = Address(
        street: value["street"],
        no: value["no"],
        postalCode: value["postalCode"],
        city: value["city"],
        additional: value["additional"]);

    Employee employee = Employee(
        employeeNo: value["employeeNo"],
        person: person,
        address: address,
        email: value["email"],
        phone: value["phone"]);
    return saveAction.performAction(
        EmployeeSaveModel(sbmContext.companyRef!, editingRef, employee));
  }
}
