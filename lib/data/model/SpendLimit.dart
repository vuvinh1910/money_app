import 'package:wallet_exe/data/dao/spend_limit_table.dart';
import 'package:wallet_exe/enums/spend_limit_type.dart';

class SpendLimit {
  int? id; // auto generate & unique

  int amount;
  SpendLimitType type;

  SpendLimit({
    this.id,
    required this.amount,
    required this.type,
  });

  SpendLimit.copyOf(SpendLimit copy)
      : id = copy.id,
        amount = copy.amount,
        type = copy.type;

  Map<String, dynamic> toMap() {
    return {
      SpendLimitTable().id: id,
      SpendLimitTable().amount: amount,
      SpendLimitTable().type: type.value,
    };
  }

  SpendLimit.fromMap(Map<String, dynamic> map)
      : id = map[SpendLimitTable().id],
        amount = map[SpendLimitTable().amount],
        type = SpendLimitType.valueOf(map[SpendLimitTable().type])!;
}
