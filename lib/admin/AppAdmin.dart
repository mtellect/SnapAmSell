import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/assets.dart';
import 'package:maugost_apps/basemodel.dart';
import 'package:maugost_apps/dialogs/inputDialog.dart';
import 'package:maugost_apps/dialogs/listDialog.dart';

import 'ShowAds.dart';
import 'ShowUsers.dart';
import 'Subscriptions.dart';

class AppAdmin extends StatefulWidget {
  @override
  _AppAdminState createState() => _AppAdminState();
}

class _AppAdminState extends State<AppAdmin> {
  List<BaseModel> usersList = [];
  List<BaseModel> adsList = [];
  bool setup = false;
  List<StreamSubscription> subs = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadUsers();
    loadAds();
  }

  @override
  void dispose() {
    for (var s in subs) s?.cancel();
    super.dispose();
  }

  loadUsers() async {
    var sub =
        Firestore.instance.collection(USER_BASE).snapshots().listen((value) {
      for (var doc in value.documents) {
        BaseModel model = BaseModel(doc: doc);
        int p = usersList.indexWhere(
            (element) => element.getObjectId() == model.getObjectId());
        if (p != -1) {
          usersList[p] = model;
        } else {
          usersList.add(model);
        }
      }
      setup = true;
      if (mounted) setState(() {});
    });
    subs.add(sub);
  }

  loadAds() async {
    var sub =
        Firestore.instance.collection(ADS_BASE).snapshots().listen((value) {
      for (var doc in value.documents) {
        BaseModel model = BaseModel(doc: doc);
        int p = adsList.indexWhere(
            (element) => element.getObjectId() == model.getObjectId());
        if (p != -1) {
          adsList[p] = model;
        } else {
          adsList.add(model);
        }
      }
      setup = true;
      if (mounted) setState(() {});
    });
    subs.add(sub);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
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
                      height: 50,
                      child: Center(
                          child: Icon(
                        Icons.keyboard_backspace,
                        color: black,
                        size: 25,
                      )),
                    )),
                Text(
                  "Admin Portal",
                  style: textStyle(true, 25, black),
                ),
                Spacer(),
              ],
            ),
          ),
          page()
        ],
      ),
    );
  }

  page() {
    return Flexible(
      child: ListView(
        padding: EdgeInsets.all(0),
        children: [
          usersStatistics(),
          usersRevenue(),
          adsStatistics(),
          adsRevenue(),
          //subscriptionFeatures(),

          ListTile(
            onTap: () {
              pushAndResult(
                  context,
                  inputDialog(
                    "Stripe Secret Key",
                    hint: "Enter Stripe Secret Key",
                    message: appSettingsModel.getString(STRIPE_SEC_KEY),
                  ), result: (_) {
                if (null == _) return;
                appSettingsModel
                  ..put(STRIPE_PUB_KEY, _)
                  ..updateItems();
                setState(() {});
              }, depend: false);
            },
            title: Text("Stripe Secret Key"),
            subtitle: Text("Set and Update Stripe Secret key Here"),
            trailing: Icon(Icons.navigate_next),
          ),

          ListTile(
            onTap: () {
              pushAndResult(
                  context,
                  inputDialog(
                    "NearBy Radius",
                    hint: "Enter NearBy Radius",
                    message:
                        appSettingsModel.getDouble(NEARBY_RADIUS).toString(),
                    inputType: TextInputType.number,
                  ),
                  depend: false, result: (_) {
                if (null == _) return;
                appSettingsModel
                  ..put(NEARBY_RADIUS, double.parse(_))
                  ..updateItems();
                setState(() {});
              });
            },
            title: Text(
                "NearBy Radius -- (${appSettingsModel.getDouble(NEARBY_RADIUS)}KM)"),
            subtitle: Text("Set App Nearby Radius here"),
            trailing: Icon(Icons.navigate_next),
          ),
          ListTile(
            onTap: () {
              pushAndResult(
                  context,
                  Subscriptions(
                    type: 0,
                  ),
                  depend: false);
            },
            title: Text("Regular Subscription"),
            subtitle: Text("Set Superlike,Swipes,Features"),
            trailing: Icon(Icons.navigate_next),
          ),
          ListTile(
            onTap: () {
              pushAndResult(
                  context,
                  Subscriptions(
                    type: 1,
                  ),
                  depend: false);
            },
            title: Text("Premium Subscription"),
            subtitle: Text("Set Superlike,Swipes,Prices and Features"),
            trailing: Icon(Icons.navigate_next),
          ),
          ListTile(
            onTap: () {
              pushAndResult(
                  context,
                  inputDialog(
                    "About Us",
                    hint: "Enter About Us url link",
                    message: appSettingsModel.getString(ABOUT_LINK),
                  ), result: (_) {
                if (null == _) return;
                appSettingsModel
                  ..put(ABOUT_LINK, _)
                  ..updateItems();
                setState(() {});
              }, depend: false);
            },
            title: Text("About Us"),
            subtitle: Text("Update About the app here"),
            trailing: Icon(Icons.navigate_next),
          ),
          ListTile(
            onTap: () {
              pushAndResult(
                  context,
                  inputDialog(
                    "Privacy Policy",
                    hint: "Enter Privacy Policy url link",
                    message: appSettingsModel.getString(PRIVACY_LINK),
                  ), result: (_) {
                if (null == _) return;
                appSettingsModel
                  ..put(PRIVACY_LINK, _)
                  ..updateItems();
                setState(() {});
              }, depend: false);
            },
            title: Text("Privacy Policy"),
            subtitle: Text("Update Privacy Policy of the app here"),
            trailing: Icon(Icons.navigate_next),
          ),
          ListTile(
            onTap: () {
              pushAndResult(
                  context,
                  inputDialog(
                    "Terms of Service",
                    hint: "Enter Terms of Service url link",
                    message: appSettingsModel.getString(TERMS_LINK),
                  ), result: (_) {
                if (null == _) return;
                appSettingsModel
                  ..put(TERMS_LINK, _)
                  ..updateItems();
                setState(() {});
              }, depend: false);
            },
            title: Text("Terms of Service"),
            subtitle: Text("Update Terms of Service of the app here"),
            trailing: Icon(Icons.navigate_next),
          ),
          ListTile(
            onTap: () {
              pushAndResult(
                  context,
                  inputDialog(
                    "Stripe Public Key",
                    hint: "Enter Stripe Public Key",
                    message: appSettingsModel.getString(STRIPE_PUB_KEY),
                  ), result: (_) {
                if (null == _) return;
                appSettingsModel
                  ..put(STRIPE_PUB_KEY, _)
                  ..updateItems();
                setState(() {});
              }, depend: false);
            },
            title: Text("Stripe Public Key"),
            subtitle: Text("Set and Update Stripe Public key Here"),
            trailing: Icon(Icons.navigate_next),
          ),
          ListTile(
            onTap: () {
              pushAndResult(
                  context,
                  inputDialog(
                    "Stripe Secret Key",
                    hint: "Enter Stripe Secret Key",
                    message: appSettingsModel.getString(STRIPE_SEC_KEY),
                  ), result: (_) {
                if (null == _) return;
                appSettingsModel
                  ..put(STRIPE_PUB_KEY, _)
                  ..updateItems();
                setState(() {});
              }, depend: false);
            },
            title: Text("Stripe Secret Key"),
            subtitle: Text("Set and Update Stripe Secret key Here"),
            trailing: Icon(Icons.navigate_next),
          ),
          ListTile(
            onTap: () {
              pushAndResult(context, listDialog(["True", "False"]),
                  result: (_) {
                if (null == _) return;
                appSettingsModel
                  ..put(STRIPE_IS_LIVE, _ == "True")
                  ..updateItems();
                setState(() {});
              }, depend: false);
            },
            title: Text(
                "Stripe in Production Mode ${appSettingsModel.getBoolean(STRIPE_IS_LIVE)}"),
            subtitle: Text("Set Stripe Production Mode"),
            trailing: Icon(Icons.navigate_next),
          )
        ],
      ),
    );
  }

  usersStatistics() {
    int total = usersList.length;
    final regular =
        usersList.where((e) => e.getInt(ACCOUNT_TYPE) == 0).toList();
    final premium =
        usersList.where((e) => e.getInt(ACCOUNT_TYPE) == 1).toList();
    final reports =
        usersList.where((e) => e.getInt(ACCOUNT_TYPE) == 1).toList();
    return Container(
      decoration: BoxDecoration(
          color: black.withOpacity(0.09),
          borderRadius: BorderRadius.circular(10)),
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Users Statistics"),
          addSpace(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (p) {
              String title;
              int count;
              if (p == 0) {
                title = "Total";
                count = total;
              }
              if (p == 1) {
                title = "Regular";
                count = regular.length;
              }
              if (p == 2) {
                title = "Premium";
                count = premium.length;
              }
              if (p == 3) {
                title = "Reports";
                count = 0;
              }

              return Flexible(
                child: GestureDetector(
                  onTap: () {
                    if (p == 3) return;
                    print("okkk");
                    pushAndResult(
                        context,
                        ShowUsers(
                          users:
                              p == 0 ? usersList : p == 1 ? regular : premium,
                          title: title + " Users",
                        ),
                        depend: false);
                  },
                  child: Container(
                    width: getScreenWidth(context) / 4,
                    color: transparent,
                    child: Column(
                      children: [
                        Text(
                          "${count}",
                          textAlign: TextAlign.center,
                          style: textStyle(true, 22, black),
                        ),
                        Text(
                          "$title",
                          textAlign: TextAlign.center,
                          style: textStyle(true, 14, black.withOpacity(.5)),
                        )
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  usersRevenue() {
    int total = adsList.length;
    final active = adsList.where((e) => e.getType() == 0).toList();
    final inActive = adsList.where((e) => e.getType() == 1).toList();
    final pending = adsList.where((e) => e.getType() == 2).toList();
    return Container(
      decoration: BoxDecoration(
          color: black.withOpacity(0.09),
          borderRadius: BorderRadius.circular(10)),
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Users Revenue Statistics \$"),
          addSpace(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (p) {
              String title;
              int count;
              if (p == 0) {
                title = "Total";
                count = total;
              }
              if (p == 1) {
                title = "Regular";
                count = active.length;
              }
              if (p == 2) {
                title = "Premium";
                count = inActive.length;
              }
              if (p == 3) {
                title = "Pending";
                count = pending.length;
              }

              return Flexible(
                child: GestureDetector(
                  onTap: () {
                    print("okkk");
                    pushAndResult(
                        context,
                        ShowUsers(
                          users: usersList,
                        ),
                        depend: false);
                  },
                  child: Container(
                    width: getScreenWidth(context) / 3,
                    color: transparent,
                    child: Column(
                      children: [
                        Text(
                          "${count.toDouble()}",
                          textAlign: TextAlign.center,
                          style: textStyle(true, 22, black),
                        ),
                        Text(
                          "$title",
                          textAlign: TextAlign.center,
                          style: textStyle(true, 14, black.withOpacity(.5)),
                        )
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  adsStatistics() {
    int total = adsList.length;
    final active = adsList.where((e) => e.getInt(STATUS) == APPROVED).toList();
    final inActive =
        adsList.where((e) => e.getInt(STATUS) == INACTIVE).toList();
    final pending = adsList.where((e) => e.getInt(STATUS) == PENDING).toList();
    return Container(
      decoration: BoxDecoration(
          color: black.withOpacity(0.09),
          borderRadius: BorderRadius.circular(10)),
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Ads Statistics"),
          addSpace(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (p) {
              String title;
              int count;
              if (p == 0) {
                title = "Total";
                count = total;
              }
              if (p == 1) {
                title = "Active";
                count = active.length;
              }
              if (p == 2) {
                title = "InActive";
                count = inActive.length;
              }
              if (p == 3) {
                title = "Pending";
                count = pending.length;
              }

              return Flexible(
                child: GestureDetector(
                  onTap: () {
                    print("okkk");
                    pushAndResult(
                        context,
                        ShowAds(
                          ads: p == 0
                              ? adsList
                              : p == 1 ? active : p == 2 ? inActive : pending,
                          title: title + " Ads",
                        ),
                        depend: false);
                  },
                  child: Container(
                    width: getScreenWidth(context) / 3,
                    color: transparent,
                    child: Column(
                      children: [
                        Text(
                          "$count",
                          textAlign: TextAlign.center,
                          style: textStyle(true, 22, black),
                        ),
                        Text(
                          "$title",
                          textAlign: TextAlign.center,
                          style: textStyle(true, 14, black.withOpacity(.5)),
                        )
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  adsRevenue() {
    int total = adsList.length;
    final active = adsList.where((e) => e.getType() == 0).toList();
    final inActive = adsList.where((e) => e.getType() == 1).toList();
    final pending = adsList.where((e) => e.getType() == 2).toList();
    return Container(
      decoration: BoxDecoration(
          color: black.withOpacity(0.09),
          borderRadius: BorderRadius.circular(10)),
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Ads Revenue Statistics \$"),
          addSpace(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (p) {
              String title;
              int count;
              if (p == 0) {
                title = "Total";
                count = total;
              }
              if (p == 1) {
                title = "Active";
                count = active.length;
              }
              if (p == 2) {
                title = "InActive";
                count = inActive.length;
              }
              if (p == 3) {
                title = "Pending";
                count = pending.length;
              }

              return Flexible(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: getScreenWidth(context) / 3,
                    color: transparent,
                    child: Column(
                      children: [
                        Text(
                          "${count.toDouble()}",
                          textAlign: TextAlign.center,
                          style: textStyle(true, 22, black),
                        ),
                        Text(
                          "$title",
                          textAlign: TextAlign.center,
                          style: textStyle(true, 14, black.withOpacity(.5)),
                        )
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
