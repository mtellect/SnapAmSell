import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/assets.dart';

class MyOrdersPage extends StatefulWidget {
  @override
  _MyOrdersPageState createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
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
                    "My Orders (3)",
                    style: textStyle(true, 25, black),
                  ),
                )
              ],
            ),
          ),
          myLists(),
//          Container(
//            padding: EdgeInsets.all(20),
//            child: FlatButton(
//              onPressed: () {
//                pushAndResult(context, AddAddress());
//              },
//              color: black,
//              padding: EdgeInsets.all(15),
//              child: Center(
//                  child: Text(
//                "ADD TO BAG",
//                style: textStyle(false, 18, white),
//              )),
//            ),
//          )
        ],
      ),
    );
  }

  myLists() {
    return Flexible(
      child: Builder(
        builder: (c) {
          emptyLayout(LineIcons.list, "No List",
              "Please add a new address to be able to receive orders.");

          return ListView.builder(
              itemCount: 3,
              padding: EdgeInsets.all(0),
              itemBuilder: (c, p) {
                String orderId = "Order No #GL-1926$p";
                String date = "Date: 19/08/2020 2 Items";

                bool atEnd = p == 10 - 1;
                bool defaultAddress = p == 0;

                return InkWell(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        //color: black.withOpacity(defaultAddress ? 0.03 : 0),
                        border: Border(
                            bottom: BorderSide(
                                color: black.withOpacity(atEnd ? 0 : 0.1)))),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(4),
                          margin: EdgeInsets.all(5),
                          height: 120,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: "https://tinyurl.com/yyd4zdhe",
                              height: 120,
                              width: 100,
                              fit: BoxFit.cover,
                              placeholder: (c, p) {
                                return placeHolder(120, width: 100);
                              },
                            ),
                          ),
                        ),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    orderId,
                                    style: textStyle(true, 18, black),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        color: statusColor(p),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Text(
                                      "",
                                      style: textStyle(false, 14, white),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                date,
                                style:
                                    textStyle(false, 16, black.withOpacity(.8)),
                              ),
//                        Text(
//                          mobile,
//                          style: textStyle(false, 14, black.withOpacity(.6)),
//                        ),
//                        addSpace(10),
//                        Row(
//                          children: [
//                            Container(
//                              height: 25,
//                              width: 25,
//                              alignment: Alignment.center,
//                              child: Icon(
//                                LineIcons.check,
//                                size: 15,
//                                color:
//                                    black.withOpacity(defaultAddress ? 1 : 0.3),
//                              ),
//                              decoration: BoxDecoration(
//                                  shape: BoxShape.circle,
//                                  border: Border.all(
//                                      color: black.withOpacity(
//                                          defaultAddress ? 1 : 0.3))),
//                            ),
//                            addSpaceWidth(10),
//                            Text(
//                              "Set as Default",
//                              style: textStyle(false, 14,
//                                  black.withOpacity(defaultAddress ? 1 : 0.6)),
//                            ),
//                          ],
//                        ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
        },
      ),
    );
  }

  Color statusColor(int p) {
    if (p == 0) return green_dark;
    if (p == 1) return orange0;
    return red;
  }
}
