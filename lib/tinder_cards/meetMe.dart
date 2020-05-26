import 'dart:async';

import 'package:Strokes/AppEngine.dart';
import 'package:Strokes/MainAdmin.dart';
import 'package:Strokes/app_config.dart';
import 'package:Strokes/assets.dart';
import 'package:Strokes/basemodel.dart';
import 'package:Strokes/its_a_match.dart';
import 'package:Strokes/main_pages/matches.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'card_stack.dart';
import 'matches.dart';
import 'profiles.dart';
import 'round_icon_button.dart';

// final MatchEngine getMatchEngine() = new MatchEngine(
//   matches: demoProfile.map((Profile profile) {
//     return new DateMatch(profile: profile);
//   }).toList(),
// );

class MeetMe extends StatefulWidget {
  @override
  _MeetMeState createState() => _MeetMeState();
}

class _MeetMeState extends State<MeetMe>
    with AutomaticKeepAliveClientMixin<MeetMe> {
  List<Profile> demoProfiles;
  Profile previousProfile;
  bool setup = false;
  List otherPeople = [];
  List<MatchEngine> matchEngines = [];
  bool showOverlay = true;
  List<StreamSubscription> subs = List();

  @override
  initState() {
    super.initState();
    var overlaySub = overlayController.stream.listen((b) {
      setState(() {
        showOverlay = b;
      });
      //print("Showoverlay $b");
    });
    subs.add(overlaySub);
    loadOtherPeople();
  }

  @override
  void dispose() {
    for (var s in subs) s?.cancel();
    super.dispose();
  }

  loadOtherPeople() async {
    QuerySnapshot shots = await Firestore.instance
        .collection(USER_BASE)
        .where(GENDER, isEqualTo: userModel.getInt(PREFERENCE))
        .getDocuments();

    for (DocumentSnapshot doc in shots.documents) {
      BaseModel model = BaseModel(doc: doc);
      if (model.myItem()) continue;
      if (!model.signUpCompleted) continue;
      if (model.getList(MATCHED_LIST).contains(userModel.getUserId())) continue;
      int index = hookupList
          .indexWhere((bm) => bm.getObjectId() == model.getObjectId());
      if (index == -1) {
        otherPeople.add(model);
      } else {
        otherPeople.add(model);
      }
    }

    otherPeople.shuffle();
    List allItems = [];
    allItems.addAll(List.from(otherPeople));
    //allItems.addAll(List.from(hookupList));
    demoProfiles = allItems
        .map((e) => Profile(
            objectId: e.getObjectId(),
            age: getAge(DateTime.parse(e.getString(BIRTH_DATE))),
            name: e.getString(NAME),
            user: e,
            isAds: false,
            photos: List<String>.from(
                e.profilePhotos.map((e) => e.imageUrl).toList()),
            bio: e.getString(ABOUT_ME),
            location: e.getString(MY_LOCATION)))
        .toList();

    MatchEngine matchEngine = new MatchEngine(
      matches: demoProfiles.map((Profile profile) {
        return new DateMatch(profile: profile);
      }).toList(),
    );
    matchEngines.add(matchEngine);

    setup = true;
    if (mounted) setState(() {});

    injectAds();
  }

  getMatchEngine() {
    return matchEngines[matchEngines.length - 1];
  }

  injectAds() {
    int myPlan = userModel.getInt(ACCOUNT_TYPE);
    String key = myPlan == 0 ? FEATURES_REGULAR : FEATURES_PREMIUM;
    BaseModel package = appSettingsModel.getModel(key);
    int adsSpacing = package.getInt(ADS_SPACING);
    adsList.shuffle();

    print("Inject Ads at $adsSpacing");
    List<Profile> newList = [];
    for (int p = 0; p < demoProfiles.length; p++) {
      //if (!adsSetup) continue;
      //if (adsList.isEmpty) continue;
      if (p % adsSpacing != 0) {
        final ads = getAdsAt(p, adsSpacing);
        print("ads.... $ads");
        if (null == ads) continue;
        print("Ads injected @ $p");
        Profile adsProfile = Profile(
            objectId: ads.getObjectId(),
            isAds: true,
            photos: [ads.getString(ADS_IMAGE)],
            name: ads.getString(TITLE),
            urlLink: ads.getString(ADS_URL),
            user: ads);
        newList.add(adsProfile);
      }
      newList.add(demoProfiles[p]);
    }
    demoProfiles.clear();
    demoProfiles.addAll(newList);

    MatchEngine matchEngine = new MatchEngine(
      matches: demoProfiles.map((Profile profile) {
        return new DateMatch(profile: profile);
      }).toList(),
    );
    matchEngines[matchEngines.length - 1] = matchEngine;
    //getMatchEngine().addListener(() {});

    //setup = true;
    if (mounted) setState(() {});
  }

  BaseModel getAdsAt(int p, int adsSpacing) {
    if (adsList.isEmpty) return null;
    int index = p ~/ adsSpacing;
    index = index - 1;

    if (index < 0) return null;
    if (index > adsList.length - 1) {
      BaseModel model = findAds(true);
      if (model == null) model = findAds(false);
      if (model == null) return null;
    }

    if (index > adsList.length - 1) return null;

    BaseModel ad = adsList[index];
    if (ad.getInt(STATUS) != APPROVED) return null;
    List<String> myHiddenPosts = List.from(userModel.getList(HIDDEN));
    if (myHiddenPosts.contains(ad.getObjectId())) return null;
    adsList.shuffle();
    return ad;
  }

  final List loadedAds = [];

  BaseModel findAds(bool skipShown) {
    BaseModel model;
    for (BaseModel bm in adsList) {
      if (loadedAds.contains(bm.getObjectId())) continue;
      if (skipShown && bm.getList(SEEN_BY).contains(userModel.getUserId()))
        continue;
      //partnersList.add(bm);
      loadedAds.add(bm.getObjectId());
      model = bm;
      break;
    }
    adsList.shuffle();
    return model;
  }

  previousMatch() async {
    print("previousProfile ${previousProfile?.name}");
    if (null == previousProfile) return;
    demoProfiles.removeWhere((e) => e.objectId == previousProfile.objectId);
//    demoProfiles.insert(0,getMatchEngine().currentMatch.profile);
    demoProfiles.insert(0, previousProfile);
//    getMatchEngine().dispose();
    setup = false;
    setState(() {});

    Future.delayed(Duration(milliseconds: 500), () {
      previousProfile = null;
      MatchEngine matchEngine = new MatchEngine(
        matches: demoProfiles.map((Profile profile) {
          return new DateMatch(profile: profile);
        }).toList(),
      );
      matchEngines.add(matchEngine);
      setup = true;
      setState(() {});
    });
  }

  removeMatch(BaseModel model) {
    return;
    demoProfiles.removeWhere((e) {
      print(e.objectId == null);
      return e.objectId == model.getObjectId();
    });
    setState(() {});
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      color: Colors.transparent,
      elevation: 0.0,
      child: new Padding(
        padding: const EdgeInsets.all(16.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            RoundIconButton.small(
              icon: Icons.settings_backup_restore,
              iconColor: Colors.orange,
              onPressed: () {
                if (previousProfile == null) return;
                previousMatch();
              },
            ),
            new RoundIconButton.large(
              icon: Icons.clear,
              iconColor: Colors.red,
              size: 65,
              onPressed: () {
                setState(() {
                  previousProfile = getMatchEngine().currentMatch.profile;
                  if (previousProfile.isAds) previousProfile = null;
                });
                getMatchEngine().currentMatch.nope();
              },
            ),
            new RoundIconButton.large(
              icon: Icons.favorite,
              iconColor: Colors.green,
              size: 65,
              onPressed: () {
                setState(() {
                  previousProfile = null;
                });
                handleMatch(getMatchEngine().currentMatch.profile.user,
                    isAds: getMatchEngine().currentMatch.profile.isAds);
                if (getMatchEngine().currentMatch.profile.isAds)
                  handleAds(getMatchEngine().currentMatch.profile.user, 1);

                getMatchEngine().currentMatch.like();
              },
            ),
            new RoundIconButton.small(
              icon: Icons.star,
              iconColor: Colors.blue,
              onPressed: () {
                setState(() {
                  previousProfile = null;
                });
                if (getMatchEngine().currentMatch.profile.isAds)
                  handleAds(getMatchEngine().currentMatch.profile.user, 2);

                getMatchEngine().currentMatch.superLike();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return WillPopScope(
      onWillPop: () async {
        Future.delayed(Duration(milliseconds: 20), () {
          Navigator.of(context).pop();
        });
        return false;
      },
      child: Scaffold(
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(0, 40, 0, 10),
              color: white,
              child: Row(
                children: <Widget>[
                  InkWell(
                      onTap: () {
                        overlayController.add(false);
                        Future.delayed(Duration(milliseconds: 20), () {
                          Navigator.of(context).pop();
                        });
                      },
                      child: Container(
                        width: 50,
                        height: 30,
                        child: Center(
                            child: Icon(
                          Icons.keyboard_backspace,
                          color: black,
                          size: 20,
                        )),
                      )),
                  GestureDetector(
                    onTap: () {},
                    child: Center(
                        child: Text(
                      "Meet Me",
                      //style: textStyle(true, 20, black)
                      style: textStyle(true, 25, black),
                    )),
                  ),
                  addSpaceWidth(10),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      overlayController.add(false);
                      pushAndResult(
                          context,
                          Matches(
                            fromHome: true,
                          ),
                          depend: false, result: (_) {
                        overlayController.add(true);
                      });
                    },
                    child: Container(
                      height: 30,
                      width: 50,
                      color: transparent,
                      child: Stack(
                        children: [
                          new Container(
                              padding: EdgeInsets.all(5),
//                          materialTapTargetSize:  MaterialTapTargetSize.shrinkWrap,

                              child: Center(
                                  child: Icon(
                                Icons.favorite,
                                size: 30,
                                color: red,
                              ))),
                          if (userModel.getList(MATCHED_LIST).isNotEmpty)
                            Container(
                                decoration: BoxDecoration(
                                    color: AppConfig.appColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: white, width: 2)),
                                padding: EdgeInsets.all(6),
                                child: Text(
                                  userModel
                                      .getList(MATCHED_LIST)
                                      .length
                                      .toString(),
                                  style: textStyle(false, 12, black),
                                ))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
                child: !setup
                    ? loadingLayout()
                    : Builder(builder: (ctx) {
                        if (!strockSetup) return loadingLayout();
                        if (otherPeople.isEmpty)
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Image.asset(
                                    "assets/icons/gender.png",
                                    width: 50,
                                    height: 50,
                                    color: white,
                                  ),
                                  Text(
                                    "No Views Yet",
                                    style: textStyle(true, 20, black),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );

                        return new CardStack(
                          matchEngine: getMatchEngine(),
                          showOverlay: showOverlay,
                          callback: (currentMatch, direction) {
                            final match = currentMatch.profile;
                            bool isAds = match.isAds;

                            print(match.user.getString(NAME));
                            BaseModel user = match.user;
                            String id = match.objectId;

                            if (isAds) handleAds(user, direction);

                            if (direction != 0) {
                              previousProfile = null;
                              if (direction == 1) {
                                handleMatch(user, isAds: isAds);
                              }
                              String key =
                                  direction == 1 ? LIKE_LIST : SUPER_LIKE_LIST;
                              List list = userModel.getList(key);
                              if (!list.contains(id)) {
                                list.add(id);
                                userModel.put(key, list);
                              }
                            } else {
                              previousProfile = match;
                            }
                            List viewedList = userModel.getList(VIEWED_LIST);
                            if (!viewedList.contains(id)) {
                              viewedList.add(id);
                              userModel.put(VIEWED_LIST, viewedList);
                            }
                            userModel.updateItems();
                            setState(() {});
                          },
                        );
                      })),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  handleAds(BaseModel user, int p) {
    String key = p == 0 ? VIEWED_LIST : p == 1 ? LIKE_LIST : SUPER_LIKE_LIST;
    user
      ..putInList(key, userModel.getObjectId(), true)
      ..updateItems();
  }

  handleMatch(BaseModel user, {bool isAds = false}) {
    if (isAds) return;
    final likes = user.getList(LIKE_LIST);
    userModel
      ..putInList(LIKE_LIST, user.getObjectId(), true)
      ..putInList(VIEWED_LIST, user.getObjectId(), true)
      ..updateItems();

    if (likes.contains(userModel.getUserId())) {
      user
        ..putInList(MATCHED_LIST, userModel.getUserId(), true)
        ..updateItems();
      userModel
        ..putInList(MATCHED_LIST, user.getUserId(), true)
        ..updateItems();
      overlayController.add(false);
      Future.delayed(Duration(milliseconds: 15), () {
        pushAndResult(
            context,
            ItsAMatch(
              user: user,
            ),
            depend: false);
      });
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
