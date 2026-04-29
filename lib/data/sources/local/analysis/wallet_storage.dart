import 'dart:convert';
import 'package:vault_storage/vault_storage.dart';
import 'package:aurora/data/models/analysis/wallet.dart';

class WalletStorage {
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

  static Future<void> saveWallet(Wallet wallet) async {
    await _saveString('wallet_data', jsonEncode(wallet.toMap()));
  }

  static Future<Wallet?> getWallet() async {
    final value = await _getString('wallet_data');
    if (value == null || value.isEmpty) return null;
    try { return Wallet.fromMap(jsonDecode(value) as Map<String, dynamic>); } catch (e) { return null; }
  }
}
