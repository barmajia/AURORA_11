import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aurora/core/account_type.dart';
import 'package:aurora/core/users.dart';
import 'package:aurora/core/storage.dart';

class UserStorage extends ChangeNotifier {
  Users? _currentUser;
  bool _isLoading = false;
  bool _isLoggedIn = false;

  Users? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;

  Future<Users?> loadUser(AccountType accountType) async {
    _isLoading = true;
    notifyListeners();

    try {
      final supabaseUser = Supabase.instance.client.auth.currentUser;
      if (supabaseUser != null) {
        final user = Users(
          id: supabaseUser.id,
          name: supabaseUser.userMetadata?['name'] ?? '',
          email: supabaseUser.email ?? '',
          accountType: accountType,
          metadata: {...(supabaseUser.userMetadata ?? {})},
        );
        _currentUser = user;
        _isLoggedIn = true;
        await Storage.saveUser(user.toJson());
        await Storage.saveAccountType(accountType.value);
        notifyListeners();
        return user;
      }
    } catch (e) {}

    try {
      final cachedUser = await Storage.getUser();
      if (cachedUser != null) {
        _currentUser = cachedUser;
        _isLoggedIn = true;
        notifyListeners();
        return cachedUser;
      }
    } catch (e) {}

    _currentUser = Users.zero();
    _isLoggedIn = false;
    notifyListeners();
    return null;
  }

  Future<void> signOut() async {
    _currentUser = null;
    _isLoggedIn = false;
    await Storage.clearUser();
    await Storage.clearUserData();
    notifyListeners();
  }

  void clearCache() {
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
