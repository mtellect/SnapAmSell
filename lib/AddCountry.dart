import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/assets.dart';

class AddCountry extends StatefulWidget {
  Map item;
  AddCountry({this.item});
  @override
  _AddCountryState createState() => _AddCountryState();
}

class _AddCountryState extends State<AddCountry> {
//  TextEditingController nameController = new TextEditingController();
  String countryName = "";
  TextEditingController currencyController = new TextEditingController();
  MoneyMaskedTextController currencyValueController =
      new MoneyMaskedTextController(
          initialValue: 0, decimalSeparator: ".", thousandSeparator: ",");
  String currencyLogo;

  int clickBack = 0;
  Map item;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    item = widget.item;
    if (item != null) {
      countryName = item[NAME];
      currencyController.text = item[CURRENCY];
      currencyLogo = item[CURRENCY_LOGO];
      double to1Dollar = item[VALUE_TO_ONE_DOLLAR];
      currencyValueController.updateValue(to1Dollar);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  BuildContext context;
  @override
  Widget build(BuildContext c) {
    context = c;
    return WillPopScope(
        onWillPop: () {
          int now = DateTime.now().millisecondsSinceEpoch;
          if ((now - clickBack) > 5000) {
            clickBack = now;
            showError("Click back again to exit");
            return;
          }
          Navigator.pop(context);
        },
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            key: _scaffoldKey,
            backgroundColor: white,
            body: page()));
  }

  BuildContext con;

  Builder page() {
    return Builder(builder: (context) {
      this.con = context;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          addSpace(40),
          new Container(
            width: double.infinity,
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
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
                Flexible(
                  fit: FlexFit.tight,
                  flex: 1,
                  child: new Text(
                    item != null ? "Update Country" : "Add Country",
                    style: textStyle(true, 20, black),
                  ),
                ),
                addSpaceWidth(10),
                FlatButton(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    color: dark_green0,
                    onPressed: () {
                      if (currencyLogo == null) {
                        showError("Select Icon");
                        return;
                      }
                      if (!currencyLogo.startsWith("http")) {
                        saveIcon();
                        return;
                      }
                      post();
                    },
                    child: Text(
                      item != null ? "UPDATE" : "ADD",
                      style: textStyle(true, 14, white),
                    )),
                addSpaceWidth(15)
              ],
            ),
          ),
          //addLine(1, black.withOpacity(.2), 0, 5, 0, 0),
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
          Expanded(
            flex: 1,
            child: Scrollbar(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(0),
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
//                            Text(
//                              "Icon",
//                              style: textStyle(true, 14, dark_green03),
//                            ),
                            addSpace(10),
                            InkWell(
                              onTap: () {
                                pickSingleImage();
                              },
                              child: Container(
                                padding: EdgeInsets.all(10),
                                width: double.infinity,
                                height: 100,
                                decoration: BoxDecoration(
                                    color: blue09,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: black.withOpacity(.1),
                                        width: .5)),
                                child: Center(
                                    child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    currencyLogo != null
                                        ? (currencyLogo.startsWith("http")
                                            ? CachedNetworkImage(
                                                imageUrl: currencyLogo,
                                                width: 30,
                                                height: 30,
                                              )
                                            : Image.file(
                                                File(currencyLogo),
                                                width: 30,
                                                height: 30,
                                              ))
                                        : Icon(
                                            Icons.image,
                                            color: black,
                                            size: 30,
                                          ),
                                    addSpace(10),
                                    Text(
                                      "Select Icon",
                                      textAlign: TextAlign.center,
                                      style: textStyle(
                                          false, 14, black.withOpacity(.5)),
                                    ),
                                  ],
                                )),
                              ),
                            ),
                            addSpace(10),
                            clickText(
                              "Country Name",
                              countryName,
                              () {
                                pickCountry(context, (c) {
                                  countryName = c.name;
                                  setState(() {});
                                });
                              },
                            ),
                            /*inputTextView("Country Name", nameController, isNum: false,
                              onEditted: (){
                              setState(() {});
                              },),*/
                            inputTextView(
                              "Currency",
                              currencyController,
                              isNum: false,
                              onEditted: () {
                                setState(() {});
                              },
                            ),
                            inputTextView(
                              "Currency to 1 dollar",
                              currencyValueController,
                              isNum: false,
                              onEditted: () {
                                setState(() {});
                              },
                            ),

                            addSpace(50),
                          ]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  void post() {
//    String name = nameController.text.trim();
    String currency = currencyController.text.toUpperCase().trim();
    double currencyValue = currencyValueController.numberValue;

    if (countryName.isEmpty) {
      showError("Enter country name");
      return;
    }
    if (currency.isEmpty) {
      showError("Enter currency");
      return;
    }
    if (currencyValue == 0) {
      showError("Enter currency value");
      return;
    }

    Map map = Map();
    map[NAME] = countryName;
    map[CURRENCY] = currency;
    map[CURRENCY_LOGO] = currencyLogo;
    map[VALUE_TO_ONE_DOLLAR] = currencyValue;

    List countryList = appSettingsModel.getList(COUNTRY_LIST);
    int index =
        countryList.indexWhere((element) => element[NAME] == countryName);
    if (index != -1) {
      countryList[index] = map;
    } else {
      countryList.add(map);
    }
    countryList.sort((m1, m2) => m1[NAME].compareTo(m2[NAME]));
    appSettingsModel.put(COUNTRY_LIST, countryList);
    appSettingsModel.updateItems();
    Navigator.pop(context, map);
  }

  saveIcon() {
    showProgress(true, context, msg: "Saving Icon");
    uploadFile(File(currencyLogo), (res, error) {
      showProgress(false, context);
      Future.delayed(Duration(milliseconds: 500), () {
        if (error != null) {
          snack("Error");
          return;
        }
        currencyLogo = res;
        setState(() {});
        post();
      });
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  snack(String text) {
    Future.delayed(Duration(milliseconds: 100), () {
      showSnack(
        _scaffoldKey,
        text,
      );
    });
  }

  pickSingleImage() async {
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: file.path,
        maxWidth: 2500,
        maxHeight: 2500,
        compressFormat: ImageCompressFormat.png);
    if (croppedFile != null) {
      currencyLogo = croppedFile.path;
      setState(() {});
    }
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
