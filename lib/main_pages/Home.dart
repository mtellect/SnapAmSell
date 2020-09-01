import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:maugost_apps/AppConfig.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/MainAdmin.dart';
import 'package:maugost_apps/SearchProduct.dart';
import 'package:maugost_apps/ShowCategories.dart';
import 'package:maugost_apps/app/dotsIndicator.dart';
import 'package:maugost_apps/assets.dart';
import 'package:maugost_apps/basemodel.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'ShowProducts.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final refreshController = RefreshController(initialRefresh: false);
  bool canRefresh = true;

  int currentPage = 0;
  final vp = PageController();
  Timer timer;
  bool reversing = false;
  final _codeWheeler = CodeWheeler(milliseconds: 8000);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 1), () {
      loadProducts(true);
    });
    if (mounted) _codeWheeler.run(pageWheeler);
  }

  @override
  dispose() {
    timer?.cancel();
    super.dispose();
  }

  pageWheeler() {
    int size = adsList.length;
    if (size == 1) return;
    if (null == vp || !mounted) return;
    if (!vp.hasClients) return;
    if (currentPage < size - 1 && !reversing) {
      reversing = false;
      if (mounted) setState(() {});
      vp.nextPage(duration: Duration(milliseconds: 12), curve: Curves.ease);
      return;
    }
    if (currentPage == size - 1 && !reversing) {
      Future.delayed(Duration(seconds: 2), () {
        reversing = true;
        if (mounted) setState(() {});
        vp.previousPage(
            duration: Duration(milliseconds: 12), curve: Curves.ease);
      });
      return;
    }
    if (currentPage == 0 && reversing) {
      Future.delayed(Duration(seconds: 2), () {
        reversing = false;
        if (mounted) setState(() {});
        vp.nextPage(duration: Duration(milliseconds: 12), curve: Curves.ease);
      });
      return;
    }

    if (currentPage == 0 && !reversing) {
      Future.delayed(Duration(seconds: 2), () {
        reversing = false;
        if (mounted) setState(() {});
        vp.nextPage(duration: Duration(milliseconds: 12), curve: Curves.ease);
      });
      return;
    }

    if (currentPage > 0 && reversing) {
      Future.delayed(Duration(seconds: 2), () {
        vp.previousPage(
            duration: Duration(milliseconds: 12), curve: Curves.ease);
      });
      return;
    }
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
      backgroundColor: default_white_color,
      body: page(),
    );
  }

  //["All", "Cosmetics", "Free", "Others"]

  page() {
    return Column(
      children: [
        //addSpace(40),
        Container(
          margin: EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    pushAndResult(context, SearchProduct());
                  },
                  child: Container(
                    height: 45,
                    //margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: white.withOpacity(.5),
                        borderRadius: BorderRadius.circular(25),
                        border:
                            Border.all(color: AppConfig.appColor, width: 2)),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        addSpaceWidth(10),
                        Expanded(
                          child: Text(
                            "Search",
                            style: textStyle(false, 16, black),
                          ),
                        ),
                        Icon(
                          Icons.search,
                          color: black.withOpacity(.8),
                          size: 20,
                        ),
                        addSpaceWidth(10),
                      ],
                    ),
                  ),
                ),
              ),
              addSpaceWidth(10),
              InkWell(
                onTap: () {
                  pushAndResult(context, ShowCategories());
                },
                child: Container(
                  child: Center(child: Icon(LineIcons.sort_alpha_desc)),
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                      color: white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppConfig.appColor, width: 2)),
                ),
              )
            ],
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
            categories(),
            addSpace(15),
            adsSlider(),
            addSpace(15),
            body(),
          ],
        ),
      ),
    );
  }

  adsSlider() {
    if (!adsSetup) return Container();

    return Container(
      height: getScreenHeight(context) * .22,
      margin: EdgeInsets.only(top: 10, bottom: 10),
      decoration: BoxDecoration(
          border: Border(
              top: BorderSide(width: 0.5, color: black.withOpacity(.09)),
              bottom: BorderSide(width: 0.5, color: black.withOpacity(.09)))),
      child: Stack(
        children: [
          PageView.builder(
              controller: vp,
              scrollDirection: Axis.horizontal,
              onPageChanged: (p) {
                currentPage = p;
                setState(() {});
              },
              itemCount: adsList.length,
              itemBuilder: (ctx, p) {
                BaseModel model = adsList[p];
                String imageUrl = getFirstPhoto(model.images);
                String url = model.getString(ADS_URL);
                String title = model.getString(TITLE);
                //"https://tinyurl.com/y3pqgajd";
                // if (p.isEven) imageUrl = "https://tinyurl.com/yxmafqng";
                //if (p.isOdd) imageUrl = "https://tinyurl.com/y6neowmn";

                return GestureDetector(
                  onTap: () {
                    openLink(url);
                  },
                  child: Container(
                    height: getScreenHeight(context) * .22,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: imageUrl,
                          height: getScreenHeight(context) * .22,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (c, s) {
                            return placeHolder(getScreenHeight(context) * .22,
                                width: double.infinity);
                          },
                        ),
                        // Container(
                        //   height: getScreenHeight(context) * .22,
                        //   width: double.infinity,
                        //   color: black.withOpacity(.3),
                        //   alignment: Alignment.center,
                        //   child: Text(
                        //     title,
                        //     style: textStyle(true, 30, white),
                        //   ),
                        // )
                      ],
                    ),
                  ),
                );
              }),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                  color: black.withOpacity(.1),
                  borderRadius: BorderRadius.circular(25)),
              padding: EdgeInsets.all(2),
              margin: EdgeInsets.all(5),
              child: DotsIndicator(
                dotsCount: adsList.length,
                position: currentPage,
                decorator: DotsDecorator(
                    activeColor: AppConfig.appColor,
                    spacing: EdgeInsets.all(3),
                    activeSize: Size(10, 10),
                    size: Size(5, 5)),
              ),
            ),
          )
        ],
      ),
    );
  }

  categories() {
    if (null == appSettingsModel) return Container();
    List<BaseModel> appCategories = appSettingsModel.getListModel(CATEGORIES);

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.3),
      itemBuilder: (c, p) {
        BaseModel model = appCategories[p];
        String categoryName = model.getString(TITLE);
        String image = getFirstPhoto(model.images);

        return GestureDetector(
          onTap: () {
            pushAndResult(context, ShowProducts(model));
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: black.withOpacity(.09))),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: image,
                    height: double.infinity,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (c, s) {
                      return Container(
                        height: double.infinity,
                        width: double.infinity,
                        color: black.withOpacity(.09),
                        child: Icon(
                          LineIcons.image,
                          color: white.withOpacity(.5),
                        ),
                      );
                    },
                  ),
                  Container(
                    height: double.infinity,
                    width: double.infinity,
                    color: black.withOpacity(.4),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: EdgeInsets.fromLTRB(8, 8, 8, 8),
                      padding: EdgeInsets.all(5),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: AppConfig.appColor,
                          borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        categoryName,
                        style: textStyle(false, 12, black),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
      itemCount: appCategories.length,
      padding: EdgeInsets.all(0),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
    );
  }

  body() {
    return Builder(
      builder: (ctx) {
        if (!productSetup)
          return Container(
            height: 200,
            child: loadingLayout(trans: true),
          );

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.65),
          itemBuilder: (c, p) {
            BaseModel model = productLists[p];
            List likes = model.getList(LIKES);
            bool isFavorite = likes.contains(userModel.getUserId());
            //print('favorite $isFavorite');
            return shopItem(
              context,
              model,
              () {
                setState(() {});
              },
              isFavorite: isFavorite,
            );
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
