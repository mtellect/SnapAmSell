import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/AppConfig.dart';
import 'package:maugost_apps/assets.dart';

class messageDialog extends StatelessWidget {
  var icon;
  Color iconColor;
  String title;
  String message;
  String yesText;
  String noText;
  BuildContext context;
  bool cancellable;
  double iconPadding;
  double textSize;

  messageDialog(
      this.icon, this.iconColor, this.title, this.message, this.yesText,
      {this.noText,
      this.cancellable = false,
      this.iconPadding = 0,
      this.textSize = 14});
  /* {
    this.iconColor = iconColor;
    this.icon = icon;
    this.title = title;
    this.message = message;
    this.yesText = yesText;
    this.noText = noText;
    this.cancellable = cancellable;
    this. = ;
    this.iconPadding = iconPadding;
  }*/

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return WillPopScope(
      onWillPop: () {
        if (cancellable) Navigator.pop(context);
      },
      child: Stack(fit: StackFit.expand, children: <Widget>[
        GestureDetector(
          onTap: () {
            if (cancellable) Navigator.pop(context);
          },
          child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
              child: Container(
                color: black.withOpacity(.7),
              )),
        ),
        page()
      ]),
    );
  }

  page() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25, 45, 25, 25),
        child: new Container(
          decoration: BoxDecoration(
              color: white, borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    new Container(
                      width: double.infinity,
                      child: new Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Image.asset(
                            ic_launcher,
                            //color: red0,
                            height: 15,
                            width: 15,
                          ),
                          addSpaceWidth(10),
                          Flexible(
                            flex: 1,
                            child: new Text(
                              AppConfig.appName,
                              style:
                                  textStyle(false, 11, black.withOpacity(.8)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: Container(
                          width: 55,
                          height: 55,
                          padding: EdgeInsets.all(
                              iconPadding == null ? 0 : iconPadding),
                          decoration: BoxDecoration(
//                            color: iconColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: iconColor, width: 4)),
                          child: (icon is String)
                              ? (Image.asset(
                                  icon,
                                  color: iconColor,
                                  width: 35,
                                  height: 35,
                                ))
                              : Icon(
                                  icon,
                                  color: iconColor,
                                  size: 35,
                                )),
                    ),
                  ],
                ),
                //addSpace(5),

                ConstrainedBox(
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height / 2),
                  child: new Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        addSpace(10),
                        Text(
                          title,
                          style: textStyle(true, 16, black),
                          textAlign: TextAlign.center,
                        ),
                        addSpace(5),
                        Text(
                          message,
                          style: textStyle(false, 14, black.withOpacity(.7)),
                          textAlign: TextAlign.center,
                        ),
                        addSpace(15),
                        Container(
                          height: 40,
                          child: FlatButton(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25)),
                              color: blue3,
                              onPressed: () {
                                Navigator.pop(context, true);
                              },
                              child: Text(
                                yesText,
                                style: textStyle(true, 16, white),
                              )),
                        ),
                        noText == null
                            ? new Container()
                            : Container(
                                width: double.infinity,
                                child: FlatButton(
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    /*shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25)),
                              color: blue3,*/
                                    onPressed: () {
                                      Navigator.pop(context, false);
                                    },
                                    child: Text(
                                      noText,
                                      style: textStyle(false, 14, red0),
                                    )),
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
