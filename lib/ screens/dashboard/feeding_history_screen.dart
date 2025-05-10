import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../common/bottom_nav.dart';

class FeedingHistoryScreen extends StatelessWidget {
  const FeedingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Feeding History')),
      body: authProvider.userId == null
          ? const Center(child: Text('Please log in to view history'))
          : FutureBuilder<List<dynamic>>(
        future: ApiService().getFeedings(authProvider.userId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No feeding history found'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final feeding = snapshot.data![index];
              final time = DateTime.parse(feeding['timestamp']); // Updated to match FeedingRecord field
              return ListTile(
                title: Text('Feeding at ${time.toLocal()}'),
                subtitle: Text('Amount: ${feeding['amount']}g'),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const BottomNav(),
    );
  }
}