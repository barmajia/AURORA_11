import 'dart:convert';
import 'package:vault_storage/vault_storage.dart';
import 'package:aurora/data/models/analysis/analytics.dart';

class AnalyticsStorage {
  static late final IVaultStorage _vault;
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;
    final storage = VaultStorage.create();
    await storage.init();
    _vault = storage;
    _isInitialized = true;
  }

  static Future<void> _saveString(String key, String value) async {
    await _vault.saveNormal(key: key, value: value);
  }

  static Future<String?> _getString(String key) async {
    return await _vault.get<String>(key);
  }

  static Future<void> saveAnalytics(AnalyticsSnapshot snapshot) async {
    await _saveString('analytics_snapshot', jsonEncode(snapshot.toMap()));
  }

  static Future<AnalyticsSnapshot?> getAnalytics() async {
    final value = await _getString('analytics_snapshot');
    if (value == null || value.isEmpty) return null;
    try { return AnalyticsSnapshot.fromMap(jsonDecode(value) as Map<String, dynamic>); } catch (e) { return null; }
  }
}
