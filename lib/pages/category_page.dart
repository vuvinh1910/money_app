import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet_exe/enums/transaction_type.dart';
import 'package:wallet_exe/widgets/card_category_list.dart';
import 'package:wallet_exe/data/model/Category.dart';
import 'package:wallet_exe/bloc/category_bloc.dart';
import 'package:wallet_exe/pages/add_category_page.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({Key? key}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  String _filter = "";
  final TextEditingController _searchController = TextEditingController();

  void _submit() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddCategoryPage()),
    );
  }

  @override
  void initState() {
    super.initState();
    final bloc = Provider.of<CategoryBloc>(context, listen: false);
    bloc.initData();
    _searchController.addListener(() {
      setState(() {
        _filter = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CategoryBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn hạng mục'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _submit,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm hạng mục...',
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.white,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Category>>(
              stream: bloc.categoryListStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Lỗi khi tải dữ liệu: ${snapshot.error}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  );
                }

                final data = snapshot.data ?? [];
                if (data.isEmpty) {
                  return const Center(
                    child: Text(
                      'Bạn chưa tạo hạng mục nào',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                final filteredAll = data
                    .where((item) => item.name.toLowerCase().contains(_filter))
                    .toList();

                final filteredExpense = data
                    .where((item) => item.transactionType == TransactionType.EXPENSE)
                    .where((item) => item.name.toLowerCase().contains(_filter))
                    .toList();

                final filteredIncome = data
                    .where((item) => item.transactionType == TransactionType.INCOME)
                    .where((item) => item.name.toLowerCase().contains(_filter))
                    .toList();

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (filteredAll.isNotEmpty) ...[
                        CardCategoryList('Tất cả', filteredAll),
                        const SizedBox(height: 16.0),
                      ],
                      if (filteredExpense.isNotEmpty) ...[
                        CardCategoryList('Hạng mục chi', filteredExpense),
                        const SizedBox(height: 16.0),
                      ],
                      if (filteredIncome.isNotEmpty) ...[
                        CardCategoryList('Hạng mục thu', filteredIncome),
                        const SizedBox(height: 16.0),
                      ],
                      if (filteredAll.isEmpty &&
                          filteredExpense.isEmpty &&
                          filteredIncome.isEmpty)
                        const Center(
                          child: Text(
                            'Không tìm thấy hạng mục phù hợp',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}