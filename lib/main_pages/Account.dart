import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:maugost_apps/AppConfig.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/MainAdmin.dart';
import 'package:maugost_apps/ManageAds.dart';
import 'package:maugost_apps/ManageProducts.dart';
import 'package:maugost_apps/admin/AppAdmin.dart';
import 'package:maugost_apps/app/app.dart';
import 'package:maugost_apps/assets.dart';
import 'package:maugost_apps/auth/login_page.dart';
import 'package:maugost_apps/auth/signUp_page.dart';
import 'package:maugost_apps/main_pages/RecentlyViewed.dart';
import 'package:maugost_apps/main_pages/Wallet.dart';

import 'EditProfile.dart';

class Account extends StatefulWidget {
  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: page(),
    );
  }

  page() {
    bool push = userModel.getBoolean(PUSH_NOTIFICATION);

    return ListView(
      padding: EdgeInsets.all(0),
      children: [
        if (!isLoggedIn)
          Container(
            width: double.infinity,
//          margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: black.withOpacity(.05),
                borderRadius: BorderRadius.circular(5)),
            child: Row(
              children: [
                Flexible(
                  child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                          side: BorderSide(color: black, width: 2)),
//                    color: blue3,
                      onPressed: () {
                        pushAndResult(context, LoginPage(), depend: false);
                      },
                      child: Text(
                        "Login",
                        style: textStyle(true, 16, black),
                      )),
                  fit: FlexFit.tight,
                ),
                addSpaceWidth(10),
                Flexible(
                  child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                          side: BorderSide(color: black, width: 2)),
//                    color: blue3,
                      onPressed: () {
                        pushAndResult(context, SignUp(), depend: false);
                      },
                      child: Text(
                        "Signup",
                        style: textStyle(true, 16, black),
                      )),
                  fit: FlexFit.tight,
                ),
              ],
            ),
          ),
        if (isLoggedIn)
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: black.withOpacity(.05),
//                  border: Border.all(color: black.withOpacity(.09)),
                borderRadius: BorderRadius.circular(5)),
            child: Column(
//                    crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                userImageItem(context, userModel,
                    size: 60, strokeSize: 1, padLeft: false),
                Text(
                  userModel.getString(NAME),
                  style: textStyle(true, 20, black),
                ),
                StarRating(
                  rating: 5,
                  size: 16,
                  color: AppConfig.appColor,
                  borderColor: black,
                ),
                addSpace(5),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.camera_alt,
                          size: 12,
                          color: black,
                        ),
                        addSpaceWidth(2),
                        Text(
                          "Buyer",
                          style: textStyle(false, 12, black),
                        ),
                      ],
                    ),
                    addSpaceWidth(10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 8,
                          width: 8,
                          decoration: BoxDecoration(
                              color: dark_green0, shape: BoxShape.circle),
                        ),
                        addSpaceWidth(2),
                        Text(
                          "Active",
                          style: textStyle(false, 12, black),
                        ),
                      ],
                    ),
                  ],
                ),
