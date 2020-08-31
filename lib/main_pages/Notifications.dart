import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:maugost_apps/AppConfig.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/MainAdmin.dart';
import 'package:maugost_apps/assets.dart';
import 'package:maugost_apps/basemodel.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'ShowOrder.dart';

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications>
    with AutomaticKeepAliveClientMixin {
  final refreshController = RefreshController(initialRefresh: false);
  bool canRefresh = true;
  List listItems = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadNotifications(false);
  }

  loadNotifications(bool isNew) async {
    final startFeedAt = [
      !isNew
          ? (listItems.isEmpty
              ? DateTime.now().millisecondsSinceEpoch
              : listItems[listItems.length - 1].createdAt)
          : (listItems.isEmpty ? 0 : listItems[0].createdAt)
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
        int p =
            listItems.indexWhere((e) => e.getObjectId() == model.getObjectId());
        if (p != -1) {
          listItems[p] = model;
        } else {
          listItems.add(model);
        }
      }

      if (isNew) {
        refreshController.refreshCompleted();
      } else {
        int oldLength = listItems.length;
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
      backgroundColor: white,
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
                color: black,
                onPressed: () {
                  Navigator.pop(context, "");
                },
              ),
              Text(
                "Notifications",
                style: textStyle(true, 25, black),
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
        enablePullDown: false,
        enablePullUp: false,
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
        if (!notifySetup)
          return Container(
            height: getScreenHeight(context) * .9,
            child: loadingLayout(trans: true),
          );
        if (nList.isEmpty)
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

        return ListView.builder(
            itemCount: nList.length,
            padding: EdgeInsets.all(0),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (c, p) {
              BaseModel model = nList[p];
              bool myItem = model.myItem();
              String message = 'A Buyer has placed a request for your product';
              if (myItem)
                message = 'You have placed an order request for a product!';

              bool atEnd = p == nList.length - 1;
              bool unRead =
                  !model.getList(READ_BY).contains(userModel.getObjectId());
              return InkWell(
                onTap: () {
                  print(model.getString(ORDER_ID));
                  model
                    ..putInList(READ_BY, userModel.getObjectId(), true)
                    ..updateItems();
                  unreadCount.remove(model.getObjectId());
                  pushAndResult(
                      context,
                      ShowOrder(
                        orderId: model.getString(ORDER_ID),
                      ));
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: black.withOpacity(unRead ? 0.03 : 0),
                      border: Border(
                          bottom: BorderSide(
                              color: black.withOpacity(atEnd ? 0 : 0.1)))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 54,
                            width: 54,
                            child: Stack(
                              children: [
                                Container(
                                    height: 45,
                                    width: 45,
                                    decoration: BoxDecoration(
                                        color: AppConfig.appColor,
                                        shape: BoxShape.circle),
                                    child: Icon(
                                      LineIcons.shopping_cart,
                                      size: 22,
                                    )),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(28),
                                    child: Container(
                                      height: 28,
                                      width: 28,
                                      decoration: BoxDecoration(
                                          color: white,
                                          border: Border.all(
                                              color: white, width: 1.5)),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(28),
                                        child: CachedNetworkImage(
                                          imageUrl: model.userImage,
                                          fit: BoxFit.cover,
                                          height: double.infinity,
                                          width: double.infinity,
                                          //width: 28,
                                          placeholder: (c, s) {
                                            return Container(
                                              height: 28,
                                              width: 28,
                                              alignment: Alignment.center,
                                              child: Icon(
                                                LineIcons.user,
                                                size: 16,
                                              ),
                                              decoration: BoxDecoration(
                                                  color: black.withOpacity(.08),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color: white,
                                                      width: 1.5)),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          addSpaceWidth(10),
                          Expanded(
                            child: Text(
                              message,
                              style: textStyle(true, 18, black),
                            ),
                          ),
                          Text(
                            getTimeAgo(model.getTime()),
                            style: textStyle(false, 14, black.withOpacity(.5)),
                          ),
                        ],
                      ),
                      // if (!model.myItem())
                      //   Container(
                      //     margin: EdgeInsets.only(top: 4),
                      //     padding: EdgeInsets.all(2),
                      //     decoration: BoxDecoration(
                      //         borderRadius: BorderRadius.circular(25),
                      //         color: black.withOpacity(.05),
                      //         border: Border.all(color: black.withOpacity(.08))
                      //         /* border: Border(
                      //           top: BorderSide(
                      //               width: 5, color: black.withOpacity(.5)),
                      //           left: BorderSide(
                      //               width: 5, color: black.withOpacity(.5)),
                      //         )*/
                      //         ),
                      //     child: Row(
                      //       mainAxisSize: MainAxisSize.min,
                      //       children: [
                      //         userImageItem(context, model,
                      //             size: 30, strokeSize: 1, padLeft: false),
                      //         addSpaceWidth(5),
                      //         Text(
                      //           model.getString(NAME),
                      //           style: textStyle(true, 12, black),
                      //         ),
                      //         addSpaceWidth(5),
                      //       ],
                      //     ),
                      //   ),
                      // Text(
                      //   getTimeAgo(model.getTime()),
                      //   style: textStyle(false, 14, black.withOpacity(.5)),
                      // ),
                    ],
                  ),
                ),
              );
            });
      },
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
