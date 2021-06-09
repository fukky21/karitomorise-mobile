import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseReportRepository {
  final _firebaseAuth = FirebaseAuth.instance;
  final _firebaseFirestore = FirebaseFirestore.instance;

  Future<void> sendReport({
    @required String report,
    @required int postNumber,
  }) async {
    final now = DateTime.now();

    await _firebaseFirestore.collection('reports').add(
      <String, dynamic>{
        'documentVersion': 1,
        'uid': _firebaseAuth.currentUser.uid,
        'postNumber': postNumber,
        'body': report,
        'isChecked': false,
        'createdAt': now,
        'updatedAt': now,
      },
    );
  }
}
