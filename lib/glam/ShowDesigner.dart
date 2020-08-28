import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/assets.dart';
import 'package:maugost_apps/basemodel.dart';
import 'package:maugost_apps/glam/AddBioData.dart';
import 'package:maugost_apps/glam/MyListPage.dart';
import 'package:maugost_apps/glam/MyOrdersPage.dart';

class ShowDesigner extends StatefulWidget {
  final BaseModel model;
  final String url;
  const ShowDesigner({Key key, this.model, this.url}) : super(key: key);
  @override
  _ShowDesignerState createState() => _ShowDesignerState();
}

class _ShowDesignerState extends State<ShowDesigner> {
  BaseModel get model => widget.model;
  List imagesUrl = [
    "https://tinyurl.com/yyd4zdhe",
    "https://tinyurl.com/y5hfxrzu",
    "https://tinyurl.com/yyglaujf",
    "https://tinyurl.com/y2wamc9p",
  ];

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
      body: Stack(
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          profilePage(),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              margin: EdgeInsets.only(top: 40),
              child: Icon(
                Icons.close,
                color: white,
              ),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: black,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20))),
            ),
          ),
        ],
      ),
    );
  }

  profilePage() {
    return ListView(
      padding: EdgeInsets.all(0),
      children: [
        GestureDetector(
          onTap: () {
            pushAndResult(context, ViewImage([widget.url], 0));
          },
          child: CachedNetworkImage(
            imageUrl: widget.url,
            height: 400,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (c, s) {
              return Container(
                height: 400,
                width: double.infinity,
                child: Icon(LineIcons.user),
                decoration: BoxDecoration(
                  color: black.withOpacity(.09),
                ),
              );
            },
          ),
        ),
        Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                model.getString("firstname") +
                    " " +
                    model.getString("lastname"),
                style: textStyle(true, 20, black),
              ),
              Text(
                model.getString('username'),
                style: textStyle(false, 16, black),
              ),
            ],
          ),
        ),
        profileItem("Biography", () {
          pushAndResult(context, AddBioData());
        }),
        profileItem("Company Details", () {
          pushAndResult(context, MyOrdersPage());
        }),
        profileItem("Contact Detail", () {
          pushAndResult(context, MyListPage());
        }),
        profileItem("Gallery", () {
          //pushAndResult(context, AddBioData());
        }),
        imagesView()
      ],
    );
  }

  profileItem(String title, onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: black.withOpacity(.08)))),
        child: Row(
          children: [
            Text(
              title,
              style: textStyle(false, 16, black),
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

  imagesView() {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 30, bottom: 30),
      color: black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Items By This Designer",
            style: textStyle(true, 16, white),
          ),
          addSpace(10),
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(imagesUrl.length, (index) {
                String imageUrl = imagesUrl[index];
                bool online = imageUrl.startsWith("http");
                bool active = 1 == index;
                return GestureDetector(
                  onTap: () {},
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(4),
                        margin: EdgeInsets.all(5),
                        height: 180,
                        width: 150,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: black.withOpacity(active ? 1 : 0.09)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            height: 120,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Full Length Dress",
                              style: textStyle(false, 14, white),
                            ),
                            Text(
                              "N160",
                              style: textStyle(true, 14, white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          )
        ],
      ),
    );
  }
}
