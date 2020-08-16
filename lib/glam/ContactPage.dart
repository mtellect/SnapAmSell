import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/assets.dart';

class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final vp = PageController();
  int currentPage = 0;

  final storyTitle = TextEditingController();
  final storyContent = TextEditingController();
  final addressStreet1 = TextEditingController();
  final addressState = TextEditingController();
  final mobileNumber = TextEditingController();
  bool defaultAddress = false;
  int selectedSize = 2;
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
                    "Contact",
                    style: textStyle(true, 25, black),
                  ),
                )
              ],
            ),
          ),
          addressPage(),
          Container(
            padding: EdgeInsets.all(20),
            child: FlatButton(
              onPressed: () {},
              color: black,
              padding: EdgeInsets.all(15),
              child: Center(
                  child: Text(
                "SEND",
                style: textStyle(false, 18, white),
              )),
            ),
          )
        ],
      ),
    );
  }

  addressPage() {
    return Flexible(
      child: Container(
        child: ListView(
          padding: EdgeInsets.all(10),
          children: [
            Text(
              "GLAM seeks to give fashion buyers and aficionados a simple"
              " platform to shop from events/runways, and indulge in all "
              "things fashion, style and the rest of life!\n\n"
              "Have any enquires or suggestions? Drop us a message below.",
              style: textStyle(false, 20, black),
            ),
            addSpace(15),
            textView("Subject", storyTitle),
            addSpace(10),
            textView("Message...", storyContent, max: 10),
            addSpace(10),
          ],
        ),
      ),
    );
  }

  textView(String title, TextEditingController controller, {int max = 1}) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: black.withOpacity(.09), width: 2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textStyle(false, 18, black.withOpacity(.5)),
          ),
          Container(
            child: TextField(
              controller: controller,
              cursorColor: black,
              maxLines: max,
              decoration: InputDecoration(border: InputBorder.none),
            ),
          )
        ],
      ),
    );
  }

  imagesView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Images/Video",
          style: textStyle(true, 18, black.withOpacity(.5)),
        ),
        addSpace(10),
        SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(2, (index) {
                  String imageUrl = imagesUrl[index];
                  bool online = imageUrl.startsWith("http");
                  bool active = 100 == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedSize = index;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(4),
                      margin: EdgeInsets.all(5),
                      height: 120,
                      width: 100,
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
                  );
                }),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.all(4),
                  margin: EdgeInsets.all(5),
                  height: 120,
                  width: 100,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: black.withOpacity(0.09)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Icon(LineIcons.plus_circle), Text("Add")],
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
