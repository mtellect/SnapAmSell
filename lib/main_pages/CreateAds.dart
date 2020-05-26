import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Strokes/AppEngine.dart';
import 'package:Strokes/SearchPlace.dart';
import 'package:Strokes/app_config.dart';
import 'package:Strokes/assets.dart';
import 'package:Strokes/basemodel.dart';
import 'package:Strokes/date_picker/flutter_datetime_picker.dart';
import 'package:Strokes/payment_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

//BuildContext _frameContext;

class CreateAds extends StatefulWidget {
  @override
  _CreateAdsState createState() => _CreateAdsState();
}

class _CreateAdsState extends State<CreateAds> {
  final titleController = TextEditingController();
  final urlLinkController = TextEditingController();
  final priceController = TextEditingController();
  File adsImage;
  int startAt = 0;
  int endAt = 0;
  String startAtStr;
  String endAtStr;
  BaseModel locationModel;
  double localAdsCost;

  String yourPaying = "";
  int adsRunFor;

  String baseCurrency = appSettingsModel.getString(APP_CURRENCY);
  String baseCurrencyName = appSettingsModel.getString(APP_CURRENCY_NAME);
  String myCountry = userModel.getString(COUNTRY);
  double adsCostPerDay;
  double baseAdsCost;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    int myPlan = userModel.getInt(ACCOUNT_TYPE);
    String key = myPlan == 0 ? FEATURES_REGULAR : FEATURES_PREMIUM;
    BaseModel package = appSettingsModel.getModel(key);
    adsCostPerDay = package.getDouble(ADS_PRICE);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  "Create Ads",
                  style: textStyle(true, 25, black),
                ),
                Spacer()
              ],
            ),
          ),
          page(),
          Container(
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(TextSpan(children: [
                  TextSpan(
                      text: "Cost Per Day",
                      style: textStyle(true, 14, black.withOpacity(0.6))),
                  TextSpan(
                      text: " $baseCurrency $adsCostPerDay",
                      style: textStyle(true, 18, black)),
                ])),
                if (null != adsRunFor)
                  Text.rich(TextSpan(children: [
                    TextSpan(
                        text: "Your ads will run for ",
                        style: textStyle(true, 14, black.withOpacity(0.6))),
                    TextSpan(
                        text: " $adsRunFor day(s)",
                        style: textStyle(true, 18, black)),
                  ])),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(15),
            child: FlatButton(
              onPressed: () {
                validateFields();
              },
              padding: EdgeInsets.all(15),
              color: AppConfig.appColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: Center(
                  child: Text(
                "PAY $yourPaying",
                style: textStyle(true, 18, white),
              )),
            ),
          )
        ],
      ),
    );
  }

  //title, image, duration(start and end) ,generate price, payment button

  page() {
    return Flexible(
      child: ListView(
        padding: EdgeInsets.all(15),
        children: [
          GestureDetector(
            onTap: () {
              getSingleCroppedImage(context, onPicked: (_) {
                setState(() {
                  adsImage = File(_);
                });
              });
            },
            child: Container(
              height: 200,
              alignment: Alignment.center,
              child: Text(
                "Add Advert Image",
                style: textStyle(true, 20, black),
              ),
              decoration: BoxDecoration(
                  image: adsImage == null
                      ? null
                      : DecorationImage(
                          image: FileImage(adsImage), fit: BoxFit.cover),
                  color: black.withOpacity(0.09)),
            ),
          ),
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
                    "Note: You are adviced to use a protrait image for better and clearer ads display",
                    style: textStyle(false, 14, white),
                  ),
                ),
              ],
            ),
          ),
          textFieldBox(titleController, "Enter Title", (v) => null),
          textFieldBox(urlLinkController, "Enter Web Address", (v) => null),
          addSpace(10),
          FlatButton(
            onPressed: () {
              pushAndResult(context, SearchPlace(), result: (BaseModel res) {
                setState(() {
                  locationModel = res;
                });
              }, depend: false);
            },
            padding: EdgeInsets.all(15),
            color: black.withOpacity(0.3),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on,
                  color: white.withOpacity(.5),
                ),
                addSpaceWidth(5),
                Text(
                  locationModel == null
                      ? "Pick a Location"
                      : (locationModel.getString(PLACE_NAME)),
                  style: textStyle(true, 18, white),
                ),
              ],
            ),
          ),
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
                    "Select a Region/Country you would like your Ad to be displayed",
                    style: textStyle(false, 14, white),
                  ),
                ),
              ],
            ),
          ),
          addSpace(10),
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: black.withOpacity(0.05)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ads Time Frame",
                  style: textStyle(true, 14, black.withOpacity(.5)),
                ),
                addSpace(10),
                Row(
                  children: [
                    Flexible(
                      child: Column(
                        children: [
                          FlatButton(
                            onPressed: () {
                              FocusScope.of(context).requestFocus(FocusNode());
                              DatePicker.showDatePicker(context,
                                  showTitleActions: true,
                                  //minTime: DateTime(1930, 12, 31),
                                  minTime: DateTime.now(),
                                  //maxTime: DateTime.now(),
                                  onChanged: (date) {}, onConfirm: (date) {
                                setState(() {
                                  startAt = date.millisecondsSinceEpoch;
                                });
                                doConversion();
                              },
                                  currentTime: startAt == 0
                                      ? null
                                      : DateTime.fromMillisecondsSinceEpoch(
                                          startAt));
                            },
                            padding: EdgeInsets.all(15),
                            color: black.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: white.withOpacity(.5),
                                ),
                                addSpaceWidth(5),
                                Text(
                                  startAt == 0
                                      ? "Choose"
                                      : formatTimeChosen(startAt),
                                  style: textStyle(true, 18, white),
                                ),
                              ],
                            ),
                          ),
                          addSpace(10),
                          Text(
                            "Start Date",
                            style: textStyle(true, 12, black),
                          ),
                        ],
                      ),
                    ),
                    addSpaceWidth(10),
                    Flexible(
                      child: Column(
                        children: [
                          FlatButton(
                            onPressed: () {
                              FocusScope.of(context).requestFocus(FocusNode());

                              DatePicker.showDatePicker(context,
                                  showTitleActions: true,
                                  //minTime: DateTime(1930, 12, 31),
                                  minTime:
                                      DateTime.now().add(Duration(days: 1)),
                                  //maxTime: DateTime.now(),
                                  onChanged: (date) {}, onConfirm: (date) {
                                setState(() {
                                  endAt = date.millisecondsSinceEpoch;
                                });
                                doConversion();
                              },
                                  currentTime: endAt == 0
                                      ? null
                                      : DateTime.fromMillisecondsSinceEpoch(
                                          endAt));
                            },
                            padding: EdgeInsets.all(15),
                            color: black.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: white.withOpacity(.5),
                                ),
                                addSpaceWidth(5),
                                Text(
                                  endAt == 0
                                      ? "Choose"
                                      : formatTimeChosen(endAt),
                                  style: textStyle(true, 18, white),
                                ),
                              ],
                            ),
                          ),
                          addSpace(10),
                          Text(
                            "End Date",
                            style: textStyle(true, 12, black),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          addSpace(30),
        ],
      ),
    );
  }

  bool converted = false;

  doConversion() async {
    var result = await (Connectivity().checkConnectivity());
    if (result == ConnectivityResult.none) {
      snack("No internet connectivity");
      return;
    }

    if (0 == startAt || 0 == endAt) return;
    setState(() {
      converted = false;
      yourPaying = "";
      adsRunFor = null;
    });
    final apiKey = "c4539a5b787cd95c601c";
    String countryUrl = "https://restcountries.eu/rest/v2/name/$myCountry";
    var response = await http.get(countryUrl);
    final model = BaseModel(items: jsonDecode(response.body)[0]);
    final currency = model.getListModel("currencies");
    String code = currency[0].getString("code");
    String symbol = currency[0].getString("symbol");
    String conKey = "${baseCurrency}_$code";
    String conBaseUrl = "https://free.currconv.com/api/v7/convert";
    String conversionUrl = "$conBaseUrl?q=$conKey&compact=ultra&apiKey=$apiKey";
    var response2 = await http.get(conversionUrl);
    Map perUnitData = jsonDecode(response2.body);
    final perUnitValue = perUnitData[conKey];
    print("Data $perUnitValue");

    final startDT = DateTime.fromMillisecondsSinceEpoch(startAt);
    final endDT = DateTime.fromMillisecondsSinceEpoch(endAt);
    adsRunFor = endDT.difference(startDT).inDays;
    localAdsCost = (adsRunFor * adsCostPerDay * perUnitValue).roundToDouble();
    baseAdsCost = (adsRunFor * adsCostPerDay).roundToDouble();
    yourPaying = "($symbol $localAdsCost)";
    print("Ads Costs $localAdsCost");
    setState(() {
      converted = true;
    });
  }

  String formatTimeChosen(int time) {
    final date = DateTime.fromMillisecondsSinceEpoch(time);
    return new DateFormat("MMMM d y").format(date);
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
        decoration: InputDecoration(labelText: hint, counter: Container()),
        onChanged: setstate,
        keyboardType: number ? TextInputType.number : null,
      ),
    );
  }

  void validateFields() async {
    FocusScope.of(context).requestFocus(FocusNode());

    String title = titleController.text;
    String urlLink = urlLinkController.text;

//    pushAndResult(
//        context,
//        PaymentDialog(
//          isAds: true,
//          amount: baseAdsCost,
//        ),
//        depend: false,
//        result: (_) {});
//    return;

    var result = await (Connectivity().checkConnectivity());
    if (result == ConnectivityResult.none) {
      snack("No internet connectivity");
      return;
    }

    if (adsImage == null) {
      snack("Add Advert Image");
      return;
    }

    if (title.isEmpty) {
      snack("Add Title to Ads");
      return;
    }

//    if (urlLink.isEmpty) {
//      snack("Add WebAddress to Ads");
//      return;
//    }
//
//    if (!urlLink.startsWith("http")) {
//      snack("Web Address must start with http");
//      return;
//    }

    if (locationModel == null) {
      snack("Add Display Location to Ads");
      return;
    }

    if (startAt == 0) {
      snack("Add Starting Date to Ads");
      return;
    }

    if (endAt == 0) {
      snack("Add Ending Date to Ads");
      return;
    }

    //showProgress(true, context, msg: "Please wait");
    String id = getRandomId();
    BaseModel model = BaseModel();
    model.put(HAS_PAID, false);
    model.put(OBJECT_ID, id);
    model.put(ADS_IMAGE, adsImage.path);
    model.put(TITLE, title);
    model.put(ADS_URL, urlLink);
    model.put(ADS_START_DATE, startAt);
    model.put(ADS_END_DATE, endAt);
    model.put(STATUS, PENDING);
    model.put(COUNTRY, locationModel.getString(COUNTRY));
    model.put(LATITUDE, locationModel.getString(LATITUDE));
    model.put(LONGITUDE, locationModel.getString(LONGITUDE));
    model.put(ADS_EXPIRY, Jiffy().add(days: adsRunFor).millisecondsSinceEpoch);
    showProgress(false, context);
    //Future.delayed(Duration(milliseconds: 100), () {
    pushAndResult(
        context,
        PaymentDialog(
          isAds: true,
          amount: baseAdsCost,
          adsModel: model,
        ),
        depend: false,
        result: (_) {});
    //});
  }

  snack(String text) {
    Future.delayed(Duration(milliseconds: 500), () {
      showSnack(_scaffoldKey, text, useWife: true);
    });
  }
}
