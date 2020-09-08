import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

import 'AppConfig.dart';
import 'AppEngine.dart';
import 'CreateCategory.dart';
import 'assets.dart';
import 'basemodel.dart';

class ChooseProductCategory extends StatefulWidget {
  final bool showSub, popResult, singleMode, onlyMain;
  final List list;
  final String category;
  final String subCategory;

  const ChooseProductCategory(
    this.list, {
    Key key,
    this.popResult = true,
    this.showSub = false,
    this.singleMode,
    this.onlyMain,
    this.category = '',
    this.subCategory = '',
  }) : super(key: key);
  @override
  _ChooseProductCategoryState createState() => _ChooseProductCategoryState();
}

class _ChooseProductCategoryState extends State<ChooseProductCategory> {
  final searchController = TextEditingController();
  bool showCancel = false;
  bool searching = false;
  List<BaseModel> result = appSettingsModel.getListModel(CATEGORIES);
  List<BaseModel> appCategories = appSettingsModel.getListModel(CATEGORIES);

  String selectedCategory = '';
  String selectedSubCategory = '';

  @override
  initState() {
    super.initState();
    searchController.addListener(listener);
    result.sort((a, b) => a.getString(TITLE).compareTo(b.getString(TITLE)));
    selectedCategory = widget.category;
    selectedSubCategory = widget.subCategory;
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
              //if (isAdmin)
              RaisedButton(
                color: AppConfig.appColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                child: Text(
                  "Add More",
                  style: textStyle(true, 16, black),
                ),
                onPressed: () {
                  pushAndResult(context, CreateCategory(), result: (_) {
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
    final subCategories = model.getListModel(SUB_CATEGORY);
    String description = model.getString(DESCRIPTION);
    String category = model.getString(CATEGORY);
    String thumbnail = model.getString(THUMBNAIL_URL);
    String image = getFirstPhoto(model.images);
    bool empty = subCategories.isEmpty;

    bool selected = selectedCategory == categoryName;

    return GestureDetector(
      onTap: () {
        if (selectedCategory == categoryName) {
          selectedCategory = "";
        } else {
          selectedCategory = categoryName;
        }
        setState(() {});
      },
      onLongPress: () {
        showListDialog(context, ['Edit', 'Delete'], (_) {
          if (_ == 0) {
            pushAndResult(
                context,
                CreateCategory(
                  model: model,
                ), result: (_) {
              appCategories = appSettingsModel.getListModel(CATEGORIES);
              setState(() {});
            });
          }

          if (_ == 1) {
            result.remove(model);
            appCategories.remove(model);
            setState(() {});
            appSettingsModel
              ..put(CATEGORIES, appCategories.map((e) => e.items).toList())
              ..updateItems();
            print(appCategories.length);
          }
        });
      },
      child: Container(
        color: selected ? black.withOpacity(.02) : white,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: transparent,
                  border: Border(
                      bottom: BorderSide(
                          color: black.withOpacity(selected ? 0 : 0.1)))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Container(
                      height: 60,
                      width: 60,
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(60),
                          border:
                              Border.all(color: AppConfig.appColor, width: 2)),
                      child: CachedNetworkImage(
                        imageUrl: image,
                        height: 60,
                        width: 60,
                        alignment: Alignment.center,
                        placeholder: (c, s) {
                          return Container(
                            height: 60,
                            width: 60,
                            color: black.withOpacity(.09),
                            child: Icon(LineIcons.image),
                          );
                        },
                      ),
                    ),
                  ),
                  // addSpaceWidth(10),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(15),
                      alignment: Alignment.centerLeft,
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
                  addSpaceWidth(5),
                  Icon(
                    selected ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    size: 25,
                    color: black.withOpacity(.5),
                  ),
                  addSpaceWidth(10),
                ],
              ),
            ),
            if (subCategories.isNotEmpty && selected)
              Container(
                margin: EdgeInsets.only(left: 30),

                decoration: BoxDecoration(
                    border: Border(
                        left: BorderSide(color: AppConfig.appColor, width: 2))),
                //padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(subCategories.length, (p) {
                    BaseModel subCat = subCategories[p];
                    String name = subCat.getString(NAME);
                    return InkWell(
                      onTap: () {
                        if (widget.popResult)
                          Navigator.pop(context,
                              [categoryName, subCategories[p].getString(NAME)]);
                        //print([category, subCategories[p].getString(NAME)]);
                      },
                      child: Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: black.withOpacity(.1), width: 1))),
                        alignment: Alignment.centerLeft,
                        child: Text.rich(TextSpan(children: [
                          TextSpan(
                              text: name.substring(
                                  0, searchController.text.length),
                              style: textStyle(true, 18, black)),
                          TextSpan(
                              text:
                                  name.substring(searchController.text.length),
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
    );
  }
}
