import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:masked_controller/mask.dart';
import 'package:masked_controller/masked_controller.dart';
import 'package:maugost_apps/AddContact.dart';
import 'package:maugost_apps/AppConfig.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/SearchPlace.dart';
import 'package:maugost_apps/app/app.dart';
import 'package:maugost_apps/assets.dart';
import 'package:maugost_apps/basemodel.dart';
import 'package:maugost_apps/dialogs/listDialog.dart';
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
  List contacts = [];

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
    contacts = userModel.getList(CONTACTS);
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
                "My Profile",
                style: textStyle(true, 20, black),
              ),
              Spacer(),
              RaisedButton(
                color: AppConfig.appColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                child: Text(
                  widget.modeEdit ? "UPDATE" : "CREATE",
                  style: textStyle(true, 16, black),
                ),
                onPressed: saveProfile,
              )
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
            child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: pickAssets,
                child: Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10),
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            width: 4, color: AppConfig.appColor_dark)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(75),
                      child: CachedNetworkImage(
                        height: 150,
                        width: 150,
                        imageUrl: profilePhoto,
                        fit: BoxFit.cover,
                        placeholder: (c, s) {
                          return Container(
                            height: 150,
                            width: 150,
                            decoration: BoxDecoration(
                              color: black.withOpacity(.04),
                            ),
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: black.withOpacity(.3),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.person_outline_outlined,
                        ),
                        addSpaceWidth(10),
                        Flexible(
                          fit: FlexFit.tight,
                          child: Text(
                            "Account Information",
                            style: textStyle(true, 22, black),
                          ),
                        ),
                      ],
                    ),
                    addSpace(20),
                    inputTextView(
                      "First Name",
                      fullName,
                      isNum: false,
                    ),
                    addSpace(10),
                    inputTextView(
                      "Mobile Number",
                      number,
                      isNum: true,
                    ),
                    addSpace(10),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.location_city_outlined,
                        ),
                        addSpaceWidth(10),
                        Flexible(
                          fit: FlexFit.tight,
                          child: Text(
                            "Delivery Information",
                            style: textStyle(true, 22, black),
                          ),
                        ),
                      ],
                    ),
                    addSpace(20),
                    clickText("Search Address", selectedAddress, () {
                      pushAndResult(context, SearchPlace(), result: (_) {
                        placeModel = _;
                        selectedAddress = placeModel.getString(PLACE_NAME);
                        setState(() {});
                      }, depend: false);
                    }),
                    addSpace(10),
                    inputTextView(
                      "Residential Address",
                      address,
                      isNum: false,
                    ),
                    addSpace(10),
                    inputTextView("LandMark Description", landMark,
                        isNum: false, maxLine: 4),
                    addSpace(20),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.contact_page_outlined,
                        ),
                        addSpaceWidth(10),
                        Flexible(
                          fit: FlexFit.tight,
                          child: Text(
                            "Contact Information",
                            style: textStyle(true, 22, black),
                          ),
                        ),
                      ],
                    ),
                    addSpace(10),
                    if (contacts.isNotEmpty)
                      Column(
                        children: List.generate(contacts.length, (p) {
                          Map item = contacts[p];
                          String name = item[NAME];
                          String phone = item[PHONE_NUMBER];
                          String phonePref = item[PHONE_PREF];
                          String email = item[EMAIL];
                          String whatapp = item[WHATSAPP_NUMBER];
                          String whatPref = item[WHATSAPP_PREF];
                          return GestureDetector(
                            onTap: () {
                              pushAndResult(
                                  context, listDialog(["Edit", "Delete"]),
                                  result: (_) {});
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: blue09,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5),
                                ),
//                                        border: Border.all(
//                                        color: black.withOpacity(.1),
//                                            width: .5
//                                    ),
//                                        color: blue09
                              ),
                              margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: <Widget>[
                                  addSpaceWidth(5),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: textStyle(false, 20, black),
                                        ),
                                        addSpace(5),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.phone,
                                              color: black.withOpacity(.5),
                                              size: 12,
                                            ),
                                            addSpaceWidth(5),
                                            Text(
                                              createPhoneNumer(
                                                  phonePref, phone),
                                              style:
                                                  textStyle(false, 14, black),
                                            ),
                                          ],
                                        ),
                                        if (whatapp.isNotEmpty) addSpace(5),
                                        if (whatapp.isNotEmpty)
                                          Row(
                                            children: [
                                              Image.asset(
                                                ic_whatsapp,
                                                color: black.withOpacity(.5),
                                                width: 12,
                                                height: 12,
                                              ),
                                              addSpaceWidth(5),
                                              Text(
                                                createPhoneNumer(
                                                    whatPref, whatapp),
                                                style:
                                                    textStyle(false, 14, black),
                                              ),
                                            ],
                                          ),
                                        if (email.isNotEmpty) addSpace(5),
                                        if (email.isNotEmpty)
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.email,
                                                color: black.withOpacity(.5),
                                                size: 12,
                                              ),
                                              addSpaceWidth(5),
                                              Text(
                                                email,
                                                style:
                                                    textStyle(false, 14, black),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                    flex: 1,
                                    fit: FlexFit.tight,
                                  ),
                                  addSpaceWidth(10),
                                  Container(
                                    width: 30,
                                    height: 30,
                                    child: FlatButton(
                                      onPressed: () {
                                        pushAndResult(
                                            context,
                                            AddContact(
                                              item: item,
                                            ), result: (_) {
                                          contacts[p] = _;
                                          setState(() {});
                                        });
                                      },
                                      color: black.withOpacity(.4),
                                      shape: CircleBorder(),
                                      padding: EdgeInsets.all(0),
                                      child: Icon(
                                        Icons.edit,
                                        color: white,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                  addSpaceWidth(10),
                                  Container(
                                    width: 30,
                                    height: 30,
                                    child: FlatButton(
                                      onPressed: () {
                                        contacts.removeAt(p);
                                        setState(() {});
                                      },
                                      color: red0,
                                      shape: CircleBorder(),
                                      padding: EdgeInsets.all(0),
                                      child: Icon(
                                        Icons.close,
                                        color: white,
                                      ),
                                    ),
                                  ),
                                  addSpaceWidth(10),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    if (contacts.length < 3)
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: FlatButton(
                          onPressed: () {
                            pushAndResult(context, AddContact(), result: (_) {
                              contacts.add(_);
                              setState(() {});
                            });
                          },
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add, size: 25, color: orange0),
                                addSpaceWidth(5),
                                Text(
                                  "Add Contact",
                                  style: textStyle(true, 18, orange0),
                                ),
                                addSpaceWidth(5),
                              ],
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25)),
                              side: BorderSide(color: orange0, width: 2)),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
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
      ..put(CONTACTS, contacts)
      ..updateItems();
    showMessage(context, Icons.check, green_dark, "Updated",
        "Profile Successfully Updated!");
  }

  void pickAssets() async {
    openGallery(context, singleMode: true, type: PickType.onlyImage,
        onPicked: (_) async {
      if (_ == null) return;
      profilePhoto = (_[0].file).path;
      uploadFile(File(profilePhoto), (res, e) {
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
