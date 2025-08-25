import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../helpers/auth_helper.dart';
import '../providers/theme_provider.dart';

// A simple User class to represent a user's data.
class User {
  String name;
  final String email;

  User({required this.name, required this.email});
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // FIX: Load the user's name from AuthHelper
    _nameController.text = AuthHelper.currentUserName ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _updateName() async {
    final newName = _nameController.text;
    if (newName.isNotEmpty) {
      await AuthHelper.saveName(newName);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name updated successfully!')),
      );
      // Rebuild the widget to show the new name
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty.')),
      );
    }
  }

  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final newPasswordConfirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Current Password'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPasswordConfirmController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirm New Password'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final oldPassword = oldPasswordController.text;
                final newPassword = newPasswordController.text;
                final newPasswordConfirm = newPasswordConfirmController.text;

                if (newPassword != newPasswordConfirm) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('New passwords do not match!')),
                  );
                  return;
                }

                final isCorrect = await AuthHelper.checkPassword(oldPassword);
                if (isCorrect) {
                  await AuthHelper.changePassword(newPassword);
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password changed successfully!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Incorrect current password.')),
                  );
                }
              },
              child: const Text('Change'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);
    final userEmail = AuthHelper.currentUserEmail ?? 'guest@example.com';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
            secondary: Icon(themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode),
          ),
          const Divider(),

          Text(
            'Account Details',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              suffixIcon: IconButton(
                icon: const Icon(Icons.save),
                onPressed: _updateName,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Email'),
            subtitle: Text(userEmail),
            leading: const Icon(Icons.email),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _showChangePasswordDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              minimumSize: const Size.fromHeight(50),
            ),
            child: const Text('Change Password'),
          ),
          const Divider(),

          const ListTile(
            leading: Icon(Icons.privacy_tip),
            title: Text('Privacy Policy'),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('About SpendSense'),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
        ],
      ),
    );
  }
}
