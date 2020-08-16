import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:filesize/filesize.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_sound/flauto.dart';
import 'package:flutter_sound/flutter_sound_player.dart';
import 'package:flutter_sound/flutter_sound_recorder.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:maugost_apps/AppConfig.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/PreSendVideo.dart';
import 'package:maugost_apps/assets.dart';
import 'package:maugost_apps/basemodel.dart';
import 'package:maugost_apps/dialogs/listDialog.dart';
import 'package:maugost_apps/notificationService.dart';
import 'package:path/path.dart' as pathLib;
import 'package:path_provider/path_provider.dart' show getTemporaryDirectory;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shimmer/shimmer.dart';
import 'package:synchronized/synchronized.dart';
import 'package:vibration/vibration.dart';
import 'package:video_player/video_player.dart';

List<String> upOrDown = List();
List<String> noFileFound = List();
String visibleChatId = "";
BaseModel mainReplyItem;

class ChatMain extends StatefulWidget {
  String chatId;
  BaseModel otherPerson;
  ChatMain(this.chatId, {this.otherPerson});

  @override
  _ChatMainState createState() => _ChatMainState();
}

class _ChatMainState extends State<ChatMain>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  TextEditingController messageController = new TextEditingController();
  final ItemScrollController messageListController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  List<BaseModel> chatList = List();

  FocusNode messageNode = FocusNode();
  String chatId;
  BaseModel otherPerson;
  bool setup = false;

  bool showEmoji = false;
  bool keyboardVisible = false;
  bool amTyping = false;
  Timer timerType;
  String lastTypedText = "";
  int lastTyped = 0;
  List<String> fileThatExists = List();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  double xPosition = -1;
  double yPosition = -1;
  bool tappingDown = false;
//  double recButtonSize = 40;

  double sendSize = 40;
  var sendIcon = Icons.mic;
  VideoPlayerController typingSoundController;
  VideoPlayerController messageSoundController;
  BaseModel replyModel;
  int blinkPosition = -1;
  bool hasMessage = false;

  bool canSound = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    mainReplyItem = null;
    loadSound();
    loadRecorder();
    WidgetsBinding.instance.addObserver(this);
    setState(() {
      chatId = widget.chatId;
      visibleChatId = chatId;
      otherPerson = widget.otherPerson ?? BaseModel();
    });
    timerType = new Timer.periodic(Duration(seconds: 1), (_) {
      if (!keyboardVisible) {
        if (amTyping) {
          setState(() {
            amTyping = false;
            updateTyping(false);
          });
        }
        return;
      }
      String newText = messageController.text;
      if (newText.trim().isEmpty) return;

      int now = DateTime.now().millisecondsSinceEpoch;

      if (newText != (lastTypedText)) {
        if (!amTyping) {
          amTyping = true;
          updateTyping(true);
          setState(() {});
        }
      } else {
        if ((now - lastTyped) > 2000) {
          if (amTyping) {
            amTyping = false;
            updateTyping(false);
            setState(() {});
          }
        }
      }

      lastTypedText = newText;
    });
    KeyboardVisibility.onChange.listen((bool visible) {
      keyboardVisible = visible;
      print("Keyboard Visible $visible");
      if (!visible) {
        amTyping = false;
        updateTyping(false);
        setState(() {});
      }
      if (showEmoji && visible) {
        showEmoji = false;
        setState(() {});
      }
    });
    var audioSub = recAudioController.onPlayerCompletion.listen((event) {
      setState(() {
        isPlaying = false;
      });
    });
    subs.add(audioSub);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
    if (widget.otherPerson != null) {
      loadChat();
      refreshOtherUser();
      return;
    }

    if (chatId == null || chatId.isEmpty) return;
    DocumentSnapshot doc = await Firestore.instance
        .collection(CHAT_IDS_BASE)
        .document(chatId)
        .get();
    if (!doc.exists) return;
    String otherId = getOtherPersonId(BaseModel(doc: doc));
    if (otherId == null || otherId.isEmpty) return;
    DocumentSnapshot person =
        await Firestore.instance.collection(USER_BASE).document(otherId).get();
    if (!person.exists) return;
    otherPerson = BaseModel(doc: person);
    loadChat();
    refreshOtherUser();
  }

  refreshOtherUser() async {
    String otherPersonId = widget.otherPerson.getUserId();
    if (otherPersonId == null || otherPersonId.isEmpty) return;
    var sub = Firestore.instance
        .collection(USER_BASE)
        .document(otherPersonId)
        .snapshots()
        .listen((shot) {
      otherPerson = BaseModel(doc: shot);
      if (userModel.getList(BLOCKED).contains(otherPersonId)) {
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pop(context);
        });
      }
      int now = DateTime.now().millisecondsSinceEpoch;
      int lastUpdated = otherPerson.getInt(TIME_UPDATED);
      int tsDiff = (now - lastUpdated);
      bool notOnline = (tsDiff > (Duration.millisecondsPerMinute * 10));
      bool notTyping = (tsDiff > (Duration.millisecondsPerMinute * 1));
      isOnline = otherPerson.getBoolean(IS_ONLINE) && (!notOnline);
      isTyping = otherPerson.getString(TYPING_ID) == chatId && (!notTyping);
      bool notRecording = (tsDiff > (Duration.millisecondsPerMinute * 5));
      isRecording = otherPerson.getString(REC_ID) == chatId && (!notRecording);
      if (mounted) setState(() {});

      /*if(typingController!=null && typingController.value.initialized) {
        if (isTyping) {
          typingController.play();
        }else{
          typingController.pause();
        }
      }*/
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
    if (chatId == null || chatId.isEmpty) return;
    print("my chat id $chatId");
    var sub = Firestore.instance
        .collection(CHAT_BASE)
        .where(CHAT_ID, isEqualTo: chatId)
        .orderBy(CREATED_AT, descending: false)
        .snapshots()
        .listen((shots) async {
      for (DocumentChange docChange in shots.documentChanges) {
        if (docChange.type == DocumentChangeType.added &&
            loadedChatIds.contains(docChange.document.documentID)) continue;
        DocumentSnapshot doc = docChange.document;
        BaseModel chat = BaseModel(doc: doc);
//        print("New Message in Chat... $chatId");
        addChatToList(chat);
        final readBy = chat.getList(READ_BY);
        bool hasRead = readBy.contains(userModel.getString(USER_ID));
//        bool myChat = chat.getString(USER_ID) == currentUser.getString(USER_ID);
        if (!chat.myItem() && !hasRead) {
          readBy.add(userModel.getString(USER_ID));
          chat.put(READ_BY, readBy);
          chat.updateItems();
        }
      }
      refreshChatDates();
      setup = true;
      if (mounted) setState(() {});
    });

    subs.add(sub);
  }

  List loadedChatIds = [];
  void addChatToList(BaseModel chat) async {
    //chatList.insert(0, chat);
    var lock = Lock();
    await lock.synchronized(() {
      int p = chatList
          .indexWhere((BaseModel c) => chat.getObjectId() == c.getObjectId());
      if (p != -1) {
        chatList[p] = chat;
        print("updating chat at $p");
//        if(mounted)setState(() {});
      } else {
        if (!chat.myItem()) playNewMessageSound();
        chatList.insert(0, chat);
//        if(mounted)setState(() {});
        if (!loadedChatIds.contains(chat.getObjectId()))
          loadedChatIds.add(chat.getObjectId());
        if (chat.getInt(TYPE) == CHAT_TYPE_DOC ||
            chat.getInt(TYPE) == CHAT_TYPE_REC) {
          checkIfFileExists(chat, false);
        }
      }
    });
  }

  int lastNewMessagePlayed = 0;
  playNewMessageSound() async {
    if (visibleChatId != chatId) return;
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
    if (visibleChatId != chatId) return;
    int now = DateTime.now().millisecondsSinceEpoch;
    int diff = now - lastTypingPlayed;
    if (diff < 2000) return;
    lastTypingPlayed = now;
    typingSoundController.setLooping(true);
    typingSoundController.setVolume(.1);
    typingSoundController.play();
  }

