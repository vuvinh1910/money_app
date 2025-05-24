import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet_exe/data/model/Category.dart';
import 'package:wallet_exe/bloc/category_bloc.dart';
import 'package:wallet_exe/event/category_event.dart';

class ItemCategory extends StatelessWidget {
  final Category category;
  final Function(Category)? onDelete; // Làm optional

  const ItemCategory(this.category, {Key? key, this.onDelete}) : super(key: key);

  Future<bool?> _showDeleteConfirmation(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa danh mục "${category.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy')
          ),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Xóa', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  void _deleteCategory(BuildContext context) {
    // Chỉ gửi event một lần tới bloc
    final bloc = Provider.of<CategoryBloc>(context, listen: false);
    bloc.event.add(DeleteCategoryEvent(category));

    // Gọi callback nếu có (để update UI local)
    onDelete?.call(category);

    // Hiển thị thông báo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã xóa danh mục "${category.name}"'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(category.id.toString()),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _showDeleteConfirmation(context),
      onDismissed: (_) => _deleteCategory(context),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete, color: Colors.white),
            SizedBox(width: 8),
            Text("Xóa", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      child: ListTile(
        leading: Icon(category.icon),
        title: Text(category.name),
        trailing: const Icon(Icons.keyboard_arrow_right),
        onTap: () {
          Navigator.pop(context, category);
        },
      ),
    );
  }
}