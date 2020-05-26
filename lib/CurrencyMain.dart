import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Strokes/AppEngine.dart';
import 'package:Strokes/assets.dart';
import 'package:Strokes/basemodel.dart';
import 'package:Strokes/dialogs/inputDialog.dart';
import 'package:Strokes/dialogs/listDialog.dart';
import 'package:Strokes/main.dart';

class CurrencyMain extends StatefulWidget {
  @override
  _CurrencyMainState createState() => _CurrencyMainState();
}

class _CurrencyMainState extends State<CurrencyMain> with TickerProviderStateMixin {
  //bool setup = false;
  List currencyList = List();
  bool setup = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadItems();
  }

  loadItems()async{
    QuerySnapshot shots = await Firestore.instance.collection(CURRENCY_BASE).getDocuments();
    for(DocumentSnapshot doc in shots.documents){
      BaseModel model = BaseModel(doc:doc);
      currencyList.add(model);
    }

    setup=true;
    setState(() {

    });
  }

  createItems(){
    List currencies = [
      "BIF",
      "CAD",
      "CDF",
      "CVE",
      "EUR",
      "GBP",
      "GHS",
      "GMD",
      "GNF",
      "KES",
      "LRD",
      "MWK",
      "MZN",
      "NGN",
      "RWF",
      "SLL",
      "STD",
      "TZS",
      "UGX",
      "USD",
      "XAF",
      "XOF",
      "ZAR",
      "ZMW",
      "ZWD",
    ];

    for(String s in currencies){
     BaseModel model = BaseModel();
     model.put(CURRENCY, s);
     model.put(OBJECT_ID, s);
     model.saveItem(CURRENCY_BASE, false,document: s);
     currencyList.add(model);
    }

    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: default_white,
      body: page(),
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
                    "Currency Rates",
                    style: textStyle(true, 17, red0),
                  ),
                ),
                addSpaceWidth(15)
              ],
            ),
          ),
          addLine(1, black.withOpacity(.1), 0, 0, 0, 0),
          new Expanded(
            flex: 1,
            child:
                 !setup
                ? loadingLayout() : Container(
                        color: default_white,
                        child: Scrollbar(
                          child: new ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.all(0),
                            itemBuilder: (c, p) {
                              BaseModel bm = currencyList[p];
                              List countries = bm.getList(COUNTRY);
                              return Container(
                                margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                child: Card(
                                  elevation: .5,
                                  color: white,
                                  clipBehavior: Clip.antiAlias,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(bm.getString(CURRENCY),style: textStyle(true, 25, black.withOpacity(.5)),),
                                        addSpace(10),
                                        GestureDetector(
                                          onTap: (){
                                            pushAndResult(context, inputDialog("Dollar Rate",
                                            message: bm.getDouble(IN_USD).toString(),inputType: TextInputType.number,),result: (_){
                                              double usd = double.parse(_.toString());
                                              bm.put(IN_USD, usd);
                                              bm.updateItems();
                                            });
                                          },
                                          child: Container(
                                            padding:EdgeInsets.fromLTRB(10, 5, 10, 5),
                                            decoration: BoxDecoration(color: bm.getDouble(IN_USD)==0?blue09:blue0,borderRadius: BorderRadius.all(Radius.circular(25)),border: Border.all(color: black.withOpacity(.1),width: .5)),
                                            child: Text("Dollar Rate: ${bm.getDouble(IN_USD)}",
                                              style: textStyle(true, 14, bm.getDouble(IN_USD)==0?black:white),),
                                          ),
                                        ),
                                        if(countries.isNotEmpty)addSpace(10),
                                        if(countries.isNotEmpty)SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,padding: EdgeInsets.all(0),
                                          child: Row(
                                            children: List.generate(countries.length, (index){
                                              String code = countries[index];
                                              String name = CountryPickerUtils.getCountryByIsoCode(code).name;
                                              return GestureDetector(
                                                onTap: (){
                                                  yesNoDialog(context, "Remove $name?", "Are your sure?", (){
                                                    countries.removeAt(index);
                                                    bm.put(COUNTRY, countries);
                                                    bm.updateItems();
                                                    setState(() {

                                                    });
                                                  });
                                                },
                                                child: Container(
                                                  padding:EdgeInsets.fromLTRB(10, 5, 10, 5),
                                                  margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                                  decoration: BoxDecoration(color: white,borderRadius: BorderRadius.all(Radius.circular(25)),border: Border.all(color: black.withOpacity(.1),width: 1)),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Text(name,
                                                        style: textStyle(true, 14, black),),
                                                      addSpaceWidth(10),
                                                       Container(width: 15,height: 15,
                                                           child: CountryPickerUtils.getDefaultFlagImage(CountryPickerUtils.getCountryByIsoCode(code))),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }),
                                          ),
                                        ),

                                        addSpace(10),
                                        Container(
                                          height: 30,
//                                          width: 100,
//                                          margin: EdgeInsets.fromLTRB(20, 0, 10, 0),
                                          child: FlatButton(
                                            color: default_white,
                                            shape: RoundedRectangleBorder(side: BorderSide(color: blue0,width: 1)
                                            ,borderRadius: BorderRadius.all(Radius.circular(25))),
                                            onPressed: (){
                                              pickCountry(context, (country){
                                                countries.add(country.isoCode);
                                                bm.put(COUNTRY, countries);
                                                bm.updateItems();
                                                setState(() {

                                                });
                                              });
                                            }, child: Text("Add Country",style: textStyle(true, 12, black),),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            itemCount: currencyList.length,
                          ),
                        )),
          ),
        ],
      );
    });
  }

}
