import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/strings.dart';
import '../widgets/custom_widgets.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ForgotPasswordScreenState createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleForgotPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.forgotPassword(_emailController.text);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
      if (result['status']) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.forgotPasswordTitle, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(Strings.forgotPasswordInstruction),
              const SizedBox(height: 20),
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
              const SizedBox(height: 16),
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return authProvider.isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: _handleForgotPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      Strings.sendResetEmailButtonTxt,
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