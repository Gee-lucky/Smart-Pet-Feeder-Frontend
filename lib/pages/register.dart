import 'package:flutter/material.dart';
import 'package:kissima/pages/schedule.dart';
import '../components/custom_widgets.dart';
import '../utils/strings.dart';
import 'login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isObscureConfirmPassword = true;
  bool _isObscurePassword = true;

  void _handleRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      // Registration logic
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ScheduleScreen()),
          (route) => false);
    }
  }

  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Register', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Center(
              child: Column(
                children: [
                  InputField(
                    hintText: Hints.hintFirstNameTxt,
                    labelText: Labels.firstnameLabel,
                    icon: const Icon(Icons.person),
                    controller: _firstnameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  InputField(
                    hintText: Hints.hintMiddleNameTxt,
                    labelText: Labels.middleNameLabel,
                    icon: const Icon(Icons.person_2),
                    controller: _middleNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your middle name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  InputField(
                    hintText: Hints.hintSurnameTxt,
                    labelText: Labels.surnameLabel,
                    icon: const Icon(Icons.person_3),
                    controller: _surnameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your surname';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  InputField(
                    hintText: Hints.hintEmailTxt,
                    labelText: Labels.emailLabel,
                    icon: const Icon(Icons.email),
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  InputField(
                    hintText: Hints.hintContactTxt,
                    labelText: Labels.contactLabel,
                    icon: const Icon(Icons.phone),
                    controller: _contactController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your contact number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  InputField.passwordField(
                    Hints.hintPasswordTxt,
                    Labels.passwordLabel,
                    const Icon(Icons.lock),
                    controller: _passwordController,
                    obscureText: _isObscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscurePassword = !_isObscurePassword;
                        });
                      },
                    ),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  const SizedBox(height: 20),
                  InputField.passwordField(
                    Hints.hintConfirmPasswordTxt,
                    Labels.confirmPasswordLabel,
                    const Icon(Icons.lock),
                    controller: _confirmPasswordController,
                    obscureText: _isObscureConfirmPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscureConfirmPassword =
                              !_isObscureConfirmPassword;
                        });
                      },
                    ),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _handleRegister();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 20),
                    ),
                    child: const Text('Register'),
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                          (route) => false);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 20),
                    ),
                    child: const Text.rich(
                      TextSpan(
                        text: "Already have an account? ",
                        children: [
                          TextSpan(
                            text: 'Login',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
