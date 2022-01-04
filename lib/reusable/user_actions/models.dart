import 'package:cloud_firestore/cloud_firestore.dart';

typedef DynamicMap = Map<String, dynamic>;

enum ActionResults { ok, error, notFound }

class ActionResult {
  final ActionResults result;
  final String? message;

  /// Data content can be returned to the caller of the action.
  final dynamic data;
  final String? actionType;
  final DocumentReference? actionReference;

  /// Content will be stored with the log.
  final DynamicMap? actionContent;

  bool get ok => result == ActionResults.ok;
  bool get empty => actionType == null;

  ActionResult.notFound()
      : result = ActionResults.notFound,
        message = null,
        data = null,
        actionType = null,
        actionReference = null,
        actionContent = null;

  ActionResult.error(this.message)
      : result = ActionResults.error,
        data = null,
        actionType = null,
        actionReference = null,
        actionContent = null;
  ActionResult.ok(this.actionType, this.actionReference, this.actionContent,
      {this.message, this.data})
      : result = ActionResults.ok;

  ActionResult.emptyOk({this.message})
      : result = ActionResults.ok,
        data = null,
        actionType = null,
        actionReference = null,
        actionContent = null;
}
