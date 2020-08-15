import 'dart:io';
import 'dart:io' as io;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/assets.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:video_player/video_player.dart';

import 'MainAdmin.dart';
import 'app/navigation.dart';
import 'AppConfig.dart';
import 'auth/auth_main.dart';
import 'auth/login_page.dart';
import 'basemodel.dart';

bool isWife = false;

class PreInit extends StatefulWidget {
  @override
  _PreInitState createState() => _PreInitState();
}

class _PreInitState extends State<PreInit> {
  VideoPlayerController controller;
  final panelController = PanelController();
  bool isPanelOpen = false;

  @override
  void initState() {
    super.initState();
    loadVideo();
  }

  bool hasSetup = false;
  loadVideo() async {
    // File file = await loadFile('assets/icons/intro.mp4', "intro.mp4");
    File file = await loadFile('assets/videos/intro.mp4', "intro.mp4");
    controller = VideoPlayerController.file(file)
      ..initialize().then((value) {
        controller.setLooping(true);
        controller.play();
        controller.setVolume(0);
        hasSetup = true;
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );

    return WillPopScope(
      onWillPop: () {
        io.exit(0);
        return;
      },
      child: Scaffold(
          backgroundColor: blue5,
          body: SlidingUpPanel(
            body: Stack(fit: StackFit.expand, children: [
              if (hasSetup)
                AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: VideoPlayer(controller)),
              Container(color: black.withOpacity(.5)),
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Strock", style: textStyle(true, 14, white)),
                    Text("Imagine a world of infinite dating...",
                        style: textStyle(true, 30, white)),
                  ],
                ),
              ),
              Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    padding: EdgeInsets.only(top: 40, left: 10),
                    child: Image.asset("assets/icons/ic_launcher.png",
                        height: 50, width: 50),
                  ))
            ]),
            borderRadius: radius,
            panel: page(),
            minHeight: 60,
            maxHeight: 340,
            controller: panelController,
            backdropEnabled: true,
            onPanelClosed: () {
              setState(() {
                isPanelOpen = false;
              });
              FocusScope.of(context).requestFocus(FocusNode());
            },
            onPanelOpened: () {
              setState(() {
                isPanelOpen = true;
              });
            },
          )),
    );
  }

  page() {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FlatButton(
            onPressed: () {
              if (isPanelOpen) {
                panelController.close();
              } else {
                panelController.open();
              }
            },
            color: blue5.withOpacity(.1),
            child: Center(
                child:
                    Icon(isPanelOpen ? Icons.keyboard_arrow_down : Icons.lock)),
            padding: EdgeInsets.all(20),
          ),
          Column(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                //alignment: Alignment.centerLeft,
                child: Text(
                  "Get Started Today!",
                  style: textStyle(true, 18, black),
                ),
              ),
              addSpace(10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      //width: 160,
                      child: FlatButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          //mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              "assets/icons/ic_launcher.png",
                              height: 20,
                              width: 20,
                              //color: white,
                            ),
                            addSpaceWidth(5),
                            Text('LOGIN WITH EMAIL',
                                style: textStyle(true, 14, white)),
                          ],
                        ),
                        onPressed: () {
                          panelController.close();
                          pushAndResult(context, LoginPage(), depend: false);
                        },
                        padding: EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                            //side: BorderSide(color: white.withOpacity(.4), width: 2),
                            borderRadius: BorderRadius.circular(8)),
                        color: AppConfig.appColor,
                      ),
                    ),
                  ),
                  Container(padding: EdgeInsets.all(10), child: Text("OR")),
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.only(
                          left: 20, right: 20), //width: double.infinity,
                      child: FlatButton(
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                "assets/icons/google.png",
                                height: 20,
                                width: 20,
                                //color: white,
                              ),
                              addSpaceWidth(5),
                              Text(
                                'LOGIN WITH GOOGLE',
                                style: textStyle(true, 14, black),
                              ),
                            ],
                          ),
                        ),
                        onPressed: () {
                          handleSignIn("google");
                        },
                        padding: EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: black.withOpacity(0.5), width: 1),
                            borderRadius: BorderRadius.circular(8)),
                        //color: Color(0xFFf4c20d),
                      ),
                    ),
                  ),
                  addSpace(10),
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      //width: 160,
                      child: FlatButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          //mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              "assets/icons/facebook.png",
                              height: 20,
                              width: 20,
                              color: white,
                            ),
                            addSpaceWidth(5),
                            Text('LOGIN WITH FACEBOOK',
                                style: textStyle(true, 14, white)),
                          ],
                        ),
                        onPressed: () {
                          handleSignIn("facebook");
                        },
                        padding: EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                            //side: BorderSide(color: white.withOpacity(.4), width: 2),
                            borderRadius: BorderRadius.circular(8)),
                        color: Color(0xFF4267B2),
                      ),
                    ),
                  ),
                  //addSpace(10),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  handleSignIn(String type) async {
    showProgress(true, context, msg: "Loggin In");
    if (type == "google") {
      GoogleSignIn googleSignIn = GoogleSignIn();
      googleSignIn.signIn().then((account) async {
        account.authentication.then((googleAuth) {
          final credential = GoogleAuthProvider.getCredential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          loginIntoApp(credential);
        }).catchError((e) {
          onError("Error 001", e);
        });
      }).catchError((e) {
        onError("Error 01", e);
      });
    }

    if (type == "facebook") {
      FacebookAuth.instance.login().then((account) {
        final credential = FacebookAuthProvider.getCredential(
          accessToken: account.accessToken.token,
        );
        loginIntoApp(credential);
      }).catchError((e) {
        onError("Error 02", e);
      });
    }
  }

  loginIntoApp(AuthCredential credential) async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    String deviceId;
    if (Platform.isIOS) {
      final deviceInfo = await deviceInfoPlugin.iosInfo;
      deviceId = deviceInfo.identifierForVendor;
    } else {
      final deviceInfo = await deviceInfoPlugin.androidInfo;
      deviceId = deviceInfo.androidId;
    }

    FirebaseAuth.instance.signInWithCredential(credential).then((value) {
      final account = value.user;

      Firestore.instance
          .collection(USER_BASE)
          .document(account.uid)
          .get()
          .then((doc) {
        if (!doc.exists) {
          userModel
            ..put(USER_ID, account.uid)
            ..put(EMAIL, account.email)
            ..put(USER_IMAGE, account.photoUrl)
            ..put(NAME, account.displayName)
            ..putInList(DEVICE_ID, deviceId, true)
            ..saveItem(USER_BASE, false, document: account.uid, onComplete: () {
              pushAndResult(context, AuthMain());
            });
          return;
        }
        userModel = BaseModel(doc: doc);
        if (!userModel.signUpCompleted) {
          popUpUntil(context, AuthMain());
          return;
        }
        popUpUntil(context, MainAdmin());
      }).catchError((e) {
        onError("Error 04", e);
      });
    }).catchError((e) {
      onError("Error 03", e);
    });
  }

  onError(String type, e) {
    showProgress(false, context);
    showMessage(context, Icons.error, red0, type, e?.message,
        delayInMilli: 950, cancellable: true);
  }
}
