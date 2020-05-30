import 'package:Strokes/AppEngine.dart';
import 'package:Strokes/MainAdmin.dart';
import 'package:Strokes/app_config.dart';
import 'package:Strokes/assets.dart';
import 'package:Strokes/basemodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
        .limit(6)
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
        int oldLength = productLists.length;
        int newLength = local.length;
        if (newLength <= oldLength) {
          refreshController.loadNoData();
          canRefresh = false;
        } else {
          refreshController.loadComplete();
        }
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

  page() {
    return Column(
      children: [
        Row(
          children: [
            Flexible(
              child: Container(
                height: 45,
                margin: EdgeInsets.fromLTRB(10, 5, 0, 10),
                decoration: BoxDecoration(
                    color: default_white,//black.withOpacity(.1),
                    borderRadius: BorderRadius.circular(25),
                    border:
                        Border.all(color: black.withOpacity(.1), width: 1)),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    addSpaceWidth(10),
                    Icon(
                      Icons.search,
                      color: black.withOpacity(.5),
                      size: 17,
                    ),
                    addSpaceWidth(10),
                    Text(
                      "Search products on Fetish",
                      style: textStyle(false, 16, black.withOpacity(.6)),
                    )
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                showListDialog(
                    context, ["All", "Cosmetics", "Free", "Others"], (p) {});
              },
              icon: Icon(
                Icons.dashboard,
                color: black,
              ),
            )
          ],
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
            return shopItem(context, model, () {
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
