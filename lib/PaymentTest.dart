// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:maugost_apps/AppEngine.dart';

import 'assets.dart';

const bool kAutoConsume = true;

const List<String> _kProductIds = <String>[
  "strock_one_month",
  'strock_six_month',
  'strock_one_months'
];

class PaymentTest extends StatefulWidget {
  @override
  _PaymentTestState createState() => _PaymentTestState();
}

class _PaymentTestState extends State<PaymentTest> {
  final InAppPurchaseConnection _connection = InAppPurchaseConnection.instance;
  StreamSubscription<List<PurchaseDetails>> _subscription;
  List<String> _notFoundIds = [];
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];
//  List<String> _consumables = [];
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = true;
  String _queryProductError;
  int selectedCoins = 0;
  int selectedPosition = -1;

  @override
  void initState() {
    Stream purchaseUpdated =
        InAppPurchaseConnection.instance.purchaseUpdatedStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // handle error here.
    });
    initStoreInfo();
    super.initState();
  }

  Future<void> initStoreInfo() async {
    final bool isAvailable = await _connection.isAvailable();
    if (!isAvailable) {
      setState(() {
        _isAvailable = isAvailable;
        _products = [];
        _purchases = [];
        _notFoundIds = [];
//        _consumables = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    ProductDetailsResponse productDetailResponse =
        await _connection.queryProductDetails(_kProductIds.toSet());
    if (productDetailResponse.error != null) {
      setState(() {
        _queryProductError = productDetailResponse.error.message;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = [];
        _notFoundIds = productDetailResponse.notFoundIDs;
//        _consumables = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {
        _queryProductError = null;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = [];
        _notFoundIds = productDetailResponse.notFoundIDs;
//        _consumables = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    final QueryPurchaseDetailsResponse purchaseResponse =
        await _connection.queryPastPurchases();
    if (purchaseResponse.error != null) {
      // handle query past purchase error..
    }
    final List<PurchaseDetails> verifiedPurchases = [];
    for (PurchaseDetails purchase in purchaseResponse.pastPurchases) {
      if (await _verifyPurchase(purchase)) {
        verifiedPurchases.add(purchase);
      }
    }
//    List<String> consumables = await ConsumableStore.load();
    setState(() {
      _isAvailable = isAvailable;
      _products = productDetailResponse.productDetails;
      _purchases = verifiedPurchases;
      _notFoundIds = productDetailResponse.notFoundIDs;
//      _consumables = consumables;
      _purchasePending = false;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stack = [];
    if (_queryProductError == null) {
      stack.add(
        ListView(
          children: [
            _buildConnectionCheckTile(),
            _buildProductList(),
//            _buildConsumableBox(),
          ],
        ),
      );
    } else {
      stack.add(Center(
        child: Text(_queryProductError),
      ));
    }
    if (_purchasePending) {
      stack.add(
        Stack(
          children: [
            Opacity(
              opacity: 0.3,
              child: const ModalBarrier(dismissible: false, color: Colors.grey),
            ),
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      );
    }

    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, "");
        return;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: white,
        body: page(),
      ),
    );
  }

  Builder page() {
    return Builder(builder: (context) {
      return new Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          addSpace(30),
          new Container(
            width: double.infinity,
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                InkWell(
                    onTap: () {
                      Navigator.of(context).pop("");
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      child: Center(
                          child: Icon(
                        Icons.keyboard_backspace,
                        color: black,
                        size: 25,
                      )),
                    )),
                Flexible(
                  fit: FlexFit.tight,
                  flex: 1,
                  child: new Text(
                    "Coins",
                    style: textStyle(true, 22, black),
                  ),
                ),
                addSpaceWidth(15),
              ],
            ),
          ),
//          addLine(1, black.withOpacity(.1), 0, 0, 0, 0),
          new Container(
            width: double.infinity,
            //height: 50,
//            color: blue6,
            padding: EdgeInsets.fromLTRB(15, 15, 20, 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Text(
                    "Available balance",
                    maxLines: 1,
                    style: textStyle(false, 15, black.withOpacity(.4)),
                  ),
                ),
                Image.asset(
                  ic_coin,
                  width: 20,
                  height: 20,
                  color: gold,
                ),
                addSpaceWidth(5),

                Text(
                  userModel.getInt(MCR).toString(),
                  style: textStyle(true, 15, gold),
                ),
                //addSpaceWidth(5),
              ],
            ),
          ),
          addLine(.5, black.withOpacity(.1), 0, 0, 0, 0),
          new Expanded(
            flex: 1,
            child: _loading
                ? loadingLayout()
                : _queryProductError != null
                    ? emptyLayout(
                        ic_coin,
                        _queryProductError,
                        "",
                      )
                    : !_isAvailable || _notFoundIds.isNotEmpty
                        ? Container()
                        : Container(
                            color: default_white,
                            child: Stack(
                              children: <Widget>[
                                Scrollbar(
                                  child: new ListView.builder(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.all(0),
                                    itemBuilder: (c, p) {
                                      ProductDetails productDetails =
                                          _products[p];
                                      String details =
                                          productDetails.description;
                                      var parts = details.split(" ");
                                      int coins = int.parse(parts[0]);
                                      bool selected = selectedCoins == coins;
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedCoins = coins;
                                            selectedPosition = p;
                                          });
                                        },
                                        child: Card(
                                          color: white,
                                          elevation: .5,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(25))),
                                          margin: EdgeInsets.fromLTRB(
                                              10, p == 0 ? 10 : 0, 10, 10),
                                          child: Container(
                                            height: 50,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                addSpaceWidth(10),
                                                new Container(
                                                  //padding: EdgeInsets.all(2),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: blue09,
                                                        border: Border.all(
                                                            color: black
                                                                .withOpacity(
                                                                    .1),
                                                            width: 1)),
                                                    child: Container(
                                                      width: 13,
                                                      height: 13,
                                                      margin: EdgeInsets.all(2),
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: selected
                                                            ? blue6
                                                            : transparent,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                addSpaceWidth(15),
                                                Image.asset(
                                                  ic_coin,
                                                  width: 20,
                                                  height: 20,
                                                  color: gold,
                                                ),
                                                //addSpaceWidth(5),
                                                Flexible(
                                                  fit: FlexFit.tight,
                                                  child: Text(
                                                    "$coins",
                                                    style: textStyle(
                                                        true, 15, gold),
                                                  ),
                                                ),
                                                addSpaceWidth(5),
                                                Text("${productDetails.price}",
                                                    style: textStyle(
                                                        true, 18, black)),
                                                addSpaceWidth(20),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    itemCount: _products.length,
                                  ),
                                ),
                                if (_purchasePending)
                                  Stack(
                                    children: [
                                      Opacity(
                                        opacity: 0.3,
                                        child: const ModalBarrier(
                                            dismissible: false,
                                            color: Colors.grey),
                                      ),
                                      Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ],
                                  ),
                              ],
                            )),
          ),
          //addSpace(20),
          addLine(.5, black.withOpacity(.1), 0, 0, 0, 0),
          Container(
            height: 40,
            margin: EdgeInsets.all(20),
            width: double.infinity,
            child: RaisedButton(
              onPressed: () async {
                if (selectedPosition == -1) {
                  toastInAndroid("Select an option");
                  return;
                }

                ProductDetails productDetails = _products[selectedPosition];
                PurchaseParam purchaseParam = PurchaseParam(
                    productDetails: productDetails,
                    applicationUserName: null,
                    sandboxTesting: true);

                _connection.buyConsumable(
                    purchaseParam: purchaseParam,
                    autoConsume: kAutoConsume || Platform.isIOS);
              },
              elevation: .5,
              color: red0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              child: Text(
                "BUY",
                style: textStyle(true, 14, white),
              ),
            ),
          ),
          Center(
            child: InkWell(
              onTap: () {
                String email = appSettingsModel.getString(SUPPORT_EMAIL);
                if (email.isEmpty) return;
                openLink(
                    "mailto:$email?subject=${"Coin Issues"}&body=${"Hi, i am issues with purchasing Coins"}");
              },
              child: Text(
                "Having payment issues? Email us",
                textAlign: TextAlign.center,
                style: textStyle(false, 14, blue0),
              ),
            ),
          ),
          addSpace(20)
        ],
      );
    });
  }

  Card _buildConnectionCheckTile() {
    if (_loading) {
      return Card(child: ListTile(title: const Text('Trying to connect...')));
    }
    final Widget storeHeader = ListTile(
      leading: Icon(_isAvailable ? Icons.check : Icons.block,
          color: _isAvailable ? Colors.green : ThemeData.light().errorColor),
      title: Text(
          'The store is ' + (_isAvailable ? 'available' : 'unavailable') + '.'),
    );
    final List<Widget> children = <Widget>[storeHeader];

    if (!_isAvailable) {
      children.addAll([
        Divider(),
        ListTile(
          title: Text('Not connected',
              style: TextStyle(color: ThemeData.light().errorColor)),
          subtitle: const Text(
              'Unable to connect to the payments processor. Has this app been configured correctly? See the example README for instructions.'),
        ),
      ]);
    }
    return Card(child: Column(children: children));
  }

  Card _buildProductList() {
    if (_loading) {
      return Card(
          child: (ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Fetching products...'))));
    }
    if (!_isAvailable) {
      return Card();
    }
    final ListTile productHeader = ListTile(title: Text('Products for Sale'));
    List<ListTile> productList = <ListTile>[];
    if (_notFoundIds.isNotEmpty) {
      productList.add(ListTile(
          title: Text('[${_notFoundIds.join(", ")}] not found',
              style: TextStyle(color: ThemeData.light().errorColor)),
          subtitle: Text(
              'This app needs special configuration to run. Please see example/README.md for instructions.')));
    }

    // This loading previous purchases code is just a demo. Please do not use this as it is.
    // In your app you should always verify the purchase data using the `verificationData` inside the [PurchaseDetails] object before trusting it.
    // We recommend that you use your own server to verity the purchase data.
    Map<String, PurchaseDetails> purchases =
        Map.fromEntries(_purchases.map((PurchaseDetails purchase) {
      if (purchase.pendingCompletePurchase) {
        InAppPurchaseConnection.instance.completePurchase(purchase);
      }
      return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
    }));
    productList.addAll(_products.map(
      (ProductDetails productDetails) {
        PurchaseDetails previousPurchase = purchases[productDetails.id];
        return ListTile(
            title: Text(
              productDetails.title,
            ),
            subtitle: Text(
              productDetails.description,
            ),
            trailing: previousPurchase != null
                ? Icon(Icons.check)
                : FlatButton(
                    child: Text(productDetails.price),
                    color: Colors.green[800],
                    textColor: Colors.white,
                    onPressed: () {
                      PurchaseParam purchaseParam = PurchaseParam(
                          productDetails: productDetails,
                          sandboxTesting: false);
                      /*if (productDetails.id == _kConsumableId) {
                        _connection.buyConsumable(
                            purchaseParam: purchaseParam,
                            autoConsume: kAutoConsume || Platform.isIOS);
                      } else {
                        _connection.buyNonConsumable(
                            purchaseParam: purchaseParam);
                      }*/
                      _connection.buyConsumable(
                          purchaseParam: purchaseParam,
                          autoConsume: kAutoConsume || Platform.isIOS);
                    },
                  ));
      },
    ));

    return Card(
        child:
            Column(children: <Widget>[productHeader, Divider()] + productList));
  }

  /*Card _buildConsumableBox() {
    if (_loading) {
      return Card(
          child: (ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Fetching consumables...'))));
    }
    if (!_isAvailable */ /*|| _notFoundIds.contains(_kConsumableId)*/ /*) {
      return Card();
    }
    final ListTile consumableHeader =
        ListTile(title: Text('Purchased consumables'));
//    final List<Widget> tokens = _consumables.map((String id) {
//      return GridTile(
//        child: IconButton(
//          icon: Icon(
//            Icons.stars,
//            size: 42.0,
//            color: Colors.orange,
//          ),
//          splashColor: Colors.yellowAccent,
//          onPressed: () => consume(id),
//        ),
//      );
//    }).toList();
    return Card(
        child: Column(children: <Widget>[
      consumableHeader,
      Divider(),
      GridView.count(
        crossAxisCount: 5,
        children: tokens,
        shrinkWrap: true,
        padding: EdgeInsets.all(16.0),
      )
    ]));
  }*/

  /*Future<void> consume(String id) async {
    await ConsumableStore.consume(id);
    final List<String> consumables = await ConsumableStore.load();
    setState(() {
      _consumables = consumables;
    });
  }*/

  void showPendingUI() {
    setState(() {
      _purchasePending = true;
    });
  }

  void deliverProduct(PurchaseDetails purchaseDetails) async {
    handleMobileCredits(
        getRandomId(), userModel.getObjectId(), selectedCoins, true,
        onAdded: () {
      setState(() {});
      showMessage(context, Icons.check, blue0, "Purchase successful",
          "You have been credited with ${selectedCoins} Coins",
          delayInMilli: 500);
    });
    print("xx Delivering Goods");
    setState(() {
      _purchasePending = false;
//      _consumables = consumables;
    });
  }

  void handleError(IAPError error) {
    setState(() {
      _purchasePending = false;
    });
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.
    return Future<bool>.value(true);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // handle invalid purchase here if  _verifyPurchase` failed.
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        print("xx Pending purchase");
        showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          handleError(purchaseDetails.error);
        } else if (purchaseDetails.status == PurchaseStatus.purchased) {
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            deliverProduct(purchaseDetails);
          } else {
            _handleInvalidPurchase(purchaseDetails);
            return;
          }
        }
        if (Platform.isAndroid) {
          if (!kAutoConsume /*&& purchaseDetails.productID == _kConsumableId*/) {
            print("xx Consuming");
            await InAppPurchaseConnection.instance
                .consumePurchase(purchaseDetails);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          print("xx PendingComplete");
          await InAppPurchaseConnection.instance
              .completePurchase(purchaseDetails);
        }
      }
    });
  }
}
