import 'dart:async';
import 'dart:io';
import 'dart:ui';


import 'package:timeago/timeago.dart' as timeAgo;
import 'package:Strokes/AppEngine.dart';
import 'package:Strokes/ChatOfferDialog.dart';
import 'package:Strokes/MainAdmin.dart';
import 'package:Strokes/app_config.dart';
import 'package:Strokes/assets.dart';
import 'package:Strokes/basemodel.dart';
import 'package:Strokes/notificationService.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:synchronized/synchronized.dart';
import 'package:video_player/video_player.dart';


class OfferMain extends StatefulWidget {
  String offerId;
  BaseModel offerModel;
  OfferMain(this.offerId, {this.offerModel});

  @override
  _OfferMainState createState() => _OfferMainState();
}

class _OfferMainState extends State<OfferMain>
    with WidgetsBindingObserver, TickerProviderStateMixin {

  final ItemScrollController messageListController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  List<BaseModel> offerList = List();

  String offerId;
  BaseModel offerModel;
  BaseModel otherPerson=BaseModel();
  bool setup = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  VideoPlayerController typingSoundController;
  VideoPlayerController messageSoundController;
  BaseModel replyModel;
  int blinkPosition = -1;
  bool canSound = true;
  double bestOffer = 0;
  
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadSound();
    offerId = widget.offerId;
    visibleChatId = offerId;
    offerModel = widget.offerModel ?? BaseModel();

    startup();
  }

  loadSound() async {
    File bubble = await loadFile('assets/sounds/typing.m4a', "typing.m4a");
    File bubble1 = await loadFile('assets/sounds/sent.m4a', "sent.m4a");

    typingSoundController = VideoPlayerController.file(bubble);
    messageSoundController = VideoPlayerController.file(bubble1);

    typingSoundController.initialize();
    messageSoundController.initialize();
  }

  startup() async {
    if (widget.offerModel != null) {
      loadChat();
      refreshOtherUser();
      return;
    }

    DocumentSnapshot doc = await Firestore.instance
        .collection(OFFER_IDS_BASE)
        .document(offerId)
        .get();
    if (!doc.exists) return;

    offerModel = BaseModel(doc: doc);
    loadChat();
    refreshOtherUser();
  }

  refreshOtherUser() async {
    String otherPersonId = getOtherPersonId(offerModel);
    if (userModel.getList(BLOCKED).contains(otherPersonId)) {
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pop(context);
      });
    }
    StreamSubscription<DocumentSnapshot> sub = Firestore.instance
        .collection(USER_BASE)
        .document(otherPersonId)
        .snapshots()
        .listen((shot) {
      otherPerson = BaseModel(doc: shot);
      int now = DateTime.now().millisecondsSinceEpoch;
      int lastUpdated = otherPerson.getInt(TIME_UPDATED);
      int tsDiff = (now - lastUpdated);
      bool notOnline = (tsDiff > (Duration.millisecondsPerMinute * 10));
      bool notTyping = (tsDiff > (Duration.millisecondsPerMinute * 1));
      isOnline = otherPerson.getBoolean(IS_ONLINE) && (!notOnline);
      isTyping = otherPerson.getString(TYPING_ID) == offerId && (!notTyping);
      bool notRecording = (tsDiff > (Duration.millisecondsPerMinute * 5));
      isRecording = otherPerson.getString(REC_ID) == offerId && (!notRecording);
      if (mounted) setState(() {});

      if (isTyping) {
        playTypingSound();
      } else if (typingSoundController != null &&
          typingSoundController.value.initialized) {
        typingSoundController.pause();
      }
    });

    subs.add(sub);
  }

  List audioSetupList = [];
  List<StreamSubscription> subs = List();
  void loadChat() async {
    StreamSubscription<QuerySnapshot> sub = Firestore.instance
        .collection(OFFER_BASE)
        .where(OFFER_ID, isEqualTo: offerId)
        .orderBy(CREATED_AT, descending: false)
        .snapshots()
        .listen((shots) async {
      for (DocumentChange docChange in shots.documentChanges) {
        if (docChange.type == DocumentChangeType.added &&
            loadedChatIds.contains(docChange.document.documentID)) continue;
        DocumentSnapshot doc = docChange.document;
        BaseModel chat = BaseModel(doc: doc);
//        print("New Message in Chat... $offerId");
        addOfferToList(chat);
        final readBy = chat.getList(READ_BY);
        bool hasRead = readBy.contains(userModel.getString(USER_ID));
//        bool myChat = chat.getString(USER_ID) == currentUser.getString(USER_ID);
        if (!chat.myItem() && !hasRead) {
          readBy.add(userModel.getString(USER_ID));
          chat.put(READ_BY, readBy);
          chat.updateItems();
        }
      }

//      refreshChatDates();

      setup = true;
      if (mounted) setState(() {});
    });

    subs.add(sub);
  }

  List loadedChatIds = [];
  BaseModel myNewestOffer = BaseModel();
  BaseModel yourNewestOffer = BaseModel();

  void addOfferToList(BaseModel chat) async {

    var lock = Lock();
    await lock.synchronized(() {

      if(chat.myItem()){
        if(chat.getTime()>myNewestOffer.getTime()){
          myNewestOffer=chat;
        }
      }else{
        if(chat.getTime()>yourNewestOffer.getTime()){
          yourNewestOffer=chat;
        }
      }

      int p = offerList
          .indexWhere((BaseModel c) => chat.getObjectId() == c.getObjectId());
      if (p != -1) {
        offerList[p] = chat;
        print("updating chat at $p");
      } else {
        if (!chat.myItem()) playNewMessageSound();
        offerList.insert(0, chat);
        if (!loadedChatIds.contains(chat.getObjectId()))
          loadedChatIds.add(chat.getObjectId());
      }
      if(mounted)setState(() {});
    });
  }

  int lastNewMessagePlayed = 0;
  playNewMessageSound() async {
    if (visibleChatId != offerId) return;
    int now = DateTime.now().millisecondsSinceEpoch;
    int diff = now - lastNewMessagePlayed;
    if (diff < 1000) return;
    lastNewMessagePlayed = now;

    if (messageSoundController == null) return;
    if (!messageSoundController.value.initialized) return;

    messageSoundController.setLooping(true);
    messageSoundController.setVolume(.1);
    messageSoundController.play();
    Future.delayed(Duration(seconds: 1), () {
      messageSoundController.pause();
    });
  }

  int lastTypingPlayed = 0;
  playTypingSound() async {
    if (visibleChatId != offerId) return;
    int now = DateTime.now().millisecondsSinceEpoch;
    int diff = now - lastTypingPlayed;
    if (diff < 2000) return;
    lastTypingPlayed = now;
    typingSoundController.setLooping(true);
    typingSoundController.setVolume(.1);
    typingSoundController.play();
  }

  List timePositions = List();
  int lastRefreshed = 0;
  int refreshedCounter = 0;
  refreshChatDates() async {
    int now = DateTime.now().millisecondsSinceEpoch;
    int diff = now - lastRefreshed;
    if (diff < 10000) return;
    lastRefreshed = now;
    timePositions.clear();
    if (refreshedCounter > 2) return;
    refreshedCounter++;
    print("Finding Time...");
    List<BaseModel> newList = [];
    for (BaseModel chat in offerList) {
      if (chatRemoved(chat)) continue;
      newList.add(chat);
    }
    print("New List ${newList.length}");
    for (int i = newList.length - 1; i >= 0; i--) {
      BaseModel chat = newList[i];
      int prevIndex = i + 1;
      BaseModel prevChat =
          prevIndex > newList.length - 1 ? null : newList[prevIndex];
      if (prevChat != null) {
        bool sameDay = isSameDay(chat.getTime(), prevChat.getTime());
        if (!sameDay) {
          timePositions.add(prevChat.getObjectId());
        }
//      timePositions.add(prevChat.documentId);
      }
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    // TODO: implement dispose

    for (StreamSubscription sub in subs) {
      sub.cancel();
    }
    WidgetsBinding.instance.removeObserver(this);
    typingSoundController.dispose();
    messageSoundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    return WillPopScope(
      onWillPop: () {
        visibleChatId = "";
        updateTyping(false);
        Navigator.pop(context);
        return;
      },
      child: Scaffold(
          resizeToAvoidBottomInset: true,
          key: scaffoldKey,
          backgroundColor: white,
          body: Stack(
            fit: StackFit.expand,
            children: [
              page(),
            ],
          )),
    );
  }

  int shownChatsCount = 10;
  int countIncrement = 10;

  bool isUserOnline() {
    int lastUpdated = offerModel.getInt(TIME_UPDATED);
    int now = DateTime.now().millisecondsSinceEpoch;
    int tsDiff = (now - lastUpdated);
    bool notOnline = (tsDiff > (Duration.millisecondsPerMinute * 10));
    bool isOnline = offerModel.getBoolean(IS_ONLINE) && (!notOnline);
    return isOnline;
  }

  bool isUserTyping() {
    int lastUpdated = offerModel.getInt(TIME_UPDATED);
    int now = DateTime.now().millisecondsSinceEpoch;
    int tsDiff = (now - lastUpdated);
    bool notOnline = (tsDiff > (Duration.millisecondsPerMinute * 10));
    bool isOnline = offerModel.getBoolean(IS_ONLINE) && (!notOnline);
    bool notTyping = (tsDiff > (Duration.millisecondsPerMinute * 1));
    bool isTyping = offerModel.getString(TYPING_ID) == offerId && (!notTyping);
    return isTyping;
  }

  bool isUserRecording() {
    int lastUpdated = offerModel.getInt(TIME_UPDATED);
    int now = DateTime.now().millisecondsSinceEpoch;
    int tsDiff = (now - lastUpdated);
    bool notOnline = (tsDiff > (Duration.millisecondsPerMinute * 10));
    bool isOnline = offerModel.getBoolean(IS_ONLINE) && (!notOnline);
    bool notRecording = (tsDiff > (Duration.millisecondsPerMinute * 5));
    bool isRecording =
        offerModel.getString(REC_ID) == offerId && (!notRecording);
    return isRecording;
  }

  bool isTyping = false;
  bool isRecording = false;
  bool isOnline = false;
  page() {
    List mutedList = List.from(userModel.getList(MUTED));
    bool isMuted = mutedList.contains(offerId);

    String image = getFirstPhoto(offerModel.images);
    String title = offerModel.getString(TITLE);
    String desc = offerModel.getString(DESCRIPTION);
    double price = offerModel.getDouble(PRICE);
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(0, 40, 0, 10),
          //color: black,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 50,
                    height: 30,
                    child: Center(
                        child: Icon(
                      Icons.arrow_back_ios,
                      color: black,
                      size: 20,
                    )),
                  )),
              Flexible(fit: FlexFit.tight,
                  child: Text("Bidding Room",style: textStyle(true,16,black),)),
              new Container(
                height: 30,
                width: 50,
                child: new FlatButton(
                    padding: EdgeInsets.all(0),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onPressed: () {
                      // postChatDoc();
                      userModel
                        ..putInList(MUTED, offerId, !isMuted)
                        ..updateItems();
                      setState(() {});
                    },
                    child: Center(
                        child:
//                        Icon(Icons.settings,color: white,)
                        Icon(
                          mutedList.contains(offerId)
                              ? Icons.notifications_off
                              : Icons.notifications_active,
                          size: 20,
                          color: mutedList.contains(offerId)
                              ? black.withOpacity(.7)
                              : black,
                        ))),
              ),
            ],
          ),
        ),
        Card(
          clipBehavior: Clip.antiAlias,
          color: default_white,
          elevation: .5,
          margin: EdgeInsets.fromLTRB(20,0,20,10),
          child: Row(
            children: [
              CachedNetworkImage(
                imageUrl: image,fit: BoxFit.cover,
                width: 100,height: 100,
              ),
              addSpaceWidth(10),
              Flexible(fit: FlexFit.tight,child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,style: textStyle(true, 18, black),),
                  addSpace(5),
                  Text(desc,style: textStyle(false, 14, black),maxLines: 1,overflow: TextOverflow.ellipsis,),
                  addSpace(5),
                  Text("\$$price",style: textStyle(true, 14, black.withOpacity(.5)),),
                ],
              )),
              addSpaceWidth(10),
            ],
          ),
        ),
        new Expanded(
            flex: 1,
            child: Builder(builder: (ctx) {
              if (!setup) return loadingLayout();

              if (offerList.isEmpty) return Container();
              return Container(
//                color: black,
                child: ScrollablePositionedList.builder(
                  itemScrollController: messageListController,
                  itemPositionsListener: itemPositionsListener,physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.all(0),
                  reverse: true,
                  itemBuilder: (c, p) {
                    BaseModel chat = offerList[p];
                    bool myItem = chat.getUserId() == userModel.getUserId();
                    int type = chat.getType();
                    bool showDate =
                        timePositions.contains(chat.getObjectId()) ||
                            p == getItemCount() - 1;

// return Container();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        new Column(
                          children: <Widget>[
                            new Center(
                              child: offerList.length < shownChatsCount ||
                                      p != shownChatsCount - 1 ||
                                      offerList.length == shownChatsCount
                                  ? Container()
                                  : new GestureDetector(
                                      onTap: () {
                                        loadMorePrev();
                                      },
                                      child: new Container(
                                        margin:
                                            EdgeInsets.fromLTRB(10, 10, 10, 0),
                                        padding:
                                            EdgeInsets.fromLTRB(10, 5, 10, 5),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Icon(
                                              Icons.rotate_left,
                                              size: 15,
                                              color: AppConfig.appColor,
                                            ),
                                            addSpaceWidth(5),
                                            Text(
                                              "Previous offers",
                                              style: textStyle(
                                                  true, 12, AppConfig.appColor),
                                            )
                                          ],
                                        ),
                                        decoration: BoxDecoration(
//                                                  color: brown04,
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            border: Border.all(
                                                color: AppConfig.appColor,
                                                width: 1)),
                                      ),
                                    ),
                            ),
                           /* if (showDate)
                              new Center(
                                  child: Container(
                                margin: EdgeInsets.fromLTRB(0,
                                    (p == getItemCount() - 1) ? 15 : 0, 0, 15),
                                child: Text(
                                  getChatDate(chat.getTime()),
                                  style:
                                      textStyle(false, 12, AppConfig.appColor),
                                ),
                                padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                decoration: BoxDecoration(
                                  color: black,
                                  borderRadius: BorderRadius.circular(25),
//                                    border: Border.all(
//                                        width: .5, color: blue0)
                                ),
                              )),*/

                            AnimatedOpacity(
                              opacity: blinkPosition == p ? (.3) : 1,
                              duration: Duration(milliseconds: 500),
                              child: Container(
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: myItem
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    myItem
                                        ? outgoingChatBid(
                                        context, chat, p == 0)
                                        : incomingChatBid(
                                        context, chat),

                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (p == 0)
                          isTyping
                              ? incomingChatTyping(context, chat, typing: true)
                              : isRecording
                                  ? incomingChatTyping(context, chat,
                                      typing: false)
                                  : Container()
                      ],
                    );
                  },
                  itemCount: (getItemCount()),
                ),
              );
            })),

        Center(
          child: Container(
            margin: EdgeInsets.all(15),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if(yourNewestOffer.getDouble(MY_BID)>0)Flexible(fit: FlexFit.loose,
                  child: Container(
                    height: 40,
                    margin: EdgeInsets.fromLTRB(0,0,5,0),
                    child: RaisedButton(
                      onPressed: () {


                      },
                      color: black,
//            padding: EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
//                          side: BorderSide(color: black)
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle,size: 16,color: white,),
                          addSpaceWidth(5),
                          Flexible(
                            child: Text(
                              "Accept \$${yourNewestOffer.getDouble(MY_BID)}",
                              style: textStyle(true, 14, white),maxLines: 1,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: Container(
                    height: 40,
                    margin: EdgeInsets.fromLTRB(5,0,0,0),
                    child: RaisedButton(
                      onPressed: () {
                        pushAndResult(context,ChatOfferDialog(bestOffer,true),result:(_){
                          String id = getRandomId();
                          BaseModel offerItem = BaseModel();
                          offerItem.put(OBJECT_ID, id);
                          offerItem.put(OFFER_ID, offerId);
                          offerItem.put(MY_BID, double.parse(_));
                          offerItem.put(PARTIES, [userModel.getUserId(), otherPerson.getUserId()]);
                          offerItem.saveItem(OFFER_BASE, true,document: id);
                          addOfferToList(offerItem);
                          setState(() {});
                          scrollToBottom();
                          updateTyping(false);
                        });
                      },
                      color: AppConfig.appColor,
//            padding: EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
//                          side: BorderSide(color: black)
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            ic_offer,
                            height: 16,
                            width: 16,
                            color: black,
                          ),
                          addSpaceWidth(5),
                          Flexible(
                            child: Text(
                              "Make New Offer",
                              style: textStyle(true, 14, black),maxLines: 1,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ],
    );
  }

  int getItemCount() {
    return offerList.length < shownChatsCount
        ? offerList.length
        : shownChatsCount;
  }

  postChatText(String text) {
    if (text.trim().isEmpty) {
      toastInAndroid("Type a message");
      return;
    }

    final String id = getRandomId();
    final BaseModel model = new BaseModel();
    model.put(CHAT_ID, offerId);

    bool sDate = showDate();
    //toastInAndroid(sDate.toString());
    model.put(
        PARTIES, [userModel.getObjectId(), offerModel.getString(USER_ID)]);
    model.put(SHOW_DATE, sDate);
    model.put(MESSAGE, text);
    model.put(TYPE, CHAT_TYPE_TEXT);
    model.put(OBJECT_ID, id);

    if (replyModel != null) {
      model.put(REPLY_DATA, replyModel.items);
      replyModel = null;
    }
    model.saveItem(OFFER_BASE, true, document: id, onComplete: () {
      pushChat(text);
    });


    addOfferToList(model);
    setState(() {});
    scrollToBottom();
    updateTyping(false);
  }

  bool showDate() {
    if (offerList.isEmpty) return true;
    BaseModel lastChat = offerList[0];
    return !isSameDay(
        lastChat.getTime(), DateTime.now().millisecondsSinceEpoch);
  }

  pushChat(String message) async {
    if (!offerModel.getList(MUTED).contains(offerId) &&
        offerModel.getBoolean(PUSH_NOTIFICATION)) {
//      String messageBody = '${getFullName(userModel).trim()}: $message';
      Map data = Map();
      data[TYPE] = PUSH_TYPE_CHAT;
      data[OBJECT_ID] = offerId;
      data[TITLE] = getFullName(userModel);
      data[MESSAGE] = message;
      NotificationService.sendPush(
          token: offerModel.getString(TOKEN),
          title: getFullName(userModel),
          body: message,
          tag: '${userModel.getObjectId()}chat',
          data: data);
    }
  }

  scrollToBottom() {
//    return;
    try {
      messageListController.jumpTo(
        index: 0,
      );
    } catch (e) {}
  }

  updateTyping(bool typing) {
    userModel
      ..put(REC_ID, null)
      ..put(TYPING_ID, typing ? offerId : null)
      ..updateItems();
  }

  updateRecording(bool recording) {
    userModel
      ..put(TYPING_ID, null)
      ..put(REC_ID, recording ? offerId : null)
      ..updateItems();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    if (state == AppLifecycleState.paused) {
      visibleChatId = "";
      updateTyping(false);
      typingSoundController.pause();
      messageSoundController.pause();
    }
    if (state == AppLifecycleState.resumed) {
      visibleChatId = offerId;
    }

    super.didChangeAppLifecycleState(state);
  }

  scrollToMessage(String id) {
    if (!mounted) return;
    showProgress(true, context);
    int position = getMessagePosition(id);

    print("The position: $position");
    if (position != -1) {
      Future.delayed(Duration(milliseconds: 1000), () {
        showProgress(false, context);

        Future.delayed(Duration(seconds: 1), () {
          messageListController.jumpTo(
            index: position,
          );

          Future.delayed(Duration(milliseconds: 500), () {
            blinkPosition = position;
            setState(() {});
            Future.delayed(Duration(seconds: 1), () {
              blinkPosition = -1;
              setState(() {});
            });
          });
        });
      });
      return;
    }
    if (shownChatsCount >= offerList.length) {
      print("Ignoring...");
      Future.delayed(Duration(milliseconds: 500), () {
        showProgress(false, context);
      });
      return;
    }

    loadMorePrev();
    Future.delayed(Duration(milliseconds: 1000), () {
      scrollToMessage(id);
    });
  }

  getMessagePosition(String id) {
    print("Finding Position...");
//      if (shownChatsCount >= offerList.length) return -1;

    for (int i = 0; i < shownChatsCount; i++) {
      BaseModel bm = offerList[i];
      if (chatRemoved(bm)) continue;
      if (bm.getObjectId() == id) {
        return i;
      }
    }

    return -1;
  }

  loadMorePrev() async {
    shownChatsCount = shownChatsCount + countIncrement;
    shownChatsCount =
        shownChatsCount >= offerList.length ? offerList.length : shownChatsCount;
    setState(() {});
  }

  incomingChatText(context, BaseModel chat) {
    String message = chat.getString(MESSAGE);

    BaseModel replyData = BaseModel(items: chat.getMap(REPLY_DATA));
    return new Stack(
      children: <Widget>[
        new GestureDetector(
          onLongPress: () {

          },
          child: Container(
              margin: EdgeInsets.fromLTRB(60, 0, 60, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    clipBehavior: Clip.antiAlias,
                    color: black.withOpacity(.2),
                    elevation: 5,
                    /*shadowColor: black.withOpacity(.3),*/
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                      topRight: Radius.circular(25),
                      topLeft: Radius.circular(0),
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    )),
                    child: new Container(
                      padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                      decoration: BoxDecoration(
//                    color: black,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            message,
                            style: textStyle(false, 17, black),
                          ),
                          addSpace(3),
                          Text(
                            /*timeAgo.format(
                            DateTime.fromMillisecondsSinceEpoch(
                                chat.getTime()),
                            locale: "en_short")*/
                            getChatTime(chat.getInt(TIME)),
                            style: textStyle(false, 12, black.withOpacity(.3)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
        ),
        offerModelImage(context)
      ],
    );
  }

  incomingChatTyping(context, BaseModel chat, {@required bool typing}) {
    return new Stack(
      children: <Widget>[
        Container(
            height: 40,
            margin: EdgeInsets.fromLTRB(60, 0, 60, 15),
            child: Column(
              children: [
                Card(
                  clipBehavior: Clip.antiAlias, color: default_white,
                  elevation: 5, //shadowColor: black.withOpacity(.3),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                    topRight: Radius.circular(25),
                    topLeft: Radius.circular(0),
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  )),
                  child: new Container(
                    padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                    decoration: BoxDecoration(
//                  color: black,
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                  color: AppConfig.appColor,
                                  shape: BoxShape.circle),
                            ),
                            addSpaceWidth(5),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                  color: AppConfig.appColor,
                                  shape: BoxShape.circle),
                            ),
                            addSpaceWidth(5),
                            Container(
                              width: 3,
                              height: 3,
                              decoration: BoxDecoration(
                                  color: AppConfig.appColor,
                                  shape: BoxShape.circle),
                            ),
                            addSpaceWidth(5),
                            if (!typing)
                              Icon(
                                Icons.mic,
                                color: AppConfig.appColor,
                                size: 12,
                              )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )),
        offerModelImage(context)
      ],
    );
  }

  outgoingChatBid(context, BaseModel chat, bool firstChat) {

    double myBid = chat.getDouble(MY_BID);
    String otherPersonId = getOtherPersonId(offerModel);
    bool read = chat.getList(READ_BY).contains(otherPersonId);

    bool newest = myNewestOffer.getObjectId()==chat.getObjectId();
    return Opacity(
      opacity: newest?1:(.5),
      child: new GestureDetector(
        onLongPress: () {
//        print(offerList.length);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 20, 5),
              child:
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                    decoration: BoxDecoration(
                        color: default_white,
                        borderRadius: BorderRadius.circular(25)
                    ),
                    child: Text(timeAgo.format(
                        DateTime.fromMillisecondsSinceEpoch(
                            chat.getTime()),
                        locale: "en_short"),style: textStyle(false,12,black),),
                  ),
      if (read && firstChat)
                  addSpaceWidth(5),
                  Icon(
                    Icons.remove_red_eye,
                    size: 12,
                    color: blue0,
                  ),

                ],
              ),

            ),
            Container(
              margin: EdgeInsets.fromLTRB(15, 0, 15, 15),
              height: 100,
//        width: 200,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Image.asset(bid_hand1,color: blue0,width: 100,height: 100,),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      height: 50,
                      padding: EdgeInsets.fromLTRB(20,5,20,5),
                      decoration: BoxDecoration(
                        color: blue0,
                          borderRadius: BorderRadius.all(Radius.circular(5))
                      ),
                      child: Text("\$$myBid",style: textStyle(true,30,white_color),),
                    ),
                  ),


                ],
              ),
            ),
//          Divider()
          ],
        ),
      ),
    );
  }


  incomingChatBid(context, BaseModel chat) {

    double myBid = chat.getDouble(MY_BID);
    String otherPersonId = getOtherPersonId(offerModel);

    bool newest = myNewestOffer.getObjectId()==chat.getObjectId();
    return Opacity(
      opacity: newest?1:(.5),
      child: new GestureDetector(
        onLongPress: () {
//        print(offerList.length);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(20, 0, 20, 5),
              child:
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                    decoration: BoxDecoration(
                        color: default_white,
                        borderRadius: BorderRadius.circular(25)
                    ),
                    child: Text(timeAgo.format(
                        DateTime.fromMillisecondsSinceEpoch(
                            chat.getTime()),
                        locale: "en_short")),
                  ),

                ],
              ),

            ),
            Container(
              margin: EdgeInsets.fromLTRB(15, 0, 15, 15),
              height: 100,
//        width: 200,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Image.asset(bid_hand,color: red0,width: 100,height: 100,),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      height: 50,
                      padding: EdgeInsets.fromLTRB(20,5,20,5),
                      decoration: BoxDecoration(
                        color: red0,
                          borderRadius: BorderRadius.all(Radius.circular(5))
                      ),
                      child: Text("\$$myBid",style: textStyle(true,30,white_color),),
                    ),
                  ),


                ],
              ),
            ),
//          Divider()
          ],
        ),
      ),
    );
  }



  offerModelImage(context) {
    return GestureDetector(
      onTap: () {
//        pushAndResult(
//            context,
//            ShowStore(
//              theUser: offerModel,
//            ),depend: false);
      },
      child: userImageItem(context, offerModel, size: 40, strokeSize: 1),
    );
  }

}

//keytool -list -v \-alias androiddebugkey -keystore ~/.android/debug.keystore
//keytool -exportcert -list -v \-alias key -keystore /Users/bappstack/RemoteJobs/strock/key.jsk
//keytool -exportcert -alias androiddebugkey -keystore ~/ -list -v
