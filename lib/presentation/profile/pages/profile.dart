import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aurora/core/storage.dart';
import 'package:aurora/core/userStorage.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Consumer<UserStorage>(
        builder: (context, userStorage, _) {
          final user = userStorage.currentUser;
          return FutureBuilder<String?>(
            future: Storage.getSellerData(),
            builder: (context, snapshot) {
              Map<String, dynamic>? sellerData;
              if (snapshot.hasData && snapshot.data != null) {
                sellerData = jsonDecode(snapshot.data!) as Map<String, dynamic>;
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          user?.name.isNotEmpty == true
                              ? user!.name[0].toUpperCase()
                              : sellerData?['full_name']
                                        ?.toString()
                                        .isNotEmpty ==
                                    true
                              ? (sellerData!['full_name'] as String)[0]
                                    .toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 36,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (user != null) ...[
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      if (sellerData != null) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Seller Info',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSellerInfoRow(
                          'Full Name',
                          sellerData['full_name'],
                        ),
                        _buildSellerInfoRow('Phone', sellerData['phone']),
                        _buildSellerInfoRow(
                          'Store Name',
                          sellerData['store_name'],
                        ),
                        _buildSellerInfoRow('Bio', sellerData['bio']),
                        _buildSellerInfoRow('Location', sellerData['location']),
                        _buildSellerInfoRow(
                          'Verified',
                          sellerData['is_verified'] == true ? 'Yes' : 'No',
                        ),
                        _buildSellerInfoRow(
                          'Allow Chats',
                          sellerData['allow_product_chats'] == true
                              ? 'Yes'
                              : 'No',
                        ),
                      ],
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () async {
                          await Supabase.instance.client.auth.signOut();
                          userStorage.signOut();

                          if (context.mounted) {
                            Navigator.of(
                              context,
                            ).pushReplacementNamed('/welcome');
                          }
                        },
                        child: const Text('Sign Out'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSellerInfoRow(String label, dynamic value) {
    if (value == null || value.toString().isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(child: Text(value.toString())),
        ],
      ),
    );
  }
}
