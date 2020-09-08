import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

import 'AppConfig.dart';
import 'AppEngine.dart';
import 'ChooseProductCategory.dart';
import 'assets.dart';
import 'basemodel.dart';
import 'main_pages/ShowDetails.dart';
import 'main_pages/ShowStore.dart';

class SearchProduct extends StatefulWidget {
  @override
  _SearchProductState createState() => _SearchProductState();
}

class _SearchProductState extends State<SearchProduct> {
  final searchController = TextEditingController();
  List<BaseModel> result = [];
  bool showCancel = false;
  bool searching = false;

  @override
  initState() {
    super.initState();
    searchController.addListener(listener);
    //applySearchFix();
  }

  applySearchFix() {
    print("<<<done>>> fixing!");

    Firestore.instance.collection(USER_BASE).getDocuments().then((value) {
      for (var doc in value.documents) {
        BaseModel model = BaseModel(doc: doc);
        String username = model.getUserName().toLowerCase();
        String name = model.getString(NAME).toLowerCase();
        final search = getSearchString('$username $name');
        String token = model.getString(TOKEN);

        Firestore.instance
            .collection(PRODUCT_BASE)
            .where(USER_ID, isEqualTo: model.getUserId())
            .getDocuments()
            .then((value) {
          for (var doc in value.documents) {
            BaseModel model = BaseModel(doc: doc);
            String title = model.getString(TITLE).toLowerCase();
            String category = model.getString(CATEGORY).toLowerCase();
            final search = getSearchString('$title $category');
            model
              ..put(TOKEN, token)
              ..updateItems(delaySeconds: 2);
          }
        });
      }

      print("doneeeeee");
    });
  }

  listener() async {
    String text = searchController.text.trim().toLowerCase();
    if (text.isEmpty) {
      result.clear();
      showCancel = false;
      searching = false;
      if (mounted) setState(() {});
      return;
    }
    showCancel = true;
    searching = true;
    if (mounted) setState(() {});
    QuerySnapshot shots = await Firestore.instance
        .collection(USER_BASE)
        .where(SEARCH, arrayContains: text.trim())
        .limit(30)
        .getDocuments();

    QuerySnapshot shots2 = await Firestore.instance
        .collection(PRODUCT_BASE)
        .where(SEARCH, arrayContains: text.trim())
        .limit(30)
        .getDocuments();

    final responses = shots.documents;
    responses.addAll(shots2.documents);

    for (var doc in shots.documents) {
      BaseModel model = BaseModel(doc: doc);
      String username = model.getUserName();
      if (username.isEmpty) username = model.get(NAME);
      if (!username.startsWith(text)) continue;
      int p = result.indexWhere((e) => e.getObjectId() == model.getObjectId());
      if (p != -1)
        result[p] = model;
      else
        result.add(model);
    }

    for (var doc in shots2.documents) {
      BaseModel model = BaseModel(doc: doc);
      String category = model.getString(CATEGORY);
      if (!category.startsWith(text)) continue;
      int p = result.indexWhere((e) => e.getObjectId() == model.getObjectId());
      if (p != -1)
        result[p] = model;
      else
        result.add(model);
    }

    searching = false;
    if (mounted) setState(() {});
  }

