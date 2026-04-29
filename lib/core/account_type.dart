enum AccountType { seller, factory, customser, middleman }

extension AccountTypeExtension on AccountType {
  String get value {
    switch (this) {
      case AccountType.seller: return 'seller';
      case AccountType.factory: return 'factory';
      case AccountType.customser: return 'customer';
      case AccountType.middleman: return 'middleman';
    }
  }
  static AccountType fromString(String value) {
    switch (value) {
      case 'seller': return AccountType.seller;
      case 'factory': return AccountType.factory;
      case 'customer': return AccountType.customser;
      case 'middleman': return AccountType.middleman;
      default: return AccountType.seller;
    }
  }
}
