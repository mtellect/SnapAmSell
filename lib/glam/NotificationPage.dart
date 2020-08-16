import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/assets.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
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
                    "Notifications",
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
              children: List.generate(2, (index) {
                bool active = currentPage == index;
                String title = "Events";
                if (index == 1) title = "Orders";
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
              children: [eventsPage(), ordersPage()],
            ),
          )
        ],
      ),
    );
  }

  eventsPage() {
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
                  Text(
                    "You have an event that is coming up soon",
                    style: textStyle(true, 18, black),
                  ),
                  Row(
                    children: [
                      Icon(LineIcons.map_marker),
                      Flexible(
                        child: Text(
                          "Michael Okpara university of agriculture,Umudike, Umuahia",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textStyle(false, 14, black.withOpacity(.8)),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(LineIcons.calendar_times_o),
                      Text(
                        "Tomorrow at 12:45PM",
                        style: textStyle(false, 14, black.withOpacity(.8)),
                      ),
                    ],
                  ),
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

  ordersPage() {
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
