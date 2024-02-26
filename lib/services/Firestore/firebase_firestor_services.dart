import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseFirestoreServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addData(String collection, Map<String, dynamic> data,
      {String? docId}) async {
    if (docId != null) {
      await _firestore.collection(collection).doc(docId).set(data);
    } else {
      await _firestore.collection(collection).add(data);
    }
  }

  Future<void> updateData(
      String collection, Map<String, dynamic> data, String docId) async {
    await _firestore.collection(collection).doc(docId).update(data);
  }

  Future<void> deleteData(String collection, String docId) async {
    await _firestore.collection(collection).doc(docId).delete();
  }

  getCollectionData(String collection, {bool stream = false}) async {
    if (stream) {
      return _firestore.collection(collection).snapshots();
    }
    return _firestore.collection(collection).get();
  }

  getUserData(String collection, String docId, {bool stream = false}) async {
    if (stream) {
      return _firestore.collection(collection).doc(docId).snapshots();
    }
    return _firestore.collection(collection).doc(docId).get();
  }
}
