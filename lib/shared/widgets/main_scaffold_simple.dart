import 'package:flutter/material.dart';

class MainScaffoldSimple extends StatelessWidget {
  final Widget child;

  const MainScaffoldSimple({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Futbol App',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        centerTitle: true,
      ),
      body: child,
    );
  }
}
