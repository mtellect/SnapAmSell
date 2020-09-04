import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/assets.dart';
import 'package:maugost_apps/main_pages/OfferItem.dart';

import 'OrderItem.dart';

class OfferPage extends StatefulWidget {
  @override
  _OfferPageState createState() => _OfferPageState();
}

class _OfferPageState extends State<OfferPage> {
  final vp = PageController();
  int currentPage = 0;
  List<StreamSubscription> subs = [];

  @override
  initState() {
    super.initState();
  }

  @override
  dispose() {
    for (var s in subs) s?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: page(),
    );
  }

  page() {
    return Column(
      children: [
        Container(
          height: 45,
          width: double.infinity,
          margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: Card(
            color: white,
            elevation: 0,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25)),
                side: BorderSide(color: black.withOpacity(.1), width: .5)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(1, 1, 1, 1),
              child: Row(
                children: List.generate(2, (p) {
                  String title =
                      p == 0 ? "Negotiation" : p == 1 ? "Orders" : "Completed";
                  bool selected = p == currentPage;
                  return Flexible(
                    child: GestureDetector(
                      onTap: () {
                        print(p);
                        vp.jumpToPage(p);
                      },
                      child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                              color: selected ? white : transparent,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                  color: !selected
                                      ? transparent
                                      : black.withOpacity(.1),
                                  width: .5)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
//                              if ((p == 1 && showNewMessageOffer.isNotEmpty) ||
//                                  p == 2 && showNewMessageDot.isNotEmpty)
//                                Container(
//                                  height: 10,
//                                  width: 10,
//                                  decoration: BoxDecoration(
//                                      border: Border.all(color: white),
//                                      shape: BoxShape.circle,
//                                      color: red),
//                                ),
                              Text(
                                title,
                                style: textStyle(selected, 14,
                                    selected ? black : (black.withOpacity(.5))),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )),
                    ),
                    fit: FlexFit.tight,
                  );
                }),
              ),
            ),
          ),
        ),
        Flexible(
            child: PageView(
          controller: vp,
          onPageChanged: (p) {
            currentPage = p;
            setState(() {});
          },
          children: List.generate(2, (p) {
            if (p == 0) return OfferItem();

            return OrderItem();
          }),
        )),
      ],
    );
  }
}
