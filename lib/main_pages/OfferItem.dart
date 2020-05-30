import 'package:Strokes/AppEngine.dart';
import 'package:Strokes/MainAdmin.dart';
import 'package:Strokes/app_config.dart';
import 'package:Strokes/assets.dart';
import 'package:Strokes/auth/login_page.dart';
import 'package:Strokes/basemodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class OfferItem extends StatefulWidget {
  final int position;
  OfferItem(this.position);
  @override
  _OfferItemState createState() => _OfferItemState();
}

class _OfferItemState extends State<OfferItem>
    with AutomaticKeepAliveClientMixin {
  final refreshController = RefreshController(initialRefresh: false);
  bool canRefresh = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadOffers(false);
  }

  loadOffers(bool isNew) async {
    final startFeedAt = [
      !isNew
          ? (offerLists.isEmpty
              ? DateTime.now().millisecondsSinceEpoch
              : offerLists[offerLists.length - 1].createdAt)
          : (offerLists.isEmpty ? 0 : offerLists[0].createdAt)
    ];

    List local = [];
    Firestore.instance
        .collection(OFFER_BASE)
        .where(SELLER_ID, isEqualTo: userModel.getUserId())
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
      backgroundColor: white,
      body: page(),
    );
  }

  page() {
    if(!isLoggedIn)return emptyLayout(Icons.local_offer, "Sign in to view offers", "",
        clickText: "Sign in",click: (){
          pushAndResult(context, LoginPage(), depend: false);
        });
    return refresher();
  }

  refresher() {
    return SmartRefresher(
      controller: refreshController,
      enablePullDown: true,
      enablePullUp: offerLists.length > 10,
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
        //physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(left: 10, right: 10, bottom: 120),

        children: <Widget>[
          body(),
        ],
      ),
    );
  }

  body() {

    return Builder(
      builder: (ctx) {
        if (!offerSetup)
          return Container(
            height: getScreenHeight(context) * .7,
            child: loadingLayout(trans: true),
          );
        if (offerLists.isEmpty)
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
