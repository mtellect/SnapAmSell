import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maugost_apps/AppConfig.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/MainAdmin.dart';
import 'package:maugost_apps/OfferMain.dart';
import 'package:maugost_apps/app/app.dart';
import 'package:maugost_apps/app/dotsIndicator.dart';
import 'package:maugost_apps/assets.dart';
import 'package:maugost_apps/auth/login_page.dart';
import 'package:maugost_apps/basemodel.dart';

class ShowProduct extends StatefulWidget {
  final BaseModel theModel;
  final String objectId;
  const ShowProduct(this.theModel, {this.objectId});
  @override
  _ShowProductState createState() => _ShowProductState();
}

class _ShowProductState extends State<ShowProduct> {
  BaseModel model;
  final vp = PageController();
  int currentPage = 0;
  BaseModel theUser;
  String objectId;
  bool setup = false;
  List<StreamSubscription> subs = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    model = widget.theModel;
    setup = null != widget.theModel;
    loadProduct();
    loadUser();
    if (!userModel
            .getList(SEEN_PRODUCTS)
            .contains(widget.theModel.getObjectId()) &&
        !widget.theModel.myItem())
      userModel
        ..putInList(SEEN_PRODUCTS, widget.theModel.getObjectId(), true)
        ..updateItems();
  }

  @override
  dispose() {
    super.dispose();
    for (var s in subs) s?.cancel();
  }

  loadProduct() async {
    var sub = Firestore.instance
        .collection(PRODUCT_BASE)
        .document(widget.objectId)
        .snapshots()
        .listen((doc) {
      model = BaseModel(doc: doc);
      print(model.getString(NAME));
      setup = true;
      setState(() {});
      loadUser();
    });
    subs.add(sub);
  }

  loadUser() {
    if (model.getUserId().isEmpty) return;
    print(widget.theModel.getString(NAME));
    var sub = Firestore.instance
        .collection(USER_BASE)
        .document(widget.theModel.getUserId())
        .snapshots()
        .listen((value) {
      theUser = BaseModel(doc: value);
      model.put(NAME, theUser.getString(NAME));
      model.put(USER_IMAGE, theUser.getString(USER_IMAGE));
//      model.put(NAME, theUser.getString(NAME));
      setState(() {});
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
    bool isInCart = false;
    if (model != null) {
      int p =
          cartLists.indexWhere((e) => e.getObjectId() == model.getObjectId());
      isInCart = p != -1;
    }
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
                "Product",
                style: textStyle(true, 25, black),
              ),
              Spacer(),
            ],
          ),
        ),
        Flexible(
            child: !setup
                ? loadingLayout()
                : ListView(
                    padding: EdgeInsets.all(0),
                    physics: BouncingScrollPhysics(),
                    children: [
                      Container(
                        height: getScreenHeight(context) * .4,
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
//              clipBehavior: Clip.antiAlias,
////              padding: EdgeInsets.all(10),
//              decoration: BoxDecoration(
//                  color: black.withOpacity(.05),
//                  border: Border.all(color: black.withOpacity(.09)),
//                  borderRadius: BorderRadius.circular(10)),
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            PageView.builder(
                              controller: vp,
                              onPageChanged: (p) {
                                setState(() {
                                  currentPage = p;
                                });
                              },
                              itemCount: model.images.length,
                              itemBuilder: (c, p) {
                                final image = model.images[p];
                                return GestureDetector(
                                  onTap: () {
                                    pushAndResult(
                                        context,
                                        ViewImage(
                                            model.images
                                                .map((e) => e.imageUrl)
                                                .toList(),
                                            p),
                                        depend: false);
                                  },
                                  child: Card(
                                    clipBehavior: Clip.antiAlias,
//                          margin: EdgeInsets.all(15),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    child: CachedNetworkImage(
                                      imageUrl: image.imageUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (c, s) {
                                        return placeHolder(
                                            getScreenHeight(context) * .4,
                                            width: double.infinity);
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                            if (model.images.length > 1)
                              Container(
                                padding: EdgeInsets.all(1),
                                margin: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: black.withOpacity(.7)),
                                child: new DotsIndicator(
                                  dotsCount: model.images.length,
                                  position: currentPage,
                                  decorator: DotsDecorator(
                                    size: const Size.square(5.0),
                                    color: black,
                                    activeColor: AppConfig.appColor,
                                    activeSize: const Size(10.0, 7.0),
                                    activeShape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0)),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      addSpace(10),
                      Container(
                        //height: 40,
                        padding: EdgeInsets.all(15),
                        alignment: Alignment.centerLeft,
                        //color: black.withOpacity(.02),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  model.getString(TITLE),
                                  style: textStyle(true, 22, black),
                                ),
                                Text(
                                  model.getString(CATEGORY),
                                  style: textStyle(
                                      true, 12, black.withOpacity(.7)),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: white,
                                      borderRadius: BorderRadius.circular(10)),
                                  padding: EdgeInsets.all(3),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.visibility,
                                        size: 13,
                                        color: black,
                                      ),
                                      addSpaceWidth(5),
                                      Text(
                                        "15k Views",
                                        style: textStyle(
                                            true, 12, black.withOpacity(.7)),
                                      ),
                                    ],
                                  ),
                                ),
                                StarRating(
                                  rating: 5,
                                  size: 16,
                                  color: AppConfig.appColor,
                                  borderColor: black,
                                ),
                              ],
                            ),
                            Spacer(),
                            Container(
                              height: 40,
                              decoration: BoxDecoration(
                                  color: AppConfig.appColor,
                                  borderRadius: BorderRadius.circular(25)),
                              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: Center(
                                child: Text(
                                  "\$${model.getDouble(PRICE)}",
                                  style: textStyle(true, 22, black),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Description",
                              style: textStyle(true, 16, black),
                            ),
                            addSpace(10),
                            Container(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              decoration: BoxDecoration(
                                  border: Border(
                                left: BorderSide(
                                    width: 10, color: black.withOpacity(.5)),
                              )),
                              child: Text(
                                model.getString(DESCRIPTION),
                                style: textStyle(false, 18, black),
                              ),
                            ),
                          ],
                        ),
                      ),
                      addSpace(15),
                      Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Seller",
                              style: textStyle(true, 20, black),
                            ),
                            addSpace(10),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.only(left: 10, right: 10),
                              decoration: BoxDecoration(
                                  border: Border(
                                left: BorderSide(
                                    width: 10, color: black.withOpacity(.5)),
                              )),
                              child: Column(
                                children: [
                                  userImageItem(context, theUser ?? model,
                                      size: 60, strokeSize: 1, padLeft: false),
                                  Text(
                                    model.getString(NAME),
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
                                                color: dark_green0,
                                                shape: BoxShape.circle),
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

                                          if (p == 1) {
                                            title = "Views";
                                            icon = Icons.visibility;
                                          }

                                          if (p == 2) {
                                            title = "Stars";
                                            icon = Icons.star;
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
                                                  "15 $title",
                                                  style: textStyle(
                                                      false, 13, black),
                                                ),
                                              ],
                                            ),
                                          );
                                        })),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      addSpace(20),
                    ],
                  )),
        if (setup)
          if (!model.myItem())
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                    child: RaisedButton(
                      onPressed: () {
                        if (!isLoggedIn) {
                          pushAndResult(context, LoginPage(), depend: false);
                          return;
                        }
                        if (null == theUser) return;
                        clickChat(context, theUser, false);
                      },
                      color: black,
                      padding: EdgeInsets.all(0),
                      shape: CircleBorder(
                          //borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: black.withOpacity(.7))),
                      child: Image.asset(
                        ic_chat1,
                        height: 25,
                        width: 25,
                        color: white,
                      ),
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.tight,
                    child: Container(
                      height: 40,
                      child: RaisedButton(
                        onPressed: () {
                          if (!isLoggedIn) {
                            pushAndResult(context, LoginPage(), depend: false);
                            return;
                          }
                          String offerId =
                              "${model.getObjectId()}${userModel.getObjectId()}";
                          bool active = model
                              .getList(ACTIVE_OFFER)
                              .contains(userModel.getUserId());
                          if (active) {
                            pushAndResult(
                                context,
                                OfferMain(
                                  offerId,
                                  offerModel: offerInfo[offerId],
                                ),
                                depend: false);
                            return;
                          }
                          BaseModel offer = BaseModel();
                          offer.put(OBJECT_ID, offerId);
                          offer.put(SELLER_ID, model.getString(USER_ID));
                          offer.put(PRODUCT_ID, model.getObjectId());
                          offer.put(PRICE, model.getDouble(PRICE));
                          offer.put(TITLE, model.getString(TITLE));
                          offer.put(DESCRIPTION, model.getString(DESCRIPTION));
                          offer.put(IMAGES, model.getList(IMAGES));
                          offer.put(PARTIES,
                              [userModel.getUserId(), model.getUserId()]);
                          offer.saveItem(OFFER_IDS_BASE, true,
                              document: offerId);
                          model
                            ..putInList(
                                ACTIVE_OFFER, userModel.getUserId(), true)
                            ..updateItems();
                          pushAndResult(
                              context,
                              OfferMain(
                                offerId,
                              ),
                              depend: false);
                        },
                        color: AppConfig.appColor,
                        padding: EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
//                          side: BorderSide(color: black)
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              ic_offer,
                              height: 16,
                              width: 16,
                              color: black,
                            ),
                            addSpaceWidth(5),
                            Flexible(
                              child: Text(
                                model
                                        .getList(ACTIVE_OFFER)
                                        .contains(userModel.getUserId())
                                    ? "Continue Offer"
                                    : "Make Offer",
                                style: textStyle(true, 16, black),
                                maxLines: 1,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    height: 40,
//                  width: 50,
                    child: RaisedButton(
                      onPressed: () {
                        cartController.add(model);
                        setState(() {});
                      },
                      color: !isInCart ? blue0 : red0,
//                    padding: EdgeInsets.all(20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
//                        side: BorderSide(color: black.withOpacity(.7))
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            ic_cart,
                            height: 14,
                            width: 14,
                            color: white_color,
                          ),
                          addSpaceWidth(5),
                          Text(
                            isInCart ? "Remove" : "Add",
                            style: textStyle(true, 16, white_color),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
      ],
    );
  }
}
