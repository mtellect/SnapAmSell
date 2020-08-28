import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:line_icons/line_icons.dart';
import 'package:maugost_apps/auth/signUp_page.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'AppConfig.dart';
import 'AppEngine.dart';
import 'assets.dart';
import 'auth/login_page.dart';
import 'basemodel.dart';

class PreAuth extends StatefulWidget {
  final bool forceSignUp;
  const PreAuth({Key key, this.forceSignUp = false}) : super(key: key);
  @override
  _PreAuthState createState() => _PreAuthState();
}

class _PreAuthState extends State<PreAuth> {
  bool forceSignUp = false;

  @override
  void initState() {
    super.initState();
    forceSignUp = widget.forceSignUp;
  }

  @override
  Widget build(BuildContext context) {
    return page();
  }

  page() {
    return Material(
      color: black.withOpacity(.1),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              color: black.withOpacity(.4),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.only(top: 80),
              decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(25),
                    topLeft: Radius.circular(25),
                  )),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.only(top: 10, right: 15, left: 15),
                      child: Row(
                        children: [
                          CloseButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          Spacer(),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(LineIcons.question_circle),
                          )
                        ],
                      )),
                  //addSpace(10),
                  authItem(forceSignUp ? 1 : 0),
                  Container(
                    padding: EdgeInsets.all(15),
                    height: 100,
                    alignment: Alignment.center,
                    child: forceSignUp
                        ? null
                        : Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                    text: 'By Clicking on ',
                                    style: textStyle(
                                        false, 13, black.withOpacity(.6))),
                                TextSpan(
                                    text: '"CONTINUE WITH", ',
                                    style: textStyle(true, 13, black)),
                                TextSpan(
                                    text: 'You hereby agree to our ',
                                    style: textStyle(
                                        false, 13, black.withOpacity(.6))),
                                TextSpan(
                                    text: 'Terms of Service',
                                    recognizer: new TapGestureRecognizer()
                                      ..onTap = () => openLink(appSettingsModel
                                          .getString(TERMS_LINK)),
                                    style: textStyle(true, 14, black,
                                        underlined: true)),
                                TextSpan(
                                    text: ' and ',
                                    style: textStyle(
                                        false, 13, black.withOpacity(.6))),
                                TextSpan(
                                    text: 'Privacy Policy',
                                    recognizer: new TapGestureRecognizer()
                                      ..onTap = () => openLink(appSettingsModel
                                          .getString(PRIVACY_LINK)),
                                    style: textStyle(true, 13, black,
                                        underlined: true)),
                                TextSpan(
                                    text: ' Binding our community.',
                                    style: textStyle(
                                        false, 13, black.withOpacity(.6))),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                  ),
                  GestureDetector(
                    onTap: () {
                      forceSignUp = !forceSignUp;
                      setState(() {});
                    },
                    child: Container(
                      padding: EdgeInsets.all(24),
                      color: black.withOpacity(.03),
                      alignment: Alignment.center,
                      child: Text.rich(TextSpan(children: [
                        TextSpan(
                          text: forceSignUp
                              ? "Don't have an account? "
                              : "Already have an account? ",
                          style: textStyle(false, 16, black),
                        ),
                        TextSpan(
                          text: forceSignUp ? "Sign up" : "Login",
                          style: textStyle(true, 16, red),
                        )
                      ])),
                    ),
                  )
                ],
              ),
            ),
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
        // print("hmmm $account");
        // if (null == account) {
        //   onError("Error 02", "Cancelled by user");
        //   return;
        // }
        account.authentication.then((googleAuth) {
          final credential = GoogleAuthProvider.getCredential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          print(credential.providerId);
          if (null != credential) loginIntoApp(credential);
        }).catchError((e) {
          onError("Error 001", e);
        });
      }).catchError((e) {
        onError("Error 01", e);
      });
    }

    if (type == "facebook") {
      FacebookLogin().logIn(permissions: [
        FacebookPermission.publicProfile,
        FacebookPermission.email,
      ]).then((account) {
        final credential = FacebookAuthProvider.getCredential(
          accessToken: account.accessToken.token,
        );
        if (null != credential) loginIntoApp(credential);
      }).catchError((e) {
        onError("Error 02", e);
      });
    }

    if (type == "apple") {
      SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      ).then((value) {
        final credential = OAuthProvider(providerId: 'apple.com').getCredential(
          accessToken: value.authorizationCode,
          idToken: value.identityToken,
        );

        if (null != credential) loginIntoApp(credential);
      }).catchError((e) {
        onError("Error 04", e);
      });
    }
  }

  loginIntoApp(
    AuthCredential credential, {
    String email,
    String pass,
  }) async {
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
      print("here....");
      if (value == null) return;
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
            ..saveItem(USER_BASE, false, document: account.uid);
        } else {
          userModel = BaseModel(doc: doc);
          isLoggedIn = true;
        }
        showProgress(false, context);
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pop(context);
        });
      }).catchError((e) {
        onError("Error 04", e);
      });
    }).catchError((e) {
      onError("Error 03", e);
    });
  }

  onError(String type, e) {
    showProgress(false, context);
    showMessage(context, Icons.error, red0, type, e.toString(),
        delayInMilli: 1200, cancellable: true);
  }

  authItem(int p) {
    String headerText = "Sign up for Fetish!";
    String description =
        "Create a profile, Post,Buy and Sell. Be your own Boss...!";

    if (p == 1) {
      headerText = "Log in to Fetish!";
      description =
          "Manage your account, check notifications, offers,orders and more...!";
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.only(left: 40, right: 40, bottom: 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                headerText,
                style: textStyle(true, 25, black),
              ),
              addSpace(10),
              Text(
                description,
                textAlign: TextAlign.center,
                style: textStyle(false, 16, black.withOpacity(.5)),
              ),
              addSpace(10),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 20, right: 20),
          //width: 160,
          child: FlatButton(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              //mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LineIcons.user,
                  color: white,
                ),
                addSpaceWidth(5),
                Text('CONTINUE WITH EMAIL', style: textStyle(true, 14, white)),
              ],
            ),
            onPressed: () {
              pushAndResult(
                context,
                forceSignUp ? SignUp() : LoginPage(),
              );
            },
            padding: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
                //side: BorderSide(color: white.withOpacity(.4), width: 2),
                borderRadius: BorderRadius.circular(8)),
            color: AppConfig.appColor,
          ),
        ),
        addSpace(10),
        if (Platform.isIOS) ...[
          Container(
            padding: EdgeInsets.only(left: 20, right: 20),
            //width: 160,
            child: FlatButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                //mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    "assets/icons/apple.png",
                    height: 20,
                    width: 20,
                    color: white,
                  ),
                  addSpaceWidth(5),
                  Text('CONTINUE WITH APPLE',
                      style: textStyle(true, 14, white)),
                ],
              ),
              onPressed: () {
                handleSignIn("apple");
              },
              padding: EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                  //side: BorderSide(color: white.withOpacity(.4), width: 2),
                  borderRadius: BorderRadius.circular(8)),
              color: black,
            ),
          ),
          addSpace(10),
        ],
        Container(
          padding:
              EdgeInsets.only(left: 20, right: 20), //width: double.infinity,
          child: FlatButton(
            color: white,
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
                    'CONTINUE WITH GOOGLE',
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
                side: BorderSide(color: black.withOpacity(0.5), width: 1),
                borderRadius: BorderRadius.circular(8)),
            //color: Color(0xFFf4c20d),
          ),
        ),
        addSpace(10),
        Container(
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
                Text('CONTINUE WITH FACEBOOK',
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
      ],
    );
  }
}
