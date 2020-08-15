import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/SearchPlace.dart';
import 'package:maugost_apps/AppConfig.dart';
import 'package:maugost_apps/assets.dart';
import 'package:maugost_apps/basemodel.dart';

class FilterDialog extends StatefulWidget {
  BaseModel locationModel;
  int genderType = -1;
  int onlineType = -1;
  int interestType = -1;
  int minAge = 0;
  int maxAge = 0;
  FilterDialog(
    this.locationModel,
    this.genderType,
    this.onlineType,
    this.minAge,
    this.maxAge,
    this.interestType,
  );
  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  BaseModel locationModel;
  int genderType = -1;
  int onlineType = -1;
  int interestType = -1;
  int minAge = 0;
  int maxAge = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    locationModel = widget.locationModel;
    genderType = widget.genderType;
    onlineType = widget.onlineType;
    minAge = widget.minAge;
    maxAge = widget.maxAge;
    interestType = widget.interestType;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(fit: StackFit.expand, children: <Widget>[
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
      ]),
      backgroundColor: Colors.transparent,
    );
  }

  page() {
    return Dismissible(
      key: Key("a"),
      onDismissed: (c) {
        Navigator.pop(context);
      },
      direction: DismissDirection.up,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //addSpace(30),
          Container(
            color: white,
            padding: EdgeInsets.only(top: 30),
            child: Row(
              children: [
                IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                Flexible(
                    fit: FlexFit.tight,
                    child: Text(
                      "Filter",
                      style: textStyle(true, 22, black),
                    )),
                Container(
//                         width: 50,
                  height: 50,
                  child: FlatButton(
                    onPressed: () {
                      yesNoDialog(context, "Reset", "Are you sure?", () {
                        locationModel = null;
                        genderType = -1;
                        onlineType = -1;
                        minAge = 18;
                        maxAge = 80;
                        interestType = -1;
                        setState(() {});
                      });
                    },
                    child: Text(
                      "Reset",
                      style: textStyle(true, 18, red0),
                    ),
                  ),
                )
              ],
            ),
          ),
          Flexible(
              child: Container(
            width: double.infinity,
            child: Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25))),
              margin: EdgeInsets.all(0),
              color: white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  addLine(1, black.withOpacity(.1), 0, 0, 0, 0),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Location",
                            style: textStyle(false, 22, black),
                          ),
                          addSpace(10),
                          GestureDetector(
                            onTap: () {
                              pushAndResult(context, SearchPlace(),
                                  result: (BaseModel res) {
                                setState(() {
                                  locationModel = res;
                                });
                              }, depend: false);
                            },
                            child: Container(
                              width: double.infinity,
//                           margin: EdgeInsets.fromLTRB(15, 0, 15, 15),
                              padding: EdgeInsets.fromLTRB(15, 7, 15, 7),
                              //height: 50,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: black.withOpacity(.1), width: 1),
                                  borderRadius: BorderRadius.circular(25),
                                  color: locationModel == null
                                      ? white
                                      : AppConfig.appColor),
                              child: Row(
                                children: [
                                  Flexible(
                                    fit: FlexFit.tight,
                                    child: Text(
                                      locationModel == null
                                          ? "Search a Location"
                                          : (locationModel
                                              .getString(PLACE_NAME)),
                                      style: textStyle(
                                          false,
                                          18,
                                          locationModel != null
                                              ? white
                                              : black),
                                      maxLines: 1,
                                    ),
                                  ),
                                  Icon(
                                    Icons.place,
                                    size: 18,
                                    color:
                                        locationModel != null ? white : black,
                                  )
                                ],
                              ),
                            ),
                          ),
                          addSpace(15),
                          Text(
                            "Show Me",
                            style: textStyle(false, 22, black),
                          ),
                          addSpace(10),
                          groupedButtons(genderTypes,
                              genderType == -1 ? "" : genderTypes[genderType],
                              (text, p) {
                            setState(() {
                              genderType = p;
                            });
                          },
                              selectedColor: AppConfig.appColor,
                              normalColor: black.withOpacity(.6),
                              selectedTextColor: white,
                              normalTextColor: black),
                          addSpace(15),
                          Text(
                            "Filter By",
                            style: textStyle(false, 22, black),
                          ),
                          addSpace(10),
                          groupedButtons(onlineTypes,
                              onlineType == -1 ? "" : onlineTypes[onlineType],
                              (text, p) {
                            setState(() {
                              onlineType = p;
                            });
                          },
                              selectedColor: AppConfig.appColor,
                              normalColor: black.withOpacity(.6),
                              selectedTextColor: white,
                              normalTextColor: black),
                          // Wrap(
                          //   children: List.generate(onlineTypes.length, (p) {
                          //     bool active = onlineType == p;
                          //     return fieldSelector(onlineTypes[p],
                          //         active: active, size: 100, onTap: () {
                          //       setState(() {
                          //         onlineType = p;
                          //       });
                          //     });
                          //   }),
                          // ),
                          addSpace(15),
                          Text(
                            "Ages ${minAge == 0 ? "" : "$minAge - $maxAge"}",
                            style: textStyle(false, 22, black),
                          ),
                          addSpace(10),
                          FlutterSlider(
                            values: [
                              double.parse(minAge.toString()),
                              double.parse(maxAge.toString())
                            ],
                            rangeSlider: true,
                            max: 80,
                            min: 18,
                            onDragging: (handlerIndex, lowerValue, upperValue) {
                              minAge = lowerValue.toInt();
                              maxAge = upperValue.toInt();
                              setState(() {});
                            },
                          ),
                          addSpace(15),
                          Text(
                            "Interests",
                            style: textStyle(false, 22, black),
                          ),
                          addSpace(10),
                          // groupedButtons(
                          //     relationshipType,
                          //     interestType == -1
                          //         ? ""
                          //         : relationshipType[interestType], (text, p) {
                          //   setState(() {
                          //     interestType = p;
                          //   });
                          // },
                          //     selectedColor: blue0,
                          //     normalColor: blue0,
                          //     selectedTextColor: white,
                          //     normalTextColor: blue0),
                          Wrap(
                            children:
                                List.generate(relationshipType.length, (p) {
                              bool active = interestType == p;
                              return fieldSelector(relationshipType[p],
                                  active: active, onTap: () {
                                setState(() {
                                  interestType = p;
                                });
                              });
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                  addSpace(30),
                  addLine(.5, black.withOpacity(.1), 0, 0, 0, 0),
                  Container(
                    width: double.infinity,
                    height: 50,
                    child: FlatButton(
                      onPressed: () {
                        Navigator.pop(context, [
                          locationModel,
                          genderType,
                          onlineType,
                          minAge,
                          maxAge,
                          interestType
                        ]);
                      },
                      color: default_white,
                      child: Text(
                        "Apply",
                        style: textStyle(true, 18, black),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )),
          //addSpace(100)
        ],
      ),
    );
  }
}
