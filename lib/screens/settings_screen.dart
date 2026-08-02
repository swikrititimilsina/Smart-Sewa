import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_colors.dart';
import '../../services/biometric_service.dart';
import '../../models/user_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _isBiometricEnabled = false;
  bool _isBiometricAvailable = false;
  bool _isLoading = false;
  bool _isCurrentPassVerified = false;  // tracks if step 1 is done
  bool _isVerifyingPass = false;        // loading just for step 1
  String? _passVerifyError;             // error msg under current password field

  bool _obscureCurrentPass = true;
  bool _obscureNewPass = true;
  bool _obscureConfirmPass = true;
  
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _nameController.text = UserSession.loggedInName;
    _checkBiometricStatus();
  }

  Future<void> _checkBiometricStatus() async {
    if (user == null || user!.email == null) return;
    final available = await BiometricService.isBiometricAvailable();
    final enabled = await BiometricService.isBiometricEnabled(user!.email!);
    setState(() {
      _isBiometricAvailable = available;
      _isBiometricEnabled = enabled;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (user == null) return;
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await user!.updateDisplayName(newName);
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({'name': newName});
      UserSession.loggedInName = newName;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyCurrentPassword() async {
    if (user == null || user!.email == null) return;
    final currentPass = _currentPassController.text.trim();
    if (currentPass.isEmpty) {
      setState(() => _passVerifyError = 'Please enter your current password.');
      return;
    }
    setState(() { _isVerifyingPass = true; _passVerifyError = null; });
    try {
      final credential = EmailAuthProvider.credential(email: user!.email!, password: currentPass);
      await user!.reauthenticateWithCredential(credential);
      setState(() => _isCurrentPassVerified = true);
    } on FirebaseAuthException catch (_) {
      setState(() => _passVerifyError = 'Incorrect password. Please try again.');
    } finally {
      if (mounted) setState(() => _isVerifyingPass = false);
    }
  }

  Future<void> _changePassword() async {
    if (user == null || user!.email == null) return;
    
    final currentPass = _currentPassController.text.trim();
    final newPass = _newPassController.text.trim();
    final confirmPass = _confirmPassController.text.trim();

    if (newPass.isEmpty || confirmPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all password fields')));
      return;
    }
    if (newPass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('New password must be at least 6 characters')));
      return;
    }
    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('New passwords do not match')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Re-authenticate with already verified current password
      final credential = EmailAuthProvider.credential(email: user!.email!, password: currentPass);
      await user!.reauthenticateWithCredential(credential);
      await user!.updatePassword(newPass);
      
      // Update biometric saved credentials if enabled
      if (_isBiometricEnabled) {
        await BiometricService.saveCredentials(user!.email!, newPass);
      }

      _currentPassController.clear();
      _newPassController.clear();
      _confirmPassController.clear();
      setState(() => _isCurrentPassVerified = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password changed successfully'), backgroundColor: Colors.green));
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Password change failed'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (user == null || user!.email == null) return;

    if (!value) {
      // Turning off
      await BiometricService.setBiometricEnabled(user!.email!, false);
      setState(() => _isBiometricEnabled = false);
      return;
    }

    // Turning on: Require password so we can save it to secure storage for auto-login
    String tempPass = '';
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Enable Biometric Login', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please enter your current password to enable biometric login.', style: TextStyle(fontSize: 13)),
              const SizedBox(height: 12),
              TextField(
                obscureText: true,
                onChanged: (val) => tempPass = val,
                decoration: InputDecoration(
                  hintText: 'Current Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Verify', style: TextStyle(color: AppColors.teal, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    if (result != true || tempPass.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      // Verify password is correct
      final credential = EmailAuthProvider.credential(email: user!.email!, password: tempPass);
      await user!.reauthenticateWithCredential(credential);

      // Now authenticate via biometric hardware
      final authSuccess = await BiometricService.authenticate();
      if (authSuccess) {
        await BiometricService.saveCredentials(user!.email!, tempPass);
        await BiometricService.setBiometricEnabled(user!.email!, true);
        setState(() => _isBiometricEnabled = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Biometric login enabled!'), backgroundColor: Colors.green));
        }
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Biometric authentication failed or canceled.')));
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Authentication failed'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      appBar: AppBar(
        title: const Text('Settings & Privacy', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.navy,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Profile Settings'),
                _buildCard(
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: TextEditingController(text: user?.email ?? ''),
                        enabled: false,
                        decoration: const InputDecoration(labelText: 'Email Address (Read-only)', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _updateProfile,
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal, padding: const EdgeInsets.symmetric(vertical: 14)),
                          child: const Text('Update Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                _buildSectionTitle('Change Password'),
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Step 1: Enter current password
                      TextField(
                        controller: _currentPassController,
                        obscureText: _obscureCurrentPass,
                        enabled: !_isCurrentPassVerified,
                        decoration: InputDecoration(
                          labelText: 'Current Password',
                          border: const OutlineInputBorder(),
                          suffixIcon: _isCurrentPassVerified
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : IconButton(
                                  icon: Icon(_obscureCurrentPass ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                                  onPressed: () => setState(() => _obscureCurrentPass = !_obscureCurrentPass),
                                ),
                          errorText: _passVerifyError,
                        ),
                      ),
                      if (!_isCurrentPassVerified) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isVerifyingPass ? null : _verifyCurrentPassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.teal,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: _isVerifyingPass
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Verify Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                      // Step 2: Shown only after verification
                      if (_isCurrentPassVerified) ...[
                        const SizedBox(height: 8),
                        const Text('✓ Password verified. Set your new password below.', style: TextStyle(fontSize: 12, color: Colors.green)),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _newPassController,
                          obscureText: _obscureNewPass,
                          decoration: InputDecoration(
                            labelText: 'New Password', 
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureNewPass ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                              onPressed: () => setState(() => _obscureNewPass = !_obscureNewPass),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _confirmPassController,
                          obscureText: _obscureConfirmPass,
                          decoration: InputDecoration(
                            labelText: 'Confirm New Password', 
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureConfirmPass ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                              onPressed: () => setState(() => _obscureConfirmPass = !_obscureConfirmPass),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _changePassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.navy,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Change Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                _buildSectionTitle('Security'),
                _buildCard(
                  child: SwitchListTile(
                    title: const Text('Biometric Login', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy)),
                    subtitle: const Text('Use Fingerprint or Face ID to login', style: TextStyle(fontSize: 12)),
                    value: _isBiometricEnabled,
                    activeColor: AppColors.teal,
                    onChanged: _isBiometricAvailable ? _toggleBiometric : null,
                    secondary: const Icon(Icons.fingerprint, size: 32, color: AppColors.navy),
                  ),
                ),
                if (!_isBiometricAvailable)
                   Padding(
                     padding: const EdgeInsets.only(top: 8.0, left: 16.0),
                     child: Text('Biometric hardware is not available on this device.', style: TextStyle(fontSize: 12, color: Colors.red.withOpacity(0.8))),
                   )
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator(color: AppColors.teal)),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navy)),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }
}
