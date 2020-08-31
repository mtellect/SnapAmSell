import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:maugost_apps/AppConfig.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/MainAdmin.dart';
import 'package:maugost_apps/ShowCategories.dart';
import 'package:maugost_apps/assets.dart';
import 'package:maugost_apps/basemodel.dart';
import 'package:maugost_apps/main_pages/SellCamera.dart';

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
  List<BaseModel> photos = [];
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final descController = TextEditingController();
  String selectedCategory;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.model != null) {
      model = widget.model;
      photos = widget.model.getListModel(IMAGES);
      titleController.text = model.getString(TITLE);
      priceController.text = model.getDouble(PRICE).toString();
      descController.text = model.getString(DESCRIPTION);
      selectedCategory = model.getString(CATEGORY);
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
                widget.model != null ? "Edit Product" : "Sell Product",
                style: textStyle(true, 25, black),
              ),
              Spacer(),
              RaisedButton(
                color: AppConfig.appColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                child: Text(
                  "Publish",
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
              categoryBox("Choose Category", selectedCategory, (s) {
                selectedCategory = s;
                setState(() {});
              }),
              textFieldBox(titleController, "Product Title", (v) => null),
              textFieldBox(priceController, "Product Price", (v) => null,
                  number: true),
              textFieldBox(descController, "Product Description", (v) => null,
                  maxLines: 4),
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

  textFieldBox(
      TextEditingController controller, String hint, setState(String v),
      {focusNode, int maxLength, int maxLines, bool number = false}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: TextFormField(
        focusNode: focusNode,
        maxLength: maxLength,
        maxLines: maxLines,
        //maxLengthEnforced: false,
        controller: controller,
        cursorColor: black,
        style: textStyle(false, 16, black),
        decoration: InputDecoration(
            fillColor: black.withOpacity(.05),
            filled: true,
            labelText: hint,
            labelStyle: textStyle(false, 16, black.withOpacity(.4)),
            counter: Container(),
            border: InputBorder.none),
        onChanged: setState,
        keyboardType: number ? TextInputType.number : null,
      ),
    );
  }

  categoryBox(String hint, String value, setState) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              pushAndResult(context, ShowCategories(), result: (BaseModel _) {
                if (null == _) return;
                setState(_.getString(TITLE));
              });
            },
            child: Container(
                decoration: BoxDecoration(
                    color: black.withOpacity(.05),
                    border: Border.all(color: black.withOpacity(.05)),
                    borderRadius: BorderRadius.circular(5)),
                padding: EdgeInsets.all(16),
                alignment: Alignment.centerRight,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        value ?? hint,
                        style: textStyle(false, 20,
                            black.withOpacity(value == null ? 0.6 : 1)),
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down_circle,
                      color: black.withOpacity(0.5),
                    )
                  ],
                )),
          ),
        ],
      ),
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
    String price = priceController.text;
    String description = descController.text;

    if (photos.isEmpty) {
      showError("Add Product Images!");
      return;
    }

    if (null == selectedCategory) {
      showError("Choose a category!");
      return;
    }
    if (title.isEmpty) {
      showError("Add Title!");
      return;
    }
    if (price.isEmpty) {
      showError("Add Price!");
      return;
    }
    if (description.isEmpty) {
      showError("Add Description!");
      return;
    }

    String id = getRandomId();

    final search = getSearchString('$title $selectedCategory');
    model
      ..put(OBJECT_ID, id)
      ..put(STATUS, PENDING)
      ..put(IMAGES, photos.map((e) => e.items).toList())
      ..put(CATEGORY, selectedCategory)
      ..put(TITLE, title)
      ..put(PRICE, double.parse(price))
      ..put(DESCRIPTION, description)
      ..put(SEARCH, search)
      ..saveItem(PRODUCT_BASE, true, document: id);
    int p = productLists.indexWhere((e) => e.getObjectId() == id);
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
