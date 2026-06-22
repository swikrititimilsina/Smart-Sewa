import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/user_session.dart';
import '../../widgets/logo_badge.dart';
import '../citizen/citizen_home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController            = TextEditingController();
  final _phoneController           = TextEditingController();
  final _emailController           = TextEditingController();
  final _passwordController        = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePass    = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 20),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.navy),
              ),
              const SizedBox(height: 10),
              const Center(child: LogoBadge(size: 80)),
              const SizedBox(height: 20),
              const Center(child: Text('Create Account',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.navy))),
              const SizedBox(height: 6),
              Center(child: Text('Register to access Smart Sewa services',
                  style: TextStyle(fontSize: 13, color: AppColors.navy.withOpacity(0.7)))),
              const SizedBox(height: 32),
              _buildField(icon: Icons.person_outline, hint: 'Full Name', controller: _nameController),
              const SizedBox(height: 14),
              _buildField(icon: Icons.phone_outlined, hint: 'Mobile Number (+977)',
                  controller: _phoneController, keyboardType: TextInputType.phone),
              const SizedBox(height: 14),
              _buildField(icon: Icons.email_outlined, hint: 'Email Address (Optional)',
                  controller: _emailController, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 14),
              _buildField(
                icon: Icons.lock_outline, hint: 'Password', controller: _passwordController,
                obscure: _obscurePass,
                suffix: IconButton(
                  icon: Icon(_obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.navy.withOpacity(0.5), size: 20),
                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                ),
              ),
              const SizedBox(height: 14),
              _buildField(
                icon: Icons.lock_outline, hint: 'Confirm Password', controller: _confirmPasswordController,
                obscure: _obscureConfirm,
                suffix: IconButton(
                  icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.navy.withOpacity(0.5), size: 20),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity, height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF3A8FE8), Color(0xFF3DAA5C)]),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [BoxShadow(color: const Color(0xFF3A8FE8).withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      final name = _nameController.text.trim();
                      if (name.isNotEmpty) {
                        UserSession.loggedInName  = name;
                        UserSession.loggedInPhone = _phoneController.text.trim();
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Account created successfully!'), backgroundColor: AppColors.teal),
                      );
                      Future.delayed(const Duration(seconds: 1), () {
                        if (mounted) {
                          Navigator.pushAndRemoveUntil(context,
                            MaterialPageRoute(builder: (_) => const CitizenHomeScreen()), (route) => false);
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                    child: const Text('CREATE ACCOUNT',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1.0)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('Already have an account? ', style: TextStyle(fontSize: 13, color: AppColors.navy.withOpacity(0.7))),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text('Login', style: TextStyle(fontSize: 13, color: AppColors.teal, fontWeight: FontWeight.w700)),
                ),
              ]),
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required IconData icon, required String hint, required TextEditingController controller,
    bool obscure = false, Widget? suffix, TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))]),
      child: TextField(
        controller: controller, obscureText: obscure, keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14, color: AppColors.navy),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.navy.withOpacity(0.5), size: 20),
          hintText: hint, hintStyle: TextStyle(fontSize: 13, color: AppColors.navy.withOpacity(0.45)),
          suffixIcon: suffix, border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}