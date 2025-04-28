import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/strings.dart';
import '../widgets/custom_widgets.dart';
import '../providers/auth_provider.dart';
import '../utils/theme/theme.dart'; // For ThemeNotifier and AppThemeColors

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  PasswordResetScreenState createState() => PasswordResetScreenState();
}

class PasswordResetScreenState extends State<PasswordResetScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
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
    _tokenController.dispose();
    _newPasswordController.dispose();
    _animationController.dispose();
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
                  Strings.resetPasswordTitle,
                  style: theme.textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  Strings.resetPasswordInstruction,
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
                          'Token',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
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
                        const SizedBox(height: 16),
                        Text(
                          Strings.newPasswordLabel,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
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
                                ? const Center(child: CircularProgressIndicator())
                                : ElevatedButton(
                              onPressed: _handleResetPassword,
                              child: Text(
                                Strings.resetPasswordButtonTxt,
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