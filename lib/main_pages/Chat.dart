import 'dart:async';
import 'dart:ui';

import 'package:Strokes/AppEngine.dart';
import 'package:Strokes/ChatMain.dart';
import 'package:Strokes/MainAdmin.dart';
import 'package:Strokes/app_config.dart';
import 'package:Strokes/assets.dart';
import 'package:Strokes/basemodel.dart';
import 'package:Strokes/dialogs/listDialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

PageController chatPageController = new PageController();
List<BaseModel> notifyList = List();

class Chat extends StatefulWidget {
  final bool showBar;

  const Chat({Key key, this.showBar = true}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> with AutomaticKeepAliveClientMixin {
  //bool setup = false;
  var sub;
  @override
  void initState() {
    super.initState();
    sub = chatMessageController.stream.listen((_) {
//      toastInAndroid("New Chat");
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
//    chatMessageController.close();
    sub.cancel();
    super.dispose();
  }

  startRefreshingMessages() {
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) setState(() {});
      startRefreshingMessages();
    });
  }

  //git remote add strock https://mtellect@bitbucket.org/primepeter/strock-app.git

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: modeColor,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // CachedNetworkImage(
          //   imageUrl: userModel.getString(USER_IMAGE),
          //   fit: BoxFit.cover,
          //   height: MediaQuery.of(context).size.height,
          // ),
          // BackdropFilter(
          //     filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          //     child: Container(
          //       color: black.withOpacity(.6),
          //     )),
          page()
        ],
      ),
    );
  }

  page() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
            flex: 1,
            child: Builder(builder: (ctx) {
              if (lastMessages.isEmpty)
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Image.asset(
                          ic_chat1,
                          width: 50,
                          height: 50,
                          color: AppConfig.appColor,
                        ),
                        Text(
                          "No Chat Yet",
                          style: textStyle(true, 20, black),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );

//              if (!chatSetup) return loadingLayout();
//              if (lastMessages.isEmpty)
//                return Center(
//                  child: Padding(
//                    padding: const EdgeInsets.all(10),
//                    child: Column(
//                      mainAxisSize: MainAxisSize.min,
//                      children: <Widget>[
//                        Image.asset(
//                          ic_chat1,
//                          width: 50,
//                          height: 50,
//                          color: AppConfig.appColor,
//                        ),
//                        Text(
//                          "No Chat Yet",
//                          style: textStyle(true, 20, black),
//                          textAlign: TextAlign.center,
//                        ),
//                      ],
//                    ),
//                  ),
//                );

              return Container(
                  child: ListView.builder(
                itemBuilder: (c, p) {
                  BaseModel model = lastMessages[p];

                  String chatId = model.getString(CHAT_ID);
                  String otherPersonId = getOtherPersonId(model);
                  BaseModel otherPerson = otherPeronInfo[otherPersonId];
                  if (otherPerson == null) return Container();

                  String name = getFullName(otherPerson);
                  String image = otherPerson.profilePhotos[0].imageUrl;

                  return chatItem(image, name, model,
                      p == lastMessages.length - 1, otherPerson);
                },
                shrinkWrap: true,
                itemCount: lastMessages.length,
                padding: EdgeInsets.all(0),
              ));
            }))
      ],
    );
  }

  dummyChatItem(String image, String name, String message) {
    return Container(
      child: Card(
        elevation: 5,
        margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
        shadowColor: black.withOpacity(.3),
        child: Container(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              imageHolder(60, image, stroke: 0, strokeColor: black),
              addSpaceWidth(10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          fit: FlexFit.tight,
                          child: Text(
                            name,
                            style: textStyle(true, 16, black),
                          ),
                        ),
                        addSpaceWidth(10),
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: black.withOpacity(.3),
                        ),
                        addSpaceWidth(10),
                      ],
                    ),
                    addSpace(3),
                    Text(
                      message,
                      //style: textStyle(false, 13, black.withOpacity(.6)),
                      style: textStyle(false, 14, black.withOpacity(.7)),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  chatItem(String image, String name, BaseModel chatModel, bool last,
      BaseModel otherPerson) {
    int type = chatModel.getInt(TYPE);
    String chatId = chatModel.getString(CHAT_ID);
    bool myItem = chatModel.myItem();

    String hisId = chatId.replaceAll(userModel.getObjectId(), "");
    bool read = chatModel.getList(READ_BY).contains(hisId);
    bool myRead = chatModel.getList(READ_BY).contains(userModel.getObjectId());
    List mutedList = userModel.getList(MUTED);
    int unread =
        unreadCounter[chatId] == null ? 0 : unreadCounter[chatId].length;

    return new InkWell(
      onLongPress: () {
        pushAndResult(
            context,
            listDialog([
              mutedList.contains(chatId) ? "Unmute Chat" : "Mute Chat",
              "Delete Chat"
            ]), result: (_) {
          if (_ == "Mute Chat" || _ == "Unmute Chat") {
            if (mutedList.contains(chatId)) {
              mutedList.remove(chatId);
            } else {
              mutedList.add(chatId);
            }
            userModel.put(MUTED, mutedList);
            userModel.updateItems();
            setState(() {});
          }
          if (_ == "Delete Chat") {
            yesNoDialog(context, "Delete Chat?",
                "Are you sure you want to delete this chat?", () {
              deleteChat(chatId);
            });
          }
        }, depend: false);
      },
      onTap: () {
        BaseModel chat = BaseModel();
        chat.put(PARTIES, [userModel.getObjectId(), otherPerson.getObjectId()]);
        chat.saveItem(CHAT_IDS_BASE, false, document: chatId);

        chatModel.putInList(READ_BY, userModel.getObjectId(), true);
        chatModel.updateItems();
        unreadCounter.remove(chatId);
        showNewMessageDot.removeWhere((id) => id == chatId);
        setState(() {});
        pushAndResult(
            context,
            ChatMain(
              chatId,
              otherPerson: otherPerson,
            ), result: (_) {
          setState(() {});
        });
      },
      //margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: Container(
        decoration: BoxDecoration(
            color: white,
            boxShadow: [BoxShadow(color: black.withOpacity(.1), blurRadius: 5)],
            borderRadius: BorderRadius.circular(5)),
        padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
        margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
//                  margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                  width: 80,
                  height: 80,
                  child: Card(
                    color: black.withOpacity(.1),
                    elevation: 0,

                    clipBehavior: Clip.antiAlias,
                    shape: CircleBorder(
                        side: BorderSide(
                            color: black.withOpacity(.2), width: .9)),
                    // shape: RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.all(Radius.circular(10)),
                    //     side: BorderSide(
                    //         color: black.withOpacity(.1), width: .8)),
                    child: CachedNetworkImage(
                      imageUrl: image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                addSpaceWidth(10),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: new Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Flexible(
                            flex: 1,
                            fit: FlexFit.tight,
                            child: Text(
                              //"Emeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",
                              name,
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: textStyle(true, 20, black),
                            ),
                          ),
                          addSpaceWidth(5),
                          !myItem && !myRead && unread > 0
                              ? /*Icon(
                                  Icons.new_releases,
                                  size: 20,
                                  color: white,
                                )*/
                              (Container(
                                  width: 25,
                                  height: 25,
                                  decoration: BoxDecoration(
                                    color: AppConfig.appColor,
                                    shape: BoxShape.circle,
//                                      border:
//                                          Border.all(color: white, width: 2)
                                  ),
                                  child: Center(
                                      child: Text(
                                    "${unread > 9 ? "9+" : unread}",
                                    style: textStyle(true, 12, white),
                                  )),
                                ))
                              : Container(),
                          addSpaceWidth(5),
                          Text(
                            getChatTime(chatModel.getTime()),
                            style: textStyle(false, 12, black.withOpacity(.8)),
                            textAlign: TextAlign.end,
                          ),

                          //addSpaceWidth(5),
                        ],
                      ),
                      addSpace(5),
                      Row(
                        children: <Widget>[
                          Flexible(
                            fit: FlexFit.tight,
                            child: Row(
                              children: <Widget>[
                                Flexible(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      if (myItem && read)
                                        Container(
                                            margin: EdgeInsets.only(right: 5),
                                            child: Icon(
                                              Icons.remove_red_eye,
                                              size: 12,
                                              color: blue0,
                                            )),
                                      Icon(
                                        type == CHAT_TYPE_TEXT
                                            ? Icons.message
                                            : type == CHAT_TYPE_IMAGE
                                                ? Icons.camera_alt
                                                : type == CHAT_TYPE_VIDEO
                                                    ? Icons.videocam
                                                    : type == CHAT_TYPE_REC
                                                        ? Icons.mic
                                                        : Icons.library_books,
                                        color: black.withOpacity(.8),
                                        size: 12,
                                      ),
                                      addSpaceWidth(5),
                                      Flexible(
                                        flex: 1,
                                        child: Text(
                                          chatRemoved(chatModel)
                                              ? "This message has been removed"
                                              : type == CHAT_TYPE_TEXT
                                                  ? chatModel.getString(MESSAGE)
                                                  : type == CHAT_TYPE_IMAGE
                                                      ? "Photo"
                                                      : type == CHAT_TYPE_VIDEO
                                                          ? "Video"
                                                          : type ==
                                                                  CHAT_TYPE_REC
                                                              ? "Voice Note (${chatModel.getString(AUDIO_LENGTH)})"
                                                              : "Document",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: textStyle(
                                              false, 14, black.withOpacity(.8)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (mutedList.contains(chatId))
                            Image.asset(
                              ic_mute,
                              width: 18,
                              height: 18,
                              color: white.withOpacity(.5),
                            )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
            addSpace(5),
            addLine(.5, white.withOpacity(.3), 0, 0, 0, 0)
          ],
        ),
      ),
    );
  }

  deleteChat(String chatId) {
    lastMessages.removeWhere((bm) => bm.getString(CHAT_ID) == chatId);
    stopListening.add(chatId);
    userModel.putInList(DELETED_CHATS, chatId, true);
    userModel.updateItems();
    if (mounted) setState(() {});

    Firestore.instance
        .collection(CHAT_BASE)
        .where(PARTIES, arrayContains: userModel.getUserId())
        .where(CHAT_ID, isEqualTo: chatId)
        .orderBy(TIME, descending: false)
        .getDocuments()
        .then((shots) {
      for (DocumentSnapshot doc in shots.documents) {
        BaseModel chat = BaseModel(doc: doc);
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
    });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
