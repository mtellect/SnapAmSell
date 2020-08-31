import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:maugost_apps/AppConfig.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/MainAdmin.dart';
import 'package:maugost_apps/SearchProduct.dart';
import 'package:maugost_apps/app/app.dart';
import 'package:maugost_apps/assets.dart';
import 'package:maugost_apps/basemodel.dart';

class ShowStore extends StatefulWidget {
  final BaseModel model;
  ShowStore(this.model);
  @override
  _ShowStoreState createState() => _ShowStoreState();
}

class _ShowStoreState extends State<ShowStore> {
  List<BaseModel> productLists = [];
  bool hasSetup = false;
  BaseModel model;
  BaseModel theUser;
  bool isFavorite = false;
  List<StreamSubscription> subs = [];

  @override
  initState() {
    super.initState();
    if (widget.model.myItem()) productLists = myProducts;
    hasSetup = productLists.isNotEmpty;
    model = widget.model;
    loadProducts(false);
    loadUser();
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  dispose() {
    super.dispose();
    for (var s in subs) s?.cancel();
  }

  loadUser() async {
    var sub = Firestore.instance
        .collection(USER_BASE)
        .document(widget.model.getUserId())
        .snapshots()
        .listen((value) {
      theUser = BaseModel(doc: value);
      if (!theUser.myItem())
        theUser
          ..putInList(SEEN_BY, userModel.getUserId(), true)
          ..updateItems();
      isFavorite = theUser.getList(LIKES).contains(userModel.getUserId());
      setState(() {});
    });
    subs.add(sub);
  }

  loadProducts(bool isNew) async {
    var sub = Firestore.instance
        .collection(PRODUCT_BASE)
        .where(
          USER_ID,
          isEqualTo: widget.model.getUserId(),
        )
        //.limit(30)
        .snapshots()
        .listen((shots) {
      for (DocumentSnapshot doc in shots.documents) {
        BaseModel model = BaseModel(doc: doc);
        int p = productLists
            .indexWhere((e) => e.getObjectId() == model.getObjectId());
        if (p != -1) {
          productLists[p] = model;
        } else {
          productLists.add(model);
        }
      }
      hasSetup = true;
      if (widget.model.myItem()) myProducts = productLists;
      if (mounted) setState(() {});
    });
    subs.add(sub);
  }

  @override
  Widget build(BuildContext context) {
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
              ),
              Text(
                widget.model.myItem() ? "My Store" : "Store",
                style: textStyle(true, 25, black),
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  theUser
                    ..putInList(LIKES, userModel.getUserId(), !isFavorite)
                    ..updateItems();

                  setState(() {});
                },
                child: Container(
                    //margin: EdgeInsets.only(right: 10),
                    width: 35,
                    height: 35,
                    // decoration: BoxDecoration(
                    //     color: green_dark, shape: BoxShape.circle),
                    padding: EdgeInsets.all(8),
                    child: FlareActor("assets/icons/Favorite.flr",
                        shouldClip: false,
                        color: isFavorite ? green_dark : black.withOpacity(.5),
                        fit: BoxFit.cover,
                        animation: isFavorite
                            ? "Favorite"
                            : "Unfavorite" //_animationName
                        )),
              ),
              IconButton(
                onPressed: () {
                  pushAndResult(context, SearchProduct());
                },
                icon: Icon(LineIcons.search),
              ),
            ],
          ),
        ),
        Flexible(
            child: ListView(
          padding: EdgeInsets.all(0),
          children: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: black.withOpacity(.05),
//                  border: Border.all(color: black.withOpacity(.09)),
                  borderRadius: BorderRadius.circular(5)),
              child: Column(
//                    crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  userImageItem(context, (theUser == null ? model : theUser),
                      size: 60, strokeSize: 1, padLeft: false),
                  Text(
                    (theUser == null ? model : theUser).getString(NAME),
                    style: textStyle(true, 20, black),
                  ),
                  StarRating(
                    rating: 5,
                    size: 16,
                    color: AppConfig.appColor,
                    borderColor: black,
                  ),
                  addSpace(5),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: 12,
                            color: black,
                          ),
                          addSpaceWidth(2),
                          Text(
                            "Buyer",
                            style: textStyle(false, 12, black),
                          ),
                        ],
                      ),
                      addSpaceWidth(10),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 8,
                            width: 8,
                            decoration: BoxDecoration(
                                color: dark_green0, shape: BoxShape.circle),
                          ),
                          addSpaceWidth(2),
                          Text(
                            "Active",
                            style: textStyle(false, 12, black),
                          ),
                        ],
                      ),
                    ],
                  ),
//                      Spacer(),
                  if (null != theUser)
                    Container(
//                    decoration: BoxDecoration(
//                        border: Border.all(color: black, width: 2),
//                        color: black.withOpacity(.9),
//                        borderRadius: BorderRadius.circular(15)
//                      //shape: BoxShape.circle
//                    ),
//                    padding: EdgeInsets.all(5),
                      //height: 70,
                      //width: 70,
                      alignment: Alignment.center,
                      child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(3, (p) {
                            String title = "likes";
                            var icon = Icons.favorite;
                            int count = theUser.getList(LIKES).length;

                            if (p == 1) {
                              title = "Views";
                              icon = Icons.visibility;
                              count = theUser.getList(SEEN_BY).length;
                            }

                            if (p == 2) {
                              title = "Stars";
                              icon = Icons.star;
                              count = theUser.getList(STARS).length;
                            }

                            return Container(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        color: AppConfig.appColor,
                                        shape: BoxShape.circle),
                                    child: Center(
                                      child: Icon(
                                        icon,
                                        size: 18,
                                        color: white_color,
                                      ),
                                    ),
                                  ),
                                  addSpace(5),
                                  Text(
                                    "${formatToK(count)} $title",
                                    style: textStyle(false, 13, black),
                                  ),
                                ],
                              ),
                            );
                          })),
                    ),
                ],
              ),
            ),
            addSpace(10),
            /* Container(
              //height: 40,
              padding: EdgeInsets.all(10),
              alignment: Alignment.centerLeft,
              color: black.withOpacity(.02),
              child: Text(
                "Products",
                style: textStyle(true, 20, black),
              ),
            ),*/
            Builder(
              builder: (ctx) {
                if (!hasSetup)
                  return Container(
                    height: getScreenHeight(context) * .5,
                    child: loadingLayout(trans: true),
                  );
                if (productLists.isEmpty)
                  return Container(
                    height: getScreenHeight(context) * .5,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Image.asset(
                              ic_product,
                              width: 50,
                              height: 50,
                              color: AppConfig.appColor,
                            ),
                            Text(
                              "No Product Yet",
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
                    BaseModel model = productLists[p];
                    return shopItem(context, model, () {
                      setState(() {});
                    });
                  },
                  itemCount: productLists.length,
                  padding: EdgeInsets.all(7),
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                );
              },
            )
          ],
        ))
      ],
    );
  }
}
