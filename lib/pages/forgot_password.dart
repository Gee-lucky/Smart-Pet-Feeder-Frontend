import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/strings.dart';
import '../widgets/custom_widgets.dart';
import '../providers/auth_provider.dart';
import '../utils/theme/theme.dart'; // For ThemeNotifier and AppThemeColors

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ForgotPasswordScreenState createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  late AnimationController _animationController;
  late Animation<Alignment> _gradientBeginAnimation;
  late Animation<Alignment> _gradientEndAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
    _gradientBeginAnimation = Tween<Alignment>(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).animate(_animationController);
    _gradientEndAnimation = Tween<Alignment>(
      begin: Alignment.bottomRight,
      end: Alignment.topLeft,
    ).animate(_animationController);
    _glowAnimation = Tween<double>(begin: 0.0, end: 6.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _animationController.dispose();
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
    final theme = Theme.of(context);

    return Scaffold(
      // Background color is set by scaffoldBackgroundColor in ThemeData
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Animated Logo
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: _gradientBeginAnimation.value,
                          end: _gradientEndAnimation.value,
                          colors: [
                            theme.primaryColor,
                            theme.primaryColor.withValues(alpha: 0.7),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withValues(alpha: _glowAnimation.value / 4 * 0.2),
                            blurRadius: _glowAnimation.value,
                            spreadRadius: 1.0,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.pets,
                        size: 60,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  Strings.forgotPasswordTitle,
                  style: theme.textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  Strings.forgotPasswordInstruction,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Form Container
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: AppThemeColors.secondaryColor, // White container
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Strings.emailLabel,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
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
                                ? const Center(child: CircularProgressIndicator())
                                : ElevatedButton(
                              onPressed: _handleForgotPassword,
                              child: Text(
                                Strings.sendResetEmailButtonTxt,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          },
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
    );
  }
}