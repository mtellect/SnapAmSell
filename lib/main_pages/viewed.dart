import 'package:Strokes/AppEngine.dart';
import 'package:Strokes/assets.dart';
import 'package:Strokes/basemodel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'show_profile.dart';

class ViewedMe extends StatefulWidget {
  final bool iViewed;

  const ViewedMe({Key key, this.iViewed = false}) : super(key: key);
  @override
  _ViewedMeState createState() => _ViewedMeState();
}

class _ViewedMeState extends State<ViewedMe> {
  bool setup = false;
  List<BaseModel> peopleList = [];

  @override
  void initState() {
    super.initState();
    loadViews();
  }

  loadViews() async {
    List seenPeople = userModel.getList(widget.iViewed ? SEEN_PEOPLE : SEEN_BY);
    for (String id in seenPeople) {
      Firestore.instance.collection(USER_BASE).document(id).get().then((value) {
        BaseModel model = BaseModel(doc: value);
        if (!model.signUpCompleted) return;

        int index = peopleList
            .indexWhere((bm) => bm.getObjectId() == model.getObjectId());
        if (index == -1) {
          peopleList.add(model);
        } else {
          peopleList[index] = model;
        }
        if (mounted)
          setState(() {
            setup = true;
          });
      });
    }
    if (mounted)
      setState(() {
        // setup = true;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: page(),
    );
  }

  page() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(0, 40, 0, 10),
          color: white,
          child: Row(
            children: <Widget>[
              InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    child: Center(
                        child: Icon(
                      Icons.keyboard_backspace,
                      color: black,
                      size: 25,
                    )),
                  )),
              Text(
                "Viewed Me",
                style: textStyle(true, 25, black),
              ),
              Spacer()
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: body(),
        )
      ],
    );
  }

  body() {
    if (!setup) return loadingLayout();
    if (peopleList.isEmpty)
      return emptyLayout(Icons.person, "No Views Yet", "");
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
                            shape: BoxShape.circle));
                  },
                ),
              ),
            ),
            Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
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
                                style:
                                    textStyle(false, 11, black.withOpacity(.5)),
                              ),
                      ],
                    ),
                    FlatButton(
                      onPressed: () {
                        clickChat(context, model, false);
                      },
                      padding: EdgeInsets.all(5),
                      shape: RoundedRectangleBorder(
                          side: BorderSide(color: black.withOpacity(.2))),
                      child: Center(
                        child: Text(
                          "Chat Now",
                          style: textStyle(false, 12, black.withOpacity(.7)),
                        ),
                      ),
                    )
                  ],
                )),
          ],
        ),
      ),
    );
  }

  // personItem(int p) {
  //   BaseModel model = peopleList[p];
  //   return GestureDetector(
  //     onTap: () {
  //       pushAndResult(
  //           context,
  //           ShowProfile(
  //             theUser: model,
  //             //fromMeetMe: widget.fromStrock,
  //           ));
  //     },
  //     child: ClipRRect(
  //       borderRadius: BorderRadius.circular(20),
  //       child: Container(
  //         decoration: BoxDecoration(color: white),
  //         child: Column(
  //           //mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Flexible(
  //               child: ClipRRect(
  //                 borderRadius: BorderRadius.circular(20),
  //                 child: CachedNetworkImage(
  //                   imageUrl: model.profilePhotos[0].imageUrl,
  //                   fit: BoxFit.cover,
  //                   width: double.infinity,
  //                   placeholder: (c, s) {
  //                     return Container(
  //                         height: double.infinity,
  //                         width: double.infinity,
  //                         child: Center(
  //                             child: Icon(
  //                           Icons.person,
  //                           color: white,
  //                           size: 15,
  //                         )),
  //                         decoration: BoxDecoration(
  //                             color: black.withOpacity(.09),
  //                             shape: BoxShape.circle));
  //                   },
  //                 ),
  //               ),
  //             ),
  //             Container(
  //                 padding: EdgeInsets.all(5),
  //                 child: Column(
  //                   children: [
  //                     Text(
  //                       model.getString(NAME),
  //                       style: textStyle(true, 16, black),
  //                     ),
  //                     addSpace(5),
  //                     Row(
  //                       mainAxisSize: MainAxisSize.min,
  //                       children: [
  //                         Container(
  //                           height: 8,
  //                           width: 8,
  //                           decoration: BoxDecoration(
  //                               color: green, shape: BoxShape.circle),
  //                         ),
  //                         addSpaceWidth(10),
  //                         Text(
  //                           "Active Now",
  //                           style: textStyle(false, 16, black.withOpacity(.7)),
  //                         ),
  //                       ],
  //                     ),
  //                   ],
  //                 )),
  // FlatButton(
  //   onPressed: () {
  //     clickChat(context, model, false);
  //   },
  //   shape: RoundedRectangleBorder(
  //       side: BorderSide(color: black.withOpacity(.2))),
  //   child: Text(
  //     "Chat Now",
  //     style: textStyle(false, 16, black.withOpacity(.7)),
  //   ),
  // )
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

}
