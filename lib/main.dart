import 'dart:async';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:maugost_apps/MainAdmin.dart';
import 'package:maugost_apps/app/navigation.dart';
import 'package:maugost_apps/assets.dart';
import 'package:maugost_apps/basemodel.dart';
import 'package:rxdart/subjects.dart';

import 'AppEngine.dart';
import 'app/app.dart';

RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

final galleryController = StreamController<List<String>>.broadcast();
final galleryResultController = StreamController<List<dynamic>>.broadcast();

void main() async {
//  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  WidgetsFlutterBinding.ensureInitialized();
  // NOTE: if you want to find out if the app was launched via notification then you could use the following call and then do something like
  // change the default route of the app
  // var notificationAppLaunchDetails =
  //     await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
//    logError(e.code, e.description);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  FirebaseAnalytics analytics = FirebaseAnalytics();
  @override
  Widget build(BuildContext c) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Fetish",
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
        navigatorObservers: [
          routeObserver,
          FirebaseAnalyticsObserver(analytics: analytics)
        ],
        home: MainHome());
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
