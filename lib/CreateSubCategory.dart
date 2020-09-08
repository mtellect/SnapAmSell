import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/ChooseOptions.dart';
import 'package:maugost_apps/assets.dart';

//import 'package:maugost_apps/photo_picker/photo.dart';

class CreateSubCategory extends StatefulWidget {
  int type;
  Map item;
  CreateSubCategory(this.type, {this.item});
  @override
  _CreateSubCategoryState createState() => _CreateSubCategoryState();
}

class _CreateSubCategoryState extends State<CreateSubCategory> {
  final String progressId = getRandomId();

  TextEditingController nameController = new TextEditingController();
  String nameError;
  List options = [];

  int clickBack = 0;
  Map item = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    item = widget.item;
    if (widget.item != null) {
      nameController.text = item[NAME];
      options = item[OPTIONS];
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  BuildContext context;
  @override
  Widget build(BuildContext c) {
    context = c;
    return WillPopScope(
        onWillPop: () async {
          int now = DateTime.now().millisecondsSinceEpoch;
          if ((now - clickBack) > 5000) {
            clickBack = now;
            toastInAndroid("Click back again to exit");
            return false;
          }
          return true;
        },
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            key: _scaffoldKey,
            backgroundColor: white,
            body: page()));
  }

  BuildContext con;

  Builder page() {
    return Builder(builder: (context) {
      this.con = context;
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
                    "Sub Category",
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
                      widget.item != null ? "UPDATE" : "ADD",
                      style: textStyle(true, 14, white),
                    )),
                addSpaceWidth(15)
              ],
            ),
          ),
          //addLine(1, black.withOpacity(.2), 0, 5, 0, 0),
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
                            addSpace(10),
                            inputTextView(
                              "Sub Category Name",
                              nameController,
                              isNum: false,
                              errorText: nameError,
                              onEditted: () {
                                nameError = null;
                                setState(() {});
                              },
                            ),
                            if (options.isNotEmpty)
                              Container(
                                height: 50,
                                width: double.infinity,
                                margin: EdgeInsets.only(bottom: 10),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
//                                controller: downScrollController,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children:
                                        List.generate(options.length, (index) {
                                      String text = options[index];
                                      return Card(
                                        clipBehavior: Clip.antiAlias,
                                        elevation: 0,
                                        margin:
                                            EdgeInsets.fromLTRB(10, 0, 0, 0),
                                        shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                color: black.withOpacity(.1),
                                                width: 2),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(25))),
                                        color: white,
                                        child: Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(10, 5, 10, 5),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                text,
                                                style:
                                                    textStyle(false, 16, black),
                                                textAlign: TextAlign.center,
                                              ),
                                              addSpaceWidth(10),
                                              GestureDetector(
                                                  onTap: () {
                                                    options.remove(text);
                                                    setState(() {});
                                                  },
                                                  child: Icon(
                                                    Icons.cancel,
                                                    size: 20,
                                                    color: red0,
                                                  ))
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                            GestureDetector(
                              onTap: () {
                                pushAndResult(context, ChooseOptions(options),
                                    result: (_) {
                                  setState(() {
                                    options = _;
                                  });
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
                                          "Add Options",
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
    });
  }

  void post() {
    String name = nameController.text.trim();

    if (name.isEmpty) {
      nameError = "Enter Sub Category Name";
      setState(() {});
      return;
    }
    nameError = null;
    setState(() {});

    //Map map = Map();
    item[NAME] = name;
    item[OPTIONS] = options;
    //map[TYPE] = widget.type;

    Navigator.pop(context, item);
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  snack(String text) {
    Future.delayed(Duration(milliseconds: 100), () {
      showSnack(
        _scaffoldKey,
        text,
      );
    });
  }
}
