import 'dart:io';

import 'package:Strokes/AppEngine.dart';
import 'package:Strokes/assets.dart';
import 'package:Strokes/payment_details.dart';
import 'package:flutter/material.dart';

import 'admin/StripeService.dart';
import 'basemodel.dart';

class PaymentDialog extends StatefulWidget {
  final bool isAds;
  final double amount;
  final int premiumPosition;
  final BaseModel adsModel;
  const PaymentDialog(
      {Key key,
      this.isAds = false,
      this.amount,
      this.premiumPosition,
      this.adsModel})
      : super(key: key);
  @override
  _PaymentDialogState createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  double amount;
  BaseModel package = appSettingsModel.getModel(FEATURES_PREMIUM);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    StripeService.init();
    amount = widget.amount;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: transparent,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              color: black.withOpacity(.4),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  )),
              //padding: EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      padding: EdgeInsets.all(15),
                      child: Text(
                        "Choose Payment Options",
                        style: textStyle(true, 13, black.withOpacity(0.6)),
                      )),
                  FlatButton(
                    onPressed: () {
                      pushReplacementAndResult(
                          context,
                          PaymentDetails(
                            amount: amount,
                            premiumIndex: widget.premiumPosition,
                            adsModel: widget.adsModel,
                            isAds: widget.isAds,
                          ),
                          depend: false);
                    },
                    padding: EdgeInsets.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/icons/stripe.png",
                          width: 60,
                          fit: BoxFit.fitWidth,
                        ),
                        addSpaceWidth(10),
                        Text("Pay With Card"),
                      ],
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      StripeService.payWithNative(
                          amount: "5000", currency: "USD");
                    },
                    padding: EdgeInsets.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/icons/${Platform.isIOS ? "apple_pay" : "google_pay"}.png",
                          //height: 20,
                          width: 60,
                          fit: BoxFit.fitWidth,
                        ),
                        addSpaceWidth(10),
                        Text(
                            "Pay With ${Platform.isIOS ? "Apple" : "Google"} Pay"),
                      ],
                    ),
                  ),
                  addSpace(20)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
