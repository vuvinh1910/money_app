import '../../utils/date_format_util.dart';
import '../dao/transaction_table.dart';
import 'Account.dart';
import 'Category.dart';

class Transaction {
  int? id;
  Account account;
  Category category;
  int amount;
  DateTime date;
  String? description; // ✅ Cho phép null

  Transaction({
    this.id,
    required this.account,
    required this.category,
    required this.amount,
    required this.date,
    this.description, // ✅ Đã nullable
  });

  Transaction.copyOf(Transaction copy)
      : id = copy.id,
        account = copy.account,
        category = copy.category,
        amount = copy.amount,
        date = copy.date,
        description = copy.description;

  Map<String, dynamic> toMap() {
    return {
      TransactionTable().id: id,
      TransactionTable().date: convertToISO8601DateFormat(date),
      TransactionTable().amount: amount,
      TransactionTable().description: description ?? '', // ✅ fallback
      TransactionTable().idCategory: category.id,
      TransactionTable().idAccount: account.id
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map[TransactionTable().id],
      account: Account.fromMap({
        // Sử dụng các key trực tiếp từ map kết quả JOIN
        // Đảm bảo các key này khớp với alias trong truy vấn SQL
        'id_account': map['account_id'], // ✅ Sửa thành alias 'account_id'
        'account_name': map['account_name'],
        'balance': map['balance'],
        'type': map['account_type'], // ✅ Sửa thành alias 'account_type'
        'icon': map['account_icon'], // ✅ Sửa thành alias 'account_icon'
        'img': map['img'],
      }),
      category: Category.fromMap({
        // Sử dụng các key trực tiếp từ map kết quả JOIN
        // Đảm bảo các key này khớp với alias trong truy vấn SQL
        'id': map['category_id'], // ✅ Sửa thành alias 'category_id'
        'color': map['color'],
        'name': map['name'],
        'type': map['category_type'], // ✅ Sửa thành alias 'category_type'
        'icon': map['category_icon'], // ✅ Sửa thành alias 'category_icon'
        'description': map['category_description'] ?? '',
      }),
      date: DateTime.parse(map[TransactionTable().date]),
      amount: map[TransactionTable().amount],
      description: map[TransactionTable().description] ?? '',
    );
  }

  void checkValidationAndThrow() {
    if (amount <= 0) {
      throw Exception("Invalid amount!");
    }
  }
}