//  List checkedList = [];
  checkIfFileExists(BaseModel model, bool notify) async {
    String fileName =
        "${model.getObjectId()}.${model.getString(FILE_EXTENSION)}";
    File file = await getDirFile(fileName);
    bool fileExists = await file.exists();
    if (fileExists) {
      fileThatExists.add(model.getObjectId());
    }
    if (/*notify &&*/ mounted) setState(() {});
  }

  handleAudio(BaseModel model) async {
    var lock = Lock();
    await lock.synchronized(() {
      if (!audioSetupList.contains(model.getObjectId())) {
        audioSetupList.add(model.getObjectId());
        if (model.getString(AUDIO_URL).isEmpty && model.myItem()) {
          saveChatAudio(model);
        }
      }
    });
  }

  saveChatAudio(BaseModel chat) async {
    String audioPath = chat.getString(AUDIO_PATH);
    bool exists = await File(audioPath).exists();
    if (!exists) {
      noFileFound.add(chat.getObjectId());
      setState(() {});
      return;
    }
    upOrDown.add(chat.getObjectId());
    uploadFile(File(audioPath), (url, error) {
      upOrDown.removeWhere((s) => s == chat.getObjectId());
      if (error != null) {
        setState(() {});
        return;
      }
      chat.put(AUDIO_URL, url);
      chat.updateItems();
      setState(() {});
    });
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
    for (BaseModel chat in chatList) {
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
    try {
      flutterSound?.release();
      soundPlayer?.release();
    } catch (err) {
      print('stopRecorder error: $err');
    }
    if (timerType != null) timerType.cancel();
//    updateTyping(false);

    for (StreamSubscription sub in subs) {
      sub.cancel();
    }
    WidgetsBinding.instance.removeObserver(this);
    typingSoundController.dispose();
    messageSoundController.dispose();
    super.dispose();
  }

  ScreenHeight screenHeight;
  @override
  Widget build(BuildContext c) {
    return WillPopScope(
      onWillPop: () {
        if (showEmoji) {
          showEmoji = false;
          setState(() {});
          return;
        }
        visibleChatId = "";
        updateTyping(false);
        recAudioController?.release();
        Navigator.pop(context);
        return;
      },
      child: KeyboardDismisser(
        gestures: [
          GestureType.onTap,
          GestureType.onPanUpdateDownDirection,
        ],
        child: KeyboardSizeProvider(
          smallSize: 500.0,
          child: Consumer<ScreenHeight>(
              builder: (context, ScreenHeight sh, child) {
            this.screenHeight = sh;
//              print("New Height: ${screenHeight.screenHeight}");
            return Scaffold(
                resizeToAvoidBottomInset: true,
                key: scaffoldKey,
                backgroundColor: white,
                body: Stack(
                  fit: StackFit.expand,
                  children: [
                    page(),
                    if (tooShort)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: IgnorePointer(
                          ignoring: true,
                          child: Container(
                            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                            margin: EdgeInsets.fromLTRB(0, 0, 10, 70),
                            decoration: BoxDecoration(
                                color: black.withOpacity(.8),
                                borderRadius: BorderRadius.circular(10)),
                            child: Text(
                              "Hold to start recording",
                              style: textStyle(true, 12, white),
                            ),
                          ),
                        ),
                      ),
                    if (recording && !canCancelRecording())
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Container(
                          margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: Text(
                            recordTimerText,
                            style: textStyle(true, 20, AppConfig.appColor),
                          ),
                        ),
                      ),
                    if (!hasMessage)
                      Positioned(
                        top: screenHeight.screenHeight -
                            (screenHeight.keyboardHeight) -
                            (77),
                        left: xPosition == -1
                            ? getScreenWidth(context) - (200)
                            : xPosition - 170,
//                  width: 80,
//                  height: 80,
                        child: Opacity(
                          opacity: !recording ? 0 : 1,
                          child: Row(
                            children: <Widget>[
                              IgnorePointer(
                                ignoring: true,
                                child: Container(
                                  margin: EdgeInsets.only(right: 10, top: 10),
                                  child: Shimmer.fromColors(
                                    baseColor: Colors.red,
                                    highlightColor: Colors.yellow,
                                    direction: ShimmerDirection.rtl,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.arrow_back_ios,
                                          color: black.withOpacity(.5),
                                        ),
                                        addSpaceWidth(5),
                                        Text(
                                          "Slide to Cancel",
                                          style: textStyle(
                                              false, 14, black.withOpacity(.5)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onPanDown: (u) async {
                                  holdToRecord(u);
                                },
                                onPanStart: (u) {
                                  holdToRecord(u);
                                },
                                onPanEnd: (u) {
                                  tappingDown = false;
                                  stopRecording();
                                },
                                onPanCancel: () {
                                  tappingDown = false;
                                  stopRecording();
                                },
                                onPanUpdate: (u) {
                                  if (stopUpdatingPosition) return;
                                  xPosition = u.globalPosition.dx;
                                  yPosition = u.globalPosition.dy;
                                  setState(() {});
                                  if (canCancelRecording() && recording)
                                    Future.delayed(Duration(milliseconds: 100),
                                        () {
                                      stopUpdatingPosition = true;
                                      cancelled = true;
                                      stopRecording();
                                    });
                                },
                                child: Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                      color: AppConfig.appColor,
                                      shape: BoxShape.circle),
                                  child: Center(
                                    child: Icon(
                                      Icons.mic,
                                      color: white,
                                      size: 50,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ));
          }),
        ),
      ),
    );
  }

  int shownChatsCount = 10;
  int countIncrement = 10;

  bool isUserOnline() {
    int lastUpdated = otherPerson.getInt(TIME_UPDATED);
    int now = DateTime.now().millisecondsSinceEpoch;
    int tsDiff = (now - lastUpdated);
    bool notOnline = (tsDiff > (Duration.millisecondsPerMinute * 10));
    bool isOnline = otherPerson.getBoolean(IS_ONLINE) && (!notOnline);
    return isOnline;
  }

  bool isUserTyping() {
    int lastUpdated = otherPerson.getInt(TIME_UPDATED);
    int now = DateTime.now().millisecondsSinceEpoch;
    int tsDiff = (now - lastUpdated);
    bool notOnline = (tsDiff > (Duration.millisecondsPerMinute * 10));
    bool isOnline = otherPerson.getBoolean(IS_ONLINE) && (!notOnline);
    bool notTyping = (tsDiff > (Duration.millisecondsPerMinute * 1));
    bool isTyping = otherPerson.getString(TYPING_ID) == chatId && (!notTyping);
    return isTyping;
  }

  bool isUserRecording() {
    int lastUpdated = otherPerson.getInt(TIME_UPDATED);
    int now = DateTime.now().millisecondsSinceEpoch;
    int tsDiff = (now - lastUpdated);
    bool notOnline = (tsDiff > (Duration.millisecondsPerMinute * 10));
    bool isOnline = otherPerson.getBoolean(IS_ONLINE) && (!notOnline);
    bool notRecording = (tsDiff > (Duration.millisecondsPerMinute * 5));
    bool isRecording =
        otherPerson.getString(REC_ID) == chatId && (!notRecording);
    return isRecording;
  }

  bool isTyping = false;
  bool isRecording = false;
  bool isOnline = false;
  page() {
    List mutedList = List.from(userModel.getList(MUTED));
    bool isMuted = mutedList.contains(chatId);
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(0, 40, 0, 10),
          color: white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              InkWell(
                  onTap: () {
                    recAudioController?.release();
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 50,
                    height: 30,
                    child: Center(
                        child: Icon(
                      Icons.arrow_back_ios,
                      //color: white,
                      size: 20,
                    )),
                  )),
              if (otherPerson != null)
                Flexible(
                    fit: FlexFit.tight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          otherPerson.getString(NAME),
                          style: textStyle(true, 18, black),
                          maxLines: 1,
                        ),
                        if (getLastSeen(otherPerson) != null)
                          Text(
                            getLastSeen(otherPerson),
                            style:
                                textStyle(false, 12, textColor.withOpacity(.3)),
                            maxLines: 1,
                          ),
                      ],
                    )),
//              Spacer(),
              new Container(
                height: 30,
                width: 50,
                child: new FlatButton(
                    padding: EdgeInsets.all(0),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onPressed: () {
                      // postChatDoc();
                      userModel
                        ..putInList(MUTED, chatId, !isMuted)
                        ..updateItems();
                      setState(() {});
                    },
                    child: Center(
                        child:
//                        Icon(Icons.settings,color: white,)
                            Icon(
                      mutedList.contains(chatId)
                          ? Icons.notifications_off
                          : Icons.notifications_active,
                      size: 20,
                      color: mutedList.contains(chatId)
                          ? black.withOpacity(.7)
                          : black,
                    ))),
              ),
            ],
          ),
        ),
        new Expanded(
            flex: 1,
            child: Builder(builder: (ctx) {
              if (!setup) return loadingLayout();

              if (chatList.isEmpty) return Container();
              return Container(
                color: white,
                child: ScrollablePositionedList.builder(
                  itemScrollController: messageListController,
                  itemPositionsListener: itemPositionsListener,
                  padding: EdgeInsets.all(0),
                  reverse: true,
                  itemBuilder: (c, p) {
                    BaseModel chat = chatList[p];
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
                              child: chatList.length < shownChatsCount ||
                                      p != shownChatsCount - 1 ||
                                      chatList.length == shownChatsCount
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
                                              "Previous messages",
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
                            if (showDate)
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
                                  color: white,
                                  borderRadius: BorderRadius.circular(25),
//                                    border: Border.all(
//                                        width: .5, color: blue0)
                                ),
                              )),

                            AnimatedOpacity(
                              opacity: blinkPosition == p ? (.3) : 1,
                              duration: Duration(milliseconds: 500),
                              child: Container(
                                width: double.infinity,
                                child: Dismissible(
                                  key: Key(getRandomId()),
                                  direction: DismissDirection.startToEnd,
                                  confirmDismiss: (_) async {
                                    if (chatRemoved(chat))
                                      return Future.value(false);
                                    replyModel = chat;
                                    FocusScope.of(context)
                                        .requestFocus(messageNode);
                                    setState(() {});
                                    return Future.value(false);
                                  },
                                  dismissThresholds: {
                                    DismissDirection.startToEnd: 0.1,
                                    DismissDirection.endToStart: 0.7
                                  },
                                  child: Column(
                                    crossAxisAlignment: myItem
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      myItem
                                          ? Builder(
                                              builder: (ctx) {
                                                if (type == CHAT_TYPE_TEXT)
                                                  return outgoingChatText(
                                                      context, chat, p == 0);

                                                if (type == CHAT_TYPE_IMAGE)
                                                  return outgoingChatImage(
                                                      context, chat, () {
                                                    setState(() {});
                                                  }, p == 0);

                                                if (type == CHAT_TYPE_REC) {
                                                  return Container(
                                                    child: getChatAudioWidget(
                                                        context, chat,
                                                        (removed) {
                                                      if (removed) {
                                                        chatList.removeAt(p);
                                                      }
                                                      if (mounted)
                                                        setState(() {});
                                                    }, p == 0),
                                                  );
                                                }
                                                if (type == CHAT_TYPE_DOC)
                                                  return outgoingChatDoc(
                                                      context, chat, () {
                                                    pushChat("Sent a document");
                                                    setState(() {});
                                                  }, p == 0);
                                                return outgoingChatVideo(
                                                    context, chat, () {
                                                  pushChat("Sent a video");
                                                  setState(() {});
                                                }, p == 0);
                                              },
                                            )
                                          : Builder(builder: (ctx) {
                                              if (type == CHAT_TYPE_TEXT)
                                                return incomingChatText(
                                                    context, chat);

                                              if (type == CHAT_TYPE_REC) {
                                                return Container(
                                                  child: getChatAudioWidget(
                                                      context, chat, (removed) {
                                                    if (removed) {
                                                      chatList.removeAt(p);
                                                    }
                                                    if (mounted)
                                                      setState(() {});
                                                  }, p == 0),
                                                );
                                              }

                                              if (type == CHAT_TYPE_IMAGE)
                                                return incomingChatImage(
                                                    context, chat);
                                              if (type == CHAT_TYPE_DOC)
                                                return incomingChatDoc(
                                                    context,
                                                    chat,
                                                    fileThatExists.contains(
                                                        chat.getObjectId()),
                                                    () {
                                                  checkIfFileExists(chat, true);
                                                });
                                              return incomingChatVideo(
                                                  context, chat);
                                            }),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // if(blinkPosition==p)Container(width: double.infinity,
                            // height: 20,color:blue0,margin: EdgeInsets.only(bottom:20),)
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
        addLine(.5, black.withOpacity(.2), 0, 0, 0, 0),
        if (setup && !recording)
          Container(
            width: double.infinity,
            color: chat_back,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  if (!hasMessage)
                    Container(
                      height: 60,
                      width: 50,
                      child: FlatButton(
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.all(0),
                          onPressed: () {
                            showListDialog(context, ["Photo", "Video"], (p) {
                              if (p == 0) postChatImage();
                              if (p == 1) postChatVideo(false);
                            }, images: [Icons.image, Icons.videocam]);
                          },
                          child: Icon(
                            Icons.camera_alt,
                            color: black.withOpacity(.5),
                            size: 20,
                          )),
                    ),
                  Flexible(
                    flex: 1,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      padding: EdgeInsets.fromLTRB(15, 0, 5, 0),
                      decoration: BoxDecoration(
//                          color: white,
                          borderRadius: replyModel != null
                              ? (BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomRight: Radius.circular(25),
                                  bottomLeft: Radius.circular(25)))
                              : BorderRadius.all(Radius.circular(25))),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (replyModel != null)
                            chatReplyWidget(
                              replyModel,
                              fitScreen: true,
                              onRemoved: () {
                                replyModel = null;
                                setState(() {});
                              },
                            ),
                          new ConstrainedBox(
                            constraints:
                                BoxConstraints(maxHeight: 120, minHeight: 45),
                            child: Container(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (hasMessage) addSpaceWidth(15),
                                  Flexible(
                                    fit: FlexFit.tight,
                                    child: new TextField(
//                                      onSubmitted: (_) {
//                                        postChatText();
//                                      },
                                      onChanged: (String text) {
//                                        if(checking)return;
//                                        checking=true;
                                        lastTyped = DateTime.now()
                                            .millisecondsSinceEpoch;
                                        bool empty = text.trim().isEmpty;
                                        if (empty && hasMessage) {
                                          hasMessage = false;
                                          setState(() {});
                                        }
                                        if (!empty && !hasMessage) {
                                          hasMessage = true;
                                          setState(() {});
                                        }
//                                        checking=false;
                                      },
                                      //textInputAction: TextInputAction.newline,
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      decoration: InputDecoration(
                                          hintText: "Type a message",
                                          isDense: true,
                                          hintStyle: textStyle(
                                              false, 17, black.withOpacity(.3)),
                                          border: InputBorder.none),
                                      style: textStyle(false, 17, black),
                                      controller: messageController,
                                      cursorColor: black,
                                      cursorWidth: 1,
                                      maxLines: null,
                                      keyboardType: TextInputType.multiline,
                                      focusNode: messageNode, autofocus: true,
                                      scrollPadding:
                                          EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    ),
                                  ),
//                                  Container(
//                                    height: 40,
//                                    width: 30,
//                                    child: FlatButton(
//                                        materialTapTargetSize:
//                                        MaterialTapTargetSize.shrinkWrap,
//                                        padding: EdgeInsets.all(0),
//                                        onPressed: () {
//                                          postChatDoc();
//                                        },
//                                        child: Icon(
//                                          Icons.attach_file,
//                                          color: black.withOpacity(.5),
//                                          size: 20,
//                                        )),
//                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    height: 45,
                    width: 45,
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: FloatingActionButton(
                      onPressed: () {
                        if (!hasMessage) {
                          return;
                        }
                        postChatText();
                      },
                      heroTag: "sendBut",
                      child: Icon(
                        !hasMessage ? Icons.mic : Icons.send,
                        color: black.withOpacity(.5),
                        size: hasMessage ? 16 : null,
                      ),
                      backgroundColor: white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (setup && recording)
          Container(
            height: 60,
            color: (canCancelRecording()) ? red0 : white,
          ),
        if (showEmoji)
          EmojiPicker(
            onEmojiSelected: (emoji, category) {
              String text = messageController.text;
              StringBuffer sb = StringBuffer();
              sb.write(text);
              sb.write(emoji.emoji);
              messageController.text = sb.toString();
//              message = sb.toString();
              setState(() {});
            },
            //recommendKeywords: ["happy", "love"],
          )
      ],
    );
  }

  bool canCancelRecording() {
    return xPosition < (getScreenWidth(context) / 1.5);
  }

  int getItemCount() {
    return chatList.length < shownChatsCount
        ? chatList.length
        : shownChatsCount;
  }

  postChatText() {
    String text = messageController.text;
    if (text.trim().isEmpty) {
      toastInAndroid("Type a message");
      return;
    }

    final String id = getRandomId();
    final BaseModel model = new BaseModel();
    model.put(CHAT_ID, chatId);

    bool sDate = showDate();
    //toastInAndroid(sDate.toString());
    model.put(
        PARTIES, [userModel.getObjectId(), otherPerson.getString(USER_ID)]);
    model.put(SHOW_DATE, sDate);
    model.put(MESSAGE, text);
    model.put(TYPE, CHAT_TYPE_TEXT);
    model.put(OBJECT_ID, id);

    if (replyModel != null) {
      model.put(REPLY_DATA, replyModel.items);
      replyModel = null;
    }
    model.saveItem(CHAT_BASE, true, document: id, onComplete: () {
      pushChat(text);
    });

    messageController.text = "";
    hasMessage = false;
//    message = "";
    sendIcon = Icons.mic;
    addChatToList(model);
    setState(() {});
    scrollToBottom();
    updateTyping(false);
  }


  bool showDate() {
    if (chatList.isEmpty) return true;
    BaseModel lastChat = chatList[0];
    return !isSameDay(
        lastChat.getTime(), DateTime.now().millisecondsSinceEpoch);
  }

  pushChat(String message) async {
    if (!otherPerson.getList(MUTED).contains(chatId) &&
        otherPerson.getBoolean(PUSH_NOTIFICATION)) {
//      String messageBody = '${getFullName(userModel).trim()}: $message';
      Map data = Map();
      data[TYPE] = PUSH_TYPE_CHAT;
      data[OBJECT_ID] = chatId;
      data[TITLE] = getFullName(userModel);
      data[MESSAGE] = message;
      NotificationService.sendPush(
          token: otherPerson.getString(TOKEN),
          title: getFullName(userModel),
          body: message,
          tag: '${userModel.getObjectId()}chat',
          data: data);
    }
  }

  postChatImage() async {
    getSingleCroppedImage(context, onPicked: (String path) {
      final String id = getRandomId();
      final BaseModel model = new BaseModel();
      model.put(CHAT_ID, chatId);
      model.put(
          PARTIES, [userModel.getObjectId(), otherPerson.getString(USER_ID)]);
      model.put(SHOW_DATE, showDate());
      model.put(TYPE, CHAT_TYPE_IMAGE);
      model.put(IMAGE_PATH, path);
      model.put(OBJECT_ID, id);
      model.put(DATABASE_NAME, CHAT_BASE);

      upOrDown.add(model.getObjectId());
      if (replyModel != null) {
        model.put(REPLY_DATA, replyModel.items);
        replyModel = null;
      }
      model.saveItem(CHAT_BASE, true, document: id, onComplete: () {
        saveChatFile(model, IMAGE_PATH, IMAGE_URL, () {
          addChatToList(model);
          setState(() {});
          pushChat('sent a photo');
        });
      });

      addChatToList(model);
      setState(() {});
      print("setting State...");
      scrollToBottom();
    });
  }

  postChatVideo(bool froCam) async {
    getSingleVideo(context, onPicked: (BaseModel videoResult) {
      pushAndResult(
          context,
          PreSendVideo(
            File(videoResult.getString(VIDEO_PATH)),
          ), result: (_) {
        String videoLength = _;

        final String id = getRandomId();
        final BaseModel model = new BaseModel();
        model.put(CHAT_ID, chatId);
        model.put(
            PARTIES, [userModel.getObjectId(), otherPerson.getString(USER_ID)]);

        model.put(SHOW_DATE, showDate());
        model.put(TYPE, CHAT_TYPE_VIDEO);
        model.put(THUMBNAIL_PATH, videoResult.getString(THUMBNAIL_PATH));
        model.put(VIDEO_PATH, videoResult.getString(VIDEO_PATH));
        model.put(VIDEO_LENGTH, videoLength);
        model.put(OBJECT_ID, id);
        model.put(DATABASE_NAME, CHAT_BASE);

        upOrDown.add(model.getObjectId());
        if (replyModel != null) {
          model.put(REPLY_DATA, replyModel.items);
          replyModel = null;
        }
        model.saveItem(CHAT_BASE, true, document: id, onComplete: () {
          saveChatVideo(model, () {
            addChatToList(model);
            setState(() {});
            pushChat('sent a video');
          });
        });

        addChatToList(model);
        setState(() {});
        scrollToBottom();
      });
    });
  }

  postChatAudio() async {
    String path = await localPath;
    File newFile = await File(recordingFilePath)
        .copy("$path/${DateTime.now().millisecondsSinceEpoch}chatRec.aac");

    final String id = getRandomId();
    BaseModel chat = BaseModel();
    if (replyModel != null) {
      chat.put(REPLY_DATA, replyModel.items);
      replyModel = null;
    }
    chat
      ..put(CHAT_ID, chatId)
      ..put(PARTIES, [userModel.getUserId(), otherPerson.getObjectId()])
      ..put(TYPE, CHAT_TYPE_REC)
      ..put(AUDIO_LENGTH, recordTimerText)
      ..put(AUDIO_PATH, newFile.path)
      ..put(OBJECT_ID, id)
      ..saveItem(CHAT_BASE, true, document: id, onComplete: () {
        pushChat("a voice note");
      });
    handleAudio(chat);
    addChatToList(chat);
    setState(() {});
    scrollToBottom();
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
      ..put(TYPING_ID, typing ? chatId : null)
      ..updateItems();
  }

  updateRecording(bool recording) {
    userModel
      ..put(TYPING_ID, null)
      ..put(REC_ID, recording ? chatId : null)
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
      visibleChatId = chatId;
    }

    super.didChangeAppLifecycleState(state);
  }

  prepareRecording(u) async {
    if (recording) return;
    recording = true;
    xPosition = u.globalPosition.dx;
    yPosition = u.globalPosition.dy;
    cancelled = false;
    stopUpdatingPosition = false;
    recordTimer = 0;
    recordTimerText = "00:00";
    recordingOpacity = 1;
    createRecordTimer();
    startRecorder();
    updateRecording(true);
    setState(() {});
  }

  stopRecording() {
    if (!recording) return;
    recording = false;
    xPosition = -1;
    yPosition = -1;
    setState(() {});
    stopRecorder();
    updateRecording(false);
    recordTimer = 0;
    setState(() {});
    if (!cancelled && !tooShort) {
      postChatAudio();
    }
  }

  double bSize = 100;
//  double cSize = 0;
  //double cSize1 = 0;
//  double holdOpacity = 0;
  String recLength = "";
  String recordingFilePath = "";
  FlutterSoundPlayer soundPlayer = new FlutterSoundPlayer();
  FlutterSoundRecorder flutterSound = new FlutterSoundRecorder();
  VideoPlayerController audioController;
  bool timerCounting = false;
  int timerCount = 4;
  double timerOpacity = 0;
  bool cancelled = false;
  bool stopUpdatingPosition = false;
  bool recording = false;
  int recordTimer = 0;
  int maxRecordTime = 30;
  String recordTimerText = "00:00";
  double recordingOpacity = 1;
  createRecordTimer() {
    Future.delayed(Duration(seconds: 1), () {
      if (!recording) {
        return;
      }
      recordTimer++;
      if (recordTimer > 30) {
        stopRecording();
        return;
      }
      recordingOpacity = recordingOpacity == 1 ? 0 : 1;

      int min = recordTimer ~/ 60;
      int sec = recordTimer % 60;

      String m = min.toString();
      String s = sec.toString();

      String ms = m.length == 1 ? "0$m" : m;
      String ss = s.length == 1 ? "0$s" : s;

      recordTimerText = "$ms:$ss";

      setState(() {});
      createRecordTimer();
    });
  }

  void startRecorder() async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      t_CODEC _codec = t_CODEC.CODEC_AAC;
      recordingFilePath = await flutterSound.startRecorder(
        uri: '${tempDir.path}/sound.aac',
        codec: _codec,
      );

      print("Rec at $recordingFilePath");
    } catch (err) {
      print('startRecorder error: ${err.toString()}');
    }
  }

  bool tooShort = false;
  void stopRecorder() async {
    recLength = recordTimerText;
    if (recordTimer < 1) {
      tooShort = true;
      setState(() {});
    }
    try {
      await flutterSound.stopRecorder();
    } catch (err) {
      print('stopRecorder error: $err');
    }
    if (tooShort || cancelled) {
      File(recordingFilePath).delete();
      Vibration.vibrate(duration: 100);
    }

    Future.delayed(Duration(seconds: 1), () {
      tooShort = false;
      cancelled = false;
      setState(() {});
    });
  }

  loadRecorder() async {
    soundPlayer = await FlutterSoundPlayer().initialize();
    flutterSound = await FlutterSoundRecorder().initialize();
    flutterSound.setSubscriptionDuration(0.01);
    flutterSound.setDbPeakLevelUpdate(0.8);
    flutterSound.setDbLevelEnabled(true);
    print("Loaded Recorder");
  }

  holdToRecord(u) {
    tappingDown = true;
//    FocusScope.of(context).requestFocus(FocusNode());
    Future.delayed(Duration(milliseconds: 500), () {
      if (!tappingDown) {
        tooShort = true;
        Vibration.vibrate(duration: 100);
        setState(() {});
        Future.delayed(Duration(seconds: 1), () {
          tooShort = false;
          setState(() {});
        });
        return;
      }
      prepareRecording(u);
    });
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
    if (shownChatsCount >= chatList.length) {
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
//      if (shownChatsCount >= chatList.length) return -1;

    for (int i = 0; i < shownChatsCount; i++) {
      BaseModel bm = chatList[i];
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
        shownChatsCount >= chatList.length ? chatList.length : shownChatsCount;
    setState(() {});
  }

  incomingChatText(context, BaseModel chat) {
    if (chat.getBoolean(DELETED)) {
      return incomingChatDeleted(context, chat);
    }
    if (chat.getList(HIDDEN).contains(userModel.getObjectId())) {
      return Container();
    }

    String message = chat.getString(MESSAGE);

    BaseModel replyData = BaseModel(items: chat.getMap(REPLY_DATA));
    return new Stack(
      children: <Widget>[
        new GestureDetector(
          onLongPress: () {
            showChatOptions(context, chat);
          },
          child: Container(
              margin: EdgeInsets.fromLTRB(60, 0, 60, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (replyData.items.isNotEmpty)
                    chatReplyWidget(
                      replyData,
                    ),
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
//                    color: white,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            message,
                            style: textStyle(false, 17, white),
                          ),
                          addSpace(3),
                          Text(
                            /*timeAgo.format(
                            DateTime.fromMillisecondsSinceEpoch(
                                chat.getTime()),
                            locale: "en_short")*/
                            getChatTime(chat.getInt(TIME)),
                            style: textStyle(false, 12, white.withOpacity(.3)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
        ),
        otherPersonImage(context)
      ],
    );
  }

  incomingChatDeleted(context, BaseModel chat) {
    if (chat.getList(HIDDEN).contains(userModel.getObjectId())) {
      return Container();
    }
    return new Stack(
      children: <Widget>[
        GestureDetector(
          onLongPress: () {
            showChatOptions(context, chat, deletedChat: true);
          },
          child: Container(
              margin: EdgeInsets.fromLTRB(60, 0, 60, 15),
              child: Card(
                clipBehavior: Clip.antiAlias,
                color: default_white,
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
//                    color: white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Deleted",
                            style: textStyle(false, 15, black),
                          ),
                          addSpaceWidth(5),
                          Icon(
                            Icons.info,
                            color: red0,
                            size: 17,
                          )
                        ],
                      ),
                      /*addSpace(3),
                Text(
                  */ /*timeAgo.format(
                        DateTime.fromMillisecondsSinceEpoch(
                            chat.getTime()),
                        locale: "en_short")*/ /*
                  getChatTime(chat.getInt(TIME)),
                  style: textStyle(false, 12, black.withOpacity(.3)),
                ),*/
                    ],
                  ),
                ),
              )),
        ),
        otherPersonImage(context)
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
//                  color: white,
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
        otherPersonImage(context)
      ],
    );
  }

  outgoingChatText(context, BaseModel chat, bool firstChat) {
    if (chat.getBoolean(DELETED)) {
      return Container();
    }
    String message = chat.getString(MESSAGE);

    String chatId = chat.getString(CHAT_ID);
    chatId = getOtherPersonId(chat);
    bool read = chat.getList(READ_BY).contains(otherPerson.getObjectId());

    BaseModel replyData = BaseModel(items: chat.getMap(REPLY_DATA));
    return new GestureDetector(
      onLongPress: () {
        showChatOptions(context, chat);
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(60, 0, 15, 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (replyData.items.isNotEmpty)
              chatReplyWidget(
                replyData,
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  child: Card(
                    elevation: 5, //shadowColor: black.withOpacity(.3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                      topRight: Radius.circular(0),
                      topLeft: Radius.circular(25),
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    )),
                    child: new Container(
                      margin: const EdgeInsets.fromLTRB(15, 10, 20, 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            message,
                            style: textStyle(false, 17, black),
                          ),
//              addSpace(3),
//              Text(
//                getChatTime(chat.getInt(TIME)),
//                style: textStyle(false, 12, black.withOpacity(.3)),
//              ),
                        ],
                      ),
                    ),
                  ),
                ),
                /* Container(
                width: 8,
                height: 8,
                margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                decoration: BoxDecoration(
                  color: read ? black.withOpacity(.3) : transparent,
                  shape: BoxShape.circle,
//                                                      border: Border.all(
//                                                          color: black, width: 1)
                ),
              ),*/
                if (read && firstChat)
                  Icon(
                    Icons.remove_red_eye,
                    size: 12,
                    color: AppConfig.appColor,
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }

  incomingChatDoc(context, BaseModel chat, bool exists, onComplete) {
    if (chat.getBoolean(DELETED)) {
      return incomingChatDeleted(context, chat);
    }
    if (chat.getList(HIDDEN).contains(userModel.getObjectId())) {
      return Container();
    }

    String fileUrl = chat.getString(FILE_URL);
    String fileName = chat.getString(FILE_NAME);
    String size = chat.getString(FILE_SIZE);
    String ext = chat.getString(FILE_EXTENSION);
    bool downloading = upOrDown.contains(chat.getObjectId());
    BaseModel replyData = BaseModel(items: chat.getMap(REPLY_DATA));
//  return Container();
    return new Stack(
      children: <Widget>[
        Opacity(
          opacity: fileUrl.isEmpty ? (.4) : 1,
          child: new GestureDetector(
            onLongPress: () {
              showChatOptions(context, chat);
            },
            onTap: () async {
              if (fileUrl.isEmpty || !exists) return;

              /*if (!exists) {
              downloadChatFile(chat, false, onComplete);
              return;
            }*/

              String fileName =
                  "${chat.getObjectId()}.${chat.getString(FILE_EXTENSION)}";
              File file = await getDirFile(fileName);
              await openTheFile(file.path);
            },
            child: Container(
              width: 200,
              margin: EdgeInsets.fromLTRB(60, 0, 0, 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (replyData.items.isNotEmpty)
                    chatReplyWidget(
                      replyData,
                    ),
                  new Card(
                    clipBehavior: Clip.antiAlias,
                    color: default_white,
                    elevation: 5,
                    /*shadowColor: black.withOpacity(.3),*/
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                      topRight: Radius.circular(25),
                      topLeft: Radius.circular(0),
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    )),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Container(
                          width: 250,
                          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                          margin: EdgeInsets.all(5),
                          decoration: BoxDecoration(
//                        color: black.withOpacity(.2),
                              borderRadius: BorderRadius.circular(5)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              //addSpaceWidth(10),
                              Image.asset(
                                getExtImage(ext),
                                width: 20,
                                height: 20,
                              ),
                              addSpaceWidth(10),
                              new Flexible(
                                flex: 1,
                                fit: FlexFit.tight,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      fileName,
                                      maxLines: 1,
                                      //overflow: TextOverflow.ellipsis,
                                      style: textStyle(false, 14, black),
                                    ),
                                    addSpace(3),
                                    Text(
                                      size,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textStyle(
                                          false, 12, black.withOpacity(.5)),
                                    ),
                                  ],
                                ),
                              ),
                              //addSpaceWidth(5),
                              exists || fileUrl.isEmpty
                                  ? Container()
                                  : Container(
                                      width: 27,
                                      height: 27,
                                      margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppConfig.appColor,
                                          border: Border.all(
                                              width: 1,
                                              color: AppConfig.appColor)),
                                      child: GestureDetector(
                                        onTap: () {
                                          if (!downloading) {
                                            downloadChatFile(chat, onComplete);
                                          }
                                        },
                                        child: (!downloading)
                                            ? Container(
                                                width: 27,
                                                height: 27,
                                                child: Icon(
                                                  Icons.arrow_downward,
                                                  color: white,
                                                  size: 15,
                                                ),
                                              )
                                            : Container(
                                                margin: EdgeInsets.all(3),
                                                child:
                                                    CircularProgressIndicator(
                                                  //value: 20,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(white),
                                                  strokeWidth: 2,
                                                ),
                                              ),
                                      ),
                                    )
                              //addSpaceWidth(5),
                            ],
                          ),
                        ),
//                  addSpace(3),
//                  Padding(
//                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
//                    child: Text(
//                      getChatTime(chat.getInt(TIME)),
//                      style: textStyle(false, 12, black.withOpacity(.3)),
//                    ),
//                  ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        otherPersonImage(context)
      ],
    );
  }

  outgoingChatDoc(context, BaseModel chat, onSaved, bool firstChat) {
    if (chat.getBoolean(DELETED)) {
      return Container();
    }
    String fileName = chat.getString(FILE_NAME);
    String size = chat.getString(FILE_SIZE);
    String ext = chat.getString(FILE_EXTENSION);
    bool uploading = upOrDown.contains(chat.getObjectId());
    String filePath = chat.getString(FILE_PATH);
    String fileUrl = chat.getString(FILE_URL);

    String chatId = chat.getString(CHAT_ID);
    chatId = getOtherPersonId(chat);
    bool read = chat.getList(READ_BY).contains(otherPerson.getObjectId());
    BaseModel replyData = BaseModel(items: chat.getMap(REPLY_DATA));
    return new GestureDetector(
      onLongPress: () {
        //long pressed chat...
        showChatOptions(context, chat);
      },
      onTap: () async {
        if (fileUrl.isEmpty) return;

        await openTheFile(filePath);
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(40, 0, 15, 15),
        width: 220,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (replyData != null)
              chatReplyWidget(
                replyData,
              ),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Container(
                  width: 200,
                  child: new Card(
                    color: AppConfig.appColor
                        .withOpacity(read ? 1 : 0.7), //  read ? blue3 : blue0,
                    clipBehavior: Clip.antiAlias,
                    elevation: 5,
                    /*shadowColor: black.withOpacity(.3),*/
                    shape: RoundedRectangleBorder(
                        borderRadius: chat.myItem()
                            ? BorderRadius.only(
                                bottomLeft: Radius.circular(25),
                                bottomRight: Radius.circular(25),
                                topLeft: Radius.circular(25),
                                topRight: Radius.circular(0),
                              )
                            : BorderRadius.only(
                                bottomLeft: Radius.circular(25),
                                bottomRight: Radius.circular(25),
                                topLeft: Radius.circular(25),
                                topRight: Radius.circular(0),
                              )),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        new Container(
                          width: 250,
                          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                          margin: EdgeInsets.all(5),
                          decoration: BoxDecoration(
//                  color: black.withOpacity(.2),
                              borderRadius: BorderRadius.circular(5)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              //addSpaceWidth(10),
                              fileUrl.isNotEmpty
                                  ? Container()
                                  : new Container(
                                      width: 27,
                                      height: 27,
                                      margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppConfig.appColor
                                              .withOpacity(.3),
                                          border: Border.all(
                                              width: 1,
                                              color: AppConfig.appColor)),
                                      child: GestureDetector(
                                        onTap: () {
                                          if (!uploading) {
                                            saveChatFile(chat, FILE_PATH,
                                                FILE_URL, onSaved);
                                            onSaved();
                                          }
                                        },
                                        child: uploading
                                            ? Container(
                                                margin: EdgeInsets.all(3),
                                                child:
                                                    CircularProgressIndicator(
                                                  //value: 20,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(white),
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Container(
                                                width: 27,
                                                height: 27,
                                                child: Icon(
                                                  Icons.arrow_upward,
                                                  color: white,
                                                  size: 15,
                                                ),
                                              ),
                                      )),

                              new Flexible(
                                flex: 1,
                                fit: FlexFit.tight,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      fileName,
                                      maxLines: 1,
                                      //overflow: TextOverflow.ellipsis,
                                      style: textStyle(true, 14, white),
                                    ),
                                    addSpace(3),
                                    Text(
                                      size,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textStyle(
                                          false, 12, white.withOpacity(.5)),
                                    ),
                                  ],
                                ),
                              ),
                              //addSpaceWidth(5),

                              addSpaceWidth(10),
                              Image.asset(
                                getExtImage(ext),
                                width: 20,
                                height: 20,
                              ),

                              //addSpaceWidth(5),
                            ],
                          ),
                        ),
                        //addSpace(3),
//            Padding(
//              padding: const EdgeInsets.fromLTRB(15, 0, 10, 10),
//              child: Text(
//                getChatTime(chat.getInt(TIME)),
//                style: textStyle(false, 12, white.withOpacity(.3)),
//              ),
//            ),
                      ],
                    ),
                  ),
                ),
                if (read && firstChat)
                  Icon(
                    Icons.remove_red_eye,
                    size: 12,
                    color: AppConfig.appColor,
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }

  incomingChatImage(context, BaseModel chat) {
    if (chat.getBoolean(DELETED)) {
      return incomingChatDeleted(context, chat);
    }
    if (chat.getList(HIDDEN).contains(userModel.getObjectId())) {
      return Container();
    }
    //List images = chat.getList(IMAGES);
    String firstImage = chat.getString(IMAGE_URL);

//  return Container();
    BaseModel replyData = BaseModel(items: chat.getMap(REPLY_DATA));
    return new Stack(
      children: <Widget>[
        new GestureDetector(
          onLongPress: () {
            //long pressed chat...
            showChatOptions(context, chat);
          },
          onTap: () {
            if (firstImage.isEmpty) return;
            pushAndResult(context, ViewImage([firstImage], 0));
          },
          child: Container(
            width: 250,
//            height: 200,
            margin: EdgeInsets.fromLTRB(65, 0, 40, 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (replyData != null)
                  chatReplyWidget(
                    replyData,
                  ),
                Container(
                  width: 250,
                  height: 200,
                  child: new Card(
                    clipBehavior: Clip.antiAlias,
                    color: default_white,
                    elevation: 5,
                    /*shadowColor: black.withOpacity(.3),*/
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                      topRight: Radius.circular(25),
                      topLeft: Radius.circular(0),
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    )),
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        CachedNetworkImage(
                            imageUrl: firstImage,
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                            placeholder: (c, p) {
                              return placeHolder(200, width: double.infinity);
                            }),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: gradientLine(height: 40),
                        ),
                        Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                getChatTime(chat.getInt(TIME)),
                                style:
                                    textStyle(false, 12, white.withOpacity(.3)),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        otherPersonImage(context)
      ],
    );
  }

  outgoingChatImage(context, BaseModel chat, onSaved, firstChat) {
    if (chat.getBoolean(DELETED)) {
      return Container();
    }
    String imageUrl = chat.getString(IMAGE_URL);
    String imagePath = chat.getString(IMAGE_PATH);
    bool uploading = upOrDown.contains(chat.getObjectId());

    String chatId = chat.getString(CHAT_ID);
    chatId = getOtherPersonId(chat);
    bool read = chat.getList(READ_BY).contains(otherPerson.getObjectId());

    BaseModel replyData = BaseModel(items: chat.getMap(REPLY_DATA));
    return new GestureDetector(
      onLongPress: () {
        //long pressed chat...
        showChatOptions(context, chat);
      },
      onTap: () {
        if (imageUrl.isEmpty) return;
        pushAndResult(context, ViewImage([imageUrl], 0));
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(40, 0, 15, 15),
        width: 270,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (replyData != null)
              chatReplyWidget(
                replyData,
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 230,
                  height: 200,
                  child: new Card(
                    color: AppConfig.appColor,
                    clipBehavior: Clip.antiAlias,
//                  margin: EdgeInsets.all(0),
                    elevation: 5,
                    /*shadowColor: black.withOpacity(.3),*/
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(0),
                    )),
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        imageUrl.isEmpty
                            ? Image.file(
                                File(imagePath),
                                fit: BoxFit.cover,
                              )
                            : CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (c, p) {
                                  return placeHolder(200,
                                      width: double.infinity);
                                }),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: gradientLine(height: 40),
                        ),
                        Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                getChatTime(chat.getInt(TIME)),
                                style:
                                    textStyle(false, 12, white.withOpacity(.3)),
                              ),
                            )),
                        imageUrl.isNotEmpty
                            ? Container()
                            : Align(
                                alignment: Alignment.center,
                                child: GestureDetector(
                                  onTap: () {
                                    if (!uploading) {
                                      saveChatFile(
                                          chat, IMAGE_PATH, IMAGE_URL, onSaved);
                                      onSaved();
                                    }
                                  },
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        color: black.withOpacity(.9),
                                        border:
                                            Border.all(color: white, width: 1),
                                        shape: BoxShape.circle),
                                    child: uploading
                                        ? Container(
                                            margin: EdgeInsets.all(5),
                                            child: CircularProgressIndicator(
                                              //value: 20,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      white),
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Center(
                                            child: Icon(
                                              Icons.arrow_upward,
                                              color: white,
                                              size: 20,
                                            ),
                                          ),
                                  ),
                                ),
                              )
                      ],
                    ),
                  ),
                ),
                if (read && firstChat)
                  Icon(
                    Icons.remove_red_eye,
                    size: 12,
                    color: AppConfig.appColor,
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }

  incomingChatVideo(context, BaseModel chat) {
    if (chat.getBoolean(DELETED)) {
      return incomingChatDeleted(context, chat);
    }
    if (chat.getList(HIDDEN).contains(userModel.getObjectId())) {
      return Container();
    }

    String videoUrl = chat.getString(VIDEO_URL);
    String thumb = chat.getString(THUMBNAIL_URL);
    String videoLenght = chat.getString(VIDEO_LENGTH);
    BaseModel replyData = BaseModel(items: chat.getMap(REPLY_DATA));
    return new Stack(
      children: <Widget>[
        Opacity(
          opacity: videoUrl.isEmpty ? (.4) : 1,
          child: new GestureDetector(
            onLongPress: () {
              showChatOptions(context, chat);
              //long pressed chat...
            },
            child: Container(
              width: 250,
              margin: EdgeInsets.fromLTRB(65, 0, 40, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (replyData != null)
                    chatReplyWidget(
                      replyData,
                    ),
                  new Card(
                    clipBehavior: Clip.antiAlias,
                    color: black,
                    elevation: 5,
                    /*shadowColor: black.withOpacity(.3),*/
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                      topRight: Radius.circular(25),
                      topLeft: Radius.circular(0),
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    )),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Container(
                            color: AppConfig.appColor.withOpacity(.1),
                            width: 250,
                            height: 150,
                            child: new GestureDetector(
                                onTap: () {
                                  if (videoUrl.isEmpty) return;

                                  pushAndResult(context,
                                      PlayVideo(chat.getObjectId(), videoUrl));
                                },
                                child: new Stack(
                                  children: <Widget>[
                                    thumb.isEmpty
                                        ? Container()
                                        : CachedNetworkImage(
                                            imageUrl: thumb,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: 250,
                                          ),
                                    Center(
                                      child: new Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                            color: white.withOpacity(.9),
                                            border: Border.all(
                                                color: white, width: 1),
                                            shape: BoxShape.circle),
                                        child: videoUrl.isNotEmpty
                                            ? Center(
                                                child: Icon(
                                                  Icons.play_arrow,
                                                  color: white,
                                                  size: 20,
                                                ),
                                              )
                                            : Container(),
                                      ),
                                    ),
                                    new Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: <Widget>[
                                        Expanded(flex: 1, child: Container()),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      8, 0, 0, 8),
                                              child: Text(
                                                getChatTime(chat.getInt(TIME)),
                                                style: textStyle(false, 12,
                                                    white.withOpacity(.3)),
                                              ),
                                            ),
                                            Flexible(
                                                flex: 1, child: Container()),
                                            Container(
                                              margin: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                  color: black.withOpacity(.9),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        8, 4, 8, 4),
                                                child: Text(videoLenght,
                                                    style: textStyle(
                                                        false, 12, white)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ))),
                        /* addSpace(3),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 5, 15, 10),
                        child: Text(
                          getChatTime(chat.getInt(TIME)),
                          style: textStyle(false, 12, black.withOpacity(.3)),
                        ),
                      ),*/
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        otherPersonImage(context)
      ],
    );
  }

  outgoingChatVideo(context, BaseModel chat, onSaved, firstChat) {
    if (chat.getBoolean(DELETED)) {
      return Container();
    }
    String videoUrl = chat.getString(VIDEO_URL);
    String videoPath = chat.getString(VIDEO_PATH);
    String thumbPath = chat.getString(THUMBNAIL_PATH);
    String thumb = chat.getString(THUMBNAIL_URL);
    String videoLenght = chat.getString(VIDEO_LENGTH);
    bool uploading = upOrDown.contains(chat.getObjectId());

    String chatId = chat.getString(CHAT_ID);
    chatId = getOtherPersonId(chat);
    bool read = chat.getList(READ_BY).contains(otherPerson.getObjectId());

    BaseModel replyData = BaseModel(items: chat.getMap(REPLY_DATA));
    return new GestureDetector(
      onLongPress: () {
        showChatOptions(context, chat);
        //long pressed chat...
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(40, 0, 20, 15),
        width: 270,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (replyData != null)
              chatReplyWidget(
                replyData,
              ),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Container(
                  width: 250,
                  child: new Card(
                    color: AppConfig.appColor,
                    clipBehavior: Clip.antiAlias,
                    elevation: 5,
                    /*shadowColor: black.withOpacity(.3),*/
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(0),
                    )),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        new Container(
                            color: AppConfig.appColor.withOpacity(.1),
                            width: 250,
                            height: 150,
                            child: new GestureDetector(
                                onTap: () {
                                  if (videoUrl.isNotEmpty) {
                                    pushAndResult(
                                        context,
                                        PlayVideo(
                                          chat.getObjectId(),
                                          videoUrl,
                                          videoFile: File(videoPath),
                                        ));
                                  } else {
                                    if (!uploading) {
                                      saveChatVideo(chat, onSaved);
                                      onSaved();
                                    }
                                  }
                                },
                                child: new Stack(
                                  fit: StackFit.expand,
                                  children: <Widget>[
                                    thumb.isEmpty
                                        ? Image.file(
                                            File(thumbPath),
                                            fit: BoxFit.cover,
                                          )
                                        : CachedNetworkImage(
                                            imageUrl: thumb,
                                            fit: BoxFit.cover,
                                            placeholder: (c, p) {
                                              return placeHolder(250,
                                                  width: double.infinity);
                                            }),
                                    /*
                                  thumb.isEmpty
                                      ? Container()
                                      : CachedNetworkImage(
                                          imageUrl: thumb,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: 250,
                                        ),*/
                                    Center(
                                      child: new Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                            color: black.withOpacity(.9),
                                            border: Border.all(
                                                color: white, width: 1),
                                            shape: BoxShape.circle),
                                        child: videoUrl.isNotEmpty
                                            ? Center(
                                                child: Icon(
                                                  Icons.play_arrow,
                                                  color: white,
                                                  size: 20,
                                                ),
                                              )
                                            : (!uploading)
                                                ? Center(
                                                    child: Icon(
                                                      Icons.arrow_upward,
                                                      color: white,
                                                      size: 20,
                                                    ),
                                                  )
                                                : Container(
                                                    margin: EdgeInsets.all(5),
                                                    child:
                                                        CircularProgressIndicator(
                                                      //value: 20,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                              Color>(white),
                                                      strokeWidth: 2,
                                                    ),
                                                  ),
                                      ),
                                    ),
                                    new Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: <Widget>[
                                        Expanded(flex: 1, child: Container()),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Container(
                                              margin: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                  color: black.withOpacity(.9),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        8, 4, 8, 4),
                                                child: Text(videoLenght,
                                                    style: textStyle(
                                                        false, 12, white)),
                                              ),
                                            ),
                                            Flexible(
                                                flex: 1, child: Container()),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 0, 8, 8),
                                              child: Text(
                                                getChatTime(chat.getInt(TIME)),
                                                style: textStyle(false, 12,
                                                    white.withOpacity(.3)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ))),
                        //addSpace(3),
                      ],
                    ),
                  ),
                ),
                if (read && firstChat)
                  Icon(
                    Icons.remove_red_eye,
                    size: 12,
                    color: AppConfig.appColor,
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }

  otherPersonImage(context) {
    return GestureDetector(
      onTap: () {
//        pushAndResult(
//            context,
//            ShowStore(
//              theUser: otherPerson,
//            ),depend: false);
      },
      child: userImageItem(context, otherPerson, size: 40, strokeSize: 1),
    );
  }

  saveChatFile(BaseModel model, String pathKey, String urlKey, onSaved) {
    upOrDown.add(model.getObjectId());
    String path = model.getString(pathKey);
    uploadFile(File(path), (_, error) {
      upOrDown.removeWhere((s) => s == model.getObjectId());
      if (error != null) {
        return;
      }
      model.put(urlKey, _);
      model.updateItems();
      onSaved();
    });
  }

  saveChatVideo(BaseModel model, onSaved) {
    String thumb = model.getString(THUMBNAIL_PATH);
    String videoPath = model.getString(VIDEO_PATH);
    String thumbUrl = model.getString(THUMBNAIL_URL);
    String videoUrl = model.getString(VIDEO_URL);

    bool uploadingThumb = thumbUrl.isEmpty;

    if (videoUrl.isNotEmpty) {
      onSaved();
      return;
    }

    upOrDown.add(model.getObjectId());

    uploadFile(File(uploadingThumb ? thumb : videoPath), (_, error) {
      upOrDown.removeWhere((s) => s == model.getObjectId());
      if (error != null) {
        return;
      }
      model.put(uploadingThumb ? THUMBNAIL_URL : VIDEO_URL, _);
      model.updateItems();
      saveChatVideo(model, onSaved);
    });
  }

  downloadChatFile(BaseModel model, onComplete) async {
    String fileName =
        "${model.getObjectId()}.${model.getString(FILE_EXTENSION)}";
    File file = await getDirFile(fileName);
    upOrDown.add(model.getObjectId());
    onComplete();

    QuerySnapshot shots = await Firestore.instance
        .collection(REFERENCE_BASE)
        .where(FILE_URL, isEqualTo: model.getString(FILE_URL))
        .limit(1)
        .getDocuments();
    if (shots.documents.isEmpty) {
      upOrDown.removeWhere((s) => s == model.getObjectId());
      onComplete();
    } else {
      for (DocumentSnapshot doc in shots.documents) {
        if (!doc.exists || doc.data.isEmpty) continue;
        BaseModel model = BaseModel(doc: doc);
        String ref = model.getString(REFERENCE);
        StorageReference storageReference =
            FirebaseStorage.instance.ref().child(ref);
        storageReference.writeToFile(file).future.then((_) {
          //toastInAndroid("Download Complete");
          upOrDown.removeWhere((s) => s == model.getObjectId());
          onComplete();
        }, onError: (error) {
          upOrDown.removeWhere((s) => s == model.getObjectId());
          onComplete();
        }).catchError((error) {
          upOrDown.removeWhere((s) => s == model.getObjectId());
          onComplete();
        });

        break;
      }
    }
  }

  showChatOptions(context, BaseModel chat, {bool deletedChat = false}) {
    int type = chat.getInt(TYPE);
    pushAndResult(
        context,
        listDialog(type == CHAT_TYPE_TEXT && !deletedChat
            ? ["Copy", "Delete"]
            : ["Delete"]),
        opaque: false, result: (_) {
      if (_ == "Copy") {
        //ClipboardManager.copyToClipBoard(chat.getString(MESSAGE));
      }
      if (_ == "Delete") {
        if (chat.myItem()) {
          chat.put(DELETED, true);
          chat.updateItems();
        } else {
          List hidden = List.from(chat.getList(HIDDEN));
          hidden.add(userModel.getObjectId());
          chat.put(HIDDEN, hidden);
          chat.updateItems();
        }
      }
    }, depend: false);
  }

  AudioPlayer recAudioController = AudioPlayer();
  bool isPlaying = false;
