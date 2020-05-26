import 'dart:async';
import 'dart:io';
import 'dart:io' as io;
import 'dart:ui';

import 'package:Strokes/assets.dart';
import 'package:Strokes/auth/login_page.dart';
import 'package:Strokes/basemodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';

import 'AppEngine.dart';
import 'ChatMain.dart';
import 'ReportMain.dart';
import 'app_config.dart';
import 'main_pages/Chat.dart';
import 'main_pages/Home.dart';
import 'main_pages/Offer.dart';
import 'main_pages/SellCamera.dart';

Map<String, List> unreadCounter = Map();
Map otherPeronInfo = Map();
List<BaseModel> allStoryList = new List();
final firebaseMessaging = FirebaseMessaging();
final chatMessageController = StreamController<bool>.broadcast();
final homeRefreshController = StreamController<bool>.broadcast();
final pageSubController = StreamController<int>.broadcast();
final overlayController = StreamController<bool>.broadcast();
final subscriptionController = StreamController<bool>.broadcast();
final adsController = StreamController<bool>.broadcast();

final uploadingController = StreamController<String>.broadcast();
final progressController = StreamController<bool>.broadcast();
final productController = StreamController<BaseModel>.broadcast();

List connectCount = [];
List<String> stopListening = List();
List<BaseModel> lastMessages = List();
bool chatSetup = false;
List showNewMessageDot = [];
bool showNewNotifyDot = false;
List newStoryIds = [];
String visibleChatId;
bool itemsLoaded = false;
List hookupList = [];
bool strockSetup = false;

List matches = [];
bool matchSetup = false;

Location location = new Location();
GeoFirePoint myLocation;

bool serviceEnabled = false;
PermissionStatus permissionGranted;
LocationData locationData;

List<BaseModel> adsList = [];
bool adsSetup = false;

List<BaseModel> productLists = [];
bool productSetup = false;

var notificationsPlugin = FlutterLocalNotificationsPlugin();

class MainAdmin extends StatefulWidget {
  @override
  _MainAdminState createState() => _MainAdminState();
}

