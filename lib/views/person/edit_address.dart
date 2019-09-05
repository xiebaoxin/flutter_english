import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../utils/comUtil.dart';
import '../../components/dropdown.dart';
import '../../utils/HttpUtils.dart';
import '../../utils/DialogUtils.dart';
import '../../routers/application.dart';
import '../../globleConfig.dart';

class EditAddressPage extends StatefulWidget {
  EditAddressPage({Key key, this.addressId = 0, this.address})
      : super(key: key);

  final int addressId;
  final Map<String, dynamic> address;

  @override
  EditAddressPageState createState() => EditAddressPageState();
}

class EditAddressPageState extends State<EditAddressPage> {
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  TextEditingController _cscontroller = new TextEditingController();
  TextEditingController _mbcountCtrl = new TextEditingController();
  TextEditingController _adrCtroller = new TextEditingController();
  TextEditingController _ctCtroller = new TextEditingController();

  String _selectedAddressStr = '';
  TextEditingController _provinceCtr = new TextEditingController();
  TextEditingController _cityCtr = new TextEditingController();
  TextEditingController _areaCtr = new TextEditingController();
  TextEditingController _townCtr = new TextEditingController();
  String _provinceName = '';
  String _cityName = '';
  String _areaName = '';
  String _townName = '';
  String _provinceId, _cityId, _areaId, _townId;
  bool _switchValue = true;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.addressId == 0 ? "添加收货地址" : "编辑收货地址"),
        ),
        body: Form(
          //绑定状态属性
            key: _formKey,
            autovalidate: true,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _cscontroller,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(10.0),
                            hintText: widget.addressId == 0
                                ? '请输入收货人名称'
                                : widget.address['consignee'],
                            icon: Icon(Icons.person)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _mbcountCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(10.0),
                            hintText: widget.addressId == 0
                                ? '请输入收货人联系方式'
                                : widget.address['mobile'],
                            icon: Icon(Icons.phone)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Icons.location_city,
                            color: Colors.black45,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Text("省："),
                                  InkWell(
                                    child: Text(
                                        "${_provinceName != "" ? _provinceName : '选择省'}"),
                                    onTap: () {
                                      _selectCity(0);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          width: 8,
                        ),
                        Icon(
                          Icons.account_balance,
                          color: Colors.black45,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text("市："),
                        InkWell(
                          child: Text(
                              "${_cityName.toString() != "" ? _cityName : ' 选择市'}"),
                          onTap: () {
                            _selectCity(1);
                          },
                        ),
                      ],
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text("县："),
                            InkWell(
                              child: Text(
                                  "${_areaName.toString() != "" ? _areaName : ' 选择县'}"),
                              onTap: () {
                                _selectCity(2);
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text("街道："),
                            InkWell(
                              child: Text(
                                  "${_townName.toString() != "" ? _townName : ' 选择街道'}"),
                              onTap: () {
                                _selectCity(3);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(),
                    /*   GestureDetector(
                      child: Cell(
                        widget.addressId == 0 ? "收货地址" : "",
                        isJump: true,
                        content: _selectedAddressStr,
                      ),
                      onTap: () {
                        _selectCity(context);
                      },
                    ),*/
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _adrCtroller,
                          maxLines: 2,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10.0),
                              hintText: widget.addressId == 0
                                  ? '详细地址'
                                  : widget.address['address'],
                              icon: Icon(Icons.home)),
                        )),
                    const SizedBox(height: 2.0),

                    Semantics(
                      container: true,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8,0,8,0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              "设置为默认",
                              style: KfontConstant.defaultSubStyle,
                            ),
                            Switch(
                              value: _switchValue,
                              activeColor: Colors.deepOrange,
                              onChanged: (bool value) {
                                setState(() {
                                  _switchValue = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                    ),

                    const SizedBox(height: 10.0),
                    ComFunUtil().buildMyButton(context, '确定', () {
                      submit();
                    }, disabled: _adrCtroller.text != '' ? false : true),
                    const SizedBox(height: 10.0),
                  ],
                ),
              ),
            )));
  }

  void _selectCity(int stp) async {
    if (stp == 0) {
      await citySelector(pid: 0).showBankPicker(context,
              (String id, String name) {
            setState(() {
              _selectedAddressStr="";
              _cityName = "";
              _cityId = "";
              _areaName = "";
              _areaId = "";
              _townName = "";
              _townId = "";

              _provinceCtr.text = name;
              _provinceName = name;
              _provinceId = id;
              _selectedAddressStr = _provinceName;
              _adrCtroller.text = _selectedAddressStr;
            });
          });
    }

    if (stp == 1 && _provinceId!="") {
      await citySelector(pid: int.tryParse(_provinceId)).showBankPicker(context,
              (String id, String name) {
            setState(() {
              _areaName = "";
              _areaId = "";
              _townName = "";
              _townId = "";

              _cityCtr.text = name;
              _cityName = name;
              _cityId = id;
              _selectedAddressStr = _selectedAddressStr + _cityName;
              _adrCtroller.text = _selectedAddressStr;
            });
          });
    }
    if (stp == 2 && _cityId!="") {
      await citySelector(pid: int.tryParse(_cityId)).showBankPicker(context,
              (String id, String name) {
            setState(() {
              _townName = "";
              _townId = "";

              _areaCtr.text = name;
              _areaName = name;
              _areaId = id;
              _selectedAddressStr =_selectedAddressStr + _areaName;
              _adrCtroller.text = _selectedAddressStr;
            });
          });
    }
    if (stp == 3 && _areaId!="") {
      await citySelector(pid: int.tryParse(_areaId)).showBankPicker(context,
              (String id, String name) {
            setState(() {
              _townName = name;
              _townCtr.text = name;
              _townId = id;
              _selectedAddressStr =_selectedAddressStr + _townName;
              _adrCtroller.text = _selectedAddressStr;
            });
          });
    }

  }

  submit() async {
    final form = _formKey.currentState;

    String yuyueday = _cscontroller.text;
    if (yuyueday.isEmpty) {
      DialogUtils.showToastDialog(context, "姓名不能为空");
      return;
    }
    String dh = _mbcountCtrl.text;
    if (dh.isEmpty) {
      DialogUtils.showToastDialog(context, "电话不能为空");
      return;
    }

    if (_areaId.isEmpty) {
      DialogUtils.showToastDialog(context, "城市不能为空");
      return;
    }

    if (form.validate()) {
      form.save();

      Map<String, String> params = {
        "consignee": _cscontroller.text.toString(),
//      "country":,
        "province": _provinceId,
        "city": _cityId,
        "district": _areaId,
        "twon": _townId,
        "address": _adrCtroller.text.toString(),
        "mobile": _mbcountCtrl.text.toString(),
        "address_id": widget.addressId != 0 ? widget.addressId.toString() : "",
        "is_default":_switchValue?"1":"0"
      };

      Application().checklogin(context, () async {
        await HttpUtils.dioappi('User/addressSave', params,
            withToken: true, context: context)
            .then((response) async {
//          await DialogUtils.showToastDialog(context, response['msg'].toString());
          if (response['status'].toString() == '1') {
            Navigator.of(context).pop(true);
          }
        });
      });
    }
    ;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.addressId != 0) {
      _cscontroller.text = widget.address['consignee'];
      _mbcountCtrl.text = widget.address['mobile'];
      _adrCtroller.text = widget.address['address'];

      _provinceId= widget.address['province'].toString();
      _cityId= widget.address['city'].toString();
      _areaId= widget.address['district'].toString();
      _townId= widget.address['twon'].toString();
      _provinceName = widget.address['provinceName'];
      _cityName = widget.address['cityName'];
      _areaName =  widget.address['districtName'];
      _townName =  widget.address['twonName'];
    }

  }
}

