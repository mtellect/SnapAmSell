import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/assets.dart';

/*class progressDialog extends StatefulWidget {
  String id;
  String message;
  bool cancelable;
  BuildContext context;

  progressDialog(id, {bool cancelable = false, message = ""}) {
    this.id = id;
    this.message = message;
    this.cancelable = cancelable;
  }

  @override
  _progressDialogState createState() {
    return _progressDialogState(id, message: message, cancelable: cancelable);
  }
}*/

class progressDialog extends StatefulWidget {
  String id;
  String message;
  bool cancelable;
  double countDown;
  progressDialog(this.id,
      {this.message = "", this.cancelable = false, this.countDown = 0});
  @override
  _progressDialogState createState() => _progressDialogState();
}

class _progressDialogState extends State<progressDialog> {
  String id;
  String message;
  bool cancelable;
  double countDown;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    id = widget.id;
    message = widget.message ?? "";
    cancelable = widget.cancelable ?? false;
    countDown = widget.countDown ?? 0;
  }

  void hideHandler() {
    Future.delayed(Duration(milliseconds: 500), () {
      if (currentProgress == id) {
        Navigator.pop(context);
        return;
      }

//      setState(() {
//      });
      //message = currentProgressText;
      if (countDown > 0) {
        setState(() {
          countDown = countDown - 0.5;
        });
      }

      hideHandler();
    });
  }

  @override
  Widget build(BuildContext context) {
    hideHandler();

    return WillPopScope(
      child: Stack(fit: StackFit.expand, children: <Widget>[
        BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
            child: Container(
              color: black.withOpacity(.2),
            )),
        page()
      ]),
      onWillPop: () async {
        if (cancelable) Navigator.pop(context);
        return false;
      },
    );
  }

  page() {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        GestureDetector(
          onTap: () {
            if (cancelable) Navigator.pop(context);
          },
          child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
              child: Container(
                color: black.withOpacity(.7),
              )),
        ),
        Center(
            child: Container(
                width: 120,
                height: 120,
                child: LoadingIndicator(
                  indicatorType: Indicator.cubeTransition,
                  color: white,
                ))),
        Center(
          child: Opacity(
            opacity: 1,
            child: Image.asset(ic_plain, // color: black,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                alignment: Alignment.center

                //color: white,
                ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: new Container(),
              flex: 1,
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                countDown > 0
                    ? "$message (in ${countDown.toInt()} secs)"
                    : message,
                style: textStyle(false, 15, white),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
