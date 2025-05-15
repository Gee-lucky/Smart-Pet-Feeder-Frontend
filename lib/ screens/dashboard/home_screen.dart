import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feeding_schedule_provider.dart';
import '../../services/api_service.dart';
import '../../services/esp32_service.dart';
import '../../widgets/custom_button.dart';
import '../common/bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  bool _isVisible = false;
  OverlayEntry? _overlayEntry; // Track the overlay entry to remove it properly

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() => _isVisible = true);
    });
  }

  void _showOverlay(BuildContext context) {
    _overlayEntry = OverlayEntry(
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
      opaque: false,
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final feedingProvider = Provider.of<FeedingScheduleProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final esp32Service = Esp32Service();
    final apiService = ApiService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Pet Feeder'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.white],
          ),
        ),
        child: AnimatedOpacity(
          opacity: _isVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue.shade50,
                          border: Border.all(
                            color: Colors.blue.shade200,
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.pets,
                          size: 40,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Welcome to Smart Pet Feeder!',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
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
                            _showOverlay(context);
                            await esp32Service.triggerFeeding();
                            await feedingProvider.logFeeding(authProvider.userId!, DateTime.now());
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Feeding triggered!')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          } finally {
                            _hideOverlay();
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FutureBuilder<String>(
                            future: esp32Service.getDeviceStatus(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }
                              if (snapshot.hasError) {
                                return Text(
                                  'Device Status: Error (${snapshot.error})',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red),
                                  textAlign: TextAlign.center,
                                );
                              }
                              return Text(
                                'Device Status: ${snapshot.data ?? "Unknown"}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh, color: Colors.blueAccent),
                            onPressed: () {
                              setState(() {}); // Force rebuild to refresh status
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (authProvider.userId != null)
                        FutureBuilder<List<dynamic>>(
                          future: apiService.getFeedings(authProvider.userId!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            final latestFeeding = snapshot.data!.reduce((a, b) =>
                            DateTime.parse(a['timestamp'])
                                .isAfter(DateTime.parse(b['timestamp'])) ? a : b);
                            final lastTime = DateTime.parse(latestFeeding['timestamp']).toLocal();
                            return Text(
                              'Last Feed: ${lastTime.toString().split('.')[0]}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(),
    );
  }
}