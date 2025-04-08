import 'package:cloud_firestore/cloud_firestore.dart';

import 'face_features.dart';

class Student {
  final String id;
  final String name;
  final String email;
  final String studentType; // PCM, PCB, or PCMB
  final String parentEmail;
  String? image;
  FaceFeatures? faceFeatures;
  Timestamp? registeredOn;

  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.studentType,
    required this.parentEmail,
    this.image,
    this.faceFeatures,
    this.registeredOn,
  });

  factory Student.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Student(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      studentType: data['studentType'] ?? 'PCM',
      parentEmail: data['parentEmail'] ?? '',
      image: data['image'],
      faceFeatures: data['faceFeatures'] != null
          ? FaceFeatures.fromJson(data['faceFeatures'])
          : null,
      registeredOn: data['registeredOn'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'studentType': studentType,
      'parentEmail': parentEmail,
      if (image != null) 'image': image,
      if (faceFeatures != null) 'faceFeatures': faceFeatures!.toJson(),
      if (registeredOn != null) 'registeredOn': registeredOn,
    };
  }
}
