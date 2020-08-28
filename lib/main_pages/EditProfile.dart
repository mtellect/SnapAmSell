import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:masked_controller/mask.dart';
import 'package:masked_controller/masked_controller.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/SearchPlace.dart';
import 'package:maugost_apps/app/app.dart';
import 'package:maugost_apps/assets.dart';
import 'package:maugost_apps/basemodel.dart';
import 'package:photo/photo.dart';

class EditProfile extends StatefulWidget {
  final bool modeEdit;

  const EditProfile({Key key, this.modeEdit = false}) : super(key: key);
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
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
    placeModel = userModel.getModel(DELIVERY_LOCATION);
    selectedAddress = placeModel.getString(PLACE_NAME);
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
                "${widget.modeEdit ? "Edit" : "Create"} Profile",
                style: textStyle(true, 25, black),
              ),
              Spacer(),
            ],
          ),
        ),
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
            child: ListView(
          padding: EdgeInsets.all(0),
          children: [
            GestureDetector(
              onTap: pickAssets,
              child: Container(
                margin: EdgeInsets.only(top: 10, bottom: 10),
                child: CachedNetworkImage(
                  height: 250,
                  width: double.infinity,
                  imageUrl: profilePhoto,
                  placeholder: (c, s) {
                    return Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        //shape: BoxShape.circle,

                        color: black.withOpacity(.05),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person,
                            size: 100,
                            color: black.withOpacity(.3),
                          ),
                          Text(
                            "Add Image",
                            style: textStyle(false, 16, black),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(
              //color: black.withOpacity(.05),
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.only(top: 10, bottom: 10),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Account Information",
                    style: textStyle(false, 16, black),
                  ),
                  addSpace(10),
                  Container(
                    decoration: BoxDecoration(
                        border: Border(
                      left: BorderSide(width: 10, color: black.withOpacity(.5)),
                    )),
                    padding: EdgeInsets.only(left: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        textField(
                          fullName,
                          "First Name",
                        ),
                        addSpace(10),
                        textField(number, "Mobile Number", isNum: true)
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              //color: black.withOpacity(.05),
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.only(top: 10, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Contact Information",
                    style: textStyle(false, 16, black),
                  ),
                  addSpace(10),
                  Container(
                    decoration: BoxDecoration(
                        border: Border(
                      left: BorderSide(width: 10, color: black.withOpacity(.5)),
                    )),
                    padding: EdgeInsets.only(left: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        selectorField(
                            selectedAddress.isEmpty ? null : selectedAddress,
                            "Search Address", () {
                          pushAndResult(context, SearchPlace(), result: (_) {
                            placeModel = _;
                            selectedAddress = placeModel.getString(PLACE_NAME);
                            setState(() {});
                          }, depend: false);
                        }),
                        addSpace(10),
                        textField(address, "Residential Address"),
                        addSpace(10),
                        textField(landMark, "LandMark Description", max: 4)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        )),
        Container(
          padding: EdgeInsets.all(15),
          child: FlatButton(
            onPressed: saveProfile,
            color: black,
            padding: EdgeInsets.all(20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            child: Center(
              child: Text(
                "SAVE",
                style: textStyle(true, 16, white),
              ),
            ),
          ),
        )
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
      showError("Add Profile Photo");
      return;
    }

    if (name.isEmpty) {
      showError("Add Full Name");
      return;
    }

    if (num.isEmpty) {
      showError("Add Mobile Number");
      return;
    }

    if (placeModel.items.isEmpty) {
      showError("Pick delivery location");
      return;
    }

    if (address.text.isEmpty) {
      showError("Add delivery address");
      return;
    }

    if (landM.isEmpty) {
      showError("Add delivery landMark");
      return;
    }

    userModel
      ..put(NAME, name)
      ..put(PHONE_NUMBER, num)
      ..put(DELIVERY_LOCATION, placeModel.items)
      ..put(ADDRESS, cAddress)
      ..put(LANDMARK, landM)
      ..put(SIGNUP_COMPLETED, true)
      ..updateItems();
    Future.delayed(Duration(milliseconds: 10), () {
      showError("Profile Updated!");
    });
  }

  void pickAssets() async {
    openGallery(context, singleMode: true, type: PickType.onlyImage,
        onPicked: (_) async {
      if (_ == null) return;
      String path = (_[0].file).path;
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
    });
  }

  String errorText = "";
  showError(String text, {bool wasLoading = false}) {
    if (wasLoading) showProgress(false, context);
    errorText = text;
    setState(() {});
    Future.delayed(Duration(seconds: 3), () {
      errorText = "";
      setState(() {});
    });
  }
}
