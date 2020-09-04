import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/ShowMyProducts.dart';
import 'package:maugost_apps/app/app.dart';
import 'package:maugost_apps/app/sliderWidget.dart';
import 'package:maugost_apps/assets.dart';

import 'MainAdmin.dart';
import 'basemodel.dart';

class AddAds extends StatefulWidget {
  final BaseModel model;

  const AddAds({Key key, this.model}) : super(key: key);
  @override
  _AddAdsState createState() => _AddAdsState();
}

class _AddAdsState extends State<AddAds> {
  BaseModel model = BaseModel();
  final titleController = TextEditingController();
  final urlController = TextEditingController();
  String promoteWhere = "";
  String product = "";
  BaseModel productModel;
  int promoteIndex = -1;
  List<BaseModel> imagesUrl = [];
  int adDays = 1;
  double adsPricePerDay = appSettingsModel.getDouble(ADS_PRICE);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.model != null) {
      model = widget.model;
      imagesUrl = model.getListModel(IMAGES);
      titleController.text = model.getString(TITLE);
      urlController.text = model.getString(ADS_URL);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(top: 30, right: 10, left: 10, bottom: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BackButton(),
                Container(
                  margin: EdgeInsets.only(left: 15),
                  child: Text(
                    widget.model != null ? "Update Ads" : "New Ads",
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
                widget.model != null
                    ? "UPDATE"
                    : "PROMOTE" +
                        " (\$${(adsPricePerDay * adDays).roundToDouble()})",
                style: textStyle(false, 18, white),
              )),
            ),
          )
        ],
      ),
    );
  }

  addressPage() {
    return Flexible(
      child: Container(
        child: ListView(
          padding: EdgeInsets.all(10),
          children: [
            clickText("Promote Where?", promoteWhere, () {
              showListDialog(context, PROMOTE_TYPE, (_) {
                promoteWhere = PROMOTE_TYPE[_];
                promoteIndex = _;
                if (_ != 1) {
                  productModel = null;
                  product = '';
                }
                setState(() {});
              });
            }),
            if (promoteIndex == 1)
              clickText("Choose Product", product, () {
                pushAndResult(context, ShowMyProducts(), result: (BaseModel _) {
                  productModel = _;
                  product = _.getString(TITLE);
                  setState(() {});
                });
              }),
            inputTextView("Ads Title", titleController, isNum: false),
            if (promoteIndex == 2)
              inputTextView(
                "Website Address",
                urlController,
                isNum: false,
              ),
            imagesView(),
            addSpace(10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "How many days would you like the Ad to Run?",
                  style: textStyle(false, 12, black.withOpacity(.8)),
                ),
                addSpace(4),
                SliderWidget(
                  max: 30,
                  min: 1,
                  fullWidth: true,
                  callBack: (v) {
                    setState(() {
                      adDays = v;
                    });
                  },
                ),
              ],
            ),
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
                      "Note: This Ads will undergo a verification process by our"
                      " support team before publication. Please follow our"
                      " community guidelines.",
                      style: textStyle(false, 14, white),
                    ),
                  ),
                ],
              ),
            ),
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
              bool active = promoteIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    promoteIndex = index;
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
          "Category Images",
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
                            promoteIndex = index;
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
              if (imagesUrl.length < 1)
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
    setState(() {});
    Future.delayed(Duration(seconds: 3), () {
      errorText = "";
      setState(() {});
    });
  }

  handleSave() async {
    FocusScope.of(context).requestFocus(FocusNode());
    String title = titleController.text;
    String urlLink = urlController.text.toLowerCase();

    var result = await (Connectivity().checkConnectivity());
    if (result == ConnectivityResult.none) {
      showError("No internet connectivity");
      return;
    }

    if (promoteIndex == -1) {
      showError("Promote Ads Where?");
      return;
    }

    if (promoteIndex == 1 && null == productModel) {
      showError("Choose a Product to Promote?");
      return;
    }

    if (title.isEmpty) {
      showError("Add Title to Ads");
      return;
    }

    if (promoteIndex == 2 && urlLink.isEmpty) {
      showError("Add WebAddress to Ads");
      return;
    }

    if (promoteIndex == 2 && !urlLink.startsWith("http")) {
      showError("Web Address must start with http");
      return;
    }

    if (imagesUrl.isEmpty) {
      showError("Add Advert Image");
      return;
    }

    model.put(HAS_PAID, false);
    model.put(TITLE, title);
    model.put(ADS_URL, urlLink);
    model.put(PROMOTE_WHERE, promoteWhere);
    model.put(PROMOTE_INDEX, promoteIndex);
    if (productModel != null) {
      model.put(PRODUCT_ID, productModel.getObjectId());
      model.put(PRICE, productModel.getDouble(PRICE));
      model.put(TITLE, productModel.getString(TITLE));
      model.put(DESCRIPTION, productModel.getString(DESCRIPTION));
      model.put(IMAGES, productModel.getList(IMAGES));
    }
    model.put(ADS_DAYS, adDays);
    model.put(STATUS, isAdmin ? APPROVED : PENDING);

    double accountBal = userModel.getDouble(ESCROW_BALANCE);
    double adsAmount = adsPricePerDay * adDays;
    double leftOver = accountBal - adsAmount;

    if (!isAdmin && accountBal == 0 || leftOver.isNegative) {
      showMessage(
          context,
          Icons.warning,
          red,
          "Insufficient Funds",
          "Oops! You do not have sufficient"
              " funds in your wallet. Please"
              " add funds to your wallet to proceed.",
          clickYesText: "Fund Wallet", onClicked: (_) {
        if (_)
          fundWallet(context, onProcessed: () {
            setState(() {});
          });
      });
      return;
    }

    showProgress(true, context,
        msg: "${widget.model != null ? "Saving" : "Adding"} Ads...");
    List<BaseModel> modelsUploaded = [];
    List<BaseModel> images = this.imagesUrl;

    saveCategoryImages(images, modelsUploaded, (_) {
      String id = getRandomId();
      if (widget.model != null) id = widget.model.getObjectId();
      model.put(OBJECT_ID, id);
      model.put(IMAGES, _.map((e) => e.items).toList());
      int p = adsList.indexWhere((e) => e.getObjectId() == id);
      if (p != -1) {
        adsList[p] = model;
      } else {
        adsList.add(model);
      }

      if (widget.model != null)
        model.updateItems();
      else
        model.saveItem(ADS_BASE, true, document: id);

      showProgress(false, context);
      promoteWhere = '';
      promoteIndex = -1;
      titleController.clear();
      urlController.clear();
      imagesUrl.clear();
      setState(() {});
      showMessage(context, Icons.check, green_dark, "Successful",
          'Ads Successfully ${widget.model != null ? "Updated" : "Added"}!',
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
