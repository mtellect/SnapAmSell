import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/assets.dart';
import 'package:maugost_apps/basemodel.dart';

class ReportMain extends StatefulWidget {
  @override
  _ReportMainState createState() => _ReportMainState();
}

class _ReportMainState extends State<ReportMain> with TickerProviderStateMixin {
  List<BaseModel> reportItems = List();
  bool setup = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadReports();
  }

  loadReports() {
    Firestore.instance
        .collection(REPORT_BASE)
        .where(STATUS, isEqualTo: STATUS_UNDONE)
        .orderBy(TIME, descending: false)
        .getDocuments()
        .then((shots) {
      for (DocumentSnapshot d in shots.documents) {
        BaseModel model = BaseModel(doc: d);
        int p = reportItems
            .indexWhere((bm) => (bm.getObjectId() == model.getObjectId()));
        if (p == -1) reportItems.add(model);
      }
      setup = true;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: white,
      body: page(),
    );
  }

  BuildContext con;

  Builder page() {
    return Builder(builder: (context) {
      this.con = context;
      return new Column(
        mainAxisSize: MainAxisSize.max,
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
                    !setup
                        ? "Reports"
                        : reportItems.isEmpty
                            ? "No Reports Yet"
                            : "${reportItems.length} Report${reportItems.length > 1 ? "s" : ""}",
                    style: textStyle(true, 17, red0),
                  ),
                ),
                addSpaceWidth(15),
              ],
            ),
          ),
          addLine(1, black.withOpacity(.1), 0, 0, 0, 0),
          new Expanded(
            flex: 1,
            child: !setup
                ? loadingLayout()
                : setup && reportItems.isEmpty
                    ? emptyLayout(
                        Icons.report,
                        "No Reports Yet!",
                        "",
                      )
                    : Scrollbar(
                        child: new ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.all(0),
                          itemBuilder: (c, p) {
                            return reportItem(reportItems[p]);
                          },
                          itemCount: reportItems.length,
                        ),
                      ),
          ),
        ],
      );
    });
  }

  reportItem(BaseModel m) {
    int type = m.getInt(REPORT_TYPE);
    Map map = m.getMap(THE_MODEL);
    BaseModel bm = BaseModel(items: map);
    bool disabled =
        appSettingsModel.getList(DISABLED).contains((bm.getObjectId()));
    bool banned = appSettingsModel.getList(BANNED).contains((bm.getObjectId()));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        type == REPORT_TYPE_PROFILE
            ? Opacity(
                opacity: disabled ? (.8) : banned ? (.3) : (1),
                child: GestureDetector(
                  onTap: () {
                    // pushAndResult(context, MyProfile1(BaseModel(items: map),));
                  },
                  onLongPress: () {
                    showListDialog(context, [
                      "Mark Completed",
                      "Show My Accounts",
                      disabled ? "Enable" : "Disable",
                      banned ? "Unban" : "Ban"
                    ], (int p) {
                      if (p == 0) {
                        showMessage(context, Icons.check, blue0, "Mark Report?",
                            "Are you sure you have handled this report?",
                            clickYesText: "YES",
                            cancellable: true,
                            clickNoText: "Cancel", onClicked: (_) {
                          if (_ == true) {
                            m.put(STATUS, STATUS_COMPLETED);
                            m.updateItems();
                            reportItems.removeWhere(
                                (bm) => bm.getObjectId() == m.getObjectId());
                            setState(() {});
                          }
                        });
                      }
                      if (p == 1) {
//                  pushAndResult(context, ShowAllfromIds(bm.getString(DEVICE_ID)));
                      }
                      if (p == 2) {
                        yesNoDialog(
                            context,
                            "${disabled ? "Enable" : "Disable"} Account?",
                            "Are you sure?", () {
                          appSettingsModel.putInList(
                              DISABLED, bm.getObjectId(), !disabled);
                          appSettingsModel.updateItems();
                          setState(() {});
                        });
                      }
                      if (p == 3) {
                        yesNoDialog(
                            context,
                            "${banned ? "Unban" : "Ban"} Account?",
                            "Are you sure?", () {
                          appSettingsModel.putInList(
                              BANNED, bm.getObjectId(), !banned);
                          appSettingsModel.updateItems();
                          setState(() {});
                        });
                      }
                    });
                  },
                  child: Container(
                    height: 200,
                    child: Card(
                      color: default_white,
                      elevation: 0,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          side: BorderSide(
                              color: black.withOpacity(.1), width: .5)),
                      child: Stack(fit: StackFit.expand, children: <Widget>[
                        CachedNetworkImage(
                          imageUrl: bm.getString(USER_IMAGE),
                          fit: BoxFit.cover,
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: gradientLine(
                              height: 120, alpha: .8, reverse: false),
                        ),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  getFullName(bm),
                                  style: textStyle(
                                    false,
                                    20,
                                    white,
                                  ),
                                  maxLines: 2,
                                ),
//                          Text(
//                            bm.getString(CITY),
//                            style: textStyle(false, 12, white.withOpacity(.5),),maxLines: 1,overflow: TextOverflow.ellipsis,
//                          ),
                                Text(
                                  bm.isMale() ? "Male" : "Female",
                                  style: textStyle(
                                    true,
                                    12,
                                    white.withOpacity(.5),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
              )
            : Container(),
        addSpace(10),
        commentItem(context, m, List(), () {}, () {}, true, isReport: true),
        addLine(2, black.withOpacity(.1), 10, 10, 10, 10)
      ],
    );
  }
}
