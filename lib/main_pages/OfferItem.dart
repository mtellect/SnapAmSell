import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maugost_apps/AppConfig.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/MainAdmin.dart';
import 'package:maugost_apps/OfferMain.dart';
import 'package:maugost_apps/assets.dart';
import 'package:maugost_apps/auth/login_page.dart';
import 'package:maugost_apps/basemodel.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'EditProfile.dart';

class OfferItem extends StatefulWidget {
  //final int position;
  OfferItem();
  @override
  _OfferItemState createState() => _OfferItemState();
}

class _OfferItemState extends State<OfferItem>
    with AutomaticKeepAliveClientMixin {
  final refreshController = RefreshController(initialRefresh: false);
  bool canRefresh = true;
//  List lastOffers = [];
  var subs = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //loadOffers(false);
    var sub = offerController.stream.listen((event) {
      setState(() {});
    });
    subs.add(sub);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    for (var sub in subs) sub.cancel();
  }

  loadOffersx(bool isNew) async {
    final startFeedAt = [
      !isNew
          ? (lastOffers.isEmpty
              ? DateTime.now().millisecondsSinceEpoch
              : lastOffers[lastOffers.length - 1].createdAt)
          : (lastOffers.isEmpty ? 0 : lastOffers[0].createdAt)
    ];

    QuerySnapshot shots = await Firestore.instance
        .collection(OFFER_IDS_BASE)
        .where(PARTIES, arrayContains: userModel.getUserId())
        .limit(10)
        .orderBy(CREATED_AT, descending: !isNew)
        .startAt(startFeedAt)
        .getDocuments();

    for (var doc in shots.documents) {
      BaseModel model = BaseModel(doc: doc);
      //if (userModel.isMuted(model.getObjectId())) continue;
      int p =
          lastOffers.indexWhere((e) => e.getObjectId() == model.getObjectId());
      if (p != -1) {
        lastOffers[p] = model;
      } else {
        lastOffers.add(model);
      }
    }

    if (isNew) {
      refreshController.refreshCompleted();
    } else {
      int oldLength = lastOffers.length;
      int newLength = shots.documents.length;
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
    if (!isLoggedIn)
      return emptyLayout(Icons.local_offer, "Sign in to view offers", "",
          clickText: "Sign in", click: () {
        pushAndResult(context, LoginPage(), depend: false);
      });
    return body();
  }

/*  refresher() {
    return SmartRefresher(
      controller: refreshController,
      enablePullDown: true,
      enablePullUp: lastOffers.length > 10,
      header: WaterDropHeader(),
      footer: ClassicFooter(
        noDataText: "Nothing more for now, check later...",
        textStyle: textStyle(false, 12, white.withOpacity(.7)),
      ),
      onLoading: () {
        loadOffers(false);
      },
      onRefresh: () {
        loadOffers(true);
      },
      child: ListView(
        //controller: scrollControllers[1],
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.only(left: 10, right: 10, bottom: 120),

        children: <Widget>[
          body(),
        ],
      ),
    );
  }*/

  body() {
    return Builder(
      builder: (ctx) {
        if (!offerSetup)
          return Container(
            height: getScreenHeight(context) * .7,
            child: loadingLayout(trans: true),
          );
        if (lastOffers.isEmpty)
          return Container(
            height: getScreenHeight(context) * .7,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Image.asset(
                      ic_offer,
                      width: 50,
                      height: 50,
                      color: AppConfig.appColor,
                    ),
                    Text(
                      "No Offers Yet",
                      style: textStyle(true, 20, black),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        return ListView.builder(
          itemBuilder: (c, p) {
            BaseModel model = lastOffers[p];
            return offerItem(context, model, () {
              setState(() {});
            });
          },
          itemCount: lastOffers.length,
          padding: EdgeInsets.all(0),
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
        );
      },
    );
  }

  offerItem(
    BuildContext context,
    BaseModel model,
    setState,
  ) {
    double myBid = model.getDouble(MY_BID);
    String offerId = model.getString(OFFER_ID);
    String otherPersonId = getOtherPersonId(model);

    BaseModel offer = offerInfo[offerId];
    BaseModel product = otherProductInfo[offer.getString(PRODUCT_ID)];
    BaseModel bidder = otherPeronInfo[otherPersonId];
    bool accepted = offer.getBoolean(ACCEPTED);
    bool hasPaid = offer.getBoolean(HAS_PAID);
    String image = getFirstPhoto(offer.images);
    String title = offer.getString(TITLE);
    String desc = offer.getString(DESCRIPTION);
    double price = offer.getDouble(PRICE);

    var types = ["You", "Buyer", "Seller"];
    String type;
    var typeColor;
    if (model.myItem()) {
      type = "You";
      typeColor = red0;
    } else if (offer.getString(SELLER_ID) == userModel.getObjectId()) {
      type = "Buyer";
      typeColor = blue0;
    } else {
      type = "Seller";
      typeColor = light_green3;
    }

    return GestureDetector(
      onTap: () {
//        pushAndResult(context, ShowProduct(model), depend: false);
        pushAndResult(
            context,
            OfferMain(
              offerId,
              offerModel: offer,
            ),
            depend: false);
      },
      child: Container(
        color: white,
        child: Column(
          children: [
            addSpace(10),
            Row(
              children: [
                addSpaceWidth(10),
                Container(
                  width: 100,
                  height: 100,
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    child: CachedNetworkImage(
                      imageUrl: image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                addSpaceWidth(10),
                Flexible(
                    fit: FlexFit.tight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: textStyle(true, 16, black),
                        ),
                        addSpace(5),
                        Text(
                          desc,
                          style: textStyle(false, 12, black),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        addSpace(5),
                        if (!accepted)
                          Text(
                            "\$$price",
                            style: textStyle(true, 12, black.withOpacity(.5)),
                          ),
                        if (accepted)
                          Container(
//                        color: red0,
//                        width: double.infinity,
//                        padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
//                          color: red0,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "\$${offer.getDouble(ACCEPTED_PRICE)} "
                                  "for ${offer.getInt(QUANTITY)} Item${offer.getInt(QUANTITY) > 1 ? "s" : ""}",
                                  style: textStyle(
                                      true, 12, black.withOpacity(.5)),
                                ),
                              ],
                            ),
                          ),
                        addSpace(5),
                        Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: black.withOpacity(.05),
                              border: Border.all(color: black.withOpacity(.08))
                              /* border: Border(
                                top: BorderSide(
                                    width: 5, color: black.withOpacity(.5)),
                                left: BorderSide(
                                    width: 5, color: black.withOpacity(.5)),
                              )*/
                              ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              userImageItem(context, bidder,
                                  padLeft: false, size: 30),
                              addSpaceWidth(5),
                              Text(
                                bidder.getString(NAME),
                                style: textStyle(true, 13, black),
                              ),
                              addSpaceWidth(5),
                            ],
                          ),
                        )
                      ],
                    )),
                addSpaceWidth(10),
                accepted
                    ? Container()
                    : model.myItem()
                        ? (Container(
                            padding: EdgeInsets.fromLTRB(15, 5, 10, 5),
                            decoration: BoxDecoration(
                                color: blue0,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25))),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "\$$myBid",
                                  style: textStyle(true, 20, white_color),
                                ),
                                addSpaceWidth(8),
                                Image.asset(
                                  ic_bid1,
                                  height: 17,
                                  color: white_color.withOpacity(.7),
                                ),
                              ],
                            ),
                          ))
                        : Container(
                            padding: EdgeInsets.fromLTRB(15, 5, 10, 5),
                            decoration: BoxDecoration(
                                color: red0,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25))),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  ic_bid,
                                  height: 17,
                                  color: white_color.withOpacity(.7),
                                ),
                                addSpaceWidth(8),
                                Text(
                                  "\$$myBid",
                                  style: textStyle(true, 20, white_color),
                                )
                              ],
                            ),
                          ),
                addSpaceWidth(10),
                if (offer.getString(SELLER_ID) != userModel.getObjectId() &&
                    accepted &&
                    !hasPaid)
                  Container(
                    height: 40,
                    margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                    child: RaisedButton(
                      onPressed: () {
                        if (!userModel.signUpCompleted) {
                          pushAndResult(
                              context,
                              EditProfile(
                                modeEdit: true,
                              ),
                              depend: false);
                          return;
                        }

                        double accountBal = userModel.getDouble(ESCROW_BALANCE);
                        double offerAmount = offer.getDouble(ACCEPTED_PRICE);
                        double leftOver = accountBal - offerAmount;
                        String sellerId = offer.getString(SELLER_ID);
                        print(offer.myItem());
                        print(offer.getUserId());
                        print(userModel.getUserId());
                        print(sellerId);

                        if (accountBal == 0 || leftOver.isNegative) {
                          showMessage(
                              context,
                              Icons.warning,
                              red,
                              "Insufficient Funds",
                              "Oops! You do not have sufficient"
                                  " funds in your wallet. Please"
                                  " add funds to your wallet to proceed.",
                              clickYesText: "Fund Wallet", onClicked: (_) {
                            if (_)
                              fundWallet(context, onProcessed: () {
                                setState(() {});
                              });
                          });
                          return;
                        }

                        //TODO handle order
                        handleOrder(context, [product], offerAmount,
                            onOfferSettled: () {
                          model
                            ..put(
                              HAS_PAID,
                              true,
                            )
                            ..updateItems();
                        });

                        //TODO fund seller here
                        /*fundSeller(context, bidder, offerAmount,
                            onProcessed: () {
                          model
                            ..put(
                              HAS_PAID,
                              true,
                            )
                            ..updateItems();
                        });*/
                      },
                      color: AppConfig.appColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
//                      Icon(
//                        Icons.monetization_on,
//                        size: 16,
//                        color: black_color,
//                      ),
//                      addSpaceWidth(5),
                          Flexible(
                            child: Text(
                              "Pay \$${offer.getDouble(ACCEPTED_PRICE)}",
                              style: textStyle(true, 14, black_color),
                              maxLines: 1,
                            ),
                          )
                        ],
                      ),
                    ),
                  )
              ],
            ),
            addLine(.5, black.withOpacity(.1), 0, 10, 0, 0)
          ],
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
