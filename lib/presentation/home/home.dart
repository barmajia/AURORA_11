import 'package:flutter/material.dart';
import 'package:aurora/core/widgets/drawer.dart';

class Homepapge extends StatelessWidget {
  const Homepapge({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aurora')),
      drawer: const FixidDrawer(),
      body: const Center(child: Text('Home')),
    );
  }
}
