// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';

// class FaceMonitoringService extends ChangeNotifier {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // Monitoring state
//   DateTime _startTime = DateTime.now();
//   DateTime _lastActiveTime = DateTime.now();
//   bool _isActive = false;

//   // Session metrics
//   Duration _totalActiveTime = Duration.zero;
//   Duration _totalAbsenceTime = Duration.zero;
//   int _absenceCount = 0;

//   // Timers and thresholds
//   Timer? _absenceTimer;
//   final int _absenceThresholdSeconds = 2; // Minimum seconds to count as absence

//   // Getters
//   Duration get totalActiveTime => _totalActiveTime;
//   Duration get totalAbsenceTime => _totalAbsenceTime;
//   int get absenceCount => _absenceCount;
//   bool get isActive => _isActive;

//   // Start a new monitoring session
//   void startSession() {
//     _startTime = DateTime.now();
//     _lastActiveTime = _startTime;
//     _isActive = true;
//     _totalActiveTime = Duration.zero;
//     _totalAbsenceTime = Duration.zero;
//     _absenceCount = 0;

//     // Log session start
//     _logSessionEvent('started');
//     notifyListeners();
//   }

//   // User detected as present
//   void markPresent() {
//     final now = DateTime.now();

//     // Cancel any pending absence timer
//     _absenceTimer?.cancel();

//     if (!_isActive) {
//       // User just became active after absence
//       final absenceDuration = now.difference(_lastActiveTime);

//       // Only count substantial absences (avoid flickering)
//       if (absenceDuration.inSeconds >= _absenceThresholdSeconds) {
//         _totalAbsenceTime += absenceDuration;
//         _absenceCount++;

//         // Log absence event
//         _logPresenceEvent(false, absenceDuration);
//       }
//     }

//     _isActive = true;
//     _lastActiveTime = now;
//     notifyListeners();
//   }

//   // User detected as absent
//   void markAbsent() {
//     if (_isActive) {
//       final now = DateTime.now();

//       // Start a timer to wait before confirming absence
//       // This helps avoid counting brief detection misses
//       _absenceTimer?.cancel();
//       _absenceTimer = Timer(Duration(seconds: _absenceThresholdSeconds), () {
//         // Only execute if still inactive after the threshold
//         if (_isActive) {
//           final activeDuration = now.difference(_lastActiveTime);
//           _totalActiveTime += activeDuration;

//           // Log presence event
//           _logPresenceEvent(true, activeDuration);

//           _isActive = false;
//           _lastActiveTime = now;
//           notifyListeners();
//         }
//       });
//     }
//   }

//   // Process continuous monitoring with face detection
//   void processFaceDetection(bool faceDetected) {
//     if (faceDetected) {
//       markPresent();
//     } else {
//       markAbsent();
//     }
//   }

//   // End monitoring session
//   Future<void> endSession() async {
//     _absenceTimer?.cancel();
//     final now = DateTime.now();
//     final sessionDuration = now.difference(_startTime);

//     // Update final metrics based on current state
//     if (_isActive) {
//       final finalActiveDuration = now.difference(_lastActiveTime);
//       _totalActiveTime += finalActiveDuration;
//     } else {
//       final finalAbsenceDuration = now.difference(_lastActiveTime);
//       // Only count substantial absences
//       if (finalAbsenceDuration.inSeconds >= _absenceThresholdSeconds) {
//         _totalAbsenceTime += finalAbsenceDuration;
//       }
//     }

//     // Log session end with metrics
//     await _logSessionEvent('ended', {
//       'totalDuration': sessionDuration.inSeconds,
//       'activeTime': _totalActiveTime.inSeconds,
//       'absenceTime': _totalAbsenceTime.inSeconds,
//       'absenceCount': _absenceCount,
//       'activePercentage': sessionDuration.inSeconds > 0
//           ? (_totalActiveTime.inSeconds / sessionDuration.inSeconds * 100).round()
//           : 0,
//     });

//     // Update user's aggregate metrics
//     await updateUserMetrics();

//     _isActive = false;
//     notifyListeners();
//   }

