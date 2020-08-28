import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maugost_apps/AppConfig.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/MainAdmin.dart';
import 'package:maugost_apps/assets.dart';
import 'package:maugost_apps/basemodel.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ShowOrder extends StatefulWidget {
  final String orderId;
  final String date;
  final List<BaseModel> orders;

  const ShowOrder(
      {Key key, @required this.orderId, this.orders = const [], this.date = ''})
      : super(key: key);
  @override
  _ShowOrderState createState() => _ShowOrderState();
}

class _ShowOrderState extends State<ShowOrder> {
  final refreshController = RefreshController(initialRefresh: false);
  bool canRefresh = true;
  List listItems = [];
  bool ready = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listItems = List.from(widget.orders);
    ready = widget.orders.isNotEmpty;
    setState(() {});
    loadItems(true);
  }

  loadItems(bool isNew) async {
    final startFeedAt = [
      !isNew
          ? (listItems.isEmpty
              ? DateTime.now().millisecondsSinceEpoch
              : listItems[listItems.length - 1].createdAt)
          : (listItems.isEmpty ? 0 : listItems[0].createdAt)
    ];

    List local = [];

    print(widget.orderId);

    Firestore.instance
        .collection(ORDER_BASE)
        .where(ORDER_ID, isEqualTo: widget.orderId)
        .limit(30)
        .orderBy(CREATED_AT, descending: !isNew)
        .startAt(startFeedAt)
        .getDocuments()
        .then((value) {
      local = value.documents;
      for (var doc in value.documents) {
        BaseModel model = BaseModel(doc: doc);
        List parties = model.getList(PARTIES);
        if (!parties.contains(userModel.getUserId())) continue;

        int p =
            listItems.indexWhere((e) => e.getObjectId() == model.getObjectId());
        if (p != -1) {
          listItems[p] = model;
        } else {
          listItems.add(model);
        }
      }

      if (isNew) {
        refreshController.refreshCompleted();
      } else {
        int oldLength = listItems.length;
        int newLength = local.length;
        if (newLength <= oldLength) {
          refreshController.loadNoData();
          canRefresh = false;
        } else {
          refreshController.loadComplete();
        }
      }
      ready = true;
      if (mounted) setState(() {});
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
        Container(
          padding: EdgeInsets.only(top: 35, right: 10, left: 10, bottom: 10),
          child: Row(
            children: [
              BackButton(
                  //color: white,
                  ),
              Text(
                "My Order ",
                style: textStyle(true, 25, textColor),
              ),
              if (widget.date.isNotEmpty)
                Text(
                  "on ${widget.date}",
                  style: textStyle(false, 16, textColor),
                ),
              Spacer(),
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
        enablePullUp: listItems.length > 10,
        header: WaterDropHeader(),
        footer: ClassicFooter(
          noDataText: "Nothing more for now, check later...",
          textStyle: textStyle(false, 12, white.withOpacity(.7)),
        ),
        onLoading: () {
          loadItems(false);
        },
        onRefresh: () {
          loadItems(true);
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
        if (!ready)
          return Container(
            height: getScreenHeight(context) * .9,
            child: loadingLayout(trans: true),
          );
        if (listItems.isEmpty)
          return Container(
            height: getScreenHeight(context) * .9,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Image.asset(
                      ic_cart,
                      width: 50,
                      height: 50,
                      color: AppConfig.appColor,
                    ),
                    Text(
                      "Nothing in Your Order Yet",
                      style: textStyle(true, 20, black),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );

        return ListView.builder(
            padding: EdgeInsets.all(0),
            itemCount: listItems.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (c, p) {
              return cartItem(p);
            });
      },
    );
  }

  double get getTotalCost {
    double totalCost = 0.0;
    for (var bm in cartLists) {
      int quantity = bm.getInt(QUANTITY);
      double price = bm.getDouble(PRICE) * quantity;
      totalCost = totalCost + price;
    }
    return totalCost;
  }

  cartItem(int p) {
    final model = listItems[p];
    int pos =
        cartLists.indexWhere((e) => e.getObjectId() == model.getObjectId());
    bool isInCart = pos != -1;
    String id = model.getObjectId();
    String image = getFirstPhoto(model.images);
    String category = model.getString(CATEGORY);
    String title = model.getString(TITLE);
    int quantity = model.getInt(QUANTITY);
    double price = model.getDouble(PRICE) * quantity;

    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(5),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: white.withOpacity(.1)),
              color: white.withOpacity(.05)),
          child: Stack(
            children: [
              Row(
                children: [
                  Flexible(
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: image,
                            height: 120,
                            width: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                        addSpaceWidth(15),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
//                            Text.rich(TextSpan(children: [
//                              TextSpan(
//                                  text: "Category ",
//                                  style: textStyle(
//                                      false, 12, black.withOpacity(.5))),
//                              TextSpan(
//                                  text: category,
//                                  style: textStyle(false, 12, black)),
//                            ])),
//                            addSpace(2),
                              Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: textStyle(true, 16, black),
                              ),
                              addSpace(2),
                              Text(
                                '~$category~',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: textStyle(false, 14, black),
                              ),
                              addSpace(2),
                              Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: black.withOpacity(.09),
                                        width: 1),
                                    color: AppConfig.appColor,
                                    borderRadius: BorderRadius.circular(8)),
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  "\$$price",
                                  style: textStyle(true, 12, black),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: transparent,
                    height: 100,
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                            color: black,
                            borderRadius: BorderRadius.circular(25)),
                        padding: EdgeInsets.all(8),
                        child: Row(
                          children: [
                            addSpaceWidth(5),
                            Text(
                              "$quantity ${quantity > 1 ? "Items" : "Item"}",
                              style: textStyle(true, 15, white),
                            ),
                            addSpaceWidth(5),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
//                 Align(
//                   alignment: Alignment.topRight,
//                   child: GestureDetector(
//                     onTap: () {
//                       yesNoDialog(context, "Remove Item", "Are you sure?", () {
//                         cartController.add(model);
//                         setState(() {});
//                       });
//                     },
//                     child: Container(
//                       child: Icon(
//                         Icons.close,
//                         color: white,
//                         size: 15,
//                       ),
//                       height: 25,
//                       width: 25,
//                       decoration:
//                           BoxDecoration(color: red, shape: BoxShape.circle
// //                    borderRadius: BorderRadius.circular(10)
//                               ),
//                     ),
//                   ),
//                 )
            ],
          ),
        ),
        addLine(.5, black.withOpacity(.1), 10, 0, 10, 0)
      ],
    );
  }
}
