import 'package:flutter/material.dart';
import 'package:wallet_exe/bloc/spend_limit_bloc.dart';
import 'package:wallet_exe/data/model/SpendLimit.dart';
import 'package:wallet_exe/event/spend_limit_event.dart';
import 'package:wallet_exe/pages/spend_limit_type_page.dart';
import 'package:wallet_exe/utils/text_input_formater.dart';

class SpendLimitPage extends StatefulWidget {
  final SpendLimit _spendLimit;
  final SpendLimitBloc bloc;
  SpendLimitPage(this._spendLimit, this.bloc);

  @override
  _SpendLimitPageState createState() => _SpendLimitPageState();
}

class _SpendLimitPageState extends State<SpendLimitPage> {
  final _spendLimitController = TextEditingController();
  final _formspendLimitKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _spendLimitController.text = widget._spendLimit.amount != null
        ? widget._spendLimit.amount.toString()
        : '';
  }

  @override
  Widget build(BuildContext context) {
    void _submit() {
      if (!(_formspendLimitKey.currentState?.validate() ?? false)) return;

      SpendLimit item = SpendLimit(
        amount: currencyToInt(_spendLimitController.text),
        type: widget._spendLimit.type,
      );
      item.id = widget._spendLimit.id;
      widget.bloc.event.add(UpdateSpendLimitEvent(item));

      Navigator.pop(context);
    }

    Future<void> _chooseType() async {
      var temp = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SpendLimitTypePage(widget._spendLimit.type),
        ),
      );

      if (temp != null) {
        setState(() {
          widget._spendLimit.type = temp;
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Sửa hạn mức'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _submit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.blueGrey
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0.0, 15.0),
                      blurRadius: 15.0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hạn mức',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Form(
                            key: _formspendLimitKey,
                            child: TextFormField(
                              validator: (String? value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Số tiền phải lớn hơn 0';
                                }
                                return currencyToInt(value) <= 0
                                    ? 'Số tiền phải lớn hơn 0'
                                    : null;
                              },
                              controller: _spendLimitController,
                              textAlign: TextAlign.end,
                              inputFormatters: [CurrencyTextFormatter()],
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                              ),
                              keyboardType: TextInputType.numberWithOptions(
                                signed: true,
                                decimal: true,
                              ),
                              autofocus: true,
                              decoration: InputDecoration(
                                suffixText: 'đ',
                                suffixStyle: Theme.of(context)
                                    .textTheme
                                    .headlineMedium ??
                                    TextStyle(fontSize: 20),
                                prefix: Icon(
                                  Icons.monetization_on,
                                  color:
                                  Theme.of(context).colorScheme.secondary,
                                  size: 26,
                                ),
                                hintText: '0',
                                hintStyle: TextStyle(
                                  color: Colors.red,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.blueGrey
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0.0, 15.0),
                      blurRadius: 15.0,
                    ),
                  ],
                ),
                width: double.infinity,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: InkWell(
                        onTap: () {},
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              child: Icon(
                                Icons.subject,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: InkWell(
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              child: Icon(
                                Icons.timelapse,
                                size: 28,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                widget._spendLimit.type.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Icon(Icons.keyboard_arrow_right),
                          ],
                        ),
                        onTap: _chooseType,
                      ),
                    ),
                    SizedBox(height: 30),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: _submit,
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.save, size: 28),
                                    SizedBox(width: 5),
                                    Text(
                                      'Lưu',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _spendLimitController.dispose();
    super.dispose();
  }
}