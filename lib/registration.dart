import 'dart:async';

import 'package:flutter/material.dart';

class ResultPage extends StatefulWidget {
//  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<String> _strings;

  ResultPage(this._strings);

  @override
  _ResultPageState createState() => _ResultPageState(_strings);
}

class _ResultPageState extends State<ResultPage> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final List<String> _strings;

  _ResultPageState(this._strings);

  TextEditingController _controler_name;
  TextEditingController _controler_kana;
  TextEditingController _controler_birthday;
  TextEditingController _controler_insurance_num;
  TextEditingController _controler_insurance_kigo;
  TextEditingController _controler_insurance_no;

  List<String> sexes = <String>['', '男性', '女性'];
  String sex = '';

  @override
  void initState() {
    print('initState[in]');
    _controler_name = TextEditingController();
    _controler_kana = TextEditingController();
    _controler_birthday = TextEditingController();
    _controler_insurance_num = TextEditingController();
    _controler_insurance_kigo = TextEditingController();
    _controler_insurance_no = TextEditingController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('build[in]');
    return new Scaffold(
      appBar: new AppBar(
        title: Text('HealtheeOne'),
        actions: <Widget>[
          new IconButton(icon: const Icon(Icons.cloud_upload), onPressed: () {})
        ],
      ),
    body: new SafeArea(
    top: false,
    bottom: false,
    child: Form(
        key: _formKey,
        autovalidate: true,
        child: Column(
          children: <Widget>[
            getListTitle(_controler_name, '氏名', '山田　太郎', ''),
            getListTitle(_controler_kana, 'カナ氏名', 'ヤマダ　タロウ', ''),
            ListTile(
              title: InputDecorator(
                decoration: const InputDecoration(
                  labelText: '性別',
                ),
                isEmpty: sex == '',
                child: new DropdownButtonHideUnderline(
                  child: new DropdownButton<String>(
                    value: sex,
                    isDense: true,
                    onChanged: (String newValue) {
                      setState(() {
                        sex = newValue;
                        print('_color:$sex');
                      });
                    },
                    items: sexes.map((String value) {
                      return new DropdownMenuItem<String>(
                        value: value,
                        child: new Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            getListTitle(_controler_birthday, '生年月日', null, '20180401'),
            getListTitle(_controler_insurance_num, '保険者番号', null, ''),
            getListTitle(_controler_insurance_kigo, '記号', null, ''),
            getListTitle(_controler_insurance_no, '番号', null, ''),
          ],
        )
    ))
    );
  }

  ListTile getListTitle(TextEditingController controller, String label,
      String initialvalue, String hint) {
    if (initialvalue != null) controller.text = initialvalue;
    return ListTile(
      title: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, hintText: hint),
      ),
      trailing: IconButton(
        icon: Icon(Icons.arrow_drop_down),
        onPressed: () {
          _showDialog(controller);
        },
      ),
    );
  }

  Future<Null> _showDialog(TextEditingController controller) async {
    var list = List<Widget>();
    _strings.forEach((value) => list.add(createOption(controller, value)));
    print('_askedToLead:${list.length}');

    switch (await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return new SimpleDialog(children: list);
        })) {
//      case Department.treasury:
//      // Let's go.
//      // ...
//        break;
//      case Department.state:
//      // ...
//        break;
    }
  }

  SimpleDialogOption createOption(
      TextEditingController controller, String item) {
    return SimpleDialogOption(
      onPressed: () {
        controller.text = item;
        Navigator.pop(context);
      },
      child: Text(item),
    );
  }
}
