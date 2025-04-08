import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:student_monitoring_app/components/camera_view.dart';
import 'package:student_monitoring_app/models/face_features.dart';
import 'package:student_monitoring_app/models/student.dart';
import 'package:student_monitoring_app/resources/extract_features.dart';

class RegisterScreen extends StatefulWidget {
  final Student student;

  const RegisterScreen({super.key, required this.student});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  String? _image;
  FaceFeatures? _faceFeatures;
  bool isRegistering = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Register User"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CameraView(
              onImage: (image) {
                setState(() {
                  _image = base64Encode(image);
                });
              },
              onInputImage: (inputImage) async {
                await _handleFaceExtraction(inputImage);
              },
            ),
            const SizedBox(height: 16),
            if (_image != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Registering face for: ${widget.student.name}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ElevatedButton(
              onPressed: _faceFeatures != null ? _registerStudentFace : null,
              child: const Text("Start Registering"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleFaceExtraction(InputImage inputImage) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final features = await extractFaceFeatures(inputImage, _faceDetector);
      setState(() {
        _faceFeatures = features;
      });
    } catch (e) {
      log("Face extraction failed: $e");
      showToast("Face detection failed. Try again.");
    } finally {
      if (mounted) Navigator.of(context).pop(); // close dialog
    }
  }

  Future<void> _registerStudentFace() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
          child: CircularProgressIndicator(color: Colors.redAccent)),
    );

    try {
      await FirebaseFirestore.instance
          .collection("students")
          .doc(widget.student.id)
          .update({
        "image": _image,
        "faceFeatures": _faceFeatures!.toJson(),
        "registeredOn": Timestamp.now(),
      });

      Navigator.of(context).pop(); // close progress dialog
      showToast('Face registered successfully');

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) Navigator.pop(context);
      });
    } catch (e) {
      Navigator.of(context).pop(); // close progress dialog
      log("Registration Error: $e");
      showToast('Registration Failed! Try Again.');
    }
  }

  void showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
    );
  }

  @override
  void dispose() {
    _faceDetector.close();
    super.dispose();
  }
}
