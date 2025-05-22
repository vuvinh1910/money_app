// import 'package:flutter/material.dart';
// import 'package:wallet_exe/bloc/account_bloc.dart';
// import 'package:wallet_exe/bloc/transaction_bloc.dart';
// import 'package:wallet_exe/data/dao/account_table.dart';
// import 'package:wallet_exe/data/model/Transaction.dart';
// import 'package:wallet_exe/widgets/card_transaction.dart';

// class TransactionFragment extends StatefulWidget {
//   const TransactionFragment({Key? key}) : super(key: key);

//   @override
//   _TransactionFragmentState createState() => _TransactionFragmentState();
// }

// class _TransactionFragmentState extends State<TransactionFragment> {
//   DateTime selectedDate = DateTime.now();
//   String _currentOption = "Tất cả";

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate,
//       firstDate: DateTime(2015, 8),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null && picked != selectedDate) {
//       setState(() {
//         selectedDate = picked;
//       });
//     }
//     print(selectedDate);
//   }

//   List<DropdownMenuItem<String>> _getDropDownMenuItems(List<String> listItem) {
//     return listItem
//         .map((option) => DropdownMenuItem<String>(
//               value: option,
//               child: Text(option),
//             ))
//         .toList();
//   }

//   List<Widget> _createListCardTransaction(List<Transaction> list) {
//     List<Widget> result = [];
//     List<Transaction> filter = list;

//     if (_currentOption != "Tất cả") {
//       filter =
//           list.where((item) => item.account.name == _currentOption).toList();
//     }

//     // Nếu người dùng chọn ngày cụ thể
//     if (selectedDate.day != DateTime.now().day ||
//         selectedDate.month != DateTime.now().month ||
//         selectedDate.year != DateTime.now().year) {
//       filter = filter
//           .where((item) =>
//               item.date.year == selectedDate.year &&
//               item.date.month == selectedDate.month &&
//               item.date.day == selectedDate.day)
//           .toList();
//       result.add(CardTransaction(filter, selectedDate));
//       return result;
//     }

//     // Giao dịch trong 7 ngày gần nhất
//     DateTime flagDate = DateTime.now();
//     for (int i = 0; i < 7; i++) {
//       List<Transaction> dayTransactions = filter
//           .where((item) =>
//               item.date.year == flagDate.year &&
//               item.date.month == flagDate.month &&
//               item.date.day == flagDate.day)
//           .toList();

//       result.add(CardTransaction(dayTransactions, flagDate));
//       result.add(const SizedBox(height: 15));
//       flagDate = flagDate.subtract(const Duration(days: 1));
//     }

//     return result;
//   }

//   void changedDropDownItem(String? selectedOption) {
//     if (selectedOption != null) {
//       setState(() {
//         _currentOption = selectedOption;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final blocAccount = AccountBloc();
//     final blocTransaction = TransactionBloc();
//     blocAccount.initData();
//     blocTransaction.initData();

//     return StreamBuilder<List<Transaction>>(
//       stream: blocTransaction.transactionListStream,
//       builder: (context, snapshot) {
//         switch (snapshot.connectionState) {
//           case ConnectionState.active:
//             return Container(
//               child: Column(
//                 children: <Widget>[
//                   Padding(
//                     padding: const EdgeInsets.all(15),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: <Widget>[
//                         Row(
//                           children: <Widget>[
//                             Text(
//                               'Tài khoản:',
//                               style: Theme.of(context)
//                                   .textTheme
//                                   .titleLarge, // Thay vì headline6
//                             ),
//                             const SizedBox(width: 10),
//                             FutureBuilder<List<String>>(
//                               future: AccountTable().getAllAccountName(),
//                               builder: (context, snapshot2) {
//                                 if (snapshot2.hasError) {
//                                   return Text('Lỗi: ${snapshot2.error}');
//                                 } else if (snapshot2.hasData) {
//                                   return DropdownButton<String>(
//                                     value: _currentOption,
//                                     items:
//                                         _getDropDownMenuItems(snapshot2.data!),
//                                     onChanged: changedDropDownItem,
//                                   );
//                                 }
//                                 return const SizedBox(
//                                   width: 50,
//                                   height: 50,
//                                   child: CircularProgressIndicator(),
//                                 );
//                               },
//                             ),
//                           ],
//                         ),
//                         TextButton(
//                           onPressed: () => _selectDate(context),
//                           child: Row(
//                             children: const <Widget>[
//                               Text('Tìm ngày'),
//                               SizedBox(width: 5),
//                               Icon(Icons.create, size: 20),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Column(
//                     children: _createListCardTransaction(snapshot.data ?? []),
//                   ),
//                 ],
//               ),
//             );

//           case ConnectionState.waiting:
//             return const Center(
//               child: SizedBox(
//                 width: 100,
//                 height: 50,
//                 child: Text('Bạn chưa có giao dịch nào'),
//               ),
//             );

//           default:
//             return const Center(
//               child: SizedBox(
//                 width: 50,
//                 height: 50,
//                 child: CircularProgressIndicator(),
//               ),
//             );
//         }
//       },
//     );
//   }
// }
