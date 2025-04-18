import 'package:flutter/material.dart';
import 'package:wallet_exe/bloc/category_bloc.dart';
import 'package:wallet_exe/data/model/Category.dart';
import 'package:wallet_exe/enums/transaction_type.dart';
import 'package:wallet_exe/event/category_event.dart';

class UpdateCategoryPage extends StatefulWidget {
  final Category _category;
  UpdateCategoryPage(this._category);

  @override
  _UpdateCategoryPageState createState() => _UpdateCategoryPageState();
}

class _UpdateCategoryPageState extends State<UpdateCategoryPage> {
  late Category _category;
  final _formNameKey = GlobalKey<FormState>();
  List<TransactionType> _option = TransactionType.getAllType();
  late List<DropdownMenuItem<String>> _dropDownMenuItems;
  late String _currentOption;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _category = widget._category;
    _dropDownMenuItems = getDropDownMenuItems();
    _currentOption = _category.transactionType.name;
    _nameController.text = _category.name;
    _descriptionController.text = _category.description;
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    return _option
        .map((option) => DropdownMenuItem(
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
    if (_formNameKey.currentState?.validate() != true) return;

    Category category = Category(
      name: _nameController.text,
      icon: Icons.ac_unit,
      color: Colors.blueAccent,
      transactionType: TransactionType.valueFromName(_currentOption)!,
      description: _descriptionController.text,
    );
    category.id = _category.id;

    bloc.event.add(UpdateCategoryEvent(category));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    var bloc = CategoryBloc();

    return Scaffold(
      appBar: AppBar(
        title: Text('Sửa hạng mục'),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Column(
            children: <Widget>[
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                width: double.infinity,
                child: Form(
                  key: _formNameKey,
                  child: TextFormField(
                    validator: (value) {
                      return value == null || value.trim().isEmpty
                          ? 'Tên hạng mục không được để trống'
                          : null;
                    },
                    controller: _nameController,
                    autofocus: true,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      hintText: 'Tên hạng mục',
                      hintStyle: TextStyle(fontSize: 20),
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
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                width: double.infinity,
                child: TextFormField(
                  controller: _descriptionController,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    hintText: 'Diễn giải',
                    hintStyle: TextStyle(fontSize: 20),
                    icon: Icon(
                      Icons.subject,
                      size: 30,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      'Loại hạng mục',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                    SizedBox(width: 15),
                    DropdownButton<String>(
                      value: _currentOption,
                      items: _dropDownMenuItems,
                      onChanged: changedDropDownItem,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextButton(
                  onPressed: () => _submit(bloc),
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.save_alt,
                          size: 28,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Cập nhật',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