class Cell extends StatelessWidget {
  final title;

  final content;

  final isJump;

  final jumpPageName;

  final type;

  final isTop;

  const Cell(
      this.title, {
        Key key,
        this.content,
        this.isJump,
        this.jumpPageName,
        this.type,
        this.isTop,
      })  : assert(title != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Divider(
          height: isTop ?? false ? 1 : 0,
        ),
        Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(8, 12, 8, 12),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  this.title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                child: _getContent(),
              ),
              _jump()
            ],
          ),
        ),
        Divider(
          height: 1,
        )
      ],
    );
  }

  _getContent() {
    var _type = type ?? "text";
    if (_type == "text") {
      var _content = content ?? "";
      return Container(
        alignment: Alignment.centerRight,
        child: Text(_content),
      );
    }
    if (type == "AssetImage") {
      return Container(
        alignment: Alignment.centerRight,
        child: SizedBox(
          height: 40,
          width: 40,
          child: CircleAvatar(radius: 20, backgroundImage: content),
        ),
      );
    }
    return Container(width: 0, height: 0);
  }

  _jump() {
    if (this.isJump ?? false) {
      return Expanded(
          flex: 1,
          child: Container(
            alignment: Alignment.centerRight,
            child: Icon(
              Icons.chevron_left,
              textDirection: TextDirection.rtl,
            ),
          ));
    }
    return Container(width: 0, height: 0);
  }
}