class _MainAdminState extends State<MainAdmin>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  PageController peoplePageController = PageController();
  List<StreamSubscription> subs = List();
  int timeOnline = 0;
  String noInternetText = "";

  String flashText = "";
  bool setup = false;
  bool settingsLoaded = false;
  String uploadingText;
  int peopleCurrentPage = 0;
  bool tipHandled = false;
  bool tipShown = true;

  bool posting = false;
  bool hasPosted = false;
  double progress = 0.0;

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    for (var sub in subs) {
      sub.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    itemsLoaded = false;
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(Duration(seconds: 1), () {
      createUserListener();
    });
    var sub1 = progressController.stream.listen((show) {
      setState(() {
        posting = show;
      });
    });

    var sub2 = uploadingController.stream.listen((text) {
      setState(() {
        uploadingText = text;
      });
//      Future.delayed(Duration(seconds: 2), () {
//        setState(() {
//          hasPosted = false;
//        });
//      });
    });

    var sub3 = productController.stream.listen((model) {
      uploadingController.add("Uploading Product");
      progressController.add(true);
      final images = model.images;
      List<BaseModel> uploadModels = [];
      saveProducts(images, uploadModels, (_) {
        model
          ..put(IMAGES, _.map((e) => e.items).toList())
          ..updateItems();
      });
    });

    subs.add(sub1);
    subs.add(sub2);
    subs.add(sub3);
  }

  saveProducts(List<BaseModel> models, List<BaseModel> modelsUploaded,
      onCompleted(List<BaseModel> _)) async {
    if (models.isEmpty) {
      uploadingController.add("Uploading Successful");
      Future.delayed(Duration(seconds: 1), () {
        uploadingController.add(null);
        progressController.add(false);
        onCompleted(modelsUploaded);
      });
      return;
    }
    Future.delayed(Duration(seconds: 1), () {
      uploadingController.add(null);
    });
    BaseModel model = models[0];
    File file = File(model.getString(IMAGE_PATH));
    uploadFile(file, (res, error) {
      if (error != null) {
        saveProducts(models, modelsUploaded, onCompleted);
        return;
      }
      model.put(IMAGE_PATH, "");
      model.put(IMAGE_URL, res);
      modelsUploaded.add(model);
      models.removeAt(0);
      saveProducts(models, modelsUploaded, onCompleted);
    });
  }

  checkTip() {
    if (!tipHandled &&
        peopleCurrentPage != hookupList.length - 1 &&
        hookupList.length > 1) {
      tipHandled = true;
      Future.delayed(Duration(seconds: 1), () async {
        SharedPreferences pref = await SharedPreferences.getInstance();
        tipShown = pref.getBool("swipe_tipx") ?? false;
        if (!tipShown) {
          pref.setBool("swipe_tipx", true);
          setState(() {});
        }
      });
    }
  }

  okLayout(bool manually) {
    checkTip();
    itemsLoaded = true;
    if (mounted) setState(() {});
    Future.delayed(Duration(milliseconds: 1000), () {
//      if(manually)pageScrollController.add(-1);
      if (manually) peoplePageController.jumpToPage(peopleCurrentPage);
    });
  }

  Future<int> getSeenCount(String id) async {
    var pref = await SharedPreferences.getInstance();
    List<String> list = pref.getStringList(SHOWN) ?? [];
    int index = list.indexWhere((s) => s.contains(id));
    if (index != -1) {
      String item = list[index];
//      print(item);
      var parts = item.split(SPACE);
      int seenCount = int.parse(parts[1].trim());
      return seenCount;
    }
    return 0;
  }

  void createUserListener() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user != null) {
      var userSub = Firestore.instance
          .collection(USER_BASE)
          .document(user.uid)
          .snapshots()
          .listen((shot) async {
        if (shot != null) {
          FirebaseUser user = await FirebaseAuth.instance.currentUser();
          if (user == null) return;

          userModel = BaseModel(doc: shot);
          isAdmin = userModel.getBoolean(IS_ADMIN) ||
              userModel.getString(EMAIL) == "johnebere58@gmail.com" ||
              userModel.getString(EMAIL) == "ammaugost@gmail.com";
          loadBlocked();

          if (!settingsLoaded) {
            settingsLoaded = true;
            loadSettings();
          }
        }
      });
      subs.add(userSub);
    }
  }

  loadSettings() async {
    var settingsSub = Firestore.instance
        .collection(APP_SETTINGS_BASE)
        .document(APP_SETTINGS)
        .snapshots()
        .listen((shot) {
      if (shot != null) {
        appSettingsModel = BaseModel(doc: shot);
        List banned = appSettingsModel.getList(BANNED);
        if (banned.contains(userModel.getObjectId()) ||
            banned.contains(userModel.getString(DEVICE_ID)) ||
            banned.contains(userModel.getEmail())) {
          io.exit(0);
        }

        String genMessage = appSettingsModel.getString(GEN_MESSAGE);
        int genMessageTime = appSettingsModel.getInt(GEN_MESSAGE_TIME);

        if (userModel.getInt(GEN_MESSAGE_TIME) != genMessageTime &&
            genMessageTime > userModel.getTime()) {
          userModel.put(GEN_MESSAGE_TIME, genMessageTime);
          userModel.updateItems();

          String title = !genMessage.contains("+")
              ? "Announcement!"
              : genMessage.split("+")[0].trim();
          String message = !genMessage.contains("+")
              ? genMessage
              : genMessage.split("+")[1].trim();
          showMessage(context, Icons.info, blue0, title, message);
        }

        if (!setup) {
          setup = true;
          blockedIds.addAll(userModel.getList(BLOCKED));
          onResume();
          //loadItems();
          loadNotification();
          loadMessages();
          loadProducts();
          setupPush();

          loadBlocked();
          loadStory();
          updatePackage();
          chkUpdate();
          setUpLocation();
        }
      }
    });
    subs.add(settingsSub);
  }

  chkUpdate() async {
    int version = appSettingsModel.getInt(VERSION_CODE);
    PackageInfo pack = await PackageInfo.fromPlatform();
    String v = pack.buildNumber;
    int myVersion = int.parse(v);
    if (myVersion < version) {
      pushAndResult(context, UpdateLayout(), opaque: false);
    }
  }

  handleMessage(var message) async {
    final dynamic data = Platform.isAndroid ? message['data'] : message;
    BaseModel model = BaseModel(items: data);
    String title = model.getString("title");
    String body = model.getString("message");

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'strock.maugost.nt', 'Maugost', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await notificationsPlugin.show(0, title, body, platformChannelSpecifics,
        payload: 'item x');

    if (data != null) {
      String type = data[TYPE];
      String id = data[OBJECT_ID];
      if (type != null) {
        if (type == PUSH_TYPE_CHAT && visibleChatId != id) {
          pushAndResult(
              context,
              ChatMain(
                id,
                otherPerson: null,
              ));
        }
      }
    }
  }

  setUpLocation() async {
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    locationData = await location.getLocation();
    Geoflutterfire geo = Geoflutterfire();

    myLocation = geo.point(
        latitude: locationData.latitude, longitude: locationData.longitude);
    final placeMark = await Geolocator()
        .placemarkFromCoordinates(myLocation.latitude, myLocation.longitude);

    if (!isLoggedIn) return;
    userModel
      ..put(POSITION, myLocation.data)
      ..put(MY_LOCATION, placeMark[0].name)
      ..put(COUNTRY, placeMark[0].country)
      ..put(COUNTRY_CODE, placeMark[0].isoCountryCode)
      ..updateItems();
  }

  setupPush() async {
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        //handleMessage(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        handleMessage(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        handleMessage(message);
      },
    );
    firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    if (userModel.isAdminItem()) {
      firebaseMessaging.subscribeToTopic('admin');
    }

    firebaseMessaging.subscribeToTopic('all');
    firebaseMessaging.getToken().then((String token) async {
      List myTopics = List.from(userModel.getList(TOPICS));

      if (userModel.isAdminItem() && !myTopics.contains('admin')) {
        myTopics.add('admin');
      }
      if (!myTopics.contains('all')) myTopics.add('all');

      userModel.put(TOPICS, myTopics);
      userModel.put(TOKEN, token);
      userModel.updateItems();
    });

    //local notifications

    notificationsPlugin = FlutterLocalNotificationsPlugin();
    var androidSettings = AndroidInitializationSettings('ic_notify');
    var iosSettings = IOSInitializationSettings(
        requestSoundPermission: false,
        requestBadgePermission: false,
        requestAlertPermission: false,
        onDidReceiveLocalNotification:
            (int id, String title, String body, String payload) async {
          print(payload);
        });

    var initializationSettings =
        InitializationSettings(androidSettings, iosSettings);
    await notificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {});

    if (Platform.isIOS) {
      var result = await notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      print("Permission result $result");
    }
  }

  void onPause() {
    if (userModel == null) return;
    int prevTimeOnline = userModel.getInt(TIME_ONLINE);
    int timeActive = (DateTime.now().millisecondsSinceEpoch) - timeOnline;
    int newTimeOnline = timeActive + prevTimeOnline;
    userModel.put(IS_ONLINE, false);
    userModel.put(TIME_ONLINE, newTimeOnline);
    userModel.updateItems();
    timeOnline = 0;
  }

  void onResume() async {
    if (userModel == null) return;

    timeOnline = DateTime.now().millisecondsSinceEpoch;
    userModel.put(IS_ONLINE, true);
    userModel.put(
        PLATFORM, Platform.isAndroid ? ANDROID : Platform.isIOS ? IOS : WEB);
    if (!userModel.getBoolean(NEW_APP)) {
      userModel.put(NEW_APP, true);
    }
    userModel.updateItems();

    Future.delayed(Duration(seconds: 2), () {
      setUpLocation();
      checkLaunch();
    });
  }

  Future<void> checkLaunch() async {
    const platform = const MethodChannel("channel.john");
    try {
      Map response = await platform
          .invokeMethod('launch', <String, String>{'message': ""});
      int type = response[TYPE];
      String chatId = response[CHAT_ID];

//      toastInAndroid(type.toString());
//      toastInAndroid(chatId);

      if (type == LAUNCH_CHAT) {
        pushAndResult(
            context,
            ChatMain(
              chatId,
              otherPerson: null,
            ));
      }

      if (type == LAUNCH_REPORTS) {
        pushAndResult(context, ReportMain());
      }

      //toastInAndroid(response);
    } catch (e) {
      //toastInAndroid(e.toString());
      //batteryLevel = "Failed to get what he said: '${e.message}'.";
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    if (state == AppLifecycleState.paused) {
      onPause();
    }
    if (state == AppLifecycleState.resumed) {
      onResume();
    }

    super.didChangeAppLifecycleState(state);
  }

  List loadedIds = [];
  loadMessages() async {
    var lock = Lock();
    await lock.synchronized(() async {
//      List<Map> myChats = List.from(userModel.getList(MY_CHATS));
      var sub = Firestore.instance
          .collection(CHAT_IDS_BASE)
          .where(PARTIES, arrayContains: userModel.getObjectId())
          .snapshots()
          .listen((shots) {
        for (DocumentSnapshot doc in shots.documents) {
          BaseModel chatIdModel = BaseModel(doc: doc);
          String chatId = chatIdModel.getObjectId();
          if (userModel.getList(DELETED_CHATS).contains(chatId)) continue;
          if (loadedIds.contains(chatId)) {
            continue;
          }
          loadedIds.add(chatId);

          var sub = Firestore.instance
              .collection(CHAT_BASE)
              .where(PARTIES, arrayContains: userModel.getUserId())
              .where(CHAT_ID, isEqualTo: chatId)
              .orderBy(TIME, descending: true)
              .limit(1)
              .snapshots()
              .listen((shots) async {
            if (shots.documents.isNotEmpty) {
              BaseModel cModel = BaseModel(doc: (shots.documents[0]));
              if (isBlocked(null, userId: getOtherPersonId(cModel))) {
                lastMessages.removeWhere(
                    (bm) => bm.getString(CHAT_ID) == cModel.getString(CHAT_ID));
                chatMessageController.add(true);
                return;
              }
            }
            if (stopListening.contains(chatId)) return;
            for (DocumentSnapshot doc in shots.documents) {
              BaseModel model = BaseModel(doc: doc);
              String chatId = model.getString(CHAT_ID);
              int index = lastMessages.indexWhere(
                  (bm) => bm.getString(CHAT_ID) == model.getString(CHAT_ID));
              if (index == -1) {
                lastMessages.add(model);
              } else {
                lastMessages[index] = model;
              }

              if (!model.getList(READ_BY).contains(userModel.getObjectId()) &&
                  !model.myItem() &&
                  visibleChatId != model.getString(CHAT_ID)) {
                try {
                  if (!showNewMessageDot.contains(chatId))
                    showNewMessageDot.add(chatId);
                  setState(() {});
                } catch (E) {
                  if (!showNewMessageDot.contains(chatId))
                    showNewMessageDot.add(chatId);
                  setState(() {});
                }
                countUnread(chatId);
              }
            }

            String otherPersonId = getOtherPersonId(chatIdModel);
            loadOtherPerson(otherPersonId);

            try {
              lastMessages
                  .sort((bm1, bm2) => bm2.getTime().compareTo(bm1.getTime()));
            } catch (E) {}
          });

          subs.add(sub);
        }
        chatSetup = true;
        if (mounted) setState(() {});
      });
      subs.add(sub);
    });
  }

  loadProducts() async {
    Firestore.instance
        .collection(PRODUCT_BASE)
        .where(
          STATUS,
          isEqualTo: APPROVED,
        )
        .limit(30)
        .getDocuments()
        .then((shots) {
      for (DocumentSnapshot doc in shots.documents) {
        BaseModel model = BaseModel(doc: doc);
        int p = productLists
            .indexWhere((e) => e.getObjectId() == model.getObjectId());
        if (p != -1) {
          productLists[p] = model;
        } else {
          productLists.add(model);
        }
      }
      productSetup = true;
      if (mounted) setState(() {});
    });
  }

  loadOtherPerson(String uId, {int delay = 0}) async {
    var lock = Lock();
    await lock.synchronized(() async {
      Future.delayed(Duration(seconds: delay), () async {
        DocumentSnapshot doc =
            await Firestore.instance.collection(USER_BASE).document(uId).get();

        if (doc == null) return;
        if (!doc.exists) return;

        BaseModel user = BaseModel(doc: doc);
        otherPeronInfo[uId] = user;
        if (mounted) setState(() {});
      });
    }, timeout: Duration(seconds: 10));
  }

  countUnread(String chatId) async {
    var lock = Lock();
    lock.synchronized(() async {
      int count = 0;
      QuerySnapshot shots = await Firestore.instance
          .collection(CHAT_BASE)
          .where(CHAT_ID, isEqualTo: chatId)
          .getDocuments();

      List list = [];
      for (DocumentSnapshot doc in shots.documents) {
        BaseModel model = BaseModel(doc: doc);
        if (!model.getList(READ_BY).contains(userModel.getObjectId()) &&
            !model.myItem()) {
          count++;
          list.add(model);
        }
      }
      if (list.isNotEmpty) unreadCounter[chatId] = list;
      chatMessageController.add(true);
    });
  }

  loadNotification() async {
    var sub = Firestore.instance
        .collection(NOTIFY_BASE)
        .where(PARTIES, arrayContains: userModel.getUserId())
        .limit(1)
        .orderBy(TIME_UPDATED, descending: true)
        .snapshots()
        .listen((shots) {
      //toastInAndroid(shots.documents.length.toString());
      for (DocumentSnapshot d in shots.documents) {
        BaseModel model = BaseModel(doc: d);
        /*int p = nList
            .indexWhere((bm) => bm.getObjectId() == model.getObjectId());
        if (p == -1) {
          nList.add(model);
        } else {
          nList[p] = model;
        }*/

        if (!model.getList(READ_BY).contains(userModel.getObjectId()) &&
            !model.myItem()) {
          showNewNotifyDot = true;
          setState(() {});
        }
      }
      /*nList.sort((bm1, bm2) =>
          bm2.getInt(TIME_UPDATED).compareTo(bm1.getInt(TIME_UPDATED)));*/
    });

    subs.add(sub);
    //notifySetup = true;
    if (mounted) setState(() {});
  }

  List pageResource = [
    {"title": "Home", "image": Icons.home, "asset": false},
    {"title": "Chat", "image": ic_chat2, "asset": true},
    {"title": "Sell", "image": Icons.camera_alt, "asset": false},
    {"title": "Offer", "image": ic_offer, "asset": true},
    {"title": "Account", "image": Icons.person, "asset": false},
  ];

  final vp = PageController();
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
      onWillPop: () {
        //backThings();
        io.exit(0);
        return;
      },
      child: Scaffold(
        //backgroundColor: AppConfig.appColor,
        body: Stack(
          children: [
//            Container(
//              color: AppConfig.appColor,
//              height: MediaQuery.of(context).size.height * .3,
//            ),
            page(),
            bottomTab()
          ],
        ),
      ),
    );
  }

  bottomTab() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: BoxDecoration(
            color: black,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        padding: EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (p) {
            String title = pageResource[p]["title"];
            bool asset = pageResource[p]["asset"];
            final image = pageResource[p]["image"];
            bool active = currentPage == p;
            double size = active ? 25 : 20;
            final color = white.withOpacity(active ? 1 : 0.7);
            return Flexible(
              child: GestureDetector(
                onTap: () {
                  if (p == 2) {
                    pushAndResult(
                        context, isLoggedIn ? SellCamera() : LoginPage(),
                        depend: false);
                    return;
                  }
                  vp.jumpToPage(p);
                },
                child: Container(
                  width: getScreenWidth(context) / 5,
                  color: transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (asset)
                        Image.asset(
                          image,
                          height: size,
                          width: size,
                          color: color,
                          fit: BoxFit.cover,
                        )
                      else
                        Icon(
                          image,
                          size: size,
                          color: color,
                        ),
                      Text(
                        title,
                        style: textStyle(active, active ? 15 : 14, color),
                      )
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  page() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(top: 50, right: 10, left: 10, bottom: 10),
          color: white,
          child: Stack(
            children: [
              Align(
                child: Text(
                  pageResource[currentPage]["title"],
                  style: textStyle(true, 22, black),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  new Container(
                    height: 30,
                    //width: 50,
                    child: new FlatButton(
                        padding: EdgeInsets.all(0),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onPressed: () {
                          // postChatDoc();
                        },
                        color: AppConfig.appColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        child: Center(
                            child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.account_balance_wallet,
                              size: 16,
                              color: black,
                            ),
                            addSpaceWidth(5),
                            Text("Wallet")
                          ],
                        ))),
                  ),
                  Spacer(),
                  new Container(
                    height: 30,
                    width: 50,
                    child: new FlatButton(
                        padding: EdgeInsets.all(0),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onPressed: () {},
                        child: Center(
                            child: Icon(
                          Icons.notifications_active,
                          size: 20,
                          color: black,
                        ))),
                  ),
                  imageHolder(35, userModel.userImage)
                ],
              )
            ],
          ),
        ),
        postingIndicator(),
        Flexible(
          child: PageView(
            controller: vp,
            onPageChanged: (p) {
              currentPage = p;
              setState(() {});
            },
            children: [Home(), Chat(), Container(), Offer(), Container()],
          ),
        ),
      ],
    );
  }

  postingIndicator() {
    //if (!isPosting) return Container();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (posting)
          AnimatedContainer(
            duration: Duration(milliseconds: 500),
            height: 2,
            color: AppConfig.appColor,
            child: LinearProgressIndicator(
              value: progress == 0 ? null : progress,
              backgroundColor: AppConfig.appColor,
              valueColor: AlwaysStoppedAnimation(white),
            ),
          ),
        AnimatedContainer(
          height: uploadingText == null ? 0 : 40,
          duration: Duration(milliseconds: 500),
          color: dark_green0,
          padding: EdgeInsets.all(10),
          child: uploadingText == null
              ? Container()
              : Row(
                  //mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check, size: 18, color: white),
                    addSpaceWidth(10),
                    Text(
                      uploadingText,
                      style: textStyle(true, 12, white),
                    )
                  ],
                ),
        )
      ],
    );
  }

  backThings() {
    if (userModel != null && !userModel.getBoolean(HAS_RATED)) {
      showMessage(context, Icons.star, blue0, "Rate Us",
          "Enjoying the App? Please support us with 5 stars",
          clickYesText: "RATE APP", clickNoText: "Later", onClicked: (_) {
        if (_ == true) {
          if (appSettingsModel == null ||
              appSettingsModel.getString(PACKAGE_NAME).isEmpty) {
            onPause();
            Future.delayed(Duration(seconds: 1), () {
              io.exit(0);
            });
          } else {
            rateApp();
          }
        } else {
          onPause();
          Future.delayed(Duration(seconds: 1), () {
            io.exit(0);
          });
        }
      });
      return;
    }
    onPause();
    Future.delayed(Duration(seconds: 1), () {
      io.exit(0);
    });
  }

  loadStory() async {
    var storySub = Firestore.instance
        .collection(STORY_BASE)
        .where(GENDER, isEqualTo: userModel.isMale() ? FEMALE : MALE)
        .where(TIME,
            isGreaterThan: (DateTime.now().millisecondsSinceEpoch -
                (Duration.millisecondsPerDay * 2)))
        .snapshots()
        .listen((shots) {
      bool added = false;
      for (DocumentSnapshot shot in shots.documents) {
        if (!shot.exists) continue;
        BaseModel model = BaseModel(doc: shot);
        if (isBlocked(model)) continue;
        int index = allStoryList
            .indexWhere(((bm) => bm.getObjectId() == model.getObjectId()));
        if (index == -1) {
          allStoryList.add(model);
          added = true;
          if (!model.myItem() &&
              !model.getList(SHOWN).contains(userModel.getObjectId())) {
            if (!newStoryIds.contains(model.getObjectId()))
              newStoryIds.add(model.getObjectId());
          }
        } else {
          allStoryList[index] = model;
        }
      }
      homeRefreshController.add(true);
    });
    var myStorySub = Firestore.instance
        .collection(STORY_BASE)
        .where(USER_ID, isEqualTo: userModel.getObjectId())
        .snapshots()
        .listen((shots) {
      bool added = false;
      for (DocumentSnapshot shot in shots.documents) {
        if (!shot.exists) continue;
        BaseModel model = BaseModel(doc: shot);
        if (isBlocked(model)) continue;
        int index = allStoryList
            .indexWhere(((bm) => bm.getObjectId() == model.getObjectId()));
        if (index == -1) {
          allStoryList.add(model);
          added = true;
        } else {
          allStoryList[index] = model;
        }
      }
      homeRefreshController.add(true);
    });
    subs.add(storySub);
    subs.add(myStorySub);
  }

  loadBlocked() async {
    var lock = Lock();
    lock.synchronized(() async {
      QuerySnapshot shots = await Firestore.instance
          .collection(USER_BASE)
          .where(BLOCKED, arrayContains: userModel.getObjectId())
          .getDocuments();

      for (DocumentSnapshot doc in shots.documents) {
        BaseModel model = BaseModel(doc: doc);
        String uId = model.getObjectId();
        String deviceId = model.getString(DEVICE_ID);
        if (!blockedIds.contains(uId)) blockedIds.add(uId);
        if (deviceId.isNotEmpty) if (!blockedIds.contains(deviceId))
          blockedIds.add(deviceId);
      }
    }, timeout: Duration(seconds: 10));
  }

  getStackedImages(List list) {
    List items = [];
    int count = 0;
    for (int i = 0; i < list.length; i++) {
      if (count > 10) break;
      BaseModel model = hookupList[i];
      items.add(Container(
        margin: EdgeInsets.only(left: double.parse((i * 20).toString())),
        child: userImageItem(context, model, size: 40, padLeft: false),
      ));
      count++;
    }
    List<Widget> children = List.from(items.reversed);
    return IgnorePointer(
      ignoring: true,
      child: Container(
        height: 40,
        child: Stack(
          children: children,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class UpdateLayout extends StatelessWidget {
  BuildContext con;
  @override
  Widget build(BuildContext context) {
    String features = appSettingsModel.getString(NEW_FEATURE);
    if (features.isNotEmpty) features = "* $features";
    bool mustUpdate = appSettingsModel.getBoolean(MUST_UPDATE);
    con = context;
    return WillPopScope(
      onWillPop: () {},
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                color: black.withOpacity(.6),
              )),
          Container(
            padding: EdgeInsets.all(15),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      if (isAdmin) {
                        Navigator.pop(con);
                      }
                    },
                    child: Icon(
                      Icons.update,
                      color: red0,
                      size: 60,
                    ),
                  ),
                  addSpace(10),
                  Text(
                    "New Update Available",
                    style: textStyle(true, 22, white),
                    textAlign: TextAlign.center,
                  ),
                  addSpace(10),
                  Text(
                    features.isEmpty
                        ? "Please update your App to proceed"
                        : features,
                    style: textStyle(false, 16, white.withOpacity(.5)),
                    textAlign: TextAlign.center,
                  ),
                  addSpace(15),
                  Container(
                    height: 40,
                    width: double.infinity,
                    child: FlatButton(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                        color: blue3,
                        onPressed: () {
                          rateApp();
                        },
                        child: Text(
                          "UPDATE",
                          style: textStyle(true, 14, white),
                        )),
                  ),
                  addSpace(15),
                  if (!mustUpdate)
                    Container(
                      height: 40,
                      child: FlatButton(
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                          color: red0,
                          onPressed: () {
                            Navigator.pop(con);
                          },
                          child: Text(
                            "Later",
                            style: textStyle(true, 14, white),
                          )),
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
