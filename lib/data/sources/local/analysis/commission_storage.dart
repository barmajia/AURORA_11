import 'dart:convert';
import 'package:vault_storage/vault_storage.dart';
import 'package:aurora/data/models/analysis/commission.dart';

class CommissionStorage {
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

  static Future<void> saveCommissions(List<Commission> commissions) async {
    final list = commissions.map((c) => c.toMap()).toList();
    await _saveString('commissions_list', jsonEncode(list));
  }

  static Future<List<Commission>> getCommissions() async {
    final value = await _getString('commissions_list');
    if (value == null || value.isEmpty) return [];
    try {
      final list = jsonDecode(value) as List;
      return list.map((item) => Commission.fromMap(item as Map<String, dynamic>)).toList();
    } catch (e) { return []; }
  }
}
