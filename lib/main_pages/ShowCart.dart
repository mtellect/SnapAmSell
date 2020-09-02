import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:maugost_apps/AppConfig.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/MainAdmin.dart';
import 'package:maugost_apps/PreAuth.dart';
import 'package:maugost_apps/assets.dart';
import 'package:maugost_apps/main_pages/EditProfile.dart';
import 'package:maugost_apps/main_pages/ShowProduct.dart';

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
                style: textStyle(true, 20, textColor),
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
                        "Your Cart is Empty",
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
                if (!isLoggedIn) {
                  pushAndResult(context, PreAuth());
                  return;
                }

                if (!userModel.signUpCompleted) {
                  pushAndResult(
                      context,
                      EditProfile(
                        modeEdit: true,
                      ),
                      depend: false);
                  return;
                }

                double accountBal = userModel.getDouble(ESCROW_BALANCE);
                double offerAmount = getTotalCost;
                double leftOver = accountBal - offerAmount;
                if (accountBal == 0 || leftOver.isNegative) {
                  showMessage(
                      context,
                      Icons.warning,
                      red,
                      "Insufficient Funds",
                      "Oops! You do not have sufficient"
                          " funds in your wallet. Please"
                          " add funds to your wallet to proceed.",
                      clickYesText: "Fund Wallet", onClicked: (_) {
                    if (_)
                      fundWallet(context, onProcessed: () {
                        setState(() {});
                      });
                  });
                  return;
                }
                showProgress(true, context, msg: "Checking Out...");
                handleOrder(context, cartLists, getTotalCost,
                    onOfferSettled: () {
                  showProgress(false, context);
                  showMessage(
                      context,
                      Icons.check,
                      green_dark,
                      "Order CheckedOut",
                      "Your order has been checked out and it's being processed.\n"
                          "We'd keep you posted on the status of order or visit the"
                          " offer tab to see the progress",
                      cancellable: false, onClicked: (_) {
                    if (_) {
                      Navigator.pop(context);
                      cartController.add(null);
                    }
                  }, delayInMilli: 2000);
                });
              },
              color: AppConfig.appColor,
              padding: EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: white)),
              child: Center(
                child: Text(
                  "CHECKOUT (TOTAL \$$getTotalCost)",
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
      child: Column(
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
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        color: transparent,
                        height: 100,
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                                color: black,
                                borderRadius: BorderRadius.circular(25)),
//                  padding: EdgeInsets.all(8),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    cartLists[p].put(QUANTITY,
                                        quantity == 1 ? 1 : quantity - 1);
                                    setState(() {});
                                  },
                                  child: Container(
                                    height: 30,
                                    width: 40,
                                    decoration:
                                        BoxDecoration(shape: BoxShape.circle),
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
                                    height: 30,
                                    width: 40,
                                    decoration:
                                        BoxDecoration(shape: BoxShape.circle),
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
                        ),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () {
                      yesNoDialog(context, "Remove Item", "Are you sure?", () {
                        cartController.add(model);
                        setState(() {});
                      });
                    },
                    child: Container(
                      child: Icon(
                        Icons.close,
                        color: white,
                        size: 15,
                      ),
                      height: 25,
                      width: 25,
                      decoration:
                          BoxDecoration(color: red, shape: BoxShape.circle
//                    borderRadius: BorderRadius.circular(10)
                              ),
                    ),
                  ),
                )
              ],
            ),
          ),
          addLine(.5, black.withOpacity(.1), 10, 0, 10, 0)
        ],
      ),
    );
  }
}
