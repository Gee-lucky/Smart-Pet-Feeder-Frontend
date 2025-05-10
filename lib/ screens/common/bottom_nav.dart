import 'package:flutter/material.dart';
import '../../app/routes/app_routes.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.schedule), label: 'Schedule'),
        BottomNavigationBarItem(
            icon: Icon(Icons.history), label: 'History'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      currentIndex: _getCurrentIndex(context),
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      onTap: (index) => _onItemTapped(index, context),
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name;
    switch (route) {
      case AppRoutes.home:
        return 0;
      case AppRoutes.schedule:
        return 1;
      case AppRoutes.feedingHistory:
        return 2;
      case AppRoutes.profile:
        return 3;
      default:
        return 0;
    }
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.schedule);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRoutes.feedingHistory);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, AppRoutes.profile);
        break;
    }
  }
}