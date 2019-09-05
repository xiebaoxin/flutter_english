import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import '../../constants/index.dart';
import '../../routers/application.dart';
import '../../utils/screen_util.dart';
import '../../model/goods.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../model/globle_model.dart';
import '../../model/buy_model.dart';
import '../../utils/comUtil.dart';
import '../../components/addplus.dart';
import '../buygoods_page.dart';

class AddCartItemWidget extends StatefulWidget {
  final GoodInfo goodsinfo;
  final String action;
  final int count;
  AddCartItemWidget(this.goodsinfo, {this.action = '0', this.count = 1});

  @override
  AddCartItemWidgetState createState() => new AddCartItemWidgetState();
}

class AddCartItemWidgetState extends State<AddCartItemWidget> {
  TextEditingController _countcontroller = new TextEditingController();
  final FocusNode _focusNode = FocusNode();

  int _count = 1;
  String _price = "0.00";
  GoodSpcPrice _sppcitem;
  Map<String, String> _specselect = {};
  String _spcstr = "";
  String _goods_item_id = "0";
  GoodInfo _goodsinfo;

  @override
  void initState() {
    // TODO: implement initState
    _goodsinfo = widget.goodsinfo;
    _price = widget.goodsinfo.presentPrice;
    _count = widget.count;
    _countcontroller.text = _count.toString();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didUpdateWidget(AddCartItemWidget oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final model = globleModel().of(context);
    List<GoodSpcListItem> itdlist = _goodsinfo.specMapList;
    return Container(
        width: ScreenUtil.screenWidthDp,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              buildplusadd(),
              Divider(
                height: 1,
              ),
              itdlist.isNotEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: itdlist.map((it) {
                        List<GoodSpc> itds = it.items;
                        return Container(
                            margin: EdgeInsets.fromLTRB(10, 2, 10, 3),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
//                    const Divider(height: 5,),
                                Text(
                                  it.sname + ":",
                                  style: TextStyle(fontSize: 12),
                                ),
                                Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: itds.map((iti) {
                                      _specselect[it.sname] =
                                          _specselect[it.sname] ?? iti.item_id;
                                      return ChoiceChip(
                                        key: ValueKey<String>(iti.item_id),
                                        label: Text(
                                          iti.item,
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Color(0xFFFFFFFF)),
                                        ),
                                        //未选定的时候背景
                                        selectedColor: Color(0xFF85BB58),
                                        //被禁用得时候背景
//                            disabledColor: Colors.grey,
                                        backgroundColor: Colors.grey,
                                        selected: _specselect[it.sname] ==
                                            iti.item_id,
                                        onSelected: (bool value) {
//                              parent.onSelectedChanged(index);
                                          setState(() {
                                            _specselect[it.sname] = iti.item_id;
                                            print(_specselect);
                                            _spcstr = getspcstr();
                                            print(_spcstr);
                                            if (_spcstr.isNotEmpty) {
                                              _sppcitem =
                                                  _goodsinfo.findSpcItem(
                                                      _spcstr); //"9_12_16"
                                              print(_sppcitem);
                                              if (_sppcitem != null) {
                                                _price = _sppcitem.price;
                                                _goods_item_id =
                                                    _sppcitem.item_id;
                                                print(
                                                    "Item_id:${_goods_item_id},price:${_price}");
                                              }
                                            }
                                          });
                                        },
                                      );
                                      //                      return Text(iti.item);
                                    }).toList()),
                              ],
                            ));
                      }).toList(),
                    )
                  : SizedBox(
                      height: 5,
                    ),
              Divider(
                height: 1,
              ),
              Container(
                height: 50,
                child: ComFunUtil().buildMyButton(
                  context,
                  widget.action == '0' ? '确定购买' : '加入购物车',
                  () {
                    Application().checklogin(context, () async {
                      Navigator.pop(context);

                      if (widget.action == '0') {
                        BuyModel param = BuyModel(
                            goodsinfo: _goodsinfo,
                            goods_id: _goodsinfo.goodsId.toString(),
                            goods_num: _count.toString(),
                            item_id: _goods_item_id,
                            imgurl: _goodsinfo.comPic,
                            goods_price:
                                double.tryParse(_goodsinfo.presentPrice));

                        Navigator.push(
                            context,
                            MaterialPageRoute(
//                            builder: (context) => BuyPage(param),
                              builder: (context) => GoodsBuyPage(param),
                            ));
                      } else {
                        Map<String, String> params = {
                          'goods_id': _goodsinfo.goodsId.toString(),
                          'goods_num': _count.toString(),
                          'item_id': _goods_item_id,
                        };
                        await model.addtocart(context, params);

                      }
                    });
                  },
                  width: ScreenUtil().L(100),
                ),
              ),
            ],
          ),
        ));
  }

  String getspcstr() {
    List<String> tsplist = _goodsinfo.specNameList;
    String retstr = "";
    if (_specselect.length == tsplist.length) {
      tsplist.forEach((v) {
        retstr = retstr + (_specselect[v] + "_");
      });
    }
    return retstr.substring(0, (retstr.length - 1));
  }

  GoodSpcPrice findSpcItem(String spcname) {
    _goodsinfo.specMapPriceList.forEach((v) {
      GoodSpcPrice item = v.items;
      if (item.key == spcname.toString()) {
        print(item);
        print(v.keyname + "======" + item.price);
        return item;
      }
    });
    return null;
  }

  Widget _buildListView(List<GoodSpcListItem> itdlist) {
    var length = itdlist.length;
    return ListView.builder(
      itemCount: length,
      itemBuilder: (BuildContext context, int index) {
        List<GoodSpc> itds = itdlist[index].items;
        return Row(
          children: <Widget>[
            Text(
              itdlist[index].sname,
              style: TextStyle(fontSize: 12),
            ),
            Wrap(
                spacing: 8,
                runSpacing: 8,
                children: itds.map((iti) {
                  return ChoiceChip(
                    key: ValueKey<String>(iti.item_id),
                    label: Text(
                      iti.item,
                      style: TextStyle(fontSize: 10),
                    ),
                    //未选定的时候背景
                    selectedColor: Color(0xff182740),
                    //被禁用得时候背景
                    disabledColor: Colors.grey[300],
                    selected: false,
                    onSelected: (bool value) {
                      setState(() {
                        _specselect.putIfAbsent(
                            itdlist[index].sname, () => iti.item_id);
                        print(_specselect);
                      });
                    },
                  );
                  //                      return Text(iti.item);
                }).toList()),
          ],
        );
      },
    );
  }

  Widget buildplusadd() {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10, right: 10, left: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 8, right: 8),
            width: 50,
            height: 50,
            child: Image.network(_goodsinfo.comPic, fit: BoxFit.fill),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                    _goodsinfo.goodsName.length <= 12
                        ? _goodsinfo.goodsName
                        : _goodsinfo.goodsName.substring(0, 12) + "…",
                    style: TextStyle(fontSize: 12)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      '￥$_price',
                      style: TextStyle(
                          fontSize: 14, color: KColorConstant.priceColor),
                    ),
                    AddPlus(
                        count: _count,
                        max: int.parse(_goodsinfo.amount),
                        callback: (v) {
                          setState(() {
                            print(v);
                            _count = v;
                          });
                        })
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
