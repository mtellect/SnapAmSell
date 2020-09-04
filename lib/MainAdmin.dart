import 'dart:async';
import 'dart:io';
import 'dart:io' as io;
import 'dart:ui';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:line_icons/line_icons.dart';
import 'package:location/location.dart';
import 'package:maugost_apps/assets.dart';
import 'package:maugost_apps/basemodel.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';

import 'AppConfig.dart';
import 'AppEngine.dart';
import 'ChatMain.dart';
import 'PreAuth.dart';
import 'ReportMain.dart';
import 'main_pages/Account.dart';
import 'main_pages/Chat.dart';
import 'main_pages/Home.dart';
import 'main_pages/Notifications.dart';
import 'main_pages/OfferPage.dart';
import 'main_pages/SellCamera.dart';
import 'main_pages/ShowCart.dart';
import 'main_pages/ShowStore.dart';

Map<String, List> unreadCounter = Map();
Map otherPeronInfo = Map();

Map offerInfo = Map();
Map otherProductInfo = Map();

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
final cartController = StreamController<BaseModel>.broadcast();
final offerController = StreamController<bool>.broadcast();
final orderController = StreamController<bool>.broadcast();
final modeController = StreamController<bool>.broadcast();
final stateController = StreamController<bool>.broadcast();

List connectCount = [];
List<String> stopListening = List();
List<BaseModel> lastMessages = List();
List<BaseModel> lastOffers = List();
List<BaseModel> nList = List();
bool chatSetup = false;
bool offerSetup = false;
List showNewMessageDot = [];
List showNewMessageOffer = [];
bool showNewNotifyDot = false;
List unreadCount = [];
List newStoryIds = [];
String visibleChatId;
bool itemsLoaded = false;
bool notifySetup = false;

Location location = new Location();
GeoFirePoint myLocation;

bool serviceEnabled = false;
PermissionStatus permissionGranted;
LocationData locationData;

List<BaseModel> adsList = [];
bool adsSetup = false;

List<BaseModel> productLists = [];
bool productSetup = false;

List<BaseModel> orderList = [];
bool orderSetup = false;

//List<BaseModel> offerLists = [];

List<BaseModel> myProducts = [];
bool myProductSetup = false;

List<BaseModel> cartLists = [];
bool cartSetup = false;

//Color themeColors(bool dark) {
//  if (dark) {
//    return Colors.grey[850];
//  } else {
//    return Colors.white;
//  }
//}
//Color white = darkMode?Colors.grey[850]:white;
//Color white_widget_color = darkMode?white:Colors.grey[850];
//Color white_reverse = darkMode?Colors.grey[850]:white;//themeColors(false);

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
        int p = productLists
            .indexWhere((e) => e.getObjectId() == model.getObjectId());
        if (p != -1) {
          productLists[p] = model;
        } else {
          productLists.add(model);
        }
      });
    });

    var sub4 = modeController.stream.listen((bool) {
      darkMode = bool;
      setState(() {
//        white = themeColors(bool);
      });
    });

    var sub5 = cartController.stream.listen((bm) {
      if (bm == null) {
        cartLists.clear();
        setState(() {});
        return;
      }

      BaseModel model = BaseModel(items: bm.items);
      String id = model.getObjectId();
      int p = cartLists.indexWhere((e) => e.getObjectId() == id);
      model.put(QUANTITY, 1);
      bool exists = p != -1;
      if (exists) {
        cartLists.removeAt(p);
//        model.deleteItem();
      } else {
        cartLists.add(model);
//        model
//          ..put(OBJECT_ID, model.getObjectId())
//          ..saveItem(CART_BASE, true, document: model.getObjectId());
      }
      setState(() {});
    });

    /* var sub6 = cartController.stream.listen((model) {
      String id = model.getObjectId();
      int p = offerLists.indexWhere((e) => e.getObjectId() == id);
      model.put(QUANTITY, 1);
      bool exists = p != -1;
      if (exists) {
        offerLists.removeAt(p);
      } else {
        offerLists.add(model);
      }
      setState(() {});
    });*/

    var sub7 = FirebaseAuth.instance.onAuthStateChanged.listen((event) {
      if (event != null) {
        loadNotification();
        loadMessages();
        loadBids();
        loadOrders();
        setupPush();
        loadBlocked();
        if (mounted) setState(() {});
        return;
      }
      if (mounted) setState(() {});
    });

    var sub8 = stateController.stream.listen((show) {
      setState(() {});
    });

    subs.add(sub1);
    subs.add(sub2);
    subs.add(sub3);
    subs.add(sub4);
    subs.add(sub5);
