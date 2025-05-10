import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../storage/ user_preferences.dart';
import '../../widgets/custom_button.dart';
import '../../app/routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final email = await UserPreferences.getEmail();
    final password = await UserPreferences.getPassword();
    if (email != null && password != null) {
      _emailController.text = email;
      _passwordController.text = password;
      setState(() => _rememberMe = true);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                          'Smart Pet Feeder',
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
                          validator: (value) =>
                          value!.isEmpty ? 'Password is required' : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) =>
                                  setState(() => _rememberMe = value!),
                              checkColor: Colors.white,
                              fillColor: WidgetStateProperty.all(Colors.blueAccent),
                            ),
                            const Text(
                              'Remember Me',
                              style: TextStyle(color: Colors.blueGrey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        authProvider.isLoading
                            ? const CircularProgressIndicator(
                          color: Colors.blueAccent,
                          strokeWidth: 4.0,
                        )
                            : CustomButton(
                          text: 'Login',
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final scaffoldMessenger = ScaffoldMessenger.of(context);
                              final navigator = Navigator.of(context);
                              bool success = await authProvider.signIn(
                                _emailController.text.trim(),
                                _passwordController.text.trim(),
                              );
                              if (success) {
                                if (_rememberMe) {
                                  await UserPreferences.saveEmail(
                                      _emailController.text.trim());
                                  await UserPreferences.savePassword(
                                      _passwordController.text.trim());
                                } else {
                                  await UserPreferences.clearCredentials();
                                }
                                navigator.pushReplacementNamed(AppRoutes.home);
                              } else {
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Login failed: ${authProvider.errorMessage ?? 'Try again.'}')),
                                );
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.register),
                          child: const Text(
                            'Don’t have an account? Register',
                            style: TextStyle(color: Colors.blueAccent),
                          ),
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