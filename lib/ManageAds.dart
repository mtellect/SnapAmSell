import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:maugost_apps/AddAds.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'AppConfig.dart';
import 'AppEngine.dart';
import 'CreateCategory.dart';
import 'assets.dart';
import 'basemodel.dart';

class ManageAds extends StatefulWidget {
  @override
  _ManageAdsState createState() => _ManageAdsState();
}

class _ManageAdsState extends State<ManageAds> {
  final searchController = TextEditingController();
  bool showCancel = false;
  bool searching = false;
  List<BaseModel> adsList = [];
  List<BaseModel> mainList = [];
  int currentPage = 0;
  final vp = PageController();
  bool setup = false;
  final refreshController = RefreshController(initialRefresh: false);
  bool canRefresh = true;

  @override
  initState() {
    super.initState();
    adsList.sort((a, b) => a.getString(TITLE).compareTo(b.getString(TITLE)));
    searchController.addListener(listener);
    loadProducts(false);
  }

  loadProducts(bool isNew) async {
    final startFeedAt = [
      !isNew
          ? (mainList.isEmpty
              ? DateTime.now().millisecondsSinceEpoch
              : mainList[mainList.length - 1].createdAt)
          : (mainList.isEmpty ? 0 : mainList[0].createdAt)
    ];

    List local = [];
    Firestore.instance
        .collection(ADS_BASE)
        .where(USER_ID, isEqualTo: userModel.getUserId())
        .limit(30)
        .orderBy(CREATED_AT, descending: !isNew)
        .startAt(startFeedAt)
        .getDocuments()
        .then((value) {
      local = value.documents;
      for (var doc in value.documents) {
        BaseModel model = BaseModel(doc: doc);
        int p =
            mainList.indexWhere((e) => e.getObjectId() == model.getObjectId());
        if (p != -1) {
          mainList[p] = model;
        } else {
          mainList.add(model);
        }
      }

      if (isNew) {
        refreshController.refreshCompleted();
      } else {
        int oldLength = mainList.length;
        int newLength = local.length;
        if (newLength <= oldLength) {
          refreshController.loadNoData();
          canRefresh = false;
        } else {
          refreshController.loadComplete();
        }
      }
      adsList.addAll(mainList);
      setup = true;
      if (mounted) setState(() {});
    }).catchError((e) {
      checkError(context, e);
    });
  }

  listener() async {
    String text = searchController.text.trim().toLowerCase();
    if (text.isEmpty) {
      adsList = mainList;
      showCancel = false;
      searching = false;
      adsList.sort((a, b) => a.getString(TITLE).compareTo(b.getString(TITLE)));
      if (mounted) setState(() {});
      return;
    }
    showCancel = true;
    searching = true;
    if (mounted) setState(() {});

    adsList = mainList
        .where((b) => b.getString(TITLE).toLowerCase().startsWith(text))
        .toList();

    searching = false;
    if (mounted) setState(() {});
  }

