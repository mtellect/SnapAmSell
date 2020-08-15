import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/assets.dart';
import 'package:maugost_apps/auth/signUp_page.dart';
import 'package:maugost_apps/basemodel.dart';

import 'forgot_password.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  bool emailInvalid = false;
  bool passwordInvalid = false;
  FocusNode focusEmail;
  FocusNode focusPassword;
  BuildContext context;
  bool passwordVisible = false;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSignUp = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    focusEmail = new FocusNode();
    focusPassword = new FocusNode();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext cc) {
    return Scaffold(
        backgroundColor: black,
        key: scaffoldKey,
        resizeToAvoidBottomInset: true,
        body: Builder(builder: (c) {
          context = c;
          return page();
        }));
  }

  page() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 40, left: 10),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: CloseButton(
                  color: white,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      "assets/icons/ic_plain.png",
                      height: 80,
                      width: 80,
                      color: white,
                    ),
                    addSpace(20),
                    Text("Login to Fetish", style: textStyle(true, 20, white)),
//                    Text("Login", style: textStyle(true, 14, black.withOpacity(.5))),
                    addSpace(10),
                  ],
                ),
              )
            ],
          ),
        ),
        addSpace(20),
        Flexible(
          //flex: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            child: Container(
              color: white,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        //mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          addSpace(20),
                          textbox(emailController, "Email Address",
                              focusNode: focusEmail),
                          textbox(passwordController, "Password",
                              focusNode: focusPassword,
                              isPass: true,
                              refresh: () => setState(() {})),
                          Container(
                            width: 150,
                            height: 50,
                            margin: EdgeInsets.fromLTRB(15, 5, 15, 10),
                            child: FlatButton(
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25)),
                                color: black,
                                onPressed: () {
                                  login();
                                },
                                child: Text(
                                  "SIGN IN",
                                  style: textStyle(true, 16, white),
                                )),
                          ),
                          Container(
                            height: 30,
                            child: FlatButton(
                              onPressed: () {
                                pushAndResult(context, ForgotPassword(),
                                    depend: false);
                              },
                              color: black.withOpacity(.05),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25)),
                                // side: BorderSide(color: app_green,width: 2)
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                              child: new Text(
                                "Forgot Password",
                                style: textStyle(true, 13, red0),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                            child: RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                    text: "Don't have an account? ",
                                    style: textStyle(false, 14, black)),
                                TextSpan(
                                  text: "Signup",
                                  style: textStyle(true, 15, blue0),
                                  recognizer: new TapGestureRecognizer()
                                    ..onTap = () {
                                      pushReplacementAndResult(
                                          context, SignUp(),
                                          depend: false);
                                    },
                                ),
                              ]),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

//                  Container(
//                    child: FlatButton(
//                      onPressed: () {
//                        pushReplacementAndResult(context, SignUp(),
//                            depend: false);
//                      },
//                      padding: EdgeInsets.all(0),
//                      child: Center(
//                        child: new Text(
//                          "CREATE ACCOUNT",
//                          style: textStyle(true, 13, black),
//                        ),
//                      ),
//                    ),
//                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void login() async {
    String email = emailController.text.trim();
    String password = passwordController.text;

    emailInvalid = !isEmailValid(email);
    passwordInvalid = password.length < 6;
    if (emailInvalid) {
      passwordInvalid = false;
      FocusScope.of(context).requestFocus(focusEmail);
      setState(() {});
      snack("Enter your email address");
      return;
    }

    if (!emailInvalid && password.isEmpty) {
      passwordInvalid = false;
      FocusScope.of(context).requestFocus(focusPassword);
      snack("Enter your password");
      setState(() {});
      return;
    }

    if (passwordInvalid) {
      FocusScope.of(context).requestFocus(focusPassword);
      setState(() {});
      snack("Password should be a minimum of 6 characters");
      return;
    }

    startLogin(email, password);
  }

  void startLogin(email, password) async {
    var result = await (Connectivity().checkConnectivity());
    if (result == ConnectivityResult.none) {
      snack("No internet connectivity");
      return;
    }

    showProgress(true, context, msg: "Signing in");

//    return;
    final FirebaseAuth mAuth = FirebaseAuth.instance;
    mAuth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((user) {
      Firestore.instance
          .collection(USER_BASE)
          .document(user.user.uid)
          .get()
          .then((shot) {
        userModel = BaseModel(doc: shot);
        showProgress(false, context);
        Future.delayed(Duration(seconds: 1), () {
          isLoggedIn = user != null;
          Navigator.pop(context);
        });
      }).catchError((error) {
        showProgress(false, context);
        snack(error.toString());
      });
    }).catchError((e) {
      handleError(email, password, e);
    });
  }

  handleError(email, password, error) {
    showProgress(false, context);

    if (error.toString().toLowerCase().contains("no user")) {
      snack("No user found");
      FocusScope.of(context).requestFocus(focusEmail);
      return;
    }

    if (error.toString().toLowerCase().contains("badly formatted")) {
      snack("Invalid email address/password");
      FocusScope.of(context).requestFocus(focusEmail);
      return;
    }

    if (error.toString().toLowerCase().contains("password is invalid")) {
      snack("Invalid email address/password");
      FocusScope.of(context).requestFocus(focusPassword);
      return;
    }
    snack("Error occurred, try again");
  }

  final String progressId = getRandomId();

  bool isEmailValid(String email) {
    if (!email.contains("@") || !email.contains(".")) return false;
    return true;
  }

  snack(String text) {
    Future.delayed(Duration(milliseconds: 500), () {
      showSnack(scaffoldKey, text, useWife: true);
    });
  }
}
