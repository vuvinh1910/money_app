import 'package:flutter/material.dart';
import 'package:wallet_exe/bloc/account_bloc.dart';
import 'package:wallet_exe/data/model/Account.dart';
import 'package:wallet_exe/enums/account_type.dart';
import 'package:wallet_exe/event/account_event.dart';
import 'package:wallet_exe/pages/main_page.dart';
import 'package:wallet_exe/utils/text_input_formater.dart';
import 'package:wallet_exe/widgets/circle_image_picker.dart';

class AddAccountPage extends StatefulWidget {
  const AddAccountPage({Key? key}) : super(key: key);

  @override
  _AddAccountPageState createState() => _AddAccountPageState();
}

class _AddAccountPageState extends State<AddAccountPage> {
  String _imgUrl = 'assets/bank.png';
  final List<AccountType> _option = AccountType.getAllType();
  late List<DropdownMenuItem<String>> _dropDownMenuItems;
  late String _currentOption;

  final _formNameKey = GlobalKey<FormState>();
  final _formBalanceKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dropDownMenuItems = getDropDownMenuItems();
    _currentOption = "Tài khoản tiêu dùng";
  }

  Future<void> _pickIcon() async {
    String? url = await FlutterCircleImagePicker.showCircleImagePicker(
      context,
      imageSize: 60,
      imagePickerShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: const Text('Chọn ảnh tài khoản',
          style: TextStyle(fontWeight: FontWeight.bold)),
      closeChild: const Text(
        'Đóng',
        textScaleFactor: 1.25,
      ),
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
        .map((option) =>
        DropdownMenuItem(value: option.name, child: Text(option.name)))
        .toList();
  }

  void changedDropDownItem(String? selectedOption) {
    if (selectedOption != null) {
      setState(() {
        _currentOption = selectedOption;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final _bloc = AccountBloc();

    void _submit() {
      if (!(_formNameKey.currentState?.validate() ?? false)) return;
      if (!(_formBalanceKey.currentState?.validate() ?? false)) return;

      final account = Account(
        name: _nameController.text,
        balance: currencyToInt(_balanceController.text),
        type: AccountType.valueFromName(_currentOption)!,
        icon: Icons.account_balance_wallet,
        img: _imgUrl,
      );

      _bloc.event.add(AddAccountEvent(account));
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MainPage(index: 2),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo tài khoản mới'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _submit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Form(
                key: _formNameKey,
                child: TextFormField(
                  validator: (value) {
                    return (value == null || value.trim().isEmpty)
                        ? 'Tên tài khoản không được để trống'
                        : null;
                  },
                  controller: _nameController,
                  autofocus: true,
                  style: const TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    hintText: 'Tên tài khoản',
                    hintStyle: const TextStyle(fontSize: 20),
                    icon: Icon(
                      Icons.account_balance_wallet,
                      size: 30,
                      color: Theme.of(context).primaryColor,
                    ),
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
                    if (value == null || value.trim().isEmpty) {
                      return 'Số dư không được để trống';
                    }
                    return currencyToInt(value) <= 0
                        ? 'Số tiền phải lớn hơn 0'
                        : null;
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
                    icon: Icon(
                      Icons.attach_money,
                      size: 30,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
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
                    children: [
                      Text(
                        'Loại:',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black.withOpacity(0.5)),
                      ),
                      const SizedBox(width: 10),
                      DropdownButton<String>(
                        value: _currentOption,
                        items: _dropDownMenuItems,
                        onChanged: changedDropDownItem,
                      ),
                    ],
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: TextFormField(
                controller: _descriptionController,
                autofocus: true,
                style: const TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  hintText: 'Diễn giải',
                  hintStyle: const TextStyle(fontSize: 20),
                  icon: Icon(
                    Icons.subject,
                    size: 30,
                    color: Theme.of(context).primaryColor,
                  ),
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
                    children: const [
                      Icon(Icons.save_alt, size: 28),
                      SizedBox(width: 5),
                      Text('Tạo'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
