import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/app/app.dart';
import 'package:maugost_apps/assets.dart';

import 'basemodel.dart';

class CreateCategory extends StatefulWidget {
  final BaseModel model;

  const CreateCategory({Key key, this.model}) : super(key: key);
  @override
  _CreateCategoryState createState() => _CreateCategoryState();
}

class _CreateCategoryState extends State<CreateCategory> {
  BaseModel model = BaseModel();
  final categoryName = TextEditingController();
  final subController = TextEditingController();
  int selectedSize = 0;
  List<BaseModel> imagesUrl = [];
  List<BaseModel> options = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.model != null) {
      model = widget.model;
      imagesUrl = model.getListModel(IMAGES);
      categoryName.text = model.getString(TITLE);
      subController.text = model.getString(SUB_CATEGORY);
      final subs = model.getListModel(SUB_CATEGORY);
      if (subs.isNotEmpty) {
        print(subs.length);
        List subNames = List.from(subs.map((e) => e.getString(NAME)).toList());
        // List.generate(subs.length, (index) => subs[index].getString(NAME));
        subController.text = convertListToString(",", subNames);
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  int clickBack = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        int now = DateTime.now().millisecondsSinceEpoch;
        if ((now - clickBack) > 5000) {
          clickBack = now;
          showError("Click back again to exit");
          return false;
        }
        //Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        backgroundColor: white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  EdgeInsets.only(top: 30, right: 10, left: 10, bottom: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BackButton(),
                  Container(
                    margin: EdgeInsets.only(left: 15),
                    child: Text(
                      widget.model != null ? "Update Category" : "New Category",
                      style: textStyle(true, 25, black),
                    ),
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
            addressPage(),
            Container(
              padding: EdgeInsets.all(20),
              child: FlatButton(
                onPressed: handleSave,
                color: black,
                padding: EdgeInsets.all(15),
                child: Center(
                    child: Text(
                  widget.model != null ? "UPDATE" : "SAVE",
                  style: textStyle(false, 18, white),
                )),
              ),
            )
          ],
        ),
      ),
    );
  }

  addressPage() {
    return Flexible(
      child: Container(
        child: ListView(
          padding: EdgeInsets.all(10),
          children: [
            inputTextView("Category Name", categoryName, isNum: false),
            inputTextView("Sub Category", subController,
                isNum: false, maxLine: 10),
            addSpace(10),
            Container(
              decoration: BoxDecoration(
                  color: red, borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.all(10),
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    color: white,
                  ),
                  addSpaceWidth(10),
                  Flexible(
                    child: Text(
                      "Note: For Sub Category,Separate each new category by a comma ",
                      style: textStyle(false, 14, white),
                    ),
                  ),
                ],
              ),
            ),
            imagesView(),
            addSpace(10),
            /* Container(
              decoration: BoxDecoration(
                  color: red, borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.all(10),
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    color: white,
                  ),
                  addSpaceWidth(10),
                  Flexible(
                    child: Text(
                      "Note: This Product will undergo a verification process by our"
                      " support team before publication. Please follow our"
                      " community guidelines.",
                      style: textStyle(false, 14, white),
                    ),
                  ),
                ],
              ),
            ),*/
          ],
        ),
      ),
    );
  }

  sizesView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Available Sizes",
          style: textStyle(true, 14, black),
        ),
        addSpace(10),
        SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(CLOTH_SIZES.length, (index) {
              String value = CLOTH_SIZES[index];
              bool active = selectedSize == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedSize = index;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: black.withOpacity(active ? 1 : 0.09)),
                  child: Text(
                    value,
                    style: textStyle(active, 14, active ? white : black),
                  ),
                ),
              );
            }),
          ),
        )
      ],
    );
  }

  imagesView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Category Icons",
          style: textStyle(true, 14, black),
        ),
        addSpace(10),
        SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(imagesUrl.length, (index) {
                  BaseModel model = imagesUrl[index];
                  String imageUrl = model.imageUrl;
                  String imagePath = model.getString(IMAGE_PATH);
                  bool online = imageUrl.startsWith("http");
                  bool active = 1 == index;
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedSize = index;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(4),
                          margin: EdgeInsets.all(5),
                          height: 120,
                          width: 100,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: black.withOpacity(active ? 1 : 0.09)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: online
                                ? CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    height: 120,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(imagePath),
                                    height: 120,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ),
                      FlatButton(
                        onPressed: () {
                          imagesUrl.remove(model);
                          setState(() {});
                        },
                        color: red,
                        child: Text("REMOVE"),
                      )
                    ],
                  );
                }),
              ),
              //if (imagesUrl.length < 1)
              GestureDetector(
                onTap: () {
                  openGallery(context, onPicked: (_) {
                    if (null == _) return;
                    imagesUrl.addAll(_
                        .map((e) => BaseModel()
                          ..put(IMAGE_PATH, e.file.path)
                          ..put(IS_VIDEO, e.isVideo)
                          ..items)
                        .toList());
                    setState(() {});
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(4),
                  margin: EdgeInsets.all(5),
                  height: 120,
                  width: 100,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: black.withOpacity(0.09)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Icon(LineIcons.plus_circle), Text("Add")],
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  String errorText = "";
  showError(String text, {bool wasLoading = false}) {
    if (wasLoading) showProgress(false, context);
    errorText = text;
    if (mounted) setState(() {});

    Future.delayed(Duration(seconds: 3), () {
      errorText = "";
      if (mounted) setState(() {});
    });
  }

  handleSave() {
    String name = categoryName.text;
    String subText = subController.text;
    List subs = convertStringToList(",", subText);

    if (name.isEmpty) {
      showError("Enter Category Name");
      return;
    }

    if (imagesUrl.isEmpty) {
      showError("Enter Category Image");
      return;
    }

    String categoryId = getRandomId();
    if (widget.model != null) categoryId = widget.model.getObjectId();

    Map map = Map();
    map[NAME] = name;
    subs.sort((a, b) => a.compareTo(b));
    List subList = List.generate(subs.length, (index) {
      return {
        NAME: subs[index],
        CATEGORY: name,
        CATEGORY_ID: categoryId,
        OPTIONS: options.map((e) => e.items).toList()
      };
    });

    showProgress(true, context,
        msg: "${widget.model != null ? "Saving" : "Adding"} Category...");
    List<BaseModel> modelsUploaded = [];
    List<BaseModel> images = this.imagesUrl;
    List categoryItems = appSettingsModel.getList(CATEGORIES);

    saveCategoryImages(images, modelsUploaded, (_) {
      model.put(OBJECT_ID, categoryId);
      model.put(TITLE, name);
      model.put(SUB_CATEGORY, subList);
      model.put(IMAGES, _.map((e) => e.items).toList());
      if (categoryItems.isEmpty) {
        categoryItems.add(model.items);
      } else {
        int p = categoryItems.indexWhere((e) => e[OBJECT_ID] == categoryId);
        if (p != -1) {
          categoryItems[p] = model.items;
        } else {
          categoryItems.add(model.items);
        }
      }
      categoryItems.sort((m1, m2) => m1[TITLE].compareTo(m2[TITLE]));
      appSettingsModel
        ..put(CATEGORIES, categoryItems)
        ..updateItems();
      showProgress(false, context);
      // if (widget.model == null) {
      //   categoryName.clear();
      //   subController.clear();
      //   imagesUrl.clear();
      //   model = BaseModel();
      // }
      categoryName.clear();
      subController.clear();
      imagesUrl.clear();
      model = BaseModel();
      if (mounted) setState(() {});
      showMessage(context, Icons.check, green_dark, "Successful",
          'Category Successfully ${widget.model != null ? "Updated" : "Added"}!',
          cancellable: true, onClicked: (_) {}, delayInMilli: 1200);
    });
  }

  saveCategoryImages(List<BaseModel> models, List<BaseModel> modelsUploaded,
      onCompleted(List<BaseModel> _)) {
    if (models.isEmpty) {
      onCompleted(modelsUploaded);
      return;
    }

    BaseModel model = models[0];
    String imagePath = model.getString(IMAGE_PATH);
    if (imagePath.isEmpty) {
      modelsUploaded.add(model);
      models.removeAt(0);
      saveCategoryImages(models, modelsUploaded, onCompleted);
      return;
    }
    File file = File(model.getString(IMAGE_PATH));
    uploadFile(file, (res, error) {
      if (error != null) {
        saveCategoryImages(models, modelsUploaded, onCompleted);
        return;
      }
      model.put(IMAGE_PATH, "");
      model.put(IMAGE_URL, res);
      modelsUploaded.add(model);
      models.removeAt(0);
      saveCategoryImages(models, modelsUploaded, onCompleted);
    });
  }
}
