import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String _selectedSpendLimitIndexKey =
      'selected_spend_limit_index';

  static Future<void> saveSelectedSpendLimitIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_selectedSpendLimitIndexKey, index);
  }

  static Future<int> getSelectedSpendLimitIndex({int defaultIndex = 1}) async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_selectedSpendLimitIndexKey);
    if (index == null) {
      await prefs.setInt(_selectedSpendLimitIndexKey, defaultIndex);
      return defaultIndex;
    }
    return index;
  }

  // Có thể thêm các hàm khác cho các preference khác ở đây
}
