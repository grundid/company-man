import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smallbusiness/reusable/user_actions/models.dart';

class QueryBuilder {
  final FirebaseFirestore firestore;
  final String logsPath;
  final String usersPath;

  QueryBuilder({
    required this.firestore,
    this.logsPath = "logs",
    this.usersPath = "users",
  });

  CollectionReference<DynamicMap> logsCollection() {
    return firestore.collection(logsPath);
  }

  CollectionReference<DynamicMap> usersCollection() {
    return firestore.collection(usersPath);
  }

  DocumentReference<DynamicMap> clientAppVersion(String appVersion) {
    return firestore.collection("clients").doc(appVersion);
  }

  CollectionReference<DynamicMap> invitationsCollection() {
    return firestore.collection("invitations");
  }

  CollectionReference<DynamicMap> invitationResponsesCollection() {
    return firestore.collection("invitationResponses");
  }

  CollectionReference<DynamicMap> timeRecordingsCollection() {
    return firestore.collection("timeRecordings");
  }

  Query<DynamicMap> latestTimeRecordingForEmployeeRef(
      DocumentReference companyRef, DocumentReference employeeRef) {
    return timeRecordingsCollection()
        .where("companyRef", isEqualTo: companyRef)
        .where("employeeRef", isEqualTo: employeeRef)
        .where("finalized", isEqualTo: false)
        .orderBy("from");
  }

  Query<DynamicMap> timeRecordingForEmployeeRef(
      {required DocumentReference companyRef,
      required DocumentReference employeeRef}) {
    return timeRecordingsCollection()
        .where("companyRef", isEqualTo: companyRef)
        .where("employeeRef", isEqualTo: employeeRef);
  }

  Query<DynamicMap> timeRecordingsForCompanyRef(
      {required DocumentReference companyRef}) {
    return timeRecordingsCollection()
        .where("companyRef", isEqualTo: companyRef);
  }

  Query<DynamicMap> invitationForEmployeeRef(
      DocumentReference companyRef, DocumentReference employeeRef) {
    return invitationsCollection()
        .where("companyRef", isEqualTo: companyRef)
        .where("employeeRef", isEqualTo: employeeRef);
  }

  Query<DynamicMap> objectRoleForEmployeeRef(
      DocumentReference companyRef, DocumentReference employeeRef) {
    return firestore
        .collectionGroup("objectRoles")
        .where("companyRef", isEqualTo: companyRef)
        .where("employeeRef", isEqualTo: employeeRef);
  }

  DocumentReference<DynamicMap> objectRoleRef(
      DocumentReference userRef, DocumentReference objectRef) {
    return userRef.collection("objectRoles").doc(objectRef.id);
  }

  CollectionReference<DynamicMap> companiesCollection() {
    return firestore.collection("companies");
  }

  CollectionReference<DynamicMap> employeesCollection(
      DocumentReference<DynamicMap> companyRef) {
    return companyRef.collection("employees");
  }

  CollectionReference<DynamicMap> wagesCollection(
      DocumentReference<DynamicMap> employeeRef) {
    return employeeRef.collection("wages");
  }

  Query<DynamicMap> wagesForCompany(DocumentReference<DynamicMap> companyRef) {
    return firestore
        .collectionGroup("wages")
        .where("companyRef", isEqualTo: companyRef);
  }

  DocumentReference<DynamicMap> companyRef(String id) {
    return companiesCollection().doc(id);
  }

  DocumentReference<DynamicMap> employeeRef(
      DocumentReference<DynamicMap> companyRef, String id) {
    return employeesCollection(companyRef).doc(id);
  }
}
