// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';
// import 'dart:typed_data';
// import 'package:face_auth_tracking/model/face_features.dart';
// import 'package:face_auth_tracking/services/face_monitoring_service.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'package:camera/camera.dart';
// import 'package:flutter_face_api/face_api.dart' as regula;

// class FaceTrackingScreen extends StatefulWidget {
//   final String userId;

//   const FaceTrackingScreen({
//     Key? key,
//     required this.userId,
//   }) : super(key: key);

//   @override
//   State<FaceTrackingScreen> createState() => _FaceTrackingScreenState();
// }

// class _FaceTrackingScreenState extends State<FaceTrackingScreen> with WidgetsBindingObserver {
//   final FaceDetector _faceDetector = FaceDetector(
//     options: FaceDetectorOptions(
//       enableLandmarks: true,
//       performanceMode: FaceDetectorMode.fast,
//       enableClassification: true,
//       minFaceSize: 0.05,
//       enableTracking: true,
//     ),
//   );

//   bool _isFacePresent = false;
//   DateTime? _lastSeen;
//   int _absenceDuration = 0;
//   DateTime _sessionStartTime = DateTime.now();
//   int _totalAbsenceCount = 0;
//   Duration _totalAbsenceTime = Duration.zero;
//   late final Stream<int> _absenceUpdateStream;
//   StreamSubscription? _absenceSubscription;
//   final _monitoringService = FaceMonitoringService();
//   CameraController? _cameraController;

//   // ///////////////////////////////////////////////////////
//   //   FaceFeatures? _faceFeatures;
//   // var image2 = regula.MatchFacesImage();
//   // bool isMatching = false;
//   // ////////////////////////////////////////////////////////

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _initializeCamera();
//     _monitoringService.startSession();
//     _absenceUpdateStream = Stream.periodic(const Duration(seconds: 1), (i) => i);
//     _startAbsenceUpdates();
//   }

//   Future<void> _initializeCamera() async {
//   final cameras = await availableCameras();
//   final frontCamera = cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front);

//   _cameraController = CameraController(
//     frontCamera,
//     ResolutionPreset.high, // Use high quality
//     enableAudio: false,
//     imageFormatGroup: ImageFormatGroup.yuv420, // Ensure correct format
//   );

//   await _cameraController!.initialize();
//   _cameraController!.startImageStream((CameraImage image) async {
//     print("📸 Processing image...");
//     await _processImage(image);
//   });

//   setState(() {}); // Refresh UI
// }

//   void _startAbsenceUpdates() {
//   _absenceSubscription = _absenceUpdateStream.listen((_) {
//     if (!_isFacePresent && _lastSeen != null) {
//       if (mounted) {
//         setState(() {
//           _absenceDuration = DateTime.now().difference(_lastSeen!).inSeconds;
//         });
//       }
//     }
//   });
// }

// Future<void> _processImage(CameraImage image) async {
//   final InputImage? inputImage = _convertCameraImageToInputImage(image);
//   if (inputImage == null) return;

//   final faces = await _faceDetector.processImage(inputImage);
//   final now = DateTime.now();
//   final bool previousFacePresent = _isFacePresent;

//   _isFacePresent = faces.isNotEmpty;
//   _monitoringService.processFaceDetection(_isFacePresent);

//   if (_isFacePresent) {
//     if (!previousFacePresent && _lastSeen != null) {
//       final absence = now.difference(_lastSeen!).inSeconds;
//       if (absence > 2) {
//         _totalAbsenceTime += Duration(seconds: absence);
//         _totalAbsenceCount++;
//       }
//     }
//     _lastSeen = now;
//   } else {
//     if (previousFacePresent) {
//       _lastSeen = now;
//     }
//     if (_lastSeen != null) {
//       _absenceDuration = now.difference(_lastSeen!).inSeconds;
//     }
//   }

//   // Only update UI if widget is still active
//   if (mounted) {
//     setState(() {});
//   }
// }

//   InputImage? _convertCameraImageToInputImage(CameraImage image) {
//   try {
//     final CameraDescription? camera = _cameraController?.description;
//     if (camera == null) return null;

//     final rotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation);
//     if (rotation == null) return null;

//     final Uint8List bytes = _convertYUV420ToNV21(image);

//     if (bytes.isEmpty) {
//       print("❌ Failed to convert image! Empty byte array.");
//       return null;
//     }

//     final metadata = InputImageMetadata(
//       size: Size(image.width.toDouble(), image.height.toDouble()),
//       rotation: rotation,
//       format: InputImageFormat.yuv420, // Ensure correct format
//       bytesPerRow: image.planes[0].bytesPerRow,
//     );

//     print("✅ Image successfully converted: ${image.width}x${image.height}");
//     return InputImage.fromBytes(bytes: bytes, metadata: metadata);
//   } catch (e) {
//     print("❌ Error converting image: $e");
//     return null;
//   }
// }

//   Uint8List _convertYUV420ToNV21(CameraImage image) {
//   final int width = image.width;
//   final int height = image.height;

//   final Uint8List yBytes = image.planes[0].bytes;
//   final Uint8List uBytes = image.planes[1].bytes;
//   final Uint8List vBytes = image.planes[2].bytes;

//   final int ySize = width * height;
//   final int uvSize = ySize ~/ 4; // U and V should be 1/4th of Y

