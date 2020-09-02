import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maugost_apps/AppConfig.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/assets.dart';
import 'package:maugost_apps/basemodel.dart';

class RecentlyViewed extends StatefulWidget {
  @override
  _RecentlyViewedState createState() => _RecentlyViewedState();
}

class _RecentlyViewedState extends State<RecentlyViewed> {
  List<BaseModel> productLists = [];
  bool hasSetup = false;

  @override
  initState() {
    super.initState();
    loadProducts(false);
  }

  loadProducts(bool isNew) async {
    final productIDs = userModel.getList(SEEN_PRODUCTS);
    for (var id in productIDs) {
      Firestore.instance
          .collection(PRODUCT_BASE)
          .document(id)
          .get()
          .then((doc) {
        BaseModel model = BaseModel(doc: doc);
        int p = productLists
            .indexWhere((e) => e.getObjectId() == model.getObjectId());
        if (p != -1) {
          productLists[p] = model;
        } else {
          productLists.add(model);
        }
        hasSetup = true;
        if (mounted) setState(() {});
      });
    }
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
                color: black,
              ),
              Text(
                "Recently Viewed",
                style: textStyle(true, 20, black),
              ),
              Spacer(),
            ],
          ),
        ),
        Flexible(child: Builder(
          builder: (ctx) {
            if (!hasSetup)
              return Container(
                //height: getScreenHeight(context) * .5,
                child: loadingLayout(trans: true),
              );
            if (productLists.isEmpty)
              return Container(
                //height: getScreenHeight(context) * .5,
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
                          "No Recently View Yet",
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
                BaseModel model = productLists[p];
                return shopItem(context, model, () {
                  setState(() {});
                });
              },
              itemCount: productLists.length,
              padding: EdgeInsets.all(7),
              //physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
            );
          },
        ))
      ],
    );
  }
}
