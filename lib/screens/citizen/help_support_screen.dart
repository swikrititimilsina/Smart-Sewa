import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'report_problem_screen.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      appBar: AppBar(
        title: const Text('Help & Support', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.navy,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.navy, AppColors.teal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'How can we help you?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Find answers or reach out to us below',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FAQ Card
                  _HelpCard(
                    icon: Icons.quiz_outlined,
                    iconColor: const Color(0xFF5C6BC0),
                    iconBg: const Color(0xFFE8EAF6),
                    title: 'Frequently Asked Questions',
                    subtitle: 'Find answers to the most common questions',
                    onTap: () => _showFAQ(context),
                  ),
                  const SizedBox(height: 14),

                  // App Guide Card
                  _HelpCard(
                    icon: Icons.menu_book_rounded,
                    iconColor: const Color(0xFF26A69A),
                    iconBg: const Color(0xFFE0F2F1),
                    title: 'App Guide',
                    subtitle: 'Learn how to use Smart Sewa step by step',
                    onTap: () => _showAppGuide(context),
                  ),
                  const SizedBox(height: 14),

                  // Report a Problem Card
                  _HelpCard(
                    icon: Icons.bug_report_outlined,
                    iconColor: const Color(0xFFEF6C00),
                    iconBg: const Color(0xFFFFF3E0),
                    title: 'Report a Problem',
                    subtitle: 'Submit a bug or issue you\'re facing',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReportProblemScreen()),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF6C00).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Go', style: TextStyle(fontSize: 11, color: Color(0xFFEF6C00), fontWeight: FontWeight.bold)),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Contact info footer
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.navy.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.navy.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.teal.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.info_outline, color: AppColors.teal, size: 22),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Smart Sewa Support', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.navy, fontSize: 14)),
                              SizedBox(height: 2),
                              Text('For further assistance, contact your nearest government service office.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFAQ(BuildContext context) {
    final faqs = [
      {
        'q': 'How do I apply for a service?',
        'a': 'Go to the Home tab and select the service you need (NID, Passport, Citizenship, Birth Certificate, etc.). Fill in the form and submit. You can track your application from the Documents tab.',
      },
      {
        'q': 'How long does approval take?',
        'a': 'Processing time varies by service. NID and Driving License typically take 7–14 working days. Passport applications may take 2–4 weeks. You will be notified once your status changes.',
      },
      {
        'q': 'What is biometric verification?',
        'a': 'If your application is approved, you may be required to visit a government office for biometric data collection (fingerprints, photo). The appointment date will be shown in your notification.',
      },
      {
        'q': 'How do I enable biometric login?',
        'a': 'Go to the hamburger menu (☰) → Settings & Privacy → Security → Turn on Biometric Login. You will be asked to confirm your password once.',
      },
      {
        'q': 'Can I edit a submitted application?',
        'a': 'Once an application is submitted, it cannot be edited. If there is an error, please report the problem via the Report a Problem section.',
      },
      {
        'q': 'How do I change my password?',
        'a': 'Go to the hamburger menu (☰) → Settings & Privacy → Change Password. Verify your current password, then set a new one.',
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(Icons.quiz_outlined, color: Color(0xFF5C6BC0)),
                    SizedBox(width: 10),
                    Text('Frequently Asked Questions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.navy)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: faqs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) => _FAQItem(q: faqs[i]['q']!, a: faqs[i]['a']!),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAppGuide(BuildContext context) {
    final steps = [
      {
        'icon': Icons.login_rounded,
        'color': const Color(0xFF5C6BC0),
        'title': 'Create an Account',
        'desc': 'Register with your Gmail address. Choose your role (Citizen) and complete the signup process.',
      },
      {
        'icon': Icons.home_rounded,
        'color': const Color(0xFF26A69A),
        'title': 'Explore the Home Screen',
        'desc': 'The Home screen shows all available government services. Tap any service card to begin an application.',
      },
      {
        'icon': Icons.edit_document,
        'color': const Color(0xFFEF6C00),
        'title': 'Submit an Application',
        'desc': 'Fill in the required details for your chosen service and submit. Make sure all information is accurate.',
      },
      {
        'icon': Icons.folder_open_rounded,
        'color': const Color(0xFF8E24AA),
        'title': 'Track via Documents Tab',
        'desc': 'The Documents tab shows all your submitted applications and their current status (Pending, In Review, Approved, Rejected).',
      },
      {
        'icon': Icons.notifications_active_rounded,
        'color': const Color(0xFFC62828),
        'title': 'Receive Notifications',
        'desc': 'You will receive real-time notifications when your application status changes or when admin announcements are posted.',
      },
      {
        'icon': Icons.fingerprint_rounded,
        'color': const Color(0xFF2E7D32),
        'title': 'Enable Biometric Login',
        'desc': 'For faster and more secure access, enable fingerprint or face login via Settings & Privacy.',
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(Icons.menu_book_rounded, color: Color(0xFF26A69A)),
                    SizedBox(width: 10),
                    Text('App Guide', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.navy)),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Getting started with Smart Sewa', style: TextStyle(fontSize: 13, color: Colors.grey)),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: steps.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final step = steps[i];
                    final color = step['color'] as Color;
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: color.withOpacity(0.15)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 38, height: 38,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(step['icon'] as IconData, color: color, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 20, height: 20,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                                      child: Text('${i + 1}', style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(step['title'] as String, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.navy)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(step['desc'] as String, style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.5)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const _HelpCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(13)),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.navy)),
                    const SizedBox(height: 3),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              trailing ?? const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.teal, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _FAQItem extends StatefulWidget {
  final String q;
  final String a;
  const _FAQItem({required this.q, required this.a});

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: _expanded ? const Color(0xFFE8EAF6) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _expanded ? const Color(0xFF5C6BC0).withOpacity(0.4) : Colors.grey.shade200,
          width: _expanded ? 1.5 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(widget.q, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.navy)),
                    ),
                    Icon(
                      _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFF5C6BC0),
                    ),
                  ],
                ),
                if (_expanded) ...[
                  const SizedBox(height: 10),
                  Text(widget.a, style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.6)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
