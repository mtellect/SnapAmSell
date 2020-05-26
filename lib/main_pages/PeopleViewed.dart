import 'package:Strokes/AppEngine.dart';
import 'package:Strokes/assets.dart';
import 'package:Strokes/basemodel.dart';
import 'package:Strokes/main_pages/show_profile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PeopleViewed extends StatefulWidget {
  @override
  _PeopleViewedState createState() => _PeopleViewedState();
}

class _PeopleViewedState extends State<PeopleViewed>
    with AutomaticKeepAliveClientMixin {
  List peopleList = [];
  bool setup = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadItems();
  }

  loadItems() async {
    List ids = userModel.getList(VIEWED_LIST);
    for (String id in ids) {
      DocumentSnapshot doc =
          await Firestore.instance.collection(USER_BASE).document(id).get();
      BaseModel model = BaseModel(doc: doc);
      if (!model.signUpCompleted) continue;
      int index = peopleList
          .indexWhere((bm) => bm.getObjectId() == model.getObjectId());
      if (index == -1) {
        peopleList.add(model);
      }
    }

    setup = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: page(),
    );
  }

  page() {
    if (!setup) return loadingLayout();
    if (peopleList.isEmpty)
      return emptyLayout(Icons.person, "Nothing to Display", "");
    return Container(
        child: GridView.builder(
      itemBuilder: (c, p) {
        return personItem(p);
      },
      shrinkWrap: true,
      itemCount: peopleList.length,
      padding: EdgeInsets.only(top: 10, right: 5, left: 5, bottom: 40),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5),
    ));
  }

  personItem(int p) {
    BaseModel model = peopleList[p];
    return GestureDetector(
      onTap: () {
        pushAndResult(
            context,
            ShowProfile(
              theUser: model,
              //fromMeetMe: widget.fromStrock,
            ));
      },
      child: Card(
        color: white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CachedNetworkImage(
                  imageUrl: model.profilePhotos[0].imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  //height: 100,
                  placeholder: (c, s) {
                    return Container(
                        height: double.infinity,
                        width: double.infinity,
                        child: Center(
                            child: Icon(
                          Icons.person,
                          color: white,
                          size: 15,
                        )),
                        decoration: BoxDecoration(
                          color: black.withOpacity(.09),
                          //shape: BoxShape.circle
                        ));
                  },
                ),
              ),
            ),
            Container(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(
                        getFirstName(model),
                        style: textStyle(true, 14, black),
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    addSpaceWidth(5),
                    isOnline(model)
                        ? Container(
                            height: 8,
                            width: 8,
                            decoration: BoxDecoration(
                                color: green, shape: BoxShape.circle),
                          )
                        : Text(
                            getMyAge(model).toString(),
                            style: textStyle(false, 12, black.withOpacity(.5)),
                          ),
                    /*addSpace(5),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 8,
                          width: 8,
                          decoration: BoxDecoration(
                              color: green, shape: BoxShape.circle),
                        ),
                        addSpaceWidth(10),
                        Text(
                          "Active Now",
                          style: textStyle(false, 16, black.withOpacity(.7)),
                        ),
                      ],
                    ),*/
                  ],
                ))
          ],
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
