import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/assets.dart';

class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final vp = PageController();
  int currentPage = 0;

  final productName = TextEditingController();
  final productPrice = TextEditingController();
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
                    "New Product",
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
                "PUBLISH",
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
            inputTextView("Product Name", productName, isNum: false),
            inputTextView("Product Price", productPrice,
                isNum: true, priceIcon: LineIcons.money),
            sizesView(),
            imagesView(),
            addSpace(10),
            Container(
              decoration: BoxDecoration(
                  color: red, borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.all(10),
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    color: white,
                  ),
                  addSpaceWidth(10),
                  Flexible(
                    child: Text(
                      "Note: This Product will undergo a verification process by our"
                      " support team before publication. Please follow our"
                      " community guidelines.",
                      style: textStyle(false, 14, white),
                    ),
                  ),
                ],
              ),
            ),
//            GestureDetector(
//              onTap: () {
//                setState(() {
//                  defaultAddress = !defaultAddress;
//                });
//              },
//              child: Row(
//                mainAxisSize: MainAxisSize.min,
//                children: [
//                  Container(
//                    height: 25,
//                    width: 25,
//                    alignment: Alignment.center,
//                    child: Icon(
//                      LineIcons.check,
//                      size: 15,
//                      color: black.withOpacity(defaultAddress ? 1 : 0.3),
//                    ),
//                    decoration: BoxDecoration(
//                        shape: BoxShape.circle,
//                        border: Border.all(
//                            color:
//                                black.withOpacity(defaultAddress ? 1 : 0.3))),
//                  ),
//                  addSpaceWidth(10),
//                  Text(
//                    "Set as Default",
//                    style: textStyle(defaultAddress, 16,
//                        black.withOpacity(defaultAddress ? 1 : .6)),
//                  ),
//                ],
//              ),
//            ),
          ],
        ),
      ),
    );
  }

  sizesView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Available Sizes",
          style: textStyle(true, 14, black),
        ),
        addSpace(10),
        SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(CLOTH_SIZES.length, (index) {
              String value = CLOTH_SIZES[index];
              bool active = selectedSize == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedSize = index;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: black.withOpacity(active ? 1 : 0.09)),
                  child: Text(
                    value,
                    style: textStyle(active, 14, active ? white : black),
                  ),
                ),
              );
            }),
          ),
        )
      ],
    );
  }

  imagesView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Images/Video",
          style: textStyle(true, 14, black),
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
                  bool active = 1 == index;
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
