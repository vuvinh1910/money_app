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
        'id_account': map['id_account'],
        'account_name': map['account_name'],
        'balance': map['balance'],
        'type': map['type'],
        'icon': map['icon'],
        'img': map['img'],
      }),
      category: Category.fromMap({
        'id': map['id'],
        'color': map['color'],
        'name': map['name'],
        'type': map['type'],
        'icon': map['icon'],
        'description': map['description'] ?? '', // ✅ fallback nếu null
      }),
      date: DateTime.parse(map[TransactionTable().date]),
      amount: map[TransactionTable().amount],
      description: map[TransactionTable().description] ?? '', // ✅ fallback
    );
  }

  void checkValidationAndThrow() {
    if (amount <= 0) {
      throw Exception("Invalid amount!");
    }
  }
}
