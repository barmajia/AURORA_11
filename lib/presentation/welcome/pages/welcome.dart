import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.storefront, size: 80, color: Color(0xFF6366F1)),
            const SizedBox(height: 24),
            const Text('Welcome to Aurora', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Choose your account type', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            const SizedBox(height: 48),
            _RoleCard(icon: Icons.store, title: 'Seller', subtitle: 'I want to sell products',
              onTap: () => Navigator.of(context).pushNamed('/seller-login')),
            const SizedBox(height: 16),
            _RoleCard(icon: Icons.factory, title: 'Factory', subtitle: 'I manufacture products',
              onTap: () => Navigator.of(context).pushNamed('/factory-login')),
          ]),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon; final String title; final String subtitle; final VoidCallback onTap;
  const _RoleCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12),
      child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [Icon(icon, size: 32, color: Theme.of(context).primaryColor),
          const SizedBox(width: 16), Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(subtitle, style: TextStyle(color: Colors.grey[600]))])]),
      ),
    );
  }
}
