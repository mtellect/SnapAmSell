import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/assets.dart';

class AddBioData extends StatefulWidget {
  @override
  _AddBioDataState createState() => _AddBioDataState();
}

class _AddBioDataState extends State<AddBioData> {
  final vp = PageController();
  int currentPage = 0;

  final fullName = TextEditingController();
  final gender = TextEditingController();
  final email = TextEditingController();
  final mobileNumber = TextEditingController();
  final addressStreet = TextEditingController();
  final website = TextEditingController();
  final bio = TextEditingController();

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
                    "Bio Data",
                    style: textStyle(true, 25, black),
                  ),
                )
              ],
            ),
          ),
          bioPage(),
          Container(
            padding: EdgeInsets.all(20),
            child: FlatButton(
              onPressed: () {},
              color: black,
              padding: EdgeInsets.all(15),
              child: Center(
                  child: Text(
                "SAVE",
                style: textStyle(false, 18, white),
              )),
            ),
          )
        ],
      ),
    );
  }

  bioPage() {
    return Flexible(
      child: Container(
        child: ListView(
          padding: EdgeInsets.all(10),
          children: [
            inputTextView("Full Name", fullName, isNum: false),
            inputTextView("Gender", gender, isNum: false, selectorMode: true,
                onSelected: () {
              showListDialog(context, genderType, (_) {
                gender.text = genderType[_];
                setState(() {});
              });
            }),
            inputTextView("Email", email, isNum: false),
            inputTextView("Phone Number", mobileNumber, isNum: false),
            inputTextView("Address", addressStreet, isNum: false),
            inputTextView("Website", website, isNum: false),
            inputTextView("Bio", bio, isNum: false, maxLine: 4),
            addSpace(10),
          ],
        ),
      ),
    );
  }

  textView(String title, TextEditingController controller, {int max = 1}) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
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
          style: textStyle(false, 18, black.withOpacity(.5)),
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
