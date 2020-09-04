import 'package:flutter/material.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/assets.dart';

class PriceMain extends StatefulWidget {
  bool selling;
  PriceMain(this.selling);
  @override
  _PriceMainState createState() => _PriceMainState();
}

class _PriceMainState extends State<PriceMain> with TickerProviderStateMixin {
  //bool setup = false;
  List priceList = List();
  bool selling;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selling = widget.selling;
    priceList =
        List.from(appSettingsModel.getList(selling ? SELL_PRICE : PRICE));
    //loadPrice();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        List<Map> list = List();
        for (Map map in priceList) {
          if (map.length < 3) continue;

          Map m = Map();
          m.addAll(map);
          list.add(m);
        }
        appSettingsModel.put(selling ? SELL_PRICE : PRICE, list);
        appSettingsModel.updateItems();
        Navigator.pop(context);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: white,
        body: page(),
      ),
    );
  }

  BuildContext con;

  Builder page() {
    return Builder(builder: (context) {
      this.con = context;
      return new Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          addSpace(30),
          new Container(
            width: double.infinity,
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      child: Center(
                          child: Icon(
                        Icons.keyboard_backspace,
                        color: black,
                        size: 25,
                      )),
                    )),
                Flexible(
                  fit: FlexFit.tight,
                  flex: 1,
                  child: new Text(
                    selling ? "Sell Prices" : "Buy Prices",
                    style: textStyle(true, 17, red0),
                  ),
                ),
                addSpaceWidth(15),
                FlatButton(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    color: blue3,
                    onPressed: () {
                      setState(() {
                        priceList.add(Map());
                      });
                    },
                    child: Text(
                      "ADD",
                      style: textStyle(true, 14, white),
                    )),
                addSpaceWidth(15)
              ],
            ),
          ),
          addLine(1, black.withOpacity(.1), 0, 0, 0, 0),
          new Expanded(
            flex: 1,
            child:
                /* !setup
                ? loadingLayout()
                : setup && */
                priceList.isEmpty
                    ? emptyLayout(
                        ic_coin,
                        "Nothing to Display",
                        "",
                      )
                    : Container(
                        color: white,
                        child: Scrollbar(
                          child: new ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.all(0),
                            itemBuilder: (c, p) {
                              Map price = priceList[p];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  p != 0
                                      ? Container()
                                      : Container(
                                          //color: blue09,
                                          height: 50,
                                          margin: EdgeInsets.fromLTRB(
                                              10, 10, 10, 0),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Flexible(
                                                flex: 1,
                                                fit: FlexFit.tight,
                                                child: Text(
                                                  "CREDITS",
                                                  textAlign: TextAlign.center,
                                                  style: textStyle(true, 15,
                                                      black.withOpacity(.5)),
                                                ),
                                              ),
                                              Flexible(
                                                flex: 1,
                                                fit: FlexFit.tight,
                                                child: Text(
                                                  "USD",
                                                  textAlign: TextAlign.center,
                                                  style: textStyle(true, 18,
                                                      black.withOpacity(.5)),
                                                ),
                                              ),
                                              Flexible(
                                                flex: 1,
                                                fit: FlexFit.tight,
                                                child: Text(
                                                  "NGN",
                                                  textAlign: TextAlign.center,
                                                  style: textStyle(true, 18,
                                                      black.withOpacity(.5)),
                                                ),
                                              ),
                                              addSpaceWidth(40)
                                            ],
                                          )),
                                  new Card(
                                    elevation: .5,
                                    margin: EdgeInsets.all(10),
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          priceItem(
                                              price[CREDITS] == null
                                                  ? ""
                                                  : price[CREDITS]
                                                      .toInt()
                                                      .toString(), (_) {
                                            price[CREDITS] =
                                                _.toString().isEmpty
                                                    ? null
                                                    : double.parse(_);
                                          }),
                                          addSpaceWidth(20),
                                          priceItem(
                                              price[IN_USD] == null
                                                  ? ""
                                                  : price[IN_USD].toString(),
                                              (_) {
                                            price[IN_USD] = _.toString().isEmpty
                                                ? null
                                                : double.parse(_);
                                          }),
                                          addSpaceWidth(20),
                                          priceItem(
                                              price[IN_NAIRA] == null
                                                  ? ""
                                                  : price[IN_NAIRA].toString(),
                                              (_) {
                                            price[IN_NAIRA] =
                                                _.toString().isEmpty
                                                    ? null
                                                    : double.parse(_);
                                          }),
                                          addSpaceWidth(10),
                                          InkWell(
                                            onTap: () {
                                              priceList.removeAt(p);
                                              setState(() {});
                                            },
                                            child: Container(
                                              width: 30,
                                              height: 30,
                                              //margin: EdgeInsets.fromLTRB(6, 0, 0, 0),
                                              color: blue09,
                                              child: Center(
                                                child: Icon(
                                                  Icons.close,
                                                  size: 12,
                                                  color: black.withOpacity(.5),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                            itemCount: priceList.length,
                          ),
                        )),
          ),
        ],
      );
    });
  }

  priceItem(String text, onChanged) {
    return Flexible(
      flex: 1,
      fit: FlexFit.tight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: TextEditingController(text: text),
            decoration: InputDecoration(border: InputBorder.none),
            style: textStyle(true, 20, black),
            cursorColor: black,
            cursorWidth: 1,
            keyboardType: TextInputType.number,
            onChanged: onChanged,
            textAlign: TextAlign.center,
          ),
          addLine(2, blue0, 0, 0, 0, 0)
        ],
      ),
    );
  }
}
