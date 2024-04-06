import 'package:cloud_firestore/cloud_firestore.dart';
class FirestoreService{
  final CollectionReference notes=FirebaseFirestore.instance.collection('notes');

  //create
Future<void> addNote(int uid,String pass,String role){
  return notes.doc(uid.toString()).set({
    'UID':uid,
    'Password':pass,
    'Role':role,
  });
}  
Future<void> addNotes(int uid,String pass,String role,String year){
  return notes.doc(uid.toString()).set({
    'UID':uid,
    'Password':pass,
    'Role':role,
    'Class':"Room2",
    'Year':year,
    'Subjects':{}
  });
}
}