import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _phoneController       = TextEditingController();
  final _otpController         = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _otpSent    = false;
  bool _obscureNew = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
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
              Text('Enter your registered mobile number.',
                  style: TextStyle(fontSize: 13, color: AppColors.navy.withOpacity(0.7))),
              const SizedBox(height: 40),
              _buildField(icon: Icons.phone_outlined, hint: 'Registered Mobile Number',
                  controller: _phoneController, keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              if (!_otpSent)
                _buildButton(label: 'Send OTP', onPressed: () => setState(() => _otpSent = true)),
              if (_otpSent) ...[
                const SizedBox(height: 16),
                _buildField(icon: Icons.lock_clock_outlined, hint: 'Enter OTP (demo: 1234)',
                    controller: _otpController, keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                _buildField(
                  icon: Icons.lock_outline,
                  hint: 'New Password',
                  controller: _newPasswordController,
                  obscure: _obscureNew,
                  suffix: IconButton(
                    icon: Icon(_obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.navy.withOpacity(0.5), size: 20),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
                const SizedBox(height: 24),
                _buildButton(
                  label: 'Reset Password',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password reset successful!'), backgroundColor: AppColors.teal),
                    );
                    Future.delayed(const Duration(seconds: 1), () => Navigator.pop(context));
                  },
                ),
              ],
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

  Widget _buildButton({required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity, height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF3A8FE8), Color(0xFF3DAA5C)]),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: const Color(0xFF3A8FE8).withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
          child: Text(label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1.0)),
        ),
      ),
    );
  }
}