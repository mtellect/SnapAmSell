import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/CreateSubOption.dart';
import 'package:maugost_apps/assets.dart';

//import 'package:ABM/photo_picker/photo.dart';

class CreateOption extends StatefulWidget {
  Map item;
  CreateOption({this.item});
  @override
  _CreateOptionState createState() => _CreateOptionState();
}

class _CreateOptionState extends State<CreateOption> {
  final String progressId = getRandomId();

  TextEditingController nameController = new TextEditingController();
  String nameError;
  TextEditingController displayNameController = new TextEditingController();
  String displayNameError;

//  TextEditingController itemsController = new TextEditingController();
//  String itemsError;
  List items = [];

  bool multiSelection = false;
  int clickBack = 0;
  Map item;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    item = widget.item;
    if (item != null) {
      nameController.text = item[NAME];
      displayNameController.text = item[DISPLAY_NAME];
      items = item[ITEMS];
      multiSelection = item[MULTIPLE];
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext c) {
    return WillPopScope(
        onWillPop: () {
          int now = DateTime.now().millisecondsSinceEpoch;
          if ((now - clickBack) > 5000) {
            clickBack = now;
            showError("Click back again to exit");
            return;
          }
          Navigator.pop(context);
        },
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            key: _scaffoldKey,
            backgroundColor: white,
            body: page()));
  }

  page() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        addSpace(40),
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
                  item != null ? "Update ${item[NAME]}" : "Add Option",
                  style: textStyle(true, 20, black),
                ),
              ),
              addSpaceWidth(10),
              FlatButton(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  color: blue3,
                  onPressed: () {
                    post();
                  },
                  child: Text(
                    item != null ? "UPDATE" : "ADD",
                    style: textStyle(true, 14, white),
                  )),
              addSpaceWidth(15)
            ],
          ),
        ),
        //addLine(1, black.withOpacity(.2), 0, 5, 0, 0),
        AnimatedContainer(
          duration: Duration(milliseconds: 500),
          width: double.infinity,
          height: errorText.isEmpty ? 0 : 40,
          color: red0,
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Center(
              child: Text(
            errorText,
            style: textStyle(true, 16, white),
          )),
        ),
        Expanded(
          flex: 1,
          child: Scrollbar(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(0),
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (item == null)
                            inputTextView(
                              "Unique Name",
                              nameController,
                              isNum: false,
                              errorText: nameError,
                              onEditted: () {
                                nameError = null;
                                setState(() {});
                              },
                            ),
                          inputTextView(
                            "Display Name",
                            displayNameController,
                            isNum: false,
                            errorText: displayNameError,
                            onEditted: () {
                              displayNameError = null;
                              setState(() {});
                            },
                          ),
                          if (items.isNotEmpty)
                            Text(
                              "List Items",
                              style: textStyle(true, 14, blue0),
                            ),
                          if (items.isNotEmpty) addSpace(10),
                          if (items.isNotEmpty)
                            Container(
                              margin: EdgeInsets.only(bottom: 10),
                              child: Column(
                                children: List.generate(items.length, (p) {
                                  Map item = items[p];
                                  String name = item[NAME];
                                  String subItems = item[ITEMS];
                                  return GestureDetector(
                                    onTap: () {
                                      pushAndResult(
                                          context,
                                          CreateSubOption(
                                            item: item,
                                          ), result: (_) {
                                        items[p] = _;
                                        setState(() {});
                                      });
                                    },
                                    child: Container(
                                      padding:
                                          EdgeInsets.fromLTRB(10, 5, 10, 5),
                                      margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                      decoration: BoxDecoration(
                                          color: default_white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5)),
                                          border: Border.all(
                                              color: black.withOpacity(.1),
                                              width: .5)),
                                      child: Row(
                                        children: [
                                          Flexible(
                                              fit: FlexFit.tight,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    name,
                                                    style: textStyle(
                                                        true, 16, black),
                                                  ),
                                                  //if(subItems.isNotEmpty)addSpace(5),
                                                  if (subItems.isNotEmpty)
                                                    Text(
                                                      subItems,
                                                      style: textStyle(
                                                          false,
                                                          12,
                                                          black
                                                              .withOpacity(.4)),
                                                    ),
                                                ],
                                              )),
                                          addSpaceWidth(10),
                                          GestureDetector(
                                              onTap: () {
                                                items.removeAt(p);
                                                setState(() {});
                                              },
                                              child: Icon(
                                                Icons.remove_circle,
                                                color: red0,
                                              ))
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          GestureDetector(
                            onTap: () {
                              pushAndResult(context, CreateSubOption(),
                                  result: (_) {
                                items.add(_);
                                setState(() {});
                              });
                            },
                            child: Container(
                              height: 35,
                              margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              decoration: BoxDecoration(
                                  border: Border.all(color: blue0, width: 2),
                                  color: transparent,
                                  borderRadius: BorderRadius.circular(25)),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Flexible(
                                      flex: 1,
                                      fit: FlexFit.tight,
                                      child: Text(
                                        "Add Items",
                                        style: textStyle(true, 16, blue0),
                                      )),
                                  addSpaceWidth(10),
                                  Center(
                                      child: Icon(
                                    Icons.add_circle,
                                    color: blue0,
                                  ))
                                ],
                              ),
                            ),
                          ),
                          addSpace(5),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                multiSelection = !multiSelection;
                              });
                            },
                            child: Container(
                              height: 35,
                              margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              decoration: BoxDecoration(
                                  border: Border.all(color: blue0, width: 2),
                                  color: transparent,
                                  borderRadius: BorderRadius.circular(25)),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Flexible(
                                      flex: 1,
                                      fit: FlexFit.tight,
                                      child: Text(
                                        "Multi Selection",
                                        style: textStyle(true, 16, blue0),
                                      )),
                                  addSpaceWidth(10),
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                        color: multiSelection ? blue0 : blue09,
                                        border:
                                            Border.all(color: blue0, width: 1),
                                        shape: BoxShape.circle),
                                    child: multiSelection
                                        ? Center(
                                            child: Icon(
                                            Icons.check,
                                            color: white,
                                            size: 15,
                                          ))
                                        : Container(),
                                  )
                                ],
                              ),
                            ),
                          ),
                          addSpace(50),
                        ]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void post() {
    String name = nameController.text.trim();
    String displayName = displayNameController.text.trim();

    if (name.isEmpty && item == null) {
      nameError = "Enter Unique Name";
      setState(() {});
      return;
    }
    nameError = null;
    setState(() {});

    if (displayName.isEmpty) {
      displayNameError = "Enter Display Name";
      setState(() {});
      return;
    }
    displayNameError = null;
    setState(() {});

    if (items.isEmpty) {
      snack("Add Items");
      return;
    }

    Map map = Map();
    map[NAME] = name;
    map[DISPLAY_NAME] = displayName;
    map[ITEMS] = items;
    map[MULTIPLE] = multiSelection;

    if (item != null) {
      Navigator.pop(context, map);
    }

    List options = appSettingsModel.getList(OPTIONS);
    for (Map item in options) {
      if (item[NAME] == name) {
        snack("SubCategory Already Exists");
        return;
      }
    }

    options.add(map);
    appSettingsModel.put(OPTIONS, options);
    appSettingsModel.updateItems();
    Navigator.pop(context, map);
  }

  snack(String text) {
    Future.delayed(Duration(milliseconds: 100), () {
      showSnack(
        _scaffoldKey,
        text,
      );
    });
  }

  String errorText = "";
  showError(String text) {
    errorText = text;
    setState(() {});
    Future.delayed(Duration(seconds: 1), () {
      errorText = "";
      setState(() {});
    });
  }
}
