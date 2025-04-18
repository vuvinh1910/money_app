import 'package:flutter/material.dart';
import 'package:wallet_exe/enums/transaction_type.dart';
import 'package:wallet_exe/widgets/card_category_list.dart';
import '../data/model/Category.dart';
import 'package:wallet_exe/bloc/category_bloc.dart';
import 'package:wallet_exe/pages/add_category_page.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({Key? key}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  String _filter = "";

  void _submit() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>  AddCategoryPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _bloc = CategoryBloc();
    _bloc.initData();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn hạng mục'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _submit,
          ),
        ],
      ),
      body: StreamBuilder<List<Category>>(
        stream: _bloc.categoryListStream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(
                child: SizedBox(
                  width: 100,
                  height: 50,
                  child: Text('Bạn chưa tạo hạng mục nào'),
                ),
              );
            case ConnectionState.none:
            case ConnectionState.active:
              final data = snapshot.data ?? [];

              final filteredAll = data
                  .where((item) => item.name.contains(_filter))
                  .toList();

              final filteredExpense = data
                  .where((item) => item.transactionType == TransactionType.EXPENSE)
                  .where((item) => item.name.contains(_filter))
                  .toList();

              final filteredIncome = data
                  .where((item) => item.transactionType == TransactionType.INCOME)
                  .where((item) => item.name.contains(_filter))
                  .toList();

              return SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black45
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
                        child: TextField(
                          onChanged: (text) {
                            setState(() {
                              _filter = text.trim();
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Tìm tên hạng mục',
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.search,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      CardCategoryList('TẤT CẢ', filteredAll),
                      const SizedBox(height: 15),
                      CardCategoryList('Hạng mục chi', filteredExpense),
                      const SizedBox(height: 15),
                      CardCategoryList('Hạng mục thu', filteredIncome),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              );
            default:
              return const Center(
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(),
                ),
              );
          }
        },
      ),
    );
  }
}
