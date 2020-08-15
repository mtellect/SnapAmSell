import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/AppConfig.dart';

import 'assets.dart';

class WithdrawDialog extends StatefulWidget {
  int quantity;
  WithdrawDialog({this.quantity = 1});
  @override
  _WithdrawDialogState createState() => _WithdrawDialogState();
}

class _WithdrawDialogState extends State<WithdrawDialog> {
  TextEditingController amountController = TextEditingController();
  TextEditingController quantityController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    quantityController.text = "${widget.quantity}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: transparent,
        body: Stack(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                  child: Container(
                    color: black.withOpacity(.7),
                  )),
            ),
            page()
          ],
        ));
  }

  page() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 40, 20, 20),
      child: Center(
        child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            color: white_color,
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /*Container(
                 width: double.infinity,
                 color: white,
                 padding: EdgeInsets.fromLTRB(20,10,20,10),
                 child:Center(child: Column(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     Text("Make Offer",style: textStyle(true, 12, white),),

                   ],
                 )),
               ),*/
                AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  width: double.infinity,
                  height: errorText.isEmpty ? 0 : 40,
                  color: red0,
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Center(
                      child: Text(
                    errorText,
                    style: textStyle(true, 16, white),
                  )),
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: Container(
                    color: default_white,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  flex: 2,
                                  child: inputTextView(
                                      "Amount to Withdraw", amountController,
                                      isNum: true, priceFormatted: () {
                                    setState(() {});
                                  }, priceIcon: Icons.monetization_on),
                                  fit: FlexFit.tight,
                                ),
//                                addSpaceWidth(10),
//                                Flexible(
//                                  fit: FlexFit.tight,
//                                  flex: 1,
//                                  child: inputTextView(
//                                      "Quantity", quantityController,
//                                      isNum: true, priceFormatted: () {
//                                    setState(() {});
//                                  }, priceIcon: Icons.shopping_cart),
//                                )
                              ],
                            ),

//                           addSpace(15),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 50,
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: FlatButton(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0)),
                      color: AppConfig.appColor,
                      onPressed: () {
                        String amountText = amountController.text.trim();
                        String quantity = quantityController.text.trim();

                        if (amountText.isEmpty) {
                          showError("Enter Amount");
                          return;
                        }
//                        if (quantity.isEmpty) {
//                          showError("Enter Quantity");
//                          return;
//                        }
                        Navigator.pop(context, [
                          double.parse(
                            amountText.replaceAll(",", ""),
                          ),
                          true
                        ]);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Request Amount",
                            style: textStyle(true, 16, black),
                          ),
                          addSpaceWidth(10),
                          Icon(
                            Icons.send,
                            color: black,
                            size: 15,
                          )
                        ],
                      )),
                ),
              ],
            )),
      ),
    );
  }

  String errorText = "";
  showError(String text) {
    errorText = text;
    setState(() {});
    Future.delayed(Duration(seconds: 1), () {
      errorText = "";
      setState(() {});
    });
  }
}
