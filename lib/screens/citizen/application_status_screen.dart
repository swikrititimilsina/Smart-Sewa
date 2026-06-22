import 'package:flutter/material.dart';

class ApplicationStatusScreen extends StatelessWidget {
  const ApplicationStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Application Status')),
      body: const Center(child: Text('Application Status Under Construction')),
    );
  }
}
