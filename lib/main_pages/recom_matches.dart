import 'package:Strokes/AppEngine.dart';
import 'package:Strokes/MainAdmin.dart';
import 'package:Strokes/assets.dart';
import 'package:Strokes/basemodel.dart';
import 'package:Strokes/payment_subscription.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'recommended_matches.dart';
import 'super_likes.dart';

class RecommMatches extends StatefulWidget {
  @override
  _RecommMatchesState createState() => _RecommMatchesState();
}

class _RecommMatchesState extends State<RecommMatches> {
  bool setup = false;
  List<BaseModel> peopleList = [];
  //List myMatches = matches;

  final pc = PageController();
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    //loadViews(0);
    loadViews(1);
  }

  loadViews(int p) async {
    bool myMatch = p == 0;
    List seenPeople = userModel.getList(myMatch ? MY_MATCHES : SUPER_LIKE_LIST);
    for (String id in seenPeople) {
      Firestore.instance.collection(USER_BASE).document(id).get().then((value) {
        BaseModel model = BaseModel(doc: value);
        if (!model.signUpCompleted) return;

        int index = peopleList
            .indexWhere((bm) => bm.getObjectId() == model.getObjectId());
        if (index == -1) {
          (myMatch ? matches : peopleList).add(model);
        } else {
          (myMatch ? matches : peopleList)[index] = model;
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
    return Scaffold(
      backgroundColor: default_white,
      body: page(),
    );
  }

  page() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(0, 40, 0, 10),
          color: white,
          child: Column(
            children: [
              Row(
                children: [
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
                    child: Container(
                      //height: 50,
//                  width: 270,
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
                                p == 0 ? "Recommended" : "Super Likes";
                            bool selected = p == currentPage;
                            return Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  if (p == 1 && !userModel.isPremium) {
                                    showMessage(
                                        context,
                                        Icons.error,
                                        red0,
                                        "Opps Sorry!",
                                        "You cannot view persons who SuperLiked your profile until you become a Premium User",
                                        textSize: 14,
                                        clickYesText: "Subscribe",
                                        onClicked: (_) {
                                      if (_) {
                                        pushAndResult(
                                            context, PaymentSubscription(),
                                            depend: false);
                                      }
                                    }, clickNoText: "Cancel");

                                    return;
                                  }

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
                  if (p == 1 && !userModel.isPremium) {
                    showMessage(context, Icons.error, red0, "Opps Sorry!",
                        "You cannot view persons who SuperLiked your profile until you become a Premium User",
                        textSize: 14,
                        clickYesText: "Subscribe", onClicked: (_) {
                      if (_) {
                        pushAndResult(context, PaymentSubscription(),
                            depend: false);
                      }
                    }, clickNoText: "Cancel");

                    return;
                  }

                  setState(() {
                    currentPage = p;
                  });
                },
                physics:
                    userModel.isPremium ? null : NeverScrollableScrollPhysics(),
                itemBuilder: (c, p) {
                  if (p == 0) return RecommendedMatches();
                  return SuperLikes();
                }))
      ],
    );
  }
}
