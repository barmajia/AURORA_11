import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aurora/storage/userStorage.dart';
import 'package:aurora/users/account_type.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userStorage = Provider.of<UserStorage>(context, listen: false);
      userStorage.loadUser(AccountType.seller);
    });
  }

  String _getAccountTypeName(AccountType? accountType) {
    if (accountType == null) return 'Unknown';
    switch (accountType) {
      case AccountType.seller:
        return 'Seller';
      case AccountType.factory:
        return 'Factory';
      case AccountType.customser:
        return 'Customer';
      case AccountType.middleman:
        return 'Middle Man';
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Logout')),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
          ),
        ],
      ),
      body: Consumer<UserStorage>(
        builder: (context, userStorage, _) {
          final user = userStorage.currentUser;
          final isSeller = user?.accountType == AccountType.seller;
          final isFactory = user?.accountType == AccountType.factory;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFF6366F1),
                child: Text(
                  user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user?.name ?? 'No Name',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                user?.email ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Chip(
                label: Text(_getAccountTypeName(user?.accountType)),
                backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.2),
              ),
              const SizedBox(height: 24),
              if (isSeller) ...[
                _buildInfoTile(Icons.store, 'Location', user?.metadata?['location'] ?? 'Not set'),
                _buildInfoTile(Icons.phone, 'Phone', user?.phonenumber != 0 ? user!.phonenumber.toString() : 'Not set'),
                _buildInfoTile(Icons.shopping_bag, 'Min Order Qty', user?.metadata?['min_order_quantity']?.toString() ?? '1'),
              ],
              if (isFactory) ...[
                _buildInfoTile(Icons.factory, 'Company', user?.metadata?['company_name'] ?? 'Not set'),
                _buildInfoTile(Icons.location_on, 'Location', user?.metadata?['location'] ?? 'Not set'),
                _buildInfoTile(Icons.phone, 'Phone', user?.phonenumber != 0 ? user!.phonenumber.toString() : 'Not set'),
                _buildInfoTile(Icons.speed, 'Production Capacity', user?.metadata?['production_capacity']?.toString() ?? 'Not set'),
                _buildInfoTile(Icons.work, 'Specialization', user?.metadata?['specialization'] ?? 'Not set'),
              ],
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Member Since'),
                subtitle: Text(user?.createdAt.toString().split(' ')[0] ?? 'Unknown'),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}