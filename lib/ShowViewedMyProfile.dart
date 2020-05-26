import 'dart:io';
import 'dart:ui';

import 'package:Strokes/MainAdmin.dart';
import 'package:Strokes/MyProfile1.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:timeago/timeago.dart' as timeAgo;

import 'AppEngine.dart';
import 'assets.dart';
import 'basemodel.dart';


class ShowViewedMyProfile extends StatefulWidget {
  @override
  _ShowViewedMyProfileState createState() => _ShowViewedMyProfileState();
}

class _ShowViewedMyProfileState extends State<ShowViewedMyProfile> with TickerProviderStateMixin {
  List<BaseModel> peopleList = List();
  bool setup = false;
  RefreshController refreshController = RefreshController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   loadPeople();
  }

  loadPeople()async{
    QuerySnapshot shots = await Firestore.instance.collection(USER_BASE)
        .where(VIEWED_LIST,arrayContains: userModel.getObjectId()).orderBy(TIME_UPDATED,descending: true)
    .startAt([peopleList.isEmpty?DateTime.now().millisecondsSinceEpoch:((peopleList[peopleList.length-1]
        .getInt(TIME_UPDATED)))]).limit(PEOPLE_MAX_LOAD)
        .getDocuments();
    for(DocumentSnapshot doc in shots.documents){
      BaseModel bm = BaseModel(doc:doc);
      String id = bm.getObjectId();
      if(isBlocked(null,userId: id))continue;
      if (appSettingsModel.getList(DISABLED).contains(id)) continue;
      if(appSettingsModel.getList(BANNED).contains(id))continue;

      int index = peopleList.indexWhere((model)=>model.getObjectId()==bm.getObjectId());
      if(index==-1){
      peopleList.add(bm);
      }
    }

    setup=true;
    try{
      refreshController.loadComplete();
    }catch(e){};
    if(mounted)setState(() {});
  }

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
                        "Viewed your profile",
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
                : setup && peopleList.isEmpty
                    ? emptyLayout(
                        Icons.person,
                        "Nothing to display",
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
                              BaseModel model = peopleList[p];
                              return peopleItem(context,model);
                            },
                            itemCount: peopleList.length,
                          ),
                        )),
          ),
        ],
      );
    });
  }

}
