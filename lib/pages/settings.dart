// import 'package:flutter/material.dart';
//
// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({super.key});
//
//   @override
//   // ignore: library_private_types_in_public_api
//   _SettingsScreenState createState() => _SettingsScreenState();
// }
//
// class _SettingsScreenState extends State<SettingsScreen> {
//   bool _notificationsEnabled = true;
//   double _alertSensitivity = 0.5; // For example, low food alert sensitivity
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Settings', style: TextStyle(color: Colors.white),),backgroundColor: Colors.blueAccent,),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           // Profile Section
//           const Row(
//             children: [
//               CircleAvatar(
//
//             ],
//           ),
//           const SizedBox(height: 20),
//           // Notification Settings
//           ExpansionTile(
//             title: const Text('Notifications'),
//             leading: const Icon(Icons.notifications),
//             children: [
//               SwitchListTile(
//                 title: const Text('Enable Notifications'),
//                 value: _notificationsEnabled,
//                 onChanged: (bool value) {
//                   setState(() {
//                     _notificationsEnabled = value;
//                   });
//                 },
//               ),
//               ListTile(
//                 title: const Text('Alert Sensitivity'),
//                 subtitle: Slider(
//                   value: _alertSensitivity,
//                   min: 0,
//                   max: 1,
//                   divisions: 10,
//                   label: (_alertSensitivity * 100).round().toString(),
//                   onChanged: _notificationsEnabled
//                       ? (value) {
//                           setState(() {
//                             _alertSensitivity = value;
//                           });
//                         }
//                       : null,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           // Theme Settings
//           ListTile(
//             leading: const Icon(Icons.color_lens),
//             title: const Text('Customize Theme'),
//             onTap: () {
//               // Navigate to a Theme customization screen or open a dialog
//             },
//           ),
//           const SizedBox(height: 20),
//           // Account & Security
//           ListTile(
//             leading: const Icon(Icons.lock),
//             title: const Text('Account & Security'),
//             onTap: () {
//               // Navigate to account management screen
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Section
          const Row(
            children: [
              CircleAvatar(
                radius: 30,
                child: Icon(Icons.person),
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Gee Luck',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('gee.luck@example.com'),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),

          // Notification Settings
          ExpansionTile(
            title: const Text('Notifications'),
            leading: const Icon(Icons.notifications),
            children: [
              SwitchListTile(
                title: const Text('Enable Notifications'),
                value: settingsProvider.notificationsEnabled,
                onChanged: (bool value) {
                  settingsProvider.toggleNotifications(value);
                },
              ),
              ListTile(
                title: const Text('Alert Sensitivity'),
                subtitle: Slider(
                  value: settingsProvider.alertSensitivity,
                  min: 0,
                  max: 1,
                  divisions: 10,
                  label: (settingsProvider.alertSensitivity * 100)
                      .round()
                      .toString(),
                  onChanged: settingsProvider.notificationsEnabled
                      ? (value) {
                          settingsProvider.setSensitivity(value);
                        }
                      : null,
                ),
              ),
            ],
          ),
          // Rest of your UI remains the same
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Customize Theme'),
            onTap: () {/* Add theme provider later */},
          ),
          // Other list tiles...
        ],
      ),
    );
  }
}
