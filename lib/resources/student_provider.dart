// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/foundation.dart';

// // import '../models/student.dart';
// // import 'auth_methods.dart';

// // class StudentProvider with ChangeNotifier {
// //   final FirebaseAuth _auth = FirebaseAuth.instance;
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// //   final AuthMethods _authMethods = AuthMethods();

// //   Student? _student;
// //   User? _user;
// //   bool _isDataLoaded = false;

// //   Student? get getStudent => _student;
// //   bool get isAuthenticated => _user != null;
// //   bool get isDataLoaded => _isDataLoaded;

// //   StudentProvider() {
// //     _auth.authStateChanges().listen((user) async {
// //       _user = user;
// //       if (_user != null) {
// //         await fetchStudentData();
// //       } else {
// //         _student = null;
// //         _isDataLoaded = true;
// //         notifyListeners();
// //       }
// //     });
// //   }

// //   Future<void> fetchStudentData() async {
// //     _isDataLoaded = false;
// //     notifyListeners();

// //     try {
// //       if (_user != null) {
// //         DocumentSnapshot studentDoc =
// //             await _firestore.collection('students').doc(_user!.uid).get();

// //         _student = Student.fromFirestore(studentDoc);
// //       }
// //     } catch (e) {
// //       print('Error fetching student data: $e');
// //       _student = null;
// //     } finally {
// //       _isDataLoaded = true;
// //       notifyListeners();
// //     }
// //   }

// //   Future<void> refreshStudent([Student? updatedStudent]) async {
// //     _isDataLoaded = false;
// //     notifyListeners();

// //     try {
// //       _student = updatedStudent ?? await _authMethods.getStudentDetails();
// //     } catch (e) {
// //       print('Error refreshing student data: $e');
// //       _student = null;
// //     } finally {
// //       _isDataLoaded = true;
// //       notifyListeners();
// //     }
// //   }

// // Future<void> updateStudent(Student updatedStudent) async {
// //   try {
// //     await _firestore
// //         .collection('students')
// //         .doc(_user!.uid)
// //         .update(updatedStudent.toJson());
// //     _student = updatedStudent;
// //     notifyListeners();
// //   } catch (e) {
// //     print('Error updating student: $e');
// //   }
// // }

// //   Future<void> signOut() async {
// //     await _auth.signOut();
// //     _student = null;
// //     _user = null;
// //     _isDataLoaded = true;
// //     notifyListeners();
// //   }
// // }
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:student_monitoring_app/models/student.dart';

// import 'auth_methods.dart';

// class StudentProvider with ChangeNotifier {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final AuthMethods _authMethods = AuthMethods();

//   Student? _student;
//   User? _user;
//   bool _isDataLoaded = false; // New flag

//   // Getter for student and auth status
//   Student? get getStudent => _student;
//   bool get isAuthenticated => _user != null;
//   bool get isDataLoaded => _isDataLoaded;

//   // Constructor to listen to auth state changes
//   StudentProvider() {
//     _auth.authStateChanges().listen((user) async {
//       _user = user;
//       if (_user != null) {
//         await fetchStudentData();
//       } else {
//         _student = null;
//         _isDataLoaded = true;
//         notifyListeners(); // Data load completed (no user)
//       }
//     });
//   }

//   // Fetch student data from Firestore
//   Future<void> fetchStudentData() async {
//     _isDataLoaded = false; // Start loading
//     notifyListeners();

//     try {
//       if (_user != null) {
//         DocumentSnapshot studentDoc =
//             await _firestore.collection('students').doc(_user!.uid).get();

//         _student = Student.fromFirestore(studentDoc);
//       }
//     } catch (e) {
//       print('Error fetching student data: $e');
//       _student = null;
//     } finally {
//       _isDataLoaded = true; // Loading complete
//       notifyListeners();
//     }
//   }

//   // Refresh using AuthMethods (existing logic)
//   Future<void> refreshStudent([Student? updatedStudent]) async {
//     _isDataLoaded = false;
//     notifyListeners();

//     try {
//       _student = updatedStudent ?? await _authMethods.getStudentDetails();
//     } catch (e) {
//       print('Error refreshing student data: $e');
//       _student = null;
//     } finally {
//       _isDataLoaded = true;
//       notifyListeners();
//     }
//   }

//   // Refresh from AuthMethods specifically
//   Future<void> refreshStudentFromAuth() async {
//     _isDataLoaded = false;
//     notifyListeners();

//     try {
//       _student = await _authMethods.getStudentDetails();
//     } catch (e) {
//       print('Error refreshing student from auth: $e');
//       _student = null;
//     } finally {
//       _isDataLoaded = true;
//       notifyListeners();
//     }
//   }

