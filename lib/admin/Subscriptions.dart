import 'package:Strokes/AppEngine.dart';
import 'package:Strokes/app_config.dart';
import 'package:Strokes/assets.dart';
import 'package:Strokes/basemodel.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Subscriptions extends StatefulWidget {
  final int type;

  const Subscriptions({Key key, this.type}) : super(key: key);
  @override
  _SubscriptionsState createState() => _SubscriptionsState();
}

class _SubscriptionsState extends State<Subscriptions> {
  final adsSpacingController = TextEditingController();
  final adsPriceController = TextEditingController();
  final superLikesController = TextEditingController();
  final swipesController = TextEditingController();
  final month1Controller = TextEditingController();
  final month6Controller = TextEditingController();
  final month12Controller = TextEditingController();
  final featuresController = TextEditingController();

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String get key {
    String key = widget.type == 0 ? FEATURES_REGULAR : FEATURES_PREMIUM;
    return key;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    BaseModel model = appSettingsModel.getModel(key);
    adsSpacingController.text = model.getInt(ADS_SPACING).toString();
    adsPriceController.text = model.getDouble(ADS_PRICE).toString();
    superLikesController.text = model.getInt(SUPER_LIKES_COUNT).toString();
    swipesController.text = model.getInt(SWIPE_COUNT).toString();
    if (widget.type == 1) {
      month1Controller.text = model.getList(PREMIUM_FEES)[0].toString();
      month6Controller.text = model.getList(PREMIUM_FEES)[1].toString();
      month12Controller.text = model.getList(PREMIUM_FEES)[2].toString();
    }

    featuresController.text = model.getString(FEATURES);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: white,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(0, 40, 0, 10),
            color: white,
            child: Row(
              children: <Widget>[
                InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
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
                Text(
                  "Subscription ${widget.type == 0 ? "Regular" : "Premium"}",
                  style: textStyle(true, 25, black),
                ),
                Spacer()
              ],
            ),
          ),
          page()
        ],
      ),
    );
  }

  page() {
    return Flexible(
      child: ListView(
        padding: EdgeInsets.all(15),
        children: [
          addSpace(10),
          textFieldBox(adsSpacingController, "Ads Spacing", (v) => null,
              number: true),
          textFieldBox(adsPriceController, "Ads Price/Day", (v) => null,
              number: true),
          textFieldBox(superLikesController, "Super Likes/Day", (v) => null,
              number: true),
          textFieldBox(swipesController, "Swipes/Day", (v) => null,
              number: true),
          if (widget.type == 1) ...[
            textFieldBox(month1Controller, "1 Month Cost", (v) => null,
                number: true),
            textFieldBox(month6Controller, "6 Months Cost", (v) => null,
                number: true),
            textFieldBox(month12Controller, "12 Months Cost", (v) => null,
                number: true),
            textFieldBox(featuresController, "Premium Features", (v) => null,
                maxLines: 5),
          ],
          addSpace(10),
          Container(
            decoration: BoxDecoration(
                color: red, borderRadius: BorderRadius.circular(8)),
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Icon(
                  Icons.info,
                  color: white,
                ),
                addSpaceWidth(10),
                Flexible(
                  child: Text(
                    "Note: Please for every new feature you'd want to add to this subscription seperate by '&'",
                    style: textStyle(false, 14, white),
                  ),
                ),
              ],
            ),
          ),
          addSpace(30),
          Container(
            //padding: EdgeInsets.only(left: 25, right: 25),
            child: FlatButton(
              onPressed: validateFields,
              padding: EdgeInsets.all(20),
              color: AppConfig.appColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: Center(
                  child: Text(
                "SAVE",
                style: textStyle(true, 18, white),
              )),
            ),
          ),
          addSpace(50),
        ],
      ),
    );
  }

  String formatTimeChosen(int time) {
    final date = DateTime.fromMillisecondsSinceEpoch(time);
    return new DateFormat("MMMM d y").format(date);
  }

  textFieldBox(
      TextEditingController controller, String hint, setstate(String v),
      {focusNode, int maxLength, int maxLines, bool number = false}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: TextFormField(
        focusNode: focusNode,
        maxLength: maxLength,
        maxLines: maxLines,
        //maxLengthEnforced: false,
        controller: controller,
        decoration: InputDecoration(
            fillColor: black.withOpacity(.05),
            filled: true,
            labelText: hint,
            counter: Container(),
            border: InputBorder.none),
        onChanged: setstate,
        keyboardType: number ? TextInputType.number : null,
      ),
    );
  }

  validateFields() async {
    String adsSpacing = adsSpacingController.text;
    String adsPrice = adsPriceController.text;
    String superLikes = superLikesController.text;
    String swipesCount = swipesController.text;
    String month1 = month1Controller.text;
    String month6 = month6Controller.text;
    String month12 = month12Controller.text;
    String features = featuresController.text;
    bool premium = widget.type != 0;

    var result = await (Connectivity().checkConnectivity());
    if (result == ConnectivityResult.none) {
      snack("No internet connectivity");
      return;
    }

    if (adsSpacing.isEmpty) {
      snack("Enter Ads Spacing");
      return;
    }

    if (adsPrice.isEmpty) {
      snack("Enter Ads Price/Day");
      return;
    }
    if (superLikes.isEmpty) {
      snack("Enter SuperLikes Count/Day");
      return;
    }

    if (swipesCount.isEmpty) {
      snack("Enter Swipes Count/Day");
      return;
    }

    if (premium && month1.isEmpty) {
      snack("Enter Cost for a month");
      return;
    }

    if (premium && month6.isEmpty) {
      snack("Enter Cost for 6 months");
      return;
    }

    if (premium && month12.isEmpty) {
      snack("Enter Cost for 12 Months");
      return;
    }

    if (premium && features.isEmpty) {
      snack("Enter Subscription Features");
      return;
    }

    BaseModel model = BaseModel();
    model..put(ADS_SPACING, int.parse(adsSpacing));
    model..put(ADS_PRICE, double.parse(adsPrice));
    model..put(SUPER_LIKES_COUNT, int.parse(superLikes));
    model..put(SWIPE_COUNT, int.parse(swipesCount));
    model..put(PREMIUM_FEES, [month1, month6, month12]);
    model..put(FEATURES, features);

    appSettingsModel
      ..put(key, model.items)
      ..updateItems();
    snack("Subscription Saved!");
  }

  snack(String text) {
    Future.delayed(Duration(milliseconds: 500), () {
      showSnack(_scaffoldKey, text, useWife: true);
    });
  }
}
