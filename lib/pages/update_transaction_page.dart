import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet_exe/bloc/account_bloc.dart';
import 'package:wallet_exe/bloc/transaction_bloc.dart';
import 'package:wallet_exe/data/model/Account.dart';
import 'package:wallet_exe/data/model/Category.dart';
import 'package:wallet_exe/data/model/Transaction.dart';
import 'package:wallet_exe/enums/transaction_type.dart';
import 'package:wallet_exe/event/account_event.dart';
import 'package:wallet_exe/event/transaction_event.dart';
import 'package:wallet_exe/pages/account_page.dart';
import 'package:wallet_exe/pages/category_page.dart';
import 'package:wallet_exe/utils/text_input_formater.dart';

class UpdateTransactionPage extends StatefulWidget {
  final Transaction transaction;

  UpdateTransactionPage(this.transaction);

  @override
  _UpdateTransactionPageState createState() => _UpdateTransactionPageState();
}

class _UpdateTransactionPageState extends State<UpdateTransactionPage> {
  late Transaction _transaction;
  final _balanceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formBalanceKey = GlobalKey<FormState>();
  late Category _category;
  late Account _account;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    _transaction = widget.transaction;
    _balanceController.text = textToCurrency(_transaction.amount.toString());
    _descriptionController.text = _transaction.description!;
    _category = _transaction.category;
    _account = _transaction.account;
    _selectedDate = _transaction.date;
    _selectedTime = TimeOfDay.fromDateTime(_transaction.date);

    super.initState();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? time =
        await showTimePicker(context: context, initialTime: _selectedTime);
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  String _getDate() {
    DateTime date = _selectedDate;
    String wd =
        date.weekday == 7 ? "Chủ Nhật" : "Thứ " + (date.weekday + 1).toString();
    String datePart = "${date.day}/${date.month}/${date.year}";
    return "$wd - $datePart";
  }

  String _getTime() {
    TimeOfDay time = _selectedTime;
    String formatTime = time.minute < 10 ? '0' : '';
    return "${time.hour}:$formatTime${time.minute}";
  }

  Color _getCurrencyColor() {
    return (_category.transactionType == TransactionType.EXPENSE)
        ? Colors.red
        : Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    var _bloc = Provider.of<TransactionBloc>(context, listen: false);
    var _blocAccount = AccountBloc();
    _bloc.initData();
    _blocAccount.initData();

    void _submit() {
      if (!(_formBalanceKey.currentState?.validate() ?? false)) return;

      if (_account == null || _category == null) return;

      DateTime saveTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      Transaction transaction = Transaction(
        id: _transaction.id,
        account: _account,
        category: _category,
        amount: currencyToInt(_balanceController.text),
        date: saveTime,
        description: _descriptionController.text,
      );

      _bloc.event.add(UpdateTransactionEvent(transaction));

      // Cập nhật số dư tài khoản
      int newAmount = currencyToInt(_balanceController.text);
      int oldAmount = _transaction.amount;

      if (_category.transactionType == TransactionType.EXPENSE) {
        if (_transaction.category.transactionType == TransactionType.EXPENSE) {
          _account.balance -= (newAmount - oldAmount);
        } else {
          _account.balance -= (newAmount + oldAmount);
        }
      } else {
        if (_transaction.category.transactionType == TransactionType.EXPENSE) {
          _account.balance += (newAmount + oldAmount);
        } else {
          _account.balance += (newAmount - oldAmount);
        }
      }

      _blocAccount.event.add(UpdateAccountEvent(_account));
      Navigator.pop(context);
    }

    void _delete() {
      _bloc.event.add(DeleteTransactionEvent(_transaction));
      // Nếu muốn cập nhật lại số dư tài khoản sau khi xóa, xử lý ở đây nếu cần
      Navigator.pop(context);
    }

    return Scaffold(
      appBar: AppBar(title: Text('Chi tiết giao dịch')),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              _buildAmountInput(context),
              SizedBox(height: 15),
              _buildTransactionDetail(context),
              SizedBox(height: 15),
              _buildButtons(context, _submit, _delete),
              SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInput(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: _buildBoxDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Số tiền', style: Theme.of(context).textTheme.titleMedium),
          Row(
            children: [
              Expanded(
                child: Form(
                  key: _formBalanceKey,
                  child: TextFormField(
                    validator: (String? value) {
                      if (value == null || value.trim() == "")
                        return 'Số tiền phải lớn hơn 0';
                      return currencyToInt(value) <= 0
                          ? 'Số tiền phải lớn hơn 0'
                          : null;
                    },
                    controller: _balanceController,
                    textAlign: TextAlign.end,
                    inputFormatters: [CurrencyTextFormatter()],
                    style: TextStyle(
                      color: _getCurrencyColor(),
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      signed: true,
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      suffixText: 'đ',
                      suffixStyle: Theme.of(context).textTheme.titleLarge,
                      prefix: Icon(
                        Icons.monetization_on,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 26,
                      ),
                      hintText: '0',
                      hintStyle: TextStyle(
                        color: Colors.red,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetail(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: _buildBoxDecoration(context),
      child: Column(
        children: [
          _buildListItem(
            icon: Icons.category,
            text: _category.name,
            onTap: () async {
              var selected = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CategoryPage()),
              );
              if (selected != null) setState(() => _category = selected);
            },
          ),
          _buildListItem(
            icon: Icons.subject,
            child: TextField(
              controller: _descriptionController,
              style: TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Diễn giải',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          ),
          _buildListItem(
            icon: Icons.calendar_today,
            text: _getDate(),
            onTap: () => _selectDate(context),
            trailing: Text(_getTime(), style: TextStyle(fontSize: 18)),
            trailingTap: () => _selectTime(context),
          ),
          _buildListItem(
            icon: Icons.account_balance,
            text: _account.name,
            onTap: () async {
              var selected = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AccountPage()),
              );
              if (selected != null) setState(() => _account = selected);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListItem({
    required IconData icon,
    String? text,
    Widget? child,
    VoidCallback? onTap,
    Widget? trailing,
    VoidCallback? trailingTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Container(width: 50, child: Icon(icon, size: 28)),
            Expanded(
              child: child ??
                  Text(
                    text ?? '',
                    style: TextStyle(fontSize: 18),
                  ),
            ),
            if (trailing != null) InkWell(onTap: trailingTap, child: trailing),
            Icon(Icons.keyboard_arrow_right),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons(
      BuildContext context, VoidCallback onSubmit, VoidCallback onDelete) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          _buildActionBtn(Icons.delete, 'Xóa', onDelete),
          _buildActionBtn(Icons.save, 'Lưu', onSubmit),
        ],
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: TextButton(
          onPressed: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 28),
                SizedBox(width: 5),
                Text(label, style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBoxDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.blueGrey
          : Colors.white,
      borderRadius: BorderRadius.circular(8.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          offset: Offset(0.0, 15.0),
          blurRadius: 15.0,
        ),
      ],
    );
  }
}