//   // ✅ Fix: Ensure correct UV plane size
//   if (uBytes.length < uvSize || vBytes.length < uvSize) {
//     print("❌ UV plane size mismatch! U: ${uBytes.length}, V: ${vBytes.length}, Expected: $uvSize");
//     return Uint8List(0); // Return empty to avoid crashes
//   }

//   final Uint8List nv21 = Uint8List(ySize + (uvSize * 2));

//   // Copy Y plane
//   nv21.setRange(0, ySize, yBytes);

//   // ✅ Fix: Handle UV stride correctly
//   int uvIndex = ySize;
//   for (int i = 0; i < uvSize; i++) {
//     nv21[uvIndex++] = vBytes[i]; // V
//     nv21[uvIndex++] = uBytes[i]; // U
//   }

//   return nv21;
// }

// // /////////////////////////////////////////////////////////////////////////////////////////////////

// //   Future _setImage(Uint8List imageToAuthenticate) async {
// //     image2.bitmap = base64Encode(imageToAuthenticate);
// //     image2.imageType = regula.ImageType.PRINTED;
// //   }

// //   void _authenticateUser() async {
// //     if (_faceFeatures == null) return;
// //     double similarity = compareFaces(_faceFeatures!, widget.signedInUser.faceFeatures!);
// //     if (similarity < 0.8 || similarity > 1.5) {
// //       setState(() {
// //         _isFacePresent = true;
// //         absenceStartTime ??= DateTime.now();
// //       });
// //     } else {
// //       if (userAbsent) {
// //         setState(() {
// //           userAbsent = false;
// //           absenceEndTime = DateTime.now();
// //           log("User was absent for ${absenceEndTime!.difference(absenceStartTime!).inSeconds} seconds");
// //           absenceStartTime = null;
// //           absenceEndTime = null;
// //         });
// //       }
// //     }
// //   }

// //   double compareFaces(FaceFeatures face1, FaceFeatures face2) {
// //     double distEar1 = euclideanDistance(face1.rightEar!, face1.leftEar!);
// //     double distEar2 = euclideanDistance(face2.rightEar!, face2.leftEar!);
// //     double ratioEar = distEar1 / distEar2;

// //     double distEye1 = euclideanDistance(face1.rightEye!, face1.leftEye!);
// //     double distEye2 = euclideanDistance(face2.rightEye!, face2.leftEye!);
// //     double ratioEye = distEye1 / distEye2;

// //     double distCheek1 = euclideanDistance(face1.rightCheek!, face1.leftCheek!);
// //     double distCheek2 = euclideanDistance(face2.rightCheek!, face2.leftCheek!);
// //     double ratioCheek = distCheek1 / distCheek2;

// //     double distMouth1 = euclideanDistance(face1.rightMouth!, face1.leftMouth!);
// //     double distMouth2 = euclideanDistance(face2.rightMouth!, face2.leftMouth!);
// //     double ratioMouth = distMouth1 / distMouth2;

// //     double distNoseToMouth1 =
// //         euclideanDistance(face1.noseBase!, face1.bottomMouth!);
// //     double distNoseToMouth2 =
// //         euclideanDistance(face2.noseBase!, face2.bottomMouth!);
// //     double ratioNoseToMouth = distNoseToMouth1 / distNoseToMouth2;

// //     double ratio =
// //         (ratioEye + ratioEar + ratioCheek + ratioMouth + ratioNoseToMouth) / 5;
// //     log(ratio.toString(), name: "Ratio");
// //     return ratio;
// //   }

// //   double euclideanDistance(Points p1, Points p2) {
// //     return math.sqrt(math.pow((p1.x! - p2.x!), 2) + math.pow((p1.y! - p2.y!), 2));
// //   }

// //   final FaceDetector _faceDetector = FaceDetector(
// //     options: FaceDetectorOptions(
// //       enableLandmarks: true,
// //       performanceMode: FaceDetectorMode.accurate,
// //     ),
// //   );
// // ///////////////////////////////////////////////////////////////////////////////////////////

//   @override
// void dispose() {
//   WidgetsBinding.instance.removeObserver(this);
//   _absenceSubscription?.cancel(); // Cancel the stream
//   _faceDetector.close();
//   _cameraController?.dispose();
//   _monitoringService.endSession();
//   super.dispose();
// }

