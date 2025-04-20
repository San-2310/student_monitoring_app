// // import 'dart:convert';
// // import 'dart:typed_data';

// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:image/image.dart' as img;
// // import 'package:provider/provider.dart';
// // import 'package:shared_preferences/shared_preferences.dart';

// // import '../../resources/student_provider.dart';
// // // import '../providers/student_provider.dart';
// // // import '../models/student.dart';

// // class ProfileScreen extends StatefulWidget {
// //   const ProfileScreen({super.key});

// //   @override
// //   State<ProfileScreen> createState() => _ProfileScreenState();
// // }

// // class _ProfileScreenState extends State<ProfileScreen> {
// //   Uint8List? localImage;

// //   @override
// //   void initState() {
// //     super.initState();
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       _loadImageFromCacheOrNetwork();
// //     });
// //   }

// //   Future<void> _loadImageFromCacheOrNetwork() async {
// //     final student =
// //         Provider.of<StudentProvider>(context, listen: false).getStudent;
// //     if (student?.image == null) return;

// //     final prefs = await SharedPreferences.getInstance();
// //     final cached = prefs.getString('student_profile_image');

// //     if (cached != null) {
// //       setState(() => localImage = base64Decode(cached));
// //     } else {
// //       try {
// //         final res = await http.get(Uri.parse(student!.image!));
// //         if (res.statusCode == 200) {
// //           final original = img.decodeImage(res.bodyBytes);
// //           final compressed = img.encodeJpg(original!, quality: 50);
// //           await prefs.setString(
// //               'student_profile_image', base64Encode(compressed));
// //           setState(() => localImage = Uint8List.fromList(compressed));
// //         }
// //       } catch (e) {
// //         print('Error caching image: $e');
// //       }
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final provider = Provider.of<StudentProvider>(context);
// //     final student = provider.getStudent;

// //     if (!provider.isDataLoaded) {
// //       return const Scaffold(
// //         body: Center(child: CircularProgressIndicator()),
// //       );
// //     }

// //     if (student == null) {
// //       return const Scaffold(
// //         body: Center(child: Text("Student data not available.")),
// //       );
// //     }

// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text(
// //           "My Profile",
// //           style: TextStyle(
// //             fontWeight: FontWeight.bold,
// //           ),
// //         ),
// //         backgroundColor: Colors.transparent,
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(20.0),
// //         child: Column(
// //           children: [
// //             CircleAvatar(
// //               radius: 60,
// //               backgroundImage: localImage != null
// //                   ? MemoryImage(localImage!)
// //                   : NetworkImage(
// //                       "https://cdn-icons-png.flaticon.com/512/17780/17780123.png"),
// //             ),
// //             const SizedBox(height: 20),
// //             Text(student.name,
// //                 style:
// //                     const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
// //             const SizedBox(height: 8),
// //             Text(student.email, style: const TextStyle(fontSize: 16)),
// //             const Divider(height: 30),
// //             _infoTile("Student Type", student.studentType),
// //             _infoTile("Parent Email", student.parentEmail),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _infoTile(String label, String value) {
// //     return ListTile(
// //       contentPadding: EdgeInsets.zero,
// //       leading: const Icon(Icons.info_outline),
// //       title: Text(label),
// //       subtitle: Text(value),
// //     );
// //   }
// // }

// import 'dart:convert';
// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:image/image.dart' as img;
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../../resources/student_provider.dart';

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   Uint8List? localImage;
//   bool isEditing = false;

//   final nameController = TextEditingController();
//   final emailController = TextEditingController();
//   final typeController = TextEditingController();
//   final parentEmailController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadImageFromPrefs();
//       _loadStudentData();
//     });
//   }

//   void _loadStudentData() {
//     final student =
//         Provider.of<StudentProvider>(context, listen: false).getStudent;
//     print(student!.id);
//     if (student != null) {
//       nameController.text = student.name;
//       emailController.text = student.email;
//       typeController.text = student.studentType;
//       parentEmailController.text = student.parentEmail;
//     }
//   }

//   Future<void> _loadImageFromPrefs() async {
//     final prefs = await SharedPreferences.getInstance();
//     final cached = prefs.getString('student_profile_image');
//     if (cached != null) {
//       setState(() => localImage = base64Decode(cached));
//     }
//   }

//   Future<void> _pickAndSaveImage() async {
//     final picker = ImagePicker();
//     final picked = await picker.pickImage(source: ImageSource.gallery);
//     if (picked == null) return;

//     final bytes = await picked.readAsBytes();
//     final original = img.decodeImage(bytes);
//     final compressed = img.encodeJpg(original!, quality: 50);
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('student_profile_image', base64Encode(compressed));

