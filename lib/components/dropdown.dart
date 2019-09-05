import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import '../utils/HttpUtils.dart';

class citySelector {
  int pid;
  citySelector({this.pid = 0});

  List<String> _bankPickerData = new List();
  Map<String, String> _bankCodeMap = {}; //
  String _bankName;
  String _bankId;

  Future  showBankPicker(BuildContext context,Function callback) async {
    await HttpUtils.dioappi(
      'Api/getregion/pid/${this.pid}',
      {},
    ).then((response) {
        response['data'].forEach((ele) {
          if (ele.isNotEmpty) {
            _bankPickerData.add(ele['name'].toString());
            _bankCodeMap[ele['name']] = ele['id'].toString();
          }
        });
    });
   await new Picker(
        adapter: PickerDataAdapter<String>(pickerdata: _bankPickerData),
        hideHeader: true,
        title: new Text("城市列表"),
        cancelText: '取消',
        confirmText: '确定',
        onConfirm: (Picker picker, List value) {
          _bankName = picker.getSelectedValues()[0].toString();
          _bankId = _bankCodeMap[_bankName];
          print("bankId:$_bankId");
          callback(_bankId,_bankName);
        }).showDialog(context);
  }

}
