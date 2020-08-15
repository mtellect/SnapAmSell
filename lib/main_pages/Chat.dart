import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/ChatMain.dart';
import 'package:maugost_apps/MainAdmin.dart';
import 'package:maugost_apps/AppConfig.dart';
import 'package:maugost_apps/assets.dart';
import 'package:maugost_apps/auth/login_page.dart';
import 'package:maugost_apps/basemodel.dart';
import 'package:maugost_apps/dialogs/listDialog.dart';

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
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
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
      backgroundColor: white,
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
    if (!isLoggedIn)
      return emptyLayout(Icons.chat, "Sign in to view messages", "",
          clickText: "Sign in", click: () {
        pushAndResult(context, LoginPage(), depend: false);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
            flex: 1,
            child: Builder(builder: (ctx) {
              if (!chatSetup) return loadingLayout(trans: true);
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
              print(lastMessages.length);
              return Container(
                  child: ListView.builder(
                itemBuilder: (c, p) {
                  BaseModel model = lastMessages[p];

                  String chatId = model.getString(CHAT_ID);
                  String otherPersonId = getOtherPersonId(model);
                  BaseModel otherPerson = otherPeronInfo[otherPersonId];
                  if (otherPerson == null) return Container();

                  String name = getFullName(otherPerson);
                  String image = otherPerson.userImage;

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
            //color: default_white.withOpacity(0.05),
            color: default_white,
            //boxShadow: [BoxShadow(color: black.withOpacity(.1), blurRadius: 5)],
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
                /* Container(
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
                ),*/
                userImageItem(context, otherPerson, size: 70, strokeSize: 1),
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
                              style: textStyle(true, 20, textColor),
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
                            style:
                                textStyle(false, 12, textColor.withOpacity(.8)),
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
                                        color: textColor.withOpacity(.8),
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
                                          style: textStyle(false, 14,
                                              textColor.withOpacity(.8)),
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
                              color: textColor.withOpacity(.5),
                            )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
            addSpace(5),
            addLine(.1, white.withOpacity(.3), 0, 0, 0, 0)
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
