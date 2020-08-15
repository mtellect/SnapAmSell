import 'package:flutter/material.dart';

import 'AppEngine.dart';
import 'MainAdmin.dart';
import 'app/navigation.dart';
import 'AppConfig.dart';
import 'assets.dart';
import 'basemodel.dart';
import 'payment_dialog.dart';

class PaymentSubscription extends StatefulWidget {
  final bool fromSignUp;
  final int premiumIndex;

  const PaymentSubscription(
      {Key key, this.fromSignUp = false, this.premiumIndex})
      : super(key: key);
  @override
  _PaymentSubscriptionState createState() => _PaymentSubscriptionState();
}

class _PaymentSubscriptionState extends State<PaymentSubscription> {
  PageController pc = PageController();
  int currentPage = 0;
  BaseModel package = appSettingsModel.getModel(FEATURES_PREMIUM);
  @override
  void initState() {
    super.initState();
    if (widget.fromSignUp) {
      pc = PageController(initialPage: widget.premiumIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.fromSignUp) {
          popUpUntil(context, MainAdmin());
        } else {
          return true;
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: white,
        body: Stack(
          children: [
            Container(
              //padding: EdgeInsets.fromLTRB(0, 50, 0, 10),
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(color: AppConfig.appColor),
              height: 150,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        InkWell(
                            onTap: () {
                              if (widget.fromSignUp) {
                                popUpUntil(context, MainAdmin());
                              } else {
                                Navigator.of(context).pop();
                              }
                            },
                            child: Container(
                              width: 50,
                              height: 30,
                              child: Center(
                                  child: Icon(
                                Icons.keyboard_backspace,
                                color: black,
                                size: 20,
                              )),
                            )),
                        GestureDetector(
                          onTap: () {},
                          child: Center(
                              child: Text(
                            "Subscriptions",
                            //style: textStyle(true, 20, black)
                            style: textStyle(true, 25, black),
                          )),
                        ),
                        addSpaceWidth(10),
                        Spacer(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 120),
              decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: Card(
                      color: black.withOpacity(0.2),
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(3, (p) {
                          String title = p == 0
                              ? "1 Month"
                              : p == 1 ? "6 Months" : "12 Months";
                          bool selected = p == currentPage;
                          return Flexible(
                            child: GestureDetector(
                              onTap: () {
                                pc.animateToPage(p,
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.ease);
                              },
                              child: Container(
                                  margin: EdgeInsets.all(4),
                                  height: 30,
                                  decoration: !selected
                                      ? null
                                      : BoxDecoration(
                                          color: selected ? white : transparent,
                                          borderRadius:
                                              BorderRadius.circular(25)),
                                  child: Center(
                                      child: Text(
                                    title,
                                    style: textStyle(
                                        true,
                                        16,
                                        selected
                                            ? black
                                            : (white.withOpacity(.7))),
                                    textAlign: TextAlign.center,
                                  ))),
                            ),
                            fit: FlexFit.tight,
                          );
                        }),
                      ),
                    ),
                  ),
                  //addSpace(30),
                  Flexible(
                    child: PageView.builder(
                        controller: pc,
                        onPageChanged: (p) {
                          setState(() {
                            currentPage = p;
                          });
                        },
                        itemCount: 3,
                        itemBuilder: (ctx, p) {
                          final fee =
                              package.getList(PREMIUM_FEES)[currentPage];
                          final features =
                              package.getString(FEATURES).split("&");

                          return SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                addSpace(20),
                                Center(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 20),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        border: Border.all(
                                            color: black.withOpacity(0.5))),
                                    child: Text.rich(TextSpan(children: [
                                      TextSpan(
                                          text: "$fee",
                                          style: textStyle(true, 50, black)),
                                      TextSpan(
                                          text: appSettingsModel
                                              .getString(APP_CURRENCY),
                                          style: textStyle(false, 20, black)),
                                    ])),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: red,
                                      borderRadius: BorderRadius.circular(8)),
                                  padding: EdgeInsets.all(10),
                                  margin: EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info,
                                        color: white,
                                      ),
                                      addSpaceWidth(10),
                                      Flexible(
                                        child: Text(
                                          "Note: The Price would be converted to your country's currency at checkout",
                                          style: textStyle(false, 14, white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    "Features",
                                    style: textStyle(true, 23, black),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 15),
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children:
                                          List.generate(features.length, (p) {
                                        return Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 5),
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: black
                                                          .withOpacity(.05)))),
                                          child: Row(
                                            children: [
                                              Container(
                                                height: 30,
                                                width: 30,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                    color: green,
                                                    shape: BoxShape.circle),
                                                child: Icon(
                                                  Icons.check,
                                                  color: white,
                                                ),
                                              ),
                                              addSpaceWidth(20),
                                              Flexible(
                                                child: Text(features[p],
                                                    style: textStyle(
                                                      false,
                                                      18,
                                                      black.withOpacity(0.6),
                                                    )),
                                              )
                                            ],
                                          ),
                                        );
                                      })),
                                ),
                                Container(
                                  padding: EdgeInsets.only(left: 25, right: 25),
                                  child: FlatButton(
                                    onPressed: () {
                                      pushAndResult(
                                        context,
                                        PaymentDialog(
                                          premiumPosition: p,
                                          amount: double.parse(fee),
                                        ),
                                        depend: false,
                                      );
                                    },
                                    padding: EdgeInsets.all(20),
                                    color: AppConfig.appColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(25)),
                                    child: Center(
                                        child: Text(
                                      "SUBSCRIBE",
                                      style: textStyle(true, 18, white),
                                    )),
                                  ),
                                )
                              ],
                            ),
                          );
                        }),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
