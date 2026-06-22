import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/user_session.dart';
import '../../widgets/service_tile.dart';
import '../auth/login_screen.dart';

// ── Admin menu sheet ──
class _AdminMenuSheet extends StatelessWidget {
  final VoidCallback onLogout;
  const _AdminMenuSheet({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.shield_outlined, color: AppColors.navy),
            title: const Text('Settings & Privacy',
                style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.navy)),
            onTap: () => Navigator.pop(context),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            title: const Text('Log Out',
                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red)),
            onTap: onLogout,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── Main screen ──
class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AdminMenuSheet(onLogout: () => _confirmLogout(context)),
    );
  }

  void _confirmLogout(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Out',
            style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.navy)),
        content: const Text('Do you want to log out?',
            style: TextStyle(color: AppColors.navy)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No',
                style: TextStyle(color: AppColors.teal, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              UserSession.loggedInName = '';
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Yes',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // ── Top bar ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Smart Sewa',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.navy)),
                        Text('Admin Panel',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.teal,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: AppColors.navy,
                          borderRadius: BorderRadius.circular(50)),
                      child: IconButton(
                        onPressed: () => _showMenu(context),
                        icon: const Icon(Icons.menu, color: Colors.white),
                        tooltip: 'Menu',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${UserSession.loggedInName}! 👋',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Manage citizen applications and services.',
                        style: TextStyle(fontSize: 13, color: AppColors.navy),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),
                const Text('Admin Tools',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy)),
                const SizedBox(height: 16),

                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    children: const [
                      ServiceTile(icon: Icons.folder_open_outlined,          label: 'Review\nApplications'),
                      ServiceTile(icon: Icons.people_outline,                label: 'Manage\nCitizens'),
                      ServiceTile(icon: Icons.notifications_active_outlined, label: 'Send\nNotice'),
                      ServiceTile(icon: Icons.storage_rounded,               label: 'Database'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}