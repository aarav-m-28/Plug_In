// 🛠️ FIX 1: Corrected the import statement (package:flutter)
import 'package:flutter/material.dart';
// import 'package:app/services/theme_service.dart'; // Assuming this exists

// --- 🛠️ FIX 2: Corrected FAKE SERVICE (Remove this in your app) ---
// This is a syntactically correct stub that mimics your service's API.
class FakeThemeService extends ValueNotifier<ThemeMode> {
  FakeThemeService(super.value);

  void toggleTheme() {
    value = value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}
final themeService = FakeThemeService(ThemeMode.light);
// --- END OF FAKE SERVICE ---

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _currentLanguage = 'English'; // 🎨 NEW FEATURE: State for language

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🎨 UI IMPROVEMENT: Light background to make sections stand out
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Settings'),
        // 🎨 UI IMPROVEMENT: Flat, modern app bar
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: ListView(
        children: [
          // 🎨 UI IMPROVEMENT: Section Header
          _SettingsHeader('General'),
          
          // 🎨 UI IMPROVEMENT: Using a helper for consistency
          
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeService,
            builder: (context, themeMode, child) {
              return _SettingsSwitchTile(
                icon: Icons.dark_mode,
                color: Colors.purple.shade600,
                title: 'Dark Mode',
                value: themeMode == ThemeMode.dark,
                onChanged: (value) {
                  themeService.toggleTheme();
                },
              );
            },
          ),
          
          // 🎨 UI IMPROVEMENT: Divider for separation
          const Divider(height: 32, indent: 16, endIndent: 16),

          // 🎨 UI IMPROVEMENT: Section Header
          _SettingsHeader('Account'),
          _SettingsTile(
            icon: Icons.person,
            color: Colors.green.shade600,
            title: 'Edit Profile',
            subtitle: 'Manage your account details',
            onTap: () {
              // TODO: Implement Edit Profile screen
            },
          ),
          _SettingsSwitchTile(
            icon: Icons.notifications,
            color: Colors.orange.shade600,
            title: 'Enable Notifications',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
                // TODO: Save notification preference
              });
            },
          ),

          const Divider(height: 32, indent: 16, endIndent: 16),

          // 🎨 UI IMPROVEMENT: Section Header
          _SettingsHeader('Support & Legal'),
          _SettingsTile(
            icon: Icons.info,
            color: Colors.blueGrey.shade500,
            title: 'About',
            subtitle: 'App version, licenses',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Slug N Plug',
                applicationVersion: '1.0.1',
                applicationLegalese: '© 2025 SnP Club',
              );
            },
          ),
          // 🎨 NEW FEATURE: Privacy Policy
          _SettingsTile(
            icon: Icons.privacy_tip,
            color: Colors.blueGrey.shade500,
            title: 'Privacy Policy',
            subtitle: 'Read our terms of service',
            onTap: () {
              // TODO: Open Privacy Policy URL
            },
          ),
          // 🎨 NEW FEATURE: Logout Button
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red.shade600),
            title: Text(
              'Logout',
              style: TextStyle(
                color: Colors.red.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: _showLogoutDialog,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // 🎨 NEW FEATURE: Language selection dialog
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select Language'),
          children: [
            SimpleDialogOption(
              onPressed: () {
                setState(() => _currentLanguage = 'English');
                Navigator.pop(context);
              },
              child: const Text('English'),
            ),
            SimpleDialogOption(
              onPressed: () {
                setState(() => _currentLanguage = 'Spanish');
                Navigator.pop(context);
              },
              child: const Text('Español'),
            ),
            SimpleDialogOption(
              onPressed: () {
                setState(() => _currentLanguage = 'French');
                Navigator.pop(context);
              },
              child: const Text('Français'),
            ),
          ],
        );
      },
    );
  }

  // 🎨 NEW FEATURE: Logout confirmation dialog
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // TODO: Add actual logout logic
                Navigator.pop(context);
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

// 🎨 UI HELPER: A reusable widget for section headers
class _SettingsHeader extends StatelessWidget {
  final String title;
  const _SettingsHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey.shade700,
          fontWeight: FontWeight.bold,
          fontSize: 12.0,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// 🎨 UI HELPER: A reusable widget for navigation tiles
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    super.key, // Added super.key
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      elevation: 1,
      shadowColor: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          foregroundColor: color,
          child: Icon(icon),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}

// 🎨 UI HELPER: A reusable widget for switch tiles
class _SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    super.key, // Added super.key
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      elevation: 1,
      shadowColor: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        secondary: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          foregroundColor: color,
          child: Icon(icon),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}