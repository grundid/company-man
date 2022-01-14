import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/reusable/object_role.dart';
import 'package:smallbusiness/reusable/user_actions/models.dart';
import 'package:smallbusiness/user_actions/invite_save.dart';
import 'package:smallbusiness/user_actions/object_role_change.dart';

part 'employee_user_state.dart';

class EmployeeUserCubit extends Cubit<EmployeeUserState> {
  final SbmContext sbmContext;
  final DocumentReference<DynamicMap> employeeRef;

  EmployeeUserCubit(this.sbmContext, String employeeId)
      : employeeRef = sbmContext.queryBuilder
            .employeeRef(sbmContext.companyRef!, employeeId),
        super(EmployeeUserInProgress()) {
    _init();
  }

  _init() async {
    QuerySnapshot<DynamicMap> querySnapshot = await sbmContext.queryBuilder
        .objectRoleForEmployeeRef(sbmContext.companyRef!, employeeRef)
        .get();
    if (querySnapshot.size == 0) {
      // prüfen, ob es eine einladung gibt
      QuerySnapshot<DynamicMap> invitationSnapshots = await sbmContext
          .queryBuilder
          .invitationForEmployeeRef(sbmContext.companyRef!, employeeRef)
          .get();
      if (invitationSnapshots.size == 0) {
        emit(EmployeeUserNoUser());
      } else {
        DocumentSnapshot<DynamicMap> inviteSnapshot =
            invitationSnapshots.docs.first;
        String inviteId = inviteSnapshot.data()!["inviteId"];
        emit(EmployeeUserInvitationAvailable(inviteId));
      }
    } else {
      DocumentSnapshot<DynamicMap> objectRoleSnapshot =
          querySnapshot.docs.first;
      ObjectRole objectRole = ObjectRole.fromJson(objectRoleSnapshot.data()!);
      DynamicMap formValues = {
        "employee": objectRole.employee,
        "manager": objectRole.manager
      };
      emit(EmployeeUserInitialized(objectRoleSnapshot.reference, formValues));
    }
  }

  Future<void> createInvite(DynamicMap values) async {
    emit(EmployeeUserInProgress());
    InviteSaveAction saveAction =
        InviteSaveAction(sbmContext.firestore, sbmContext.userRef);
    InviteSaveModel saveModel = InviteSaveModel(sbmContext.companyRef!,
        employeeRef, true == values["employee"], true == values["manager"]);

    await saveAction.performAction(saveModel);
    _init();
  }

  Future<void> changeRights(
      DocumentReference<DynamicMap> objectRoleRef, DynamicMap values) async {
    emit(EmployeeUserInProgress());
    ObjectRoleSaveAction saveAction =
        ObjectRoleSaveAction(sbmContext.firestore, sbmContext.userRef);
    ObjectRoleSaveModel saveModel = ObjectRoleSaveModel(
        objectRoleRef,
        sbmContext.companyRef!,
        true == values["employee"],
        true == values["manager"]);

    await saveAction.performAction(saveModel);
    _init();
  }
}
