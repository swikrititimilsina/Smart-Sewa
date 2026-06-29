import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_colors.dart';
import '../../models/user_model.dart';
import '../../widgets/service_card_widget.dart';
import '../../widgets/nav_item_widget.dart';
import '../login_screen.dart';
import 'documents_screen.dart';
import 'notifications_screen.dart';
import 'chat_screen.dart';
import 'citizenship_redirect_screen.dart';
import 'generic_redirect_screen.dart';

enum _ServiceState { nid, citizenship, birthReg, passport, disabled }

// ── Menu item model ──
class _MenuItem {
  final IconData icon;
  final String label;
  final bool isDestructive;
  const _MenuItem({required this.icon, required this.label, this.isDestructive = false});
}

// ── Bottom sheet widget ──
class _MenuSheet extends StatelessWidget {
  final List<_MenuItem> items;
  final VoidCallback onLogout;
  const _MenuSheet({required this.items, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),
          ...items.map((item) => ListTile(
            leading: Icon(item.icon, color: item.isDestructive ? Colors.red : AppColors.navy),
            title: Text(
              item.label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: item.isDestructive ? Colors.red : AppColors.navy,
              ),
            ),
            onTap: item.isDestructive ? onLogout : () => Navigator.pop(context),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── Main screen ──
class CitizenHomeScreen extends StatefulWidget {
  const CitizenHomeScreen({super.key});

  @override
  State<CitizenHomeScreen> createState() => _CitizenHomeScreenState();
}

class _CitizenHomeScreenState extends State<CitizenHomeScreen> {
  int _currentIndex = 0;
  int _unreadCount = 0;
  DateTime _lastViewedAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Listen to general_notices and count those newer than _lastViewedAt
    FirebaseFirestore.instance
        .collection('general_notices')
        .orderBy('postedAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      if (!mounted) return;
      final count = snapshot.docs.where((doc) {
        final ts = (doc.data())['postedAt'] as Timestamp?;
        if (ts == null) return false;
        return ts.toDate().isAfter(_lastViewedAt);
      }).length;
      setState(() => _unreadCount = count);
    });
  }

  void _onNotificationsViewed() {
    setState(() {
      _lastViewedAt = DateTime.now();
      _unreadCount = 0;
    });
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _MenuSheet(
        items: const [
          _MenuItem(icon: Icons.shield_outlined,      label: 'Settings & Privacy'),
          _MenuItem(icon: Icons.flag_outlined,         label: 'Report a Problem'),
          _MenuItem(icon: Icons.help_outline_rounded,  label: 'Help & Support'),
          _MenuItem(icon: Icons.logout_rounded,        label: 'Log Out', isDestructive: true),
        ],
        onLogout: () => _confirmLogout(context),
      ),
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
              UserSession.loggedInName  = '';
              UserSession.loggedInPhone = '';
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
    final List<Widget> pages = [
      const _HomeContent(),
      const DocumentsScreen(),
      NotificationsScreen(onViewed: _onNotificationsViewed),
    ];

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
                // ── Page body ──
                Expanded(child: pages[_currentIndex]),

                // ── Bottom Nav ──
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _currentIndex = 0),
                        child: NavItem(
                          icon: Icons.home_rounded,
                          label: 'Home',
                          active: _currentIndex == 0,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _currentIndex = 1),
                        child: NavItem(
                          icon: Icons.folder_outlined,
                          label: 'Documents',
                          active: _currentIndex == 1,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _currentIndex = 2),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            NavItem(
                              icon: Icons.notifications_outlined,
                              label: 'Notifications',
                              active: _currentIndex == 2,
                            ),
                            if (_unreadCount > 0)
                              Positioned(
                                right: -4,
                                top: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                      minWidth: 18, minHeight: 18),
                                  child: Text(
                                    _unreadCount > 9
                                        ? '9+'
                                        : '$_unreadCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
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

// ── Home tab as its own widget so it can access context via the State ──
class _HomeContent extends StatelessWidget {
  const _HomeContent();

  static const Map<String, _ServiceState> _serviceRoutes = {
    'NID': _ServiceState.nid,
    'Citizenship': _ServiceState.citizenship,
    'Birth Registration': _ServiceState.birthReg,
    'Passport': _ServiceState.passport,
  };

  void _handleServiceTap(BuildContext context, String label) {
    final state = _serviceRoutes[label];
    switch (state) {
      case _ServiceState.nid:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const GenericRedirectScreen(serviceType: ServiceType.nid)));
        break;
      case _ServiceState.citizenship:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CitizenshipRedirectScreen()));
        break;
      case _ServiceState.birthReg:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const GenericRedirectScreen(serviceType: ServiceType.birthReg)));
        break;
      case _ServiceState.passport:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const GenericRedirectScreen(serviceType: ServiceType.passport)));
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access parent state for menu & logout via context
    final state = context.findAncestorStateOfType<_CitizenHomeScreenState>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        // ── Top bar ──
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: AppColors.teal, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.navy.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.person_rounded, color: AppColors.navy, size: 30),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi, ${UserSession.loggedInName}',
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.navy),
                  ),
                  const Text('Welcome back!',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.teal, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  color: AppColors.navy, borderRadius: BorderRadius.circular(50)),
              child: IconButton(
                onPressed: () => state._showMenu(context),
                icon: const Icon(Icons.menu, color: Colors.white),
                tooltip: 'Menu',
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),
        const Text('Services',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.navy)),
        const SizedBox(height: 16),

        // ── Service Grid ──
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.05,
            children: [
              GestureDetector(onTap: () => _handleServiceTap(context, 'NID'), child: const ServiceTile(icon: Icons.credit_card_rounded, label: 'NID')),
              GestureDetector(onTap: () => _handleServiceTap(context, 'Birth Registration'), child: const ServiceTile(icon: Icons.child_care_rounded, label: 'Birth Registration')),
              GestureDetector(onTap: () => _handleServiceTap(context, 'Citizenship'), child: const ServiceTile(icon: Icons.account_balance_outlined, label: 'Citizenship')),
              GestureDetector(onTap: () => _handleServiceTap(context, 'Passport'), child: const ServiceTile(icon: Icons.language_rounded, label: 'Passport')),
            ],
          ),
        ),

        // ── Chat button ──
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Center(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatScreen()),
                );
              },
              icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
              label: const Text('Chat with Smart Sathi',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
