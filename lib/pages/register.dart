import 'package:flutter/material.dart';
import 'package:kissima/utils/strings.dart';
import 'package:kissima/widgets/custom_widgets.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isObscureConfirmPassword = true;
  bool _isObscurePassword = true;
  bool _isLoading = false;

  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  Future<void> _handleRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final result = await authProvider.register(
        firstName: _firstnameController.text,
        middleName: _middleNameController.text,
        username: _usernameController.text,
        lastName: _surnameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        phoneNumber: _contactController.text,
      );

      if (mounted) {
        if (result['status']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful')),
          );
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
                (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'])),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _middleNameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(Strings.registerTitle, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                InputField(
                  hintText: Strings.hintFirstnameTxt,
                  labelText: Strings.firstnameLabel,
                  icon: const Icon(Icons.person),
                  controller: _firstnameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return Strings.emptyFirstnameError;
                    }
                    return null;
                  },
                ),
                InputField(
                  hintText: 'Enter your username',
                  labelText: 'Username',
                  icon: const Icon(Icons.person_outline),
                  controller: _usernameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
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
                  hintText: Strings.hintEmailTxt,
                  labelText: Strings.emailLabel,
                  icon: const Icon(Icons.email),
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return Strings.emptyEmailError;
                    }
                    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (!RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(value)) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                InputField.passwordField(
                  Strings.hintPasswordTxt,
                  Strings.passwordLabel,
                  const Icon(Icons.lock),
                  controller: _passwordController,
                  obscureText: _isObscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return Strings.emptyPasswordError;
                    }
                    if (value.length < 6) {
                      return Strings.shortPasswordError;
                    }
                    return null;
                  },
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscurePassword = !_isObscurePassword;
                      });
                    },
                  ),
                ),
                InputField.passwordField(
                  Strings.hintConfirmPasswordTxt,
                  Strings.confirmPasswordLabel,
                  const Icon(Icons.lock),
                  controller: _confirmPasswordController,
                  obscureText: _isObscureConfirmPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return Strings.emptyConfirmPasswordError;
                    }
                    if (value != _passwordController.text) {
                      return Strings.passwordMismatchError;
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
                        _isObscureConfirmPassword = !_isObscureConfirmPassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}