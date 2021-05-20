import 'package:cloud_firestore/cloud_firestore.dart';

class FirebasePublicRepository {
  final _firebaseFirestore = FirebaseFirestore.instance;

  Future<List<String>> getHotwords() async {
    final snapshot =
        await _firebaseFirestore.collection('public').doc('static').get();
    final data = snapshot.data();

    final hotwords = <String>[];
    if (data != null) {
      for (final hotword in data['hotwords'] as List<dynamic>) {
        hotwords.add(hotword as String);
      }
    }
    return hotwords;
  }
}
