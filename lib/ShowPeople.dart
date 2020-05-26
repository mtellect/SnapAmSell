import 'dart:io';
import 'dart:ui';

import 'package:Strokes/MyProfile1.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:timeago/timeago.dart' as timeAgo;

import 'AppEngine.dart';
import 'assets.dart';
import 'basemodel.dart';


class ShowPeople extends StatefulWidget {
  List ids;
  String title;
  String emptyText;
  bool hidden;
  ShowPeople(this.ids, this.title, this.emptyText, {this.hidden = false});
  @override
  _ShowPeopleState createState() => _ShowPeopleState();
}

class _ShowPeopleState extends State<ShowPeople> with TickerProviderStateMixin {
  List<BaseModel> people = List();
  List ids;
  String title;
  String emptyText;
  bool setup = false;
  RefreshController refreshController = RefreshController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.ids = widget.ids;
    this.title = widget.title;
    this.emptyText = widget.emptyText;
    loadPeople();
  }


  List loadedIds = [];

  loadPeople()async{
    int loadMax = 20;
    int loadCount = 0;
    for(String id in ids){
      if(loadedIds.contains(id))continue;
      loadedIds.add(id);
      if(isBlocked(null,userId: id))continue;
      if (appSettingsModel.getList(DISABLED).contains(id)) continue;
      if(appSettingsModel.getList(BANNED).contains(id))continue;

      DocumentSnapshot doc = await Firestore.instance.collection(USER_BASE).document(id).get();
      if(doc==null)continue;
      if(!doc.exists)continue;
      BaseModel user = BaseModel(doc:doc);
      people.add(user);

      loadCount++;
      if(loadCount==(loadMax/2)){
        setup=true;
        setState(() {});
      }
      if(loadCount>=loadMax)break;
    }

    setup = true;
    try{
      refreshController.loadComplete();
    }catch(e){};
    if(mounted)setState(() {

    });
  }
  /*loadPeople() async {
    for (String userId in ids) {
      DocumentSnapshot doc =
          await Firestore.instance.collection(USER_BASE).document(userId).get();
      BaseModel model = BaseModel(doc: doc);
      int p = people.indexWhere(
        (bm) => bm.getObjectId() == model.getObjectId(),
      );
      if (p == -1) {
        people.add(model);
      }
    }

    setup = true;
    if (mounted) setState(() {});
  }*/

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, "");
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: transparent,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(color: black.withOpacity(.8),)),

            page()
          ],
        ),
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
                      Navigator.of(context).pop("");
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      child: Center(
                          child: Icon(
                        Icons.keyboard_backspace,
                        color: white,
                        size: 25,
                      )),
                    )),
                Flexible(
                  fit: FlexFit.tight,
                  flex: 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text(
                        title,
                        style: textStyle(true, 22, white),
                      ),
                    ],
                  ),
                ),
                addSpaceWidth(15),
              ],
            ),
          ),
//          addLine(1, black.withOpacity(.1), 0, 0, 0, 0),
          new Expanded(
            flex: 1,
            child: !setup
                ? loadingLayout(trans: true)
                : setup && people.isEmpty
                    ? emptyLayout(
                        Icons.person,
                        emptyText,
                        "",trans: true
                      )
                    : Container(
//                        color: white,
                child:SmartRefresher(
                  controller: refreshController,
                  enablePullDown: false,
                  enablePullUp: true,
                  header: Platform.isIOS ? WaterDropHeader() : WaterDropMaterialHeader(),
                  footer: ClassicFooter(
                    idleText: "",
                    idleIcon: Icon(Icons.arrow_drop_down, color: transparent),
                  ),
                  onLoading: () {
                    loadPeople();
                  },
                  onOffsetChange: (_, d) {},
                          child: new ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.all(0),
                            itemBuilder: (c, p) {
                              BaseModel model = people[p];
                              return peopleItem(context,model);
                            },
                            itemCount: people.length,
                          ),
                        )),
          ),
        ],
      );
    });
  }

}