//   // Get current absence duration
//   Duration getCurrentAbsenceDuration() {
//     if (_isActive) return Duration.zero;

//     return DateTime.now().difference(_lastActiveTime);
//   }

//   // Log presence/absence events
//   Future<void> _logPresenceEvent(bool wasPresent, Duration duration) async {
//     final user = _auth.currentUser;
//     if (user == null) return;

//     // Don't log very brief events
//     if (duration.inSeconds < _absenceThresholdSeconds) return;

//     try {
//       await _firestore
//           .collection('users')
//           .doc(user.uid)
//           .collection('presenceLogs')
//           .add({
//         'timestamp': FieldValue.serverTimestamp(),
//         'type': wasPresent ? 'present' : 'absent',
//         'duration': duration.inSeconds,
//         'sessionId': _startTime.millisecondsSinceEpoch.toString(),
//       });
//     } catch (e) {
//       debugPrint('Error logging presence event: $e');
//     }
//   }

//   // Log session events
//   Future<void> _logSessionEvent(String event, [Map<String, Object>? metrics]) async {
//     final user = _auth.currentUser;
//     if (user == null) return;

//     try {
//       final data = {
//         'timestamp': FieldValue.serverTimestamp(),
//         'event': event,
//         'sessionId': _startTime.millisecondsSinceEpoch.toString(),
//       };

//       if (metrics != null) {
//         data.addAll(metrics);
//       }

//       await _firestore
//           .collection('users')
//           .doc(user.uid)
//           .collection('sessionLogs')
//           .add(data);
//     } catch (e) {
//       debugPrint('Error logging session event: $e');
//     }
//   }

//   // Update user metrics on Firestore
//   Future<void> updateUserMetrics() async {
//     final user = _auth.currentUser;
//     if (user == null) return;

//     try {
//       await _firestore.collection('users').doc(user.uid).update({
//         'lastActive': FieldValue.serverTimestamp(),
//         'totalActiveTime': FieldValue.increment(_totalActiveTime.inSeconds),
//         'totalAbsenceTime': FieldValue.increment(_totalAbsenceTime.inSeconds),
//         'absenceCount': FieldValue.increment(_absenceCount),
//       });
//     } catch (e) {
//       debugPrint('Error updating user metrics: $e');
//     }
//   }

//   // Clean up resources
//   @override
//   void dispose() {
//     _absenceTimer?.cancel();
//     endSession();
//     super.dispose();
//   }
// }

// import 'dart:async';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';

// class FaceMonitoringService extends ChangeNotifier {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   int _appSwitchCount = 0;
//   int get appSwitchCount => _appSwitchCount;

//   // Monitoring state
//   DateTime _startTime = DateTime.now();
//   DateTime _lastActiveTime = DateTime.now();
//   bool _isActive = false;

//   // Session metrics
//   Duration _totalActiveTime = Duration.zero;
//   Duration _totalAbsenceTime = Duration.zero;
//   int _absenceCount = 0;

//   // Getters
//   Duration get totalActiveTime => _totalActiveTime;
//   Duration get totalAbsenceTime => _totalAbsenceTime;
//   int get absenceCount => _absenceCount;
//   bool get isActive => _isActive;

//   // Start a new monitoring session
//   void startSession() {
//     _startTime = DateTime.now();
//     _lastActiveTime = _startTime;
//     _isActive = true;
//     _totalActiveTime = Duration.zero;
//     _totalAbsenceTime = Duration.zero;
//     _absenceCount = 0;
//     _appSwitchCount = 0;

//     // Log session start
//     _logSessionEvent('started');
//     notifyListeners();
//   }

//   void incrementAppSwitches() {
//     _appSwitchCount++;
//     debugPrint("📱 App switch detected: $_appSwitchCount");
//     notifyListeners(); // if UI wants to listen
//   }

//   // User detected as present
//   void markPresent() {
//     final now = DateTime.now();

//     if (!_isActive) {
//       // User just became active after absence
//       final absenceDuration = now.difference(_lastActiveTime);
//       _totalAbsenceTime += absenceDuration;

//       // Log absence event
//       _logPresenceEvent(false, absenceDuration);

