import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:maugost_apps/MainAdmin.dart';
import 'package:maugost_apps/app/navigation.dart';
import 'package:maugost_apps/assets.dart';
import 'package:maugost_apps/basemodel.dart';

import 'AppConfig.dart';
import 'AppEngine.dart';
import 'MainAdminWeb.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // ui.platformViewRegistry.registerViewFactory(
    //     'hello-world-html',
    //     (int viewId) => IFrameElement()
    //       ..width = '640'
    //       ..height = '360'
    //       ..src = 'https://www.youtube.com/embed/IyFZznAk69U'
    //       ..style.border = 'none');
  } else {
    try {
      cameras = await availableCameras();
    } on CameraException catch (e) {
//    logError(e.code, e.description);
    }
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  //FirebaseAnalytics analytics = FirebaseAnalytics();
  @override
  Widget build(BuildContext c) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppConfig.appName,
        color: white,
        theme: ThemeData(
          fontFamily: 'Averta',
          primaryColor: black,
          pageTransitionsTheme: PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
              TargetPlatform.iOS: createTransition(),
              TargetPlatform.android: createTransition(),
            },
          ),
        ),
        navigatorObservers: [],
        home: kIsWeb ? MainAdminWeb() : MainAdmin());
  }

  PageTransitionsBuilder createTransition() {
    return ZoomPageTransitionsBuilder();
  }
}

class MainHome extends StatefulWidget {
  @override
  _MainHomeState createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  @override
  void initState() {
    // TODO: implement initState
    checkUser();
    loadSettings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loadingLayout();
  }

  checkUser() async {
    // FirebaseAuth.instance.signOut();
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    isLoggedIn = user != null;
    if (isLoggedIn) {
      loadLocalUser(user.uid, onInComplete: () {}, onLoaded: () {});
    }
//    popUpUntil(context, LoginPage());
//    return;
    popUpUntil(context, MainAdmin());
  }

  loadSettings() {
    Firestore.instance
        .collection(APP_SETTINGS_BASE)
        .document(APP_SETTINGS)
        .get(/*source: Source.cache*/)
        .then((doc) {
      if (!doc.exists) {
        appSettingsModel = new BaseModel();
        appSettingsModel.saveItem(APP_SETTINGS_BASE, false,
            document: APP_SETTINGS);
        return;
      }
      appSettingsModel = BaseModel(doc: doc);
    }).catchError((e) {});
  }

  loadLocalUser(String userId, {onLoaded, onInComplete}) {
    Firestore.instance
        .collection(USER_BASE)
        .document(userId)
        .get()
        .then((doc) async {
      userModel = BaseModel(doc: doc);
      isAdmin = userModel.getBoolean(IS_ADMIN) ||
          userModel.getString(EMAIL) == "johnebere58@gmail.com" ||
          userModel.getString(EMAIL) == "ammaugost@gmail.com";
      /* if (!userModel.signUpCompleted || !doc.exists) {
        await GoogleSignIn().signOut();
        await FacebookAuth.instance.logOut();
        await FirebaseAuth.instance.signOut();
        userModel = BaseModel();
        onInComplete();
        return;
      }*/
      onLoaded();
    }).catchError((e) {
      //popUpUntil(context, PreInit());
    });
  }
}
