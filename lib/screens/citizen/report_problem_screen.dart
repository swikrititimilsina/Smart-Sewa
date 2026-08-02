import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/app_colors.dart';
import '../../models/user_model.dart';

class ReportProblemScreen extends StatefulWidget {
  const ReportProblemScreen({super.key});

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedCategory;
  File? _screenshotFile;
  bool _isSubmitting = false;

  final List<String> _categories = [
    'App Crashing',
    'Document Upload Failed',
    'Payment Issue',
    'Login / Authentication Problem',
    'Notification Not Working',
    'Application Status Error',
    'Slow Performance',
    'Other',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickScreenshot() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 1200,
      imageQuality: 50, // compress to keep under Firestore 1MB limit
    );
    if (picked != null) {
      setState(() => _screenshotFile = File(picked.path));
    }
  }

  Future<String?> _encodeScreenshot() async {
    if (_screenshotFile == null) return null;
    final bytes = await _screenshotFile!.readAsBytes();
    if (bytes.lengthInBytes > 900000) {
      // Safety check: > 900KB is too large for Firestore
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Screenshot is too large. Please pick a smaller image.'), backgroundColor: Colors.orange),
        );
      }
      return null;
    }
    return base64Encode(bytes);
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final screenshotBase64 = await _encodeScreenshot();

      await FirebaseFirestore.instance.collection('problem_reports').add({
        'citizenId': user?.uid ?? '',
        'citizenEmail': user?.email ?? '',
        'citizenName': UserSession.loggedInName,
        'category': _selectedCategory,
        'description': _descriptionController.text.trim(),
        'screenshotBase64': screenshotBase64,
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      appBar: AppBar(
        title: const Text('Report a Problem', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.navy,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.teal.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.teal, size: 20),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Your report will be reviewed by the admin team. Please provide as much detail as possible.',
                            style: TextStyle(fontSize: 12, color: AppColors.navy),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Category dropdown
                  _buildSectionLabel('Issue Category *'),
                  _buildCard(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      hint: const Text('Select a category', style: TextStyle(color: Colors.grey)),
                      decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero),
                      icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.navy),
                      items: _categories.map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat, style: const TextStyle(fontSize: 14, color: AppColors.navy)),
                      )).toList(),
                      onChanged: (val) => setState(() => _selectedCategory = val),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  _buildSectionLabel('Describe the Problem *'),
                  _buildCard(
                    child: TextFormField(
                      controller: _descriptionController,
                      maxLines: 6,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please describe the issue' : null,
                      decoration: const InputDecoration(
                        hintText: 'e.g. When I try to upload my document, the app shows an error...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Screenshot
                  _buildSectionLabel('Attach Screenshot (Optional)'),
                  GestureDetector(
                    onTap: _pickScreenshot,
                    child: Container(
                      width: double.infinity,
                      height: _screenshotFile != null ? null : 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _screenshotFile != null ? AppColors.teal : Colors.grey.shade300,
                          width: _screenshotFile != null ? 2 : 1.5,
                          style: BorderStyle.solid,
                        ),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
                      ),
                      child: _screenshotFile != null
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.file(_screenshotFile!, width: double.infinity, fit: BoxFit.cover),
                                ),
                                Positioned(
                                  top: 8, right: 8,
                                  child: GestureDetector(
                                    onTap: () => setState(() => _screenshotFile = null),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                      child: const Icon(Icons.close, color: Colors.white, size: 16),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined, size: 36, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Tap to attach a screenshot', style: TextStyle(color: Colors.grey, fontSize: 13)),
                                Text('(JPG, PNG — max ~900KB)', style: TextStyle(color: Colors.grey, fontSize: 11)),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submitReport,
                      icon: const Icon(Icons.send_rounded, color: Colors.white),
                      label: const Text('Submit Report', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          if (_isSubmitting)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator(color: AppColors.teal)),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.navy)),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: child,
    );
  }
}
