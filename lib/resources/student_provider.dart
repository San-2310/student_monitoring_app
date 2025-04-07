import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_monitoring_app/models/student.dart';

import 'auth_methods.dart';

class StudentProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthMethods _authMethods = AuthMethods();

  Student? _student;
  User? _user;
  bool _isDataLoaded = false; // New flag

  // Getter for student and auth status
  Student? get getStudent => _student;
  bool get isAuthenticated => _user != null;
  bool get isDataLoaded => _isDataLoaded;

  // Constructor to listen to auth state changes
  StudentProvider() {
    _auth.authStateChanges().listen((user) {
      _user = user;
      if (_user != null) {
        fetchStudentData();
      } else {
        _student = null;
        _isDataLoaded = true; // Data load completed (no user)
      }
      notifyListeners();
    });
  }

  // Fetch student data from Firestore
  Future<void> fetchStudentData() async {
    _isDataLoaded = false; // Start loading
    notifyListeners();

    try {
      if (_user != null) {
        DocumentSnapshot studentDoc =
            await _firestore.collection('students').doc(_user!.uid).get();

        _student = Student.fromFirestore(studentDoc);
      }
    } catch (e) {
      print('Error fetching student data: $e');
      _student = null;
    } finally {
      _isDataLoaded = true; // Loading complete
      notifyListeners();
    }
  }

  // Refresh using AuthMethods (existing logic)
  Future<void> refreshStudent([Student? updatedStudent]) async {
    _isDataLoaded = false;
    notifyListeners();

    try {
      _student = updatedStudent ?? await _authMethods.getStudentDetails();
    } catch (e) {
      print('Error refreshing student data: $e');
      _student = null;
    } finally {
      _isDataLoaded = true;
      notifyListeners();
    }
  }

  // Refresh from AuthMethods specifically
  Future<void> refreshStudentFromAuth() async {
    _isDataLoaded = false;
    notifyListeners();

    try {
      _student = await _authMethods.getStudentDetails();
    } catch (e) {
      print('Error refreshing student from auth: $e');
      _student = null;
    } finally {
      _isDataLoaded = true;
      notifyListeners();
    }
  }

  // Sign out method
  Future<void> signOut() async {
    await _auth.signOut();
    _student = null;
    _user = null;
    _isDataLoaded = true; // Avoid loading indicator on sign-out
    notifyListeners();
  }
}
