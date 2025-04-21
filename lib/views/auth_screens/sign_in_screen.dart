import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:student_monitoring_app/components/gradient_border.dart';
import 'package:student_monitoring_app/resources/auth_methods.dart';
import 'package:student_monitoring_app/views/main_layout_screen.dart';

import '../../components/text_input.dart';
import 'login_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  // final TextEditingController _studentTypeController = TextEditingController();
  String? selectedStudentType;
  final TextEditingController _parentEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    // _studentTypeController.dispose();
    // selectedStudentType!.dispose();
    _parentEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void navigateToLogin() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  void signInStudent() async {
    setState(() => _isLoading = true);
    String res = await AuthMethods().signUpStudent(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      studentType: selectedStudentType!,
      parentEmail: _parentEmailController.text,
    );
    setState(() => _isLoading = false);

    if (res != 'success') {
      showSnackBar(res, context);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainLayoutScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> studentTypes = [
      'Engineering',
      'Medical',
      'Boards',
    ];

    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 50),
              const Text(
                'Student Sign In',
                style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              GradientBorder(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      TextFieldInput(
                        hintText: 'Enter your Name',
                        textEditingController: _nameController,
                        textInputType: TextInputType.name,
                      ),
                      const SizedBox(height: 24),
                      TextFieldInput(
                        hintText: 'Enter your Email',
                        textEditingController: _emailController,
                        textInputType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 24),
                      TextFieldInput(
                        hintText: 'Enter your Password',
                        textEditingController: _passwordController,
                        textInputType: TextInputType.visiblePassword,
                        isPass: true,
                      ),
                      const SizedBox(height: 24),
                      DropdownButtonFormField2<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color.fromARGB(204, 213, 247, 231),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                          border: InputBorder.none, // No border by default
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide
                                .none, // No visible border, but keeps radius
                          ), // No border normally
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              color: Color.fromRGBO(20, 184, 129, 1),
                              width: 1.5,
                            ),
                          ),
                        ),
                        hint: const Text(
                          'Select your Student Type',
                          style: TextStyle(fontSize: 16),
                        ),
                        items: studentTypes
                            .map((type) => DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(
                                    type,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ))
                            .toList(),
                        value: selectedStudentType,
                        onChanged: (value) {
                          selectedStudentType = value;
                          setState(() {});
                        },
                        iconStyleData: const IconStyleData(
                          icon: Icon(Icons.arrow_drop_down,
                              color: Colors.black45),
                        ),
                        dropdownStyleData: DropdownStyleData(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: const Color.fromARGB(204, 213, 247, 231),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFieldInput(
                        hintText: 'Enter Parent Email',
                        textEditingController: _parentEmailController,
                        textInputType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: _isLoading ? null : signInStudent,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Container(
                        width: w / 2.5,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                                colors: [
                                  Color.fromRGBO(91, 202, 191, 1),
                                  Color.fromRGBO(222, 249, 196, 1)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight)),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.black)
                            : const Text('Sign Up'),
                      ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const Text(
                      'Already have an account?',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  GestureDetector(
                    onTap: navigateToLogin,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Text(
                        ' Log in.',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

showSnackBar(String content, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(content)));
}