//       _absenceCount++;
//     }

//     _isActive = true;
//     _lastActiveTime = now;
//     notifyListeners();
//   }

//   // User detected as absent
//   void markAbsent() {
//     if (_isActive) {
//       // User just became inactive
//       final now = DateTime.now();
//       final activeDuration = now.difference(_lastActiveTime);
//       _totalActiveTime += activeDuration;

//       // Log presence event
//       _logPresenceEvent(true, activeDuration);

//       _isActive = false;
//       _lastActiveTime = now;
//       notifyListeners();
//     }
//   }

//   // End monitoring session
//   Future<void> endSession(BuildContext context) async {
//     final now = DateTime.now();
//     final sessionDuration = now.difference(_startTime);

//     // Update final metrics based on current state
//     if (_isActive) {
//       final finalActiveDuration = now.difference(_lastActiveTime);
//       _totalActiveTime += finalActiveDuration;
//     } else {
//       final finalAbsenceDuration = now.difference(_lastActiveTime);
//       _totalAbsenceTime += finalAbsenceDuration;
//     }

//     // Log session end with metrics
//     await _logSessionEvent('ended', {
//       'totalDuration': sessionDuration.inSeconds,
//       'activeTime': _totalActiveTime.inSeconds,
//       'absenceTime': _totalAbsenceTime.inSeconds,
//       'absenceCount': _absenceCount,
//       'activePercentage': sessionDuration.inSeconds > 0
//           ? (_totalActiveTime.inSeconds / sessionDuration.inSeconds * 100)
//               .round()
//           : 0,
//       'appSwitches': _appSwitchCount,
//     });
//     // Navigator.of(context).pushReplacement(
//     //   MaterialPageRoute(builder: (context) => QuestionnaireScreen()),
//     // );
//     _isActive = false;
//     notifyListeners();
//   }

//   Future<Map<String, dynamic>> endSessionAndGetMetrics() async {
//     final now = DateTime.now();
//     final sessionDuration = now.difference(_startTime);

//     if (_isActive) {
//       final finalActiveDuration = now.difference(_lastActiveTime);
//       _totalActiveTime += finalActiveDuration;
//     } else {
//       final finalAbsenceDuration = now.difference(_lastActiveTime);
//       _totalAbsenceTime += finalAbsenceDuration;
//     }

//     final activePercentage = sessionDuration.inSeconds > 0
//         ? (_totalActiveTime.inSeconds / sessionDuration.inSeconds)
//         : 0.0;

//     final Map<String, dynamic> sessionMetrics = {
//       "startTime": Timestamp.fromDate(_startTime),
//       "endTime": Timestamp.fromDate(now),
//       "inFrame": double.parse(activePercentage.toStringAsFixed(2)),
//       "appSwitches": _appSwitchCount,
//     };

//     _isActive = false;
//     notifyListeners();

//     return sessionMetrics;
//   }

//   // Get current absence duration
//   Duration getCurrentAbsenceDuration() {
//     if (_isActive) return Duration.zero;

//     return DateTime.now().difference(_lastActiveTime);
//   }

//   // Log presence/absence events
//   Future<void> _logPresenceEvent(bool wasPresent, Duration duration) async {
//     final user = _auth.currentUser;
//     if (user == null) return;

//     try {
//       await _firestore
//           .collection('students')
//           .doc(user.uid)
//           .collection('presenceLogs')
//           .add({
//         'timestamp': FieldValue.serverTimestamp(),
//         'type': wasPresent ? 'present' : 'absent',
//         'duration': duration.inSeconds,
//       });
//     } catch (e) {
//       debugPrint('Error logging presence event: $e');
//     }
//   }

//   // Log session events
//   Future<void> _logSessionEvent(String event,
//       [Map<String, Object>? metrics]) async {
//     final user = _auth.currentUser;
//     if (user == null) return;

//     try {
//       final data = {
//         'timestamp': FieldValue.serverTimestamp(),
//         'event': event,
//       };

//       if (metrics != null) {
//         data.addAll(metrics);
//       }

