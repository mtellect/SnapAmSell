import 'dart:io';

import 'package:Strokes/AppEngine.dart';
import 'package:Strokes/app/dotsIndicator.dart';
import 'package:Strokes/app/navigation.dart';
import 'package:Strokes/app_config.dart';
import 'package:Strokes/assets.dart';
import 'package:Strokes/basemodel.dart';
import 'package:Strokes/date_picker/flutter_datetime_picker.dart';
import 'package:Strokes/dialogs/inputDialog.dart';
import 'package:Strokes/payment_subscription.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_bubble/chat_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:photo/photo.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_compress/video_compress.dart';

import '../MainAdmin.dart';
import '../preinit.dart';

class AuthMain extends StatefulWidget {
  @override
  _AuthMainState createState() => _AuthMainState();
}

class _AuthMainState extends State<AuthMain> {
  final pc = PageController();
  int currentPage = 0;
  String photoUrl = "";
  var scaffoldKey = GlobalKey<ScaffoldState>();

  int selectedPreference = -1;
  int selectedRelationship = -1;
  int selectedIntent = -1;
  int selectedSmoke = -1;
  int selectedQuickHookUp = 1;
  List<BaseModel> profilePhotos = [];
  List<BaseModel> hookUpPhotos = [];

  int selectedGender = -1;
  int selectedEthnicity = -1;
  bool emailNotification = false;
  bool pushNotification = false;
  String birthDate;
  bool activatePremuim = false;

  String get pageTitle {
    if (currentPage == 0) return "Your Account";
    return "Dating Preferences";
  }

