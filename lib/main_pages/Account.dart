import 'dart:io';
import 'dart:ui';

import 'package:Strokes/AppEngine.dart';
import 'package:Strokes/Settings.dart';
import 'package:Strokes/admin/AppAdmin.dart';
import 'package:Strokes/app_config.dart';
import 'package:Strokes/assets.dart';
import 'package:Strokes/basemodel.dart';
import 'package:Strokes/dialogs/inputDialog.dart';
import 'package:Strokes/main_pages/AdsPage.dart';
import 'package:Strokes/payment_subscription.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo/photo.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_compress/video_compress.dart';

class Account extends StatefulWidget {
  final bool showBar;

  const Account({Key key, this.showBar = true}) : super(key: key);

  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  TextEditingController aboutController = TextEditingController();
  int myPreference = -1;

  List<BaseModel> profilePhotos = userModel.profilePhotos;
  List<BaseModel> hookUpPhotos = userModel.hookUpPhotos;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: page(),
    );
  }

  String get formatBirthDate {
    final date = DateTime.parse(userModel.birthDate);
    return new DateFormat("MMMM d").format(date);
  }

  page() {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                height: getScreenHeight(context) / 2,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (userModel.profilePhotos[0].isLocal)
                      Image.file(
                        File(getFirstPhoto(userModel.profilePhotos)),
                        fit: BoxFit.cover,
                      )
                    else
                      CachedNetworkImage(
                        imageUrl: getFirstPhoto(userModel.profilePhotos),
                        fit: BoxFit.cover,
                      ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(25),
                                topLeft: Radius.circular(25))),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            margin: EdgeInsets.fromLTRB(20, 0, 10, 0),
                            height: 100,
                            width: 100,
                            child: Card(
                              margin: EdgeInsets.only(bottom: 5),
                              clipBehavior: Clip.antiAlias,
                              shape: CircleBorder(
                                  side: BorderSide(color: white, width: 2)),
                              child: CachedNetworkImage(
                                  imageUrl:
                                      getFirstPhoto(userModel.profilePhotos),
                                  fit: BoxFit.cover),
                            ),
                          ),
                          Flexible(
                            child: Container(
                                margin: EdgeInsets.only(bottom: 15),
                                child: Row(
                                  children: [
                                    Flexible(
                                      fit: FlexFit.tight,
                                      child: Text(
                                        userModel.getString(NAME),
                                        style: textStyle(false, 22, black),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    addSpaceWidth(5),
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
                                              "Your Name",
                                              message:
                                                  userModel.getString(NAME),
                                              hint: "What's your name?",
                                            ), result: (_) {
                                          if (null == _) return;
                                          userModel
                                            ..put(NAME, _)
                                            ..updateItems();

                                          setState(() {});
                                        });
                                      },
                                    ),
                                    addSpaceWidth(5),
                                  ],
                                )),
                          )
                        ],
                      ),
                    ),
