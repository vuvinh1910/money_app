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
import 'package:wallet_exe/pages/main_page.dart';
import 'package:wallet_exe/utils/text_input_formater.dart';

import '../bloc/category_bloc.dart';

class NewTransactionPage extends StatefulWidget {
  const NewTransactionPage({Key? key}) : super(key: key);

  @override
  _NewTransactionPageState createState() => _NewTransactionPageState();
}

class _NewTransactionPageState extends State<NewTransactionPage> {
  final _balanceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formBalanceKey = GlobalKey<FormState>();

  Category? category;
  Account? _account;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  String _getDate() {
    String wd = _selectedDate.weekday == 7
        ? "Chủ Nhật"
        : "Thứ " + (_selectedDate.weekday + 1).toString();
    String datePart =
        "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}";
    return "$wd - $datePart";
  }

  String _getTime() {
    String formatTime = _selectedTime.minute < 10 ? '0' : '';
    return "${_selectedTime.hour}:$formatTime${_selectedTime.minute}";
  }

  Color _getCurrencyColor() {
    if (category == null) return Colors.red;
    return category!.transactionType == TransactionType.EXPENSE
        ? Colors.red
        : Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    var _bloc = Provider.of<TransactionBloc>(context);
    var _blocAccount = Provider.of<AccountBloc>(context);
    var _categoryBloc = Provider.of<CategoryBloc>(context);

    _categoryBloc.initData();
    _bloc.initData();
    _blocAccount.initData();

    void _submit() {
      if (!(_formBalanceKey.currentState?.validate() ?? false)) return;
      if (_account == null || category == null) return;

      DateTime saveTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final transaction = Transaction(
        account: _account!,
        category: category!,
        amount: currencyToInt(_balanceController.text),
        date: saveTime,
        description: _descriptionController.text,
      );

      _bloc.event.add(AddTransactionEvent(transaction));

      if (category!.transactionType == TransactionType.EXPENSE) {
        _account!.balance -= currencyToInt(_balanceController.text);
      } else {
        _account!.balance += currencyToInt(_balanceController.text);
      }

      _blocAccount.event.add(UpdateAccountEvent(_account!));

      Navigator.pop(context);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Giao dịch mới')),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          child: Column(
            children: <Widget>[
              _buildAmountInput(context),
              const SizedBox(height: 15),
              _buildTransactionInfo(context),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextButton(
                  onPressed: _submit,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.save, size: 28),
                        const SizedBox(width: 5),
                        Text(
                          'Ghi',
                          style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                      color: Theme.of(context).primaryColor) ??
                              const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.blueGrey
            : Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0.0, 15.0),
            blurRadius: 15.0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Số tiền', style: Theme.of(context).textTheme.titleMedium),
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Form(
                  key: _formBalanceKey,
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Số tiền phải lớn hơn 0';
                      }
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
                    keyboardType: const TextInputType.numberWithOptions(
                      signed: true,
                      decimal: true,
                    ),
                    autofocus: true,
                    decoration: InputDecoration(
                      suffixText: 'đ',
                      suffixStyle: Theme.of(context).textTheme.headlineMedium,
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.blueGrey
            : Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0.0, 15.0),
            blurRadius: 15.0,
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          _buildRowItem(
            context,
            icon: category == null ? Icons.category : category!.icon,
            label: category?.name ?? 'Chọn hạng mục',
            onTap: () async {
              category = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CategoryPage()),
              );
              setState(() {});
            },
          ),
          _buildRowItem(
            context,
            icon: Icons.subject,
            child: TextField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.black, fontSize: 16),
              decoration: const InputDecoration(
                hintText: 'Diễn giải',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          ),
          _buildRowItem(
            context,
            icon: Icons.calendar_today,
            label: _getDate(),
            trailingLabel: _getTime(),
            onTap: () => _selectDate(context),
            trailingTap: () => _selectTime(context),
          ),
          _buildRowItem(
            context,
            iconWidget: _account == null
                ? const Icon(Icons.account_balance_wallet, size: 28)
                : Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(_account!.img),
                  ),
            label: _account?.name ?? 'Chọn tài khoản',
            onTap: () async {
              _account = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AccountPage()),
              );
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRowItem(BuildContext context,
      {IconData? icon,
      Widget? iconWidget,
      String? label,
      Widget? child,
      String? trailingLabel,
      VoidCallback? onTap,
      VoidCallback? trailingTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            SizedBox(
              width: 50,
              child: iconWidget ??
                  (icon != null ? Icon(icon, size: 28) : const SizedBox()),
            ),
            Expanded(
              flex: 3,
              child: child ??
                  Text(
                    label ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
            ),
            if (trailingLabel != null)
              GestureDetector(
                onTap: trailingTap,
                child: Text(
                  trailingLabel,
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                ),
              )
            else
              const Icon(Icons.keyboard_arrow_right),
          ],
        ),
      ),
    );
  }
}
