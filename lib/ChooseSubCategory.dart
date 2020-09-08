import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/CreateOption.dart';
import 'package:maugost_apps/CreateSubCategory.dart';

import 'assets.dart';
import 'basemodel.dart';

class ChooseSubCategory extends StatefulWidget {
  List selections;
  ChooseSubCategory(this.selections);
  @override
  _ChooseSubCategoryState createState() => _ChooseSubCategoryState();
}

class _ChooseSubCategoryState extends State<ChooseSubCategory> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController searchController = TextEditingController();

  bool setup = false;
  bool showCancel = false;
  FocusNode focusSearch = FocusNode();
  List allItems = [];
  List items = [];
  List selections;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selections = widget.selections;
    List catItems = appSettingsModel.getList(CATEGORIES);
    allItems = orderedList;
    allItems.sort((m1, m2) => m1[CATEGORY].compareTo(m2[CATEGORY]));
    reload();
  }

  List get orderedList {
    List subCategories = [];
    for (var model in appSettingsModel.getListModel(CATEGORIES)) {
      String title = model.getString(TITLE);
      List<BaseModel> subCatsItem = model.getListModel(SUB_CATEGORY);
      for (var subModel in subCatsItem) {
        String name = subModel.getString(NAME);
        subModel.put(CATEGORY, title);
        subModel.put(CATEGORY_ID, model.getObjectId());
        subCategories.add(subModel.items);
      }
    }
    return subCategories;
  }

  reload() {
    String search = searchController.text.trim().toLowerCase();
    items.clear();
    for (Map item in allItems) {
      if (search.isNotEmpty) {
        List values = item.values.toList();
        bool exist = false;
        for (var a in values) {
          if (a.toString().toLowerCase().contains(search)) {
            exist = true;
            break;
          }
        }
        if (!exist) continue;
      }
      items.add(item);
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, selections);
        return;
      },
      child: Scaffold(
        body: page(),
        backgroundColor: white,
        key: _scaffoldKey,
      ),
    );
  }

  page() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        addSpace(40),
        Row(
          children: <Widget>[
            InkWell(
                onTap: () {
                  Navigator.pop(context, selections);
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
            Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Text(
                  "Sub Categories",
                  style: textStyle(true, 25, blue3),
                )),
            addSpaceWidth(10),
            FlatButton(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                color: red0,
                onPressed: () {
                  pushAndResult(context, CreateOption(), result: (_) {
                    //allItems.add(_);
                    reload();
                  });
                },
                child: Text(
                  "Create",
                  style: textStyle(true, 14, white),
                )),
            addSpaceWidth(20),
          ],
        ),
        addSpace(5),
        Container(
          height: 45,
          margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
          decoration: BoxDecoration(
              color: white.withOpacity(.8),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: black.withOpacity(.1), width: 1)),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            //mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              addSpaceWidth(10),
              Icon(
                Icons.search,
                color: blue3.withOpacity(.5),
                size: 17,
              ),
              addSpaceWidth(10),
              new Flexible(
                flex: 1,
                child: new TextField(
                  textInputAction: TextInputAction.search,
                  textCapitalization: TextCapitalization.sentences,
                  autofocus: false,
                  onSubmitted: (_) {
                    //reload();
                  },
                  decoration: InputDecoration(
                      hintText: "Search",
                      hintStyle: textStyle(
                        false,
                        18,
                        blue3.withOpacity(.5),
                      ),
                      border: InputBorder.none,
                      isDense: true),
                  style: textStyle(false, 16, black),
                  controller: searchController,
                  cursorColor: black,
                  cursorWidth: 1,
                  focusNode: focusSearch,
                  keyboardType: TextInputType.text,
                  onChanged: (s) {
                    showCancel = s.trim().isNotEmpty;
                    setState(() {});
                    reload();
                  },
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    focusSearch.unfocus();
                    showCancel = false;
                    searchController.text = "";
                  });
                  reload();
                },
                child: showCancel
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                        child: Icon(
                          Icons.close,
                          color: black,
                          size: 20,
                        ),
                      )
                    : new Container(),
              )
            ],
          ),
        ),
        Expanded(
            child: ListView.builder(
          itemBuilder: (c, p) {
            Map item = items[p];
            BaseModel model = BaseModel(items: item);
            String category = model.getString(CATEGORY);
            String categoryId = model.getString(CATEGORY_ID);
            String displayName = model.getString(NAME);
            List subItems = model.getList(OPTIONS);
            List catItems = appSettingsModel.getList(CATEGORIES);
            int catIndex =
                catItems.indexWhere((e) => e[OBJECT_ID] == categoryId);
            List subCatItems = catItems[catIndex][SUB_CATEGORY];
            bool multiple = model.getBoolean(MULTIPLE);
            bool selected = selections.contains(category);
            int subCatIndex =
                subCatItems.indexWhere((e) => e[NAME] == displayName);
            bool hasSub = subCatIndex != -1;

            print(hasSub);

            return GestureDetector(
              onTap: () {
                if (!selections.contains(category)) {
                  selections.add(category);
                } else {
                  selections.remove(category);
                }
                setState(() {});
              },
              onLongPress: () {
                print(hasSub);

                showListDialog(
                  context,
                  ["Edit", "Delete"],
                  (int x) {
                    if (x == 0) {
                      pushAndResult(context, CreateSubCategory(p, item: item),
                          result: (_) {
                        int index = allItems.indexWhere((m) => m == item);
                        if (index != -1) allItems[index] = _;

                        int index1 = items.indexWhere((m) => m == item);
                        if (index1 != -1) items[index1] = _;

                        if (hasSub) {
                          //TODO update the sub category in the list
                          subCatItems[subCatIndex] = _;
                          //TODO update the app category
                          catItems[catIndex][SUB_CATEGORY] = subCatItems;
                          appSettingsModel.put(CATEGORIES, catItems);
                          appSettingsModel.updateItems();
                        }
                        setState(() {});
                      });
                    }
                    if (x == 1) {
                      yesNoDialog(context, "Delete?", "Delete This?", () {
                        items.remove(item);
                        allItems.remove(item);

                        if (hasSub) {
                          //TODO update the sub category in the list
                          subCatItems.removeAt(subCatIndex);
                          //TODO update the app category
                          catItems[catIndex][SUB_CATEGORY] = subCatItems;
                          appSettingsModel.put(CATEGORIES, catItems);
                          //appSettingsModel.updateItems();
                        }

                        setState(() {});
                      });
                    }
                  },
                );
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                    border: Border.all(color: black.withOpacity(.1), width: .5),
                    color: blue09),
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: <Widget>[
                    addSpaceWidth(5),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: textStyle(true, 18, blue3),
                          ),
                          addSpace(10),
                          nameItem("Unique Name", category),
                          nameItem("Items", subItems.toString()),
                          nameItem("Multi Selection", multiple.toString()),
                        ],
                      ),
                      flex: 1,
                      fit: FlexFit.tight,
                    ),
                    addSpaceWidth(10),
                    //checkBox(selected),
//                 addSpaceWidth(10)
                  ],
                ),
              ),
            );
          },
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.all(0),
          itemCount: items.length,
        )),
        // Container(
        //   width: double.infinity,
        //   height: 50,
        //   child: FlatButton(
        //       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        //       shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(0)),
        //       color: blue3,
        //       onPressed: () {
        //         Navigator.pop(context, selections);
        //       },
        //       child: Text(
        //         "Select",
        //         style: textStyle(true, 18, white),
        //       )),
        // ),
      ],
    );
  }
}
