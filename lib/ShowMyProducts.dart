import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:maugost_apps/main_pages/SellPage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'AppConfig.dart';
import 'AppEngine.dart';
import 'app/app.dart';
import 'assets.dart';
import 'basemodel.dart';

class ShowMyProducts extends StatefulWidget {
  final bool popadsList;

  const ShowMyProducts({Key key, this.popadsList = true}) : super(key: key);
  @override
  _ShowMyProductsState createState() => _ShowMyProductsState();
}

class _ShowMyProductsState extends State<ShowMyProducts> {
  final searchController = TextEditingController();
  bool showCancel = false;
  bool searching = false;
  //List<BaseModel> adsList = appSettingsModel.getListModel(CATEGORIES);
  //List<BaseModel> mainList = appSettingsModel.getListModel(CATEGORIES);
  List<BaseModel> adsList = [];
  List<BaseModel> mainList = [];

  bool setup = false;
  final refreshController = RefreshController(initialRefresh: false);
  bool canRefresh = true;

  @override
  initState() {
    super.initState();
    searchController.addListener(listener);
    adsList.sort((a, b) => a.getString(TITLE).compareTo(b.getString(TITLE)));
    loadProducts(true);
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
        .collection(PRODUCT_BASE)
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
                "My Products",
                style: textStyle(true, 16, black),
              ),
              Spacer(),
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
                          hintText: "Search in Products ",
                          border: InputBorder.none),
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
        refresher(),
      ],
    );
  }

  refresher() {
    return Expanded(
      child: SmartRefresher(
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
      ),
    );
  }

  body() {
    return Builder(
      builder: (ctx) {
        if (!setup)
          return Container(
            height: getScreenHeight(context) * .7,
            child: loadingLayout(trans: true),
          );

        if (adsList.isEmpty)
          return Container(
            height: getScreenHeight(context) * .7,
            child: Center(
              child: emptyLayout(
                ic_product,
                'No Product Yet',
                'Add Product to Promote',
              ),
            ),
          );

        return ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(0),
          children: List.generate(adsList.length, (index) {
            return item(index);
          }),
        );
      },
    );
  }

  item(int index) {
    BaseModel model = adsList[index];
    String title = model.getString(TITLE);
    String description = model.getString(DESCRIPTION);
    String category = model.getString(CATEGORY);
    String subCategory = model.getString(SUB_CATEGORY);
    if (subCategory.isNotEmpty) category = '$category $subCategory';
    String thumbnail = model.getString(THUMBNAIL_URL);
    String image = getFirstPhoto(model.images);
    double price = model.getDouble(PRICE);

    return InkWell(
      onTap: () {
        Navigator.pop(context, model);
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
                  Text('~$category~', style: textStyle(true, 14, black)),
                  Text.rich(TextSpan(children: [
                    TextSpan(
                        text: title.substring(0, searchController.text.length),
                        style: textStyle(true, 18, black)),
                    TextSpan(
                        text: title.substring(searchController.text.length),
                        style: textStyle(false, 18, black))
                  ])),
                  Text("\$${formatCurrency.format(price)}",
                      style: textStyle(true, 14, AppConfig.appColor)),
                ],
              ),
            ),
            if (isAdmin || model.myItem())
              IconButton(
                onPressed: () {
                  pushAndResult(
                      context,
                      SellPage(
                        model: model,
                      ),
                      result: (_) {});
                },
                icon: Icon(Icons.edit),
              )
          ],
        ),
      ),
    );
  }
}
