import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maugost_apps/AppConfig.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/assets.dart';
import 'package:maugost_apps/auth/login_page.dart';
import 'package:maugost_apps/basemodel.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'ShowOrder.dart';

class OrderItem extends StatefulWidget {
  //final int position;
  OrderItem();
  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem>
    with AutomaticKeepAliveClientMixin {
  final refreshController = RefreshController(initialRefresh: false);
  bool canRefresh = true;
  List<BaseModel> listItems = [];
  bool ready = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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

    Firestore.instance
        .collection(ORDER_BASE)
        .where(PARTIES, arrayContains: userModel.getUserId())
        .limit(30)
        .orderBy(CREATED_AT, descending: !isNew)
        .startAt(startFeedAt)
        .getDocuments()
        .then((value) {
      local = value.documents;
      for (var doc in value.documents) {
        BaseModel model = BaseModel(doc: doc);
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

  // @override
  // void dispose() {
  //   // TODO: implement dispose
  //   super.dispose();
  //   for (var sub in subs) sub.cancel();
  // }

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
      return emptyLayout(Icons.local_offer, "Sign in to view Orders", "",
          clickText: "Sign in", click: () {
        pushAndResult(context, LoginPage(), depend: false);
      });
    return refresher();
  }

  refresher() {
    return SmartRefresher(
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
    );
  }

  body() {
    return Builder(
      builder: (ctx) {
        if (!ready)
          return Container(
            height: getScreenHeight(context) * .6,
            child: loadingLayout(trans: true),
          );
        if (listItems.isEmpty)
          return Container(
            height: getScreenHeight(context) * .6,
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
          itemBuilder: (c, p) {
            String orderId = orderedList.keys.toList()[p];
            print(orderId);
            List<BaseModel> orders = orderedList[orderId].toList();

            final date =
                DateTime.fromMillisecondsSinceEpoch(orders[0].getTime());
            String formatted = DateFormat("MMMM dd, yyy.").format(date);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(15, 5, 10, 5),
                  decoration: BoxDecoration(
                      color: red0,
                      borderRadius: BorderRadius.all(Radius.circular(25))),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      addSpaceWidth(5),
                      Text(
                        "${orders.length} ${orders.length > 1 ? "Orders" : "Order"} on $formatted",
                        style: textStyle(true, 15, white),
                      ),
                      addSpaceWidth(5),
                    ],
                  ),
                ),
                ...List.generate(orders.length > 2 ? 2 : orders.length,
                    (index) {
                  BaseModel model = orders[index];
                  return orderItem(model, () {
                    setState(() {});
                  });
                }),
                FlatButton(
                    onPressed: () {
                      pushAndResult(
                          context,
                          ShowOrder(
                            orderId: orderId,
                            orders: orders,
                            date: formatted,
                          ));
                    },
                    color: AppConfig.appColor,
                    child: Center(
                        child: Text(
                            "Show all ${orders.length > 2 ? "(${orders.length - 2} Hidden)" : ""}")))
              ],
            );
          },
          itemCount: orderedList.keys.length,
          padding: EdgeInsets.all(0),
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
        );
      },
    );
  }

  Map<String, List<BaseModel>> get orderedList {
    //List<String> orderIds = [];
    Map<String, List<BaseModel>> orders = {};
    for (var model in listItems) {
      String orderId = model.getString(ORDER_ID);
      bool available = orders.containsKey(orderId);
      if (available) {
        orders[orderId].add(model);
      } else {
        List<BaseModel> order = [];
        order.add(model);
        orders[orderId] = order;
      }
    }
    return orders;
  }

  orderItem(
    BaseModel model,
    setState,
  ) {
    double myBid = model.getDouble(MY_BID);
    String otherPersonId = getOtherPersonId(model);
    String image = getFirstPhoto(model.images);
    String title = model.getString(TITLE);
    String desc = model.getString(DESCRIPTION);
    int quantity = model.getInt(QUANTITY);
    double price = model.getDouble(PRICE) * quantity;

    return Container(
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      addSpace(5),
                      Text(
                        "\$$price",
                        style: textStyle(true, 12, black.withOpacity(.5)),
                      ),
                      addSpace(5),
                      Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: black.withOpacity(.05),
                            border: Border.all(color: black.withOpacity(.08))),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            userImageItem(context, model,
                                padLeft: false, size: 30),
                            addSpaceWidth(5),
                            Text(
                              model.getString(NAME),
                              style: textStyle(true, 13, black),
                            ),
                            addSpaceWidth(5),
                          ],
                        ),
                      )
                    ],
                  )),
            ],
          ),
          addLine(.5, black.withOpacity(.1), 0, 10, 0, 0)
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

// extension Iterables<E> on Iterable<E> {
//   Map<K, List<E>> groupBy<K>(K Function(E) keyFunction) => fold(
//       <K, List<E>>{},
//           (Map<K, List<E>> map, E element) =>
//       map..putIfAbsent(keyFunction(element), () => <E>[]).add(element));
// }
