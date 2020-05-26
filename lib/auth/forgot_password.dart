
import 'package:Strokes/AppEngine.dart';
import 'package:Strokes/app/navigation.dart';
import 'package:Strokes/app_config.dart';
import 'package:Strokes/assets.dart';
import 'package:Strokes/preinit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';



class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() {
    return _ForgotPasswordState();
  }
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController emailController;
  bool emailInvalid = false;
  FocusNode focusEmail;
  BuildContext context;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    focusEmail = new FocusNode();
    emailController = new TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    emailController.dispose();
  }

  @override
  Widget build(BuildContext cc) {
    return WillPopScope(
      onWillPop: () async {
        popUpUntil(context, PreInit());
        return false;
      },
      child: Scaffold(
          backgroundColor: white,
          key: _scaffoldKey,
          resizeToAvoidBottomPadding: true,
          body: Builder(builder: (c) {
            context = c;
            return page();
          })),
    );
  }

  page() {
    return Column(
      children: <Widget>[
        Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: EdgeInsets.only(top: 40, left: 10),
              child: Row(
                children: [
                  BackButton(
                    color: black,
                    onPressed: () {
                      popUpUntil(context, PreInit());
                    },
                  ),
                  Text("Reset Password",
                      style: textStyle(true, 22, black)),
                ],
              ),
            )),
        Image.asset("assets/icons/ic_launcher.png", height: 50, width: 50),
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 50,
                ),
                textbox(emailController, "Email Address",
                    focusNode: focusEmail),
                addSpace(10),
                Container(
                  margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: tipBox(
                      blue2,
                      "A link will be emailed to, follow the link to reset your password",
                      white),
                ),
                addSpace(50),
                /*new Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: SizedBox(
                        width: double.infinity,
                      ),
                    ),
                    bigButton(50, 120, "RESET", blue0, white, () {
                      //Toast(password);
                      findUser();
                    }),
                  ],
                ),*/
                /*bigButton(50, double.infinity, "RESET", white, blue0, () {
                  //Toast(password);
                  findUser();
                }),*/
              ],
            ),
          ),
        ),
        Container(
          width: double.infinity,
          height: 60,
          margin: EdgeInsets.all(0),
          child: FlatButton(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0)),
              color: AppConfig.appColor,
              onPressed: () {
                findUser();
              },
              child: Text(
                "RESET",
                style: textStyle(true, 16, white),
              )),
        )
      ],
    );
  }

  void findUser() async {
    String email = emailController.text.trim();

    emailInvalid = !isEmailValid(email);
    if (emailInvalid) {
      FocusScope.of(context).requestFocus(focusEmail);
      snack("Enter your email address");
      setState(() {});
      return;
    }

    var result = await (Connectivity().checkConnectivity());
    if (result == ConnectivityResult.none) {
      snack("No internet connectivity");
      return;
    }

    showProgress(true, context, msg: "Finding Account");

    Firestore.instance
        .collection(USER_BASE)
        .where(EMAIL, isEqualTo: email.toLowerCase().trim())
        .getDocuments()
        .then((shots) {
      showProgress(false, context);
      if (shots.documents.isEmpty) {
        snack("No account with $email was found");
        return;
      }

      FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      showMessage(context, Icons.check, blue0, "Link Sent",
          "A link has been emailed to you, follow the link to reset your password",
          onClicked: (_) {
        popUpUntil(context, PreInit());
      }, delayInMilli: 1000);
    }).catchError((error) {
      showProgress(false, context);
      snack(error.toString());
    });
  }

  snack(String text) {
    showSnack(_scaffoldKey, text);
  }

  final String progressId = getRandomId();
}
