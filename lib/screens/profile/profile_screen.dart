import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      if (!context.mounted) return;
      await context.read<AuthProvider>().logout();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : const Color(0xFFF3F4F6);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 32),
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Theme.of(
                  context,
                ).primaryColor.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              user?.fullName ?? 'Guest User',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              user?.email ?? 'No email provided',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.badge, color: Colors.blue),
                    title: const Text('Role'),
                    subtitle: Text(user?.role ?? 'N/A'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.business, color: Colors.orange),
                    title: const Text('Department'),
                    subtitle: Text(user?.department ?? 'N/A'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.settings, color: Colors.green),
                    title: const Text('Settings'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to settings if needed
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _handleLogout(context),
                icon: const Icon(Icons.logout),
                label: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