//  @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     appBar: AppBar(title: const Text("Face Tracking"), centerTitle: true, elevation: 0),
//     body: Column(
//       children: [
//         Expanded(
//           child: _cameraController != null && _cameraController!.value.isInitialized
//               ? Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     CameraPreview(_cameraController!),
//                     Positioned(
//                       top: 20,
//                       child: Container(
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           color: Colors.black54,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Column(
//                           children: [
//                             Text(
//                               _isFacePresent ? "😀 Face Detected" : "😞 Face Not Detected",
//                               style: const TextStyle(color: Colors.white, fontSize: 18),
//                             ),
//                             Text(
//                               "🕒 Current Absence: $_absenceDuration sec",
//                               style: const TextStyle(color: Colors.white, fontSize: 16),
//                             ),
//                             Text(
//                               "⏳ Total Absence Time: ${_totalAbsenceTime.inSeconds} sec",
//                               style: const TextStyle(color: Colors.white, fontSize: 16),
//                             ),
//                             Text(
//                               "📉 Total Absences: $_totalAbsenceCount",
//                               style: const TextStyle(color: Colors.white, fontSize: 16),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 )
//               : const Center(child: CircularProgressIndicator()),
//         ),
//       ],
//     ),
//   );
// }
// }

// // import 'dart:convert';
// // import 'dart:developer';
// // import 'dart:typed_data';
// // import 'dart:math' as math;
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:face_auth_tracking/model/face_features.dart';
// // import 'package:face_auth_tracking/model/user_model.dart';
// // import 'package:face_auth_tracking/screens/authenticated_user_screen.dart';
// // import 'package:face_auth_tracking/services/extract_features.dart';
// // import 'package:face_auth_tracking/widgets/camera_view.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_face_api/face_api.dart' as regula;
// // import 'package:fluttertoast/fluttertoast.dart';
// // import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

// // class FaceTrackingScreen extends StatefulWidget {
// //   final UserModel signedInUser;
// //   const FaceTrackingScreen({super.key, required this.signedInUser});

// //   @override
// //   State<FaceTrackingScreen> createState() => _FaceTrackingScreenState();
// // }

// // class _FaceTrackingScreenState extends State<FaceTrackingScreen> {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         centerTitle: true,
// //         title: const Text("Face Tracking"),
// //         elevation: 0,
// //       ),
// //       body: SingleChildScrollView(
// //         child: Column(
// //           children: [
// //             CameraView(
// //               onImage: (image) {
// //                 _setImage(image);
// //               },
// //               onInputImage: (inputImage) async {
// //                 setState(() => isMatching = true);
// //                 _faceFeatures = await extractFaceFeatures(
// //                     inputImage, _faceDetector);
// //                 setState(() => isMatching = false);
// //                 _authenticateUser();
// //               },
// //             ),
// //             const SizedBox(height: 38),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Future _setImage(Uint8List imageToAuthenticate) async {
// //     image2.bitmap = base64Encode(imageToAuthenticate);
// //     image2.imageType = regula.ImageType.PRINTED;
// //   }

// //   void _authenticateUser() async {
// //     if (_faceFeatures == null) return;
// //     double similarity = compareFaces(_faceFeatures!, widget.signedInUser.faceFeatures!);
// //     if (similarity < 0.8 || similarity > 1.5) {
// //       setState(() {
// //         userAbsent = true;
// //         absenceStartTime ??= DateTime.now();
// //       });
// //     } else {
// //       if (userAbsent) {
// //         setState(() {
// //           userAbsent = false;
// //           absenceEndTime = DateTime.now();
// //           log("User was absent for ${absenceEndTime!.difference(absenceStartTime!).inSeconds} seconds");
// //           absenceStartTime = null;
// //           absenceEndTime = null;
// //         });
// //       }
// //     }
// //   }

// //   double compareFaces(FaceFeatures face1, FaceFeatures face2) {
// //     double distEar1 = euclideanDistance(face1.rightEar!, face1.leftEar!);
// //     double distEar2 = euclideanDistance(face2.rightEar!, face2.leftEar!);
// //     double ratioEar = distEar1 / distEar2;

// //     double distEye1 = euclideanDistance(face1.rightEye!, face1.leftEye!);
// //     double distEye2 = euclideanDistance(face2.rightEye!, face2.leftEye!);
// //     double ratioEye = distEye1 / distEye2;

// //     double distCheek1 = euclideanDistance(face1.rightCheek!, face1.leftCheek!);
// //     double distCheek2 = euclideanDistance(face2.rightCheek!, face2.leftCheek!);
// //     double ratioCheek = distCheek1 / distCheek2;

// //     double distMouth1 = euclideanDistance(face1.rightMouth!, face1.leftMouth!);
// //     double distMouth2 = euclideanDistance(face2.rightMouth!, face2.leftMouth!);
// //     double ratioMouth = distMouth1 / distMouth2;

// //     double distNoseToMouth1 =
// //         euclideanDistance(face1.noseBase!, face1.bottomMouth!);
// //     double distNoseToMouth2 =
// //         euclideanDistance(face2.noseBase!, face2.bottomMouth!);
// //     double ratioNoseToMouth = distNoseToMouth1 / distNoseToMouth2;

// //     double ratio =
// //         (ratioEye + ratioEar + ratioCheek + ratioMouth + ratioNoseToMouth) / 5;
// //     log(ratio.toString(), name: "Ratio");
// //     return ratio;
// //   }

// //   double euclideanDistance(Points p1, Points p2) {
// //     return math.sqrt(math.pow((p1.x! - p2.x!), 2) + math.pow((p1.y! - p2.y!), 2));
// //   }

// //   final FaceDetector _faceDetector = FaceDetector(
// //     options: FaceDetectorOptions(
// //       enableLandmarks: true,
// //       performanceMode: FaceDetectorMode.accurate,
// //     ),
// //   );
// //   FaceFeatures? _faceFeatures;
// //   var image2 = regula.MatchFacesImage();

// //   bool userAbsent = false;
// //   DateTime? absenceStartTime;
// //   DateTime? absenceEndTime;
// //   bool isMatching = false;

// //   @override
// //   void dispose() {
// //     _faceDetector.close();
// //     super.dispose();
// //   }
// // }

// // import 'dart:async';
// // import 'dart:convert';
// // import 'dart:developer';
// // import 'dart:typed_data';
// // import 'dart:math' as math;
// // import 'package:camera/camera.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:face_auth_tracking/model/face_features.dart';
// // import 'package:face_auth_tracking/model/user_model.dart';
// // import 'package:face_auth_tracking/services/extract_features.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_face_api/face_api.dart' as regula;
// // import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

// // class FaceTrackingScreen extends StatefulWidget {
// //   final UserModel signedInUser;
// //   const FaceTrackingScreen({super.key, required this.signedInUser});

// //   @override
// //   State<FaceTrackingScreen> createState() => _FaceTrackingScreenState();
// // }

// // class _FaceTrackingScreenState extends State<FaceTrackingScreen> {
// //   final FaceDetector _faceDetector = FaceDetector(
// //     options: FaceDetectorOptions(
// //       enableLandmarks: true,
// //       performanceMode: FaceDetectorMode.accurate,
// //       enableClassification: true,
// //       enableTracking: true,
// //     ),
// //   );

// //   CameraController? _cameraController;
// //   FaceFeatures? _faceFeatures;
// //   bool userAbsent = false;
// //   DateTime? absenceStartTime;
// //   DateTime? absenceEndTime;
// //   Duration totalAbsenceDuration = Duration.zero;
// //   int totalAbsenceCount = 0;
// //   var image2 = regula.MatchFacesImage();

// //   @override
// //   void initState() {
// //     super.initState();
// //     _initializeCamera();
// //   }

// //   Future<void> _initializeCamera() async {
// //     final cameras = await availableCameras();
// //     final frontCamera = cameras.firstWhere(
// //         (camera) => camera.lensDirection == CameraLensDirection.front);

// //     _cameraController = CameraController(
// //       frontCamera,
// //       ResolutionPreset.high,
// //       enableAudio: false,
// //       imageFormatGroup: ImageFormatGroup.yuv420,
// //     );
// //     await _cameraController!.initialize();

// //     _cameraController!.startImageStream((CameraImage image) async {
// //       await _processImage(image);
// //     });
// //     setState(() {});
// //   }

// //   Future<void> _processImage(CameraImage image) async {
// //     final InputImage? inputImage = _convertCameraImageToInputImage(image);
// //     if (inputImage == null) return;

// //     final faces = await _faceDetector.processImage(inputImage);
// //     if (faces.isNotEmpty) {
// //       _faceFeatures = await extractFaceFeatures(inputImage, _faceDetector);
// //       _authenticateUser();
// //     } else {
// //       if (!userAbsent) {
// //         setState(() {
// //           userAbsent = true;
// //           absenceStartTime ??= DateTime.now();
// //         });
// //       }
// //     }
// //   }

// //   void _authenticateUser() async {
// //     if (_faceFeatures == null) return;
// //     double similarity = compareFaces(_faceFeatures!, widget.signedInUser.faceFeatures!);
// //     if (similarity < 0.8 || similarity > 1.5) {
// //       if (!userAbsent) {
// //         setState(() {
// //           userAbsent = true;
// //           absenceStartTime ??= DateTime.now();
// //         });
// //       }
// //     } else {
// //       if (userAbsent) {
// //         setState(() {
// //           userAbsent = false;
// //           absenceEndTime = DateTime.now();
// //           totalAbsenceDuration += absenceEndTime!.difference(absenceStartTime!);
// //           totalAbsenceCount++;
// //           absenceStartTime = null;
// //           absenceEndTime = null;
// //         });
// //       }
// //     }
// //   }

// //   double compareFaces(FaceFeatures face1, FaceFeatures face2) {
// //     double ratio = (
// //       euclideanDistance(face1.rightEye!, face1.leftEye!) /
// //       euclideanDistance(face2.rightEye!, face2.leftEye!) +
// //       euclideanDistance(face1.rightEar!, face1.leftEar!) /
// //       euclideanDistance(face2.rightEar!, face2.leftEar!) +
// //       euclideanDistance(face1.rightCheek!, face1.leftCheek!) /
// //       euclideanDistance(face2.rightCheek!, face2.leftCheek!) +
// //       euclideanDistance(face1.rightMouth!, face1.leftMouth!) /
// //       euclideanDistance(face2.rightMouth!, face2.leftMouth!) +
// //       euclideanDistance(face1.noseBase!, face1.bottomMouth!) /
// //       euclideanDistance(face2.noseBase!, face2.bottomMouth!)
// //     ) / 5;
// //     return ratio;
// //   }

// //   double euclideanDistance(Points p1, Points p2) {
// //     return math.sqrt(math.pow((p1.x! - p2.x!), 2) + math.pow((p1.y! - p2.y!), 2));
// //   }

// //   InputImage? _convertCameraImageToInputImage(CameraImage image) {
// //     try {
// //       final CameraDescription? camera = _cameraController?.description;
// //       if (camera == null) return null;
// //       final rotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation);
// //       if (rotation == null) return null;

// //       final Uint8List bytes = image.planes[0].bytes;
// //       return InputImage.fromBytes(
// //         bytes: bytes,
// //         metadata: InputImageMetadata(
// //           size: Size(image.width.toDouble(), image.height.toDouble()),
// //           rotation: rotation,
// //           format: InputImageFormat.yuv420,
// //           bytesPerRow: image.planes[0].bytesPerRow,
// //         ),
// //       );
// //     } catch (e) {
// //       print("Error converting image: $e");
// //       return null;
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _faceDetector.close();
// //     _cameraController?.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text("Face Tracking"), centerTitle: true),
// //       body: Column(
// //         children: [
// //           Expanded(
// //             child: _cameraController != null && _cameraController!.value.isInitialized
// //                 ? Stack(
// //                     alignment: Alignment.center,
// //                     children: [
// //                       CameraPreview(_cameraController!),
// //                       Positioned(
// //                         top: 20,
// //                         child: Container(
// //                           padding: const EdgeInsets.all(10),
// //                           decoration: BoxDecoration(
// //                             color: Colors.black54,
// //                             borderRadius: BorderRadius.circular(10),
// //                           ),
// //                           child: Column(
// //                             children: [
// //                               Text(userAbsent ? "😞 User Absent" : "😀 User Present",
// //                                   style: const TextStyle(color: Colors.white, fontSize: 18)),
// //                               Text("Total Absences: $totalAbsenceCount",
// //                                   style: const TextStyle(color: Colors.white, fontSize: 16)),
// //                               Text("Total Absence Time: ${totalAbsenceDuration.inSeconds} sec",
// //                                   style: const TextStyle(color: Colors.white, fontSize: 16)),
// //                             ],
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   )
// //                 : const Center(child: CircularProgressIndicator()),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_face_api/face_api.dart' as regula;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:student_monitoring_app/models/face_features.dart';
import 'package:student_monitoring_app/models/student.dart';
import 'package:student_monitoring_app/resources/face_monitoring_service.dart';

