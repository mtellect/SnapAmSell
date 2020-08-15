import 'dart:async';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:maugost_apps/MainAdmin.dart';
import 'package:maugost_apps/app/navigation.dart';
import 'package:maugost_apps/assets.dart';
import 'package:maugost_apps/basemodel.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/subjects.dart';

import 'AppEngine.dart';
import 'ChatMain.dart';
import 'app/app.dart';
import 'photo/photo_provider.dart';

RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

//FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Streams are created so that app can respond to notification-related events since the plugin is initialised in the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

final galleryController = StreamController<List<String>>.broadcast();
final galleryResultController = StreamController<List<dynamic>>.broadcast();

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification(
      {@required this.id,
      @required this.title,
      @required this.body,
      @required this.payload});
}

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
  InAppPurchaseConnection.enablePendingPurchases();
  runApp(ChangeNotifierProvider<PhotoProvider>.value(
    value: provider,
    child: MyApp(),
  ));
}

final provider = PhotoProvider();

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

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
          primaryColor: white,
          pageTransitionsTheme: PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
              TargetPlatform.iOS: createTransition(),
              TargetPlatform.android: createTransition(),
            },
          ),
        ), //Futura//Nirmala
        navigatorObservers: [
          routeObserver,
          FirebaseAnalyticsObserver(analytics: analytics)
        ],
        home: MainHome()
        // PostAd(),
        );
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

    loadNotify();
    checkUser();
    loadSettings();
//    EmailService.send();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loadingLayout();
  }

  loadNotify() async {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notify');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification:
            (int id, String title, String body, String payload) async {
      didReceiveLocalNotificationSubject.add(ReceivedNotification(
          id: id, title: title, body: body, payload: payload));
    });
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
      if (payload != null) {
        debugPrint('notification payload: ' + payload);
        pushAndResult(
            context,
            ChatMain(
              payload,
              otherPerson: null,
            ));
      }
      selectNotificationSubject.add(payload);
    });
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
