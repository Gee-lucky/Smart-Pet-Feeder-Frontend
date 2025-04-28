import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../modals/user_modal.dart';
import '../modals/user_preference.dart';
import '../providers/feeding_schedule_provider.dart';
import '../utils/theme/theme.dart'; // For ThemeNotifier and AppThemeColors

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Alignment> _gradientBeginAnimation;
  late Animation<Alignment> _gradientEndAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _secondFadeAnimation;
  late Animation<double> _buttonScaleAnimation;
  int _currentIndex = 0; // Set to 0 for HomeScreen

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
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

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _secondFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeIn),
      ),
    );

    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return; // Prevent navigation if already on the current screen

    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/schedule');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/settings');
        break;
    }
  }

  Future<void> _feedNow() async {
    final feedingProvider = Provider.of<FeedingScheduleProvider>(context, listen: false);
    final result = await feedingProvider.feedNow(context);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<User?>(
      future: UserPreferences.getUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

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
                      'Welcome, ${user?.username ?? "Guest"}',
                      style: theme.textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Keep your pet happy and healthy!',
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    // Main Content Container
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: AppThemeColors.secondaryColor, // White container
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              'Effortlessly manage your pet’s feeding schedule with a single tap! Keep your furry friend happy and healthy.',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: theme.brightness == Brightness.dark ? Colors.black87 : Colors.black87,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FadeTransition(
                            opacity: _secondFadeAnimation,
                            child: Text(
                              'Track your pet’s feeding history and ensure consistency with automated reminders, all in one place!',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: theme.brightness == Brightness.dark ? Colors.black54 : Colors.black54,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 48),
                          GestureDetector(
                            onTapDown: (_) => _animationController.forward(),
                            onTapUp: (_) {
                              _animationController.reverse();
                              _feedNow();
                            },
                            onTapCancel: () => _animationController.reverse(),
                            child: AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _buttonScaleAnimation.value,
                                  child: ElevatedButton(
                                    onPressed: () {}, // Handled by GestureDetector
                                    child: Text(
                                      'Feed Now',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: CurvedNavigationBar(
            index: _currentIndex,
            color: AppThemeColors.secondaryColor, // White background
            buttonBackgroundColor: theme.primaryColor, // Primary color for active item
            height: 65,
            animationDuration: const Duration(milliseconds: 300),
            backgroundColor: Colors.transparent,
            items: [
              Icon(
                Icons.home,
                size: 30,
                color: _currentIndex == 0 ? Colors.white : Colors.grey,
              ),
              Icon(
                Icons.schedule,
                size: 30,
                color: _currentIndex == 1 ? Colors.white : Colors.grey,
              ),
              Icon(
                Icons.settings,
                size: 30,
                color: _currentIndex == 2 ? Colors.white : Colors.grey,
              ),
            ],
            onTap: _onItemTapped,
          ),
        );
      },
    );
  }
}