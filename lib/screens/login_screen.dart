import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/demo_credentials.dart';
import '../models/user_model.dart';
import '../widgets/logo_badge_widget.dart';
import 'citizen/citizen_dashboard_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import 'auth/forgot_password_screen.dart';
import 'auth/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  bool _isCitizen       = true;
  bool _obscurePassword = true;
  bool _isLoading       = false;
  String? _errorMessage;

  final _phoneController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  late AnimationController _cardController;
  late Animation<double> _cardOpacity;
  late Animation<Offset> _cardSlide;
  late AnimationController _tabController;

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..forward();
    _tabController  = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _cardOpacity = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOut));
    _cardSlide   = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _cardController.dispose();
    _tabController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _switchTab(bool toCitizen) {
    if (_isCitizen == toCitizen) return;
    setState(() { _isCitizen = toCitizen; _errorMessage = null; });
    _cardController.forward(from: 0);
  }

  Future<void> _handleLogin() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    await Future.delayed(const Duration(milliseconds: 1500));

    if (_isCitizen) {
      final phone    = _phoneController.text.trim();
      final password = _passwordController.text.trim();
      if (phone.isEmpty || password.isEmpty) {
        setState(() { _errorMessage = 'Please enter phone and password.'; _isLoading = false; });
        return;
      }
      if (phone == DemoCredentials.citizenPhone && password == DemoCredentials.citizenPassword) {
        UserSession.loggedInName  = DemoCredentials.citizenName;
        UserSession.loggedInPhone = phone;
        if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CitizenHomeScreen()));
      } else {
        setState(() { _errorMessage = 'Invalid phone number or password.'; _isLoading = false; });
      }
    } else {
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();
      if (username.isEmpty || password.isEmpty) {
        setState(() { _errorMessage = 'Please enter username and password.'; _isLoading = false; });
        return;
      }
      if (username == DemoCredentials.adminUsername && password == DemoCredentials.adminPassword) {
        UserSession.loggedInName = DemoCredentials.adminName;
        if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminHomeScreen()));
      } else {
        setState(() { _errorMessage = 'Invalid username or password.'; _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 32),
                        _buildTabSwitcher(),
                        const SizedBox(height: 36),
                        const LogoBadge(size: 110),
                        const SizedBox(height: 20),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _isCitizen
                              ? _buildGreeting(key: const ValueKey('c'), line1: 'Namaste! नमस्ते', line2: 'Access your local services.')
                              : _buildGreeting(key: const ValueKey('a'), line1: 'Admin Login', line2: 'Access your admin panel.'),
                        ),
                        const SizedBox(height: 28),
                        SlideTransition(
                          position: _cardSlide,
                          child: FadeTransition(opacity: _cardOpacity, child: _buildFormCard()),
                        ),
                        const Spacer(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        _tab(label: 'Citizen (नागरिक)', active: _isCitizen,  onTap: () => _switchTab(true),  isLeft: true),
        _tab(label: 'Admin (प्रशासक)',  active: !_isCitizen, onTap: () => _switchTab(false), isLeft: false),
      ]),
    );
  }

  Widget _tab({required String label, required bool active, required VoidCallback onTap, required bool isLeft}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.teal : Colors.transparent,
            borderRadius: BorderRadius.horizontal(
              left:  isLeft  ? const Radius.circular(12) : Radius.zero,
              right: !isLeft ? const Radius.circular(12) : Radius.zero,
            ),
          ),
          child: Text(label, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                  color: active ? Colors.white : AppColors.navy, letterSpacing: 0.2)),
        ),
      ),
    );
  }

  Widget _buildGreeting({required Key key, required String line1, required String line2}) {
    return Column(key: key, children: [
      Text(line1, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.navy)),
      const SizedBox(height: 4),
      Text(line2, style: TextStyle(fontSize: 13, color: AppColors.navy.withOpacity(0.75))),
    ]);
  }

  Widget _buildFormCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isCitizen) ...[
          _phoneField(),
          const SizedBox(height: 14),
        ] else ...[
          _inputField(icon: Icons.person_outline, hint: 'Enter Username', controller: _usernameController),
          const SizedBox(height: 14),
        ],
        _inputField(
          icon: Icons.lock_outline,
          hint: 'Enter Password',
          controller: _passwordController,
          obscure: _obscurePassword,
          suffix: IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.navy.withOpacity(0.5), size: 20),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(_errorMessage!, style: const TextStyle(fontSize: 12, color: Colors.red))),
            ]),
          ),
        ],
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity, height: 52,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF3A8FE8), Color(0xFF3DAA5C)]),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [BoxShadow(color: const Color(0xFF3A8FE8).withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: _isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : const Text('LOGIN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1.2)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
              child: const Text('Forgot Password?', style: TextStyle(fontSize: 12, color: AppColors.navy, fontWeight: FontWeight.w500)),
            ),
            if (_isCitizen)
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                child: const Text('Register/Create Account', style: TextStyle(fontSize: 12, color: AppColors.navy, fontWeight: FontWeight.w500)),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.navy.withOpacity(0.15)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Demo Credentials', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.navy)),
            const SizedBox(height: 4),
            if (_isCitizen) ...[
              Text('Phone: ${DemoCredentials.citizenPhone}',       style: TextStyle(fontSize: 11, color: AppColors.navy.withOpacity(0.8))),
              Text('Password: ${DemoCredentials.citizenPassword}', style: TextStyle(fontSize: 11, color: AppColors.navy.withOpacity(0.8))),
            ] else ...[
              Text('Username: ${DemoCredentials.adminUsername}',   style: TextStyle(fontSize: 11, color: AppColors.navy.withOpacity(0.8))),
              Text('Password: ${DemoCredentials.adminPassword}',   style: TextStyle(fontSize: 11, color: AppColors.navy.withOpacity(0.8))),
            ],
          ]),
        ),
      ],
    );
  }

  Widget _phoneField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(children: [
        const SizedBox(width: 16),
        Icon(Icons.phone_outlined, color: AppColors.navy.withOpacity(0.5), size: 20),
        const SizedBox(width: 8),
        const Text('+977 ', style: TextStyle(fontSize: 13, color: AppColors.navy, fontWeight: FontWeight.w500)),
        Expanded(
          child: TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(fontSize: 14, color: AppColors.navy),
            decoration: InputDecoration(
              hintText: 'Enter 10-digit Mobile Number',
              hintStyle: TextStyle(fontSize: 13, color: AppColors.navy.withOpacity(0.45)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _inputField({
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
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14, color: AppColors.navy),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.navy.withOpacity(0.5), size: 20),
          hintText: hint,
          hintStyle: TextStyle(fontSize: 13, color: AppColors.navy.withOpacity(0.45)),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
