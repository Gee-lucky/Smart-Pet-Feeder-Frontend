import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:kissima/utils/images.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class MySplashScreen extends StatelessWidget {
  const MySplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splashIconSize: 200,
      backgroundColor: Colors.blueAccent,
      centered: true,
      splash: ClipOval(
        child: CircleAvatar(
          radius: 100,
          backgroundImage: AssetImage(Images.splashImage),
        ),
      ),
      duration: 3000,
      nextScreen: const LoadingScreen(),
    );
  }
}

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3)); // Match splash duration
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        authProvider.isLoggedIn ? '/home' : '/login',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}

// import 'package:animated_splash_screen/animated_splash_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:kissima/utils/images.dart';
// import 'package:provider/provider.dart';
// import '../providers/auth_provider.dart';
// import 'login.dart';
// import 'home.dart';
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
//       duration: 3000,
//       nextScreen: const LoadingScreen(),
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
//   void initState() {
//     super.initState();
//     _navigateToNextScreen(context);
//   }
//
//   Future<void> _navigateToNextScreen(BuildContext context) async {
//     await Future.delayed(const Duration(seconds: 3)); // Match splash duration
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     Navigator.pushReplacementNamed(
//       context,
//       authProvider.isLoggedIn ? '/home' : '/login',
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