//   Future<void> updateStudent(Student updatedStudent) async {
//     try {
//       await _firestore
//           .collection('students')
//           .doc(_user!.uid)
//           .update(updatedStudent.toJson());
//       _student = updatedStudent;
//       notifyListeners();
//     } catch (e) {
//       print('Error updating student: $e');
//     }
//   }

//   // Sign out method
//   Future<void> signOut() async {
//     await _auth.signOut();
//     _student = null;
//     _user = null;
//     _isDataLoaded = true; // Avoid loading indicator on sign-out
//     notifyListeners();
//   }
// }



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
  bool _isDataLoaded = false;
  bool _isLoading = false;
  String? _error;

  // Getters
  Student? get getStudent => _student;
  bool get isAuthenticated => _user != null;
  bool get isDataLoaded => _isDataLoaded;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Constructor to listen to auth state changes
  StudentProvider() {
    _auth.authStateChanges().listen((user) async {
      _user = user;
      if (_user != null) {
        await fetchStudentData();
      } else {
        _student = null;
        _isDataLoaded = true;
        _error = null;
        notifyListeners();
      }
    });
  }

  // Fetch student data from Firestore with improved error handling
  Future<void> fetchStudentData() async {
    if (_isLoading) return; // Prevent multiple simultaneous fetches
    
    _isLoading = true;
    _isDataLoaded = false;
    _error = null;
    notifyListeners();

    try {
      if (_user != null) {
        final String uid = _user!.uid.trim();
        print('Fetching student data for UID: $uid');
        
        DocumentSnapshot studentDoc = await _firestore
            .collection('students')
            .doc(uid)
            .get();

        if (studentDoc.exists) {
          _student = Student.fromFirestore(studentDoc);
          print('Student data loaded successfully: ${_student?.id}');
        } else {
          _error = "Student document not found";
          print('Error: Student document not found for UID: $uid');
        }
      }
    } catch (e) {
      _error = "Error fetching student data: $e";
      print('Error fetching student data: $e');
      _student = null;
    } finally {
      _isLoading = false;
      _isDataLoaded = true;
      notifyListeners();
    }
  }

  // Refresh using AuthMethods with retry logic
  Future<void> refreshStudentFromAuth() async {
    if (_isLoading) return;
    
    _isLoading = true;
    _isDataLoaded = false;
    _error = null;
    notifyListeners();

    try {
      // First, ensure we have a current user
      if (_auth.currentUser == null) {
        print('No authenticated user found when refreshing from auth');
        _error = "No authenticated user";
        _student = null;
        return;
      }

      // Try getting student details via AuthMethods
      _student = await _authMethods.getStudentDetails();
      
      // If that failed, fall back to direct Firestore fetch
      if (_student == null) {
        print('AuthMethods returned null student, falling back to Firestore');
        await fetchStudentData();
      } else {
        print('Successfully loaded student via AuthMethods: ${_student?.id}');
      }
    } catch (e) {
      print('Error refreshing student from auth: $e');
      _error = "Error refreshing student: $e";
      
      // On failure, try direct Firestore fetch as backup
      try {
        await fetchStudentData();
      } catch (e2) {
        print('Backup fetch also failed: $e2');
      }
    } finally {
      _isLoading = false;
      _isDataLoaded = true;
      notifyListeners();
    }
  }

  // Generic refresh method
  Future<void> refreshStudent([Student? updatedStudent]) async {
    if (_isLoading) return;
    
    _isLoading = true;
    _isDataLoaded = false;
    notifyListeners();

    try {
      if (updatedStudent != null) {
        _student = updatedStudent;
      } else {
        _student = await _authMethods.getStudentDetails();
        if (_student == null) {
          await fetchStudentData();
        }
      }
    } catch (e) {
      print('Error refreshing student data: $e');
      _error = "Error refreshing student: $e";
      _student = null;
    } finally {
      _isLoading = false;
      _isDataLoaded = true;
      notifyListeners();
    }
  }

  Future<void> updateStudent(Student updatedStudent) async {
    try {
      if (_user == null) {
        _error = "Cannot update: No authenticated user";
        notifyListeners();
        return;
      }
      
      await _firestore
          .collection('students')
          .doc(_user!.uid)
          .update(updatedStudent.toJson());
          
      _student = updatedStudent;
      _error = null;
      notifyListeners();
    } catch (e) {
      print('Error updating student: $e');
      _error = "Error updating student: $e";
      notifyListeners();
    }
  }

  // Sign out method
  Future<void> signOut() async {
    await _auth.signOut();
    _student = null;
    _user = null;
    _error = null;
    _isDataLoaded = true;
    notifyListeners();
  }
}