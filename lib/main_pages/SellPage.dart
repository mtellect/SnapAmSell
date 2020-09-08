import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:maugost_apps/AppConfig.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/ChooseProductCategory.dart';
import 'package:maugost_apps/MainAdmin.dart';
import 'package:maugost_apps/SelectRegion.dart';
import 'package:maugost_apps/assets.dart';
import 'package:maugost_apps/basemodel.dart';
import 'package:maugost_apps/main_pages/SellCamera.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SellPage extends StatefulWidget {
  final List<BaseModel> photos;
  final BaseModel model;
  const SellPage({Key key, this.photos = const [], this.model})
      : super(key: key);
  @override
  _SellPageState createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  BaseModel model = BaseModel();
  String objectId = getRandomId();
  List<BaseModel> photos = [];
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final titleController = TextEditingController();
  final priceController = new MoneyMaskedTextController(
      decimalSeparator: ".", thousandSeparator: ",");

  final descController = TextEditingController();
  String selectedCategory;

  String state = '';
  String city = '';
  String category = '';
  String subCategory = '';
  Map<String, String> specifications = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.model != null) {
      model = widget.model;
      objectId = model.getObjectId();
      photos = widget.model.getListModel(IMAGES);
      titleController.text = model.getString(TITLE);
      priceController.updateValue(model.getDouble(PRICE));
      descController.text = model.getString(DESCRIPTION);
      selectedCategory = model.getString(CATEGORY);
      category = model.getString(CATEGORY);
      subCategory = model.getString(SUB_CATEGORY);
      state = model.getString(STATE);
      city = model.getString(CITY);
      specifications = Map<String, String>.from(model.getMap(SPECIFICATION));
    } else {
      photos = widget.photos;
      model.put(IMAGES, widget.photos.map((e) => e.items).toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: white,
      body: page(),
    );
  }

  List get categoryOptions {
    List catItems = appSettingsModel.getList(CATEGORIES);
    int catIndex = catItems.indexWhere((e) => e[TITLE] == category);
    List options = catItems[catIndex][OPTIONS];

    return options ?? [];
  }

  List get subCategoryOptions {
    if (subCategory.isEmpty && category.isEmpty) return [];
    List catItems = appSettingsModel.getList(CATEGORIES);
    int catIndex = catItems.indexWhere((e) => e[TITLE] == category);
    List subCatItems = catItems[catIndex][SUB_CATEGORY];
    int subCatIndex = subCatItems.indexWhere((e) => e[NAME] == subCategory);
    List options = subCatItems[subCatIndex][OPTIONS];
    return options ?? [];
  }

  List requiredOptions(String sortName) {
    List itemOption = [];
    List optionItems = appSettingsModel.getList(OPTIONS);
    for (var item in optionItems) {
      String name = item[NAME];
      if (name != sortName) continue;
      List items = item[ITEMS];
      itemOption = items.map((e) => e[NAME]).toList();
    }
    return itemOption;
  }

  page() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(top: 35, right: 10, left: 10, bottom: 10),
          child: Row(
            children: [
              BackButton(
                color: black,
              ),
              Text(
                "Sell Item",
                style: textStyle(true, 25, black),
              ),
              Spacer(),
              RaisedButton(
                color: AppConfig.appColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                child: Text(
                  widget.model != null ? "Update" : "Publish",
                  style: textStyle(true, 16, black),
                ),
                onPressed: validateFields,
              )
            ],
          ),
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: 500),
          width: double.infinity,
          height: errorText.isEmpty ? 0 : 40,
          color: red0,
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Center(
              child: Text(
            errorText,
            style: textStyle(true, 16, white),
          )),
        ),
        Flexible(
          child: ListView(
            padding: EdgeInsets.all(0),
            children: [
              photoBox(photos, (p) {
                photos.removeAt(p);
                setState(() {});
              }),
              Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    clickText(
                        "Choose Region",
                        defaultCity.isEmpty && defaultState.isEmpty
                            ? ""
                            : defaultCity.isEmpty
                                ? ""
                                : "${defaultCity.isEmpty ? "" : "$defaultCity in"} $defaultState",
                        () {
                      pushAndResult(
                          context,
                          SelectRegion(
                            selectedRegion: defaultCity,
                            selectedState: defaultState,
                            canSelectOnlyState: true,
                          ), result: (_) async {
                        defaultState = _[0];
                        defaultCity = _[1];
                        SharedPreferences pref =
                            await SharedPreferences.getInstance();
                        pref.setString(DEFAULT_STATE, defaultState);
                        pref.setString(DEFAULT_CITY, defaultCity);
                        setState(() {});
                      });
                    }),
                    clickText(
                        "Choose Category",
                        subCategory.isEmpty && category.isEmpty
                            ? ""
                            : subCategory.isEmpty
                                ? ""
                                : "${category.isEmpty ? "" : "$subCategory in"} $category",
                        () {
                      pushAndResult(
                        context,
                        ChooseProductCategory(
                          [],
                          singleMode: true,
                          onlyMain: true,
                          popResult: true,
                          category: category,
                          subCategory: subCategory,
                        ),
                        result: (List item) {
                          category = item[0] ?? "";
                          subCategory = item[1] ?? "";
                          setState(() {});
                        },
                      );
                    }),
                    ...List.generate(
                      subCategoryOptions.length,
                      (index) {
                        String name = subCategoryOptions[index];

                        List options = requiredOptions(name);

                        return clickText("$name", specifications[name] ?? '',
                            () {
                          showListDialog(context, options, (_) {
                            specifications[name] = options[_];
                            setState(() {});
                          }, title: name);
                        });
                      },
                    ),
                    inputTextView(
                      "Product Title",
                      titleController,
                      isNum: false,
                    ),
                    inputTextView("Product Price", priceController,
                        isNum: true, isAmount: true),
                    inputTextView("Product Description", descController,
                        isNum: false, maxLine: 5),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    color: red, borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(10),
                child: Row(
                  children: [
                    Icon(
                      Icons.info,
                      color: white_color,
                    ),
                    addSpaceWidth(10),
                    Flexible(
                      child: Text(
                        "Note: This Products would be verified by our support team before they would appear and approved if it passes our community guidelines.",
                        style: textStyle(false, 14, white_color),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  photoBox(List<BaseModel> photos, onRemoved) {
    //final hookUpPhotos = theUser.hookUpPhotos;
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(left: 15, right: 15),
          child: Row(
            children: [
              Text(
                "Add Images",
                style: textStyle(true, 14, black.withOpacity(.6)),
              ),
              Spacer(),
              IconButton(
                onPressed: () {
                  pushAndResult(context, SellCamera(), result: (_) {
                    if (null == _) return;
                    photos.addAll(_);
                    setState(() {});
                  }, depend: false);
                },
                icon: Icon(
                  Icons.add_a_photo,
                  color: black,
                  //size: 18,
                ),
              )
            ],
          ),
        ),
        if (photos.isNotEmpty)
          Container(
            height: 250,
            color: black.withOpacity(0.02),
            child: LayoutBuilder(
              builder: (ctx, b) {
                int photoLength = photos.length;
                return Column(
                  children: <Widget>[
                    Flexible(
                      child: ListView.builder(
                          padding: EdgeInsets.all(0),
                          itemCount: photoLength,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (ctx, p) {
                            BaseModel photo = photos[p];
                            bool isVideo = photo.isVideo;
                            String imageUrl = photo
                                .getString(isVideo ? THUMBNAIL_URL : IMAGE_URL);

                            String localUrl = photo.getString(
                                isVideo ? THUMBNAIL_PATH : IMAGE_PATH);

                            bool isLocal = photo.isLocal;
                            return Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.all(8),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: isLocal
                                        ? Image.file(
                                            File(localUrl),
                                            height: 220,
                                            width: 160,
                                            fit: BoxFit.cover,
                                          )
                                        : CachedNetworkImage(
                                            imageUrl: imageUrl,
                                            height: 220,
                                            width: 160,
                                            fit: BoxFit.cover,
                                            placeholder: (ctx, s) {
                                              return placeHolder(200,
                                                  width: 160);
                                            },
                                          ),
                                  ),
                                ),
                                if (isVideo)
                                  Center(
                                    child: Container(
                                      height: 50,
                                      width: 50,
                                      child: Icon(
                                        Icons.play_arrow,
                                        color: Colors.black,
                                      ),
                                      decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.8),
                                          border: Border.all(
                                              color: Colors.black, width: 1.5),
                                          shape: BoxShape.circle),
                                    ),
                                  ),
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Container(
                                    height: 200,
                                    width: 160,
                                    alignment: Alignment.topLeft,
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      margin: EdgeInsets.fromLTRB(5, 25, 0, 0),
                                      width: 30,
                                      height: 30,
                                      child: new RaisedButton(
                                          padding: EdgeInsets.all(0),
                                          elevation: 2,
                                          shape: CircleBorder(),
                                          color: red0,
                                          child: Icon(
                                            Icons.close,
                                            color: white_color,
                                            size: 13,
                                          ),
                                          onPressed: () {
                                            //toast(scaffoldKey, "Removed!");
                                            onRemoved(p);
                                          }),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }

  validateFields() async {
    String title = titleController.text;
    double price = priceController.numberValue;
    String description = descController.text;

    if (photos.isEmpty) {
      showError("Add Product Images!");
      return;
    }

    if (defaultCity.isEmpty || defaultState.isEmpty) {
      showError("Choose Ad Region!");
      return;
    }

    if (category.isEmpty || subCategory.isEmpty) {
      showError("Choose a category!");
      return;
    }

    if (specifications.length != subCategoryOptions.length) {
      for (var v in subCategoryOptions) {
        if (specifications[v] == null) {
          showError("Choose $v!");
          break;
        }
      }

      return;
    }

    if (title.isEmpty) {
      showError("Add Title!");
      return;
    }
    if (price == 0) {
      showError("Add Price!");
      return;
    }
    if (description.isEmpty) {
      showError("Add Description!");
      return;
    }

    final search = getSearchString('$title $selectedCategory');
    model
      ..put(OBJECT_ID, objectId)
      ..put(STATUS, PENDING)
      ..put(IMAGES, photos.map((e) => e.items).toList())
      ..put(CATEGORY, category)
      ..put(SUB_CATEGORY, subCategory)
      ..put(TITLE, title)
      ..put(PRICE, price)
      ..put(DESCRIPTION, description)
      ..put(SEARCH, search)
      ..put(DEFAULT_STATE, defaultState)
      ..put(DEFAULT_CITY, defaultCity)
      ..put(SPECIFICATION, specifications)
      ..saveItem(PRODUCT_BASE, true, document: objectId);
    int p = productLists.indexWhere((e) => e.getObjectId() == objectId);
    if (p != -1) {
      productLists[p] = model;
    } else {
      productLists.add(model);
    }
    productController.add(model);
    Navigator.pop(context);
  }

  String errorText = "";
  showError(String text, {bool wasLoading = false}) {
    if (wasLoading) showProgress(false, context);
    errorText = text;
    setState(() {});
    Future.delayed(Duration(seconds: 3), () {
      errorText = "";
      setState(() {});
    });
  }
}
