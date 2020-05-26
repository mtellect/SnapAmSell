import 'dart:io';

import 'package:Strokes/AppEngine.dart';
import 'package:Strokes/MainAdmin.dart';
import 'package:Strokes/app_config.dart';
import 'package:Strokes/assets.dart';
import 'package:Strokes/basemodel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShowProfile extends StatefulWidget {
  final BaseModel theUser;
  final bool fromMeetMe;

  const ShowProfile({Key key, this.theUser, this.fromMeetMe = false})
      : super(key: key);
  @override
  _ShowProfileState createState() => _ShowProfileState();
}

class _ShowProfileState extends State<ShowProfile> {
  BaseModel theUser;
  double matchRate = 0;
  @override
  void initState() {
    super.initState();
    theUser = widget.theUser;
    userModel
      //..putInList(SEEN_BY, theUser.getUserId(), true)
      ..putInList(VIEWED_LIST, theUser.getUserId(), true)
      ..updateItems();

    theUser
      ..putInList(SEEN_BY, userModel.getUserId(), true)
      ..updateItems();

    if (theUser.getInt(ETHNICITY) == userModel.getInt(ETHNICITY)) {
      matchRate = matchRate + 80;
    }
    if (theUser.getInt(RELATIONSHIP) == userModel.getInt(RELATIONSHIP)) {
      matchRate = matchRate + 80;
    }
    matchRate = matchRate > 100 ? 100 : matchRate;
    matchRate = matchRate < 50 ? 50 : matchRate;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        overlayController.add(false);

        return true;
      },
      child: Scaffold(
        //backgroundColor: white,
        body: page(),
      ),
    );
  }

  String get formatBirthDate {
    final date = DateTime.parse(theUser.birthDate);
    return new DateFormat("MMMM d").format(date);
  }

  //Gender relationship and ethnicity if 3 match 80% else if all match 100%
  //For 100% match
  page() {
    List images = theUser.getList(PROFILE_PHOTOS);
    //String image = getFirstPhoto(images);
    String image = theUser.profilePhotos[0].imageUrl;

    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: image,
          height: getScreenHeight(context) * 0.5,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Container(
          height: getScreenHeight(context) * 0.5,
          color: black.withOpacity(.1),
        ),
        Column(
          children: [
            Container(
              height: 100,
              //color: black.withOpacity(.1),
            ),
            Flexible(
              child: ListView(
                children: [
                  Container(
                    height: getScreenHeight(context) * 0.25,
                  ),
                  Container(
                    // height: 220,
                    //margin: EdgeInsets.all(20),
                    color: transparent,
                    child: Container(
                      child: Stack(
                        //mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            margin: EdgeInsets.all(20),
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      color: black.withOpacity(.3),
                                      blurRadius: 5),
                                ],
                                color: white,
                                borderRadius: BorderRadius.circular(25)),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  theUser.getString(NAME),
                                  style: textStyle(true, 18, black),
                                ),
                                addSpace(10),
                                Row(
                                  children: [
                                    Image.asset(
                                      "assets/icons/gender.png",
                                      height: 30,
                                      width: 30,
                                      color: black.withOpacity(.6),
                                      fit: BoxFit.cover,
                                    ),
                                    addSpaceWidth(5),
                                    Text.rich(TextSpan(children: [
                                      TextSpan(text: "Interest in "),
                                      TextSpan(
                                        text: preferenceType[
                                            userModel.getInt(PREFERENCE)],
                                        style: textStyle(false, 18, black),
                                      )
                                    ]))
                                  ],
                                ),
                                addSpace(10),
                                Row(
                                  children: [
                                    Image.asset(
                                      "assets/icons/gender.png",
                                      height: 30,
                                      width: 30,
                                      color: black.withOpacity(.6),
                                      fit: BoxFit.cover,
                                    ),
                                    addSpaceWidth(5),
                                    Text.rich(TextSpan(children: [
                                      TextSpan(text: "Relationship Pref "),
                                      TextSpan(
                                        text: relationshipType[
                                            userModel.getInt(RELATIONSHIP)],
                                        style: textStyle(false, 18, black),
                                      )
                                    ]))
                                  ],
                                ),
                                addSpace(10),
                                Row(
                                  children: [
                                    Image.asset(
                                      "assets/icons/network.png",
                                      height: 30,
                                      width: 30,
                                      color: black.withOpacity(.6),
                                      fit: BoxFit.cover,
                                    ),
                                    addSpaceWidth(5),
                                    Text.rich(TextSpan(children: [
                                      TextSpan(text: "Ethnicity Pref "),
                                      TextSpan(
                                        text: ethnicityType[
                                            userModel.getInt(ETHNICITY)],
                                        style: textStyle(false, 18, black),
                                      )
                                    ]))
                                  ],
                                ),
                                addSpace(10),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      color: black.withOpacity(.5),
                                    ),
                                    addSpaceWidth(5),
                                    Text.rich(TextSpan(children: [
                                      //TextSpan(text: "Last Seen "),
                                      TextSpan(
                                        text: getLastSeen(theUser),
                                        style: textStyle(false, 18, black),
                                      )
                                    ]))
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: AppConfig.appColor,
                                  gradient: LinearGradient(
                                      colors: [
                                        orange01,
                                        orange04,
                                        orange01,
                                        //AppConfig.appColor.withOpacity(.7),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight),
                                  borderRadius: BorderRadius.circular(25)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.favorite,
                                    color: white,
                                    size: 20,
                                  ),
                                  addSpaceWidth(10),
                                  Text(
                                    "${matchRate.toInt()}% Match!",
                                    style: textStyle(false, 16, white),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
//                        Container(
//                          height: 60,
//                          width: 60,
//                          child: Icon(
//                            Icons.more_horiz,
//                            color: white,
//                          ),
//                          decoration: BoxDecoration(
//                            color: AppConfig.appColor,
//                            shape: BoxShape.circle,
//                            gradient: LinearGradient(
//                                colors: [
//                                  orange01,
//                                  orange04,
//                                  //AppConfig.appColor.withOpacity(.7),
//                                ],
//                                begin: Alignment.topLeft,
//                                end: Alignment.bottomRight),
//                          ),
//                        ),
//                        addSpaceWidth(15),
                        GestureDetector(
                          onTap: () {
                            clickChat(context, theUser, false);
                          },
                          child: Container(
                            padding: EdgeInsets.all(18),
                            decoration: BoxDecoration(
                                color: AppConfig.appColor,
                                gradient: LinearGradient(
                                    colors: [
                                      orange01,
                                      orange04,
                                      //AppConfig.appColor.withOpacity(.7),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight),
                                borderRadius: BorderRadius.circular(25)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.chat,
                                  color: white,
                                  size: 20,
                                ),
                                addSpaceWidth(10),
                                Text(
                                  "Start Chatting",
                                  style: textStyle(false, 16, white),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(20),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(color: black.withOpacity(.3), blurRadius: 5),
                    ], color: white, borderRadius: BorderRadius.circular(25)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Photos",
                          style: textStyle(true, 16, black),
                        ),
                        //addSpace(10),
                        photoBox(theUser.profilePhotos)
                      ],
                    ),
                  ),
                  if (widget.fromMeetMe)
                    Container(
                      margin: EdgeInsets.all(20),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(color: black.withOpacity(.3), blurRadius: 5),
                      ], color: white, borderRadius: BorderRadius.circular(25)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Quick Strock Photos",
                            style: textStyle(true, 16, black),
                          ),
                          //addSpace(10),
                          photoBox(theUser.hookUpPhotos)
                        ],
                      ),
                    ),
                  if (theUser.getString(ABOUT_ME).isNotEmpty)
                    Container(
                      margin: EdgeInsets.all(20),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(color: black.withOpacity(.3), blurRadius: 5),
                      ], color: white, borderRadius: BorderRadius.circular(25)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "About Me",
                            style: textStyle(true, 16, black),
                          ),
                          addSpace(10),
                          Text(
                            theUser.getString(ABOUT_ME),
                            style: textStyle(false, 14, black),
                          ),
                        ],
                      ),
                    ),
                  if (theUser.getString(WOW_FACTOR).isNotEmpty)
                    Container(
                      margin: EdgeInsets.all(20),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(color: black.withOpacity(.3), blurRadius: 5),
                      ], color: white, borderRadius: BorderRadius.circular(25)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Wow Factor",
                            style: textStyle(true, 16, black),
                          ),
                          addSpace(10),
                          Text(
                            theUser.getString(WOW_FACTOR),
                            style: textStyle(false, 14, black),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.only(top: 35, right: 15, left: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BackButton(
                color: white,
              ),
//              IconButton(
//                onPressed: () {},
//                icon: Icon(
//                  Icons.more_vert,
//                  color: white,
//                ),
//              )
            ],
          ),
        )
      ],
    );
  }

  photoBox(List<BaseModel> photos) {
    //final hookUpPhotos = theUser.hookUpPhotos;
    return Column(
      children: [
        if (photos.isNotEmpty)
          Container(
            height: 240,
            child: LayoutBuilder(
              builder: (ctx, b) {
                int photoLength = photos.length;
                return Column(
                  children: <Widget>[
                    Flexible(
                      child: ListView.builder(
                          itemCount: photoLength,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (ctx, p) {
                            BaseModel photo = photos[p];
                            bool isVideo = photo.isVideo;
                            String imageUrl = photo
                                .getString(isVideo ? THUMBNAIL_URL : IMAGE_URL);
                            bool isLocal = photo.isLocal;
                            return GestureDetector(
                              onTap: () {
                                if (isVideo) {
                                } else {
                                  pushAndResult(
                                      context,
                                      ViewImage(
                                          photos
                                              .map((e) => e.imageUrl)
                                              .toList(),
                                          p),
                                      depend: false);
                                }
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.all(8),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: isLocal
                                          ? Image.file(
                                              File(imageUrl),
                                              height: 200,
                                              width: 160,
                                              fit: BoxFit.cover,
                                            )
                                          : CachedNetworkImage(
                                              imageUrl: imageUrl,
                                              height: 200,
                                              width: 160,
                                              fit: BoxFit.cover,
                                              placeholder: (ctx, s) {
                                                return placeHolder(200,
                                                    width: 160);
                                              },
                                            ),
                                    ),
                                  ),
                                  if (isVideo)
                                    Center(
                                      child: Container(
                                        height: 50,
                                        width: 50,
                                        child: Icon(
                                          Icons.play_arrow,
                                          color: Colors.white,
                                        ),
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.8),
                                            border: Border.all(
                                                color: Colors.white,
                                                width: 1.5),
                                            shape: BoxShape.circle),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }
}
