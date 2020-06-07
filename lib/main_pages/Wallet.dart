import 'dart:io';

import 'package:Strokes/AppEngine.dart';
import 'package:Strokes/app_config.dart';
import 'package:Strokes/assets.dart';
import 'package:Strokes/basemodel.dart';
import 'package:flutter/material.dart';
import 'package:masked_controller/mask.dart';
import 'package:masked_controller/masked_controller.dart';
import 'package:photo/photo.dart';

class Wallet extends StatefulWidget {
  @override
  _WalletState createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  final fullName = TextEditingController();
  //final number = TextEditingController();
  final number = MaskedController(mask: Mask(mask: 'NNN-NNN-NNNNN'));

  final phoneNumber = TextEditingController();
  final address = TextEditingController();
  final landMark = TextEditingController();
  String selectedAddress;
//  double addressLat = 0.0;
//  double addressLong = 0.0;
  String profilePhoto = "";
  BaseModel placeModel;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fullName.text = userModel.getString(NAME);
    number.text = userModel.getString(PHONE_NUMBER);
    address.text = userModel.getString(ADDRESS);
    landMark.text = userModel.getString(LANDMARK);
    placeModel = userModel.getModel(MY_LOCATION);
    profilePhoto = userModel.userImage;
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
                "Account Details",
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
                                "\$29",
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
                                "\$50",
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
                        "\$229",
                        style: textStyle(true, 40, green),
                      ),
                      Text(
                        "Account Balance",
                        style: textStyle(false, 12, black),
                      ),
                      addSpace(10),
                      FlatButton(
                        onPressed: () {},
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

  saveProfile() {
    String name = fullName.text;
    String num = number.text;
    String cAddress = address.text;
    String landM = landMark.text;

    if (profilePhoto.isEmpty) {
      snack("Add Profile Photo");
      return;
    }

    if (name.isEmpty) {
      snack("Add Full Name");
      return;
    }

    if (num.isEmpty) {
      snack("Add Mobile Number");
      return;
    }

    if (placeModel.items.isEmpty) {
      snack("Pick delivery location");
      return;
    }

    if (address.text.isEmpty) {
      snack("Add delivery address");
      return;
    }

    if (landM.isEmpty) {
      snack("Add delivery landMark");
      return;
    }

    userModel
      ..put(NAME, name)
      ..put(PHONE_NUMBER, num)
      ..put(MY_LOCATION, placeModel.items)
      ..put(ADDRESS, cAddress)
      ..put(LANDMARK, landM)
      ..put(SIGNUP_COMPLETED, true)
      ..updateItems();
    Future.delayed(Duration(milliseconds: 10), () {
      snack("Profile Updated!");
    });
  }

  snack(String text) {
    Future.delayed(Duration(milliseconds: 500), () {
      showSnack(scaffoldKey, text, useWife: true);
    });
  }

  void pickAssets() async {
    PhotoPicker.pickAsset(
            maxSelected: 1,
            thumbSize: 250,
            context: context,
            provider: I18nProvider.english,
            pickType: PickType.onlyImage,
            themeColor: AppConfig.appColor,
            rowCount: 3)
        .then((value) async {
      if (value == null) return;
      String path = (await value[0].originFile).path;
      uploadFile(File(path), (res, e) {
        if (null != e) {
          return;
        }
        profilePhoto = res;
        userModel
          ..put(USER_IMAGE, res)
          ..updateItems();
        setState(() {});
      });
    }).catchError((e) {});

    /// Use assetList to do something.
  }
}
