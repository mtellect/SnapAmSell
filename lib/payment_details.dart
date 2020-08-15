import 'dart:convert';

import 'package:awesome_card/awesome_card.dart' as card;
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:http/http.dart' as http;
import 'package:stripe_sdk/stripe_sdk.dart';
import 'package:stripe_sdk/stripe_sdk_ui.dart';

import 'AppConfig.dart';
import 'AppEngine.dart';
import 'admin/StripeService.dart';
import 'assets.dart';
import 'basemodel.dart';

class PaymentDetails extends StatefulWidget {
  final double amount;
  final bool isSubscription;
  const PaymentDetails({
    Key key,
    this.amount,
    this.isSubscription = false,
  }) : super(key: key);
  @override
  _PaymentDetailsState createState() => _PaymentDetailsState();
}

class _PaymentDetailsState extends State<PaymentDetails> {
  String cardNumber = "";
  String cardHolderName = "";
  String expiryDate = "";
  String cvv = "";
  bool showBack = false;
  FocusNode _focusNode;

  final nameController = TextEditingController();
  final cvvController = TextEditingController();

  final numberController =
      new MaskedTextController(mask: '0000 **** **** 0000');

  final expiryController =
      new MaskedTextController(mask: '00/00 **** **** 0000');

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String payText = "PAY";

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), () {
      StripeService.init();
    });
    _focusNode = new FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _focusNode.hasFocus ? showBack = true : showBack = false;
      });
    });
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //print(widget.amount);
    return Scaffold(
      key: _scaffoldKey,
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
                            Navigator.of(context).pop();
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
                          "Payment Details",
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
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  addSpace(40),
                  card.CreditCard(
                    cardNumber: cardNumber,
                    cardExpiry: expiryDate,
                    cardHolderName: cardHolderName,
                    cvv: cvv,
                    bankName: "",
                    showBackSide: showBack,
                    frontBackground: card.CardBackgrounds.black,
                    backBackground: card.CardBackgrounds.white,
                    showShadow: true,
                  ),
                  addSpace(30),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: black.withOpacity(0.04)),
                    child: Column(
                      children: <Widget>[
                        textFieldBox(nameController, "Card Holder", (v) {
                          setState(() {
                            cardHolderName = v;
                          });
                        }),
                        textFieldBox(numberController, "Card Number", (v) {
                          setState(() {
                            cardNumber = v;
                          });
                        }, number: true),
                        Row(
                          children: [
                            Flexible(
                              child:
                                  textFieldBox(expiryController, "Expire", (v) {
                                setState(() {
                                  expiryDate = v;
                                });
                              }, number: true),
                            ),
                            Flexible(
                              child: textFieldBox(cvvController, "CVV", (v) {
                                setState(() {
                                  cvv = v;
                                });
//                                StripeService.doConversion(widget.amount)
//                                    .then((value) {
//                                  payText =
//                                      "PAY " +
//                                      value.getString(AMOUNT_TO_PAY);
//                                  if (mounted) setState(() {});
//                                });
                              },
                                  focusNode: _focusNode,
                                  maxLength: 3,
                                  number: true),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  addSpace(30),
                  Container(
                    padding: EdgeInsets.only(left: 25, right: 25),
                    child: FlatButton(
                      onPressed: processTransaction,
                      padding: EdgeInsets.all(20),
                      color: AppConfig.appColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      child: Center(
                          child: Text(
                        payText,
                        style: textStyle(true, 18, white),
                      )),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  textFieldBox(
      TextEditingController controller, String hint, setstate(String v),
      {focusNode, int maxLength, bool number = false}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: TextFormField(
        focusNode: focusNode,
        maxLength: maxLength,
        //maxLengthEnforced: false,
        controller: controller,
        decoration: InputDecoration(hintText: hint, counter: Container()),
        onChanged: setstate,
        keyboardType: number ? TextInputType.number : null,
      ),
    );
  }

  processTransaction() async {
    var result = await (Connectivity().checkConnectivity());
    if (result == ConnectivityResult.none) {
      snack("No Internet Connectivity");
      return;
    }

    if (cardHolderName.isEmpty) {
      snack("Enter Your Card Name");
      return;
    }

    if (cardNumber.isEmpty) {
      snack("Enter Your Card Number");
      return;
    }

    if (expiryDate.isEmpty) {
      snack("Enter Your Card Expiry Date");
      return;
    }

    if (cvv.isEmpty) {
      snack("Enter Your Card CVV");
      return;
    }
    _focusNode.unfocus();
    handleStripePayment();
  }

  handleStripePayment() async {
    showProgress(true, context, msg: "Processing");
    int amount = widget.amount.toInt() * 100;
    String currency = appSettingsModel.getString(APP_CURRENCY);

    final card = StripeCard(
      number: cardNumber.replaceAll(" ", ""),
      cvc: cvv,
      expMonth: int.parse(expiryDate.split("/")[0]),
      expYear: int.parse(expiryDate.split("/")[1]),
    );

    Map<String, dynamic> body = {
      'amount': amount.toString(),
      'currency': currency,
      'payment_method_types[]': 'card'
    };

    http
        .post(StripeService.paymentApiUrl,
            body: body, headers: StripeService.headers)
        .then((resp) {
      Map<String, dynamic> paymentIntent = jsonDecode(resp.body);
      if (resp.statusCode == 400) {
        print(paymentIntent["error"]["message"]);
        onError(paymentIntent["error"]["message"]);
        return;
      }
      String clientSecret = paymentIntent['client_secret'];
      print(clientSecret);
      StripeApi.instance.createPaymentMethodFromCard(card)
          //StripePayment.createPaymentMethod(PaymentMethodRequest(card: creditCard))
          .then((value) {
        print("resp ${value}");
        String paymentMethodId = value["id"];
        Stripe.instance
            .confirmPayment(clientSecret, paymentMethodId: paymentMethodId)
            .then((value) {
          final liveMode = appSettingsModel.getBoolean(STRIPE_IS_LIVE);
          Duration howLong;
          if (liveMode) {
            howLong = Duration(days: 30);
          } else {
            howLong = Duration(minutes: 10);
          }
          int duration = DateTime.now().add(howLong).millisecondsSinceEpoch;
          print(
              "Sub-Expiring in ${DateTime.fromMillisecondsSinceEpoch(duration)}");

          String id = getRandomId();
          final model = BaseModel(items: value);
          model.put(OBJECT_ID, id);
          model.put(AMOUNT, amount / 100);
          model.put(TYPE, widget.isSubscription ? 1 : 0);
          model.saveItem(TRANSACTION_BASE, true, document: id, onComplete: () {
            if (widget.isSubscription) {
              userModel.put(SUBSCRIPTION_EXPIRY, duration);
              userModel.put(ACCOUNT_TYPE, 1);
            } else {
              userModel.put(ESCROW_BALANCE, accountBalance + (amount / 100));
            }
            userModel.updateItems();
            showProgress(false, context);
            showMessage(
                context,
                Icons.check,
                green,
                "Process Successful",
                widget.isSubscription
                    ? "Your account has been upgraded to a Premium User Account, Enjoy Unlimited Job Posting!"
                    : 'You have successfully added funds to your wallet!',
                delayInMilli: 1200, onClicked: (_) {
              if (_) Navigator.pop(context, model);
            });
          });

//
        }).catchError((e) {
          showProgress(false, context);
          showMessage(context, Icons.error, red0, "Opps Error1!", e.toString(),
              delayInMilli: 600);
        });
      }).catchError((e) {
        showProgress(false, context);
        showMessage(context, Icons.error, red0, "Opps Error2!", e.toString(),
            delayInMilli: 600);
      });
    }).catchError((e) {
      showProgress(false, context);
      showMessage(context, Icons.error, red0, "Opps Error3!", e.toString(),
          delayInMilli: 600);
    });
  }

  snack(String text) {
    Future.delayed(Duration(milliseconds: 500), () {
      showSnack(_scaffoldKey, text, useWife: true);
    });
  }

  onError(e) {
    showProgress(false, context);
    showMessage(context, Icons.error, red0, "Opps Error!", e.toString(),
        delayInMilli: 600);
  }
}

//class _PaymentDetailsState extends State<PaymentDetails> {
//  String cardNumber = "";
//  String cardHolderName = "";
//  String expiryDate = "";
//  String cvv = "";
//  bool showBack = false;
//  FocusNode _focusNode;
//
//  final nameController = TextEditingController();
//  final cvvController = TextEditingController();
//
//  final numberController =
//      new MaskedTextController(mask: '0000 **** **** 0000');
//
//  final expiryController =
//      new MaskedTextController(mask: '00/00 **** **** 0000');
//
//  final _scaffoldKey = GlobalKey<ScaffoldState>();
//
//  String payText = "PAY";
//
//  @override
//  void initState() {
//    super.initState();
//    StripeService.init();
////    StripeService.doConversion(widget.amount).then((value) {
////      payText = "PAY ${value.getString(AMOUNT_TO_PAY)}";
////      if (mounted) setState(() {});
////    });
//    payText = "PAY \$${widget.amount}";
//    _focusNode = new FocusNode();
//    _focusNode.addListener(() {
//      setState(() {
//        _focusNode.hasFocus ? showBack = true : showBack = false;
//      });
//    });
//  }
//
//  @override
//  void dispose() {
//    _focusNode.dispose();
//    super.dispose();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      key: _scaffoldKey,
//      backgroundColor: white,
//      body: Stack(
//        children: [
//          Container(
//            //padding: EdgeInsets.fromLTRB(0, 50, 0, 10),
//            alignment: Alignment.topCenter,
//            decoration: BoxDecoration(color: AppConfig.appColor),
//            height: 150,
//            child: Stack(
//              children: [
//                Align(
//                  alignment: Alignment.topCenter,
//                  child: Row(
//                    mainAxisAlignment: MainAxisAlignment.start,
//                    children: <Widget>[
//                      InkWell(
//                          onTap: () {
//                            Navigator.of(context).pop();
//                          },
//                          child: Container(
//                            width: 50,
//                            height: 30,
//                            child: Center(
//                                child: Icon(
//                              Icons.keyboard_backspace,
//                              color: black,
//                              size: 20,
//                            )),
//                          )),
//                      GestureDetector(
//                        onTap: () {},
//                        child: Center(
//                            child: Text(
//                          "Payment Details",
//                          //style: textStyle(true, 20, black)
//                          style: textStyle(true, 25, black),
//                        )),
//                      ),
//                      addSpaceWidth(10),
//                      Spacer(),
//                    ],
//                  ),
//                ),
//              ],
//            ),
//          ),
//          Container(
//            margin: EdgeInsets.only(top: 120),
//            decoration: BoxDecoration(
//                color: white,
//                borderRadius: BorderRadius.only(
//                    topRight: Radius.circular(20),
//                    topLeft: Radius.circular(20))),
//            child: SingleChildScrollView(
//              child: Column(
//                children: <Widget>[
//                  addSpace(40),
//                  card.CreditCard(
//                    cardNumber: cardNumber,
//                    cardExpiry: expiryDate,
//                    cardHolderName: cardHolderName,
//                    cvv: cvv,
//                    bankName: "",
//                    showBackSide: showBack,
//                    frontBackground: card.CardBackgrounds.black,
//                    backBackground: card.CardBackgrounds.white,
//                    showShadow: true,
//                  ),
//                  addSpace(30),
//                  Container(
//                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
//                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
//                    decoration: BoxDecoration(
//                        borderRadius: BorderRadius.circular(15),
//                        color: black.withOpacity(0.04)),
//                    child: Column(
//                      children: <Widget>[
//                        textFieldBox(nameController, "Card Holder", (v) {
//                          setState(() {
//                            cardHolderName = v;
//                          });
//                        }),
//                        textFieldBox(numberController, "Card Number", (v) {
//                          setState(() {
//                            cardNumber = v;
//                          });
//                        }, number: true),
//                        Row(
//                          children: [
//                            Flexible(
//                              child:
//                                  textFieldBox(expiryController, "Expire", (v) {
//                                setState(() {
//                                  expiryDate = v;
//                                });
//                              }, number: true),
//                            ),
//                            Flexible(
//                              child: textFieldBox(cvvController, "CVV", (v) {
//                                setState(() {
//                                  cvv = v;
//                                });
////                                StripeService.doConversion(widget.amount)
////                                    .then((value) {
////                                  payText =
////                                      "PAY " +
////                                      value.getString(AMOUNT_TO_PAY);
////                                  if (mounted) setState(() {});
////                                });
//                              },
//                                  focusNode: _focusNode,
//                                  maxLength: 3,
//                                  number: true),
//                            )
//                          ],
//                        ),
//                      ],
//                    ),
//                  ),
//                  addSpace(30),
//                  Container(
//                    padding: EdgeInsets.only(left: 25, right: 25),
//                    child: FlatButton(
//                      onPressed: processTransaction,
//                      padding: EdgeInsets.all(20),
//                      color: AppConfig.appColor,
//                      shape: RoundedRectangleBorder(
//                          borderRadius: BorderRadius.circular(25)),
//                      child: Center(
//                          child: Text(
//                        payText,
//                        style: textStyle(true, 18, white),
//                      )),
//                    ),
//                  )
//                ],
//              ),
//            ),
//          ),
//        ],
//      ),
//    );
//  }
//
//  textFieldBox(
//      TextEditingController controller, String hint, setstate(String v),
//      {focusNode, int maxLength, bool number = false}) {
//    return Container(
//      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
//      child: TextFormField(
//        focusNode: focusNode,
//        maxLength: maxLength,
//        //maxLengthEnforced: false,
//        controller: controller,
//        decoration: InputDecoration(hintText: hint, counter: Container()),
//        onChanged: setstate,
//        keyboardType: number ? TextInputType.number : null,
//      ),
//    );
//  }
//
//  processTransaction() async {
//    var result = await (Connectivity().checkConnectivity());
//    if (result == ConnectivityResult.none) {
//      snack("No Internet Connectivity");
//      return;
//    }
//
//    if (cardHolderName.isEmpty) {
//      snack("Enter Your Card Name");
//      return;
//    }
//
//    if (cardNumber.isEmpty) {
//      snack("Enter Your Card Number");
//      return;
//    }
//
//    if (expiryDate.isEmpty) {
//      snack("Enter Your Card Expiry Date");
//      return;
//    }
//
//    if (cvv.isEmpty) {
//      snack("Enter Your Card CVV");
//      return;
//    }
//
//    _focusNode.unfocus();
//    showProgress(true, context, msg: "Processing Payment");
//
////    final CreditCard creditCard = CreditCard(
////      number: '4000002760003184',
////      expMonth: 12,
////      expYear: 21,
////    );
//
//    final CreditCard creditCard = CreditCard(
//      number: cardNumber.replaceAll(" ", ""),
//      expMonth: int.parse(expiryDate.split("/")[0]),
//      expYear: int.parse(expiryDate.split("/")[1]),
//    );
//
//    int amount = widget.amount.toInt() * 100;
//
//    StripeService.payViaExistingCard(
//            card: creditCard,
//            amount: amount.toString(),
//            currency: appSettingsModel.getString(APP_CURRENCY))
//        .then((res) {
//      print(res.body);
//
//      String id = getRandomId();
//      final model = BaseModel(items: res.body);
//      model.put(OBJECT_ID, id);
//      model.put(AMOUNT, amount);
//      model.put(TYPE, widget.isSubscription ? 1 : 0);
//      model.saveItem(TRANSACTION_BASE, true, document: id, onComplete: () {
//        if (widget.isSubscription) {
//          int duration = Jiffy().add(months: 1).millisecondsSinceEpoch;
//          userModel
//            ..put(IS_PREMIUM, true)
//            ..put(AMOUNT, amount)
//            ..put(SUBSCRIPTION_EXPIRY, duration)
//            ..updateItems();
//        } else {
//          userModel
//            ..put(ESCROW_BALANCE, accountBalance + amount)
//            ..updateItems();
//        }
//        showProgress(false, context);
//        showMessage(
//            context,
//            Icons.check,
//            green,
//            "Process Successful",
//            widget.isSubscription
//                ? "Your account has been upgraded to a Premium User Account, Enjoy Unlimited Job Posting!"
//                : 'You have successfully added funds to your wallet!',
//            delayInMilli: 1200, onClicked: (_) {
//          if (_) Navigator.pop(context, model);
//        });
//      });
//    }).catchError(onError);
//  }
//
//  snack(String text) {
//    Future.delayed(Duration(milliseconds: 500), () {
//      showSnack(_scaffoldKey, text, useWife: true);
//    });
//  }
//
//  onError(e) {
//    showProgress(false, context);
//    showMessage(
//      context,
//      Icons.error,
//      red0,
//      "Opps Error!",
//      e.toString(),
//    );
//  }
//}
