import 'package:flutter/material.dart';
import 'package:aurora/users/users.dart';
import 'package:aurora/users/account_type.dart';
import 'package:aurora/storage/storage.dart';

class UserStorage extends ChangeNotifier {
  Users? _currentUser;
  bool _isLoading = false;
  String? _error;

  // In-memory cache for account type and uuid
  AccountType? _cachedAccountType;
  String? _cachedUuid;

  Users? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null && _currentUser!.id.isNotEmpty;
  
  // Cached getters - no storage calls needed
  AccountType? get cachedAccountType => _cachedAccountType;
  String? get cachedUuid => _cachedUuid;

  Future<void> loadUser(AccountType accountType) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final localUser = await Storage.getUser();
      if (localUser != null) {
        _currentUser = localUser;
      } else {
        _currentUser = Users.zero();
      }
    } catch (e) {
      _error = e.toString();
      _currentUser = Users.zero();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
    required AccountType accountType,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final storedUser = await Storage.getUser();
      
      if (storedUser != null && 
          storedUser.email == email && 
          storedUser.password == password &&
          storedUser.accountType == accountType) {
        _currentUser = storedUser;
        // Update in-memory cache
        _cachedAccountType = accountType;
        _cachedUuid = storedUser.id;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Invalid email or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required AccountType accountType,
    Map<String, dynamic>? metadata,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check if user already exists
      final existingUser = await Storage.getUser();
      if (existingUser != null && existingUser.email == email) {
        _error = 'Email already registered';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final user = Users(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: name,
        password: password,
        accountType: accountType,
        phonenumber: 0,
        createdAt: DateTime.now(),
        isactive: true,
        metadata: metadata ?? {},
      );

      await Storage.saveUser(user.toJson());
      
      // Update in-memory cache
      _currentUser = user;
      _cachedAccountType = accountType;
      _cachedUuid = user.id;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> saveSeller(Users user, {
    String? firstname,
    String? secondName,
    String? thirdName,
    String? fourthName,
    String? location,
    String? phone,
    double? latitude,
    double? longitude,
    bool? isFactory,
    String? factoryLicenseUrl,
    int? minOrderQuantity,
    double? wholesaleDiscount,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = Users(
        id: user.id,
        email: user.email,
        name: user.name,
        password: user.password,
        accountType: user.accountType,
        phonenumber: int.tryParse(phone ?? user.phonenumber.toString()) ?? user.phonenumber,
        createdAt: user.createdAt,
        isactive: user.isactive,
        metadata: {
          ...user.metadata,
          if (firstname != null) 'firstname': firstname,
          if (secondName != null) 'second_name': secondName,
          if (thirdName != null) 'thirdname': thirdName,
          if (fourthName != null) 'fourth_name': fourthName,
          if (location != null) 'location': location,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          if (isFactory != null) 'is_factory': isFactory,
          if (factoryLicenseUrl != null) 'factory_license_url': factoryLicenseUrl,
          if (minOrderQuantity != null) 'min_order_quantity': minOrderQuantity,
          if (wholesaleDiscount != null) 'wholesale_discount': wholesaleDiscount,
        },
      );

      _currentUser = updatedUser;
      await Storage.saveUser(updatedUser.toJson());
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveFactory(Users user, {
    String? companyName,
    String? phone,
    String? location,
    String? locationText,
    double? latitude,
    double? longitude,
    int? productionCapacity,
    String? specialization,
    String? websiteUrl,
    String? businessLicenseUrl,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = Users(
        id: user.id,
        email: user.email,
        name: user.name,
        password: user.password,
        accountType: user.accountType,
        phonenumber: int.tryParse(phone ?? user.phonenumber.toString()) ?? user.phonenumber,
        createdAt: user.createdAt,
        isactive: user.isactive,
        metadata: {
          ...user.metadata,
          if (companyName != null) 'company_name': companyName,
          if (location != null) 'location': location,
          if (locationText != null) 'location_text': locationText,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          if (productionCapacity != null) 'production_capacity': productionCapacity,
          if (specialization != null) 'specialization': specialization,
          if (websiteUrl != null) 'website_url': websiteUrl,
          if (businessLicenseUrl != null) 'business_license_url': businessLicenseUrl,
        },
      );

      _currentUser = updatedUser;
      await Storage.saveUser(updatedUser.toJson());
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _currentUser = Users.zero();
    // Clear in-memory cache
    _cachedAccountType = null;
    _cachedUuid = null;
    await Storage.clearUser();
    notifyListeners();
  }

  /// Clear cached data when app is closed/paused
  void clearCache() {
    _cachedAccountType = null;
    _cachedUuid = null;
  }
}
