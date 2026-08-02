import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_colors.dart';
import '../../models/user_model.dart';
import '../../widgets/logo_badge_widget.dart';
import '../citizen/citizen_dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController            = TextEditingController();
  final _emailController           = TextEditingController();
  final _passwordController        = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePass    = true;
  bool _obscureConfirm = true;
  bool _isLoading      = false;

  @override
  void dispose() {
    _nameController.dispose();
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
              _buildField(icon: Icons.email_outlined, hint: 'Email Address',
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
                    onPressed: _isLoading ? null : () async {
                      final name = _nameController.text.trim();
                      final email = _emailController.text.trim();
                      final pass = _passwordController.text.trim();
                      final conf = _confirmPasswordController.text.trim();

                      if (email.isEmpty || pass.isEmpty || name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
                        return;
                      }
                      if (pass != conf) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
                        return;
                      }

                      setState(() => _isLoading = true);
                      try {
                        final userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                          email: email,
                          password: pass,
                        );
                        
                        if (userCred.user != null) {
                          // Update Firebase Auth profile so displayName is always available as fallback
                          await userCred.user!.updateDisplayName(name);
                          
                          await FirebaseFirestore.instance.collection('users').doc(userCred.user!.uid).set({
                            'name': name,
                            'email': email,
                            'role': 'citizen',
                            'createdAt': FieldValue.serverTimestamp(),
                          });
                        }
                        
                        UserSession.loggedInName  = name;
                        UserSession.loggedInPhone = email; // Fallback for display
                        
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Account created successfully!'), backgroundColor: AppColors.teal),
                          );
                          Navigator.pushAndRemoveUntil(context,
                            MaterialPageRoute(builder: (_) => const CitizenHomeScreen()), (route) => false);
                        }
                      } on FirebaseAuthException catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.message ?? 'Registration failed'), backgroundColor: Colors.red),
                          );
                        }
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                    child: _isLoading 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('CREATE ACCOUNT',
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
