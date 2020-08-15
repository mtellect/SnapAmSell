import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/assets.dart';

import '../AppConfig.dart';

class listDialog extends StatefulWidget {
  String title;
  var items;
  List images;
  bool useTint;
  List selections;

  listDialog(items, {title, images, bool useTint = true, selections}) {
    this.title = title;
    this.items = items;
    this.images = images == null ? List() : images;
    this.useTint = useTint;
    this.selections = selections;
  }

  @override
  _listDialogState createState() => _listDialogState();
}

class _listDialogState extends State<listDialog> {
  BuildContext context;

  List selections = [];
  bool multiple;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    multiple = widget.selections != null;
    selections = widget.selections ?? [];
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return Stack(fit: StackFit.expand, children: <Widget>[
      GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
            child: Container(
              color: black.withOpacity(.7),
            )),
      ),
      page()
    ]);
  }

  page() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25, 45, 25, 25),
        child: new Container(
          decoration: BoxDecoration(
              color: white, borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Container(
                  width: double.infinity,
                  child: new Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      addSpaceWidth(15),
                      Image.asset(
                        ic_plain,
                        height: 14,
                        width: 14,
                        color: red0,
                      ),
                      addSpaceWidth(10),
                      new Flexible(
                        flex: 1,
                        child: widget.title == null
                            ? new Text(
                                AppConfig.appName,
                                style:
                                    textStyle(false, 11, black.withOpacity(.1)),
                              )
                            : new Text(
                                widget.title,
                                style: textStyle(true, 20, black),
                              ),
                      ),
                      addSpaceWidth(15),
                    ],
                  ),
                ),
                addSpace(5),
                addLine(.5, black.withOpacity(.1), 0, 0, 0, 0),
                Flexible(
                  fit: FlexFit.loose,
                  child: Container(
                    color: white,
                    child: new ConstrainedBox(
                      constraints: BoxConstraints(
                          maxHeight: (MediaQuery.of(context).size.height / 2) +
                              (MediaQuery.of(context).orientation ==
                                      Orientation.landscape
                                  ? 0
                                  : (MediaQuery.of(context).size.height / 5))),
                      child: Scrollbar(
                        child: new ListView.builder(
                          padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                          itemBuilder: (context, position) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                position == 0
                                    ? Container()
                                    : addLine(
                                        .5, black.withOpacity(.1), 0, 0, 0, 0),
                                GestureDetector(
                                  onTap: () {
                                    if (multiple) {
                                      bool selected = selections
                                          .contains(widget.items[position]);
                                      if (selected) {
                                        selections
                                            .remove(widget.items[position]);
                                      } else {
                                        selections.add(widget.items[position]);
                                      }
                                      setState(() {});
                                      return;
                                    }
                                    Navigator.of(context)
                                        .pop(widget.items[position]);
                                  },
                                  child: new Container(
                                    color: white,
                                    width: double.infinity,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 15, 0, 15),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          widget.images.isEmpty
                                              ? Container()
                                              : !(widget.images[position]
                                                      is String)
                                                  ? Icon(
                                                      widget.images[position],
                                                      size: 17,
                                                      color: !widget.useTint
                                                          ? null
                                                          : black
                                                              .withOpacity(.3),
                                                    )
                                                  : Image.asset(
                                                      widget.images[position],
                                                      width: 17,
                                                      height: 17,
                                                      color: !widget.useTint
                                                          ? null
                                                          : black
                                                              .withOpacity(.3),
                                                    ),
                                          widget.images.isNotEmpty
                                              ? addSpaceWidth(10)
                                              : Container(),
                                          Flexible(
                                            flex: 1,
                                            fit: FlexFit.tight,
                                            child: Text(
                                              widget.items[position],
                                              style: textStyle(false, 18,
                                                  black.withOpacity(.8)),
                                            ),
                                          ),
                                          if (multiple) addSpace(10),
                                          if (multiple)
                                            checkBox(selections.contains(
                                                widget.items[position]))
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                          itemCount: widget.items.length,
                          shrinkWrap: true,
                        ),
                      ),
                    ),
                  ),
                ),
                addLine(.5, black.withOpacity(.1), 0, 0, 0, 0),
                if (multiple)
                  Container(
                      width: double.infinity,
                      height: 40,
                      margin: EdgeInsets.all(10),
                      child: FlatButton(
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                              side: BorderSide(color: blue0, width: 1),
                              borderRadius: BorderRadius.circular(10)),
                          color: white,
                          onPressed: () {
                            /*if(selections.isEmpty){
                              toastInAndroid("Nothing Selected");
                              return;
                            }*/
                            Navigator.pop(context, selections);
                          },
                          child: Text(
                            "OK",
                            style: textStyle(true, 16, blue0),
                          )))
                //gradientLine(alpha: .1)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
