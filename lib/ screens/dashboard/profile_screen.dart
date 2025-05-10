import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../app/routes/app_routes.dart';
import '../common/bottom_nav.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: authProvider.userId == null
            ? const Text('Not logged in')
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'User ID: ${authProvider.userId}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Sign Out',
              onPressed: () async {
                await authProvider.signOut();
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(),
    );
  }
}