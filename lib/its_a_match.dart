import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/AppConfig.dart';
import 'package:maugost_apps/basemodel.dart';

import 'MainAdmin.dart';
import 'assets.dart';

class ItsAMatch extends StatefulWidget {
  final BaseModel user;

  const ItsAMatch({Key key, this.user}) : super(key: key);
  @override
  _ItsAMatchState createState() => _ItsAMatchState();
}

class _ItsAMatchState extends State<ItsAMatch> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: transparent,
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: widget.user.profilePhotos[0].imageUrl,
            fit: BoxFit.cover,
            height: MediaQuery.of(context).size.height,
          ),
          GestureDetector(
            onTap: () {
              overlayController.add(true);
              Navigator.pop(context);
            },
            child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  color: black.withOpacity(.6),
                )),
          ),
          Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                        width: 140,
                        height: 140,
                        child: LoadingIndicator(
                          indicatorType: Indicator.ballScaleMultiple,
                          color: red,
                        )),
                    Container(
                      height: 80,
                      width: 80,
                      decoration:
                          BoxDecoration(color: red, shape: BoxShape.circle),
                      child: Icon(
                        Icons.favorite,
                        size: 50,
                        color: white,
                      ),
                    ),
                  ],
                ),
                addSpace(10),
                Text(
                  "It's a Match!",
                  style: GoogleFonts.niconne(
                      color: white, fontSize: 60, fontWeight: FontWeight.bold),
                  //style: textStyle(true, 25, white),
                ),
                addSpace(10),
                FlatButton(
                  onPressed: () {
                    clickChat(context, widget.user, false,
                        replace: true, depend: false);
                  },
                  color: AppConfig.appColor,
                  padding: EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Text(
                    "Chat Now!",
                    style: textStyle(true, 16, white),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
