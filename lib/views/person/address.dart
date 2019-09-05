import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../utils/HttpUtils.dart';
import '../../globleConfig.dart';
import 'edit_address.dart';

class AddressPage extends StatefulWidget {
  AddressPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  AddressPageState createState() => AddressPageState();
}

class AddressPageState extends State<AddressPage> {
  int page = 1;
  bool _loadOk = false;
  bool isLoading = false;
  List<Map<String, dynamic>> _addressList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _deleteAddress(addressid) {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('确认要删除吗?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('删除后将无法回复该收货地址'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('确认'),
              onPressed: () {
                Navigator.of(context).pop();
                deletefun(addressid);
              },
            ),
          ],
        );
      },
    );
  }
deletefun(addressid) async{
  Map<String, String> params = {
    "address_id":addressid
  };
  Map<String, dynamic> response = await HttpUtils.dioappi(
      'User/addressDelete', params,
      withToken: true, context: context);

  if (response['status'].toString() == '1') {
    _onRefresh();
  }

}
  defalutfun(addressid) async{
    Map<String, String> params = {
      "address_id":addressid
    };
    Map<String, dynamic> response = await HttpUtils.dioappi(
        'User/addressSetDefault', params,
        withToken: true, context: context);

    if (response['status'].toString() == '1') {
      _onRefresh();
    }

  }

  _loadData() async {
      Map<String, String> params = {};
      Map<String, dynamic> response = await HttpUtils.dioappi(
          'User/ajaxAddress', params,
          withToken: true, context: context);
      print(response);
      setState(() {
        _loadOk = true;
       response['result'].forEach((ele) {
          if (ele.isNotEmpty) {
            _addressList.add(ele);
          }
        });

      });
    }

  @override
  void dispose() {
    super.dispose();
  }

  void _onRefresh() {
    try {
      _addressList = [];
      _loadData();
    } catch (e) {
    }
  }

  Widget _addressItemCard(Map<String, dynamic> address) {
  return Column(
    children: <Widget>[
      ListTile(
        leading:Icon(Icons.location_city),
        isThreeLine: true,
        title:Row(
          children: <Widget>[
            Text("${address['consignee']}[${address['mobile']}]", ),
            address['is_default'].toString()!="1"? Container(
                padding: EdgeInsets.all(2),
                height: 24,
                decoration: BoxDecoration(
                    color: GlobalConfig.mainColor,
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(2.0, 0, 2, 0),
                  child: Center(
                    child: Text(
                      '默认',
                      style: TextStyle(
                          fontFamily: 'FZLanTing',
                          letterSpacing: 2,
                          color: Color(0xFFFFFFFF) ,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                )):Text(''),
          ],
        ),
        subtitle:  Text(
            "${address['address']}",style: KfontConstant.defaultSubStyle),
          trailing: Icon(Icons.edit),
          onTap: () {
            Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => new EditAddressPage(
                    addressId:int.tryParse(address['address_id'].toString())??0 ,address: address,
                  )),
            ).then((v){_onRefresh();});
          }
      ),

      Divider()
    ],
  );

  }

  Widget addressList() {
    num length = _addressList.length;
    return  ListView.builder(
      itemCount: length,
      itemBuilder: (BuildContext context, int index) {
        if (index >= length) {
          return null;
        }else{
          return _addressItemCard(_addressList[index]);
        }
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("收货地址"),
        leading: InkWell(child: Icon(Icons.arrow_back),onTap: (){
          Navigator.of(context).pop(true);
        },),
      ),
      body: _loadOk ?Center(child: addressList() ,) : Container(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            new MaterialPageRoute(builder: (context) => new EditAddressPage()),
          ).then((v){
            _onRefresh();
          });
        },
        tooltip: '添加收货地址',
        child: Icon(Icons.add),
      ),
    );
  }
}
