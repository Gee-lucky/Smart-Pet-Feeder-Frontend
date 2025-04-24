import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/strings.dart';
import '../widgets/custom_widgets.dart';
import '../providers/auth_provider.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  PasswordResetScreenState createState() => PasswordResetScreenState();
}

class PasswordResetScreenState extends State<PasswordResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  @override
  void dispose() {
    _tokenController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.resetPassword(
      _tokenController.text,
      _newPasswordController.text,
    );

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
        title: const Text(Strings.resetPasswordTitle, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(Strings.resetPasswordInstruction),
              const SizedBox(height: 20),
              InputField(
                hintText: 'Enter the token',
                labelText: 'Token',
                icon: const Icon(Icons.vpn_key),
                controller: _tokenController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the token';
                  }
                  return null;
                },
              ),
              InputField(
                hintText: Strings.hintPasswordTxt,
                labelText: Strings.newPasswordLabel,
                icon: const Icon(Icons.lock),
                controller: _newPasswordController,
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
              const SizedBox(height: 16),
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return authProvider.isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: _handleResetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      Strings.resetPasswordButtonTxt,
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