import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:student_monitoring_app/models/student.dart' as model;

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.Student> getStudentDetails() async {
    User currentUser = _auth.currentUser!;
    DocumentSnapshot snap =
        await _firestore.collection('students').doc(currentUser.uid).get();

    return model.Student.fromFirestore(snap);
  }

  Future<String> signUpStudent({
    required String email,
    required String password,
    required String name,
    required String studentType,
    required String parentEmail,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty &&
          password.isNotEmpty &&
          name.isNotEmpty &&
          studentType.isNotEmpty) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        model.Student student = model.Student(
          id: cred.user!.uid,
          name: name,
          email: email,
          studentType: studentType,
          parentEmail: parentEmail,
        );

        await _firestore
            .collection('students')
            .doc(cred.user!.uid)
            .set(student.toFirestore());
        res = 'success';
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == 'invalid-email') res = 'Invalid email';
      if (err.code == 'weak-password') res = 'Weak password';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> loginStudent(
      {required String email, required String password}) async {
    String res = 'Some error occurred';
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = 'success';
      } else {
        res = 'Please enter all details';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}