//                    Align(
//                      alignment: Alignment.bottomRight,
//                      child: Container(
//                        margin: EdgeInsets.fromLTRB(0, 0, 20, 80),
//                        child: FloatingActionButton(
//                          onPressed: () {},
//                          heroTag: "cax",
//                          backgroundColor: white,
//                          child: Icon(
//                            Icons.add_a_photo,
//                            size: 20,
//                            color: black,
//                          ),
//                        ),
//                      ),
//                    )
                  ],
                ),
              ),
              Flexible(
                child: Container(
                  child: ListView(
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(0),
                    shrinkWrap: true,
                    children: [
                      addSpace(10),
                      Row(
                        children: [
                          Flexible(
                              fit: FlexFit.tight,
                              child: Column(
                                children: [
                                  Text(
                                    "Popularity\n ${userModel.isPremium ? "Full" : "Very low"}",
                                    textAlign: TextAlign.center,
                                    style: textStyle(
                                        false, 14, black.withOpacity(.5)),
                                  ),
                                  //addSpace(5),
                                  Image.asset(
                                    "assets/icons/${userModel.isPremium ? "battery" : "low-battery"}.png",
                                    width: 50,
                                  )
                                ],
                              )),
                          Flexible(
                              fit: FlexFit.tight,
                              child: GestureDetector(
                                onTap: () {
                                  if (userModel.isPremium) return;
                                  pushAndResult(context, PaymentSubscription(),
                                      depend: false);
                                },
                                child: Column(
                                  children: [
                                    Text(
                                      "Your\nStatus",
                                      textAlign: TextAlign.center,
                                      style: textStyle(
                                          false, 14, black.withOpacity(.5)),
                                    ),
                                    addSpace(5),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          userModel.isPremium
                                              ? "PREMIUM"
                                              : "REGULAR",
                                          style: textStyle(false, 18, black),
                                        ),
                                        addSpaceWidth(5),
                                        Icon(
                                          Icons.add_circle_outline,
                                          size: 18,
                                          color: blue0,
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              )),
                          Flexible(
                              fit: FlexFit.tight,
                              child: Column(
                                children: [
                                  Text(
                                    "Super\nPowers",
                                    textAlign: TextAlign.center,
                                    style: textStyle(
                                        false, 14, black.withOpacity(.5)),
                                  ),
                                  addSpace(5),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        userModel.isPremium ? "On" : "Off",
                                        style: textStyle(false, 18, black),
                                      ),
                                      addSpaceWidth(5),
                                      Icon(
                                        Icons.add_circle_outline,
                                        size: 18,
                                        color: blue0,
                                      )
                                    ],
                                  )
                                ],
                              )),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 30, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Profile Photos",
                                  style: textStyle(true, 22, black),
                                ),
                                Spacer(),
                                IconButton(
                                  onPressed: () {
                                    pickAssets("normal");
                                  },
                                  icon: Icon(Icons.add_a_photo),
                                )
                              ],
                            ),
                            photoBox(profilePhotos, (p) {
                              if (profilePhotos.length <= 1) return;
                              profilePhotos.removeAt(p);
                              setState(() {});
                              userModel
                                ..put(PROFILE_PHOTOS,
                                    profilePhotos.map((e) => e.items).toList())
                                ..updateItems();
                            }),
                            if (hookUpPhotos.isNotEmpty) ...[
                              Row(
                                children: [
                                  Text(
                                    "Quick Strock Photos",
                                    style: textStyle(true, 22, black),
                                  ),
                                  Spacer(),
                                  IconButton(
                                    onPressed: () {
                                      pickAssets("nah");
                                    },
                                    icon: Icon(Icons.add_a_photo),
                                  )
                                ],
                              ),
                              if (userModel.getBoolean(SHOW_STROCK_PICS))
                                photoBox(hookUpPhotos, (p) {
                                  //if (hookUpPhotos.length <= 1) return;

                                  hookUpPhotos.removeAt(p);
                                  setState(() {});
                                  userModel
                                    ..put(
                                        HOOKUP_PHOTOS,
                                        hookUpPhotos
                                            .map((e) => e.items)
                                            .toList())
                                    ..updateItems();
                                }),
                              InkWell(
                                onTap: () {
                                  bool show =
                                      userModel.getBoolean(SHOW_STROCK_PICS);
                                  setState(() {
                                    userModel
                                      ..put(SHOW_STROCK_PICS, !show)
                                      ..updateItems();
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.only(top: 15, bottom: 15),
                                  child: Row(
                                    children: [
                                      Text(
                                          "${userModel.getBoolean(SHOW_STROCK_PICS) ? "Hide" : "Show"} Quick Strock Photos?",
                                          style: textStyle(true, 16, black)),
                                      addSpaceWidth(5),
                                      GestureDetector(
                                          onTap: () {
                                            showProgress(true, context);
                                            return;
                                            showMessage(
                                                context,
                                                Icons.info,
                                                black,
                                                "Quick HookUp?",
                                                "Ok Do hhhhmfgfg");
                                          },
                                          child: Icon(Icons.info)),
                                      Spacer(),
                                      if (Platform.isIOS)
                                        CupertinoSwitch(
                                            value: userModel
                                                .getBoolean(SHOW_STROCK_PICS),
                                            activeColor: AppConfig.appColor,
                                            onChanged: (b) {
                                              bool show = userModel
                                                  .getBoolean(SHOW_STROCK_PICS);
                                              setState(() {
                                                userModel
                                                  ..put(SHOW_STROCK_PICS, !show)
                                                  ..updateItems();
                                              });
                                            })
                                      else
                                        Switch(
                                            value: userModel
                                                .getBoolean(SHOW_STROCK_PICS),
                                            activeColor: AppConfig.appColor,
                                            onChanged: (b) {
                                              bool show = userModel
                                                  .getBoolean(SHOW_STROCK_PICS);
                                              setState(() {
                                                userModel
                                                  ..put(SHOW_STROCK_PICS, !show)
                                                  ..updateItems();
                                              });
                                            })
                                    ],
                                  ),
                                ),
                              ),
                            ] else
                              GestureDetector(
                                onTap: () {
                                  pickAssets("nah");
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: AppConfig.appColor,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      border: Border.all(
                                          color: black.withOpacity(.1),
                                          width: 1)),
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color:
                                                          white.withOpacity(.5),
                                                      width: 1)),
                                              child: Center(
                                                child: Icon(Icons.contacts),
                                              ),
                                            ),
                                            addSpaceWidth(10),
                                            Text(
                                              "JOIN QUICK STROCK",
                                              style:
                                                  textStyle(false, 18, black),
                                            ),
                                          ],
                                        ),
                                      ),
                                      addSpaceWidth(10),
                                      Icon(
                                        Icons.navigate_next,
                                        size: 24,
                                        color: white.withOpacity(.4),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            addSpace(20),
                            Row(
                              children: [
                                Text(
                                  "About you",
                                  style: textStyle(true, 22, black),
                                ),
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
                                          "About you",
                                          hint: "Write a bit about yourself",
                                          message:
                                              userModel.getString(ABOUT_ME),
                                        ), result: (_) {
                                      if (null == _) return;
                                      userModel
                                        ..put(ABOUT_ME, _)
                                        ..updateItems();

                                      setState(() {});
                                    });
                                  },
                                ),
                              ],
                            ),
                            addSpace(15),
                            Container(
                                child: Text(
                                    userModel.getString(ABOUT_ME).isEmpty
                                        ? "Write a bit about yourself"
                                        : userModel.getString(ABOUT_ME),
                                    style: textStyle(
                                        false, 18, black.withOpacity(.6)))),
                            addLine(1, black.withOpacity(.1), 0, 10, 0, 10),
                            Text(
                              "Your Birthday?",
                              style: textStyle(true, 22, black),
                            ),
                            addSpace(15),
                            Text(
                              formatBirthDate,
                              style:
                                  textStyle(false, 16, black.withOpacity(.7)),
                            ),
                            addSpace(15),
                            addLine(1, black.withOpacity(.1), 0, 10, 0, 10),
                            Text(
                              "Your Ethnicity preference?",
                              style: textStyle(true, 22, black),
                            ),
                            addSpace(15),
                            groupedButtons(
                                ethnicityType,
                                userModel.getInt(ETHNICITY) == -1
                                    ? ""
                                    : ethnicityType[userModel
                                        .getInt(ETHNICITY)], (text, p) {
                              userModel
                                ..put(ETHNICITY, p)
                                ..updateItems();
                              setState(() {
                                //myPreference = p;
                              });
                            },
                                selectedColor: AppConfig.appColor,
                                normalColor: black.withOpacity(.6),
                                selectedTextColor: white,
                                normalTextColor: black),
                            addLine(1, black.withOpacity(.1), 0, 10, 0, 10),
                            addSpace(15),
                            Text(
                              "What's your Gender preference?",
                              style: textStyle(true, 22, black),
                            ),
                            addSpace(15),
                            groupedButtons(
                                preferenceType,
                                userModel.getInt(PREFERENCE) == -1
                                    ? ""
                                    : preferenceType[userModel
                                        .getInt(PREFERENCE)], (text, p) {
                              userModel
                                ..put(PREFERENCE, p)
                                ..updateItems();
                              setState(() {
                                //myPreference = p;
                              });
                            },
                                selectedColor: AppConfig.appColor,
                                normalColor: black.withOpacity(.6),
                                selectedTextColor: white,
                                normalTextColor: black),
                            addSpace(15),
                            addLine(1, black.withOpacity(.1), 0, 10, 0, 10),
                            Text(
                              "Your Relationship preference?",
                              style: textStyle(true, 22, black),
                            ),
                            addSpace(15),
                            groupedButtons(
                                relationshipType,
                                userModel.getInt(RELATIONSHIP) == -1
                                    ? ""
                                    : relationshipType[userModel
                                        .getInt(RELATIONSHIP)], (text, p) {
                              userModel
                                ..put(RELATIONSHIP, p)
                                ..updateItems();
                              setState(() {
                                //myPreference = p;
                              });
                            },
                                selectedColor: AppConfig.appColor,
                                normalColor: black.withOpacity(.6),
                                selectedTextColor: white,
                                normalTextColor: black),
                            addSpace(15),
                            addLine(1, black.withOpacity(.1), 0, 10, 0, 10),
                            Text(
                              "Location",
                              style: textStyle(true, 22, black),
                            ),
                            addSpace(15),
                            Container(
                                height: 40,
                                width: double.infinity,
                                child: Row(children: [
                                  Flexible(
                                      fit: FlexFit.tight,
                                      child: Text(
                                        userModel.getString(MY_LOCATION),
                                        style: textStyle(false, 18, black),
                                      )),
                                  Text(userModel.getString(COUNTRY),
                                      style: textStyle(
                                          false, 14, black.withOpacity(.5)))
                                ])),
                            if (userModel.isPremium)
                              InkWell(
                                onTap: () {
                                  showMessage(
                                      context,
                                      Icons.error,
                                      red0,
                                      "Cancel?",
                                      "Are you sure you want to cancel your Subscription? This would revert you back to a regular user.",
                                      textSize: 14,
                                      clickYesText: "UnSubscribe",
                                      onClicked: (_) {
                                    if (_) {
                                      userModel
                                        ..put(ACCOUNT_TYPE, 0)
                                        ..updateItems();
                                      setState(() {});
                                    }
                                  }, clickNoText: "Cancel");
                                },
                                child: Container(
                                    //height: 50,
                                    color: red,
                                    padding: EdgeInsets.all(15),
                                    width: double.infinity,
                                    child: Row(children: [
                                      Flexible(
                                          fit: FlexFit.tight,
                                          child: Text(
                                            "Cancel Subscription",
                                            style: textStyle(true, 18, white),
                                          )),
                                      Icon(
                                        Icons.navigate_next,
                                        size: 18,
                                        color: white,
                                      )
                                    ])),
                              ),
                            addLine(1, black.withOpacity(.1), 0, 0, 0, 10),
                            InkWell(
                              onTap: () {
                                pushAndResult(context, Settings(),
                                    depend: false);
                              },
                              child: Container(
                                  height: 40,
                                  width: double.infinity,
                                  child: Row(children: [
                                    Flexible(
                                        fit: FlexFit.tight,
                                        child: Text(
                                          "General Settings",
                                          style: textStyle(true, 18, black),
                                        )),
                                    Icon(
                                      Icons.navigate_next,
                                      size: 18,
                                      color: black,
                                    )
                                  ])),
                            ),
                            addLine(1, black.withOpacity(.1), 0, 0, 0, 10),
                            InkWell(
                              onTap: () {
                                pushAndResult(context, AdsPage());
                              },
                              child: Container(
                                  height: 40,
                                  width: double.infinity,
                                  child: Row(children: [
                                    Flexible(
                                        fit: FlexFit.tight,
                                        child: Text(
                                          "Advertize With Us",
                                          style: textStyle(true, 18, black),
                                        )),
                                    Icon(
                                      Icons.navigate_next,
                                      size: 18,
                                      color: black,
                                    )
                                  ])),
                            ),
                            addLine(1, black.withOpacity(.1), 0, 10, 0, 0),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              if (isAdmin) ...[
                InkWell(
                  onTap: () {
                    pushAndResult(context, AppAdmin(), depend: false);
                  },
                  child: Container(
                      //height: 50,
                      color: red,
                      padding: EdgeInsets.all(15),
                      width: double.infinity,
                      child: Row(children: [
                        Flexible(
                            fit: FlexFit.tight,
                            child: Text(
                              "Admin Portal",
                              style: textStyle(true, 18, white),
                            )),
                        Icon(
                          Icons.navigate_next,
                          size: 18,
                          color: white,
                        )
                      ])),
                ),
              ],
              addSpace(150),
            ],
          ),
        ),
        if (widget.showBar)
          Align(
            alignment: Alignment.topLeft,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                  margin: EdgeInsets.fromLTRB(0, 40, 0, 0),
                  padding: EdgeInsets.only(left: 10, right: 15),
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                      color: white,
                      boxShadow: [
                        BoxShadow(color: black.withOpacity(.3), blurRadius: 5)
                      ],
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(15),
                          bottomRight: Radius.circular(15))),
                  child: Icon(
                    Icons.cancel,
                    size: 35,
                    color: black.withOpacity(.5),
                  )),
            ),
          ),
      ],
    );
  }

  photoBox(List<BaseModel> photos, onRemoved) {
    //final hookUpPhotos = theUser.hookUpPhotos;
    return Column(
      children: [
        if (photos.isNotEmpty)
          Container(
            height: 240,
            child: LayoutBuilder(
              builder: (ctx, b) {
                int photoLength = photos.length;
                return Column(
                  children: <Widget>[
                    Flexible(
                      child: ListView.builder(
                          itemCount: photoLength,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (ctx, p) {
                            BaseModel photo = photos[p];
                            bool isVideo = photo.isVideo;
                            String imageUrl = photo
                                .getString(isVideo ? THUMBNAIL_URL : IMAGE_URL);

                            String localUrl = photo.getString(
                                isVideo ? THUMBNAIL_PATH : IMAGE_PATH);

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
                                            onRemoved(p);
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
      ],
    );
  }

  void uploadPhotos(BaseModel model, String s, String id) {
    final photos = s == "normal" ? profilePhotos : hookUpPhotos;
    photos.add(model);
    String key = s == "normal" ? PROFILE_PHOTOS : HOOKUP_PHOTOS;
    userModel
      ..put(key, photos.map((e) => e.items).toList())
      ..updateItems();
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
//    final photos = s == "normal" ? profilePhotos : hookUpPhotos;
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
//        int p = photos.indexWhere((e) => e.getObjectId() == a.id);
//        if (p != -1) {
//          photos[p] = model;
//        } else {
//          photos.add(model);
//        }
        uploadPhotos(model, s, a.id);
      }

      setState(() {});
    }).catchError((e) {});

    /// Use assetList to do something.
  }
}
