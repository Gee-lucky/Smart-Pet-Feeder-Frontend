import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../modals/user_preference.dart';
import '../modals/user_modal.dart';
import '../providers/theme_notifier.dart';
import '../utils/theme/theme.dart';
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
  int _currentIndex = 2;

  @override
  void dispose() {
    _firstNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return; // Prevent navigation if already on the current screen

    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/schedule');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/settings');
        break;
    }
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

  Future<void> _confirmLogout(AuthProvider authProvider) async {
    final theme = Theme.of(context);

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: AppThemeColors.secondaryColor,
          title: Text(
            'Confirm Logout',
            style: theme.textTheme.titleMedium,
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // No
              child: Text(
                'No',
                style: GoogleFonts.poppins(
                  color: theme.primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true), // Yes
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Yes',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      await authProvider.logout();
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final themeNotifier = Provider.of<ThemeNotifier>(context);

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
          // Background color is set by scaffoldBackgroundColor in ThemeData
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              children: [
                Text(
                  'Settings',
                  style: theme.textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Customize your app preferences',
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Profile Section
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppThemeColors.secondaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: theme.primaryColor,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.firstName ?? 'Guest',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.brightness == Brightness.dark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              user?.email ?? 'No email',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isEditing ? Icons.cancel : Icons.edit,
                          color: theme.primaryColor,
                        ),
                        onPressed: () {
                          setState(() => _isEditing = !_isEditing);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Edit Profile Form
                if (_isEditing)
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: AppThemeColors.secondaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'First Name',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
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
                          const SizedBox(height: 16),
                          Text(
                            'Email',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          InputField(
                            hintText: 'Enter your email',
                            labelText: 'Email',
                            icon: const Icon(Icons.email),
                            controller: _emailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Phone Number',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
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
                            child: Text(
                              'Save Profile',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                // Notifications Section
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppThemeColors.secondaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      'Notifications',
                      style: theme.textTheme.titleMedium,
                    ),
                    children: [
                      SwitchListTile(
                        title: Text(
                          'Enable Notifications',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: theme.brightness == Brightness.dark ? Colors.white : Colors.black87,
                          ),
                        ),
                        secondary: Icon(Icons.notifications, color: theme.primaryColor),
                        value: settingsProvider.notificationsEnabled,
                        onChanged: (bool value) {
                          settingsProvider.toggleNotifications(value);
                        },
                        activeColor: theme.primaryColor,
                      ),
                      ListTile(
                        title: Text(
                          'Alert Sensitivity',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: theme.brightness == Brightness.dark ? Colors.white : Colors.black87,
                          ),
                        ),
                        subtitle: Slider(
                          value: settingsProvider.alertSensitivity,
                          min: 0,
                          max: 1,
                          divisions: 10,
                          label: (settingsProvider.alertSensitivity * 100).round().toString(),
                          onChanged: settingsProvider.notificationsEnabled
                              ? (value) {
                            settingsProvider.setSensitivity(value);
                          }
                              : null,
                          activeColor: theme.primaryColor,
                          inactiveColor: theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Theme Toggle
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppThemeColors.secondaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SwitchListTile(
                    title: Text(
                      'Dark Theme',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: theme.brightness == Brightness.dark ? Colors.white : Colors.black87,
                      ),
                    ),
                    secondary: Icon(Icons.color_lens, color: theme.primaryColor),
                    value: themeNotifier.isDarkMode,
                    onChanged: (bool value) {
                      themeNotifier.toggleTheme();
                    },
                    activeColor: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                // Logout Button
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppThemeColors.secondaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: Text(
                      'Logout',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                    onTap: () => _confirmLogout(authProvider),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: CurvedNavigationBar(
            index: _currentIndex,
            color: AppThemeColors.secondaryColor,
            buttonBackgroundColor: theme.primaryColor,
            height: 65,
            animationDuration: const Duration(milliseconds: 300),
            backgroundColor: Colors.transparent,
            items: [
              Icon(
                Icons.home,
                size: 30,
                color: _currentIndex == 0 ? Colors.white : Colors.grey,
              ),
              Icon(
                Icons.schedule,
                size: 30,
                color: _currentIndex == 1 ? Colors.white : Colors.grey,
              ),
              Icon(
                Icons.settings,
                size: 30,
                color: _currentIndex == 2 ? Colors.white : Colors.grey,
              ),
            ],
            onTap: _onItemTapped,
          ),
        );
      },
    );
  }
}