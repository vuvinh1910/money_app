import 'dart:async';

import 'package:wallet_exe/bloc/base_bloc.dart';
import 'package:wallet_exe/data/dao/category_table.dart';
import 'package:wallet_exe/data/model/Category.dart';
import 'package:wallet_exe/event/category_event.dart';
import 'package:wallet_exe/event/base_event.dart';

class CategoryBloc extends BaseBloc {
  CategoryTable _categorytable = CategoryTable();

  StreamController<List<Category>> _categoryListStreamController =
  StreamController<List<Category>>.broadcast();

  Stream<List<Category>> get categoryListStream =>
      _categoryListStreamController.stream;

  List<Category> _categoryListData = [];

  List<Category> get categoryListData => _categoryListData;

  void initData() async {
    _categoryListData = await _categorytable.getAll() ?? [];
    print('CategoryBloc init: Loaded ${_categoryListData.length} categories');

    if (!_categoryListStreamController.isClosed) {
      _categoryListStreamController.sink.add(_categoryListData);
    }
  }

  _addCategory(Category category) async {
    await _categorytable.insert(category); // Dùng await để đảm bảo thao tác DB hoàn thành
    // Sau khi thêm vào DB, tải lại toàn bộ dữ liệu để đảm bảo đồng bộ ID và cập nhật Stream
    initData();
  }

  _deleteCategory(Category category) async {
    // Thêm kiểm tra null an toàn trước khi sử dụng '!'
    if (category.id != null) {
      await _categorytable.delete(category.id!); // Dùng await
      // Sau khi xóa khỏi DB, tải lại toàn bộ dữ liệu để đảm bảo đồng bộ và cập nhật Stream
      initData();
    } else {
      print("Lỗi: Không thể xóa danh mục vì ID là null: ${category.name}");
      // Có thể tải lại dữ liệu để cố gắng đồng bộ lại UI với DB
      initData();
    }
  }

  _updateCategory(Category category) async {
    if (category.id != null) {
      await _categorytable.update(category); // Dùng await
      // Sau khi cập nhật DB, tải lại toàn bộ dữ liệu để đảm bảo đồng bộ và cập nhật Stream
      initData();
    } else {
      print("Lỗi: Không thể cập nhật danh mục vì ID là null: ${category.name}");
    }
  }

  void dispatchEvent(BaseEvent event) {
    if (event is AddCategoryEvent) {
      Category category = Category.copyOf(event.category);
      _addCategory(category);
    } else if (event is DeleteCategoryEvent) {
      Category category = Category.copyOf(event.category);
      _deleteCategory(category);
    } else if (event is UpdateCategoryEvent) {
      Category category = Category.copyOf(event.category);
      _updateCategory(category);
    }
  }

  @override
  void dispose() {
    _categoryListStreamController.close(); // Đảm bảo đóng StreamController
    super.dispose();
  }
}