  String get btnTitle {
    if (currentPage == 0) return "Continue";
    return "Finish";
  }

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  loadUser() {
    selectedGender = userModel.selectedGender;
    selectedEthnicity = userModel.selectedEthnicity;
    emailNotification = userModel.emailNotification;
    pushNotification = userModel.pushNotification;
    selectedPreference = userModel.selectedPreference;
    selectedRelationship = userModel.selectedRelationship;
    selectedQuickHookUp = userModel.selectedQuickHookUp;
    profilePhotos = userModel.profilePhotos;
    hookUpPhotos = userModel.hookUpPhotos;
    birthDate = userModel.birthDate;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    //showProgress(true, context, msg: "Hello");
    setState(() {});
    return WillPopScope(
      onWillPop: () async {
        //io.exit(0);
        if (currentPage != 0) {
          pc.jumpTo((currentPage - 1).toDouble());
          return false;
        }
        await FirebaseAuth.instance.signOut();
        await GoogleSignIn().signOut();
        await FacebookAuth.instance.logOut();
        popUpUntil(context, PreInit());
        return false;
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(top: 40, right: 0, left: 10, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pageTitle,
                          style: textStyle(true, 25, black),
                        ),
                        addSpace(10),
                        Container(
                          padding: EdgeInsets.all(1),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: black.withOpacity(.7)),
                          child: DotsIndicator(
                            dotsCount: 2,
                            position: currentPage,
                            decorator: DotsDecorator(
                              size: const Size.square(5.0),
                              color: white,
                              activeColor: AppConfig.appColor,
                              activeSize: const Size(10.0, 7.0),
                              activeShape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  FlatButton(
                    onPressed: () async {
                      if (currentPage != 0) {
                        pc.jumpTo((currentPage - 1).toDouble());
                        return;
                      }
                      await FirebaseAuth.instance.signOut();
                      await GoogleSignIn().signOut();
                      await FacebookAuth.instance.logOut();
                      popUpUntil(context, PreInit());
                    },
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(20),
                    child: Icon(
                      Icons.close,
                      color: black,
                    ),
                  )
                ],
              ),
            ),
            Flexible(
              child: PageView(
                controller: pc,
                physics: NeverScrollableScrollPhysics(),
                onPageChanged: (p) {
                  setState(() {
                    currentPage = p;
                  });
                },
                children: [
                  authPage1(),
                  authPage2(),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(14),
              child: FlatButton(
                onPressed: () {
                  if (currentPage == 0)
                    validateAuth0();
                  else
                    validateAuth1();
                },
                color: AppConfig.appColor,
                padding: EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                child: Center(
                  child: Text(
                    btnTitle,
                    style: textStyle(true, 16, white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  authPage1() {
    //GoogleFonts.futu;
    return Container(
      padding: EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          addLine(.3, black.withOpacity(.2), 0, 20, 0, 10),
          Text("Profile Photos/Videos", style: textStyle(true, 16, black)),
          profilePhotoBox(),
          addLine(.3, black.withOpacity(.2), 0, 20, 0, 10),
          Text("Gender", style: textStyle(true, 16, black)),
          Row(
            children: List.generate(genderType.length, (p) {
              bool active = selectedGender == p;
              return fieldSelector(genderType[p], active: active, onTap: () {
                setState(() {
                  selectedGender = p;
                });
              });
            }),
          ),
          addLine(.3, black.withOpacity(.2), 0, 20, 0, 10),
          Text("Birthdate", style: textStyle(true, 16, black)),
          GestureDetector(
            onTap: () {
              bool empty = null == birthDate || birthDate.isEmpty;

              int year;
              int month;
              int day;
              if (!empty) {
                var birthDay = birthDate.split("-");
                year = num.parse(birthDay[0]);
                month = num.parse(birthDay[1]);
                day = num.parse(birthDay[2]);
              }

              DatePicker.showDatePicker(
                context,
                showTitleActions: true,
                minTime: DateTime(1930, 12, 31),
                maxTime: DateTime(2040, 12, 31),
                onChanged: (date) {},
                onConfirm: (date) {
                  setState(() {
                    int year = date.year;
                    int month = date.month;
                    int day = date.day;
                    birthDate = "$year-${formatDOB(month)}-${formatDOB(day)}";
                  });
                },
                currentTime: empty ? null : DateTime(year, month, day),
              );
            },
            child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: black.withOpacity(.1)),
                    borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.all(14),
                margin: EdgeInsets.all(10),
                child: Builder(
                  builder: (ctx) {
                    bool empty = null == birthDate || birthDate.isEmpty;

                    return Row(children: [
                      Text(empty ? "Date" : birthDate,
                          style: textStyle(
                              true, 14, black.withOpacity(empty ? 0.6 : 1))),
                      Spacer(),
                      Icon(Icons.event,
                          color: black.withOpacity(empty ? 0.6 : 1))
                    ]);
                  },
                )),
          ),
          addLine(.3, black.withOpacity(.2), 0, 20, 0, 10),
          Text("Ethnicity", style: textStyle(true, 16, black)),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: List.generate(ethnicityType.length, (p) {
              bool active = selectedEthnicity == p;
              return fieldSelector(ethnicityType[p],
                  active: active,
                  size: 100,
                  //alignment: Alignment.centerLeft,
                  margin: 8, onTap: () {
                setState(() {
                  selectedEthnicity = p;
                });
              });
            }),
          ),
          addLine(.3, black.withOpacity(.2), 0, 20, 0, 20),
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
                addSpaceWidth(5),
                Flexible(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                            text:
                                'By Clicking on "Continue", You hereby agree to our ',
                            style: textStyle(false, 15, white)),
                        TextSpan(
                            text: 'Terms of Service',
                            style: textStyle(true, 15, AppConfig.appColor)),
                        TextSpan(
                            text: ' and ', style: textStyle(false, 15, white)),
                        TextSpan(
                            text: 'Privacy Policy',
                            style: textStyle(true, 15, AppConfig.appColor)),
                        TextSpan(
                            text: ' Binding our community.',
                            style: textStyle(false, 15, white)),
                      ],
                    ),
                    //textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          addSpace(10),
          InkWell(
            onTap: () {
              setState(() {
                emailNotification = !emailNotification;
              });
            },
            child: Container(
              child: Row(
                children: [
                  Checkbox(
                      activeColor: AppConfig.appColor,
                      value: emailNotification,
                      onChanged: (b) {
                        setState(() {
                          emailNotification = b;
                        });
                      }),
                  Flexible(
                    child: Row(
                      children: [
                        Text("I want to recieve ",
                            style: textStyle(false, 16, black)),
                        Container(
                          child: Text("Email Notifications",
                              style: textStyle(false, 16, black)),
                          decoration: BoxDecoration(
                              border: Border(bottom: BorderSide())),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                pushNotification = !pushNotification;
              });
            },
            child: Container(
              child: Row(
                children: [
                  Checkbox(
                      activeColor: AppConfig.appColor,
                      value: pushNotification,
                      onChanged: (b) {
                        setState(() {
                          pushNotification = b;
                        });
                      }),
                  //addSpaceWidth(5),

                  Flexible(
                    child: Row(
                      children: [
                        Text("I want to recieve ",
                            style: textStyle(false, 16, black)),
                        Container(
                          child: Text("Push Notifications",
                              style: textStyle(false, 16, black)),
                          decoration: BoxDecoration(
                              border: Border(bottom: BorderSide())),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ]),
      ),
    );
  }

  authPage2() {
    return Container(
      padding: EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ChatBubble(
            direction: ChatBubbleNipDirection.LEFT,
            nipLength: 25.0,
            nipRadius: 10.0,
            nipTop: 40.0,
            radius: 10,
            child: Container(
              padding:
                  EdgeInsets.only(left: 40, right: 20, top: 20, bottom: 20),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: AppConfig.appColor,
                //border: Border.all(color: AppConfig.appColor)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Who are you looking for,",
                      style: textStyle(false, 20, black)),
                  addSpace(5),
                  Text("Who do you see spending all your time with?",
                      style: textStyle(false, 14, black)),
                ],
              ),
            ),
          ),

          // addSpace(20),
          addLine(.3, black.withOpacity(.2), 0, 20, 0, 10),
          Text("What's your preference?", style: textStyle(true, 16, black)),
          Row(
            children: List.generate(preferenceType.length, (p) {
              bool active = selectedPreference == p;
              return fieldSelector(preferenceType[p], active: active,
                  onTap: () {
                setState(() {
                  selectedPreference = p;
                });
              });
            }),
          ),
          addLine(.3, black.withOpacity(.2), 0, 20, 0, 10),
          Text("What kind of relationship do you want?",
              style: textStyle(true, 16, black)),
          Wrap(
            children: List.generate(relationshipType.length, (p) {
              bool active = selectedRelationship == p;
              return fieldSelector(relationshipType[p], active: active,
                  onTap: () {
                setState(() {
                  selectedRelationship = p;
                });
              });
            }),
          ),
          addLine(.3, black.withOpacity(.2), 0, 20, 0, 10),
          Row(
            children: [
              Text("Do you want to be listed on Quick Strock?",
                  style: textStyle(true, 16, black)),
              addSpaceWidth(5),
              GestureDetector(
                  onTap: () {
                    showMessage(context, Icons.info, black, "Quick Strock",
                        "What kind of person are you interested to hookup with?");
                  },
                  child: Icon(Icons.info)),
            ],
          ),
          Row(
            children: List.generate(quickHookUps.length, (p) {
              bool active = selectedQuickHookUp == p;
              return fieldSelector(quickHookUps[p], active: active, onTap: () {
                setState(() {
                  selectedQuickHookUp = p;
                });
              });
            }),
          ),
          if (selectedQuickHookUp == 0) ...[
            hookUpPhotoBox(),
            Row(
              children: [
                Text("Whats your Wow Factor?",
                    style: textStyle(true, 16, black)),
                addSpaceWidth(5),
                GestureDetector(
                    onTap: () {
                      showMessage(context, Icons.info, black, "Quick Strock",
                          "What kind of person are you interested to hookup with?");
                    },
                    child: Icon(Icons.info)),
                Spacer(),
                IconButton(
                  icon: Image.asset(
                    ic_edit_profile,
                    color: black,
                    height: 20,
                  ),
                  onPressed: () {
                    pushAndResult(
                        context,
                        inputDialog(
                          "Wow Factor",
                          hint: "Write about your wow factor",
                          message: userModel.getString(WOW_FACTOR),
                        ), result: (_) {
                      if (null == _) return;
                      userModel
                        ..put(WOW_FACTOR, _)
                        ..updateItems();

                      setState(() {});
                    });
                  },
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                pushAndResult(
                    context,
                    inputDialog(
                      "Wow Factor",
                      hint: "Write about your wow factor",
                      message: userModel.getString(WOW_FACTOR),
                    ), result: (_) {
                  if (null == _) return;
                  userModel
                    ..put(WOW_FACTOR, _)
                    ..updateItems();

                  setState(() {});
                });
              },
              child: Container(
                  decoration: BoxDecoration(
                      color: black.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(15)),
                  padding: EdgeInsets.all(15),
                  alignment: Alignment.centerLeft,
                  child: Text(
                      userModel.getString(WOW_FACTOR).isEmpty
                          ? "Write about your wow factor"
                          : userModel.getString(ABOUT_ME),
                      style: textStyle(false, 16, black.withOpacity(.6)))),
            ),
          ],

          addLine(.3, black.withOpacity(.2), 0, 20, 0, 10),
          InkWell(
            onTap: () {
              setState(() {
                activatePremuim = !activatePremuim;
              });
            },
            child: Container(
              padding: EdgeInsets.only(top: 15, bottom: 15),
              child: Row(
                children: [
                  Text("Become a Premium User Today?",
                      style: textStyle(true, 16, black)),
                  addSpaceWidth(5),
                  GestureDetector(
                      onTap: () {
                        showProgress(true, context);
                        return;
                        showMessage(context, Icons.info, black, "Quick HookUp?",
                            "Ok Do hhhhmfgfg");
                      },
                      child: Icon(Icons.info)),
                  Spacer(),
                  if (Platform.isIOS)
                    CupertinoSwitch(
                        value: activatePremuim,
                        activeColor: AppConfig.appColor,
                        onChanged: (b) {
                          setState(() {
                            activatePremuim = b;
                          });
                        })
                  else
                    Switch(
                        value: activatePremuim,
                        activeColor: AppConfig.appColor,
                        onChanged: (b) {
                          setState(() {
                            activatePremuim = b;
                          });
                        })
                ],
              ),
            ),
          ),

          if (activatePremuim) packagesBox()
        ]),
      ),
    );
  }

  int selectedPlan = -1;

  packagesBox() {
    return Container(
      color: black.withOpacity(.02),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(3, (p) {
            return packages(p);
          })),
    );
  }

  packages(int p) {
    BaseModel package = appSettingsModel.getModel(FEATURES_PREMIUM);
    final fee = package.getList(PREMIUM_FEES)[p];
    final features = package.getString(FEATURES).split("&");
    String baseCurrency = appSettingsModel.getString(APP_CURRENCY);

    String title = p == 0 ? "1 Month" : p == 1 ? "6 Months" : "12 Months";

    //String fee = plan["fee"];
    bool active = selectedPlan == p;
    double mSize = active ? 30 : 20;
    double fSize = active ? 20 : 16;

    return Flexible(
        child: GestureDetector(
      onTap: () {
        setState(() {
          selectedPlan = p;
        });
      },
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: active ? white : black.withOpacity(.04),
            border: Border.all(
                width: active ? 3 : 1,
                color: active ? AppConfig.appColor : black.withOpacity(.1))),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: textStyle(true, fSize, black.withOpacity(.7)),
            ),
//            Text("Months"),
//            addSpace(10),
            Text(
              fee,
              style: textStyle(true, fSize,
                  active ? AppConfig.appColor : black.withOpacity(.7)),
            ),
            Text(
              "($baseCurrency)",
            ),
          ],
        ),
      ),
    ));
  }

  profilePhotoBox() {
    final photos = profilePhotos.where((e) => !e.isHookUps).toList();

    return Column(
      children: [
        addSpace(10),
        if (profilePhotos.isNotEmpty)
          Container(
            height: 240,
            child: LayoutBuilder(
              builder: (ctx, b) {
                int photoLength = profilePhotos.length;
                return Column(
                  children: <Widget>[
                    Flexible(
                      child: ListView.builder(
                          itemCount: photoLength,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (ctx, p) {
                            BaseModel photo = profilePhotos[p];
                            bool isVideo = photo.isVideo;
                            String imageUrl = photo
                                .getString(isVideo ? THUMBNAIL_URL : IMAGE_URL);
                            bool isLocal = photo.isLocal;
                            return Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.all(8),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: isLocal
                                        ? Image.file(
                                            File(imageUrl),
                                            height: 200,
                                            width: 160,
                                            fit: BoxFit.cover,
                                          )
                                        : CachedNetworkImage(
                                            imageUrl: imageUrl,
                                            height: 200,
                                            width: 160,
                                            fit: BoxFit.cover,
                                            placeholder: (ctx, s) {
                                              return placeHolder(200,
                                                  width: 160);
                                            },
                                          ),
                                  ),
                                ),
                                if (isVideo)
                                  Center(
                                    child: Container(
                                      height: 50,
                                      width: 50,
                                      child: Icon(
                                        Icons.play_arrow,
                                        color: Colors.white,
                                      ),
                                      decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.8),
                                          border: Border.all(
                                              color: Colors.white, width: 1.5),
                                          shape: BoxShape.circle),
                                    ),
                                  ),
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Container(
                                    height: 200,
                                    width: 160,
                                    alignment: Alignment.topLeft,
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      margin: EdgeInsets.fromLTRB(5, 25, 0, 0),
                                      width: 30,
                                      height: 30,
                                      child: new RaisedButton(
                                          padding: EdgeInsets.all(0),
                                          elevation: 2,
                                          shape: CircleBorder(),
                                          color: red0,
                                          child: Icon(
                                            Icons.close,
                                            color: white,
                                            size: 13,
                                          ),
                                          onPressed: () {
                                            //toast(scaffoldKey, "Removed!");

                                            profilePhotos.removeAt(p);
                                            setState(
                                              () {},
                                            );
                                          }),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                    ),
                  ],
                );
              },
            ),
          ),
        if (profilePhotos.length < 10) ...[
          //addSpace(10),
          Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: FlatButton(
              onPressed: () async {
                pickAssets("normal");
              },
              color: black.withOpacity(.5),
              padding: EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              child: Center(
                child: Text(
                  'Add',
                  style: textStyle(true, 14, white),
                ),
              ),
            ),
          )
        ],
        addSpace(10),
      ],
    );
  }

