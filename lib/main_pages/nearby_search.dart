import 'package:Strokes/AppEngine.dart';
import 'package:Strokes/FilterDialog.dart';
import 'package:Strokes/app_config.dart';
import 'package:Strokes/assets.dart';
import 'package:Strokes/basemodel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:great_circle_distance2/great_circle_distance2.dart';

import 'Account.dart';
import 'Chat.dart';
import 'matches.dart';
import 'show_profile.dart';

class NearbySearch extends StatefulWidget {
  final bool fromStrock;
  final int currentPage;

  const NearbySearch({Key key, this.fromStrock = false, this.currentPage = 0})
      : super(key: key);
  @override
  _NearbySearchState createState() => _NearbySearchState();
}

class _NearbySearchState extends State<NearbySearch> {
  bool setup = false;
  List peopleList = [];
  BaseModel filterLocation;
  int genderType = -1;
  int onlineType = -1;
  int interestType = -1;
  int minAge = 18;
  int maxAge = 80;

  PageController pc;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    currentPage = widget.currentPage;
    pc = PageController(initialPage: widget.currentPage);

    loadItems();
  }

  var loadingSub;
  loadItems() async {
    if (loadingSub != null) {
      loadingSub.cancel();
      peopleList.clear();
      setup = false;
      setState(() {});
    }
    Geoflutterfire geo = Geoflutterfire();
    Map myPosition = userModel.getMap(POSITION);
    if (myPosition.isEmpty) {
      showMessage(context, Icons.error, red0, "No Location",
          "Sorry we could no find your location",
          onClicked: (_) => Navigator.pop(context));
      return;
    }
    GeoPoint geoPoint = myPosition["geopoint"];
    double lat = geoPoint.latitude;
    double lon = geoPoint.longitude;
    if (filterLocation != null) {
      lat = filterLocation.getDouble(LATITUDE);
      lon = filterLocation.getDouble(LONGITUDE);
    }
    print("Filter Lat/Lon $lat  $lon");
    GeoFirePoint center = geo.point(latitude: lat, longitude: lon);

    // get the collection reference or query
    var collectionReference;
    if (widget.fromStrock) {
      collectionReference = Firestore.instance
          .collection(USER_BASE)
          .where(QUICK_HOOKUP, isEqualTo: 0);
    } else {
      collectionReference = Firestore.instance.collection(USER_BASE);
    }

//    double radius = 100;
    double radius = appSettingsModel.getDouble(NEARBY_RADIUS);
    loadingSub = geo
        .collection(collectionRef: collectionReference)
        .within(center: center, radius: radius, field: POSITION)
        .listen((event) async {
      for (DocumentSnapshot doc in event) {
        BaseModel model = BaseModel(doc: doc);
        if (model.myItem()) continue;
        if (!model.signUpCompleted) continue;
        //if (widget.fromStrock && !model.getBoolean(SHOW_STROCK_PICS)) continue;
        if (genderType != -1) if ((genderType == 0 || genderType == 1) &&
            model.getInt(GENDER) != genderType) continue;
        if (onlineType > 0) {
          if (onlineType == 1) if (!isOnline(model)) continue;
          int now = DateTime.now().millisecondsSinceEpoch;
          if (onlineType == 2) if ((now - (model.getInt(TIME))) >
              Duration.millisecondsPerSecond) continue;
        }

        if (minAge != -1) {
          int age = getAge(DateTime.parse(model.getString(BIRTH_DATE)));
          if (minAge > age) continue;
        }
        if (maxAge != -1) {
          int age = getAge(DateTime.parse(model.getString(BIRTH_DATE)));
          if (maxAge < age) continue;
        }
        if (interestType != -1) {
          if (model.getInt(RELATIONSHIP) != interestType) continue;
        }

        final geoPoint = model.getModel(POSITION).get("geopoint") as GeoPoint;
        print("User Lat/Lon ${geoPoint.latitude}  ${geoPoint.longitude}");
        model.put(DISTANCE, await calculateDistanceTo(geoPoint));

        int index = peopleList
            .indexWhere((bm) => bm.getObjectId() == model.getObjectId());
        if (index == -1) peopleList.add(model);
      }
      loadingSub.cancel();
      setup = true;
      if (mounted) setState(() {});
    });
  }

  calculateDistanceTo(
    GeoPoint geoPoint,
  ) async {
    final myGeoPoint = userModel.getModel(POSITION).get("geopoint") as GeoPoint;
    return await Geolocator().distanceBetween(myGeoPoint.latitude,
        myGeoPoint.longitude, geoPoint.latitude, geoPoint.longitude);

    var gcd = new GreatCircleDistance.fromDegrees(
        latitude1: myGeoPoint.latitude,
        longitude1: myGeoPoint.longitude,
        latitude2: geoPoint.latitude,
        longitude2: geoPoint.longitude);
    print("Calc ${gcd.vincentyDistance()}");
    return gcd.vincentyDistance();
  }

  @override
  void dispose() {
    //  for (var sub in loadingSub) {
    //     sub?.cancel();
    //   }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: page(),
    );
  }

  String get headerTitle {
    if (currentPage == 0)
      return widget.fromStrock ? "Quick Strock" : "Nearby Search";

    if (currentPage == 1) return "Matches";
    if (currentPage == 2) return "Chat";
    return "Profile";
  }

  page() {
    return Column(
      children: [
        addSpace(40),
        pages(),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (p) {
              if (p == 0) {
                return btmTab(p, Feather.home, "Explore", isAsset: false);
              }
              if (p == 1) {
                return btmTab(p, Feather.heart, "Matches", isAsset: false);
              }
              if (p == 2) {
                return btmTab(p, Feather.message_circle, "Chat",
                    isAsset: false);
              }
              return btmTab(p, Feather.user, "Profile", isAsset: false);
            }))
      ],
    );
  }

  pages() {
    return Expanded(
      child: PageView(
        controller: pc,
        onPageChanged: (p) {
          setState(() {
            currentPage = p;
          });
        },
        children: [
          page1(),
          Matches(
            showBar: false,
          ),
          Chat(
            showBar: false,
          ),
          Account(
            showBar: false,
          )
        ],
      ),
    );
  }

  page1() {
    if (!setup) return loadingLayout();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
                child: Row(
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
                  child: Text(
                    headerTitle,
                    style: textStyle(true, 25, black),
                  ),
                ),
              ],
            )),
            IconButton(
                icon: Icon(Icons.sort),
                onPressed: () {
                  pushAndResult(
                      context,
                      FilterDialog(filterLocation, genderType, onlineType,
                          minAge, maxAge, interestType), result: (_) {
                    List items = _;
                    filterLocation = items[0];
                    genderType = items[1];
                    onlineType = items[2];
                    minAge = items[3];
                    maxAge = items[4];
                    interestType = items[5];
                    loadItems();
                  }, depend: false);
                })
          ],
        ),
        StaggeredGridView.countBuilder(
          crossAxisCount: 3,
          itemCount: peopleList.length,
          itemBuilder: (BuildContext context, int p) {
            BaseModel model = peopleList[p];
            List images = model.getList(PROFILE_PHOTOS);
            //print(model.get(DISTANCE));
            String image = model.profilePhotos[0].imageUrl;
            if (widget.fromStrock) {
              image = model.hookUpPhotos[0].imageUrl;
            }
            return Container(
              margin: EdgeInsets.only(top: p == 1 ? 50 : 0),
              width: double.infinity,
              //alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      //clickChat(context, model, false);
                      pushAndResult(
                          context,
                          ShowProfile(
                            theUser: model,
                            fromMeetMe: widget.fromStrock,
                          ));
                    },
                    child: Container(
                      height: 110,
                      width: double.infinity,
                      alignment: Alignment.center,
//                padding: EdgeInsets.all(5),
                      child: Stack(
                        children: [
                          // Align(
                          //   alignment: Alignment.topCenter,
                          //   child: imageHolder(90, image,
                          //       iconHolderSize: 20,
                          //       stroke: 0,
                          //       strokeColor: transparent),
                          // ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: image,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                placeholder: (c, s) {
                                  return Container(
                                      width: 100,
                                      height: 100,
                                      child: Center(
                                          child: Icon(
                                        Icons.person,
                                        color: white,
                                        size: 15,
                                      )),
                                      decoration: BoxDecoration(
                                        color: black.withOpacity(.09),
                                        //shape: BoxShape.circle
                                      ));
                                },
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                                //alignment: Alignment.bottomCenter,
                                padding: EdgeInsets.fromLTRB(5, 3, 5, 3),
                                decoration: BoxDecoration(
                                    color: AppConfig.appColor,
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(color: white, width: 2)),
                                child: Text(
                                  "${(model.getDouble(DISTANCE) / 1000).roundToDouble()} KM",
                                  style: textStyle(false, 12, white),
                                )),
                          )
                        ],
                      ),
                    ),
                  ),
                  Text(
                    model.getString(NAME),
                    style: textStyle(true, 12, black),
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            );
          },
          padding: EdgeInsets.all(0),
          staggeredTileBuilder: (int index) =>
              new StaggeredTile.extent(1, (index == 1) ? 180 : 130),
          shrinkWrap: true,
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
        ),
      ],
    );
  }

  btmTab(int p, icon, String title, {bool isAsset = false}) {
    bool active = currentPage == p;
    final width = MediaQuery.of(context).size.width / 4;
    return Flexible(
      child: GestureDetector(
          onTap: () {
            setState(() {
              pc.jumpToPage(p);
            });
          },
          child: Container(
            width: width,
            height: 64,
            alignment: Alignment.center,
            color: transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Builder(
                  builder: (ctx) {
                    if (isAsset)
                      return Image.asset(
                        icon,
                        height: 20,
                        width: 20,
                        color: black.withOpacity(active ? 1 : 0.5),
                      );
                    return Icon(
                      icon,
                      size: 20,
                      color: black.withOpacity(active ? 1 : 0.5),
                    );
                  },
                ),
                Text(
                  title,
                  style: textStyle(active, active ? 13 : 12,
                      black.withOpacity(active ? 1 : 0.5)),
                )
              ],
            ),
          )),
    );
  }
}
