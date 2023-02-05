import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/company/models.dart';
import 'package:smallbusiness/reusable/converter.dart';
import 'package:smallbusiness/reusable/object_role.dart';
import 'package:smallbusiness/reusable/user_actions/models.dart';
import 'package:smallbusiness/user_actions/notification_token_save.dart';
import 'package:smallbusiness/user_actions/sign_in_user.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SbmContext sbmContext;
  late StreamSubscription _authStateChanges;

  AuthCubit(this.sbmContext) : super(AuthInProgress()) {
    _authStateChanges = sbmContext.auth.authStateChanges().listen((User? user) async {
      log("User changed: uid: ${user?.uid}");
      if (user != null) {
        emit(AuthInProgress());

        ObjectRole? objectRole;
        DocumentReference<DynamicMap> userRef =
            sbmContext.queryBuilder.usersCollection().doc(user.uid);
        DocumentSnapshot<DynamicMap> userSnapshot = await userRef.get();
        DateTime anonReminder;
        String? displayName;
        String? companyLabel;
        if (userSnapshot.exists) {
          DynamicMap userData = userSnapshot.data()!;
          anonReminder =
              fromTimeStamp(userData["anonReminder"]) ?? DateTime.now();
          // wir belassen companyRef um eventuell die companyRef
          // zu wechseln, falls es mehrere objectRoles gibt
          DocumentReference? companyRef = userSnapshot.data()!["companyRef"];
          if (companyRef != null) {
            final userObjectRoleRef =
                sbmContext.queryBuilder.objectRoleRef(userRef, companyRef);
            DocumentSnapshot<DynamicMap> objectRoleSnapshot =
                await userObjectRoleRef.get();
            if (objectRoleSnapshot.exists) {
              objectRole = ObjectRole.fromJson(objectRoleSnapshot.data()!);
              final companySnapshot = await objectRole.companyRef.get();
              final employeeSnapshot = await objectRole.employeeRef.get();
              Company company = Company.fromMap(companySnapshot.data()!);
              Employee employee = Employee.fromSnapshot(employeeSnapshot);
              displayName = employee.displayName();
              companyLabel = company.companyLabel;
            }
          }
        } else {
          anonReminder = DateTime.now().add(Duration(days: 7));
          SignInUserAction action =
              SignInUserAction(sbmContext.firestore, userRef);
          await action.performAction(SignInUserModel(userRef, anonReminder));
        }
        sbmContext.init(SbmUser(
            companyLabel: companyLabel,
            displayName: displayName,
            userRef: userRef,
            objectRole: objectRole,
            user: user,
            anonReminder: anonReminder));
        await _initNotifications();
        emit(AuthInitialized(sbmContext));
      } else {
        emit(AuthNotLoggedIn());
      }
    });
  }

  _initNotifications() async {
    if (!kIsWeb) {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.requestPermission();
      log(settings.authorizationStatus.toString());
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _updateTokenIfNecessary(sbmContext.userRef, token);
      }
      FirebaseMessaging.instance.onTokenRefresh.listen((String token) {
        _updateTokenIfNecessary(sbmContext.userRef, token);
      });
    }
  }

  Future _updateTokenIfNecessary(
      DocumentReference userRef, String token) async {
    NotificationTokenSaveAction notificationTokenSave =
        NotificationTokenSaveAction(sbmContext.firestore, sbmContext.userRef);
    await notificationTokenSave
        .performAction(NotificationTokenSaveModel(token));
  }

  updateUser() async {
    final userSnapshot = await sbmContext.userRef.get();
    DocumentReference? companyRef = userSnapshot.data()!["companyRef"];
    if (companyRef != null) {
      DocumentSnapshot<DynamicMap> objectRoleSnapshot = await sbmContext
          .queryBuilder
          .objectRoleRef(sbmContext.userRef, companyRef)
          .get();
      if (objectRoleSnapshot.exists) {
        sbmContext.user.objectRole =
            ObjectRole.fromJson(objectRoleSnapshot.data()!);
        emit(AuthInitialized(sbmContext));
      }
    }
  }

  signIn() {
    emit(AuthInProgress());
    sbmContext. auth.signInAnonymously();
  }

  signOut() {
    emit(AuthInProgress());
    sbmContext.auth.signOut();
  }

  @override
  Future<void> close() async {
    log("authcubit closed");
    await _authStateChanges.cancel();
    return super.close();
  }
}
