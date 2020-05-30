import 'package:Strokes/AppEngine.dart';
import 'package:Strokes/MainAdmin.dart';
import 'package:Strokes/app_config.dart';
import 'package:Strokes/assets.dart';
import 'package:Strokes/basemodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications>
    with AutomaticKeepAliveClientMixin {
  final refreshController = RefreshController(initialRefresh: false);
  bool canRefresh = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadNotifications(false);
  }

  loadNotifications(bool isNew) async {
    final startFeedAt = [
      !isNew
          ? (offerLists.isEmpty
              ? DateTime.now().millisecondsSinceEpoch
              : offerLists[offerLists.length - 1].createdAt)
          : (offerLists.isEmpty ? 0 : offerLists[0].createdAt)
    ];

    List local = [];
    Firestore.instance
        .collection(NOTIFY_BASE)
        .where(PARTIES, arrayContains: userModel.getUserId())
        .limit(10)
        .orderBy(CREATED_AT, descending: !isNew)
        .startAt(startFeedAt)
        .getDocuments()
        .then((value) {
      local = value.documents;
      for (var doc in value.documents) {
        BaseModel model = BaseModel(doc: doc);
        //if (userModel.isMuted(model.getObjectId())) continue;
        int p = offerLists
            .indexWhere((e) => e.getObjectId() == model.getObjectId());
        if (p != -1) {
          offerLists[p] = model;
        } else {
          offerLists.add(model);
        }
      }

      if (isNew) {
        refreshController.refreshCompleted();
      } else {
        int oldLength = offerLists.length;
        int newLength = local.length;
        if (newLength <= oldLength) {
          refreshController.loadNoData();
          canRefresh = false;
        } else {
          refreshController.loadComplete();
        }
      }
      offerSetup = true;
      if (mounted)
        setState(() {
          //myNotifications.sort((a, b) => b.time.compareTo(a.time));
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: modeColor,
      body: page(),
    );
  }

  page() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(top: 35, right: 10, left: 10, bottom: 10),
          child: Row(
            children: [
              BackButton(
                color: white,
                onPressed: () {
                  Navigator.pop(context, "");
                },
              ),
              Text(
                "Notifications",
                style: textStyle(true, 25, white),
              ),
              Spacer(),
            ],
          ),
        ),
        refresher(),
      ],
    );
  }

  refresher() {
    return Flexible(
      child: SmartRefresher(
        controller: refreshController,
        enablePullDown: true,
        enablePullUp: offerLists.length > 10,
        header: WaterDropHeader(),
        footer: ClassicFooter(
          noDataText: "Nothing more for now, check later...",
          textStyle: textStyle(false, 12, white.withOpacity(.7)),
        ),
        onLoading: () {
          loadNotifications(false);
        },
        onRefresh: () {
          loadNotifications(true);
        },
        child: ListView(
          //controller: scrollControllers[1],
          shrinkWrap: true,
          //physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.only(left: 10, right: 10, bottom: 120),

          children: <Widget>[
            body(),
          ],
        ),
      ),
    );
  }

  body() {
    return Builder(
      builder: (ctx) {
        if (!productSetup)
          return Container(
            height: getScreenHeight(context) * .9,
            child: loadingLayout(trans: true),
          );
        if (offerLists.isEmpty)
          return Container(
            height: getScreenHeight(context) * .9,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.notifications_active,
                      color: AppConfig.appColor,
                      size: 50,
                    ),
                    Text(
                      "No Notifications Yet",
                      style: textStyle(true, 20, black),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              childAspectRatio: 0.65),
          itemBuilder: (c, p) {
            BaseModel model = offerLists[p];
            return shopItem(context, model, () {
              setState(() {});
            });
          },
          itemCount: offerLists.length,
          padding: EdgeInsets.all(0),
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
        );
      },
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
