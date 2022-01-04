import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

mixin BatchHelper {
  static const maxEntriesPerBatch = 450; // real limit is 500
  late FirebaseFirestore _batchFirestore;
  late WriteBatch _batch;
  int _batchCount = 0;
  bool logging = false;

  startBatch(FirebaseFirestore firestore) {
    _batchFirestore = firestore;
    _batch = firestore.batch();
  }

  finishBatch() async {
    if (_batchCount > 0) {
      return _batch.commit();
    }
  }

  addDeleteToBatch(DocumentReference ref,
      {int commitAfter = maxEntriesPerBatch}) async {
    _batch.delete(ref);
    if (logging) {
      log("batch delete: $ref");
    }
    await _processBatch(commitAfter);
  }

  addUpdateToBatch(DocumentReference ref, Map<String, dynamic> data,
      {int commitAfter = maxEntriesPerBatch}) async {
    _batch.update(ref, data);
    if (logging) {
      log("batch update: $ref => $data");
    }
    await _processBatch(commitAfter);
  }

  addSetDataToBatch(DocumentReference ref, Map<String, dynamic> data,
      {int commitAfter = maxEntriesPerBatch, bool merge = false}) async {
    _batch.set(ref, data, SetOptions(merge: merge));
    if (logging) {
      log("batch set: $ref => $data");
    }
    await _processBatch(commitAfter);
  }

  Future _processBatch(int commitAfter) async {
    _batchCount++;
    if (_batchCount > commitAfter) {
      _batchCount = 0;
      await _batch.commit();
      _batch = _batchFirestore.batch();
    }
  }
}
