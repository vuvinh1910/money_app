import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String _selectedSpendLimitIndexKey =
      'selected_spend_limit_index';

  static Future<void> saveSelectedSpendLimitIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_selectedSpendLimitIndexKey, index);
  }

  static Future<int?> getSelectedSpendLimitIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_selectedSpendLimitIndexKey);
  }

  // Có thể thêm các hàm khác cho các preference khác ở đây
}
