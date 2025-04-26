import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kissima/providers/feeding_schedule_provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../modals/user_modal.dart';
import '../modals/user_preference.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {

  // Handle navigation when a bottom navigation item is tapped
  void _onItemTapped(int index) {
    setState(() {
    });

    // Navigate based on the selected index
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
      case 1:
        Navigator.pushNamed(context, '/schedule');
        break;
      case 2:
        Navigator.pushNamed(context, '/settings');
        break;
    }
  }

  Future<void> _feedNow() async {
    final feedingProvider = Provider.of<FeedingScheduleProvider>(context, listen: false);
    final result = await feedingProvider.feedNow();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          appBar: AppBar(
            title: Text(
              'Welcome, ${user?.username ?? "Guest"}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.blueAccent,
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Pet image with fade-in animation
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: FadeInImage(
                      placeholder: const AssetImage('assets/images/placeholder.png'), // Fallback placeholder
                      image: const NetworkImage(
                        'https://images.unsplash.com/photo-1592194996308-7b43878e84a6', // Dog image
                      ),
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                      fadeInDuration: const Duration(milliseconds: 800),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Description text
                  Text(
                    'Effortlessly manage your pet’s feeding schedule with a single tap! Keep your furry friend happy and healthy.',
                    style: GoogleFonts.oswald(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48), // Increased spacing to move the button down
                  // Feed Now button
                  ElevatedButton(
                    onPressed: _feedNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                      shadowColor: Colors.blueAccent.withOpacity(0.5), // Add a shadow
                    ),
                    child: const Text(
                      'Feed Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.schedule),
                label: 'View Feeding Schedule',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
            selectedItemColor: Colors.blueAccent,
            onTap: _onItemTapped,
          ),
        );
      },
    );
  }
}