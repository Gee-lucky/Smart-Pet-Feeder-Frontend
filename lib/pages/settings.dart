import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../modals/user_preference.dart';
import '../modals/user_modal.dart';
import '../widgets/custom_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isEditing = false;


  @override
  void dispose() {
    _firstNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdateProfile(AuthProvider authProvider) async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final profileData = {
      'first_name': _firstNameController.text,
      'email': _emailController.text,
      'phone_number': _phoneController.text,
    };
    final result = await authProvider.updateProfile(profileData);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
      if (result['status']) {
        setState(() => _isEditing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return FutureBuilder<User?>(
      future: UserPreferences.getUser(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (!_isEditing) {
          _firstNameController.text = user?.firstName ?? '';
          _emailController.text = user?.email ?? '';
          _phoneController.text = user?.phone ?? '';
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.blueAccent,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [

                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.firstName ?? 'Guest',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(user?.email ?? 'No email'),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(_isEditing ? Icons.cancel : Icons.edit),
                    onPressed: () {
                      setState(() => _isEditing = !_isEditing);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_isEditing)
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      InputField(
                        hintText: 'Enter your first name',
                        labelText: 'First Name',
                        icon: const Icon(Icons.person),
                        controller: _firstNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your first name';
                          }
                          return null;
                        },
                      ),
                      InputField(
                        hintText: 'Enter your email',
                        labelText: 'Email',
                        icon: const Icon(Icons.email),
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      InputField(
                        hintText: 'Enter your phone number',
                        labelText: 'Phone Number',
                        icon: const Icon(Icons.phone),
                        controller: _phoneController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          if (!RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(value)) {
                            return 'Please enter a valid phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _handleUpdateProfile(authProvider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          'Save Profile',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ExpansionTile(
                title: const Text('Notifications'),
                children: [
                  SwitchListTile(
                    title: const Text('Enable Notifications'),
                    secondary: const Icon(Icons.notifications),
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
              SwitchListTile(
                title: const Text('Dark Theme'),
                secondary: const Icon(Icons.color_lens),
                value: settingsProvider.themeMode == ThemeMode.dark,
                onChanged: (bool value) {
                  settingsProvider.toggleTheme(value);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout'),
                onTap: () async {
                  await authProvider.logout();
                  if (mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                          (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}