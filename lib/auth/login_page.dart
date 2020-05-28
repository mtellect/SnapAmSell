import 'dart:async';

import 'package:Strokes/AppEngine.dart';
import 'package:Strokes/MainAdmin.dart';
import 'package:Strokes/app_config.dart';
import 'package:Strokes/assets.dart';
import 'package:Strokes/auth/signUp_page.dart';
import 'package:Strokes/basemodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
        backgroundColor: modeColor,
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
                    addSpace(20),
                    Text("Hair Slaya's", style: textStyle(true, 30, white)),
                    Text("Login to Fetish", style: textStyle(true, 14, white)),
                    addSpace(10),
                    Image.asset("assets/icons/ic_launcher.png",
                        height: 50, width: 50),
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
                  Flexible(
                    child: ListView(
                      //mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        textbox(emailController, "Email Address",
                            focusNode: focusEmail),
                        textbox(passwordController, "Password",
                            focusNode: focusPassword,
                            isPass: true,
                            refresh: () => setState(() {})),
                        GestureDetector(
                          onTap: () {
                            pushAndResult(context, ForgotPassword(),
                                depend: false);
                          },
                          child: new Text(
                            "FORGOT PASSWORD?",
                            textAlign: TextAlign.center,
                            style: textStyle(true, 17, black),
                          ),
                        ),
                      ],
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      pushReplacementAndResult(context, SignUp(),
                          depend: false);
                    },
                    child: Center(
                      child: new Text(
                        "CREATE ACCOUNT",
                        style: textStyle(true, 17, black),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 60,
                    margin: EdgeInsets.all(15),
                    child: FlatButton(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        color: AppConfig.appColor,
                        onPressed: () {
                          login();
                        },
                        child: Text(
                          "SIGN IN",
                          style: textStyle(true, 16, white),
                        )),
                  )
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
      setState(() {});
      return;
    }

    if (passwordInvalid) {
      FocusScope.of(context).requestFocus(focusPassword);
      setState(() {});
      snack("Enter your password");
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
