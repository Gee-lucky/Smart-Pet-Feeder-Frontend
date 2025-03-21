// import 'package:animated_splash_screen/animated_splash_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:kissima/utils/images.dart';
// import 'package:provider/provider.dart';
//
// import '../providers/auth_provider.dart';
// import 'login.dart';
// import '../main.dart';
//
// class MySplashScreen extends StatelessWidget {
//   const MySplashScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedSplashScreen(
//       splashIconSize: 200,
//       backgroundColor: Colors.blue,
//       centered: true,
//       splash: ClipOval(
//         child: CircleAvatar(
//           radius: 100,
//           backgroundImage: AssetImage(Images.splashImage),
//         ),
//       ),
//       duration: 3000, // Same as the delay in _navigateToNextScreen
//       nextScreen: const LoadingScreen(), // navigate to the new screen, with loading and redirection logic
//     );
//   }
// }
//
// class LoadingScreen extends StatefulWidget {
//   const LoadingScreen({super.key});
//
//   @override
//   State<LoadingScreen> createState() => _LoadingScreenState();
// }
//
// class _LoadingScreenState extends State<LoadingScreen> {
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _navigateToNextScreen(context);
//   }
//
//   Future<void> _navigateToNextScreen(BuildContext context) async {
//     // await Future.delayed(const Duration(seconds: 3));
//
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     // Use pushReplacement to avoid going back to the splash screen.
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (_) =>
//         authProvider.isLoggedIn ? const HomeScreen() : const LoginPage(),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(
//         child: CircularProgressIndicator(),
//       ),
//     );
//   }
// }

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:kissima/utils/images.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'login.dart';
import '../main.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _navigateToNextScreen(context);
  }

  Future<void> _navigateToNextScreen(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // Wait until the authProvider checked if there is a user logged in
    await authProvider.checkLoginStatus();

    // Use pushReplacement to avoid going back to the splash screen.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            authProvider.isLoggedIn ? const HomeScreen() : const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splashIconSize: 200,
      backgroundColor: Colors.blue,
      centered: true,
      splash: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipOval(
            child: CircleAvatar(
              radius: 100,
              backgroundImage: AssetImage(Images.splashImage),
            ),
          ),
          const SizedBox(height: 20), // Space between image and text
          const Text(
            'Welcome to My App', // Your text here
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Customize text color
            ),
          ),
          const SizedBox(
              height: 20), // Space between text and progress indicator
          const CircularProgressIndicator(
            color: Colors.white, // Customize progress indicator color
          ),
        ],
      ),
      duration: 3000, // animation of 3 seconds
      nextScreen: Container(), // We will not navigate here
    );
  }
}
