import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maugost_apps/AppConfig.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/MainAdmin.dart';
import 'package:maugost_apps/SearchProduct.dart';
import 'package:maugost_apps/assets.dart';
import 'package:maugost_apps/basemodel.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final refreshController = RefreshController(initialRefresh: false);
  bool canRefresh = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 1), () {
      loadProducts(true);
    });
  }

  loadProducts(bool isNew) async {
    final startFeedAt = [
      !isNew
          ? (productLists.isEmpty
              ? DateTime.now().millisecondsSinceEpoch
              : productLists[productLists.length - 1].createdAt)
          : (productLists.isEmpty ? 0 : productLists[0].createdAt)
    ];

    List local = [];
    Firestore.instance
        .collection(PRODUCT_BASE)
        //.where(PARTIES, arrayContains: userModel.getUserId())
        .limit(16)
        .orderBy(CREATED_AT, descending: !isNew)
        .startAt(startFeedAt)
        .getDocuments()
        .then((value) {
      local = value.documents;
      for (var doc in value.documents) {
        BaseModel model = BaseModel(doc: doc);
        //if (userModel.isMuted(model.getObjectId())) continue;
        int p = productLists
            .indexWhere((e) => e.getObjectId() == model.getObjectId());
        if (p != -1) {
          productLists[p] = model;
        } else {
          productLists.add(model);
        }
      }

      if (isNew) {
        refreshController.refreshCompleted();
      } else {
        /*int oldLength = productLists.length;
        int newLength = local.length;
        if (newLength <= oldLength) {
          refreshController.loadNoData();
          canRefresh = false;
        } else {
          refreshController.loadComplete();
        }*/
        refreshController.loadComplete();
      }
      productSetup = true;
      if (mounted)
        setState(() {
          //myNotifications.sort((a, b) => b.time.compareTo(a.time));
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: page(),
    );
  }

  //["All", "Cosmetics", "Free", "Others"]

  page() {
    return Column(
      children: [
        //addSpace(40),
        GestureDetector(
          onTap: () {
            print("sfdf");
            pushAndResult(context, SearchProduct());
          },
          child: Container(
            height: 45,
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: default_white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: black.withOpacity(.1), width: 1)),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                addSpaceWidth(10),
                Icon(
                  Icons.search,
                  color: black.withOpacity(.5),
                  size: 17,
                ),
                addSpaceWidth(10),
                Text(
                  "Search Products on Fetish",
                  style: textStyle(false, 16, black.withOpacity(.6)),
                )
              ],
            ),
          ),
        ),
        refresher()
      ],
    );
  }

  refresher() {
    return Flexible(
      child: SmartRefresher(
        controller: refreshController,
        enablePullDown: true,
        enablePullUp: productLists.length > 6,
        header: WaterDropHeader(),
        footer: ClassicFooter(
          noDataText: "Nothing more for now, check later...",
          textStyle: textStyle(false, 12, black.withOpacity(.7)),
        ),
        onLoading: () {
          loadProducts(false);
        },
        onRefresh: () {
          loadProducts(true);
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
            height: getScreenHeight(context) / 1.5,
            child: loadingLayout(trans: true),
          );
        if (productLists.isEmpty)
          return Container(
            height: getScreenHeight(context) / 1.5,
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
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.65),
          itemBuilder: (c, p) {
            BaseModel model = productLists[p];
            return shopItem(
                context,
                model,
                () {
                  setState(() {});
                },
                isFavorite:
                    model.getList(LIKED).contains(userModel.getUserId()),
                onLiked: (m) {
                  productLists[p] = m;
                  setState(() {});
                });
          },
          itemCount: productLists.length,
          padding: EdgeInsets.all(0),
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
        );
      },
    );
  }
}
