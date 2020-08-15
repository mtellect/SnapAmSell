import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/assets.dart';

import 'MainAdmin.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> with TickerProviderStateMixin {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: transparent,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          CachedNetworkImage(
            imageUrl: userModel.profilePhotos[0].imageUrl,
            fit: BoxFit.cover,
            height: MediaQuery.of(context).size.height,
          ),
          BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                color: black.withOpacity(.6),
              )),
          page()
        ],
      ),
    );
  }

  BuildContext con;

  Builder page() {
    bool push = userModel.getBoolean(PUSH_NOTIFICATION);

    return Builder(builder: (context) {
      this.con = context;
      return new Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          addSpace(40),
          Padding(
            padding: const EdgeInsets.only(left: 0),
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
                        color: white,
                        size: 25,
                      )),
                    )),
                Flexible(
                    child: Text(
                  "Settings",
                  style: textStyle(true, 25, white),
                )),
              ],
            ),
          ),
          addSpace(15),
          new Expanded(
              flex: 1,
              child: Scrollbar(
                child: new ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(0),
                  children: <Widget>[
                    settingsItemCheck("Push Notifications",
                        push ? "Enabled" : "Disabled", push, () {
                      push = !push;
                      userModel.put(PUSH_NOTIFICATION, push);
                      userModel.updateItems();
                      setState(() {});

                      handleTopics();
                    }),
                    settingsItem("Share App", () {
                      shareApp();
                    }),
                    settingsItem("Rate App", () {
                      rateApp();
                    }),

                    /*settingsItem("Share App", () {}),*/
                    // settingsItem("About App", () {
                    //   String link = appSettingsModel.getString(ABOUT_LINK);
                    //   if (link.isEmpty) return;
                    //   openLink(link);
                    // }),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Text(
                        "Help & Support",
                        style: textStyle(false, 17, white.withOpacity(.5)),
                      ),
                    ),
                    settingsItem("Send us feedback", () {
                      String email = appSettingsModel.getString(SUPPORT_EMAIL);
                      if (email.isEmpty) return;
                      sendEmail(email);
                    }),
                    // settingsItem("Contact us", () {
                    //   String email = appSettingsModel.getString(SUPPORT_EMAIL);
                    //   if (email.isEmpty) return;
                    //   sendEmail(email);
                    // }),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Text(
                        "App Usage",
                        style: textStyle(false, 17, white.withOpacity(.5)),
                      ),
                    ),
                    settingsItem("Privacy policy", () {
                      String link = appSettingsModel.getString(PRIVACY_LINK);
                      if (link.isEmpty) return;
                      openLink(link);
                    }),
                    settingsItem("Terms and conditions", () {
                      String link = appSettingsModel.getString(TERMS_LINK);
                      if (link.isEmpty) return;
                      openLink(link);
                    }),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Text(
                        "Account",
                        style: textStyle(false, 17, white.withOpacity(.5)),
                      ),
                    ),
                    /*settingsItem("Add Account", () {}),*/
                    settingsItem("Logout", () {
                      clickLogout(context);
                    }),
                    addSpace(150),
                  ],
                ),
              )),
        ],
      );
    });
  }

  settingsItemCheck(String title, String text, bool selected, onTapped) {
    return GestureDetector(
      onTap: onTapped,
      child: Container(
        height: 70,
        padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
        color: transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    title,
                    style: textStyle(false, 18, white),
                  ),
                  (text.isEmpty) ? Container() : addSpace(3),
                  (text.isEmpty)
                      ? Container()
                      : Text(
                          text,
                          style: textStyle(false, 12, white.withOpacity(.8)),
                        ),
                ],
              ),
            ),
            addSpace(10),
            new Container(
              //padding: EdgeInsets.all(2),
              child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: blue09,
                    border: Border.all(color: white.withOpacity(.7), width: 1)),
                child: Container(
                  width: 13,
                  height: 13,
                  margin: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? white : transparent,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 8,
                    color: selected ? black : transparent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  settingsItem(String text, onTapped) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        addLine(.5, white.withOpacity(.1), 0, 0, 0, 0),
        new Container(
          width: double.infinity,
          height: 50,
          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: new FlatButton(
              padding: EdgeInsets.fromLTRB(15, 5, 10, 5),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
//side: BorderSide(color: blue0, width: 1)
              ),
//              color: blue09,
              onPressed: onTapped,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  /*Image.asset(
                          ic_world,
                          color: white,
                          width: 14,
                          height: 14,
                        ),
                        addSpaceWidth(10),*/
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: Text(
                      text,
                      style: textStyle(true, 16, white),
                      maxLines: 1,
                    ),
                  ),
                  Center(
                      child: Icon(
                    Icons.navigate_next,
                    color: white.withOpacity(.5),
                    size: 19,
                  )),
                  //addSpaceWidth(5),
                ],
              )),
        ),
      ],
    );
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
