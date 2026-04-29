import 'package:aurora/core/account_type.dart';
import 'package:aurora/core/storage.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProvider extends ChangeNotifier {
  bool _isReady = false;
  bool get isReady => _isReady;

  Future<void> init({required String url, required String anonKey}) async {
    if (_isReady) return;
    await Supabase.initialize(url: url, anonKey: anonKey);
    _isReady = true;
    notifyListeners();
  }

  SupabaseClient get client => Supabase.instance.client;
  bool get isAuthenticated => Supabase.instance.client.auth.currentUser != null;
  User? get currentUser => Supabase.instance.client.auth.currentUser;
  String? get userId => currentUser?.id;

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    notifyListeners();
  }

  Stream<AuthState> get authStateChanges =>
      Supabase.instance.client.auth.onAuthStateChange;
  /**
 * related to the seller login 
 * fetches the seller data from the database and saves it to the storage  
 */
  Future<void> fetchSellerData() async {
    final user = client.auth.currentUser;
    if (user != null) {
      final response = await Supabase.instance.client
          .from('sellers')
          .select('*')
          .eq('user_id', user.id);

      final sellerData = response as List<Map<String, dynamic>>;
      debugPrint(response.toString());
      await Storage.saveUser(sellerData.first);
      await Storage.saveUserId(user.id);
      await Storage.saveAccountType(AccountType.seller.toString());
    }
  }
}
