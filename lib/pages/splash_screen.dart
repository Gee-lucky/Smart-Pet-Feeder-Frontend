import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
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

    _navigateToNextScreen();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.loadUserFromPrefs();

    if (mounted) {
      if (authProvider.user != null && authProvider.accessToken != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // Background color is set by scaffoldBackgroundColor in ThemeData
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              'Smart Pet Feeder',
              style: theme.textTheme.headlineLarge,
            ),
            const SizedBox(height: 16),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}