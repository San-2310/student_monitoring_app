// video_call_screen.dart
import 'dart:async';
import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class VideoCallScreen extends StatefulWidget {
  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late CameraController _cameraController;
  late IO.Socket socket;
  bool isPersonDetected = false;
  double confidence = 0.0;
  Timer? _frameTimer;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _connectSocket();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController.initialize();
    if (mounted) {
      setState(() {});
      _startFrameProcessing();
    }
  }

  void _connectSocket() {
    socket = IO.io('http://192.168.87.49:8000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) {
      print('Connected to Flask server');
    });

    socket.on('detection_result', (data) {
      setState(() {
        isPersonDetected = data['person_detected'];
        confidence = data['confidence'];
      });

      // Send detection data to Firestore
      _updateStudySession(data);
    });

    socket.onDisconnect((_) {
      print('Disconnected from Flask server');
    });
  }

  void _startFrameProcessing() {
    _frameTimer = Timer.periodic(Duration(milliseconds: 500), (timer) async {
      if (!_cameraController.value.isInitialized) return;

      try {
        final image = await _cameraController.takePicture();
        final bytes = await image.readAsBytes();
        final base64Image = base64Encode(bytes);

        // Send frame to Flask server
        socket.emit('video_frame', base64Image);
      } catch (e) {
        print('Error capturing frame: $e');
      }
    });
  }

  Future<void> _updateStudySession(Map<String, dynamic> detectionData) async {
    // TODO: Update Firestore with detection data
    // This should include:
    // - Timestamp
    // - Person detection status
    // - Confidence level
    // - Session ID
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Study Session'),
        actions: [
          IconButton(
            icon: Icon(Icons.stop),
            onPressed: _endSession,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                CameraPreview(_cameraController),
                Positioned(
                  top: 20,
                  left: 20,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isPersonDetected ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isPersonDetected ? 'In Frame' : 'Out of Frame',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            child: Text(
              'Confidence: ${(confidence * 100).toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _endSession() async {
    // TODO: Implement session end logic
    // - Stop frame processing
    // - Save session data to Firestore
    // - Navigate to questionnaire screen
  }

  @override
  void dispose() {
    _frameTimer?.cancel();
    _cameraController.dispose();
    socket.disconnect();
    super.dispose();
  }
}
