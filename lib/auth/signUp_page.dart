import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:maugost_apps/AppConfig.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/assets.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() {
    return _SignUpState();
  }
}

class _SignUpState extends State<SignUp> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  bool emailInvalid = false;
  bool passwordInvalid = false;
  final focusName = new FocusNode();
  final focusEmail = new FocusNode();
  final focusPassword = new FocusNode();
  BuildContext context;
  bool passwordVisible = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    focusName.requestFocus();
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
        backgroundColor: AppConfig.appColor,
        key: _scaffoldKey,
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
                    Image.asset(
                      "assets/icons/ic_plain.png",
                      height: 80,
                      width: 80,
                    ),
                    addSpace(10),
                    Text("Create Account", style: textStyle(true, 20, white)),
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
                          textbox(nameController, "Name", focusNode: focusName),
                          textbox(
                            emailController,
                            "Email Address",
                            focusNode: focusEmail,
                          ),
                          textbox(passwordController, "Password",
                              focusNode: focusPassword,
                              isPass: true,
                              refresh: () => setState(() {})),
                          Container(
//                            width: double.infinity,
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
                                  signUp();
                                },
                                child: Text(
                                  "SIGN UP",
                                  style: textStyle(true, 16, white),
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),
                  /* Container(
                    width: double.infinity,
                    height: 60,
                    margin: EdgeInsets.all(15),
                    child: FlatButton(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        color: AppConfig.appColor,
                        onPressed: () {
                          signUp();
                        },
                        child: Text(
                          "CREATE ACCOUNT",
                          style: textStyle(true, 16, black),
                        )),
                  )*/
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void signUp() async {
    String name = nameController.text;
    String email = emailController.text.trim();
    String password = passwordController.text;

    emailInvalid = !isEmailValid(email);
    passwordInvalid = password.length < 6;

    if (name.isEmpty) {
      passwordInvalid = false;
      FocusScope.of(context).requestFocus(focusName);
      setState(() {});
      snack("Enter your name");
      return;
    }

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
      snack("Enter your password");
      return;
    }

    if (passwordInvalid) {
      FocusScope.of(context).requestFocus(focusPassword);
      setState(() {});
      snack("Password should be a minimum of 6 characters");
      return;
    }

    startSignUp(name, email, password);
  }

  startSignUp(name, email, password) async {
    var result = await (Connectivity().checkConnectivity());
    if (result == ConnectivityResult.none) {
      snack("No internet connectivity");
      return;
    }

    showProgress(true, context, msg: "Signing Up");
    final FirebaseAuth mAuth = FirebaseAuth.instance;
    mAuth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((value) {
      userModel
        ..put(NAME, name)
        ..put(EMAIL, email)
        ..put(PASSWORD, password)
        ..put(USER_ID, value.user.uid)
        ..put(OBJECT_ID, value.user.uid)
        ..saveItem(USER_BASE, false, document: value.user.uid, onComplete: () {
          showProgress(false, context);
          Future.delayed(Duration(seconds: 1), () {
            isLoggedIn = value.user != null;
            Navigator.pop(context);
          });
        });
    }).catchError((e) {
      handleError(email, password, e);
    });
  }

  handleError(email, password, error) {
    showProgress(false, context);

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
      showSnack(_scaffoldKey, text, useWife: true);
    });
  }
}
