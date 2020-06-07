import 'package:Strokes/AppEngine.dart';
import 'package:Strokes/MainAdmin.dart';
import 'package:Strokes/app_config.dart';
import 'package:Strokes/assets.dart';
import 'package:Strokes/main_pages/EditProfile.dart';
import 'package:Strokes/main_pages/ShowProduct.dart';
import 'package:Strokes/payment_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ShowCart extends StatefulWidget {
  @override
  _ShowCartState createState() => _ShowCartState();
}

class _ShowCartState extends State<ShowCart> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
                "My Cart",
                style: textStyle(true, 25, textColor),
              ),
              Spacer(),
            ],
          ),
        ),
        Flexible(child: Builder(
          builder: (c) {
            if (cartLists.isEmpty)
              return Center(
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
                        "Nothing in Cart Yet",
                        style: textStyle(true, 20, black),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );

            return ListView.builder(
                padding: EdgeInsets.all(0),
                itemCount: cartLists.length,
                itemBuilder: (c, p) {
                  return cartItem(p);
                });
          },
        )),
        if (cartLists.isNotEmpty)
          Container(
            padding: EdgeInsets.all(15),
            child: FlatButton(
              onPressed: () {
                if (userModel.signUpCompleted) {
                  pushAndResult(
                      context,
                      PaymentDialog(
                        amount: getTotalCost,
                      ),
                      depend: false);
                  return;
                }

                pushAndResult(
                    context,
                    EditProfile(
                      modeEdit: true,
                    ),
                    depend: false);
              },
              color: AppConfig.appColor,
              padding: EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: white)),
              child: Center(
                child: Text(
                  "CHECKOUT (Total \$$getTotalCost)",
                  style: textStyle(true, 16, white),
                ),
              ),
            ),
          )
      ],
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
    final model = cartLists[p];
    int pos =
        cartLists.indexWhere((e) => e.getObjectId() == model.getObjectId());
    bool isInCart = pos != -1;
    String id = model.getObjectId();
    String image = getFirstPhoto(model.images);
    String category = model.getString(CATEGORY);
    String title = model.getString(TITLE);
    int quantity = model.getInt(QUANTITY);
    double price = model.getDouble(PRICE) * quantity;

    return GestureDetector(
      onTap: () {
        pushAndResult(context, ShowProduct(model), depend: false, result: (_) {
          setState(() {});
        });
      },
      child: Container(
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: white.withOpacity(.1)),
            color: white.withOpacity(.05)),
        child: Stack(
          alignment: Alignment.topRight,
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
                          children: [
                            Text.rich(TextSpan(children: [
                              TextSpan(
                                  text: "Category ",
                                  style: textStyle(
                                      false, 12, black.withOpacity(.5))),
                              TextSpan(
                                  text: category,
                                  style: textStyle(false, 12, black)),
                            ])),
                            addSpace(2),
                            Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: textStyle(true, 18, black),
                            ),
                            addSpace(2),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: black.withOpacity(.09), width: 1),
                                  color: AppConfig.appColor,
                                  borderRadius: BorderRadius.circular(8)),
                              padding: EdgeInsets.all(8),
                              child: Text(
                                "\$$price",
                                style: textStyle(true, 16, black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      color: black, borderRadius: BorderRadius.circular(18)),
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          cartLists[p]
                              .put(QUANTITY, quantity == 1 ? 1 : quantity - 1);
                          setState(() {});
                        },
                        child: Container(
                          height: 20,
                          width: 40,
                          decoration: BoxDecoration(shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: Text(
                            "-",
                            style: textStyle(false, 16, white),
                          ),
                        ),
                      ),
                      Text(
                        "$quantity",
                        style: textStyle(true, 15, white),
                      ),
                      GestureDetector(
                        onTap: () {
                          cartLists[p].put(QUANTITY, quantity + 1);
                          setState(() {});
                        },
                        child: Container(
                          height: 20,
                          width: 40,
                          decoration: BoxDecoration(shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: Text(
                            "+",
                            style: textStyle(false, 16, white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                cartController.add(model);
                setState(() {});
              },
              child: Container(
                child: Icon(
                  Icons.close,
                  color: white,
                  size: 15,
                ),
                height: 25,
                width: 25,
                decoration: BoxDecoration(
                    color: red, borderRadius: BorderRadius.circular(10)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
