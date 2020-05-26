import 'dart:async';
import 'dart:core';
import 'dart:core';
import 'dart:io';

import 'package:Strokes/MyProfile1.dart';
import 'package:Strokes/assets.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filesize/filesize.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:screen/screen.dart';
import 'package:video_player/video_player.dart';
import 'package:timeago/timeago.dart' as timeAgo;

import 'AppEngine.dart';
//import 'ViewedStatus.dart';
import 'ShowPeople.dart';
import 'basemodel.dart';

class ShowStatus extends StatefulWidget {
  List<BaseModel> stories;
  int defPosition;
  ShowStatus(this.stories, this.defPosition);

  @override
  _ShowStatusState createState() => _ShowStatusState();
}

class _ShowStatusState extends State<ShowStatus> with TickerProviderStateMixin{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<BaseModel> stories;
  PageController pc = PageController();
  double currentPage = 0;
  int currentPageInt = 0;
  Timer timer;
  bool tappingDown = false;
  int defPosition;
  List<double> progressValue = List();
  bool showHeart = false;
  BaseModel personModel;
//  double heartSize = 40;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    Screen.keepOn(false);
    if (timer != null) timer.cancel();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Screen.keepOn(true);
    stories = widget.stories;
    defPosition = widget.defPosition;
    for (int i = 0; i < stories.length; i++) progressValue.add(0);
    pc.addListener(() {
      setState(() {
        currentPage = pc.page;
      });
    });

