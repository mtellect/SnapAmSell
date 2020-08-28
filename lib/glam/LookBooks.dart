import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/assets.dart';

class LookBooks extends StatefulWidget {
  @override
  _LookBooksState createState() => _LookBooksState();
}

class _LookBooksState extends State<LookBooks> {
  int itemCount = 17;
  List<Map> eventItems = [
    {
      "image": "https://bit.ly/3g3g5Qy",
      "title": "Lagos Fassion & Design Week 2018"
    },
    {"image": "https://bit.ly/3g6dsNM", "title": "Kolo Open Air Pop Up Shop "},
    {
      "image": "https://bit.ly/3458BtX",
      "title": "Zara A/W 19 Collection Release"
    },
    {
      "image": "https://bit.ly/3h3JnzU",
      "title": "For the Love of African Print"
    },
    {"image": "https://bit.ly/3205a54", "title": "Gala Week & Show Down"},
    {"image": "https://bit.ly/30ZIQt2", "title": "The Power of Female Fassion"},
    {"image": "https://bit.ly/30ZJarG", "title": "Womens Fashion Necklace"},
    {"image": "https://bit.ly/344Cxqb", "title": "Red Carpet"},
    {"image": "https://bit.ly/2Q0xM8R", "title": "AMI Awards"},
    {"image": "https://bit.ly/3fY3SMR", "title": "Festac Festival"},
    {"image": "https://bit.ly/3120sEP", "title": "Calabar Carnival 2018"},
  ];

  @override
  Widget build(BuildContext context) {
    return page();
  }

  page() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
//        addSpace(10),
//        Container(
//          child: Stack(
//            children: [
//              Align(
//                  alignment: Alignment.bottomCenter,
//                  child: addLine(1, white.withOpacity(.2), 0, 52, 0, 0)),
//              Row(
//                mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                children: [
//                  Container(
//                    alignment: Alignment.bottomCenter,
//                    padding: EdgeInsets.only(top: 10, bottom: 10, left: 10),
//                    child: Row(
//                      mainAxisAlignment: MainAxisAlignment.start,
//                      mainAxisSize: MainAxisSize.min,
//                      children: [
//                        Column(
//                          mainAxisAlignment: MainAxisAlignment.start,
//                          children: [
//                            Text(
//                              "Filter by Year",
//                              style: textStyle(false, 20, white),
//                            ),
//                            addSpace(10),
//                            Container(
//                              height: 2,
//                              color: white,
//                              width: 120,
//                            )
//                          ],
//                        ),
//                        Container(
//                          child: RawMaterialButton(
//                            onPressed: () {},
//                            child: Icon(
//                              Icons.keyboard_arrow_down,
//                              color: white,
//                            ),
//                          ),
//                        ),
//                      ],
//                    ),
//                  ),
//                  Spacer(),
//                  Container(
//                    padding: EdgeInsets.only(top: 10, bottom: 10, left: 10),
//                    child: Row(
//                      mainAxisAlignment: MainAxisAlignment.start,
//                      mainAxisSize: MainAxisSize.min,
//                      children: [
//                        Container(
//                          child: Text(
//                            "2018",
//                            style: textStyle(false, 20, white),
//                          ),
//                        ),
//                        Container(
//                          child: RawMaterialButton(
//                            onPressed: () {},
//                            child: Icon(
//                              Icons.keyboard_arrow_down,
//                              color: white,
//                            ),
//                          ),
//                        ),
//                      ],
//                    ),
//                  )
//                ],
//              ),
//            ],
//          ),
//        ),
        Expanded(
            child: GridView.builder(
                padding: EdgeInsets.only(left: 5, right: 5),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: .85,
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10),
                itemCount: eventItems.length,
                shrinkWrap: true,
                addAutomaticKeepAlives: true,
                itemBuilder: (ctx, p) {
                  String image = eventItems[p]["image"];
                  String title = eventItems[p]["title"];

                  return Container(
                    decoration: BoxDecoration(
                        color: black, borderRadius: BorderRadius.circular(10)),
                    height: 150,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                              color: white.withOpacity(.1),
                              child: CachedNetworkImage(
                                imageUrl: image,
                                fit: BoxFit.cover,
                                height: double.infinity,
                                width: double.infinity,
                              )),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            color: black.withOpacity(.2),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                title,
                                overflow: TextOverflow.ellipsis,
                                style: textStyle(false, 18, white),
                              ),
                              addSpace(5),
                              Text(
                                "$itemCount items",
                                style: textStyle(false, 15, white),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                })

//              ListView.builder(
//            itemBuilder: (c, p) {
//              BaseModel model = eventList[p];
//
//              String otherPersonId = getOtherPersonId(model);
//              String eventId = getEventId(model);
//              return Container(height: 100, color: red);
//            },
//            shrinkWrap: true,
//            itemCount: 10,
//            padding: EdgeInsets.all(0),
//
            ),
      ],
    );
  }
}