class FaceTrackingScreen extends StatefulWidget {
  final Student user;
  const FaceTrackingScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<FaceTrackingScreen> createState() => _FaceTrackingScreenState();
}

class _FaceTrackingScreenState extends State<FaceTrackingScreen>
    with WidgetsBindingObserver {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.fast,
      enableClassification: true,
      minFaceSize: 0.05,
      enableTracking: true,
    ),
  );

  bool _isFacePresent = false;
  bool _isAuthenticatedUser = false;
  DateTime? _lastSeen;
  int _absenceDuration = 0;
  DateTime _sessionStartTime = DateTime.now();
  int _totalAbsenceCount = 0;
  Duration _totalAbsenceTime = Duration.zero;
  late final Stream<int> _absenceUpdateStream;
  StreamSubscription? _absenceSubscription;
  final _monitoringService = FaceMonitoringService();
  CameraController? _cameraController;
  FaceFeatures? _loggedInUserFeatures;
  FaceFeatures? _currentFaceFeatures;
  bool _isLoading = true;
  double _currentRatio = 0.0;
  double _currentSimilarity = 0.0;
  bool _showDebugInfo = true;

  // Regula SDK objects for face matching
  final regula.MatchFacesImage _image1 = regula.MatchFacesImage();
  final regula.MatchFacesImage _image2 = regula.MatchFacesImage();

  // Recent face image
  Uint8List? _recentFaceImage;

  // Timer for regulaSDK processing to avoid continuous API calls
  Timer? _regulaProcessingTimer;
  bool _isProcessingRegula = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchUserFaceFeatures();
    _initializeCamera();
    _monitoringService.startSession();
    _absenceUpdateStream =
        Stream.periodic(const Duration(seconds: 1), (i) => i);
    _startAbsenceUpdates();

    // Initialize Regula image1 with the user's stored image
    _image1.bitmap = widget.user.image;
    _image1.imageType = regula.ImageType.PRINTED;
  }

  Future<void> _fetchUserFaceFeatures() async {
    try {
      // Fetch logged-in user's face features from Firebase
      _loggedInUserFeatures = widget.user.faceFeatures;
      log("Loaded user face features: ${_loggedInUserFeatures != null ? 'Success' : 'Failed'}",
          name: "FaceAuth");

      // Debug log to check the loaded features
      if (_loggedInUserFeatures != null) {
        log("User features - right eye: ${_loggedInUserFeatures!.rightEye?.x},${_loggedInUserFeatures!.rightEye?.y}",
            name: "FaceFeatures");
        log("User features - left eye: ${_loggedInUserFeatures!.leftEye?.x},${_loggedInUserFeatures!.leftEye?.y}",
            name: "FaceFeatures");
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      log("Error fetching user face features: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _cameraController!.initialize();
    _cameraController!.startImageStream((CameraImage image) async {
      await _processImage(image);
    });

    if (mounted) {
      setState(() {});
    }
  }

  void _startAbsenceUpdates() {
    _absenceSubscription = _absenceUpdateStream.listen((_) {
      if (!_isAuthenticatedUser && _lastSeen != null) {
        if (mounted) {
          setState(() {
            _absenceDuration = DateTime.now().difference(_lastSeen!).inSeconds;
          });
        }
      }
    });
  }

  Future<void> _processImage(CameraImage image) async {
    final InputImage? inputImage = _convertCameraImageToInputImage(image);
    if (inputImage == null) return;

    final faces = await _faceDetector.processImage(inputImage);
    final now = DateTime.now();
    final bool previousFacePresent = _isFacePresent;
    final bool previousAuthenticatedUser = _isAuthenticatedUser;

    _isFacePresent = faces.isNotEmpty;
    _monitoringService.processFaceDetection(_isFacePresent);

    if (_isFacePresent && faces.isNotEmpty) {
      // Extract face landmarks for authentication
      _extractFaceFeatures(faces.first);

      // Capture face image for Regula SDK processing every few seconds
      if (_recentFaceImage == null ||
          (_regulaProcessingTimer == null && !_isProcessingRegula)) {
        _captureFaceImage();
      }

      // Step 1: First do the ratio-based authentication
      _authenticateUserByRatio();

      if (!previousAuthenticatedUser && _isAuthenticatedUser) {
        // User was absent but is now present
        if (_lastSeen != null) {
          final absence = now.difference(_lastSeen!).inSeconds;
          if (absence > 2) {
            _totalAbsenceTime += Duration(seconds: absence);
            _totalAbsenceCount++;
          }
        }
      }

      if (_isAuthenticatedUser) {
        _lastSeen = now;
      }
    } else {
      if (previousAuthenticatedUser) {
        _lastSeen = now;
      }

      _isAuthenticatedUser = false;
      _currentRatio = 0.0;
      _currentSimilarity = 0.0;

      if (_lastSeen != null) {
        _absenceDuration = now.difference(_lastSeen!).inSeconds;
      }
    }

    // Only update UI if widget is still active
    if (mounted) {
      setState(() {});
    }
  }

  void _captureFaceImage() async {
    try {
      if (_cameraController != null && _cameraController!.value.isInitialized) {
        _recentFaceImage = await _takePhoto();

        // Process with Regula SDK if we have an image
        if (_recentFaceImage != null && !_isProcessingRegula) {
          _isProcessingRegula = true;

          // Avoid continuous processing by setting a timer
          _regulaProcessingTimer?.cancel();
          _regulaProcessingTimer = Timer(const Duration(seconds: 3), () {
            _authenticateUserByRegula(_recentFaceImage!);
            _regulaProcessingTimer = null;
          });
        }
      }
    } catch (e) {
      log("Error capturing face image: $e", name: "FaceCapture");
    }
  }

  Future<Uint8List?> _takePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return null;
    }

    try {
      XFile file = await _cameraController!.takePicture();
      return await file.readAsBytes();
    } catch (e) {
      log("Error taking photo: $e", name: "Camera");
      return null;
    }
  }

  void _extractFaceFeatures(Face face) {
    // Log detected landmarks for debugging
    log("Face landmarks detected: ${face.landmarks.length}",
        name: "FaceDetection");

    if (face.landmarks.isEmpty) {
      log("No landmarks detected in face", name: "FaceDetection");
      return;
    }

    // Create a new FaceFeatures object for current detected face
    _currentFaceFeatures = FaceFeatures(
      rightEye: face.landmarks[FaceLandmarkType.rightEye] != null
          ? Points(
              x: face.landmarks[FaceLandmarkType.rightEye]!.position.x,
              y: face.landmarks[FaceLandmarkType.rightEye]!.position.y,
            )
          : null,
      leftEye: face.landmarks[FaceLandmarkType.leftEye] != null
          ? Points(
              x: face.landmarks[FaceLandmarkType.leftEye]!.position.x,
              y: face.landmarks[FaceLandmarkType.leftEye]!.position.y,
            )
          : null,
      rightEar: face.landmarks[FaceLandmarkType.rightEar] != null
          ? Points(
              x: face.landmarks[FaceLandmarkType.rightEar]!.position.x,
              y: face.landmarks[FaceLandmarkType.rightEar]!.position.y,
            )
          : null,
      leftEar: face.landmarks[FaceLandmarkType.leftEar] != null
          ? Points(
              x: face.landmarks[FaceLandmarkType.leftEar]!.position.x,
              y: face.landmarks[FaceLandmarkType.leftEar]!.position.y,
            )
          : null,
      rightCheek: face.landmarks[FaceLandmarkType.rightCheek] != null
          ? Points(
              x: face.landmarks[FaceLandmarkType.rightCheek]!.position.x,
              y: face.landmarks[FaceLandmarkType.rightCheek]!.position.y,
            )
          : null,
      leftCheek: face.landmarks[FaceLandmarkType.leftCheek] != null
          ? Points(
              x: face.landmarks[FaceLandmarkType.leftCheek]!.position.x,
              y: face.landmarks[FaceLandmarkType.leftCheek]!.position.y,
            )
          : null,
      rightMouth: face.landmarks[FaceLandmarkType.rightMouth] != null
          ? Points(
              x: face.landmarks[FaceLandmarkType.rightMouth]!.position.x,
              y: face.landmarks[FaceLandmarkType.rightMouth]!.position.y,
            )
          : null,
      leftMouth: face.landmarks[FaceLandmarkType.leftMouth] != null
          ? Points(
              x: face.landmarks[FaceLandmarkType.leftMouth]!.position.x,
              y: face.landmarks[FaceLandmarkType.leftMouth]!.position.y,
            )
          : null,
      noseBase: face.landmarks[FaceLandmarkType.noseBase] != null
          ? Points(
              x: face.landmarks[FaceLandmarkType.noseBase]!.position.x,
              y: face.landmarks[FaceLandmarkType.noseBase]!.position.y,
            )
          : null,
      bottomMouth: face.landmarks[FaceLandmarkType.bottomMouth] != null
          ? Points(
              x: face.landmarks[FaceLandmarkType.bottomMouth]!.position.x,
              y: face.landmarks[FaceLandmarkType.bottomMouth]!.position.y,
            )
          : null,
    );

    // Debug log to check the detected features
    if (_currentFaceFeatures?.rightEye != null &&
        _currentFaceFeatures?.leftEye != null) {
      log("Current face - eye distance: ${euclideanDistance(_currentFaceFeatures!.rightEye!, _currentFaceFeatures!.leftEye!)}",
          name: "FaceFeatures");
    }
  }

  void _authenticateUserByRatio() {
    if (_currentFaceFeatures == null || _loggedInUserFeatures == null) {
      log("Missing face features for comparison", name: "Authentication");
      return;
    }

    // Log some landmark positions to verify data
    if (_currentFaceFeatures?.rightEye != null &&
        _loggedInUserFeatures?.rightEye != null) {
      log("Current face - right eye: ${_currentFaceFeatures!.rightEye!.x},${_currentFaceFeatures!.rightEye!.y}",
          name: "FaceFeatures");
      log("Logged user - right eye: ${_loggedInUserFeatures!.rightEye!.x},${_loggedInUserFeatures!.rightEye!.y}",
          name: "FaceFeatures");
    }

    double ratio = compareFaces(_currentFaceFeatures!, _loggedInUserFeatures!);
    _currentRatio = ratio;

    // Define thresholds for first-level filtering (similar to AuthenticateScreen)
    const double lowerThreshold = 0.8;
    const double upperThreshold = 1.5;

    bool passedFirstFilter =
        ratio >= lowerThreshold && ratio <= upperThreshold && ratio > 0;

    // Log authentication result
    log("Face ratio: $ratio (passed first filter: $passedFirstFilter)",
        name: "Authentication");

    // For immediate feedback while Regula processes, we can temporarily authenticate
    // based on the ratio if the second-level authentication hasn't happened yet
    if (_currentSimilarity < 90.0) {
      // Only use ratio if we don't have a strong Regula match
      setState(() {
        _isAuthenticatedUser = passedFirstFilter;
      });
    }
  }

  void _authenticateUserByRegula(Uint8List faceImageBytes) async {
    try {
      // Set up image2 with the current face image
      _image2.bitmap = base64Encode(faceImageBytes);
      _image2.imageType = regula.ImageType.PRINTED;

      // Create match request
      var request = regula.MatchFacesRequest();
      request.images = [_image1, _image2];

      // Send match request to Regula SDK
      dynamic value = await regula.FaceSDK.matchFaces(jsonEncode(request));

      // Process results
      var response = regula.MatchFacesResponse.fromJson(json.decode(value));
      dynamic str = await regula.FaceSDK.matchFacesSimilarityThresholdSplit(
          jsonEncode(response!.results), 0.75);

      var split =
          regula.MatchFacesSimilarityThresholdSplit.fromJson(json.decode(str));

      double similarity = 0.0;
      if (split != null && split.matchedFaces.isNotEmpty) {
        similarity = split.matchedFaces[0]!.similarity! * 100;
        _currentSimilarity = similarity;

        log("Regula similarity: ${similarity.toStringAsFixed(2)}",
            name: "RegulaMatcher");

        // Final authentication decision based on Regula's similarity score
        final bool authenticated = similarity > 90.0;

        setState(() {
          _isAuthenticatedUser = authenticated;
        });
      } else {
        log("No face match from Regula SDK", name: "RegulaMatcher");
      }
    } catch (e) {
      log("Error in Regula face matching: $e", name: "RegulaMatcher");
    } finally {
      _isProcessingRegula = false;
    }
  }

  double compareFaces(FaceFeatures face1, FaceFeatures face2) {
    // Use a list to store valid ratios (avoiding null values)
    List<double> ratios = [];

    // Calculate ear ratio if data is available
    if (face1.rightEar != null &&
        face1.leftEar != null &&
        face2.rightEar != null &&
        face2.leftEar != null) {
      double distEar1 = euclideanDistance(face1.rightEar!, face1.leftEar!);
      double distEar2 = euclideanDistance(face2.rightEar!, face2.leftEar!);
      if (distEar2 > 0) {
        double ratio = distEar1 / distEar2;
        log("Ear ratio: $ratio", name: "FaceComparison");
        ratios.add(ratio);
      }
    }

    // Calculate eye ratio if data is available
    if (face1.rightEye != null &&
        face1.leftEye != null &&
        face2.rightEye != null &&
        face2.leftEye != null) {
      double distEye1 = euclideanDistance(face1.rightEye!, face1.leftEye!);
      double distEye2 = euclideanDistance(face2.rightEye!, face2.leftEye!);
      if (distEye2 > 0) {
        double ratio = distEye1 / distEye2;
        log("Eye ratio: $ratio", name: "FaceComparison");
        ratios.add(ratio);
      }
    }

    // Calculate cheek ratio if data is available
    if (face1.rightCheek != null &&
        face1.leftCheek != null &&
        face2.rightCheek != null &&
        face2.leftCheek != null) {
      double distCheek1 =
          euclideanDistance(face1.rightCheek!, face1.leftCheek!);
      double distCheek2 =
          euclideanDistance(face2.rightCheek!, face2.leftCheek!);
      if (distCheek2 > 0) {
        double ratio = distCheek1 / distCheek2;
        log("Cheek ratio: $ratio", name: "FaceComparison");
        ratios.add(ratio);
      }
    }

    // Calculate mouth ratio if data is available
    if (face1.rightMouth != null &&
        face1.leftMouth != null &&
        face2.rightMouth != null &&
        face2.leftMouth != null) {
      double distMouth1 =
          euclideanDistance(face1.rightMouth!, face1.leftMouth!);
      double distMouth2 =
          euclideanDistance(face2.rightMouth!, face2.leftMouth!);
      if (distMouth2 > 0) {
        double ratio = distMouth1 / distMouth2;
        log("Mouth ratio: $ratio", name: "FaceComparison");
        ratios.add(ratio);
      }
    }

    // Calculate nose-to-mouth ratio if data is available
    if (face1.noseBase != null &&
        face1.bottomMouth != null &&
        face2.noseBase != null &&
        face2.bottomMouth != null) {
      double distNoseToMouth1 =
          euclideanDistance(face1.noseBase!, face1.bottomMouth!);
      double distNoseToMouth2 =
          euclideanDistance(face2.noseBase!, face2.bottomMouth!);
      if (distNoseToMouth2 > 0) {
        double ratio = distNoseToMouth1 / distNoseToMouth2;
        log("Nose-to-mouth ratio: $ratio", name: "FaceComparison");
        ratios.add(ratio);
      }
    }

    // Return average ratio, or 0 if no valid ratios
    if (ratios.isEmpty) {
      log("No valid face feature ratios found for comparison",
          name: "FaceComparison");
      return 0;
    }

    // Calculate the average of all valid ratios
    double avgRatio = ratios.reduce((a, b) => a + b) / ratios.length;
    log("Average ratio: $avgRatio (from ${ratios.length} features)",
        name: "FaceComparison");
    return avgRatio;
  }

  double euclideanDistance(Points p1, Points p2) {
    return math
        .sqrt(math.pow((p1.x! - p2.x!), 2) + math.pow((p1.y! - p2.y!), 2));
  }

  InputImage? _convertCameraImageToInputImage(CameraImage image) {
    try {
      final CameraDescription? camera = _cameraController?.description;
      if (camera == null) return null;

      final rotation =
          InputImageRotationValue.fromRawValue(camera.sensorOrientation);
      if (rotation == null) return null;

      final Uint8List bytes = _convertYUV420ToNV21(image);
      if (bytes.isEmpty) {
        print("❌ Failed to convert image! Empty byte array.");
        return null;
      }

      final metadata = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.yuv420,
        bytesPerRow: image.planes[0].bytesPerRow,
      );

      return InputImage.fromBytes(bytes: bytes, metadata: metadata);
    } catch (e) {
      print("❌ Error converting image: $e");
      return null;
    }
  }

  Uint8List _convertYUV420ToNV21(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final Uint8List yBytes = image.planes[0].bytes;
    final Uint8List uBytes = image.planes[1].bytes;
    final Uint8List vBytes = image.planes[2].bytes;
    final int ySize = width * height;
    final int uvSize = ySize ~/ 4; // U and V should be 1/4th of Y

    // Ensure correct UV plane size
    if (uBytes.length < uvSize || vBytes.length < uvSize) {
      print(
          "❌ UV plane size mismatch! U: ${uBytes.length}, V: ${vBytes.length}, Expected: $uvSize");
      return Uint8List(0); // Return empty to avoid crashes
    }

    final Uint8List nv21 = Uint8List(ySize + (uvSize * 2));

    // Copy Y plane
    nv21.setRange(0, ySize, yBytes);

    // Handle UV stride correctly
    int uvIndex = ySize;
    for (int i = 0; i < uvSize; i++) {
      nv21[uvIndex++] = vBytes[i]; // V
      nv21[uvIndex++] = uBytes[i]; // U
    }

    return nv21;
  }

  void _toggleDebugInfo() {
    setState(() {
      _showDebugInfo = !_showDebugInfo;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _absenceSubscription?.cancel();
    _faceDetector.close();
    _cameraController?.dispose();
    _monitoringService.endSession();
    _regulaProcessingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Face Tracking"),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Debug toggle button
          IconButton(
            icon:
                Icon(_showDebugInfo ? Icons.visibility_off : Icons.visibility),
            onPressed: _toggleDebugInfo,
            tooltip: _showDebugInfo ? "Hide Debug Info" : "Show Debug Info",
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _cameraController != null &&
                        _cameraController!.value.isInitialized
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          CameraPreview(_cameraController!),
                          Positioned(
                            top: 20,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    _isFacePresent
                                        ? "😀 Face Detected"
                                        : "😞 Face Not Detected",
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                  Text(
                                    _isAuthenticatedUser
                                        ? "✅ Authenticated User"
                                        : "❌ Unverified User",
                                    style: TextStyle(
                                      color: _isAuthenticatedUser
                                          ? Colors.green
                                          : Colors.red,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (_showDebugInfo && _isFacePresent)
                                    Column(
                                      children: [
                                        Text(
                                          "Ratio: ${_currentRatio.toStringAsFixed(2)}",
                                          style: TextStyle(
                                            color: _currentRatio >= 0.8 &&
                                                    _currentRatio <= 1.5
                                                ? Colors.green
                                                : Colors.orange,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          "SDK Similarity: ${_currentSimilarity.toStringAsFixed(2)}%",
                                          style: TextStyle(
                                            color: _currentSimilarity > 90.0
                                                ? Colors.green
                                                : Colors.orange,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  Text(
                                    "🕒 Current Absence: $_absenceDuration sec",
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                  Text(
                                    "⏳ Total Absence Time: ${_totalAbsenceTime.inSeconds} sec",
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                  Text(
                                    "📉 Total Absences: $_totalAbsenceCount",
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Visual indicator for authentication status
                          Positioned(
                            right: 20,
                            top: 20,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isAuthenticatedUser
                                    ? Colors.green.withOpacity(0.7)
                                    : _isFacePresent
                                        ? Colors.orange.withOpacity(0.7)
                                        : Colors.red.withOpacity(0.7),
                              ),
                              child: Icon(
                                _isAuthenticatedUser
                                    ? Icons.check
                                    : _isFacePresent
                                        ? Icons.face
                                        : Icons.face_3,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                          // Processing indicator for Regula SDK
                          if (_isProcessingRegula)
                            Positioned(
                              bottom: 20,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Verifying...",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      )
                    : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}
