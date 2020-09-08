import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'AppConfig.dart';
import 'AppEngine.dart';
import 'assets.dart';
import 'basemodel.dart';

//7.19.1

class MainAdminWeb extends StatefulWidget {
  @override
  _MainAdminWebState createState() {
    // TODO: implement createState
    return _MainAdminWebState();
  }
}

class _MainAdminWebState extends State<MainAdminWeb> {
  List<BaseModel> productLists = [];
  bool productSetup = false;

  List<StreamSubscription> subs = List();
  int timeOnline = 0;
  String noInternetText = "";

  String flashText = "";
  bool setup = false;
  bool settingsLoaded = false;
  String uploadingText;
  int peopleCurrentPage = 0;
  bool tipHandled = false;
  bool tipShown = true;

  bool posting = false;
  bool hasPosted = false;
  double progress = 0.0;

  ScrollController scrollController = ScrollController();
  bool showIcon = false;
  double searchIconOpacity = 1;
  double iconOpacity = 0;

  FocusNode focusNode = FocusNode();

  @override
  void dispose() {
    // TODO: implement dispose
    for (var sub in subs) {
      sub.cancel();
    }
    super.dispose();
  }

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      createUserListener();
    });
    scrollController.addListener(() {
      final position = scrollController.position.pixels;
      showIcon = position > 50;
      double v = position / 100;
      print("Scroll v $v $position");

      iconOpacity = v.clamp(0, 1);
      searchIconOpacity = (1.0 - iconOpacity).clamp(0, 1);
      setState(() {});
    });
  }

  void createUserListener() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user != null) {
      var userSub = Firestore.instance
          .collection(USER_BASE)
          .document(user.uid)
          .snapshots()
          .listen((shot) async {
        if (shot != null) {
          FirebaseUser user = await FirebaseAuth.instance.currentUser();
          if (user == null) return;
          isLoggedIn = true;
          userModel = BaseModel(doc: shot);
          isAdmin = userModel.getBoolean(IS_ADMIN) ||
              userModel.getString(EMAIL) == "johnebere58@gmail.com" ||
              userModel.getString(EMAIL) == "ammaugost@gmail.com";
          if (mounted) setState(() {});

          // if (!settingsLoaded) {
          //   settingsLoaded = true;
          //   loadSettings();
          // }
        }
      });
      subs.add(userSub);
    }
    if (!settingsLoaded) {
      settingsLoaded = true;
      loadSettings();
    }
  }

  loadSettings() async {
    var settingsSub = Firestore.instance
        .collection(APP_SETTINGS_BASE)
        .document(APP_SETTINGS)
        .snapshots()
        .listen((shot) {
      if (shot != null) {
        appSettingsModel = BaseModel(doc: shot);
        List banned = appSettingsModel.getList(BANNED);
        if (mounted) setState(() {});

        String genMessage = appSettingsModel.getString(GEN_MESSAGE);
        int genMessageTime = appSettingsModel.getInt(GEN_MESSAGE_TIME);

        if (userModel.getInt(GEN_MESSAGE_TIME) != genMessageTime &&
            genMessageTime > userModel.getTime()) {
          userModel.put(GEN_MESSAGE_TIME, genMessageTime);
          userModel.updateItems();

          String title = !genMessage.contains("+")
              ? "Announcement!"
              : genMessage.split("+")[0].trim();
          String message = !genMessage.contains("+")
              ? genMessage
              : genMessage.split("+")[1].trim();
          showMessage(context, Icons.info, blue0, title, message);
        }

        if (!setup) {
          setup = true;
          blockedIds.addAll(userModel.getList(BLOCKED));
//           onResume();
//           //loadItems();
//           loadNotification();
//           loadMessages();
// //          loadCarts();
// //          loadProducts();
//           loadBids();
//           loadOrders();
//           setupPush();
//           loadBlocked();
//           updatePackage();
//           chkUpdate();
//           setUpLocation();
//           loadAds();
          loadProducts(true);
        }
      }
    });
    subs.add(settingsSub);
  }

  double scaleSize(BoxConstraints con, double neededSize) {
    double screenWidth = con.maxWidth;
    double scaleFactor = (screenWidth / 1000).clamp(0.5, 2);
    double size = neededSize * scaleFactor;
    //print("no clamp ${(screenWidth / 1000)}");
    //print("clamp ${(screenWidth / 1000).clamp(0, 1.2)}");
    //print("res ${(screenWidth / 1000).clamp(0, 1) * 30}");
    return size;
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
        //refreshController.refreshCompleted();
      } else {
        /*int oldLength = productLists.length;
        int newLength = local.length;
        if (newLength <= oldLength) {
          refreshController.loadNoData();
          canRefresh = false;
        } else {
          refreshController.loadComplete();
        }*/
        //refreshController.loadComplete();
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
    // TODO: implement build
    return Scaffold(
        //backgroundColor: white_color,
        body: LayoutBuilder(
      builder: (c, con) {
        return Column(
          children: [
            buildAppBar(con),
            Flexible(
              child: RawKeyboardListener(
                focusNode: focusNode,
                onKey: (e) {
                  print("Key Pressed ${e.data}");
                },
                autofocus: true,
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      buildSearchBar(con),
                      buildCategories(con),
                      buildTrending(con)
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ));
  }

  buildAppBar(BoxConstraints con) {
    return Material(
      elevation: 12,
      color: transparent,
      child: Container(
        //alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: AppConfig.appColor,
            gradient: LinearGradient(colors: [
              AppConfig.appColor_dark,
              AppConfig.appColor,
            ], begin: Alignment.topCenter, end: Alignment.bottomRight)),
        child: Row(
          children: [
            Expanded(
              child: AnimatedOpacity(
                opacity: iconOpacity,
                duration: Duration(milliseconds: 100),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        ic_launcher,
                        height: 40,
                        width: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                    addSpaceWidth(10),
                    Text(
                      'SnapAmSell',
                      //pageResource[currentPage]["title"],
                      style: textStyle(true, 18, white),
                    ),
                  ],
                ),
              ),
            ),
            RaisedButton(
              onPressed: () {},
              color: transparent,
              elevation: 0,
              child: Text(
                'Sign In',
                style: textStyle(false, 13, white),
              ),
            ),
            Container(
              height: 20,
              width: 1,
              color: white,
            ),
            RaisedButton(
              onPressed: () {},
              color: transparent,
              elevation: 0,
              child: Text(
                'Registration',
                style: textStyle(false, 13, white),
              ),
            ),
            addSpaceWidth(10),
            RaisedButton(
              onPressed: () {},
              color: Colors.orange,
              child: Text(
                'Sell',
                //pageResource[currentPage]["title"],
                style: textStyle(false, 18, black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildSearchBar(BoxConstraints con) {
    double scaledBoxSize = scaleSize(con, 200);
    double boxSize = scaleSize(con, (0));

    if (con.maxWidth > 500) {
      boxSize = scaleSize(con, (scaledBoxSize));
    }

    if (con.maxWidth > 1250) {
      boxSize = scaleSize(con, (scaledBoxSize)).clamp(0, 350);
    }

    print("Scaled $boxSize");

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(left: 10, right: 10, top: 10),
      decoration: BoxDecoration(
          color: AppConfig.appColor,
          gradient: LinearGradient(colors: [
            AppConfig.appColor_dark,
            AppConfig.appColor,
          ], begin: Alignment.topCenter, end: Alignment.bottomRight)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //if (con.maxWidth > 800)
          Container(
            height: boxSize, //100,
            width: boxSize, //100,
            color: transparent,
            margin: EdgeInsets.only(right: 10),
            child: CachedNetworkImage(
              imageUrl: 'https://static.jiji.ng/static/img/main-page/man.png',
              height: boxSize, //100,
              width: boxSize,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                AnimatedOpacity(
                  opacity: searchIconOpacity,
                  duration: Duration(milliseconds: 100),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          ic_launcher,
                          height: 40,
                          width: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                      addSpaceWidth(10),
                      Text(
                        'SnapAmSell',
                        //pageResource[currentPage]["title"],
                        style: textStyle(true, 22, white),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 50,
                  //width: scaleSize(con, 00),
                  //padding: EdgeInsets.all(10),
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8)),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(child: Text("Type your search here")),
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(8),
                                bottomRight: Radius.circular(8))),
                        child: Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: boxSize, //100,
            width: boxSize, //100,
            color: transparent,
            margin: EdgeInsets.only(left: 10),
            child: CachedNetworkImage(
              imageUrl: 'https://static.jiji.ng/static/img/main-page/girls.png',
              height: boxSize,
              width: boxSize,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
        ],
      ),
    );
  }

  buildCategories(BoxConstraints con) {
    int crossSize = 3;
    double maxWidth = con.maxWidth;

    double scaleFactor = (con.maxWidth / 1000).clamp(0.5, 1);
    double aspectRatio = 1 * scaleFactor;
    double padding = scaleSize(con, 100);

    if (maxWidth > 500 && maxWidth < 800) {
      crossSize = 4;
      padding = scaleSize(con, 80);
    }

    if (maxWidth > 700 && maxWidth < 800) {
      crossSize = 5;
    }

    if (maxWidth > 800) {
      crossSize = 6;
    }

    if (maxWidth > 1200) {
      crossSize = 8;
    }

    if (null == appSettingsModel) return Container();
    List<BaseModel> appCategories = appSettingsModel.getListModel(CATEGORIES);

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossSize,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          childAspectRatio: 1),
      padding:
          EdgeInsets.only(top: 20, bottom: 10, left: padding, right: padding),
      itemBuilder: (c, p) {
        BaseModel model = appCategories[p];
        String categoryName = model.getString(TITLE);
        String image = getFirstPhoto(model.images);

        return MaterialButton(
          onPressed: () {
            //pushAndResult(context, ShowProducts(model));
          },
          onLongPress: () {
            // pushAndResult(
            //     context,
            //     CreateCategory(
            //       model: model,
            //     ));
          },
          color: white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            //side: BorderSide(color: black.withOpacity(.1)),
          ),
          elevation: 1.5,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  //color: black.withOpacity(.09),
                  child: CachedNetworkImage(
                    imageUrl: image,
                    height: 70,
                    width: 70,
                  ),
                ),
              ),
              Container(
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
                  maxLines: 2,
                ),
              )
            ],
          ),
        );
      },
      itemCount: appCategories.length,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
    );
  }

  buildTrending(BoxConstraints con) {
    int crossSize = 2;
    double maxWidth = con.maxWidth;

    double scaleFactor = (con.maxWidth / 1000).clamp(0.5, 1);
    double aspectRatio = 1 * scaleFactor;
    print("Maxw $maxWidth");
    double padding = scaleSize(con, 100);

    if (maxWidth > 500 && maxWidth < 800) {
      //crossSize = 4;
      padding = scaleSize(con, 80);
    }

    if (maxWidth > 700 && maxWidth < 800) {
      crossSize = 4;
    }

    if (maxWidth > 800) {
      crossSize = 4;
    }

    if (maxWidth > 1200) {
      crossSize = 6;
    }

    if (!productSetup)
      return Container(
        height: 150,
        alignment: Alignment.center,
        child: loadingLayout(),
      );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(
              top: 20, bottom: 10, left: padding, right: padding),

          child: Text(
            'Trending Ads',
            style: textStyle(true, 18, black),
            textAlign: TextAlign.center,
          ),
        ),
        GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossSize,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.65),
          padding: EdgeInsets.only(
              top: 20, bottom: 10, left: padding, right: padding),
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
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
        ),
      ],
    );
  }
}