//  VideoPlayerController recAudioController;
  String currentPlayingAudio;

  bool recPlayEnded = false;
  List noFileFound = [];
  getChatAudioWidget(
      context, BaseModel chat, onEdited(bool removed), bool firstChat) {
    if (chat.getBoolean(DELETED)) {
      if (!chat.myItem()) {
        return incomingChatDeleted(context, chat);
      }
      return Container();
    }
//    return Container();
    bool read = chat.getList(READ_BY).contains(otherPerson.getObjectId());
    String audioUrl = chat.getString(AUDIO_URL);
    String audioPath = chat.getString(AUDIO_PATH);
    String audioLength = chat.getString(AUDIO_LENGTH);
    bool uploading = upOrDown.contains(chat.getObjectId());
    bool noFile = noFileFound.contains(chat.getObjectId());
    bool currentPlay = currentPlayingAudio == chat.getObjectId();
/*    bool isPlaying = recAudioController != null &&
        recAudioController.value.initialized &&
        recAudioController. value.isPlaying;*/
    var parts = audioPath.split("/");
    String baseFileName = parts[parts.length - 1];
    BaseModel replyData = BaseModel(items: chat.getMap(REPLY_DATA));
    return Container(
//    height: chat.myItem()?null:40,
      width: chat.myItem() ? null : 270,
      margin: EdgeInsets.fromLTRB(0, 0, 0, chat.myItem() ? 15 : 10),
      child: Stack(
        children: [
          Align(
            alignment:
                !chat.myItem() ? Alignment.centerLeft : Alignment.centerRight,
            child: Opacity(
              opacity: audioUrl.isEmpty && !chat.myItem() ? (.4) : 1,
              child: new GestureDetector(
                onTap: () async {
                  if (audioUrl.isEmpty && !chat.myItem()) return;
                  if (uploading) return;
                  if (noFile) {
                    showMessage(context, Icons.error, red0, "File not found",
                        "This file no longer exist on your device");
                    return;
                  }

                  if (!chat.myItem()) {
                    String path = await localPath;
                    File file =
                        File("$path/${chat.getObjectId()}$baseFileName");
                    print("File Path: ${file.path}");
                    bool exists = await file.exists();
                    if (!exists) {
                      upOrDown.add(chat.getObjectId());
                      onEdited(false);
                      downloadFile(file, audioUrl, (e) {
                        upOrDown.removeWhere((r) => r == chat.getObjectId());
                        fileThatExists.add(chat.getObjectId());
                        onEdited(false);
                      });
                      return;
                    } else {
                      audioPath = file.path;
                      fileThatExists.add(chat.getObjectId());
                      onEdited(false);
                    }
                  }

                  if (currentPlayingAudio == chat.getObjectId()) {
                    /*if (recAudioController != null &&
                        recAudioController.value.initialized) {
                      if (recAudioController.value.isPlaying) {
                        recAudioController.pause();
                      } else {
                        currentPlayingAudio = chat.getObjectId();
                        recAudioController.play();
                        recPlayEnded = false;
                        onEdited(false);
                      }
                    }*/
                    if (isPlaying) {
                      recAudioController.pause();
                      isPlaying = false;
                      setState(() {});
                    } else {
                      recAudioController.resume();
                      isPlaying = true;
                      setState(() {});
                    }
                  } else {
                    /*if (recAudioController != null) {
                    await recAudioController.pause();
                    await recAudioController.dispose();
                    recAudioController = null;
                  }*/
                    try {
                      await recAudioController.stop();
                    } catch (e) {}
//                    try {
//                      await recAudioController.dispose();
//                    } catch (e) {}
//                    recAudioController = null;

                    /*recAudioController =
                        VideoPlayerController.file(File(audioPath));
                    recAudioController.addListener(() async {
                      if (recAudioController != null) {
                        int currentTime =
                            recAudioController.value.position.inSeconds;
                        int fullTime = getSeconds(chat.getString(AUDIO_LENGTH));
                        print("FullTime $fullTime CurrentTime $currentTime");
                        if (currentTime >= fullTime - 1 && currentTime != 0) {
                          if (recPlayEnded) return;
                          recPlayEnded = true;
                          await recAudioController.pause();
                          await recAudioController.seekTo(Duration(seconds: 0));
                          print("Play Finished");
                          onEdited(false);
                          */ /* Future.delayed(Duration(milliseconds: 200),()async{
                            currentPlayingAudio="";
                            recAudioController=null;
                          });*/ /*
                        }
                      }
                    });*/
                    recAudioController.play(
                      audioPath,
                      isLocal: true,
                    );
                    recAudioController.setReleaseMode(ReleaseMode.STOP);
                    isPlaying = true;
                    currentPlayingAudio = chat.getObjectId();
                    setState(() {});
                    /*recAudioController.initialize().then((value) {
                      currentPlayingAudio = chat.getObjectId();
                      recAudioController.play();
                      recPlayEnded = false;
                      onEdited(false);
                    }).catchError((e) {
                      showMessage(context, Icons.error, red0, "Audio Error",
                          "This audio recording is corrupted");
                    });*/
                  }
                },
                onLongPress: () {
                  showChatOptions(context, chat);
                },
                child: Container(
                  width: 200,
                  margin: EdgeInsets.fromLTRB(35, 0, 0, 0),
                  child: Column(
                    crossAxisAlignment: chat.myItem()
                        ? (CrossAxisAlignment.start)
                        : CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (replyData != null)
                        chatReplyWidget(
                          replyData,
                        ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          new Container(
                            height: 30,
                            width: 170,
                            color: transparent,
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              elevation: 5,
                              /*shadowColor: black.withOpacity(.3),*/
                              shape: RoundedRectangleBorder(
                                  borderRadius: chat.myItem()
                                      ? BorderRadius.only(
                                          bottomLeft: Radius.circular(25),
                                          bottomRight: Radius.circular(25),
                                          topLeft: Radius.circular(25),
                                          topRight: Radius.circular(0),
                                        )
                                      : BorderRadius.only(
                                          bottomLeft: Radius.circular(25),
                                          bottomRight: Radius.circular(25),
                                          topLeft: Radius.circular(0),
                                          topRight: Radius.circular(25),
                                        )),
                              margin: EdgeInsets.all(0),
                              color: AppConfig.appColor.withOpacity((isPlaying &&
                                      currentPlay)
                                  ? 1
                                  : .8), // isPlaying && currentPlay ? AppConfig.appColor : blue0,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  /*LinearProgressIndicator(
                                    value:currentPlay?(playPosition / 100):0,
                                    backgroundColor: transparent,
                                    valueColor:
                                    AlwaysStoppedAnimation<Color>(black.withOpacity(.7)),
                                  ),*/
                                  Row(
                                    children: [
                                      addSpaceWidth(10),
                                      if (uploading)
                                        Container(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(
                                            //value: 20,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    white),
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      if (!uploading)
                                        chat.myItem()
                                            ? (Icon(
                                                currentPlay && isPlaying
                                                    ? (Icons.pause)
                                                    : Icons.play_circle_filled,
                                                color: white,
                                              ))
                                            : (Icon(
                                                !fileThatExists.contains(
                                                        chat.getObjectId())
                                                    ? Icons.file_download
                                                    : currentPlay && isPlaying
                                                        ? (Icons.pause)
                                                        : Icons
                                                            .play_circle_filled,
                                                color: white,
                                              )) /*FutureBuilder(
                                      builder: (c,d){
                                        if(!d.hasData)return Container();
                                        bool exists = d.data;
                                        return Icon(
                                          !exists?Icons.file_download:currentPlay && isPlaying?
                                          (Icons.pause):Icons.play_circle_filled,
                                          color: white,
                                        );
                                      },future: checkLocalFile("${chat.getObjectId()}$baseFileName"),
                                    )*/
                                      ,
                                      Flexible(
                                        fit: FlexFit.tight,
                                        child: Container(
                                          height: 2,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                              color: white,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(5))),
                                        ),
                                      ),
                                      Container(
                                        padding:
                                            EdgeInsets.fromLTRB(5, 2, 5, 2),
                                        decoration: BoxDecoration(
                                            color: white,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(25))),
                                        child: Text(
                                          audioLength,
                                          style: textStyle(
                                              false, 12, AppConfig.appColor),
                                        ),
                                      ),
                                      addSpaceWidth(5),
                                      if (noFile)
                                        Container(
                                            padding: EdgeInsets.all(1),
                                            decoration: BoxDecoration(
                                                color: white,
                                                shape: BoxShape.circle),
                                            child: Icon(
                                              Icons.error,
                                              color: red0,
                                              size: 18,
                                            )),
                                      addSpaceWidth(10),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          if (chat.myItem())
                            if (read && firstChat)
                              Icon(
                                Icons.remove_red_eye,
                                size: 12,
                                color: AppConfig.appColor,
                              )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (!chat.myItem()) otherPersonImage(context)
        ],
      ),
    );
  }

  chatReplyWidget(BaseModel chat, {onRemoved, bool fitScreen = false}) {
    if (chat.items.isEmpty) return Container();
    String text = chat.getString(MESSAGE);
    int type = chat.getType();
    if (type == CHAT_TYPE_DOC) text = "Document";
    if (type == CHAT_TYPE_IMAGE) text = "Photo";
    if (type == CHAT_TYPE_VIDEO)
      text = "Video (${chat.getString(VIDEO_LENGTH)})";
    if (type == CHAT_TYPE_REC)
      text = "Voice Message (${chat.getString(AUDIO_LENGTH)})";
    var icon;
    if (type == CHAT_TYPE_DOC) icon = Icons.assignment;
    if (type == CHAT_TYPE_IMAGE) icon = Icons.photo;
    if (type == CHAT_TYPE_VIDEO) icon = Icons.videocam;
    if (type == CHAT_TYPE_REC) icon = Icons.mic;

    String image = "";
    if (type == CHAT_TYPE_IMAGE) image = chat.getString(IMAGE_URL);
    if (type == CHAT_TYPE_VIDEO) image = chat.getString(THUMBNAIL_URL);

    return GestureDetector(
      onTap: () {
        scrollToMessage(chat.getObjectId());
      },
      child: Container(
//    width: 100,
          width: fitScreen ? double.infinity : null,
          child: Card(
            clipBehavior: Clip.antiAlias,
            color: default_white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                side: BorderSide(color: black.withOpacity(.1), width: .5)),
            child: Container(
              decoration: BoxDecoration(
                  border: Border(
                      left: BorderSide(color: AppConfig.appColor, width: 5))),
              child: Row(
                mainAxisSize: fitScreen ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  Flexible(
                    fit: fitScreen ? FlexFit.tight : FlexFit.loose,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          10,
                          onRemoved == null ? 10 : 0,
                          onRemoved == null ? 10 : 0,
                          image.isEmpty ? 10 : 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                  fit: !fitScreen
                                      ? FlexFit.loose
                                      : FlexFit.tight,
                                  child: Text(
                                    chat.myItem()
                                        ? "YOU"
                                        : chat.getString(FIRST_NAME),
                                    style: textStyle(
                                        true, 12, black.withOpacity(.5)),
                                  )),
                              if (onRemoved != null && image.isEmpty)
                                Container(
                                  width: 30,
                                  height: 25,
                                  child: FlatButton(
                                      padding: EdgeInsets.all(0),
                                      onPressed: () {
                                        onRemoved();
                                      },
                                      child: Icon(
                                        Icons.close,
                                        size: 15,
                                        color: black.withOpacity(.5),
                                      )),
                                )
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (icon != null)
                                Icon(
                                  icon,
                                  size: 14,
                                  color: black.withOpacity(.3),
                                ),
                              addSpaceWidth(3),
                              Flexible(
                                child: Text(
                                  text,
                                  style: textStyle(false, 14, black),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              addSpaceWidth(10),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (image.isNotEmpty)
                    Container(
                      width: 50,
                      height: 50,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: image,
                            fit: BoxFit.cover,
                          ),
                          if (onRemoved != null)
                            Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                width: 16,
                                height: 16,
                                margin: EdgeInsets.all(2),
                                child: FlatButton(
                                    padding: EdgeInsets.all(0),
                                    onPressed: () {
                                      onRemoved();
                                    },
                                    shape: CircleBorder(),
                                    color: white.withOpacity(.5),
                                    child: Icon(
                                      Icons.close,
                                      size: 12,
                                      color: black.withOpacity(.5),
                                    )),
                              ),
                            )
                        ],
                      ),
                    )
                ],
              ),
            ),
          )),
    );
  }
}

//keytool -list -v \-alias androiddebugkey -keystore ~/.android/debug.keystore
//keytool -exportcert -list -v \-alias key -keystore /Users/bappstack/RemoteJobs/strock/key.jsk
//keytool -exportcert -alias androiddebugkey -keystore ~/ -list -v