//     setState(() => localImage = Uint8List.fromList(compressed));
//   }

//   Future<void> _saveProfile() async {
//     final provider = Provider.of<StudentProvider>(context, listen: false);
//     final student = provider.getStudent;
//     if (student == null) return;

//     final updated = student.copyWith(
//       name: nameController.text.trim(),
//       email: emailController.text.trim(),
//       studentType: typeController.text.trim(),
//       parentEmail: parentEmailController.text.trim(),
//     );

//     await provider.refreshStudent(updated);
//     setState(() => isEditing = false);
//     ScaffoldMessenger.of(context)
//         .showSnackBar(const SnackBar(content: Text("Profile updated")));
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<StudentProvider>(context);
//     final student = provider.getStudent;

//     if (!provider.isDataLoaded) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     if (student == null) {
//       return const Scaffold(
//           body: Center(child: Text("No student data found.")));
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("My Profile",
//             style: TextStyle(fontWeight: FontWeight.bold)),
//         backgroundColor: Colors.transparent,
//         actions: [
//           IconButton(
//             icon: Icon(isEditing ? Icons.save : Icons.edit),
//             onPressed: () =>
//                 isEditing ? _saveProfile() : setState(() => isEditing = true),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             GestureDetector(
//               onTap: isEditing ? _pickAndSaveImage : null,
//               child: CircleAvatar(
//                 radius: 60,
//                 backgroundImage: localImage != null
//                     ? MemoryImage(localImage!)
//                     : const NetworkImage(
//                             "https://cdn-icons-png.flaticon.com/512/17780/17780123.png")
//                         as ImageProvider,
//               ),
//             ),
//             const SizedBox(height: 20),
//             _buildEditableField("Name", nameController),
//             _buildEditableField("Email", emailController),
//             _buildEditableField("Student Type", typeController),
//             _buildEditableField("Parent Email", parentEmailController),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEditableField(String label, TextEditingController controller) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: TextField(
//         controller: controller,
//         enabled: isEditing,
//         decoration: InputDecoration(
//           labelText: label,
//           border: const OutlineInputBorder(),
//           suffixIcon: isEditing ? const Icon(Icons.edit) : null,
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../resources/auth_methods.dart';
import '../../resources/student_provider.dart';
import '../auth_screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Uint8List? localImage;
  bool isEditing = false;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final typeController = TextEditingController();
  final parentEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadImageFromPrefs();
      _loadStudentData();
    });
  }

  void _loadStudentData() {
    final student =
        Provider.of<StudentProvider>(context, listen: false).getStudent;
    if (student != null) {
      nameController.text = student.name;
      emailController.text = student.email;
      typeController.text = student.studentType;
      parentEmailController.text = student.parentEmail;
    }
  }

  Future<void> _loadImageFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('student_profile_image');
    if (cached != null) {
      setState(() => localImage = base64Decode(cached));
    }
  }

  Future<void> _pickAndSaveImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    final original = img.decodeImage(bytes);
    final compressed = img.encodeJpg(original!, quality: 50);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('student_profile_image', base64Encode(compressed));

    setState(() => localImage = Uint8List.fromList(compressed));
  }

  Future<void> _saveProfile() async {
    final provider = Provider.of<StudentProvider>(context, listen: false);
    final student = provider.getStudent;
    if (student == null) return;

    final updated = student.copyWith(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      studentType: typeController.text.trim(),
      parentEmail: parentEmailController.text.trim(),
    );

    // Update in Firestore
    await provider.updateStudent(updated);
    setState(() => isEditing = false);

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully.")));
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StudentProvider>(context);
    final student = provider.getStudent;

    if (!provider.isDataLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (student == null) {
      return const Scaffold(
          body: Center(child: Text("No student data found.")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: () =>
                isEditing ? _saveProfile() : setState(() => isEditing = true),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: isEditing ? _pickAndSaveImage : null,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: localImage != null
                    ? MemoryImage(localImage!)
                    : NetworkImage(student.image ??
                            "https://cdn-icons-png.flaticon.com/512/17780/17780123.png")
                        as ImageProvider,
              ),
            ),
            const SizedBox(height: 20),
            _buildEditableField("Name", nameController),
            _buildEditableField("Email", emailController),
            _buildEditableField("Student Type", typeController),
            _buildEditableField("Parent Email", parentEmailController),
            // ElevatedButton(onPressed: onPressed, child: child)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () async {
                await AuthMethods().signOut();
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('student_profile_image');
                // Optional: Navigate to login screen OR pop to root
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        enabled: isEditing,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: isEditing ? const Icon(Icons.edit) : null,
        ),
      ),
    );
  }
}
