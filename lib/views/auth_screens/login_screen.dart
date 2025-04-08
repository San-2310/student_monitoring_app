import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_monitoring_app/components/gradient_border.dart';
import 'package:student_monitoring_app/components/text_input.dart';
import 'package:student_monitoring_app/resources/auth_methods.dart';
import 'package:student_monitoring_app/views/main_layout_screen.dart';

import '../../resources/student_provider.dart';
import 'sign_in_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void loginUser() async {
    setState(() {
      _isLoading = true;
    });

    String res = await AuthMethods().loginStudent(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (res == "success") {
      StudentProvider studentProvider =
          Provider.of<StudentProvider>(context, listen: false);
      await studentProvider.refreshStudent();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainLayoutScreen(),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res),
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  void navigateToSignUp() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  const Text(
                    'Log In',
                    style: TextStyle(color: Colors.black, fontSize: 35),
                  ),
                  const SizedBox(height: 60),
                  GradientBorder(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Email",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          TextFieldInput(
                            hintText: 'Enter your email',
                            textEditingController: _emailController,
                            textInputType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 24),
                          const Text("Password",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          TextFieldInput(
                            hintText: 'Enter your password',
                            textEditingController: _passwordController,
                            textInputType: TextInputType.text,
                            isPass: true,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  InkWell(
                    onTap: loginUser,
                    child: Container(
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
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text('Log In'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: const Text("Don't have an account?"),
                      ),
                      GestureDetector(
                        onTap: () {
                          navigateToSignUp();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
