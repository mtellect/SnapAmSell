import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/assets.dart';

import 'AddCard.dart';

class CardsPage extends StatefulWidget {
  @override
  _CardsPageState createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
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
                    "Cards",
                    style: textStyle(true, 25, black),
                  ),
                )
              ],
            ),
          ),
          addressBooks(),
          Container(
            padding: EdgeInsets.all(20),
            child: FlatButton(
              onPressed: () {
                pushAndResult(context, AddCard());
              },
              color: black,
              padding: EdgeInsets.all(15),
              child: Center(
                  child: Text(
                "ADD NEW CARD",
                style: textStyle(false, 18, white),
              )),
            ),
          )
        ],
      ),
    );
  }

  addressBooks() {
    return Flexible(
      child: Builder(
        builder: (c) {
          emptyLayout(LineIcons.credit_card, "No Cards",
              "Please add a new card to be able to make payments.");

          return ListView.builder(
              itemCount: 2,
              padding: EdgeInsets.all(0),
              itemBuilder: (c, p) {
                String cardType = "MasterCard";
                String cardLast4 = "*2180";
                bool atEnd = p == 10 - 1;
                bool defaultCard = p == 0;

                return InkWell(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: black.withOpacity(defaultCard ? 0.03 : 0),
                        border: Border(
                            bottom: BorderSide(
                                color: black.withOpacity(atEnd ? 0 : 0.1)))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              cardType,
                              style: textStyle(true, 18, black),
                            ),
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: black,
                                  borderRadius: BorderRadius.circular(5)),
                              child: Text(
                                "EDIT",
                                style: textStyle(false, 14, white),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          cardLast4,
                          style: textStyle(false, 16, black.withOpacity(.8)),
                        ),
                        addSpace(10),
                        Row(
                          children: [
                            Container(
                              height: 25,
                              width: 25,
                              alignment: Alignment.center,
                              child: Icon(
                                LineIcons.check,
                                size: 15,
                                color: black.withOpacity(defaultCard ? 1 : 0.3),
                              ),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: black
                                          .withOpacity(defaultCard ? 1 : 0.3))),
                            ),
                            addSpaceWidth(10),
                            Text(
                              "Set as Default",
                              style: textStyle(false, 14,
                                  black.withOpacity(defaultCard ? 1 : 0.6)),
                            ),
                          ],
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
}
