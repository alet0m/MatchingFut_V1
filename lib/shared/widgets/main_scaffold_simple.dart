import 'package:flutter/material.dart';

class MainScaffoldSimple extends StatelessWidget {
  final Widget child;

  const MainScaffoldSimple({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Futbol App',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: scheme.onPrimary,
          ),
        ),
        backgroundColor: scheme.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: child,
    );
  }
}
