import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:provider/provider.dart';
import 'package:wallet_exe/bloc/category_bloc.dart';
import 'package:wallet_exe/data/model/Category.dart';
import 'package:wallet_exe/enums/transaction_type.dart';
import 'package:wallet_exe/event/category_event.dart';

class AddCategoryPage extends StatefulWidget {
  AddCategoryPage({Key? key}) : super(key: key);

  @override
  _AddCategoryPageState createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  IconData? _iconData;
  late List<TransactionType> _option;
  late List<DropdownMenuItem<String>> _dropDownMenuItems;
  late String _currentOption;
  final _formNameKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _option = TransactionType.getAllType();
    _dropDownMenuItems = getDropDownMenuItems();
    _currentOption = "Hạng mục chi";
    _iconData = Icons.category;
  }

  Future<void> _pickIcon() async {
    IconData? icon = await showIconPicker(context,
        iconSize: 40,
        iconPickerShape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Chọn icon', style: TextStyle(fontWeight: FontWeight.bold)),
        closeChild: const Text(
          'Đóng',
          textScaleFactor: 1.25,
        ),
        searchHintText: 'Tìm icon...',
        noResultsText: 'Không tìm thấy:');

    if (icon != null) {
      setState(() {
        _iconData = icon;
      });
    }
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    return _option
        .map((option) => DropdownMenuItem<String>(
      value: option.name,
      child: Text(option.name),
    ))
        .toList();
  }

  void changedDropDownItem(String? selectedOption) {
    if (selectedOption != null) {
      setState(() {
        _currentOption = selectedOption;
      });
    }
  }

  void _submit(CategoryBloc bloc) {
    if (_formNameKey.currentState?.validate() != true) {
      return;
    }

    final category = Category(
      name: _nameController.text,
      icon: _iconData!,
      color: Colors.blueAccent,
      transactionType: TransactionType.valueFromName(_currentOption)!,
      description: _descriptionController.text,
    );

    bloc.event.add(AddCategoryEvent(category));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final _bloc = Provider.of<CategoryBloc>(context,listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo hạng mục mới'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => _submit(_bloc),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                width: double.infinity,
                child: Form(
                  key: _formNameKey,
                  child: TextFormField(
                    validator: (String? value) {
                      return value == null || value.trim().isEmpty
                          ? 'Tên hạng mục không được để trống'
                          : null;
                    },
                    controller: _nameController,
                    autofocus: true,
                    style: const TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      hintText: 'Tên hạng mục',
                      hintStyle: const TextStyle(fontSize: 20),
                      icon: Icon(
                        Icons.category,
                        size: 30,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                width: double.infinity,
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
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _iconData != null
                              ? Icon(_iconData, size: 30)
                              : Container(),
                        ),
                        const SizedBox(width: 10),
                        TextButton(
                          onPressed: _pickIcon,
                          child: Text('Chọn icon',
                              style: Theme.of(context).textTheme.titleMedium),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
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
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: TextButton(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Icon(Icons.save_alt, size: 28),
                        const SizedBox(width: 5),
                        Text(
                          'Tạo',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  onPressed: () => _submit(_bloc),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
