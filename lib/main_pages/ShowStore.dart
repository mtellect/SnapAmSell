import 'package:Strokes/AppEngine.dart';
import 'package:Strokes/MainAdmin.dart';
import 'package:Strokes/app/app.dart';
import 'package:Strokes/app_config.dart';
import 'package:Strokes/assets.dart';
import 'package:Strokes/basemodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ShowStore extends StatefulWidget {
  final BaseModel model;
  ShowStore(this.model);
  @override
  _ShowStoreState createState() => _ShowStoreState();
}

class _ShowStoreState extends State<ShowStore> {
  List<BaseModel> productLists = [];
  bool hasSetup = false;

  @override
  initState() {
    super.initState();
    if (widget.model.myItem()) productLists = myProducts;
    hasSetup = productLists.isNotEmpty;
    loadProducts(false);
  }

  loadProducts(bool isNew) async {
    Firestore.instance
        .collection(PRODUCT_BASE)
        .where(
          USER_ID,
          isEqualTo: widget.model.getUserId(),
        )
        //.limit(30)
        .getDocuments()
        .then((shots) {
      for (DocumentSnapshot doc in shots.documents) {
        BaseModel model = BaseModel(doc: doc);
        int p = productLists
            .indexWhere((e) => e.getObjectId() == model.getObjectId());
        if (p != -1) {
          productLists[p] = model;
        } else {
          productLists.add(model);
        }
      }
      hasSetup = true;
      if (widget.model.myItem()) myProducts = productLists;
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
                color: white,
              ),
              Text(
                widget.model.myItem() ? "My Store" : "Store",
                style: textStyle(true, 25, white),
              ),
              Spacer(),
            ],
          ),
        ),
        Flexible(
            child: ListView(
          padding: EdgeInsets.all(0),
          children: [
            Container(
              margin: EdgeInsets.all(15),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: white.withOpacity(.05),
                  border: Border.all(color: black.withOpacity(.09)),
                  borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Column(
                    children: [
                      imageHolder(60, widget.model.imageUrl,
                          stroke: 1, strokeColor: white),
                      Text(
                        widget.model.getString(NAME),
                        style: textStyle(false, 16, white),
                      ),
                      StarRating(
                        rating: 5,
                        size: 16,
                        color: AppConfig.appColor,
                        borderColor: white,
                      ),
                      addSpace(5),
                      Row(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 15,
                                color: white,
                              ),
                              addSpaceWidth(2),
                              Text(
                                "Buyer",
                                style: textStyle(false, 13, white),
                              ),
                            ],
                          ),
                          addSpaceWidth(10),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: 10,
                                width: 10,
                                decoration: BoxDecoration(
                                    color: dark_green0, shape: BoxShape.circle),
                              ),
                              addSpaceWidth(2),
                              Text(
                                "Active",
                                style: textStyle(false, 13, white),
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                  Spacer(),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: white, width: 2),
                        color: black.withOpacity(.9),
                        borderRadius: BorderRadius.circular(15)
                        //shape: BoxShape.circle
                        ),
                    padding: EdgeInsets.all(5),
                    //height: 70,
                    //width: 70,
                    alignment: Alignment.center,
                    child: Row(
                        children: List.generate(3, (p) {
                      String title = "likes";
                      var icon = Icons.favorite;

                      if (p == 1) {
                        title = "Views";
                        icon = Icons.visibility;
                      }

                      if (p == 2) {
                        title = "Stars";
                        icon = Icons.star;
                      }

                      return Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              icon,
                              size: 18,
                              color: white,
                            ),
                            addSpace(5),
                            Text(
                              "15 $title",
                              style: textStyle(false, 13, white),
                            ),
                          ],
                        ),
                      );
                    })),
                  ),
                  addSpaceWidth(10),
                ],
              ),
            ),
            addSpace(10),
            Container(
              //height: 40,
              padding: EdgeInsets.all(10),
              alignment: Alignment.centerLeft,
              color: white.withOpacity(.02),
              child: Text(
                "Products",
                style: textStyle(true, 20, white),
              ),
            ),
            Builder(
              builder: (ctx) {
                if (!hasSetup)
                  return Container(
                    height: getScreenHeight(context) * .5,
                    child: loadingLayout(trans: true),
                  );
                if (productLists.isEmpty)
                  return Container(
                    height: getScreenHeight(context) * .5,
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
                              style: textStyle(true, 20, white),
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
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                );
              },
            )
          ],
        ))
      ],
    );
  }
}
