import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';

class CameraView extends StatefulWidget {
  const CameraView(
      {super.key, required this.onImage, required this.onInputImage});

  final Function(Uint8List image) onImage;
  final Function(InputImage inputImage) onInputImage;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  File? _image;
  ImagePicker? _imagePicker;

  @override
  void initState() {
    super.initState();

    _imagePicker = ImagePicker();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 300,
          decoration: const BoxDecoration(
            color: Colors.yellowAccent,
          ),
          child: _image != null
              ? Image.file(
                  _image!,
                  fit: BoxFit.cover,
                )
              : const Center(
                  child: Icon(
                    Icons.camera_alt,
                    size: 32,
                    color: Color(0xff2E2E2E),
                  ),
                ),
        ),
        const SizedBox(
          height: 12,
        ),
        InkWell(
          onTap: _getImage,
          child: Container(
            width: 240,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(colors: [
                // Color.fromRGBO(91, 202, 191, 1),
                Color.fromRGBO(222, 249, 196, 1),
                Color.fromRGBO(222, 249, 196, 1)
              ], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            child: const Text("Click here to Capture",
                style: TextStyle(fontSize: 16)),
          ),
        ),
        // ElevatedButton(
        //   onPressed: _getImage,
        //   child: const Text(
        //     "Click here to Capture",
        //     style: TextStyle(
        //       fontSize: 14,
        //     ),
        //   ),
        // ),
        const SizedBox(
          height: 12,
        ),
      ],
    );
  }

  Future _getImage() async {
    setState(() {
      _image = null;
    });
    final pickedFile = await _imagePicker?.pickImage(
      source: ImageSource.camera,
      maxWidth: 400,
      maxHeight: 400,
      // imageQuality: 50,
    );
    if (pickedFile != null) {
      _setPickedFile(pickedFile);
    }
    setState(() {});
  }

  Future _setPickedFile(XFile? pickedFile) async {
    final path = pickedFile?.path;
    if (path == null) {
      return;
    }
    setState(() {
      _image = File(path);
    });

    Uint8List imageBytes = _image!.readAsBytesSync();
    widget.onImage(imageBytes);

    InputImage inputImage = InputImage.fromFilePath(path);
    widget.onInputImage(inputImage);
  }
}
