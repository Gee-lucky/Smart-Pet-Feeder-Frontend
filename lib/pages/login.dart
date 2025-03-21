import 'package:flutter/material.dart';
import 'package:kissima/components/custom_widgets.dart';
import 'package:kissima/utils/strings.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'register.dart';
import 'forgot_password.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscurePassword = true;

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        showDialog(
          context: context,
          builder: (context) => LoadingAnimationWidget.staggeredDotsWave(
              color: Colors.blue, size: 50),
        );
        await authProvider.login(
            _emailController.text, _passwordController.text);
        // Navigation is handled automatically by the root widget
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.toString()}')),
        );
      }
    }
  }

  void _handleGoogleSignIn() {
    // Implement Google Sign-In
  }

  void _handleFacebookSignIn() {
    // Implement Facebook Sign-In
  }

  void _handleTelegramSignIn() {
    // Implement Telegram Sign-In
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Login',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Center(
              child: Column(
                children: [
                  // Existing form fields
                  InputField(
                    controller: _emailController,
                    hintText: Hints.hintEmailTxt,
                    labelText: Labels.emailLabel,
                    icon: const Icon(Icons.email),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
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
                  ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      iconColor: Colors.blue,
                      shadowColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 20),
                    ),
                    child: const Text('Login'),
                  ),
                  const SizedBox(height: 15),

                  // Registration link
                  TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                        (route) => false,
                      );
                    },
                    child: const Text.rich(
                      TextSpan(
                        text: "Don't have an account? ",
                        children: [
                          TextSpan(
                            text: 'Register',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 3,
                        ),
                        GestureDetector(
                          child: Text(
                            "forgot password ?",
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ForgotPassword()));
                          },
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // OR divider
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 50),
                        child: Text('OR'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Social login buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SocialLoginButton(
                        icon: Icon(
                          Icons.g_mobiledata_outlined,
                          size: 35,
                          color: Colors.blue,
                        ),
                        onPressed: _handleGoogleSignIn,
                      ),
                      const SizedBox(width: 20),
                      SocialLoginButton(
                        icon: Icon(
                          Icons.facebook,
                          size: 35,
                          color: Colors.blue,
                        ),
                        onPressed: _handleFacebookSignIn,
                      ),
                      const SizedBox(width: 20),
                      SocialLoginButton(
                        icon: Icon(
                          Icons.telegram,
                          size: 35,
                          color: Colors.blue,
                        ),
                        onPressed: _handleTelegramSignIn,
                      ),
                    ],
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

// Custom Social Login Button Widget
class SocialLoginButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onPressed;

  const SocialLoginButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: icon,
      style: IconButton.styleFrom(
        padding: const EdgeInsets.all(15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
