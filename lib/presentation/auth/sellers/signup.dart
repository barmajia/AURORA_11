import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SellerSignupPage extends StatefulWidget {
  const SellerSignupPage({super.key});
  @override
  State<SellerSignupPage> createState() => _SellerSignupPageState();
}

class _SellerSignupPageState extends State<SellerSignupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signup() async {
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {'name': _nameController.text.trim(), 'account_type': 'seller'},
      );
      if (response.user != null && mounted)
        Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> sellerchecktype() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final response = await Supabase.instance.client
          .from('sellers')
          .select('user_id')
          .eq('user_id', user.id)
          .single();
      if (response.isEmpty) {
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('User is not a seller')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seller Signup')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _signup,
                    child: const Text('Sign Up'),
                  ),
          ],
        ),
      ),
    );
  }
}
