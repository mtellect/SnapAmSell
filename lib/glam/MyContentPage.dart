import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/assets.dart';

import 'AddProduct.dart';
import 'AddStory.dart';

class MyContentPage extends StatefulWidget {
  @override
  _MyContentPageState createState() => _MyContentPageState();
}

class _MyContentPageState extends State<MyContentPage> {
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
            padding: EdgeInsets.only(top: 30, right: 10, left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BackButton(),
                Container(
                  margin: EdgeInsets.only(left: 15),
                  child: Text(
                    "My Content",
                    style: textStyle(true, 25, black),
                  ),
                )
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 10, right: 10, left: 10),
            decoration: BoxDecoration(
                border: Border(
                    bottom:
                        BorderSide(width: 2, color: black.withOpacity(0.1)))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(3, (index) {
                bool active = currentPage == index;
                String title = "Products";
                if (index == 1) title = "Stories";
                if (index == 2) title = "Lookbooks";
                return GestureDetector(
                  onTap: () {
                    vp.jumpToPage(index);
                  },
                  child: Container(
                    width: 120,
                    height: 45,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: transparent,
                        border: Border(
                            bottom: BorderSide(
                                width: 4,
                                color: black.withOpacity(active ? 1 : 0)))),
                    child: Text(
                      title,
                      style: textStyle(active, 18, black),
                    ),
                  ),
                );
              }),
            ),
          ),
          Flexible(
            child: PageView(
              controller: vp,
              onPageChanged: (p) {
                setState(() {
                  currentPage = p;
                });
              },
              children: [productPage(), storiesPage(), lookBookPage()],
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            child: FlatButton(
              onPressed: () {
                if (currentPage == 0) pushAndResult(context, AddProduct());
                if (currentPage == 1) pushAndResult(context, AddStory());
                if (currentPage == 2) pushAndResult(context, AddProduct());
              },
              color: black,
              padding: EdgeInsets.all(15),
              child: Center(
                  child: Text(
                "CREATE NEW ${currentPage == 0 ? "PRODUCT" : currentPage == 1 ? "STORY" : "LOOKBOOK"}",
                style: textStyle(false, 18, white),
              )),
            ),
          )
        ],
      ),
    );
  }

  productPage() {
    emptyLayout(LineIcons.shirtsinbulk, "No Product",
        "Please add a new product to build your catelogue!");

    return ListView.builder(
        itemCount: 1,
        padding: EdgeInsets.all(0),
        itemBuilder: (c, p) {
          String orderId = "#GL-1926";
          String time = "20 mins ago";
          bool atEnd = p == 10 - 1;
          bool unRead = p < 4;

          final images = [
            "https://tinyurl.com/yyd4zdhe",
            "https://tinyurl.com/y5hfxrzu",
            "https://tinyurl.com/yyglaujf",
            "https://tinyurl.com/y2wamc9p",
          ];

          return InkWell(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                  //color: black.withOpacity(unRead ? 0.03 : 0),
                  border: Border(
                      bottom: BorderSide(
                          color: black.withOpacity(atEnd ? 0 : 0.1)))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 300,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: black.withOpacity(.1), width: 2)),
                          child: CachedNetworkImage(
                            imageUrl: images[0],
                            //height: 300,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            placeholder: (c, s) {
                              return placeHolder(300, width: double.infinity);
                            },
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            width: 80,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(images.length, (index) {
//
                                  return Container(
                                    height: 80,
                                    width: 80,
                                    decoration: BoxDecoration(
                                        border: Border(
                                            left: BorderSide(
                                                color: black, width: 3),
                                            bottom: BorderSide(
                                                color: black, width: 3))),
                                    child: Stack(
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl: images[index],
                                          fit: BoxFit.cover,
                                          alignment: Alignment.topCenter,
                                          width: double.infinity,
                                          placeholder: (c, s) {
                                            return placeHolder(80, width: 80);
                                          },
                                        ),
//                                        Container(
//                                          height: 80,
//                                          width: 80,
//                                          //color: black.withOpacity(.3),
//                                          alignment: Alignment.center,
//                                          child: Container(
//                                            height: 25,
//                                            width: 25,
//                                            decoration: BoxDecoration(
//                                                color: black,
//                                                shape: BoxShape.circle),
//                                            alignment: Alignment.center,
//                                            padding: EdgeInsets.all(3),
//                                            child: Text(
//                                              "$index",
//                                              style: textStyle(true, 15, white),
//                                            ),
//                                          ),
//                                        )
                                      ],
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Short Gown Ankara",
                              style: textStyle(true, 20, black),
                            ),
                            Row(
                              children: [
                                Icon(LineIcons.underline),
                                Flexible(
                                  child: Text(
                                    "Medium Size",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textStyle(
                                        false, 14, black.withOpacity(.8)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(color: black),
                        padding: EdgeInsets.all(5),
                        child: Row(
                          children: [
                            Icon(
                              LineIcons.money,
                              color: white,
                            ),
                            addSpaceWidth(10),
                            Text(
                              "NGN 5500.0",
                              style: textStyle(true, 18, white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  storiesPage() {
    return emptyLayout(LineIcons.dot_circle_o, "No Stories",
        "Please add a new story to build your catelogue!");

    return ListView.builder(
        itemCount: 10,
        padding: EdgeInsets.all(0),
        itemBuilder: (c, p) {
          String orderId = "#GL-1926";
          String time = "20 mins ago";
          bool atEnd = p == 10 - 1;
          bool unRead = p < 4;

          return InkWell(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: black.withOpacity(unRead ? 0.03 : 0),
                  border: Border(
                      bottom: BorderSide(
                          color: black.withOpacity(atEnd ? 0 : 0.1)))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(TextSpan(children: [
                    TextSpan(
                        text: "Your order ",
                        style: textStyle(false, 18, black)),
                    TextSpan(
                        text: "$orderId ", style: textStyle(true, 18, black)),
                    TextSpan(
                        text: " has been shipped!",
                        style: textStyle(false, 18, black)),
                  ])),
                  //addSpace(5),
                  Text(
                    time,
                    style: textStyle(false, 14, black.withOpacity(.5)),
                  ),
                ],
              ),
            ),
          );
        });
  }

  lookBookPage() {
    return emptyLayout(LineIcons.book, "No LookBooks",
        "Please add a new lookBook to build your catelogue!");

    return ListView.builder(
        itemCount: 10,
        padding: EdgeInsets.all(0),
        itemBuilder: (c, p) {
          String orderId = "#GL-1926";
          String time = "20 mins ago";
          bool atEnd = p == 10 - 1;
          bool unRead = p < 4;

          return InkWell(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: black.withOpacity(unRead ? 0.03 : 0),
                  border: Border(
                      bottom: BorderSide(
                          color: black.withOpacity(atEnd ? 0 : 0.1)))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(TextSpan(children: [
                    TextSpan(
                        text: "Your order ",
                        style: textStyle(false, 18, black)),
                    TextSpan(
                        text: "$orderId ", style: textStyle(true, 18, black)),
                    TextSpan(
                        text: " has been shipped!",
                        style: textStyle(false, 18, black)),
                  ])),
                  //addSpace(5),
                  Text(
                    time,
                    style: textStyle(false, 14, black.withOpacity(.5)),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
