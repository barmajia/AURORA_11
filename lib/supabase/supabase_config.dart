import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aurora/storage/storage.dart';
import 'package:aurora/users/account_type.dart';
import 'package:aurora/users/users.dart';

class SupabaseConfig {
  static final SupabaseClient _client = Supabase.instance.client;

  // Get Supabase client instance
  static SupabaseClient get client => _client;

  // Get current authenticated user
  static User? get currentUser => _client.auth.currentUser;

  // Check if user is authenticated
  static bool get isLoggedIn => _client.auth.currentUser != null;

  // Initialize Supabase configuration
  static void initialize() {
    Supabase.initialize(
      url: 'https://ofovfxsfazlwvcakpuer.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9mb3ZmeHNmYXpsd3ZjYWtwdWVyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIxMjY0MDcsImV4cCI6MjA4NzcwMjQwN30.QYx8-c9IiSMpuHeikKz25MKO5o6g112AKj4Tnr4aWzI',
    );
  }

  // ==================== AUTHENTICATION ====================

  /// Sign up a new user with email and password
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      debugPrint('Sign up error: $e');
      rethrow;
    }
  }

  /// Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      debugPrint('Sign in error: $e');
      rethrow;
    }
  }

  /// Sign out current user
  static Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      await Storage.clearUserData();
    } catch (e) {
      debugPrint('Sign out error: $e');
      rethrow;
    }
  }

  /// Listen to auth state changes
  static Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // ==================== SELLER OPERATIONS ====================

  /// Create a new seller profile
  static Future<Map<String, dynamic>> createSeller({
    required String userId,
    required String email,
    required String fullName,
    String? firstname,
    String? secondName,
    String? thirdName,
    String? fourthName,
    String? phone,
    String? location,
    double? latitude,
    double? longitude,
    String? avatarUrl,
    String? bio,
    String? storeName,
    String? storeSlug,
  }) async {
    try {
      final data = {
        'user_id': userId,
        'email': email,
        'full_name': fullName,
        'firstname': firstname,
        'second_name': secondName,
        'thirdname': thirdName,
        'fourth_name': fourthName,
        'phone': phone,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'account_type': 'seller',
        'is_factory': false,
        'is_verified': false,
        'avatar_url': avatarUrl,
        'bio': bio,
        'store_name': storeName,
        'store_slug': storeSlug,
        'currency': 'USD',
        'min_order_quantity': 1,
        'wholesale_discount': 0,
        'accepts_returns': true,
        'allow_product_chats': true,
        'allow_custom_requests': false,
        'allow_middleman_promo': true,
        'require_middleman_approval': false,
        'current_template_id': 1,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _client.from('sellers').insert(data).select();
      return response.first;
    } catch (e) {
      debugPrint('Create seller error: $e');
      rethrow;
    }
  }

  /// Update seller profile
  static Future<Map<String, dynamic>?> updateSeller({
    required String userId,
    Map<String, dynamic>? updates,
  }) async {
    try {
      final data = {
        ...?updates,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from('sellers')
          .update(data)
          .eq('user_id', userId)
          .select()
          .maybeSingle();
      return response;
    } catch (e) {
      debugPrint('Update seller error: $e');
      rethrow;
    }
  }

  /// Get seller by user ID
  static Future<Map<String, dynamic>?> getSellerByUserId(String userId) async {
    try {
      final response = await _client
          .from('sellers')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      return response;
    } catch (e) {
      debugPrint('Get seller error: $e');
      return null;
    }
  }

  /// Get all verified sellers
  static Future<List<Map<String, dynamic>>> getAllSellers({
    int limit = 100,
    bool verifiedOnly = true,
  }) async {
    try {
      var query = _client.from('sellers').select();

      if (verifiedOnly) {
        query = query.eq('is_verified', true);
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      return response;
    } catch (e) {
      debugPrint('Get all sellers error: $e');
      return [];
    }
  }

  /// Fetch all sellers and save to storage
  static Future<void> fetchAndCacheAllSellers() async {
    try {
      final sellers = await getAllSellers();
      final sellersJson = jsonEncode(sellers);
      await Storage.saveSellerData(sellersJson);
      debugPrint('Cached ${sellers.length} sellers');
    } catch (e) {
      debugPrint('Fetch and cache sellers error: $e');
      rethrow;
    }
  }

  /// Get cached sellers from storage
  static Future<List<Map<String, dynamic>>> getCachedSellers() async {
    try {
      final data = await Storage.getSellerData();
      if (data == null || data.isEmpty) return [];
      final List<dynamic> decoded = jsonDecode(data);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Get cached sellers error: $e');
      return [];
    }
  }

  // ==================== FACTORY OPERATIONS ====================

  /// Create a new factory profile
  static Future<Map<String, dynamic>> createFactory({
    required String userId,
    required String email,
    required String fullName,
    String? companyName,
    String? phone,
    String? location,
    double? latitude,
    double? longitude,
    String? productionCapacity,
    String? specialization,
    String? websiteUrl,
    String? businessLicenseUrl,
    String? factoryLicenseUrl,
    int? minOrderQuantity,
    double? wholesaleDiscount,
  }) async {
    try {
      final data = {
        'user_id': userId,
        'email': email,
        'full_name': fullName,
        'company_name': companyName,
        'phone': phone,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'account_type': 'factory',
        'is_factory': true,
        'is_verified': false,
        'production_capacity': productionCapacity,
        'specialization': specialization,
        'website_url': websiteUrl,
        'business_license_url': businessLicenseUrl,
        'factory_license_url': factoryLicenseUrl,
        'min_order_quantity': minOrderQuantity ?? 1,
        'wholesale_discount': wholesaleDiscount ?? 0,
        'accepts_returns': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Note: Using 'sellers' table with is_factory=true for factories
      // based on the schema where account_type can be 'factory'
      final response = await _client.from('sellers').insert(data).select();
      return response.first;
    } catch (e) {
      debugPrint('Create factory error: $e');
      rethrow;
    }
  }

  /// Update factory profile
  static Future<Map<String, dynamic>?> updateFactory({
    required String userId,
    Map<String, dynamic>? updates,
  }) async {
    try {
      final data = {
        ...?updates,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from('sellers')
          .update(data)
          .eq('user_id', userId)
          .eq('is_factory', true)
          .select()
          .maybeSingle();
      return response;
    } catch (e) {
      debugPrint('Update factory error: $e');
      rethrow;
    }
  }

  /// Get factory by user ID
  static Future<Map<String, dynamic>?> getFactoryByUserId(String userId) async {
    try {
      final response = await _client
          .from('sellers')
          .select()
          .eq('user_id', userId)
          .eq('is_factory', true)
          .maybeSingle();
      return response;
    } catch (e) {
      debugPrint('Get factory error: $e');
      return null;
    }
  }

  /// Get all verified factories
  static Future<List<Map<String, dynamic>>> getAllFactories({
    int limit = 100,
    bool verifiedOnly = true,
  }) async {
    try {
      var query = _client.from('sellers').select();

      if (verifiedOnly) {
        query = query.eq('is_verified', true);
      }

      final response = await query
          .eq('is_factory', true)
          .order('created_at', ascending: false)
          .limit(limit);

      return response;
    } catch (e) {
      debugPrint('Get all factories error: $e');
      return [];
    }
  }

  /// Fetch all factories and save to storage
  static Future<void> fetchAndCacheAllFactories() async {
    try {
      final factories = await getAllFactories();
      final factoriesJson = jsonEncode(factories);
      await Storage.saveFactoryData(factoriesJson);
      debugPrint('Cached ${factories.length} factories');
    } catch (e) {
      debugPrint('Fetch and cache factories error: $e');
      rethrow;
    }
  }

  /// Get cached factories from storage
  static Future<List<Map<String, dynamic>>> getCachedFactories() async {
    try {
      final data = await Storage.getFactoryData();
      if (data == null || data.isEmpty) return [];
      final List<dynamic> decoded = jsonDecode(data);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Get cached factories error: $e');
      return [];
    }
  }

  // ==================== USER PROFILE OPERATIONS ====================

  /// Get user profile by account type
  static Future<Map<String, dynamic>?> getUserProfile({
    required String userId,
    required AccountType accountType,
  }) async {
    try {
      if (accountType == AccountType.factory) {
        return getFactoryByUserId(userId);
      } else {
        return getSellerByUserId(userId);
      }
    } catch (e) {
      debugPrint('Get user profile error: $e');
      return null;
    }
  }

  /// Save user profile to storage
  static Future<void> saveUserProfileToStorage(Map<String, dynamic> profile) async {
    try {
      final accountType = profile['account_type'];
      final jsonStr = jsonEncode(profile);
      
      if (accountType == 'factory') {
        await Storage.saveFactoryData(jsonStr);
      } else {
        await Storage.saveSellerData(jsonStr);
      }
    } catch (e) {
      debugPrint('Save user profile error: $e');
      rethrow;
    }
  }

  // ==================== HELPER METHODS ====================

  /// Check if user has a profile in database
  static Future<bool> hasProfile({required AccountType accountType}) async {
    try {
      final user = currentUser;
      if (user == null) return false;

      final profile = await getUserProfile(
        userId: user.id,
        accountType: accountType,
      );

      return profile != null;
    } catch (e) {
      debugPrint('Has profile error: $e');
      return false;
    }
  }

  /// Get user UUID from storage or auth
  static String? getUserUuid() {
    return currentUser?.id;
  }

  /// Get account type from storage
  static Future<String> getStoredAccountType() async {
    return await Storage.getAccountType();
  }

  /// Clear all cached data
  static Future<void> clearCachedData() async {
    await Storage.clearUserData();
  }
}
