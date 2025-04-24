import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/strings.dart';
import '../widgets/custom_widgets.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _surnameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userData = {
      'first_name': _firstNameController.text,
      'middle_name': _middleNameController.text,
      'last_name': _surnameController.text,
      'username': _usernameController.text,
      'email': _emailController.text,
      'phone_number': _contactController.text,
      'password': _passwordController.text,
    };
    final result = await authProvider.register(userData);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
      if (result['status']) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
              (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.registerTitle, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              InputField(
                hintText: Strings.hintFirstnameTxt,
                labelText: Strings.firstnameLabel,
                icon: const Icon(Icons.person),
                controller: _firstNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return Strings.emptyFirstnameError;
                  }
                  return null;
                },
              ),
              InputField(
                hintText: Strings.hintMiddleNameTxt,
                labelText: Strings.middleNameLabel,
                icon: const Icon(Icons.person),
                controller: _middleNameController,
              ),
              InputField(
                hintText: Strings.hintSurnameTxt,
                labelText: Strings.surnameLabel,
                icon: const Icon(Icons.person),
                controller: _surnameController,
              ),
              InputField(
                hintText: 'Enter your username',
                labelText: 'Username',
                icon: const Icon(Icons.person),
                controller: _usernameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              InputField(
                hintText: Strings.hintEmailTxt,
                labelText: Strings.emailLabel,
                icon: const Icon(Icons.email),
                controller: _emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return Strings.emptyEmailError;
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return Strings.invalidEmailError;
                  }
                  return null;
                },
              ),
              InputField(
                hintText: Strings.hintContactTxt,
                labelText: Strings.contactLabel,
                icon: const Icon(Icons.phone),
                controller: _contactController,
              ),
              InputField(
                hintText: Strings.hintPasswordTxt,
                labelText: Strings.passwordLabel,
                icon: const Icon(Icons.lock),
                controller: _passwordController,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return Strings.emptyPasswordError;
                  }
                  if (value.length < 6) {
                    return Strings.shortPasswordError;
                  }
                  return null;
                },
              ),
              InputField(
                hintText: Strings.hintConfirmPasswordTxt,
                labelText: Strings.confirmPasswordLabel,
                icon: const Icon(Icons.lock),
                controller: _confirmPasswordController,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return Strings.emptyConfirmPasswordError;
                  }
                  if (value != _passwordController.text) {
                    return Strings.passwordMismatchError;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return authProvider.isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      Strings.registerButtonTxt,
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}