    Future.delayed(Duration(milliseconds: 500), () {
      pc.jumpToPage(defPosition);
      createTimer(defPosition);
      handleSeen(0);
    });
    loadPerson();
  }

  loadPerson()async{
    String id = stories[0].getUserId();
    DocumentSnapshot doc = await Firestore.instance.collection(USER_BASE).document(id).get();
    personModel = BaseModel(doc:doc);
    setState(() {

    });
  }

  handleChange(int index) {
    if (index < currentPageInt) {
      progressValue[index] = 0;
      for (int i = currentPageInt; i > index; i--) {
        progressValue[i] = 0;
      }
    } else if (index > currentPageInt) {
      progressValue[index] = 0;
      for (int i = currentPageInt; i < index; i++) {
        progressValue[i] = 100;
      }
    }
  }

  handleSeen(int index) {
    BaseModel model = stories[index];
    if (stories[index].myItem()) return;

    List shown = model.getList(SHOWN);
    if(shown.contains(userModel.getObjectId())) return;

    model.putInList(SHOWN, userModel.getObjectId(), true);
    model.updateItems(updateTime: false);
    setState(() {});
  }

  createTimer(int position) {
    int seconds = 3;
    BaseModel model = stories[position];

    if (timer != null) {
      timer.cancel();
    }
    int milli = seconds * 1000;
    double freq = milli / 100;
    timer = Timer.periodic(Duration(milliseconds: freq.toInt()), (timer) async {
      double val = progressValue[position];
      val = val + 1;
      progressValue[position] = val;
      if (val >= 100) {
        timer.cancel();
        position++;
        if (position < stories.length) {
          await pc.animateToPage(position,
              duration: Duration(milliseconds: 500), curve: Curves.ease);
        } else {
//          Navigator.pop(context, "");
        }
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, "");
        return;
      },
      child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: black,
          body: Container(
            color: stories[currentPageInt].getString(COLOR_KEY).isEmpty?black:
            getColorForKey(stories[currentPageInt].getString(COLOR_KEY)),
            child: new Stack(
              fit: StackFit.expand,
              children: <Widget>[

                PageView.builder(
                    itemBuilder: (c, position) {
                      if (position == currentPage.floor()) {
                        return Transform(
                          transform: Matrix4.identity()
                            ..rotateX(currentPage - position),
                          child: page(position),
                        );
                      } else if (position == currentPage.floor() + 1) {
                        return Transform(
                          transform: Matrix4.identity()
                            ..rotateX(currentPage - position),
                          child: page(position),
                        );
                      } else {
                        return page(position);
                      }
                      /*  */
                    },
                    itemCount: stories.length,
                    controller: pc,
                    onPageChanged: (index) {
                      if (timer != null) {
                        timer.cancel();
                      }
                      handleChange(index);
                      currentPageInt = index;
                      createTimer(currentPageInt);
                      handleSeen(index);
                    }),
               /* Column(
                  children: <Widget>[
                    Expanded(flex: 1, child: Container()),
                    gradientLine(alpha: .7, height: 100)
                  ],
                ),*/
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                      addSpace(40),
                    Row(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () async {
                            Navigator.pop(context, "");
                          },
                          child: Container(
                              //margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
                              width: 50,
                              height: 50,
                              child: Icon(
                                Icons.arrow_back,
                                color: white,
                                size: 20,
                              )),
                        ),
                        Flexible(child: personModel==null?Container():GestureDetector(
                          onTap: (){
                            //pushAndResult(context,MyProfile1(personModel));
                          },
                          child: Container(color: transparent,
                            child: Row(
                              children: <Widget>[
                                imageHolder(
                                    35,
                                    stories[currentPageInt]
                                        .getString(USER_IMAGE),
                                    strokeColor: blue3,
                                    stroke: 0),
                                addSpaceWidth(10),
                                Flexible(
                                  flex: 1,
                                  fit: FlexFit.tight,
                                  child: Text(
                                    "${stories[currentPageInt].getString(NAME)}",
                                    style: textStyle(true, 16, white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),

                        if (stories[currentPageInt].getString(USER_ID) ==
                            userModel.getObjectId() || isAdmin)
                          GestureDetector(
                            onTap: () async {
                              yesNoDialog(context, "Delete Story?",
                                  "Are you sure you want to delete this story?",
                                  () {
                                BaseModel v = stories[currentPageInt];
                                v.deleteItem();
                                Navigator.pop(context, v.getObjectId());
                                /*stories.removeAt(currentPageInt);
                                if (stories.isEmpty) {
                                  Navigator.pop(context, "remove");
                                } else {
                                  progressValue.removeAt(currentPageInt);
                                  positions.removeAt(currentPageInt);
                                  controllers.removeAt(currentPageInt);
                                  if (timer != null) timer.cancel();
                                  pc.jumpToPage(currentPageInt == 0
                                      ? 0
                                      : currentPageInt - 1);
                                  setState(() {});
                                }*/
                              });
                            },
                            child: Container(
                                //margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
                                width: 50,
                                height: 50,
                                child: Icon(
                                  Icons.delete,
                                  color: white,
                                  size: 20,
                                )),
                          ),
                      ],
                    ),
                    new Expanded(
                      flex: 1,
                      child: Container(
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                changePage(false);
                              },
                              onHorizontalDragStart: (_) {
                                changePage(false);
                              },
                              child: Container(
                                height: double.infinity,
                                width: 50,
                                color: transparent,
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: Container(),
                              fit: FlexFit.tight,
                            ),
                            GestureDetector(
                              onTap: () {
                                changePage(true);
                              },
                              onHorizontalDragStart: (_) {
                                changePage(true);
                              },
                              child: Container(
                                height: double.infinity,
                                width: 50,
                                color: transparent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if(stories[currentPageInt].getString(STORY_IMAGE).isNotEmpty
                       && stories[currentPageInt].getString(STORY_TEXT).isNotEmpty)Container(
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      margin: EdgeInsets.only(bottom: 125),
                      width: double.infinity,
                      decoration: BoxDecoration(color: black.withOpacity(.5),borderRadius: BorderRadius.all(Radius.circular(0))),
                      child: ReadMoreText(stories[currentPageInt].getString(STORY_TEXT),fontSize: 16,textColor: white,minLength: 150,center: true,),
                    )  ,

                  ],
                ),
                IgnorePointer(
                  ignoring: true,child: Container(
                  width: double.infinity,
                  child: LinearProgressIndicator(
                    value: (progressValue[currentPageInt] / 100),
                    backgroundColor: transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      black.withOpacity(.2),
                    ),
                  ),
                ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: tabIndicator(stories.length,currentPageInt,margin: EdgeInsets.all(10)),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child:  myStory()?(
                      GestureDetector(
                        onTap: ()async{
                          timer.cancel();
                          pushAndResult(
                              context,
                              ShowPeople(stories[currentPageInt].getList(LIKED), "Loved By",
                                "Nothing to display",),opaque: false,result: (_){
                            createTimer(currentPageInt);
                          });
                        },
                        child: new Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 50),
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            width: 70,
                          height: 30,
                          decoration: BoxDecoration(
                              color: black.withOpacity(.8),
                              borderRadius: BorderRadius.all(Radius.circular(25))
                          ),
                          child: Center(
                            child: Row(mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                formatPrice("${stories[currentPageInt].getList(LIKED).length}"),
                                  style: textStyle(true, 14, white),
                                ),
                                addSpaceWidth(5),
                                Image.asset(heart,color: red0,width: 12,height: 12,)
                              ],
                            ),
                          ),
                        ),
                      )
                  ):Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if(stories[currentPageInt].getList(LIKED).isNotEmpty)Text(
                        "${formatPrice(stories[currentPageInt].getList(LIKED).length.toString())} Like"
                            "${stories[currentPageInt].getList(LIKED).length>1?"s":""}",
                        style: textStyle(true, 14, white),
                      ),
                      Container(
                        width: 50,height: 50,margin: EdgeInsets.only(bottom: 50,top: 5),
                        child: FloatingActionButton(onPressed: (){
                          bool liked = isLiked();
                          handleLiked(!liked);
                          if(liked)return;
                         showHeart=true;
                         Future.delayed(Duration(milliseconds: 500),(){
                           showHeart=false;
                           setState(() {});
                         });
                        },heroTag: "h2",
                          shape: CircleBorder(
                           //   side: BorderSide(color: white,width: 3)
                          ),
                          child: Image.asset(!isLiked()?heart_border:heart,width: 25,height: 25,color: white,),
                          backgroundColor: red0,elevation: 5,),
                      ),
                    ],
                  ),
                ),

                !showHeart
                    ? Container()
                    : Container(
                  color: black.withOpacity(.5),
                  child: Center(
                    child: Image.asset(heart,width: 60,height: 60,color: white,),
                  ),
                ),
              ],
            ),
          )),
    );
  }

  bool myStory(){
    return (stories[currentPageInt].getString(USER_ID) ==
        userModel.getObjectId());
  }

  page(int index) {
    BaseModel model = stories[index];
    String image = model.getString(STORY_IMAGE);
    String message = model.getString(STORY_TEXT);
    return GestureDetector(
      onTapDown: (_) {
        tappingDown = true;
        if (timer != null) timer.cancel();
      },
      onTapUp: (_) {
        tappingDown = false;
        createTimer(index);
      },
      child: Container(
        color: transparent,
        child: image.isEmpty?(
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Text(message,style: textStyle(true, 40, white),textAlign: TextAlign.center,),
              ),
            )
        ):CachedNetworkImage(imageUrl: model.getString(STORY_IMAGE),
          placeholder: (c,s){
            return Container(width: 20,height: 20,child: Center(
              child: CircularProgressIndicator(
                //value: 20,
                valueColor: AlwaysStoppedAnimation<Color>(white),
                strokeWidth: 2,
              ),
            ));
          },),
      ),
    );
  }

  void downloadFile(File file, String url) async {
    QuerySnapshot shots = await Firestore.instance
        .collection(REFERENCE_BASE)
        .where(FILE_URL, isEqualTo: url)
        .limit(1)
        .getDocuments();
    if (shots.documents.isEmpty) {
      //toastInAndroid("Link not found");
    } else {
      for (DocumentSnapshot doc in shots.documents) {
        if (!doc.exists || doc.data.isEmpty) continue;
        BaseModel model = BaseModel(doc: doc);
        String ref = model.getString(REFERENCE);
        StorageReference storageReference =
            FirebaseStorage.instance.ref().child(ref);
        storageReference.writeToFile(file).future.then((_) {
          //toastInAndroid("Download Complete");
        }, onError: (error) {
          //toastInAndroid(error);
        }).catchError((error) {
          //toastInAndroid(error);
        });

        break;
      }
    }
  }

  handleLiked(bool love) {
    BaseModel model = stories[currentPageInt];

    model.putInList(LIKED, userModel.getObjectId(), love);
    model.updateItems(updateTime: false);
    setState(() {});
  }

  bool isLiked(){
    BaseModel model = stories[currentPageInt];

    List liked = model.getList(LIKED);
    return (liked.contains(userModel.getObjectId()));
  }

  changePage(bool next) {
    int position = currentPageInt;
    if (next) position++;
    if (!next) position--;
    if (position < stories.length && next) {
      pc.animateToPage(position,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
    } else if (!next && position >= 0) {
      pc.animateToPage(position,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
    } else {
      Navigator.pop(context, "");
    }
  }

  bool allRead() {
    for (BaseModel bm in stories) {
      if (!bm.getList(SHOWN).contains(userModel.getObjectId())) return false;
    }
    return true;
  }
}
