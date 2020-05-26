import 'package:Strokes/AppEngine.dart';
import 'package:Strokes/MainAdmin.dart';
import 'package:Strokes/assets.dart';
import 'package:Strokes/basemodel.dart';
import 'package:Strokes/main_pages/MyMatch.dart';
import 'package:Strokes/main_pages/PeopleViewed.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'show_profile.dart';

class Matches extends StatefulWidget {
  final bool showBar;
  final bool fromHome;

  const Matches({Key key, this.showBar = true, this.fromHome = false})
      : super(key: key);
  @override
  _MatchesState createState() => _MatchesState();
}

class _MatchesState extends State<Matches> {
  bool setup = false;
  List<BaseModel> peopleList = [];
  List<BaseModel> myMatches = [];

  final pc = PageController();
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    loadViews(0);
    loadViews(1);
  }

  loadViews(int p) async {
    bool myMatch = p == 0;
    List seenPeople = userModel.getList(myMatch ? MY_MATCHES : SEEN_PEOPLE);
    for (String id in seenPeople) {
      Firestore.instance.collection(USER_BASE).document(id).get().then((value) {
        BaseModel model = BaseModel(doc: value);
        if (!model.signUpCompleted) return;
        int index = peopleList
            .indexWhere((bm) => bm.getObjectId() == model.getObjectId());
        if (index == -1) {
          (myMatch ? myMatches : peopleList).add(model);
        } else {
          (myMatch ? myMatches : peopleList)[index] = model;
        }
        if (mounted)
          setState(() {
            setup = true;
          });
      });
    }
    if (mounted)
      setState(() {
        setup = true;
      });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        overlayController.add(false);
        Navigator.pop(context, "");
        return false;
      },
      child: Scaffold(
        backgroundColor: default_white,
        body: page(),
      ),
    );
  }

  page() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(0, widget.showBar ? 40 : 0, 0, 10),
          color: white,
          child: Column(
            children: [
              //if (widget.fromHome) addSpace(40),
              // addSpace(10),
              Row(
                children: [
                  InkWell(
                      onTap: () {
                        overlayController.add(true);
                        Navigator.pop(context, "");
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
                    child: Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 50, 0),
                      child: Card(
                        color: black.withOpacity(0.2),
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(25))),
                        child: Row(
                          children: List.generate(2, (p) {
                            String title =
                                p == 0 ? "My Matches" : "People I Viewed";
                            bool selected = p == currentPage;
                            return Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  pc.animateToPage(p,
                                      duration: Duration(milliseconds: 500),
                                      curve: Curves.ease);
                                },
                                child: Container(
                                    margin: EdgeInsets.all(4),
                                    height: 30,
                                    decoration: !selected
                                        ? null
                                        : BoxDecoration(
                                            color:
                                                selected ? white : transparent,
//                      border: Border.all(color: black.withOpacity(.1),width: 3),
                                            borderRadius:
                                                BorderRadius.circular(25)),
                                    child: Center(
                                        child: Text(
                                      title,
                                      style: textStyle(
                                          true,
                                          14,
                                          selected
                                              ? black
                                              : (white.withOpacity(.7))),
                                      textAlign: TextAlign.center,
                                    ))),
                              ),
                              fit: FlexFit.tight,
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              /* Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(2, (p) {
                    bool active = currentPage == p;
                    return Flexible(
                        child: GestureDetector(
                      onTap: () {
                        pc.jumpToPage(p);
                      },
                      child: Container(
                          alignment: Alignment.center,
                          width: getScreenWidth(context) / 2,
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: AppConfig.appColor
                                  .withOpacity(active ? 1 : 0.2),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                  color:
                                      black.withOpacity(active ? 0.1 : 0.5))),
                          child: Text(p == 0 ? "My Matches" : "People I Viewed",
                              style: textStyle(active, 17,
                                  active ? white : black.withOpacity(.7)))),
                    ));
                  }))*/
            ],
          ),
        ),
        Expanded(
            flex: 1,
            child: PageView.builder(
                controller: pc,
                itemCount: 2,
                onPageChanged: (p) {
                  setState(() {
                    currentPage = p;
                  });
                },
//                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (c, p) {
                  if (p == 0) return MyMatch();
                  if (p == 1) return PeopleViewed();

                  return Builder(builder: (ctx) {
                    bool myMatch = currentPage == 0;

                    if (!matchSetup) return loadingLayout();
                    if ((myMatch ? myMatches : peopleList).isEmpty)
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Image.asset(
                                "assets/icons/views.png",
                                width: 50,
                                height: 50,
                                color: white,
                              ),
                              Text(
                                myMatch ? "No Match Yet" : "No Views Yet",
                                style: textStyle(true, 20, black),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );

                    return Container(
                        child: GridView.builder(
                      itemBuilder: (c, p) {
                        return personItem(p);
                      },
                      shrinkWrap: true,
                      itemCount: matches.length,
                      padding: EdgeInsets.only(top: 10, right: 0, left: 0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.78,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5),
                    ));
                  });
                }))
      ],
    );
  }

  personItem(int p) {
    bool myMatch = currentPage == 0;

    BaseModel model = (myMatch ? myMatches : peopleList)[p];
    return GestureDetector(
      onTap: () {
        pushAndResult(
            context,
            ShowProfile(
              theUser: model,
              //fromMeetMe: widget.fromStrock,
            ));
      },
      child: Card(
        color: white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                imageUrl: model.profilePhotos[0].imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 100,
                placeholder: (c, s) {
                  return Container(
                      height: double.infinity,
                      width: double.infinity,
                      child: Center(
                          child: Icon(
                        Icons.person,
                        color: white,
                        size: 15,
                      )),
                      decoration: BoxDecoration(
                          color: black.withOpacity(.09),
                          shape: BoxShape.circle));
                },
              ),
            ),
            Container(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(
                        getFirstName(model),
                        style: textStyle(true, 14, black),
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    addSpaceWidth(5),
                    isOnline(model)
                        ? Container(
                            height: 8,
                            width: 8,
                            decoration: BoxDecoration(
                                color: green, shape: BoxShape.circle),
                          )
                        : Text(
                            getMyAge(model).toString(),
                            style: textStyle(false, 11, black.withOpacity(.5)),
                          ),
                    /*addSpace(5),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 8,
                          width: 8,
                          decoration: BoxDecoration(
                              color: green, shape: BoxShape.circle),
                        ),
                        addSpaceWidth(10),
                        Text(
                          "Active Now",
                          style: textStyle(false, 16, black.withOpacity(.7)),
                        ),
                      ],
                    ),*/
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