  @override
  dispose() {
    super.dispose();
    searchController?.removeListener(listener);
    searchController?.dispose();
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
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.only(top: 30, right: 10, left: 10, bottom: 0),
          child: Row(
            children: [
              BackButton(),
              Text(
                "Manage Advert",
                style: textStyle(true, 16, black),
              ),
              Spacer(),
              if (isAdmin)
                RaisedButton(
                  color: AppConfig.appColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  child: Text(
                    "Create Ads",
                    style: textStyle(true, 16, black),
                  ),
                  onPressed: () {
                    pushAndResult(context, AddAds(), result: (_) {
                      mainList = appSettingsModel.getListModel(CATEGORIES);
                      setState(() {});
                    });
                  },
                ),
            ],
          ),
        ),
        addSpace(5),
        Container(
          margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
          child: Container(
              padding: EdgeInsets.only(left: 15, right: 15),
              decoration: BoxDecoration(
                  color: black.withOpacity(.04),
                  border: Border.all(
                    color: black.withOpacity(.09),
                  ),
                  borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: black.withOpacity(.4),
                    size: 20,
                  ),
                  addSpaceWidth(5),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      cursorColor: black,
                      decoration: InputDecoration(
                          hintText: "Search in Ads ", border: InputBorder.none),
                    ),
                  ),
                  if (showCancel)
                    GestureDetector(
                      onTap: () {
                        searchController.clear();
                        adsList = mainList;
                        showCancel = false;
                        searching = false;
                        adsList.sort((a, b) =>
                            a.getString(TITLE).compareTo(b.getString(TITLE)));

                        setState(() {});
                      },
                      child: Icon(
                        LineIcons.close,
                        color: black.withOpacity(.5),
                      ),
                    ),
                ],
              )),
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: 400),
          child: LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation(orange03),
          ),
          height: searching ? 2 : 0,
          margin: EdgeInsets.only(bottom: searching ? 5 : 0),
        ),
        Container(
          height: 45,
          width: double.infinity,
          margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: Card(
            color: white,
            elevation: 0,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25)),
                side: BorderSide(color: black.withOpacity(.1), width: .5)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(1, 1, 1, 1),
              child: Row(
                children: List.generate(4, (p) {
                  String title = 'Pending';
                  if (p == 1) title = "Active";
                  if (p == 2) title = "Paused";
                  if (p == 3) title = "Declined";
                  bool selected = p == currentPage;
                  return Flexible(
                    child: GestureDetector(
                      onTap: () {
                        print(p);
                        vp.jumpToPage(p);
                      },
                      child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                              color: selected ? white : transparent,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                  color: !selected
                                      ? transparent
                                      : black.withOpacity(.1),
                                  width: .5)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
//                              if ((p == 1 && showNewMessageOffer.isNotEmpty) ||
//                                  p == 2 && showNewMessageDot.isNotEmpty)
//                                Container(
//                                  height: 10,
//                                  width: 10,
//                                  decoration: BoxDecoration(
//                                      border: Border.all(color: white),
//                                      shape: BoxShape.circle,
//                                      color: red),
//                                ),
                              Text(
                                title,
                                style: textStyle(selected, 14,
                                    selected ? black : (black.withOpacity(.5))),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )),
                    ),
                    fit: FlexFit.tight,
                  );
                }),
              ),
            ),
          ),
        ),
        Expanded(
          child: PageView.builder(
              controller: vp,
              onPageChanged: (p) {
                currentPage = p;
                setState(() {});
              },
              itemCount: 4,
              itemBuilder: (c, p) {
                return refresher(p);
              }),
        )
      ],
    );
  }

  refresher(int p) {
    return SmartRefresher(
      controller: refreshController,
      enablePullDown: true,
      enablePullUp: adsList.length > 6,
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
    );
  }

  String get currentTitle {
    String title = 'Pending';
    if (currentPage == 1) title = "Active";
    if (currentPage == 2) title = "Paused";
    if (currentPage == 3) title = "Declined";
    return title;
  }

  List<BaseModel> get currentList {
    Iterable<BaseModel> list = [];
    if (currentPage == 0)
      list = adsList.where((e) => e.getInt(STATUS) == PENDING);
    if (currentPage == 1)
      list = adsList.where((e) => e.getInt(STATUS) == APPROVED);
    if (currentPage == 2)
      list = adsList.where((e) => e.getInt(STATUS) == INACTIVE);
    if (currentPage == 3)
      list = adsList.where((e) => e.getInt(STATUS) == REJECTED);

    return list.toList();
  }

  body() {
    return Builder(
      builder: (ctx) {
        // if (!setup)
        /*return*/ Container(
          height: getScreenHeight(context) * .7,
          child: loadingLayout(trans: true),
        );

        if (currentList.isEmpty)
          return Container(
            height: getScreenHeight(context) * .7,
            child: Center(
              child: emptyLayout(
                ic_product,
                'No $currentTitle Ads Yet',
                'Promote your Store, Product or Item',
              ),
            ),
          );

        return ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(0),
          children: List.generate(currentList.length, (index) {
            return resultItem(index);
          }),
        );
      },
    );
  }

  resultItem(int index) {
    BaseModel model = currentList[index];
    String categoryName = model.getString(TITLE);
    String description = model.getString(DESCRIPTION);
    String category = model.getString(CATEGORY);
    String thumbnail = model.getString(THUMBNAIL_URL);
    String image = getFirstPhoto(model.images);

    return InkWell(
      onTap: () {
        //Navigator.pop(context, model);
      },
      child: Container(
        padding: EdgeInsets.all(5),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: black.withOpacity(.1))),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: image,
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                      placeholder: (c, s) {
                        return Container(
                          height: 80,
                          width: 80,
                          color: black.withOpacity(.09),
                          child: Icon(LineIcons.image),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            addSpaceWidth(10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(TextSpan(children: [
                    TextSpan(
                        text: categoryName.substring(
                            0, searchController.text.length),
                        style: textStyle(true, 18, black)),
                    TextSpan(
                        text: categoryName
                            .substring(searchController.text.length),
                        style: textStyle(false, 18, black))
                  ])),
                ],
              ),
            ),
            if (isAdmin || model.myItem()) ...[
              IconButton(
                onPressed: () {
                  pushAndResult(
                      context,
                      CreateCategory(
                        model: model,
                      ), result: (_) {
                    mainList = appSettingsModel.getListModel(CATEGORIES);
                    setState(() {});
                  });
                },
                icon: Icon(Icons.edit),
              ),
              IconButton(
                onPressed: () {
                  yesNoDialog(context, "Delete Ad",
                      "Are you sure you want to disable and delete this ad from Fetish?",
                      () {
                    mainList.remove(model);
                    adsList.remove(model);
                    setState(() {});
                  });
                },
                icon: Icon(
                  Icons.delete,
                  color: red,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
