import 'package:Strokes/AppEngine.dart';
import 'package:Strokes/MainAdmin.dart';
import 'package:Strokes/assets.dart';
import 'package:Strokes/basemodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'OfferItem.dart';

class Offer extends StatefulWidget {
  @override
  _OfferState createState() => _OfferState();
}

class _OfferState extends State<Offer> with AutomaticKeepAliveClientMixin {
  final refreshController = RefreshController(initialRefresh: false);
  bool canRefresh = true;

  final pc = PageController();
  int currentPage = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadOffers(false);
  }

  loadOffers(bool isNew) async {
    final startFeedAt = [
      !isNew
          ? (offerLists.isEmpty
              ? DateTime.now().millisecondsSinceEpoch
              : offerLists[offerLists.length - 1].createdAt)
          : (offerLists.isEmpty ? 0 : offerLists[0].createdAt)
    ];

    List local = [];
    Firestore.instance
        .collection(OFFER_BASE)
        .where(SELLER_ID, isEqualTo: userModel.getUserId())
        .limit(10)
        .orderBy(CREATED_AT, descending: !isNew)
        .startAt(startFeedAt)
        .getDocuments()
        .then((value) {
      local = value.documents;
      for (var doc in value.documents) {
        BaseModel model = BaseModel(doc: doc);
        //if (userModel.isMuted(model.getObjectId())) continue;
        int p = offerLists
            .indexWhere((e) => e.getObjectId() == model.getObjectId());
        if (p != -1) {
          offerLists[p] = model;
        } else {
          offerLists.add(model);
        }
      }

      if (isNew) {
        refreshController.refreshCompleted();
      } else {
        int oldLength = offerLists.length;
        int newLength = local.length;
        if (newLength <= oldLength) {
          refreshController.loadNoData();
          canRefresh = false;
        } else {
          refreshController.loadComplete();
        }
      }
      offerSetup = true;
      if (mounted)
        setState(() {
          //myNotifications.sort((a, b) => b.time.compareTo(a.time));
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: white,
      body: page(),
    );
  }

  page() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(

          margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
          color: white,
          child: Card(
            color: black.withOpacity(.2),
    elevation: 0,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25))),
            child: Row(
              children: List.generate(2, (p) {
                String title = p == 0 ? "Sent" : "Recieved";
                bool selected = p == currentPage;
                return Flexible(
                  child: GestureDetector(
                    onTap: () {
                      pc.animateToPage(p,
                          duration: Duration(milliseconds: 500),
                          curve: Curves.ease);
                    },
                    child: Container(
                        margin: EdgeInsets.all(1.5),
                        height: 30,
                        decoration: !selected
                            ? null
                            : BoxDecoration(
                                color: selected ? white : transparent,
//                      border: Border.all(color: black.withOpacity(.1),width: 3),
                                borderRadius: BorderRadius.circular(25)),
                        child: Center(
                            child: Text(
                          title,
                          style: textStyle(true, 14,
                              selected ? black : (white.withOpacity(.7))),
                          textAlign: TextAlign.center,
                        ))),
                  ),
                  fit: FlexFit.tight,
                );
              }),
            ),
          ),
        ),
        Expanded(
            flex: 1,
            child: PageView.builder(
                controller: pc,
                itemCount: 2,
                onPageChanged: (p) {
                  setState(() {
                    currentPage = p;
                  });
                },
                itemBuilder: (c, p) {
                  return OfferItem(p);
                }))
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
