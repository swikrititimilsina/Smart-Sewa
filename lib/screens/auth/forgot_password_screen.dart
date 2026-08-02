import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/app_colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
              const SizedBox(height: 20),
              const Text('Forgot Password',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.navy)),
              const SizedBox(height: 8),
              Text('Enter your registered email address.',
                  style: TextStyle(fontSize: 13, color: AppColors.navy.withOpacity(0.7))),
              const SizedBox(height: 40),
              _buildField(icon: Icons.email_outlined, hint: 'Registered Email Address',
                  controller: _emailController, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 24),
              _buildButton(
                label: 'Send Reset Link',
                isLoading: _isLoading,
                onPressed: () async {
                  final email = _emailController.text.trim();
                  if (email.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your email')));
                    return;
                  }
                  
                  setState(() => _isLoading = true);
                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password reset link sent to your email!'), backgroundColor: AppColors.teal),
                      );
                      Future.delayed(const Duration(seconds: 2), () {
                        if (mounted) Navigator.pop(context);
                      });
                    }
                  } on FirebaseAuthException catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.message ?? 'Failed to send reset link'), backgroundColor: Colors.red),
                      );
                    }
                  } finally {
                    if (mounted) setState(() => _isLoading = false);
                  }
                },
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    bool obscure = false,
    Widget? suffix,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: TextField(
        controller: controller, obscureText: obscure, keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14, color: AppColors.navy),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.navy.withOpacity(0.5), size: 20),
          hintText: hint,
          hintStyle: TextStyle(fontSize: 13, color: AppColors.navy.withOpacity(0.45)),
          suffixIcon: suffix, border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildButton({required String label, required VoidCallback onPressed, bool isLoading = false}) {
    return SizedBox(
      width: double.infinity, height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF3A8FE8), Color(0xFF3DAA5C)]),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: const Color(0xFF3A8FE8).withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
          child: isLoading 
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1.0)),
        ),
      ),
    );
  }
}
