import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

import 'AddCategory.dart';
import 'AppConfig.dart';
import 'AppEngine.dart';
import 'assets.dart';
import 'basemodel.dart';

class ShowCategories extends StatefulWidget {
  final bool popResult;
  final bool showSub;

  const ShowCategories({Key key, this.popResult = true, this.showSub=false}) : super(key: key);
  @override
  _ShowCategoriesState createState() => _ShowCategoriesState();
}

class _ShowCategoriesState extends State<ShowCategories> {
  final searchController = TextEditingController();
  bool showCancel = false;
  bool searching = false;
  List<BaseModel> result = appSettingsModel.getListModel(CATEGORIES);
  List<BaseModel> appCategories = appSettingsModel.getListModel(CATEGORIES);

  @override
  initState() {
    super.initState();
    searchController.addListener(listener);
    result.sort((a, b) => a.getString(TITLE).compareTo(b.getString(TITLE)));
  }

  listener() async {
    String text = searchController.text.trim().toLowerCase();
    if (text.isEmpty) {
      result = appCategories;
      showCancel = false;
      searching = false;
      result.sort((a, b) => a.getString(TITLE).compareTo(b.getString(TITLE)));
      if (mounted) setState(() {});
      return;
    }
    showCancel = true;
    searching = true;
    if (mounted) setState(() {});

    result = appCategories
        .where((b) => b.getString(TITLE).toLowerCase().startsWith(text))
        .toList();

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
          child: Row(
            children: [
              BackButton(),
              Spacer(),
              if (isAdmin)
                RaisedButton(
                  color: AppConfig.appColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  child: Text(
                    "Add More",
                    style: textStyle(true, 16, black),
                  ),
                  onPressed: () {
                    pushAndResult(context, AddCategory(), result: (_) {
                      appCategories = appSettingsModel.getListModel(CATEGORIES);
                      setState(() {});
                    });
                  },
                ),
              addSpaceWidth(5),
              if (widget.popResult)
                RaisedButton(
                  color: AppConfig.appColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  child: Text(
                    "Select All",
                    style: textStyle(true, 16, black),
                  ),
                  onPressed: () {},
                ),
            ],
          ),
        ),
        addSpace(5),
        Container(
          margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
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
                          hintText: "Search Categories ",
                          border: InputBorder.none),
                    ),
                  ),
                  if (showCancel)
                    GestureDetector(
                      onTap: () {
                        searchController.clear();
                        result = appCategories;
                        showCancel = false;
                        searching = false;
                        result.sort((a, b) =>
                            a.getString(TITLE).compareTo(b.getString(TITLE)));

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
    String categoryName = model.getString(TITLE);
    String sCategories = model.getString(SUB_CATEGORY);
    List subCategories = [];
    if (sCategories.isNotEmpty) subCategories = sCategories.split(',');
    String description = model.getString(DESCRIPTION);
    String category = model.getString(CATEGORY);
    String thumbnail = model.getString(THUMBNAIL_URL);
    String image = getFirstPhoto(model.images);
    bool empty = subCategories.isEmpty;
    return Container(
      padding: EdgeInsets.all(5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                        child: Icon(LineIcons.image),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          addSpaceWidth(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    if (widget.popResult)
                      Navigator.pop(context, [category, '']);
                  },
                  child: Container(
                    padding: EdgeInsets.all(15),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: black.withOpacity(empty ? 0 : 0.1),
                                width: 1))),
                    child: Text.rich(TextSpan(children: [
                      TextSpan(
                          text: categoryName.substring(
                              0, searchController.text.length),
                          style: textStyle(true, 18, black)),
                      TextSpan(
                          text: categoryName
                              .substring(searchController.text.length),
                          style: textStyle(false, 18, black))
                    ])),
                  ),
                ),
                if (subCategories.isNotEmpty && widget.showSub)
                  Container(
                    decoration: BoxDecoration(
                        border: Border(
                            left: BorderSide(
                                color: AppConfig.appColor, width: 2))),
                    //padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(subCategories.length, (p) {
                        return InkWell(
                          onTap: () {
                            if (widget.popResult)
                              Navigator.pop(
                                  context, [category, subCategories[p]]);
                          },
                          child: Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: black.withOpacity(.1),
                                        width: 1))),
                            alignment: Alignment.centerLeft,
                            child: Text.rich(TextSpan(children: [
                              TextSpan(
                                  text: subCategories[p].substring(
                                      0, searchController.text.length),
                                  style: textStyle(true, 18, black)),
                              TextSpan(
                                  text: subCategories[p]
                                      .substring(searchController.text.length),
                                  style: textStyle(false, 18, black))
                            ])),
                          ),
                        );
                      }),
                    ),
                  )
              ],
            ),
          ),
          if (isAdmin)
            IconButton(
              onPressed: () {
                pushAndResult(
                    context,
                    AddCategory(
                      model: model,
                    ), result: (_) {
                  appCategories = appSettingsModel.getListModel(CATEGORIES);
                  setState(() {});
                });
              },
              icon: Icon(Icons.edit),
            )
        ],
      ),
    );
  }
}
