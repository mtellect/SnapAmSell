import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maugost_apps/AppConfig.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/PayoutMain.dart';
import 'package:maugost_apps/admin/ShowStripeTC.dart';
import 'package:maugost_apps/admin/StripeService.dart';
import 'package:maugost_apps/assets.dart';
import 'package:maugost_apps/basemodel.dart';
import 'package:maugost_apps/dialogs/OfferDialog.dart';

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
          children: [balanceItem(), payoutItem()],
        )),
      ],
    );
  }

  balanceItem() {
    final formatCurrency =
        new NumberFormat.currency(decimalDigits: 2, symbol: "\$");
    double balance = userModel.getDouble(ESCROW_BALANCE);
    double deposits = userModel.getDouble(ACCOUNT_DEPOSIT);
    double withdrawals = userModel.getDouble(ACCOUNT_WITHDRAWN);

    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(left: 8, right: 8),
          child: Row(
            children: [
              Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      //shape: BoxShape.circle,
                      color: orange0,
                      borderRadius: BorderRadius.circular(8)),
                  child: Icon(
                    Icons.account_balance_wallet,
                    color: white,
                    size: 15,
                  )),
              addSpaceWidth(10),
              Text(
                "Wallet Balance",
                style: textStyle(true, 14, black.withOpacity(.9)),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          margin: EdgeInsets.all(15),
          decoration: BoxDecoration(
              //borderRadius: BorderRadius.circular(5),
              //color: black.withOpacity(.05),
              border: Border(
            //top: BorderSide(width: 10, color: black.withOpacity(.5)),
            left: BorderSide(width: 10, color: black.withOpacity(.5)),
          )),
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
                            formatCurrency.format(deposits),
                            style: textStyle(true, 25, black),
                          ),
                          Text(
                            "Deposits",
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
                            formatCurrency.format(withdrawals),
                            style: textStyle(true, 25, black),
                          ),
                          Text(
                            "Withdrawals",
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
                    formatCurrency.format(balance),
                    style: textStyle(true, 40, green),
                  ),
                  Text(
                    "Account Balance",
                    style: textStyle(false, 12, black),
                  ),
                  addSpace(10),
                  Row(
                    children: [
                      Flexible(
                        child: FlatButton(
                          onPressed: () {
                            fundWallet(context, onProcessed: (b) {
                              setState(() {});
                            });
                          },
                          color: blue3,
                          //padding: EdgeInsets.all(20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(color: white.withOpacity(.3))),
                          child: Center(
                            child: Text(
                              "FUND",
                              style: textStyle(true, 14, white),
                            ),
                          ),
                        ),
                      ),
                      addSpaceWidth(10),
                      Flexible(
                        child: FlatButton(
                          onPressed: handleWithdraw,
                          color: green,
                          //padding: EdgeInsets.all(20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(color: white.withOpacity(.3))),
                          child: Center(
                            child: Text(
                              "WITHDRAW",
                              style: textStyle(true, 14, white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  payoutItem() {
    String customerId = userModel.getString(STRIPE_ACCOUNT_ID);
    String personId = userModel.getString(STRIPE_PERSON_ID);
    bool payoutReady = userModel.getBoolean(STRIPE_PAYMENT_READY);
    bool payoutTerms = userModel.getBoolean(STRIPE_TERMS_ACCEPTED);

    String accountName = userModel.getString(ACCOUNT_NAME);
    String accountNum = userModel.getString(ACCOUNT_NUMBER);
    String bankName = userModel.getString(BANK_NAME);

    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(left: 8, right: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          //shape: BoxShape.circle,
                          color: orange0,
                          borderRadius: BorderRadius.circular(8)),
                      child: Icon(
                        Icons.account_balance,
                        color: white,
                        size: 15,
                      )),
                  addSpaceWidth(10),
                  Text(
                    "Payout Information",
                    style: textStyle(true, 14, black.withOpacity(.9)),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: payoutReady ? green_dark : red03),
                padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    Text(
                      payoutReady ? "Ready" : "Needs Setup",
                      style: textStyle(false, 14, white),
                    ),
                    addSpaceWidth(5),
                    Icon(
                      payoutReady ? Icons.check : Icons.warning,
                      size: 15,
                      color: white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          margin: EdgeInsets.all(15),
          decoration: BoxDecoration(
              //borderRadius: BorderRadius.circular(5),
              //color: black.withOpacity(.05),
              border: Border(
            //top: BorderSide(width: 10, color: black.withOpacity(.5)),
            left: BorderSide(width: 10, color: black.withOpacity(.5)),
          )),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              addSpace(10),
              Text(
                payoutReady ? bankName : "Bank Name",
                style: textStyle(true, 18, black),
              ),
              Text(
                payoutReady ? accountName : "Account Name",
                style: textStyle(false, 14, black),
              ),
              Text(
                payoutReady ? accountNum : "Account Number",
                style: textStyle(false, 12, black),
              ),
              addSpace(10),
              FlatButton(
                onPressed: handlePayout,
                color: AppConfig.appColor,
                //padding: EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: white.withOpacity(.3))),
                child: Center(
                  child: Text(
                    payoutReady ? "EDIT" : "SETUP PAYOUT",
                    style: textStyle(true, 14, black),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  void handlePayout() async {
    String customerId = userModel.getString(STRIPE_ACCOUNT_ID);
    String personId = userModel.getString(STRIPE_PERSON_ID);
    bool payoutReady = userModel.getBoolean(STRIPE_PAYMENT_READY);
    bool payoutTerms = userModel.getBoolean(STRIPE_TERMS_ACCEPTED);

    if (!payoutReady && customerId.isEmpty) {
      showProgress(true, context, msg: "Preparing Connection...");
      StripeService.createStripeCustomer(onResponse: (resp) async {
        showProgress(false, context);
        print(resp.message);
        print(resp.body);
        if (!resp.success) {
          showMessage(context, Icons.error_outline, red, "Error", resp.message,
              delayInMilli: 800);
          return;
        }
        userModel
          ..put(STRIPE_ACCOUNT_ID, resp.body["id"])
          ..updateItems();
        Future.delayed(Duration(milliseconds: 800), () {
          pushAndResult(
            context,
            ShowStripeTC(),
          );
        });
      });
      return;
    }
    if (!payoutReady && customerId.isNotEmpty && !payoutTerms) {
      pushAndResult(
        context,
        ShowStripeTC(),
      );
      return;
    }

    pushAndResult(context, PayoutMain(), depend: false, result: (_) {
      setState(() {});
    });
  }

  void handleWithdraw() async {
    bool payoutReady = userModel.getBoolean(STRIPE_PAYMENT_READY);

    double accountBal = userModel.getDouble(ESCROW_BALANCE);

    if (!payoutReady) {
      showMessage(
          context,
          Icons.warning,
          red,
          "Payout SetUp",
          " Oops! You have not set up your bank"
              " account information that is "
              "needed for a withdrawal.",
          clickYesText: "Setup Payout", onClicked: (_) {
        if (_) handlePayout();
      });
      return;
    }

    if (accountBal == 0) {
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

    pushAndResult(context, AmountDialog(), depend: false,
        result: (double amount) {
      if (amount > accountBal) {
        showMessage(
            context,
            Icons.warning,
            red,
            "Payout SetUp",
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

      yesNoDialog(context, "Request Withdrawal?",
          "Are you sure you want to place a withdrawal request?", () {
        showProgress(true, context, msg: "Processing Request...");
        StripeService.createTransfer(
            amount: amount,
            onResponse: (resp) {
              showProgress(false, context);
              print(resp.message);
              print(resp.body);
              if (!resp.success) {
                showMessage(context, Icons.error_outline, red, "Request Error",
                    resp.message,
                    delayInMilli: 800);
                return;
              }
              BaseModel(items: resp.body)
                ..put(OBJECT_ID, resp.body['id'])
                ..saveItem(WITHDRAW_BASE, true, document: resp.body['id']);
              userModel
                ..put(ESCROW_BALANCE, accountBal - amount)
                ..updateItems();
              showMessage(context, Icons.check, green, "Request Received!",
                  "Your withdrawal request has been received and is been processed, We will keep you updated",
                  delayInMilli: 1200);
            });
      });
    });
  }
}
