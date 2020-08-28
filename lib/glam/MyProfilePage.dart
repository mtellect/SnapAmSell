import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/assets.dart';
import 'package:maugost_apps/glam/AddBioData.dart';
import 'package:maugost_apps/glam/MyContentPage.dart';
import 'package:maugost_apps/glam/MyListPage.dart';
import 'package:maugost_apps/glam/MyOrdersPage.dart';
import 'package:maugost_apps/glam/NotificationPage.dart';

class MyProfilePage extends StatefulWidget {
  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  final vp = PageController();
  int currentPage = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(top: 30, right: 10, left: 10, bottom: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BackButton(),
                Container(
                  margin: EdgeInsets.only(left: 15),
                  child: Text(
                    "Profile",
                    style: textStyle(true, 25, black),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 15),
                  child: Row(
                    children: [
                      Container(
                        height: 80,
                        width: 80,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(80),
                              child: CachedNetworkImage(
                                imageUrl: userModel.userImage,
                                fit: BoxFit.cover,
                                height: 80,
                                width: 80,
                                placeholder: (c, s) {
                                  return Container(
                                    height: 80,
                                    width: 80,
                                    alignment: Alignment.center,
                                    child: Icon(LineIcons.user),
                                    decoration: BoxDecoration(
                                        color: black.withOpacity(.08),
                                        shape: BoxShape.circle),
                                  );
                                },
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                height: 30,
                                width: 30,
                                padding: EdgeInsets.all(4),
                                alignment: Alignment.center,
                                child: Icon(
                                  LineIcons.plus,
                                  color: white,
                                  size: 15,
                                ),
                                decoration: BoxDecoration(
                                    color: black,
                                    border: Border.all(color: white, width: 3),
                                    shape: BoxShape.circle),
                              ),
                            )
                          ],
                        ),
                      ),
                      addSpaceWidth(10),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Maugost Okore",
                              style: textStyle(false, 20, black),
                            ),
                            Text(
                              "Designer",
                              style: textStyle(false, 16, black),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          profilePage(),
        ],
      ),
    );
  }

  profilePage() {
    return Flexible(
      child: ListView(
        padding: EdgeInsets.all(0),
        children: [
          profileItem("Bio Data", () {
            pushAndResult(context, AddBioData());
          }),
          profileItem("My Orders", () {
            pushAndResult(context, MyOrdersPage());
          }),
          profileItem("My List", () {
            pushAndResult(context, MyListPage());
          }),
          profileItem("My Products", () {
            //pushAndResult(context, AddBioData());
          }),
          profileItem("My Content", () {
            pushAndResult(context, MyContentPage());
          }),
          profileItem("Notifications", () {
            pushAndResult(context, NotificationPage());
          }),
          profileItem("Sign Out", () {
            //pushAndResult(context, AddBioData());
          }),
        ],
      ),
    );
  }

  profileItem(String title, onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(15),
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: black.withOpacity(.08)))),
        child: Row(
          children: [
            Text(
              title,
              style: textStyle(false, 20, black),
            ),
            Spacer(),
            Icon(
              Icons.navigate_next,
              color: black.withOpacity(.4),
            )
          ],
        ),
      ),
    );
  }
}
