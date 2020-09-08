import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maugost_apps/AppConfig.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/SearchProduct.dart';
import 'package:maugost_apps/ShowFilter.dart';
import 'package:maugost_apps/assets.dart';
import 'package:maugost_apps/basemodel.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ShowProducts extends StatefulWidget {
  final BaseModel category;
  ShowProducts(this.category);
  @override
  _ShowProductsState createState() => _ShowProductsState();
}

class _ShowProductsState extends State<ShowProducts> {
  List<BaseModel> productLists = [];
  bool hasSetup = false;
  final refreshController = RefreshController(initialRefresh: false);
  bool canRefresh = true;
  String category;
  String categoryId;

  @override
  initState() {
    super.initState();
    setState(() {
      category = widget.category.getString(TITLE);
      categoryId = widget.category.getObjectId();
    });
    loadProducts(true);
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  dispose() {
    super.dispose();
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
        .where(CATEGORY, isEqualTo: category)
        .limit(12)
        .orderBy(CREATED_AT, descending: !isNew)
        .startAt(startFeedAt)
        .getDocuments()
        .then((value) {
      local = value.documents;
      for (var doc in value.documents) {
        print("oooo");

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
      hasSetup = true;
      if (mounted) setState(() {});
    }).catchError((e) {
      checkError(context, e);
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(top: 40, right: 10, left: 10, bottom: 10),
          child: Row(
            children: [
              BackButton(),
              Expanded(
                child: Container(
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
                                color: white_color,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: AppConfig.appColor, width: 2)),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                addSpaceWidth(10),
                                Expanded(
                                  child: Text(
                                    "Search in $category",
                                    style: textStyle(
                                        false, 16, black.withOpacity(.6)),
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
                          pushAndResult(
                              context, ShowFilter(categoryId: categoryId));
                        },
                        child: Container(
                          child: Center(child: Icon(Icons.tune_outlined)),
                          height: 45,
                          width: 45,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppConfig.appColor, width: 2)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
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
            body(),
          ],
        ),
      ),
    );
  }

  body() {
    return Builder(
      builder: (ctx) {
        if (!hasSetup)
          return Container(
            height: getScreenHeight(context) * .7,
            child: loadingLayout(trans: true),
          );

        if (productLists.isEmpty)
          return Container(
            height: getScreenHeight(context) * .7,
            child: Center(
              child: emptyLayout(ic_product, 'Oops! Nothing Yet',
                  'Modify your search and try again', clickText: 'Reload',
                  click: () {
                setState(() {
                  hasSetup = false;
                });
                loadProducts(false);
              }),
            ),
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
