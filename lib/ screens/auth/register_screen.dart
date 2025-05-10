import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../app/routes/app_routes.dart';
// For StaticPaw

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade100,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue.shade50,
                                border: Border.all(
                                  color: Colors.blue.shade200,
                                  width: 3,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.pets,
                              size: 60,
                              color: Colors.blueAccent,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Join Smart Pet Feeder',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: const TextStyle(color: Colors.blueGrey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.blue.shade50,
                            prefixIcon: const Icon(Icons.email, color: Colors.blueAccent),
                          ),
                          style: const TextStyle(color: Colors.blueGrey),
                          validator: (value) =>
                          value!.isEmpty ? 'Email is required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _firstNameController,
                          decoration: InputDecoration(
                            labelText: 'First Name',
                            labelStyle: const TextStyle(color: Colors.blueGrey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.blue.shade50,
                            prefixIcon: const Icon(Icons.person, color: Colors.blueAccent),
                          ),
                          style: const TextStyle(color: Colors.blueGrey),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                            labelText: 'Last Name',
                            labelStyle: const TextStyle(color: Colors.blueGrey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.blue.shade50,
                            prefixIcon: const Icon(Icons.person, color: Colors.blueAccent),
                          ),
                          style: const TextStyle(color: Colors.blueGrey),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: const TextStyle(color: Colors.blueGrey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.blue.shade50,
                            prefixIcon: const Icon(Icons.lock, color: Colors.blueAccent),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.blueAccent,
                              ),
                              onPressed: () =>
                                  setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          style: const TextStyle(color: Colors.blueGrey),
                          obscureText: _obscurePassword,
                          validator: (value) => value!.length < 6
                              ? 'Password must be at least 6 characters'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            labelStyle: const TextStyle(color: Colors.blueGrey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.blue.shade50,
                            prefixIcon: const Icon(Icons.lock, color: Colors.blueAccent),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.blueAccent,
                              ),
                              onPressed: () => setState(() =>
                              _obscureConfirmPassword = !_obscureConfirmPassword),
                            ),
                          ),
                          style: const TextStyle(color: Colors.blueGrey),
                          obscureText: _obscureConfirmPassword,
                          validator: (value) => value != _passwordController.text
                              ? 'Passwords do not match'
                              : null,
                        ),
                        const SizedBox(height: 20),
                        authProvider.isLoading
                            ? const CircularProgressIndicator(
                          color: Colors.blueAccent,
                            strokeWidth: 4.0,
                        )
                            : CustomButton(
                          text: 'Register',
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              bool success = await authProvider.register(
                                _emailController.text.trim(),
                                _passwordController.text.trim(),
                                _firstNameController.text.trim(),
                                _lastNameController.text.trim(),
                              );
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Registration successful! Please log in.')),
                                );
                                Navigator.pushReplacementNamed(
                                    context, AppRoutes.login);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Registration failed: ${authProvider.errorMessage ?? 'Try again.'}')),
                                );
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Back to Login',
                          onPressed: () =>
                              Navigator.pushReplacementNamed(context, AppRoutes.login),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}