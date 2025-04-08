// // // // import 'dart:async';
// // // // import 'dart:typed_data';
// // // // import 'package:camera/camera.dart';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

// // // // class ContinuousCameraView extends StatefulWidget {
// // // //   final Function(Uint8List imageBytes, InputImage inputImage) onProcessFrame;
// // // //   final Duration processingInterval;
  
// // // //   const ContinuousCameraView({
// // // //     Key? key,
// // // //     required this.onProcessFrame,
// // // //     this.processingInterval = const Duration(seconds: 3),
// // // //   }) : super(key: key);

// // // //   @override
// // // //   State<ContinuousCameraView> createState() => _ContinuousCameraViewState();
// // // // }

// // // // class _ContinuousCameraViewState extends State<ContinuousCameraView> with WidgetsBindingObserver {
// // // //   CameraController? _cameraController;
// // // //   List<CameraDescription>? _cameras;
// // // //   bool _isInitialized = false;
// // // //   bool _isProcessing = false;
// // // //   Timer? _processingTimer;
  
// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     WidgetsBinding.instance.addObserver(this);
// // // //     _initializeCamera();
// // // //   }
  
// // // //   @override
// // // //   void didChangeAppLifecycleState(AppLifecycleState state) {
// // // //     final CameraController? cameraController = _cameraController;
    
// // // //     // App state changed before camera was initialized
// // // //     if (cameraController == null || !cameraController.value.isInitialized) {
// // // //       return;
// // // //     }
    
// // // //     if (state == AppLifecycleState.inactive) {
// // // //       cameraController.dispose();
// // // //     } else if (state == AppLifecycleState.resumed) {
// // // //       _initializeCamera();
// // // //     }
// // // //   }
  
// // // //   Future<void> _initializeCamera() async {
// // // //     try {
// // // //       // Get available cameras
// // // //       _cameras = await availableCameras();
      
// // // //       if (_cameras!.isEmpty) {
// // // //         return;
// // // //       }
      
// // // //       // Find front camera
// // // //       CameraDescription? frontCamera;
// // // //       for (var camera in _cameras!) {
// // // //         if (camera.lensDirection == CameraLensDirection.front) {
// // // //           frontCamera = camera;
// // // //           break;
// // // //         }
// // // //       }
      
// // // //       // If no front camera found, use the first available
// // // //       final selectedCamera = frontCamera ?? _cameras!.first;
      
// // // //       // Initialize controller
// // // //       _cameraController = CameraController(
// // // //         selectedCamera,
// // // //         ResolutionPreset.medium,
// // // //         enableAudio: false,
// // // //         imageFormatGroup: ImageFormatGroup.jpeg,
// // // //       );
      
// // // //       await _cameraController!.initialize();
      
// // // //       // Setup periodic processing
// // // //       _startPeriodicProcessing();
      
// // // //       if (mounted) {
// // // //         setState(() {
// // // //           _isInitialized = true;
// // // //         });
// // // //       }
// // // //     } catch (e) {
// // // //       debugPrint("Error initializing camera: $e");
// // // //     }
// // // //   }
  
// // // //   void _startPeriodicProcessing() {
// // // //     _processingTimer = Timer.periodic(widget.processingInterval, (_) {
// // // //       _processCurrentFrame();
// // // //     });
// // // //   }
  
// // // //   Future<void> _processCurrentFrame() async {
// // // //     // Skip if camera not initialized or already processing
// // // //     if (_cameraController == null || 
// // // //         !_cameraController!.value.isInitialized ||
// // // //         _isProcessing) {
// // // //       return;
// // // //     }
    
// // // //     setState(() {
// // // //       _isProcessing = true;
// // // //     });
    
// // // //     try {
// // // //       // Capture image
// // // //       final XFile imageFile = await _cameraController!.takePicture();
      
// // // //       // Convert to bytes
// // // //       final Uint8List imageBytes = await imageFile.readAsBytes();
      
// // // //       // Create inputImage for ML Kit
// // // //       final InputImage inputImage = InputImage.fromFilePath(imageFile.path);
      
