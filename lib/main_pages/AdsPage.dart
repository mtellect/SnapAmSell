import 'dart:async';

import 'package:Strokes/AppEngine.dart';
import 'package:Strokes/MainAdmin.dart';
import 'package:Strokes/assets.dart';
import 'package:Strokes/basemodel.dart';
import 'package:Strokes/main_pages/CreateAds.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdsPage extends StatefulWidget {
  @override
  _AdsPageState createState() => _AdsPageState();
}

class _AdsPageState extends State<AdsPage> {
  List adsList = [];
  bool setup = false;

  final List<StreamSubscription> subs = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var ads = adsController.stream.listen((b) {
      if (!b) return;
      showMessage(
        context,
        Icons.check,
        green,
        "Successful!",
        "You ads has been created successfully and it's being reviewed!",
      );
    });
    subs.add(ads);
    loadAds();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    for (var sub in subs) {
      sub.cancel();
    }
    super.dispose();
  }

  loadAds() async {
    var ads = Firestore.instance
        .collection(ADS_BASE)
        .where(USER_ID, isEqualTo: userModel.getUserId())
        .snapshots()
        .listen((value) {
      for (var doc in value.documents) {
        BaseModel model = BaseModel(doc: doc);
        int p =
            adsList.indexWhere((e) => e.getObjectId() == model.getObjectId());
        if (p != -1) {
          adsList[p] = model;
        } else {
          adsList.add(model);
        }
      }
      setup = true;
      if (mounted) setState(() {});
    });
    subs.add(ads);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(0, 40, 0, 10),
            color: white,
            child: Row(
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
                Text(
                  "My Ads",
                  style: textStyle(true, 25, black),
                ),
                Spacer(),
                Container(
                  height: 30,
                  width: 50,
                  child: new FlatButton(
                      padding: EdgeInsets.all(5),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onPressed: () {
                        pushAndResult(context, CreateAds());
                      },
                      shape: CircleBorder(),
                      child: Center(
                          child: Icon(
                        Icons.add,
                        size: 20,
                        color: black,
                      ))),
                ),
              ],
            ),
          ),
          page()
        ],
      ),
    );
  }

  page() {
    return Flexible(
      child: Builder(
        builder: (ctx) {
          if (!setup) return loadingLayout();
          if (adsList.isEmpty)
            return emptyLayout(
                Icons.trending_up, "No ads", "You have no ads with us",
                clickText: "Create One", click: () {
              pushAndResult(context, CreateAds());
            });
          return Container(
              child: ListView.builder(
            itemBuilder: (c, p) {
              return adsItem(p);
            },
            shrinkWrap: true,
            itemCount: adsList.length,
            padding: EdgeInsets.only(top: 10, right: 5, left: 5, bottom: 40),
          ));
        },
      ),
    );
  }

  adsItem(int p) {
    BaseModel model = adsList[p];
    String imageUrl = model.getString(ADS_IMAGE);
    String title = model.getString(TITLE);
    String url = model.getString(ADS_URL);
    final seenBy = model.getList(VIEWED_LIST);
    final likes = model.getList(LIKE_LIST);
    final superLike = model.getList(SUPER_LIKE_LIST);
    final clicks = model.getList(CLICKS);
    int status = model.getInt(STATUS);
    bool declined = status == REJECTED;
    String reason = model.getString(REJECTED_MESSAGE);

    String statusMsg = status == APPROVED
        ? "Approved"
        : status == PENDING
            ? "Pending Approval"
            : status == REJECTED ? "Rejected" : "Inactive";
    return Container(
      decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: black.withOpacity(.09))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textStyle(true, 16, black),
                ),
                addSpace(10),
                if (declined) ...[
                  Container(
                    decoration: BoxDecoration(
                        color: black.withOpacity(.09),
                        borderRadius: BorderRadius.circular(9)),
                    padding: EdgeInsets.all(10),
                    child: Text.rich(TextSpan(children: [
                      TextSpan(text: "Declined "),
                      TextSpan(
                          text: "$reason ", style: textStyle(true, 16, red))
                    ])),
                  ),
                  addSpace(10),
                ],
                Text.rich(TextSpan(children: [
                  TextSpan(text: "Status "),
                  TextSpan(
                      text: "$statusMsg ", style: textStyle(true, 14, black))
                ])),
                addSpace(10),
                Row(
                  children: [
                    Text.rich(TextSpan(children: [
                      TextSpan(text: "Views "),
                      TextSpan(
                          text: "${seenBy.length} ",
                          style: textStyle(true, 14, black))
                    ])),
                    addSpaceWidth(10),
                    Text.rich(TextSpan(children: [
                      TextSpan(text: "Clicks "),
                      TextSpan(
                          text: "${clicks.length} ",
                          style: textStyle(true, 14, black))
                    ])),
                    addSpaceWidth(10),
                    Text.rich(TextSpan(children: [
                      TextSpan(text: "Likes "),
                      TextSpan(
                          text: "${likes.length} ",
                          style: textStyle(true, 14, black))
                    ])),
                    addSpaceWidth(10),
                    Text.rich(TextSpan(children: [
                      TextSpan(text: "SuperLikes "),
                      TextSpan(
                          text: "${superLike.length} ",
                          style: textStyle(true, 14, black))
                    ]))
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
