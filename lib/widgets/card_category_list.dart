import 'package:flutter/material.dart';
import 'package:wallet_exe/data/model/Category.dart';
import 'package:wallet_exe/widgets/item_category.dart';

class CardCategoryList extends StatelessWidget {
  final List<Category> categories;
  final String title;

  const CardCategoryList(this.title, this.categories, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    for (int i = 0; i < categories.length; i++) {
      children.add(ItemCategory(
        categories[i],
        // Không cần truyền onDelete callback nữa
        // onDelete: (category) => _onDeleteCategory(context, category),
      ));
      if (i < categories.length - 1) {
        children.add(const Divider(height: 1));
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 15),
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
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        initiallyExpanded: true,
        children: categories.isNotEmpty
            ? children
            : const [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Không có danh mục nào',
              style: TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}