// // // //       // Process frame through callback
// // // //       widget.onProcessFrame(imageBytes, inputImage);
// // // //     } catch (e) {
// // // //       debugPrint("Error processing frame: $e");
// // // //     } finally {
// // // //       if (mounted) {
// // // //         setState(() {
// // // //           _isProcessing = false;
// // // //         });
// // // //       }
// // // //     }
// // // //   }
  
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     if (!_isInitialized || _cameraController == null) {
// // // //       return const Expanded(
// // // //         child: Center(
// // // //           child: CircularProgressIndicator(),
// // // //         ),
// // // //       );
// // // //     }
    
// // // //     return Expanded(
// // // //       child: Column(
// // // //         children: [
// // // //           // Camera preview
// // // //           Expanded(
// // // //             child: Container(
// // // //               width: double.infinity,
// // // //               decoration: BoxDecoration(
// // // //                 border: Border.all(color: Colors.blueGrey.shade200),
// // // //               ),
// // // //               child: ClipRRect(
// // // //                 borderRadius: BorderRadius.circular(8),
// // // //                 child: CameraPreview(_cameraController!),
// // // //               ),
// // // //             ),
// // // //           ),
          
// // // //           // Manual check button
// // // //           Padding(
// // // //             padding: const EdgeInsets.all(16),
// // // //             child: ElevatedButton.icon(
// // // //               onPressed: _isProcessing ? null : _processCurrentFrame,
// // // //               icon: const Icon(Icons.camera),
// // // //               label: const Text("Check Now"),
// // // //               style: ElevatedButton.styleFrom(
// // // //                 padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
// // // //               ),
// // // //             ),
// // // //           ),
          
// // // //           // Processing indicator
// // // //           if (_isProcessing)
// // // //             const Padding(
// // // //               padding: EdgeInsets.only(bottom: 16),
// // // //               child: Row(
// // // //                 mainAxisAlignment: MainAxisAlignment.center,
// // // //                 children: [
// // // //                   SizedBox(
// // // //                     width: 16,
// // // //                     height: 16,
// // // //                     child: CircularProgressIndicator(strokeWidth: 2),
// // // //                   ),
// // // //                   SizedBox(width: 8),
// // // //                   Text("Processing..."),
// // // //                 ],
// // // //               ),
// // // //             ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
  
// // // //   @override
// // // //   void dispose() {
// // // //     _processingTimer?.cancel();
// // // //     _cameraController?.dispose();
// // // //     WidgetsBinding.instance.removeObserver(this);
// // // //     super.dispose();
// // // //   }
// // // // }

// // // import 'dart:async';
// // // import 'dart:typed_data';
// // // import 'package:camera/camera.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

// // // class ContinuousCameraView extends StatefulWidget {
// // //   final Function(Uint8List imageBytes, InputImage inputImage) onProcessFrame;
// // //   final Duration processingInterval;
  
// // //   const ContinuousCameraView({
// // //     Key? key,
// // //     required this.onProcessFrame,
// // //     this.processingInterval = const Duration(seconds: 3),
// // //   }) : super(key: key);

// // //   @override
// // //   State<ContinuousCameraView> createState() => _ContinuousCameraViewState();
// // // }

// // // class _ContinuousCameraViewState extends State<ContinuousCameraView> with WidgetsBindingObserver {
// // //   CameraController? _cameraController;
// // //   List<CameraDescription>? _cameras;
// // //   bool _isInitialized = false;
// // //   bool _isProcessing = false;
// // //   Timer? _processingTimer;
// // //   bool _isMounted = false;
  
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _isMounted = true;
// // //     WidgetsBinding.instance.addObserver(this);
// // //     // Use a delay to ensure widget is fully mounted before camera init
// // //     Future.delayed(Duration.zero, () {
// // //       if (_isMounted) {
// // //         _initializeCamera();
// // //       }
// // //     });
// // //   }
  
// // //   @override
// // //   void didChangeAppLifecycleState(AppLifecycleState state) {
// // //     // Only handle lifecycle state if camera controller exists and is initialized
// // //     if (_cameraController == null || !_cameraController!.value.isInitialized) {
// // //       return;
// // //     }
    
// // //     if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
// // //       // Stop timer and dispose camera when app is inactive or paused
// // //       _processingTimer?.cancel();
// // //       _cameraController?.dispose();
// // //     } else if (state == AppLifecycleState.resumed) {
// // //       // Re-initialize camera when app is resumed
// // //       if (_isMounted) {
// // //         _initializeCamera();
// // //       }
// // //     }
// // //   }
  
// // //   Future<void> _initializeCamera() async {
// // //     // Cancel existing timer if any
// // //     _processingTimer?.cancel();
    
// // //     // Dispose existing controller if any
// // //     await _cameraController?.dispose();
    
// // //     if (!_isMounted) return;
    
// // //     try {
// // //       // Get available cameras
// // //       _cameras = await availableCameras();
      
// // //       if (_cameras == null || _cameras!.isEmpty) {
// // //         debugPrint("No cameras available");
// // //         return;
// // //       }
      
// // //       // Find front camera
// // //       CameraDescription? frontCamera;
// // //       for (var camera in _cameras!) {
// // //         if (camera.lensDirection == CameraLensDirection.front) {
// // //           frontCamera = camera;
// // //           break;
// // //         }
// // //       }
      
// // //       // If no front camera found, use the first available
// // //       final selectedCamera = frontCamera ?? _cameras!.first;
      
// // //       // Initialize controller
// // //       _cameraController = CameraController(
// // //         selectedCamera,
// // //         ResolutionPreset.medium,
// // //         enableAudio: false,
// // //         imageFormatGroup: ImageFormatGroup.jpeg,
// // //       );
      
// // //       // Initialize the controller
// // //       await _cameraController!.initialize();
      
// // //       if (!_isMounted) {
// // //         // Widget was disposed during initialization
// // //         await _cameraController?.dispose();
// // //         return;
// // //       }
      
// // //       // Setup periodic processing only after successful initialization
// // //       _startPeriodicProcessing();
      
// // //       setState(() {
// // //         _isInitialized = true;
// // //       });
// // //     } catch (e) {
// // //       debugPrint("Error initializing camera: $e");
// // //       if (_isMounted) {
// // //         setState(() {
// // //           _isInitialized = false;
// // //         });
// // //       }
// // //     }
// // //   }
  
// // //   void _startPeriodicProcessing() {
// // //     _processingTimer?.cancel();
// // //     _processingTimer = Timer.periodic(widget.processingInterval, (_) {
// // //       if (_isMounted && !_isProcessing) {
// // //         _processCurrentFrame();
// // //       }
// // //     });
// // //   }
  
// // //   Future<void> _processCurrentFrame() async {
// // //     // Skip if camera not initialized or already processing
// // //     if (_cameraController == null || 
// // //         !_cameraController!.value.isInitialized ||
// // //         _isProcessing ||
// // //         !_isMounted) {
// // //       return;
// // //     }
    
// // //     setState(() {
// // //       _isProcessing = true;
// // //     });
    
// // //     try {
// // //       // Capture image
// // //       final XFile imageFile = await _cameraController!.takePicture();
      
// // //       if (!_isMounted) return;
      
// // //       // Convert to bytes
// // //       final Uint8List imageBytes = await imageFile.readAsBytes();
      
// // //       // Create inputImage for ML Kit
// // //       final InputImage inputImage = InputImage.fromFilePath(imageFile.path);
      
// // //       // Process frame through callback
// // //       widget.onProcessFrame(imageBytes, inputImage);
// // //     } catch (e) {
// // //       debugPrint("Error processing frame: $e");
// // //     } finally {
// // //       if (_isMounted) {
// // //         setState(() {
// // //           _isProcessing = false;
// // //         });
// // //       }
// // //     }
// // //   }
  
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     if (!_isInitialized || _cameraController == null || !_cameraController!.value.isInitialized) {
// // //       return Expanded(
// // //         child: Container(
// // //           width: double.infinity,
// // //           decoration: BoxDecoration(
// // //             color: Colors.black12,
// // //             border: Border.all(color: Colors.blueGrey.shade200),
// // //           ),
// // //           child: const Center(
// // //             child: Column(
// // //               mainAxisAlignment: MainAxisAlignment.center,
// // //               children: [
// // //                 CircularProgressIndicator(),
// // //                 SizedBox(height: 16),
// // //                 Text("Initializing camera..."),
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //       );
// // //     }
    
// // //     return Expanded(
// // //       child: Column(
// // //         children: [
// // //           // Camera preview
// // //           Expanded(
// // //             child: Container(
// // //               width: double.infinity,
// // //               decoration: BoxDecoration(
// // //                 border: Border.all(color: Colors.blueGrey.shade200),
// // //               ),
// // //               child: ClipRRect(
// // //                 borderRadius: BorderRadius.circular(8),
// // //                 child: CameraPreview(_cameraController!),
// // //               ),
// // //             ),
// // //           ),
          
// // //           // Manual check button
// // //           Padding(
// // //             padding: const EdgeInsets.all(16),
// // //             child: ElevatedButton.icon(
// // //               onPressed: _isProcessing ? null : _processCurrentFrame,
// // //               icon: const Icon(Icons.camera),
// // //               label: const Text("Check Now"),
// // //               style: ElevatedButton.styleFrom(
// // //                 padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
// // //               ),
// // //             ),
// // //           ),
          
// // //           // Processing indicator
// // //           if (_isProcessing)
// // //             const Padding(
// // //               padding: EdgeInsets.only(bottom: 16),
// // //               child: Row(
// // //                 mainAxisAlignment: MainAxisAlignment.center,
// // //                 children: [
// // //                   SizedBox(
// // //                     width: 16,
// // //                     height: 16,
// // //                     child: CircularProgressIndicator(strokeWidth: 2),
// // //                   ),
// // //                   SizedBox(width: 8),
// // //                   Text("Processing..."),
// // //                 ],
// // //               ),
// // //             ),
// // //         ],
// // //       ),
// // //     );
// // //   }
  
// // //   @override
// // //   void dispose() {
// // //     _isMounted = false;
// // //     _processingTimer?.cancel();
// // //     _cameraController?.dispose();
// // //     WidgetsBinding.instance.removeObserver(this);
// // //     super.dispose();
// // //   }
// // // }


// // import 'dart:async';
// // import 'dart:typed_data';
// // import 'package:camera/camera.dart';
// // import 'package:flutter/foundation.dart';
// // import 'package:flutter/material.dart';
// // import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// // import 'dart:io';

// // class StreamingCameraView extends StatefulWidget {
// //   final Function(Uint8List imageBytes, InputImage inputImage) onProcessFrame;
// //   final Duration processingInterval;
  
// //   const StreamingCameraView({
// //     Key? key,
// //     required this.onProcessFrame,
// //     this.processingInterval = const Duration(seconds: 3),
// //   }) : super(key: key);

// //   @override
// //   State<StreamingCameraView> createState() => _StreamingCameraViewState();
// // }

// // class _StreamingCameraViewState extends State<StreamingCameraView> with WidgetsBindingObserver {
// //   CameraController? _cameraController;
// //   bool _isInitialized = false;
// //   bool _isProcessing = false;
// //   Timer? _processingTimer;
// //   bool _isMounted = true;
  
// //   @override
// //   void initState() {
// //     super.initState();
// //     WidgetsBinding.instance.addObserver(this);
// //     _initializeCamera();
// //   }
  
// //   @override
// //   void didChangeAppLifecycleState(AppLifecycleState state) {
// //     if (state == AppLifecycleState.inactive) {
// //       _disposeCamera();
// //     } else if (state == AppLifecycleState.resumed) {
// //       _initializeCamera();
// //     }
// //   }
  
// //   Future<void> _initializeCamera() async {
// //     // Dispose any existing camera controller
// //     await _disposeCamera();
    
// //     if (!_isMounted) return;
    
// //     try {
// //       // Get available cameras
// //       final cameras = await availableCameras();
      
// //       if (cameras.isEmpty) {
// //         debugPrint("No cameras available");
// //         return;
// //       }
      
// //       // Find front camera
// //       CameraDescription? frontCamera;
// //       for (var camera in cameras) {
// //         if (camera.lensDirection == CameraLensDirection.front) {
// //           frontCamera = camera;
// //           break;
// //         }
// //       }
      
// //       // If no front camera found, use the first available
// //       final selectedCamera = frontCamera ?? cameras.first;
      
// //       // Initialize controller with streaming enabled
// //       _cameraController = CameraController(
// //         selectedCamera,
// //         ResolutionPreset.medium,
// //         enableAudio: false,
// //         imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.yuv420 : ImageFormatGroup.bgra8888,
// //       );
      
// //       // Initialize the controller
// //       await _cameraController!.initialize();
      
// //       if (!_isMounted) return;
      
// //       // Start image stream
// //       await _cameraController!.startImageStream(_processCameraImage);
      
// //       // Set up periodic timer to process frames at specific intervals
// //       _startProcessingTimer();
      
// //       if (_isMounted) {
// //         setState(() {
// //           _isInitialized = true;
// //         });
// //       }
// //     } catch (e) {
// //       debugPrint("Error initializing camera: $e");
// //       if (_isMounted) {
// //         setState(() {
// //           _isInitialized = false;
// //         });
// //       }
// //     }
// //   }
  
// //   void _startProcessingTimer() {
// //     _processingTimer?.cancel();
// //     _processingTimer = Timer.periodic(widget.processingInterval, (_) {
// //       // This will flag that we should process the next frame
// //       if (!_isProcessing && _isMounted) {
// //         setState(() {
// //           _isProcessing = true;
// //         });
// //       }
// //     });
// //   }
  
// //   Future<void> _disposeCamera() async {
// //     _processingTimer?.cancel();
// //     _processingTimer = null;
    
// //     if (_cameraController != null) {
// //       try {
// //         if (_cameraController!.value.isStreamingImages) {
// //           await _cameraController!.stopImageStream();
// //         }
// //         await _cameraController!.dispose();
// //       } catch (e) {
// //         debugPrint("Error disposing camera: $e");
// //       }
// //       _cameraController = null;
// //     }
// //   }
  
// //   // This gets called for every frame from the camera stream
// //   void _processCameraImage(CameraImage cameraImage) async {
// //     // Only process the frame if we're due for processing (based on timer)
// //     if (!_isProcessing || !_isMounted || _cameraController == null) {
// //       return;
// //     }
    
// //     try {
// //       // Convert CameraImage to InputImage for ML Kit
// //       final camera = _cameraController!.description;
// //       final inputImage = _convertCameraImageToInputImage(cameraImage, camera);
      
// //       if (inputImage != null) {
// //         // Convert to bytes for other processing (like face comparison)
// //         final bytes = _convertCameraImageToBytes(cameraImage);
        
// //         if (bytes != null) {
// //           // Process the frame
// //           widget.onProcessFrame(bytes, inputImage);
// //         }
// //       }
// //     } catch (e) {
// //       debugPrint("Error processing camera image: $e");
// //     } finally {
// //       // Reset flag to allow future processing
// //       if (_isMounted) {
// //         setState(() {
// //           _isProcessing = false;
// //         });
// //       }
// //     }
// //   }
  
// //   // Convert CameraImage to InputImage for ML Kit

// // InputImage? _convertCameraImageToInputImage(CameraImage cameraImage, CameraDescription camera) {
// //   try {
// //     // Convert CameraImage to bytes
// //     final WriteBuffer allBytes = WriteBuffer();
// //     for (final Plane plane in cameraImage.planes) {
// //       allBytes.putUint8List(plane.bytes);
// //     }
// //     final bytes = allBytes.done().buffer.asUint8List();

// //     final imageSize = Size(
// //       cameraImage.width.toDouble(),
// //       cameraImage.height.toDouble(),
// //     );

// //     // Handle rotation
// //     final int sensorOrientation = camera.sensorOrientation ?? 0;
// //     InputImageRotation imageRotation;

// //     switch (sensorOrientation) {
// //       case 0:
// //         imageRotation = InputImageRotation.rotation0deg;
// //         break;
// //       case 90:
// //         imageRotation = InputImageRotation.rotation90deg;
// //         break;
// //       case 180:
// //         imageRotation = InputImageRotation.rotation180deg;
// //         break;
// //       case 270:
// //         imageRotation = InputImageRotation.rotation270deg;
// //         break;
// //       default:
// //         imageRotation = InputImageRotation.rotation0deg;
// //     }

// //     // Set image format
// //     final InputImageFormat inputImageFormat = Platform.isIOS ? InputImageFormat.bgra8888 : InputImageFormat.nv21;

// //     return InputImage.fromBytes(
// //       bytes: bytes,
// //       metadata: InputImageMetadata(
// //         size: imageSize,
// //         rotation: imageRotation,
// //         format: inputImageFormat,
// //         bytesPerRow: cameraImage.planes[0].bytesPerRow,
// //       ),
// //     );
// //   } catch (e) {
// //     debugPrint("Error converting CameraImage to InputImage: $e");
// //     return null;
// //   }
// // }
  
// //   // Convert CameraImage to bytes for other processing
// //   Uint8List? _convertCameraImageToBytes(CameraImage cameraImage) {
// //     // Simplified conversion to bytes
// //     // This implementation might need to be adjusted based on platform
// //     try {
// //       final WriteBuffer allBytes = WriteBuffer();
// //       for (final Plane plane in cameraImage.planes) {
// //         allBytes.putUint8List(plane.bytes);
// //       }
// //       return allBytes.done().buffer.asUint8List();
// //     } catch (e) {
// //       debugPrint("Error converting camera image to bytes: $e");
// //       return null;
// //     }
// //   }
  
// //   @override
// //   Widget build(BuildContext context) {
// //     if (!_isInitialized || _cameraController == null || !_cameraController!.value.isInitialized) {
// //       return Expanded(
// //         child: Container(
// //           width: double.infinity,
// //           decoration: BoxDecoration(
// //             color: Colors.black12,
// //             border: Border.all(color: Colors.blueGrey.shade200),
// //           ),
// //           child: const Center(
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 CircularProgressIndicator(),
// //                 SizedBox(height: 16),
// //                 Text("Initializing camera..."),
// //               ],
// //             ),
// //           ),
// //         ),
// //       );
// //     }
    
// //     return Expanded(
// //       child: Column(
// //         children: [
// //           // Camera preview
// //           Expanded(
// //             child: Container(
// //               width: double.infinity,
// //               decoration: BoxDecoration(
// //                 border: Border.all(color: Colors.blueGrey.shade200),
// //               ),
// //               child: ClipRRect(
// //                 borderRadius: BorderRadius.circular(8),
// //                 child: CameraPreview(_cameraController!),
// //               ),
// //             ),
// //           ),
          
// //           // Manual check button
// //           Padding(
// //             padding: const EdgeInsets.all(16),
// //             child: ElevatedButton.icon(
// //               onPressed: _isProcessing ? null : () {
// //                 setState(() {
// //                   _isProcessing = true;
// //                 });
// //               },
// //               icon: const Icon(Icons.camera),
// //               label: const Text("Check Now"),
// //               style: ElevatedButton.styleFrom(
// //                 padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
// //               ),
// //             ),
// //           ),
          
// //           // Processing indicator
// //           if (_isProcessing)
// //             const Padding(
// //               padding: EdgeInsets.only(bottom: 16),
// //               child: Row(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   SizedBox(
// //                     width: 16,
// //                     height: 16,
// //                     child: CircularProgressIndicator(strokeWidth: 2),
// //                   ),
// //                   SizedBox(width: 8),
// //                   Text("Processing..."),
// //                 ],
// //               ),
// //             ),
// //         ],
// //       ),
// //     );
// //   }
  
// //   @override
// //   void dispose() {
// //     _isMounted = false;
// //     _disposeCamera();
// //     WidgetsBinding.instance.removeObserver(this);
// //     super.dispose();
// //   }
// // }

// // custom_camera_view.dart
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'dart:async';

// class CustomCameraView extends StatefulWidget {
//   final Function(InputImage) onImage;

//   const CustomCameraView({Key? key, required this.onImage}) : super(key: key);

//   @override
//   _CustomCameraViewState createState() => _CustomCameraViewState();
// }

// class _CustomCameraViewState extends State<CustomCameraView> {
//   CameraController? _cameraController;
//   List<CameraDescription>? _cameras;
//   bool isProcessing = false;
//   Timer? absenceTimer;
//   int absenceDuration = 0;
//   bool isFacePresent = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }

//   Future<void> _initializeCamera() async {
//     _cameras = await availableCameras();
//     if (_cameras != null && _cameras!.isNotEmpty) {
//       _cameraController = CameraController(_cameras![1], ResolutionPreset.medium);
//       await _cameraController!.initialize();
//       _cameraController!.startImageStream((CameraImage image) {
//         if (!isProcessing) {
//           isProcessing = true;
//           _processCameraImage(image);
//         }
//       });
//       setState(() {});
//     }
//   }

//   Future<void> _processCameraImage(CameraImage image) async {
//     final inputImage = InputImage.fromBytes(
//       bytes: image.planes[0].bytes,
//       metadata: InputImageMetadata(
//         size: Size(image.width.toDouble(), image.height.toDouble()),
//         rotation: InputImageRotation.rotation0deg,
//         format: InputImageFormat.nv21,
//         bytesPerRow: image.planes[0].bytesPerRow,
//       ),
//     );
//     widget.onImage(inputImage);
//     isProcessing = false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return _cameraController == null || !_cameraController!.value.isInitialized
//         ? Container()
//         : CameraPreview(_cameraController!);
//   }

//   @override
//   void dispose() {
//     _cameraController?.dispose();
//     absenceTimer?.cancel();
//     super.dispose();
//   }
// }


import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraScreen extends StatefulWidget {
  final Function(InputImage)? onImage;
  final Function(bool)? onFaceDetected;
  final bool showOverlay;

  const CameraScreen({
    super.key,
    this.onImage,
    this.onFaceDetected,
    this.showOverlay = true,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  
  // Store last captured image for processing
  InputImage? _lastCapturedImage;
  
  // Face detector setup
  final _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
      enableClassification: true,
      performanceMode: FaceDetectorMode.fast,
      minFaceSize: 0.05,
    ),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;
    
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    
    if (state == AppLifecycleState.inactive) {
      cameraController.stopImageStream();
    } else if (state == AppLifecycleState.resumed) {
      _startImageStream();
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      final cameras = await availableCameras();
      final front = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      try {
        await _controller!.initialize();
        if (!mounted) return;
        
        // Configure camera settings
        await _controller!.setExposureMode(ExposureMode.auto);
        await _controller!.setFocusMode(FocusMode.auto);
        
        _startImageStream();
        setState(() => _isCameraInitialized = true);
      } catch (e) {
        debugPrint('Error initializing camera: $e');
      }
    }
  }
  
  void _startImageStream() {
    _controller!.startImageStream(_processImage);
  }

  void _processImage(CameraImage cameraImage) async {
    if (_isProcessing) return;
    
    _isProcessing = true;
    
    final InputImage? inputImage = _convertCameraImageToInputImage(cameraImage);
    if (inputImage == null) {
      debugPrint('Failed to convert image');
      _isProcessing = false;
      return;
    }

    try {
      final faces = await _faceDetector.processImage(inputImage);
      
      if (widget.onFaceDetected != null) {
        widget.onFaceDetected!(faces.isNotEmpty);
      }

      if (faces.isNotEmpty) {
        _lastCapturedImage = inputImage;
      }

      if (widget.onImage != null && faces.isNotEmpty) {
        widget.onImage!(inputImage);
      }
    } catch (e) {
      debugPrint('Error processing face: $e');
    } finally {
      _isProcessing = false;
    }
  }

  InputImage? _convertCameraImageToInputImage(CameraImage cameraImage) {
    final CameraDescription? camera = _controller?.description;
    if (camera == null) return null;

    final rotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    if (rotation == null) return null;

    // Handle YUV format for MLKit
    const format = InputImageFormat.nv21;
    
    // Convert YUV420 to NV21 for ML Kit processing
    final bytes = _convertYUV420ToNV21(cameraImage);

    final metadata = InputImageMetadata(
      size: Size(cameraImage.width.toDouble(), cameraImage.height.toDouble()),
      rotation: rotation,
      format: format,
      bytesPerRow: cameraImage.planes[0].bytesPerRow,
    );
    
    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  Uint8List _convertYUV420ToNV21(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final int ySize = width * height;
    final int uvSize = ySize ~/ 2;
    
    Uint8List nv21 = Uint8List(ySize + uvSize);
    
    // Copy Y channel
    nv21.setRange(0, ySize, image.planes[0].bytes);
    
    // Copy UV channels in NV21 format (interleaved U/V)
    int uvIndex = ySize;
    for (int i = 0; i < image.planes[1].bytes.length; i += 2) {
      if (i + 1 < image.planes[1].bytes.length && uvIndex < nv21.length - 1) {
        nv21[uvIndex++] = image.planes[1].bytes[i];   // U channel
        nv21[uvIndex++] = image.planes[2].bytes[i];   // V channel
      }
    }

    return nv21;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.stopImageStream();
    _controller?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera preview
        CameraPreview(_controller!),
        
        // Face overlay
        if (widget.showOverlay)
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(125),
              ),
            ),
          ),
          
        // Processing indicator
        Positioned(
          bottom: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isProcessing ? Colors.amber : Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Face Detection Active",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}