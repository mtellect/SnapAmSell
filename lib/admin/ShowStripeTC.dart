import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/PayoutMain.dart';
import 'package:maugost_apps/admin/StripeService.dart';
import 'package:maugost_apps/assets.dart';

class ShowStripeTC extends StatefulWidget {
  @override
  _ShowStripeTCState createState() => _ShowStripeTCState();
}

class _ShowStripeTCState extends State<ShowStripeTC> {
  @override
  initState() {
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
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
                color: black,
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
              Text(
                "Payout Agreement",
                style: textStyle(true, 25, black),
              ),
              Spacer(),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: red, borderRadius: BorderRadius.circular(8)),
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
                          "Note: The data provided during the process"
                          " will undergo a verification by Stripe"
                          " support team before being approved. Please ensure the"
                          " information you provide are accurate.",
                          style: textStyle(false, 14, white),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: Text.rich(TextSpan(children: [
                    TextSpan(
                        text:
                            "Payment processing services for users(“Seekers” and “Doers”)"
                            " on Ponos{Operated by Elek Applications, LLC} are "
                            "provided by Stripe and are subject to the Stripe"
                            " Connected Account Agreement, which includes the ",
                        style: textStyle(false, 20, black)),
                    TextSpan(
                        text: "Stripe Terms of Service",
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => openLink(
                              "https://stripe.com/connect-account/legal"),
                        style: textStyle(true, 20, blue3, underlined: true)),
                    TextSpan(
                        text:
                            " (collectively, the “Stripe Services Agreement”)."
                            " By agreeing to [this agreement / these terms / etc.] "
                            "or continuing to operate as a user on Ponos, "
                            "you agree to be bound by the Stripe Services Agreement,"
                            " as the same may be modified by Stripe from time "
                            "to time. As a condition of Ponos enabling payment "
                            "processing services through Stripe, you agree "
                            "to provide Ponos accurate and complete information"
                            " about yourself, and you authorize Ponos to share "
                            "it and transaction information related to your use "
                            "of the payment processing services provided by "
                            "Stripe. To learn more about how Stripe handles "
                            "personal information and data, please visit the"
                            " Stripe Services Agreement."
                            " To learn more about how Elek Applications "
                            "LLC manages and handles personal information "
                            "and data within the Ponos mobile application, "
                            "please visit the Ponos ",
                        style: textStyle(false, 20, black)),
                    TextSpan(
                        text: "Privacy Policy ",
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => openLink(
                              appSettingsModel.getString(PRIVACY_LINK)),
                        style: textStyle(true, 20, blue3, underlined: true)),
                    TextSpan(
                        text: "and ",
                        style: textStyle(
                          false,
                          20,
                          black,
                        )),
                    TextSpan(
                        text: "Terms of Service.",
                        recognizer: TapGestureRecognizer()
                          ..onTap = () =>
                              openLink(appSettingsModel.getString(TERMS_LINK)),
                        style: textStyle(true, 20, blue3, underlined: true)),
                  ])),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Flexible(
                child: FlatButton(
                  onPressed: () {
                    showProgress(true, context, msg: "Please wait...");
                    StripeService.updateStripeAcceptance(onResponse: (resp) {
                      showProgress(false, context);
                      print(resp.message);
                      print(resp.body);
                      if (!resp.success) {
                        showMessage(context, Icons.error_outline, red, "Error",
                            resp.message,
                            delayInMilli: 800);
                        return;
                      }

                      userModel
                        ..put(STRIPE_TERMS_ACCEPTED, true)
                        ..updateItems();
                      Future.delayed(Duration(milliseconds: 800), () {
                        pushReplacementAndResult(
                          context,
                          PayoutMain(),
                          depend: false,
                        );
                      });
                    });
                  },
                  color: green_dark,
                  padding: EdgeInsets.all(14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  child: Center(
                      child: Text(
                    "I AGREE",
                    style: textStyle(true, 16, white),
                  )),
                ),
              ),
              addSpaceWidth(10),
              Flexible(
                child: FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  color: red,
                  padding: EdgeInsets.all(14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  child: Center(
                      child: Text(
                    "I DISAGREE",
                    style: textStyle(true, 16, white),
                  )),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