//    subs.add(sub6);
    subs.add(sub7);
    subs.add(sub8);
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

  okLayout(bool manually) {
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
//          loadCarts();
//          loadProducts();
          loadBids();
          loadOrders();
          setupPush();
          loadBlocked();
          updatePackage();
          chkUpdate();
          setUpLocation();
          loadAds();
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

  loadAds() async {
    var sub = Firestore.instance
        .collection(ADS_BASE)
        //.where(PARTIES, arrayContains: userModel.getUserId())
        //.limit(1)
        .orderBy(TIME_UPDATED, descending: true)
        .snapshots()
        .listen((shots) {
      for (var d in shots.documentChanges) {
        BaseModel model = BaseModel(doc: d.document);
        bool hide = model.getInt(STATUS) == 123;
        int p =
            adsList.indexWhere((bm) => bm.getObjectId() == model.getObjectId());
        if (d.type == DocumentChangeType.removed || hide) {
          nList.removeWhere((bm) => bm.getObjectId() == model.getObjectId());
          continue;
        }
        if (p == -1) {
          adsList.add(model);
        } else {
          adsList[p] = model;
        }
        adsSetup = true;
        setState(() {});
      }
    });
    subs.add(sub);
    if (mounted) setState(() {});
  }

  setUpLocation() async {
//    return;
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
      //setUpLocation();
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
            print(otherPersonId);
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

  loadCarts() async {
    Firestore.instance
        .collection(CART_BASE)
        .where(USER_ID, isEqualTo: userModel.getUserId())
        .getDocuments()
        .then((value) {
      for (var doc in value.documents) {
        BaseModel bm = BaseModel(doc: doc);
        int p =
            cartLists.indexWhere((e) => e.getObjectId() == bm.getObjectId());
        if (p != -1) {
          cartLists[p] = bm;
        } else {
          cartLists.add(bm);
        }
      }
      cartSetup = true;
      if (mounted) setState(() {});
    });
  }

  loadBids() async {
    var lock = Lock();
    await lock.synchronized(() async {
//      List<Map> myChats = List.from(userModel.getList(MY_CHATS));
      var sub = Firestore.instance
          .collection(OFFER_IDS_BASE)
          .where(PARTIES, arrayContains: userModel.getObjectId())
          .snapshots()
          .listen((shots) {
        for (DocumentSnapshot doc in shots.documents) {
          BaseModel offerModel = BaseModel(doc: doc);
          String offerId = offerModel.getObjectId();
          offerInfo[offerId] = offerModel;
          if (loadedIds.contains(offerModel)) {
            continue;
          }
          loadedIds.add(offerModel);

          var sub = Firestore.instance
              .collection(OFFER_BASE)
              .where(PARTIES, arrayContains: userModel.getUserId())
              .where(OFFER_ID, isEqualTo: offerId)
              .orderBy(TIME, descending: true)
              .limit(1)
              .snapshots()
              .listen((shots) async {
            /*if (shots.documents.isNotEmpty) {
              BaseModel cModel = BaseModel(doc: (shots.documents[0]));
              if (isBlocked(null, userId: getOtherPersonId(cModel))) {
                lastMessages.removeWhere(
                    (bm) => bm.getString(CHAT_ID) == cModel.getString(CHAT_ID));
                offerController.add(true);
                return;
              }
            }*/
            if (stopListening.contains(offerId)) return;
            for (DocumentSnapshot doc in shots.documents) {
              BaseModel model = BaseModel(doc: doc);
              int index = lastOffers.indexWhere(
                  (bm) => bm.getString(OFFER_ID) == model.getString(OFFER_ID));
              if (index == -1) {
                lastOffers.add(model);
              } else {
                lastOffers[index] = model;
              }

              if (!model.getList(READ_BY).contains(userModel.getObjectId()) &&
                  !model.myItem() &&
                  visibleChatId != offerId) {
                if (!showNewMessageOffer.contains(offerId))
                  showNewMessageOffer.add(offerId);
                if (mounted) setState(() {});
//                countUnread(chatId);
              }
            }
            String otherPersonId = getOtherPersonId(offerModel);
            print("Offer party $otherPersonId");
            loadOtherPerson(otherPersonId);
            String productId = offerModel.getString(PRODUCT_ID);
            loadProductAt(productId);
            try {
              lastOffers
                  .sort((bm1, bm2) => bm2.getTime().compareTo(bm1.getTime()));
            } catch (E) {}
          });

          subs.add(sub);
        }
        offerController.add(true);
        offerSetup = true;
        if (mounted) setState(() {});
      });
      subs.add(sub);
    });
  }

  loadOrders() async {
    Firestore.instance
        .collection(ORDER_BASE)
        .where(PARTIES, arrayContains: userModel.getUserId())
        .getDocuments()
        .then((shots) {
      for (DocumentSnapshot doc in shots.documents) {
        BaseModel model = BaseModel(doc: doc);
        int p =
            orderList.indexWhere((e) => e.getObjectId() == model.getObjectId());
        if (p != -1) {
          orderList[p] = model;
        } else {
          orderList.add(model);
        }
      }
      orderSetup = true;
      if (mounted) setState(() {});
    });
  }

  loadProducts() async {
    Firestore.instance
        .collection(PRODUCT_BASE)
        /* .where(
          STATUS,
          isEqualTo: APPROVED,
        )*/
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

    //my products
    if (!isLoggedIn) return;
    Firestore.instance
        .collection(PRODUCT_BASE)
        .where(
          USER_ID,
          isEqualTo: userModel.getUserId(),
        )
        .limit(30)
        .getDocuments()
        .then((shots) {
      for (DocumentSnapshot doc in shots.documents) {
        BaseModel model = BaseModel(doc: doc);
        int p = myProducts
            .indexWhere((e) => e.getObjectId() == model.getObjectId());
        if (p != -1) {
          myProducts[p] = model;
        } else {
          myProducts.add(model);
        }
      }
      myProductSetup = true;
      if (mounted) setState(() {});
    });
  }

  loadProductAt(String pID, {int delay = 0}) async {
    var lock = Lock();
    await lock.synchronized(() async {
      Future.delayed(Duration(seconds: delay), () async {
        Firestore.instance
            .collection(PRODUCT_BASE)
            .document(pID)
            .get()
            .then((doc) {
          if (doc == null) return;
          if (!doc.exists) return;
          BaseModel product = BaseModel(doc: doc);
          otherProductInfo[pID] = product;
          if (mounted) setState(() {});
        });
      });
    }, timeout: Duration(seconds: 10));
  }

  loadOtherPerson(String uId, {int delay = 0}) async {
    var lock = Lock();
    await lock.synchronized(() async {
      Future.delayed(Duration(seconds: delay), () async {
        Firestore.instance
            .collection(USER_BASE)
            .document(uId)
            .get()
            .then((doc) {
          if (doc == null) return;
          if (!doc.exists) return;

          BaseModel user = BaseModel(doc: doc);
          otherPeronInfo[uId] = user;
          if (mounted) setState(() {});
        });
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
      for (var d in shots.documentChanges) {
        BaseModel model = BaseModel(doc: d.document);

        if (d.type == DocumentChangeType.removed) {
          nList.removeWhere((bm) => bm.getObjectId() == model.getObjectId());
          continue;
        }
        int p =
            nList.indexWhere((bm) => bm.getObjectId() == model.getObjectId());
        if (p == -1) {
          nList.add(model);
        } else {
          nList[p] = model;
        }

        if (!model.getList(READ_BY).contains(userModel.getObjectId()) &&
            !model.myItem()) {
          unreadCount.add(model.getObjectId());
          showNewNotifyDot = true;
          setState(() {});
        }
      }
      /*nList.sort((bm1, bm2) =>
          bm2.getInt(TIME_UPDATED).compareTo(bm1.getInt(TIME_UPDATED)));*/
    });

    subs.add(sub);
    notifySetup = true;
    if (mounted) setState(() {});
  }

  List pageResource = [
    {"title": "Home", "image": LineIcons.home, "asset": false},
    {"title": "Chat", "image": ic_chat2, "asset": true},
    //{"title": "Sell", "image": Icons.camera_alt, "asset": false},
    {"title": "Offers", "image": ic_offer, "asset": true},
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
            page(),
            bottomTab(),
            /*Align(
              alignment: Alignment.bottomRight,
              child: Container(
                margin: EdgeInsets.only(bottom: 100, right: 10),
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    MaterialButton(
                      onPressed: () {
                        pushAndResult(
                          context,
                          ShowCart(),
                        );
                      },
                      color: black,
                      padding: EdgeInsets.all(24),
                      elevation: 12,
                      shape: CircleBorder(
                          //borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: black.withOpacity(.7))),
                      child: Image.asset(
                        ic_cart,
                        height: 20,
                        width: 20,
                        color: white,
                      ),
                    ),
                    if (cartLists.length > 0)
                      Container(
                        decoration: BoxDecoration(
                            color: red,
                            shape: BoxShape.circle,
                            border: Border.all(color: white_color, width: 1.5)),
                        padding: EdgeInsets.all(10),
                        child: Text(
                          cartLists.length.toString(),
                          style: textStyle(false, 12, white_color),
                        ),
                      )
                  ],
                ),
              ),
            ),*/
          ],
        ),
      ),
    );
  }

  bottomTab() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
            color: black,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        padding: EdgeInsets.all(15),
        child: Row(
          children: [
            bottomTabItem(0, Icons.home, "Home"),
            bottomTabItem(1, ic_chat2, "Chat"),
            Flexible(
              child: GestureDetector(
                onTap: () {
                  pushAndResult(context, isLoggedIn ? SellCamera() : PreAuth(),
                      depend: false);
                },
                child: Container(
                  //key: btnKey,
                  margin: EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                      color: white,
                      shape: BoxShape.circle,
                      border: Border.all(color: white, width: 5)),
                  child: Center(
                    child: Icon(
                      Icons.camera_enhance_outlined,
                      color: black,
                    ),
                  ),
                ),
              ),
              fit: FlexFit.tight,
            ),
            bottomTabItem(2, ic_offer, "Offers"),
            bottomTabItem(3, LineIcons.user, "Account")
          ],
        ),
      ),
    );
  }

  bottomTabItem(
    int index,
    icon,
    title,
  ) {
    bool isAsset = icon.toString().contains("asset");
    bool active = currentPage == index;
    double size = active ? 25 : 20;
    final color = white.withOpacity(active ? 1 : (.4));

    return Flexible(
      child: GestureDetector(
        onTap: () {
          if (!isLoggedIn && index > 0) {
            pushAndResult(context, PreAuth(), depend: false);
            return;
          }

          vp.jumpToPage(index);
        },
        child: Container(
          color: transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isAsset)
                Image.asset(
                  icon,
                  height: size,
                  width: size,
                  color: color,
                )
              else
                Icon(icon, size: size, color: color),
              Text(
                title,
                style: textStyle(active, active ? 15 : 14, color),
              )
            ],
          ),
        ),
      ),
      fit: FlexFit.tight,
    );
  }

  page() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(top: 50, right: 10, left: 10, bottom: 10),
          color: default_white_color,
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
                  // new Container(
                  //   height: 30,
                  //   //width: 50,
                  //   child: new FlatButton(
                  //       padding: EdgeInsets.all(0),
                  //       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  //       onPressed: () {
                  //         // postChatDoc();
                  //         pushAndResult(
                  //           context,
                  //           isLoggedIn ? Wallet() : PreAuth(),
                  //         );
                  //       },
                  //       color: AppConfig.appColor,
                  //       shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(15)),
                  //       child: Center(
                  //           child: Row(
                  //         mainAxisSize: MainAxisSize.min,
                  //         children: [
                  //           Icon(
                  //             Icons.account_balance_wallet_outlined,
                  //             size: 16,
                  //             color: black,
                  //           ),
                  //           addSpaceWidth(5),
                  //           Text(
                  //             "Wallet",
                  //             style: textStyle(true, 13, black),
                  //           )
                  //         ],
                  //       ))),
                  // ),
                  imageHolder(
                    35,
                    userModel.userImage,
                    onImageTap: () {
                      pushAndResult(
                        context,
                        isLoggedIn ? ShowStore(userModel) : PreAuth(),
                      );
                    },
                    strokeColor: black,
                    stroke: 2,
                  ),
                  Spacer(),
                  new Container(
                    height: 30,
                    width: 60,
                    child: new FlatButton(
                        padding: EdgeInsets.all(0),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onPressed: () {
                          pushAndResult(
                            context,
                            isLoggedIn ? Notifications() : PreAuth(),
                          );
                        },
                        child: Stack(
                          children: [
                            Align(
                                alignment: Alignment.center,
                                child: Container(
                                  margin: EdgeInsets.only(left: 4),
                                  child: Icon(
                                    Icons.notifications_active,
                                    size: 24,
                                    color: black,
                                  ),
                                )),
                            if (unreadCount.length > 0)
                              Container(
                                // height: 10,
                                // width: 10,
                                padding: EdgeInsets.only(
                                    left: 6, right: 6, top: 3, bottom: 3),
                                margin: EdgeInsets.only(left: 6),
                                child: Text(
                                  unreadCount.length.toString(),
                                  style: textStyle(false, 11, white),
                                ),
                                decoration: BoxDecoration(
                                    color: red,
                                    borderRadius: BorderRadius.circular(5)
                                    //shape: BoxShape.circle
                                    ),
                              )
                          ],
                        )),
                  ),
                  new Container(
                    height: 30,
                    width: 60,
                    child: new FlatButton(
                        padding: EdgeInsets.all(0),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onPressed: () {
                          pushAndResult(
                            context,
                            isLoggedIn ? ShowCart() : PreAuth(),
                          );
                        },
                        child: Stack(
                          children: [
                            Align(
                                alignment: Alignment.center,
                                child: Container(
                                  margin: EdgeInsets.only(left: 4),
                                  child: Image.asset(
                                    ic_cart,
                                    height: 20,
                                    width: 20,
                                    color: black,
                                  ),
                                )),
                            if (cartLists.length > 0)
                              Container(
                                // height: 10,
                                // width: 10,
                                padding: EdgeInsets.only(
                                    left: 6, right: 6, top: 3, bottom: 3),
                                margin: EdgeInsets.only(left: 6),
                                child: Text(
                                  cartLists.length.toString(),
                                  style: textStyle(false, 11, white),
                                ),
                                decoration: BoxDecoration(
                                    color: red,
                                    borderRadius: BorderRadius.circular(5)
                                    //shape: BoxShape.circle
                                    ),
                              )
                          ],
                        )),
                  ),
                  //if (isLoggedIn)
                ],
              )
            ],
          ),
        ),
        postingIndicator(),
        Expanded(
          child: PageView(
            controller: vp,
            onPageChanged: (p) {
              currentPage = p;
              setState(() {});
            },
            physics: NeverScrollableScrollPhysics(),
            children: [Home(), Chat(), OfferPage(), Account()],
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