//       await _firestore
//           .collection('students')
//           .doc(user.uid)
//           .collection('sessionLogs')
//           .add(data);
//     } catch (e) {
//       debugPrint('Error logging session event: $e');
//     }
//   }

//   // Update user metrics on Firestore
//   Future<void> updateUserMetrics() async {
//     final user = _auth.currentUser;
//     if (user == null) return;

//     try {
//       await _firestore.collection('students').doc(user.uid).update({
//         'lastActive': FieldValue.serverTimestamp(),
//         'totalActiveTime': FieldValue.increment(_totalActiveTime.inSeconds),
//         'totalAbsenceTime': FieldValue.increment(_totalAbsenceTime.inSeconds),
//         'absenceCount': FieldValue.increment(_absenceCount),
//       });
//     } catch (e) {
//       debugPrint('Error updating user metrics: $e');
//     }
//   }

//   // Process continuous monitoring with face detection
//   void processFaceDetection(bool faceDetected) {
//     if (faceDetected) {
//       markPresent();
//     } else {
//       markAbsent();
//     }
//   }

//   // Clean up resources
//   @override
//   void dispose() {
//     // endSession();
//     super.dispose();
//   }
// }













import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FaceMonitoringService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _appSwitchCount = 0;
  int get appSwitchCount => _appSwitchCount;

  // Monitoring state
  DateTime _startTime = DateTime.now();
  DateTime _lastActiveTime = DateTime.now();
  bool _isActive = false;
  bool _isInitialized = false; // Flag to prevent immediate notifications during setup

  // Session metrics
  Duration _totalActiveTime = Duration.zero;
  Duration _totalAbsenceTime = Duration.zero;
  int _absenceCount = 0;

  // Getters
  Duration get totalActiveTime => _totalActiveTime;
  Duration get totalAbsenceTime => _totalAbsenceTime;
  int get absenceCount => _absenceCount;
  bool get isActive => _isActive;
  bool get isInitialized => _isInitialized;

  // Start a new monitoring session
  void startSession() {
    _startTime = DateTime.now();
    _lastActiveTime = _startTime;
    _isActive = true;
    _totalActiveTime = Duration.zero;
    _totalAbsenceTime = Duration.zero;
    _absenceCount = 0;
    _appSwitchCount = 0;
    
    // Log session start
    _logSessionEvent('started');
    
    // Set initialization flag after setup
    _isInitialized = true;
    notifyListeners();
  }

  void incrementAppSwitches() {
    _appSwitchCount++;
    debugPrint("📱 App switch detected: $_appSwitchCount");
    
    // Only notify if fully initialized
    if (_isInitialized) {
      notifyListeners();
    }
  }

  // User detected as present
  void markPresent() {
    if (!_isInitialized) return; // Skip if not initialized
    
    final now = DateTime.now();

    if (!_isActive) {
      // User just became active after absence
      final absenceDuration = now.difference(_lastActiveTime);
      _totalAbsenceTime += absenceDuration;

      // Log absence event
      _logPresenceEvent(false, absenceDuration);

      _absenceCount++;
    }

    _isActive = true;
    _lastActiveTime = now;
    notifyListeners();
  }

  // User detected as absent
  void markAbsent() {
    if (!_isInitialized) return; // Skip if not initialized
    
    if (_isActive) {
      // User just became inactive
      final now = DateTime.now();
      final activeDuration = now.difference(_lastActiveTime);
      _totalActiveTime += activeDuration;

      // Log presence event
      _logPresenceEvent(true, activeDuration);

      _isActive = false;
      _lastActiveTime = now;
      notifyListeners();
    }
  }

  // End monitoring session
  Future<void> endSession(BuildContext context) async {
    if (!_isInitialized) return; // Skip if not initialized
    
    final now = DateTime.now();
    final sessionDuration = now.difference(_startTime);

    // Update final metrics based on current state
    if (_isActive) {
      final finalActiveDuration = now.difference(_lastActiveTime);
      _totalActiveTime += finalActiveDuration;
    } else {
      final finalAbsenceDuration = now.difference(_lastActiveTime);
      _totalAbsenceTime += finalAbsenceDuration;
    }

    // Log session end with metrics
    await _logSessionEvent('ended', {
      'totalDuration': sessionDuration.inSeconds,
      'activeTime': _totalActiveTime.inSeconds,
      'absenceTime': _totalAbsenceTime.inSeconds,
      'absenceCount': _absenceCount,
      'activePercentage': sessionDuration.inSeconds > 0
          ? (_totalActiveTime.inSeconds / sessionDuration.inSeconds * 100)
              .round()
          : 0,
      'appSwitches': _appSwitchCount,
    });
    
    _isActive = false;
    
    // Use a post-frame callback to handle any navigation
    // This prevents build-time setState issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
      // If you need to navigate:
      // Navigator.of(context).pushReplacement(
      //   MaterialPageRoute(builder: (context) => QuestionnaireScreen()),
      // );
    });
  }

  Future<Map<String, dynamic>> endSessionAndGetMetrics() async {
    if (!_isInitialized) {
      return {
        "startTime": Timestamp.fromDate(_startTime),
        "endTime": Timestamp.fromDate(DateTime.now()),
        "inFrame": 0.0,
        "appSwitches": 0,
      };
    }
    
    final now = DateTime.now();
    final sessionDuration = now.difference(_startTime);

    if (_isActive) {
      final finalActiveDuration = now.difference(_lastActiveTime);
      _totalActiveTime += finalActiveDuration;
    } else {
      final finalAbsenceDuration = now.difference(_lastActiveTime);
      _totalAbsenceTime += finalAbsenceDuration;
    }

    final activePercentage = sessionDuration.inSeconds > 0
        ? (_totalActiveTime.inSeconds / sessionDuration.inSeconds)
        : 0.0;

    final Map<String, dynamic> sessionMetrics = {
      "startTime": Timestamp.fromDate(_startTime),
      "endTime": Timestamp.fromDate(now),
      "inFrame": double.parse(activePercentage.toStringAsFixed(2)),
      "appSwitches": _appSwitchCount,
    };

    _isActive = false;
    
    // Use post-frame callback for notification
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    return sessionMetrics;
  }

  // Get current absence duration
  Duration getCurrentAbsenceDuration() {
    if (_isActive) return Duration.zero;

    return DateTime.now().difference(_lastActiveTime);
  }

  // Log presence/absence events
  Future<void> _logPresenceEvent(bool wasPresent, Duration duration) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('students')
          .doc(user.uid)
          .collection('presenceLogs')
          .add({
        'timestamp': FieldValue.serverTimestamp(),
        'type': wasPresent ? 'present' : 'absent',
        'duration': duration.inSeconds,
      });
    } catch (e) {
      debugPrint('Error logging presence event: $e');
    }
  }

  // Log session events
  Future<void> _logSessionEvent(String event,
      [Map<String, Object>? metrics]) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final data = {
        'timestamp': FieldValue.serverTimestamp(),
        'event': event,
      };

      if (metrics != null) {
        data.addAll(metrics);
      }

      await _firestore
          .collection('students')
          .doc(user.uid)
          .collection('sessionLogs')
          .add(data);
    } catch (e) {
      debugPrint('Error logging session event: $e');
    }
  }

  // Update user metrics on Firestore
  Future<void> updateUserMetrics() async {
    if (!_isInitialized) return;
    
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('students').doc(user.uid).update({
        'lastActive': FieldValue.serverTimestamp(),
        'totalActiveTime': FieldValue.increment(_totalActiveTime.inSeconds),
        'totalAbsenceTime': FieldValue.increment(_totalAbsenceTime.inSeconds),
        'absenceCount': FieldValue.increment(_absenceCount),
      });
    } catch (e) {
      debugPrint('Error updating user metrics: $e');
    }
  }

  // Process continuous monitoring with face detection - safe to call from anywhere
  void processFaceDetection(bool faceDetected) {
    // Defer state changes to avoid build-time issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (faceDetected) {
        markPresent();
      } else {
        markAbsent();
      }
    });
  }

  // Clean up resources
  @override
  void dispose() {
    _isInitialized = false;
    super.dispose();
  }
}