  hookUpPhotoBox() {
    final photos = profilePhotos.where((e) => e.isHookUps).toList();

    return Column(
      children: [
        addSpace(10),
        if (hookUpPhotos.isNotEmpty)
          Container(
            height: 240,
            child: LayoutBuilder(
              builder: (ctx, b) {
                int photoLength = hookUpPhotos.length;
                return Column(
                  children: <Widget>[
                    Flexible(
                      child: ListView.builder(
                          itemCount: photoLength,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (ctx, p) {
                            BaseModel photo = hookUpPhotos[p];
                            bool isVideo = photo.isVideo;
                            String imageUrl = photo
                                .getString(isVideo ? THUMBNAIL_URL : IMAGE_URL);
                            bool isLocal = photo.isLocal;
                            return Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.all(8),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: isLocal
                                        ? Image.file(
                                            File(imageUrl),
                                            height: 200,
                                            width: 160,
                                            fit: BoxFit.cover,
                                          )
                                        : CachedNetworkImage(
                                            imageUrl: imageUrl,
                                            height: 200,
                                            width: 160,
                                            fit: BoxFit.cover,
                                            placeholder: (ctx, s) {
                                              return placeHolder(200,
                                                  width: 160);
                                            },
                                          ),
                                  ),
                                ),
                                if (isVideo)
                                  Center(
                                    child: Container(
                                      height: 50,
                                      width: 50,
                                      child: Icon(
                                        Icons.play_arrow,
                                        color: Colors.white,
                                      ),
                                      decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.8),
                                          border: Border.all(
                                              color: Colors.white, width: 1.5),
                                          shape: BoxShape.circle),
                                    ),
                                  ),
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Container(
                                    height: 200,
                                    width: 160,
                                    alignment: Alignment.topLeft,
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      margin: EdgeInsets.fromLTRB(5, 25, 0, 0),
                                      width: 30,
                                      height: 30,
                                      child: new RaisedButton(
                                          padding: EdgeInsets.all(0),
                                          elevation: 2,
                                          shape: CircleBorder(),
                                          color: red0,
                                          child: Icon(
                                            Icons.close,
                                            color: white,
                                            size: 13,
                                          ),
                                          onPressed: () {
                                            //toast(scaffoldKey, "Removed!");

                                            hookUpPhotos.removeAt(p);
                                            setState(
                                              () {},
                                            );
                                          }),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                    ),
                  ],
                );
              },
            ),
          ),
        if (hookUpPhotos.length < 10) ...[
          //addSpace(10),
          Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: FlatButton(
              onPressed: () async {
                pickAssets("nahh");
              },
              color: black.withOpacity(.5),
              padding: EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              child: Center(
                child: Text(
                  'Add Photos/Videos',
                  style: textStyle(true, 14, white),
                ),
              ),
            ),
          )
        ],
        addSpace(10),
      ],
    );
  }

  void uploadPhotos(BaseModel model, String s, String id) {
    final photos = s == "normal" ? profilePhotos : hookUpPhotos;
    photos.add(model);
    String key = s == "normal" ? PROFILE_PHOTOS : HOOKUP_PHOTOS;
//    userModel
//      ..put(key, photos.map((e) => e.items).toList())
//      ..updateItems();
    if (mounted) setState(() {});
    //return;
    uploadFile(File(model.imageUrl), (res, err) {
      if (null != err) return;
      final photos = userModel.profilePhotos;

      int pos = photos.indexWhere((e) => e.getObjectId() == id);
      if (pos != -1) {
        model.put(IMAGE_URL, res);
        photos[pos] = model;
        userModel
          ..put(key, photos.map((e) => e.items).toList())
          ..updateItems();
      }

      if (mounted) setState(() {});
    });
  }

  void pickAssets(String s) async {
    PhotoPicker.pickAsset(
            context: context, provider: I18nProvider.english, rowCount: 3)
        .then((value) async {
      if (value == null) return;
      for (var a in value) {
        String path = (await a.originFile).path;
        bool isVideo = a.type == AssetType.video;
        BaseModel model = BaseModel();
        model.put(OBJECT_ID, a.id);
        model.put(IMAGE_URL, path);
        model.put(IS_VIDEO, isVideo);
        if (isVideo) {
          model.put(THUMBNAIL_URL,
              (await VideoCompress().getThumbnailWithFile(path)).path);
        }
        uploadPhotos(model, s, a.id);
      }

      setState(() {});
    }).catchError((e) {});

    /// Use assetList to do something.
  }

  void validateAuth0() async {
    int minAge = 18;
    int maxAge = 80;

    bool empty = null == birthDate || birthDate.isEmpty;
    int age = getAge(DateTime.parse(birthDate));

    if (profilePhotos.isEmpty) {
      toast(scaffoldKey, "Add Profile Photo or Video");
      return;
    }
    if (selectedGender == -1) {
      toast(scaffoldKey, "Choose your Gender");
      return;
    }
    if (empty) {
      toast(scaffoldKey, "Choose your BirthDate");
      return;
    }

    if (minAge > age) {
      toast(scaffoldKey, "Sorry, You must be up to 18 years");
      return;
    }

    if (maxAge < age) {
      toast(scaffoldKey, "Sorry, You can't be above 80 years");
      return;
    }

    if (selectedEthnicity == -1) {
      toast(scaffoldKey, "Choose your Ethnicity");
      return;
    }

    userModel
      ..put(BIRTH_DATE, birthDate)
      ..put(GENDER, selectedGender)
      ..put(ETHNICITY, selectedEthnicity)
      ..put(EMAIL_NOTIFICATION, emailNotification)
      ..put(PUSH_NOTIFICATION, pushNotification)
      ..updateItems();

    pc.nextPage(
        duration: Duration(milliseconds: 500), curve: Curves.easeInToLinear);
    return;
  }

  void validateAuth1() async {
    if (selectedPreference == -1) {
      toast(scaffoldKey, "Choose your Preference");
      return;
    }
    if (selectedRelationship == -1) {
      toast(scaffoldKey, "Choose your Relationship Kind");
      return;
    }
    if (selectedQuickHookUp == -1) {
      toast(scaffoldKey, "Choose your Quick Strock Choice");
      return;
    }
    if (selectedQuickHookUp == 0 && hookUpPhotos.isEmpty) {
      toast(scaffoldKey, "Quick Strock Photos/Videos cannot be empty!");
      return;
    }

    //  if (selectedQuickHookUp == 0 && userModel.getString(WOW_FACTOR).isEmpty) {
    //   toast(scaffoldKey, "Write about your wow factor!");
    //   return;
    // }

    showProgress(true, context, msg: "Saving Profile...");
    userModel
      ..put(PROFILE_PHOTOS, profilePhotos.map((e) => e.items).toList())
      ..put(HOOKUP_PHOTOS, hookUpPhotos.map((e) => e.items).toList())
      ..put(PREFERENCE, selectedPreference)
      ..put(RELATIONSHIP, selectedRelationship)
      ..put(QUICK_HOOKUP, selectedQuickHookUp)
      ..put(SIGNUP_COMPLETED, true)
      ..updateItems();
    Future.delayed(Duration(seconds: 3), () {
      if (selectedPlan != -1) {
        popUpUntil(
            context,
            PaymentSubscription(
              fromSignUp: true,
              premiumIndex: selectedPlan,
            ));
      } else {
        popUpUntil(context, MainAdmin());
      }
    });
  }
}
