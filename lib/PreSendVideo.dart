import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/SimpleVideoPlayer.dart';
import 'package:maugost_apps/AppConfig.dart';
import 'package:maugost_apps/assets.dart';

//import 'package:maugost_apps/photo_picker/photo.dart';

class PreSendVideo extends StatefulWidget {
  File videoFile;

  PreSendVideo(this.videoFile);
  @override
  _PreSendVideoState createState() => _PreSendVideoState();
}

class _PreSendVideoState extends State<PreSendVideo> {
  File videoFile;
  String videoDuration;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    videoFile = widget.videoFile;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppConfig.appColor,
        body: page());
  }

  BuildContext con;

  Builder page() {
    return Builder(builder: (context) {
      this.con = context;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          addSpace(30),
          new Container(
            width: double.infinity,
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      child: Center(
                          child: Icon(
                        Icons.keyboard_backspace,
                        color: black,
                        size: 25,
                      )),
                    )),
                Flexible(
                  fit: FlexFit.tight,
                  flex: 1,
                  child: new Text(
                    "Video Preview",
                    style: textStyle(true, 17, black),
                  ),
                ),
                addSpaceWidth(10),
                Container(
                  width: 70,
                  child: FlatButton(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      color: white,
                      onPressed: () {
                        Navigator.of(context).pop(videoDuration);
                      },
                      child:
                          /* Text(
                        "SEND",
                        style: textStyle(true, 14, white),
                      )*/
                          Icon(
                        Icons.send,
                        color: AppConfig.appColor,
                        size: 16,
                      )),
                ),
                addSpaceWidth(15)
              ],
            ),
          ),
          addLine(1, black.withOpacity(.1), 0, 0, 0, 0),
          Expanded(
            flex: 1,
            child: new Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
              color: black,
              width: double.infinity,
//              height: 200,
              child: SimpleVideoPlayer(
                file: videoFile,
                vidDuration: (_) {
                  if (_ != null) videoDuration = _;
                },
              ),
            ),
          ),
        ],
      );
    });
  }
}
