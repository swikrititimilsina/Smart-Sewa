import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_colors.dart';
import '../widgets/logo_badge_widget.dart';
import '../widgets/arc_spinner_widget.dart';
import 'login_screen.dart';
import '../models/user_model.dart';
import 'admin/admin_dashboard_screen.dart';
import 'citizen/citizen_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _spinnerController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _logoController    = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _textController    = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _spinnerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();

    _logoScale   = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _logoController, curve: Curves.elasticOut));
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _logoController, curve: const Interval(0, 0.4)));
    _textOpacity = Tween<double>(begin: 0, end: 1).animate(_textController);
    _textSlide   = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 500), () => _textController.forward());
    Future.delayed(const Duration(milliseconds: 3200), () {
      _checkAuthAndRoute();
    });
  }

  Future<void> _checkAuthAndRoute() async {
    try {
      // Wait for Firebase Auth to restore session — currentUser is null briefly on cold start
      final user = await FirebaseAuth.instance.authStateChanges().first;

      if (user == null) {
        _routeTo(const LoginScreen());
        return;
      }

      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final role = data['role'] ?? 'citizen';
        UserSession.loggedInName = data['name'] ?? user.email?.split('@')[0] ?? '';
        UserSession.loggedInPhone = user.email ?? '';

        if (role == 'admin') {
          _routeTo(const AdminHomeScreen());
        } else {
          _routeTo(const CitizenHomeScreen());
        }
      } else {
        // Fallback if no Firestore doc
        UserSession.loggedInName = user.displayName ?? user.email?.split('@')[0] ?? '';
        UserSession.loggedInPhone = user.email ?? '';
        bool isAdmin = (user.email?.toLowerCase() == 'admin@smartsewa.com');
        _routeTo(isAdmin ? const AdminHomeScreen() : const CitizenHomeScreen());
      }
    } catch (e) {
      _routeTo(const LoginScreen());
    }
  }

  void _routeTo(Widget screen) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _spinnerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _logoController,
                builder: (_, __) => Opacity(
                  opacity: _logoOpacity.value,
                  child: Transform.scale(scale: _logoScale.value, child: const LogoBadge(size: 160)),
                ),
              ),
              const SizedBox(height: 28),
              SlideTransition(
                position: _textSlide,
                child: FadeTransition(
                  opacity: _textOpacity,
                  child: Column(children: [
                    RichText(
                      text: const TextSpan(children: [
                        TextSpan(
                          text: 'Smart ',
                          style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: AppColors.navy, letterSpacing: 0.5),
                        ),
                        TextSpan(
                          text: 'Sewa',
                          style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: AppColors.green, letterSpacing: 0.5),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'SMART GOVERNMENT SERVICE ASSISTANT',
                      style: TextStyle(fontSize: 10, letterSpacing: 2.0, color: AppColors.navy, fontWeight: FontWeight.w500),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 60),
              FadeTransition(
                opacity: _textOpacity,
                child: AnimatedBuilder(
                  animation: _spinnerController,
                  builder: (_, __) => CustomPaint(
                    size: const Size(40, 40),
                    painter: ArcSpinnerPainter(progress: _spinnerController.value),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FadeTransition(
                opacity: _textOpacity,
                child: const Text(
                  'Loading services...',
                  style: TextStyle(fontSize: 13, color: AppColors.navy, fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
