// Updated Student Model
import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String id;
  final String name;
  final String email;
  final String studentType; // PCM, PCB, or PCMB
  final String parentEmail;

  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.studentType,
    required this.parentEmail,
  });

  factory Student.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Student(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      studentType: data['studentType'] ?? 'PCM',
      parentEmail: data['parentEmail'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'studentType': studentType,
      'parentEmail': parentEmail,
    };
  }
}
