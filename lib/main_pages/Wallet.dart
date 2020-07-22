import 'package:Strokes/AppEngine.dart';
import 'package:Strokes/WithdrawDialog.dart';
import 'package:Strokes/app_config.dart';
import 'package:Strokes/assets.dart';
import 'package:flutter/material.dart';

class Wallet extends StatefulWidget {
  @override
  _WalletState createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  int selectedMode = -1;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
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
                "Account",
                style: textStyle(true, 25, black),
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
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: black.withOpacity(.05),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          width: getScreenWidth(context) / 2,
                          padding: EdgeInsets.all(15),
                          //color: blue3,
                          child: Column(
                            children: [
                              Text(
                                "\$${userModel.getDouble(ACCOUNT_DEPOSIT)}",
                                style: textStyle(true, 25, black),
                              ),
                              Text(
                                "Deposit",
                                style: textStyle(false, 12, black),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          width: getScreenWidth(context) / 2,
                          //color: red,
                          padding: EdgeInsets.all(15),
                          child: Column(
                            children: [
                              Text(
                                "\$${userModel.getDouble(ACCOUNT_WITHDRAWN)}",
                                style: textStyle(true, 25, black),
                              ),
                              Text(
                                "Withdrawl",
                                style: textStyle(false, 12, black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  //addSpace(15),
                  addLine(.5, black.withOpacity(.2), 0, 5, 0, 5),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "\$${userModel.getDouble(ACCOUNT_BALANCE)}",
                        style: textStyle(true, 40, green),
                      ),
                      Text(
                        "Account Balance",
                        style: textStyle(false, 12, black),
                      ),
                      addSpace(10),
                      FlatButton(
                        onPressed: () {
                          if (userModel.getDouble(ACCOUNT_BALANCE) == 0) {
                            showMessage(
                                context,
                                Icons.warning,
                                red,
                                "Insufficent Funds",
                                "Sorry you have insufficant funds in your account to proceed with this transaction");
                            return;
                          }

                          if (selectedMode == -1) {
                            showMessage(
                                context,
                                Icons.warning,
                                red,
                                "Select Option",
                                "Please select a mode in which you would want your funds sent to you");
                            return;
                          }

                          pushAndResult(context, WithdrawDialog(),
                              result: (List _) {
                            showMessage(
                                context,
                                Icons.check,
                                green,
                                "Request Successful!",
                                "Your withdrawal was successful");
                          }, depend: false);
                        },
                        color: green,
                        //padding: EdgeInsets.all(20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(color: white.withOpacity(.3))),
                        child: Center(
                          child: Text(
                            "WITHDRAW",
                            style: textStyle(true, 14, black),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            Column(
              children: List.generate(2, (p) {
                bool active = selectedMode == p;
                bool payPal = p == 0;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedMode = p;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(15),
                    margin: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: black.withOpacity(.05),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (active)
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: blue3,
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check,
                                  size: 16,
                                  color: white,
                                ),
                                addSpaceWidth(5),
                                Text(
                                  "Active",
                                  style: textStyle(true, 13, white),
                                )
                              ],
                            ),
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p == 0
                                        ? userModel.getEmail()
                                        : "IRS Bank of Africa",
                                    style: textStyle(true, 18, black),
                                  ),
                                  Text(
                                    p == 0
                                        ? "PayPal Email Address"
                                        : "Banking Information",
                                    style: textStyle(false, 12, black),
                                  ),
                                ],
                              ),
                            ),
                            Image.asset(
                              "assets/icons/${payPal ? "paypal.jpg" : "bank.png"}",
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          ],
                        ),
                        FlatButton(
                          onPressed: () {},
                          color: AppConfig.appColor,
                          //padding: EdgeInsets.all(20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(color: white.withOpacity(.3))),
                          child: Center(
                            child: Text(
                              "EDIT ${payPal ? "PAYPAL" : "ACCOUNT"}",
                              style: textStyle(true, 14, black),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }),
            )
          ],
        )),
      ],
    );
  }

  textField(controller, hint, {int max, bool isNum = false}) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: black.withOpacity(.05))),
      child: TextField(
        controller: controller,
        maxLines: max,
        keyboardType: isNum ? TextInputType.number : null,
        decoration: InputDecoration(
            labelText: hint,
            labelStyle: textStyle(true, 12, black),
            border: InputBorder.none,
            fillColor: black.withOpacity(.05),
            filled: true),
      ),
    );
  }

  selectorField(value, hint, onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
            color: black.withOpacity(.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: black.withOpacity(.05))),
        child: Row(
          children: [
            Flexible(
              fit: FlexFit.tight,
              child: Text(
                value ?? hint,
                style: textStyle(
                    true, value == null ? 12 : 14, black.withOpacity(1)),
              ),
            ),
            Icon(Icons.search)
          ],
        ),
      ),
    );
  }
}
