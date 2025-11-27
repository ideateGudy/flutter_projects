import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // get collection of notes
  final CollectionReference notesCollection = FirebaseFirestore.instance
      .collection('notes');

  //CREATE: add note
  Future<void> addNote(String text) {
    return notesCollection.add({'note': text, 'timestamp': Timestamp.now()});
  }

  //READ: get notes from database
  Stream<QuerySnapshot> getNotes() {
    return notesCollection.orderBy('timestamp', descending: true).snapshots();
  }

  //UPDATE: update note given an id
  Future<void> updateNote(String docId, String newText) {
    return notesCollection.doc(docId).update({'note': newText, 'timestamp': Timestamp.now()});
  }

  //DELETE: delete note given an id
  Future<void> deleteNote(String docId) {
    return notesCollection.doc(docId).delete();
  }
}
