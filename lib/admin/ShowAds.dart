import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/assets.dart';
import 'package:maugost_apps/basemodel.dart';
import 'package:maugost_apps/dialogs/inputDialog.dart';

class ShowAds extends StatefulWidget {
  final List<BaseModel> ads;
  final String title;

  const ShowAds({Key key, this.ads, this.title}) : super(key: key);
  @override
  _ShowAdsState createState() => _ShowAdsState();
}

class _ShowAdsState extends State<ShowAds> {
  TextEditingController searchController = TextEditingController();
  bool _showCancel = false;
  FocusNode focusSearch = FocusNode();
  List adsList = [];

  reload() async {
    adsList.clear();
    String search = searchController.text.toString().toLowerCase().trim();
    for (BaseModel model in widget.ads) {
      String contactName = model.getString(NAME).toLowerCase().trim();
      String number = model.getString(PHONE_NUMBER).toLowerCase().trim();
      if (search.isNotEmpty) {
        if (!contactName.contains(search)) {
          if (!number.contains(search)) continue;
        }
      }
      adsList.add(model);
    }

    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: white,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(0, 40, 0, 10),
            color: white,
            child: Row(
              children: <Widget>[
                InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 50,
                      height: 30,
                      child: Center(
                          child: Icon(
                        Icons.arrow_back_ios,
                        color: black,
                        size: 20,
                      )),
                    )),
                Flexible(
                    child: GestureDetector(
                  onTap: () {},
                  child: Center(
                      child: Text(
                          "${widget.title ?? "Users"} ${adsList.length}",
                          style: textStyle(true, 20, black))),
                )),
                addSpaceWidth(10),
                new Container(
                  height: 30,
                  width: 50,
                  child: new FlatButton(
                      padding: EdgeInsets.all(0),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onPressed: () {},
                      child: Center(
                          child: Icon(
                        Icons.more_vert,
                        color: black,
                      ))),
                ),
              ],
            ),
          ),
//          Container(
//            height: 45,
//            margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
//            decoration: BoxDecoration(
//                color: white,
//                borderRadius: BorderRadius.circular(25),
//                border: Border.all(color: black.withOpacity(0.2), width: 1)),
//            child: Row(
//              mainAxisSize: MainAxisSize.max,
//              crossAxisAlignment: CrossAxisAlignment.center,
//              //mainAxisAlignment: MainAxisAlignment.center,
//              children: <Widget>[
//                addSpaceWidth(10),
//                Icon(
//                  Icons.search,
//                  color: black.withOpacity(.5),
//                  size: 17,
//                ),
//                addSpaceWidth(10),
//                new Flexible(
//                  flex: 1,
//                  child: new TextField(
//                    textInputAction: TextInputAction.search,
//                    textCapitalization: TextCapitalization.sentences,
//                    autofocus: false,
//                    onSubmitted: (_) {
//                      //reload();
//                    },
//                    decoration: InputDecoration(
//                        hintText: "Search by name",
//                        hintStyle: textStyle(
//                          false,
//                          18,
//                          black.withOpacity(.5),
//                        ),
//                        border: InputBorder.none,
//                        isDense: true),
//                    style: textStyle(false, 16, black),
//                    controller: searchController,
//                    cursorColor: black,
//                    cursorWidth: 1,
//                    focusNode: focusSearch,
//                    keyboardType: TextInputType.text,
//                    onChanged: (s) {
//                      _showCancel = s.trim().isNotEmpty;
//                      setState(() {});
//                      reload();
//                    },
//                  ),
//                ),
//                GestureDetector(
//                  onTap: () {
//                    setState(() {
//                      focusSearch.unfocus();
//                      _showCancel = false;
//                      searchController.text = "";
//                    });
//                    reload();
//                  },
//                  child: _showCancel
//                      ? Padding(
//                          padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
//                          child: Icon(
//                            Icons.close,
//                            color: black,
//                            size: 20,
//                          ),
//                        )
//                      : new Container(),
//                )
//              ],
//            ),
//          ),
          Expanded(
              flex: 1,
              child: Builder(builder: (ctx) {
                //if (!contactSetup) return loadingLayout();
                if (adsList.isEmpty)
                  return emptyLayout(Icons.trending_flat, "No Ads Yet", "");

                return Container(
                    child: ListView.builder(
                  itemBuilder: (c, p) {
                    return adsItem(p);
                  },
                  shrinkWrap: true,
                  itemCount: adsList.length,
                  padding: EdgeInsets.only(top: 10, right: 5, left: 5),
                ));
              }))
        ],
      ),
    );
  }

  adsItem(int p) {
    BaseModel model = adsList[p];
    String imageUrl = model.getString(ADS_IMAGE);
    String title = model.getString(TITLE);
    String url = model.getString(ADS_URL);
    final seenBy = model.getList(SEEN_BY);
    int status = model.getInt(STATUS);
    String userImage = model.getString(USER_IMAGE);
    bool live = status == APPROVED;

    String statusMsg = status == APPROVED
        ? "Approved"
        : status == PENDING
            ? "Pending Approval"
            : status == REJECTED ? "Rejected" : "Inactive";
    return Container(
      decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: black.withOpacity(.09))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  width: 60,
                  height: 60,
                  child: Card(
                    color: black.withOpacity(.1),
                    elevation: 0,
                    clipBehavior: Clip.antiAlias,
                    shape: CircleBorder(
                        side: BorderSide(
                            color: black.withOpacity(.2), width: .9)),
                    child: CachedNetworkImage(
                      imageUrl: userImage,
                      fit: BoxFit.cover,
                      placeholder: (c, s) {
                        return Container(
                          width: 60,
                          height: 60,
                          child: Center(
                            child: Icon(Icons.account_circle),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                addSpaceWidth(10),
                Flexible(
                  fit: FlexFit.tight,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textStyle(true, 16, black),
                      ),
                      addSpace(5),
                      Text.rich(TextSpan(children: [
                        TextSpan(text: "Status "),
                        TextSpan(
                            text: "$statusMsg ",
                            style: textStyle(true, 14, black))
                      ])),
                      addSpace(5),
                      Text.rich(TextSpan(children: [
                        TextSpan(text: "Views "),
                        TextSpan(
                            text: "${seenBy.length} ",
                            style: textStyle(true, 14, black))
                      ]))
                    ],
                  ),
                ),
                Column(
                  children: [
                    FlatButton(
                      onPressed: () {
                        model
                          ..put(STATUS, APPROVED)
                          ..updateItems();
                        setState(() {});
                      },
                      padding: EdgeInsets.all(8),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      color: green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check,
                            color: white,
                            size: 14,
                          ),
                          addSpaceWidth(5),
                          Text(
                            "APPROVE",
                            style: textStyle(true, 13, white),
                          ),
                        ],
                      ),
                    ),
                    addSpace(5),
                    FlatButton(
                      onPressed: () {
                        pushAndResult(
                            context,
                            inputDialog(
                              "Reason",
                              hint: "Enter reason of rejection",
                            ), result: (_) {
                          if (null == _) return;
                          model
                            ..put(STATUS, REJECTED)
                            ..put(REJECTED_MESSAGE, _)
                            ..updateItems();
                          setState(() {});
                        }, depend: false);
                      },
                      padding: EdgeInsets.all(8),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      color: live ? blue6 : red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.block,
                            color: white,
                            size: 14,
                          ),
                          addSpaceWidth(5),
                          Text(
                            "DECLINE",
                            style: textStyle(true, 13, white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
