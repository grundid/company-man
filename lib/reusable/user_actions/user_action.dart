import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smallbusiness/reusable/batch_helper.dart';
import 'package:smallbusiness/reusable/query_builder.dart';
import 'package:smallbusiness/reusable/user_actions/action_log.dart';
import 'package:smallbusiness/reusable/user_actions/models.dart';

class _ActionLogEntry {
  final DocumentReference logRef;
  final Map<String, dynamic> data;

  _ActionLogEntry(this.logRef, this.data);
}

class ActionLogList {
  final DocumentReference userRef;
  final List<ActionLog> _actionLogList = [];
  final QueryBuilder _queryBuilder;

  QueryBuilder get queryBuilder => _queryBuilder;

  ActionLogList(FirebaseFirestore _firestore, this.userRef)
      : _queryBuilder = QueryBuilder(firestore: _firestore);

  Iterable<_ActionLogEntry> purgeActionLog() {
    CollectionReference logs = _queryBuilder.logsCollection();

    Iterable<_ActionLogEntry> result = _actionLogList
        .map((e) => _ActionLogEntry(logs.doc(), e.toMap()))
        .toList();
    _actionLogList.clear();
    return result;
  }

  void clearActionLog() {
    _actionLogList.clear();
  }

  void appendActionLog(ActionResult result) {
    if (!result.empty) {
      ActionLog actionLog = ActionLog(
        type: result.actionType!,
        reference: result.actionReference,
        created: DateTime.now(),
        userRef: userRef,
        content: result.actionContent,
      );
      _actionLogList.add(actionLog);
    }
  }
}

abstract class UserAction<A> extends ActionLogList with BatchHelper {
  final FirebaseFirestore _firestore;
  DateTime? _actionDateTime;

  UserAction(this._firestore, DocumentReference userRef)
      : super(_firestore, userRef);

  DateTime get actionDateTime {
    _actionDateTime ??= DateTime.now();
    return _actionDateTime!;
  }

  Future<ActionResult> performActionInternal(A action);

  Future<ActionResult> performAction(A action) async {
    startBatch(_firestore);
    clearActionLog();

    ActionResult result = await performActionInternal(action);
    if (result.ok) {
      appendActionLog(result);
      Iterable<_ActionLogEntry> logEntries = purgeActionLog();
      for (_ActionLogEntry entry in logEntries) {
        await addSetDataToBatch(entry.logRef, entry.data);
      }
      await finishBatch();
    }
    return result;
  }

  void deleteQueryResults(Query query) async {
    QuerySnapshot querySnapshot = await query.get();
    for (DocumentSnapshot snapshot in querySnapshot.docs) {
      await addDeleteToBatch(snapshot.reference);
    }
  }

  void _appendCreatedBy(Map<String, dynamic> data) {
    data["createdBy"] = userRef.id;
    data["created"] = actionDateTime;
  }

  void _appendUpdatedBy(Map<String, dynamic> data) {
    data["updatedBy"] = userRef.id;
    data["updated"] = actionDateTime;
  }

  @override
  addSetDataToBatch(DocumentReference ref, Map<String, dynamic> data,
      {int commitAfter = BatchHelper.maxEntriesPerBatch, bool merge = false}) {
    _appendCreatedBy(data);
    return super
        .addSetDataToBatch(ref, data, commitAfter: commitAfter, merge: merge);
  }

  @override
  addUpdateToBatch(DocumentReference ref, Map<String, dynamic> data,
      {int commitAfter = BatchHelper.maxEntriesPerBatch,
      bool appendUpdatedBy = true}) {
    if (appendUpdatedBy) {
      _appendUpdatedBy(data);
    }
    return super.addUpdateToBatch(ref, data, commitAfter: commitAfter);
  }
/*
  addObjectRole(ObjectRole objectRole) async {
    String ownerId = userRef.id;
    DocumentReference objectRef = objectRole.objectRef;
    return addSetDataToBatch(
        queryBuilder.objectRolesForUser(ownerId).document(objectRef.id),
        objectRole.toMap());
  }*/
}
