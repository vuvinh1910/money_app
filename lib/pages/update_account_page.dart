import 'package:flutter/material.dart';
import 'package:wallet_exe/bloc/account_bloc.dart';
import 'package:wallet_exe/data/model/Account.dart';
import 'package:wallet_exe/enums/account_type.dart';
import 'package:wallet_exe/event/account_event.dart';
import 'package:wallet_exe/pages/main_page.dart';
import 'package:wallet_exe/utils/text_input_formater.dart';
import 'package:wallet_exe/widgets/circle_image_picker.dart';

class UpdateAccountPage extends StatefulWidget {
  final Account account;
  UpdateAccountPage(this.account, {Key? key}) : super(key: key);

  @override
  _UpdateAccountPageState createState() => _UpdateAccountPageState();
}

class _UpdateAccountPageState extends State<UpdateAccountPage> {
  late Account _account;
  late List<AccountType> _option;
  late List<DropdownMenuItem<String>> _dropDownMenuItems;
  late String _currentOption;
  late String _imgUrl;

  final _formNameKey = GlobalKey<FormState>();
  final _formBalanceKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _account = widget.account;
    _option = AccountType.getAllType();
    _dropDownMenuItems = getDropDownMenuItems();
    _currentOption = _account.type.name;
    _imgUrl = _account.img;
    _nameController.text = _account.name;
    _balanceController.text = textToCurrency(_account.balance.toString());
  }

  Future<void> _pickIcon() async {
    String? url = await FlutterCircleImagePicker.showCircleImagePicker(
      context,
      imageSize: 60,
      imagePickerShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text('Chọn ảnh tài khoản', style: TextStyle(fontWeight: FontWeight.bold)),
      closeChild: const Text('Đóng', textScaleFactor: 1.25),
      searchHintText: 'Tìm ảnh...',
      noResultsText: 'Không tìm thấy:',
    );

    if (url != null) {
      setState(() {
        _imgUrl = url;
      });
    }
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    return _option
        .map((option) => DropdownMenuItem(value: option.name, child: Text(option.name)))
        .toList();
  }

  void changedDropDownItem(String? selectedOption) {
    if (selectedOption != null) {
      setState(() {
        _currentOption = selectedOption;
      });
    }
  }

  void _submit() {
    if (!(_formNameKey.currentState?.validate() ?? false)) return;
    if (!(_formBalanceKey.currentState?.validate() ?? false)) return;

    final updatedAccount = Account(
      name: _nameController.text,
      balance: currencyToInt(_balanceController.text),
      type: AccountType.valueFromName(_currentOption)!,
      icon: Icons.account_balance_wallet,
      img: _imgUrl,
    );
    updatedAccount.id = _account.id;

    final bloc = AccountBloc();
    bloc.initData();
    bloc.event.add(UpdateAccountEvent(updatedAccount));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => MainPage(index: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_account.name),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Form(
                  key: _formNameKey,
                  child: TextFormField(
                    validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Tên tài khoản không được để trống' : null,
                    controller: _nameController,
                    autofocus: true,
                    style: const TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      hintText: 'Tên tài khoản',
                      hintStyle: const TextStyle(fontSize: 20),
                      icon: Icon(Icons.account_balance_wallet, size: 30, color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Form(
                  key: _formBalanceKey,
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Số dư không được để trống';
                      return currencyToInt(value) <= 0 ? 'Số tiền phải lớn hơn 0' : null;
                    },
                    controller: _balanceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [CurrencyTextFormatter()],
                    autofocus: true,
                    style: const TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      suffixText: 'đ',
                      hintText: 'Số dư ban đầu',
                      hintStyle: const TextStyle(fontSize: 20),
                      icon: Icon(Icons.attach_money, size: 30, color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: SizedBox(
                            height: 38,
                            width: 38,
                            child: Image.asset(_imgUrl),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.mode_edit),
                          onPressed: _pickIcon,
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text('Loại:',
                            style: TextStyle(fontSize: 18, color: Colors.black.withOpacity(0.5))),
                        const SizedBox(width: 10),
                        DropdownButton<String>(
                          value: _currentOption,
                          items: _dropDownMenuItems,
                          onChanged: changedDropDownItem,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: TextFormField(
                  controller: _descriptionController,
                  style: const TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    hintText: 'Diễn giải',
                    hintStyle: const TextStyle(fontSize: 20),
                    icon: Icon(Icons.subject, size: 30, color: Theme.of(context).primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: TextButton(
                  onPressed: _submit,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Icon(Icons.save, size: 28),
                        const SizedBox(width: 5),
                        Text('Lưu', style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
