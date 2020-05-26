
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:timeago/timeago.dart' as timeAgo;

import 'AppEngine.dart';
import 'MainAdmin.dart';
import 'assets.dart';
import 'dialogs/inputDialog.dart';

class AddQuote extends StatefulWidget {

  @override
  _AddQuoteState createState() => _AddQuoteState();
}

class _AddQuoteState extends State<AddQuote> {

  List quotes = [];


  @override
  void initState() {
    // TODO: implement initState
   super.initState();
   quotes = appSettingsModel.getList(LOVE_QUOTE);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){
        appSettingsModel.put(LOVE_QUOTE, quotes);
        appSettingsModel.updateItems();
        Navigator.pop(context);
        return;
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
          addSpace(40),
          new Container(
            width: double.infinity,
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                InkWell(
                    onTap: () {
                      appSettingsModel.put(LOVE_QUOTE, quotes);
                      appSettingsModel.updateItems();
                      Navigator.pop(context);
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
                  child: Text(
                    "Love Quotes",
                    style: textStyle(true, 25, black),
                  ),
                ),
                addSpaceWidth(10),
                Container(
                  height: 35,width: 90,
//                  margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: FlatButton(
                      materialTapTargetSize:
                      MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),),
                      color: blue0,
                      onPressed: () {
                        pushAndResult(context, inputDialog("Quote",),result: (_){
                          if(_.toString().contains(",")){
                            List list = convertStringToList(",", _);
                            for(String s in list)quotes.add(s.trim());
                          }else{
                            quotes.add(_);
                          }
                          setState(() {
                          });
                        });
                      },
                      child: Text("ADD",
                        style: textStyle(true, 12, white),
                        maxLines: 1,overflow: TextOverflow.ellipsis,)),
                ),
                addSpaceWidth(20),
              ],
            ),
          ),

          addSpace(8),
          new Expanded(
            flex: 1,
            child:quotes.isEmpty?(emptyLayout(Icons.group, "No Quotes Yet", "")):
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: List.generate(quotes.length, (p){
                  String title = quotes[p];
                  return GestureDetector(
                    onTap: (){
                      showListDialog(context, ["Edit","Remove"], (int i){
                        if(i==0){
                          pushAndResult(context, inputDialog("Edit",message: quotes[p],),result: (_){
                            setState(() {
                              quotes[p]=_;
                            });
                          },);
                        }
                        if(i==1){
                          yesNoDialog(context, "Remove?", "Remove this group?", (){
                            setState(() {
                              quotes.removeAt(p);
                            });
                          });
                        }
                      });
                    },
                    child: Container(
                      width: double.infinity,

                      decoration: BoxDecoration(
                        color: blue09,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.only(top: 10,left: 10,right: 10),
                      child: Text(title,style: textStyle(false, 25, black),),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      );
    });
  }


}

