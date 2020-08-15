import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/assets.dart';
import 'package:maugost_apps/basemodel.dart';

//import 'package:maugost_apps/photo_picker/photo.dart';

class NewUpdate extends StatefulWidget {
  @override
  _NewUpdateState createState() => _NewUpdateState();
}

class _NewUpdateState extends State<NewUpdate> {
  final String progressId = getRandomId();

  TextEditingController codeController = new TextEditingController();
  TextEditingController featuresController = new TextEditingController();

  bool mustUpdate = false;
  int clickBack = 0;
  BaseModel model;
  @override
  void initState() {
    // TODO: implement initState
    codeController.text = appSettingsModel.getInt(VERSION_CODE).toString();
    featuresController.text = appSettingsModel.getString(NEW_FEATURE);
    featuresController.text = featuresController.text.replaceAll("\n*", ",");
    mustUpdate = appSettingsModel.getBoolean(MUST_UPDATE);
    super.initState();
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
        onWillPop: () {
          int now = DateTime.now().millisecondsSinceEpoch;
          if ((now - clickBack) > 5000) {
            clickBack = now;
            toastInAndroid("Click back again to exit");
            return;
          }
          Navigator.pop(context);
        },
        child: Scaffold(
            resizeToAvoidBottomInset: true,
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
                    "Release Update",
                    style: textStyle(true, 17, black),
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
                      "UPDATE",
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
                            Text(
                              "Version Code",
                              style: textStyle(true, 14, blue0),
                            ),
                            addSpace(10),
                            Container(
                              //height: 45,
                              margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                              decoration: BoxDecoration(
                                  color: blue09,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: black.withOpacity(.1), width: .5)),
                              child: new TextField(
                                onSubmitted: (_) {
                                  //post();
                                },
                                textInputAction: TextInputAction.done,

                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 10, 10, 10),
                                    hintText: "",
                                    hintStyle: textStyle(
                                        false, 16, black.withOpacity(.2))),
                                style: textStyle(
                                  false,
                                  16,
                                  black,
                                ),
                                controller: codeController,
                                cursorColor: black,
                                cursorWidth: 1,
//                          maxLength: 50,
                                maxLines: 1,
                                keyboardType: TextInputType.number,
                                scrollPadding: EdgeInsets.all(0),
                              ),
                            ),
                            Text(
                              "New Feature (user comma for new line)",
                              style: textStyle(true, 14, blue0),
                            ),
                            addSpace(10),
                            Container(
                              height: 120,
                              margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                              decoration: BoxDecoration(
                                  color: blue09,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: black.withOpacity(.1), width: .5)),
                              width: double.infinity,
                              child: new TextField(
                                onSubmitted: (_) {
                                  //post();
                                },
                                textInputAction: TextInputAction.newline,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 10, 10, 10),
                                    hintText: "",
                                    hintStyle: textStyle(
                                        false, 16, black.withOpacity(.2))),
                                style: textStyle(false, 16, black),
                                controller: featuresController,
                                cursorColor: black,
                                cursorWidth: 1,
                                //maxLength: 50,
                                maxLines: 100,
                                keyboardType: TextInputType.text,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  mustUpdate = !mustUpdate;
                                });
                              },
                              child: Container(
                                height: 35,
                                margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                decoration: BoxDecoration(
                                    border: Border.all(color: blue0, width: 2),
                                    color: transparent,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Flexible(
                                        flex: 1,
                                        fit: FlexFit.tight,
                                        child: Text(
                                          "MUST UPDATE",
                                          style: textStyle(true, 16, blue0),
                                        )),
                                    addSpaceWidth(10),
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                          color: mustUpdate ? blue0 : blue09,
                                          border: Border.all(
                                              color: blue0, width: 1),
                                          shape: BoxShape.circle),
                                      child: mustUpdate
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
    });
  }

  void post() {
    String code = codeController.text.trim();
    String feature = featuresController.text.trim();
    feature = feature.replaceAll(",", "\n*");

    if (code.isEmpty) {
      toastInAndroid("Add version code");
      return;
    }

    appSettingsModel.put(VERSION_CODE, int.parse(code));
    appSettingsModel.put(NEW_FEATURE, feature);
    appSettingsModel.put(MUST_UPDATE, mustUpdate);
    appSettingsModel.updateItems();

    Navigator.pop(context);
  }
}
