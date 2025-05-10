import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feeding_schedule_provider.dart';
import '../../services/esp32_service.dart';
import '../../widgets/custom_button.dart';
import '../common/bottom_nav.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final feedingProvider = Provider.of<FeedingScheduleProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context); // Access AuthProvider
    final esp32Service = Esp32Service();

    return Scaffold(
      appBar: AppBar(title: const Text('Smart Pet Feeder')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Smart Pet Feeder!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Feed Now',
              onPressed: () async {
                if (authProvider.userId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please log in to feed')),
                  );
                  return;
                }
                try {
                  await esp32Service.triggerFeeding();
                  await feedingProvider.logFeeding(authProvider.userId!, DateTime.now());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Feeding triggered!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            FutureBuilder<String>(
              future: esp32Service.getDeviceStatus(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                return Text('Device Status: ${snapshot.data ?? "Unknown"}');
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(),
    );
  }
}