//                      Spacer(),
                Container(
//                    decoration: BoxDecoration(
//                        border: Border.all(color: black, width: 2),
//                        color: black.withOpacity(.9),
//                        borderRadius: BorderRadius.circular(15)
//                      //shape: BoxShape.circle
//                    ),
//                    padding: EdgeInsets.all(5),
                  //height: 70,
                  //width: 70,
                  alignment: Alignment.center,
                  child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (p) {
                        String title = "likes";
                        var icon = Icons.favorite;

                        int count = userModel.getList(LIKES).length;

                        if (p == 1) {
                          title = "Views";
                          icon = Icons.visibility;
                          count = userModel.getList(SEEN_BY).length;
                        }

                        if (p == 2) {
                          title = "Stars";
                          icon = Icons.star;
                          count = userModel.getList(STARS).length;
                        }

                        return Container(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                    color: AppConfig.appColor,
                                    shape: BoxShape.circle),
                                child: Center(
                                  child: Icon(
                                    icon,
                                    size: 18,
                                    color: white_color,
                                  ),
                                ),
                              ),
                              addSpace(5),
                              Text(
                                "${formatToK(count)} $title",
                                style: textStyle(false, 13, black),
                              ),
                            ],
                          ),
                        );
                      })),
                ),
              ],
            ),
          ),
        if (isLoggedIn)
          Container(
            color: black.withOpacity(.05),
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(top: 10, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                fieldItem(Icons.visibility, brown, "Recently Viewed", () {
                  pushAndResult(context, RecentlyViewed(), depend: false);
                }),
                //fieldItem(Icons.link, blue1, "Purchase Orders", () {}),
                fieldItem(Icons.person, green, "Edit Profile", () {
                  pushAndResult(
                      context,
                      EditProfile(
                        modeEdit: true,
                      ),
                      depend: false);
                }),
                fieldItem(Icons.account_balance, orange0, "Wallet Settings",
                    () {
                  pushAndResult(context, Wallet(), depend: false);
                }),
                fieldItem(Icons.view_list, blue, "Manage Products", () {
                  pushAndResult(
                    context,
                    ManageProducts(),
                  );
                }),
                fieldItem(Icons.list, blue, "Manage Ads", () {
                  pushAndResult(
                    context,
                    ManageAds(),
                  );
                }),
                fieldItem(Icons.notifications_active_outlined,
                    AppConfig.appColor, "Push Notifications", () {
                  push = !push;
                  userModel.put(PUSH_NOTIFICATION, push);
                  userModel.updateItems();
                  setState(() {});
                },
                    checkField: true,
                    subTitle: push ? "Enabled" : "Disabled",
                    selected: push),
              ],
            ),
          ),
        Container(
          color: black.withOpacity(.05),
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.only(top: 0, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              fieldItem(Icons.help, blue1, "Support", () {
                String email = appSettingsModel.getString(SUPPORT_EMAIL);
                if (email.isEmpty) return;
                sendEmail(email);
              }),
              fieldItem(LineIcons.sticky_note, black.withOpacity(.5),
                  "Terms & Conditions", () {
                String link = appSettingsModel.getString(TERMS_LINK);
                if (link.isEmpty) return;
                openLink(link);
              }),
              fieldItem(Icons.lock, black.withOpacity(.5), "Privacy Policy",
                  () {
                String link = appSettingsModel.getString(PRIVACY_LINK);
                if (link.isEmpty) return;
                openLink(link);
              }),
              fieldItem(Icons.person, blue, "Tell a friend", () {
                String appLink = appSettingsModel.getString(APP_LINK_IOS);
                String message = appSettingsModel.getString(APP_SHARE_MESSAGE);
                if (Platform.isAndroid)
                  appLink = appSettingsModel.getString(APP_LINK_ANDROID);
                shareApp(message: "$message\n $appLink");
              }),
            ],
          ),
        ),
        if (isLoggedIn)
          Container(
            color: black.withOpacity(.05),
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(top: 0, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                fieldItem(Icons.support_agent, red, "Admin Portal", () {
                  pushAndResult(context, AppAdmin());
                }),
                fieldItem(Icons.exit_to_app, red, "Logout", () {
                  clickLogout(context);
                }),
              ],
            ),
          ),
        addSpace(100)
      ],
    );
  }

  // settingsItemCheck("Push Notifications",
  // push ? "Enabled" : "Disabled", push, () {
  // push = !push;
  // userModel.put(PUSH_NOTIFICATION, push);
  // userModel.updateItems();
  // setState(() {});
  //
  // handleTopics();
  // }),

  fieldItem(icon, color, title, onPressed,
      {bool checkField = false, bool selected = false, String subTitle}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            //height: 40,
            decoration: BoxDecoration(
                border: Border.all(color: white.withOpacity(.02))),
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      //borderRadius: BorderRadius.circular(8)
                    ),
                    child: Icon(
                      icon,
                      color: white_color,
                      size: 18,
                    )),
                addSpaceWidth(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textStyle(false, 16, black),
                      ),
                      if (checkField)
                        Text(
                          subTitle,
                          style: textStyle(false, 12, black.withOpacity(.8)),
                        ),
                    ],
                  ),
                ),
                if (checkField)
                  new Container(
                    //padding: EdgeInsets.all(2),
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: blue09,
                          border: Border.all(
                              color: white.withOpacity(.7), width: 1)),
                      child: Container(
                        width: 25,
                        height: 25,
                        margin: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected ? white : transparent,
                        ),
                        child: Icon(
                          Icons.check,
                          size: 15,
                          color: selected ? black : transparent,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        //addLine(0.09, black, 0, 10, 0, 10),
      ],
    );
  }

  void pickAssets(String s) async {
//    final photos = s == "normal" ? profilePhotos : hookUpPhotos;
//    PhotoPicker.pickAsset(
//            context: context, provider: I18nProvider.english, rowCount: 3)
//        .then((value) async {
//      if (value == null) return;
//      for (var a in value) {
//        String path = (await a.originFile).path;
//        bool isVideo = a.type == AssetType.video;
//        BaseModel model = BaseModel();
//        model.put(OBJECT_ID, a.id);
//        model.put(IMAGE_URL, path);
//        model.put(IS_VIDEO, isVideo);
//        if (isVideo) {
//          model.put(THUMBNAIL_URL,
//              (await VideoCompress().getThumbnailWithFile(path)).path);
//        }
////        int p = photos.indexWhere((e) => e.getObjectId() == a.id);
////        if (p != -1) {
////          photos[p] = model;
////        } else {
////          photos.add(model);
////        }
////        uploadPhotos(model, s, a.id);
//      }
//
//      setState(() {});
//    }).catchError((e) {});

    /// Use assetList to do something.
  }

  handleTopics() {
    bool subscribe = userModel.getBoolean(PUSH_NOTIFICATION);
    List topics = userModel.getList(TOPICS);
    for (String s in topics) {
      if (subscribe) {
        firebaseMessaging.subscribeToTopic(s);
      } else {
        firebaseMessaging.unsubscribeFromTopic(s);
      }
    }
  }
}