  @override
  dispose() {
    super.dispose();
    searchController?.removeListener(listener);
    searchController?.dispose();
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
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.only(top: 30, right: 10, left: 10, bottom: 0),
          child: BackButton(),
        ),
        Container(
          margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
          child: Row(
            children: [
              Expanded(
                child: Container(
                    padding: EdgeInsets.only(left: 15, right: 15),
                    decoration: BoxDecoration(
                        color: black.withOpacity(.04),
                        border: Border.all(
                          color: black.withOpacity(.09),
                        ),
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: black.withOpacity(.4),
                          size: 20,
                        ),
                        addSpaceWidth(5),
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            cursorColor: black,
                            decoration: InputDecoration(
                                hintText: "Search ", border: InputBorder.none),
                          ),
                        ),
                        if (showCancel)
                          GestureDetector(
                            onTap: () {
                              searchController.clear();
                              result.clear();
                              showCancel = false;
                              setState(() {});
                            },
                            child: Icon(
                              LineIcons.close,
                              color: black.withOpacity(.5),
                            ),
                          ),
                      ],
                    )),
              ),
              addSpaceWidth(10),
              FlatButton(
                onPressed: () {
                  pushAndResult(context, ChooseProductCategory([]));
                },
                shape: CircleBorder(),
                minWidth: 45,
                padding: EdgeInsets.zero,
                child: Container(
                  child: Center(child: Icon(LineIcons.sort_alpha_desc)),
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: black.withOpacity(.1))),
                ),
              )
            ],
          ),
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: 400),
          child: LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation(orange03),
          ),
          height: searching ? 2 : 0,
          margin: EdgeInsets.only(bottom: searching ? 5 : 0),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(0),
            children: List.generate(result.length, (index) {
              return resultItem(index);
            }),
          ),
        )
      ],
    );
  }

  resultItem(int index) {
    BaseModel model = result[index];
    String username = model.getUserName();
    if (username.isEmpty) username = model.get(NAME);
    bool following = model.followers.contains(userModel.getUserId());
    bool isProduct = model.getString(DATABASE_NAME) == PRODUCT_BASE;

    String description = model.getString(DESCRIPTION);
    String category = model.getString(CATEGORY);
    String thumbnail = model.getString(THUMBNAIL_URL);
    String image = getFirstPhoto(model.images);

    return InkWell(
      onTap: () {
        if (isProduct) {
          pushAndResult(
              context,
              ShowDetails(
                model,
                objectId: model.getObjectId(),
              ),
              depend: false);
          return;
        }

        pushAndResult(
            context,
            ShowStore(
              model,
            ),
            depend: false);
      },
      child: Container(
        padding: EdgeInsets.all(5),
        child: Row(
          children: [
            if (isProduct) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: black.withOpacity(.1))),
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: image,
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                        placeholder: (c, s) {
                          return Container(
                            height: 80,
                            width: 80,
                            color: black.withOpacity(.09),
                            child: Icon(LineIcons.user),
                          );
                        },
                      ),
                      // Container(
                      //   width: double.infinity,
                      //   height: double.infinity,
                      //   color: black.withOpacity(.09),
                      //   child: Center(
                      //     child: Container(
                      //       height: 25,
                      //       width: 25,
                      //       child: Icon(
                      //         Icons.play_arrow,
                      //         color: Colors.white,
                      //         size: 14,
                      //       ),
                      //       decoration: BoxDecoration(
                      //           color: black.withOpacity(0.8),
                      //           border:
                      //               Border.all(color: Colors.white, width: 1.5),
                      //           shape: BoxShape.circle),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
              addSpaceWidth(10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(TextSpan(children: [
                      // TextSpan(
                      //     text: category.substring(
                      //         0, searchController.text.length),
                      //     style: textStyle(true, 14, black)),
                      TextSpan(
                          text: category, style: textStyle(true, 14, black))
                    ])),
                    addSpace(5),
                    Text.rich(
                      TextSpan(children: [
                        TextSpan(
                            text: description.substring(
                                0, searchController.text.length),
                            style: textStyle(true, 15, black)),
                        TextSpan(
                            text: description
                                .substring(searchController.text.length),
                            style: textStyle(false, 15, black.withOpacity(.5)))
                      ]),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: black.withOpacity(.02),
                          border: Border.all(color: black.withOpacity(.0)),
                          borderRadius: BorderRadius.circular(15)),
                      padding: EdgeInsets.all(4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: CachedNetworkImage(
                              imageUrl: model.userImage,
                              height: 20,
                              width: 20,
                              fit: BoxFit.cover,
                              placeholder: (c, s) {
                                return Container(
                                  height: 20,
                                  width: 20,
                                  color: black.withOpacity(.09),
                                  child: Icon(
                                    LineIcons.user,
                                    size: 15,
                                  ),
                                );
                              },
                            ),
                          ),
                          addSpaceWidth(5),
                          Text.rich(TextSpan(children: [
                            TextSpan(
                                text: username,
                                style:
                                    textStyle(false, 14, black.withOpacity(1)))
                          ])),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ] else ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: CachedNetworkImage(
                  imageUrl: model.userImage,
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                  placeholder: (c, s) {
                    return Container(
                      height: 50,
                      width: 50,
                      color: black.withOpacity(.09),
                      child: Icon(LineIcons.user),
                    );
                  },
                ),
              ),
              addSpaceWidth(10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Store",
                      style: textStyle(true, 12, black),
                    ),
                    Text.rich(TextSpan(children: [
                      TextSpan(
                          text: username.substring(
                              0, searchController.text.length),
                          style: textStyle(true, 14, black)),
                      TextSpan(
                          text:
                              username.substring(searchController.text.length),
                          style: textStyle(false, 14, black.withOpacity(.5)))
                    ])),
                  ],
                ),
              ),
              FlatButton(
                onPressed: () {
                  model
                    ..putInList(FOLLOWERS, userModel.getUserId(), !following)
                    ..updateItems();
                  setState(() {});
                },
                color: AppConfig.appColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                  following ? "Following" : "Follow",
                  style: textStyle(true, 14, white),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
