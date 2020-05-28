import 'package:Strokes/AppEngine.dart';
import 'package:Strokes/MainAdmin.dart';
import 'package:Strokes/OfferDialog.dart';
import 'package:Strokes/app/app.dart';
import 'package:Strokes/app/dotsIndicator.dart';
import 'package:Strokes/app_config.dart';
import 'package:Strokes/assets.dart';
import 'package:Strokes/basemodel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ShowProduct extends StatefulWidget {
  final BaseModel model;

  const ShowProduct(this.model);
  @override
  _ShowProductState createState() => _ShowProductState();
}

class _ShowProductState extends State<ShowProduct> {
  BaseModel model;
  final vp = PageController();
  int currentPage = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    model = widget.model;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: modeColor,
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
                color: white,
              ),
              Text(
                "Product",
                style: textStyle(true, 25, white),
              ),
              Spacer(),
            ],
          ),
        ),
        Flexible(
            child: ListView(
          padding: EdgeInsets.all(0),
          children: [
            Container(
              height: getScreenHeight(context) * .4,
              margin: EdgeInsets.all(15),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: white.withOpacity(.05),
                  border: Border.all(color: black.withOpacity(.09)),
                  borderRadius: BorderRadius.circular(10)),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  PageView.builder(
                    controller: vp,
                    onPageChanged: (p) {
                      setState(() {
                        currentPage = p;
                      });
                    },
                    itemCount: model.images.length,
                    itemBuilder: (c, p) {
                      final image = model.images[p];
                      return CachedNetworkImage(
                        imageUrl: image.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (c, s) {
                          return placeHolder(getScreenHeight(context) * .4,
                              width: double.infinity);
                        },
                      );
                    },
                  ),
                  Container(
                    padding: EdgeInsets.all(1),
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: black.withOpacity(.7)),
                    child: new DotsIndicator(
                      dotsCount: model.images.length,
                      position: currentPage,
                      decorator: DotsDecorator(
                        size: const Size.square(5.0),
                        color: white,
                        activeColor: AppConfig.appColor,
                        activeSize: const Size(10.0, 7.0),
                        activeShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            addSpace(10),
            Container(
              //height: 40,
              padding: EdgeInsets.all(15),
              alignment: Alignment.centerLeft,
              //color: white.withOpacity(.02),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.getString(TITLE),
                        style: textStyle(true, 22, white),
                      ),
                      Text(
                        model.getString(CATEGORY),
                        style: textStyle(true, 12, white.withOpacity(.7)),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: black,
                            borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.all(3),
                        child: Row(
                          children: [
                            Icon(
                              Icons.visibility,
                              size: 13,
                              color: white,
                            ),
                            addSpaceWidth(5),
                            Text(
                              "15k Views",
                              style: textStyle(true, 12, white.withOpacity(.7)),
                            ),
                          ],
                        ),
                      ),
                      StarRating(
                        rating: 5,
                        size: 16,
                        color: AppConfig.appColor,
                        borderColor: white,
                      ),
                    ],
                  ),
                  Spacer(),
                  Container(
                    decoration: BoxDecoration(
                        color: AppConfig.appColor,
                        borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "\$${model.getDouble(PRICE)}",
                      style: textStyle(true, 22, white),
                    ),
                  ),
                ],
              ),
            ),
            addSpace(10),
            Container(
              //height: 40,
              padding: EdgeInsets.all(10),
              alignment: Alignment.centerLeft,
              color: white.withOpacity(.02),
              child: Text(
                "Description",
                style: textStyle(true, 16, white),
              ),
            ),
            addSpace(10),
            Container(
              //height: 40,
              padding: EdgeInsets.all(15),
              alignment: Alignment.centerLeft,
              //color: white.withOpacity(.02),
              child: Text(
                model.getString(DESCRIPTION),
                style: textStyle(false, 18, white),
              ),
            ),
            addSpace(10),
            Container(
              //height: 40,
              padding: EdgeInsets.all(10),
              alignment: Alignment.centerLeft,
              color: white.withOpacity(.02),
              child: Text(
                "Seller",
                style: textStyle(true, 16, white),
              ),
            ),
            addSpace(10),
            Container(
              margin: EdgeInsets.all(15),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: white.withOpacity(.05),
                  border: Border.all(color: black.withOpacity(.09)),
                  borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Column(
                    children: [
                      imageHolder(60, model.imageUrl,
                          stroke: 1, strokeColor: white),
                      Text(
                        model.getString(NAME),
                        style: textStyle(false, 16, white),
                      ),
                      StarRating(
                        rating: 5,
                        size: 16,
                        color: AppConfig.appColor,
                        borderColor: white,
                      ),
                      addSpace(5),
                      Row(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 15,
                                color: white,
                              ),
                              addSpaceWidth(2),
                              Text(
                                "Buyer",
                                style: textStyle(false, 13, white),
                              ),
                            ],
                          ),
                          addSpaceWidth(10),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: 10,
                                width: 10,
                                decoration: BoxDecoration(
                                    color: dark_green0, shape: BoxShape.circle),
                              ),
                              addSpaceWidth(2),
                              Text(
                                "Active",
                                style: textStyle(false, 13, white),
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                  Spacer(),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: white, width: 2),
                        color: black.withOpacity(.9),
                        borderRadius: BorderRadius.circular(15)
                        //shape: BoxShape.circle
                        ),
                    padding: EdgeInsets.all(5),
                    //height: 70,
                    //width: 70,
                    alignment: Alignment.center,
                    child: Row(
                        children: List.generate(3, (p) {
                      String title = "likes";
                      var icon = Icons.favorite;

                      if (p == 1) {
                        title = "Views";
                        icon = Icons.visibility;
                      }

                      if (p == 2) {
                        title = "Stars";
                        icon = Icons.star;
                      }

                      return Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              icon,
                              size: 18,
                              color: white,
                            ),
                            addSpace(5),
                            Text(
                              "15 $title",
                              style: textStyle(false, 13, white),
                            ),
                          ],
                        ),
                      );
                    })),
                  ),
                  addSpaceWidth(10),
                ],
              ),
            ),
            addSpace(20),
          ],
        )),
        Container(
          padding: EdgeInsets.all(15),
          child: Row(
            children: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                color: white,
                padding: EdgeInsets.all(20),
                shape: CircleBorder(
                    //borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: black.withOpacity(.7))),
                child: Image.asset(
                  ic_chat1,
                  height: 20,
                  width: 20,
                ),
              ),
              Flexible(
                child: FlatButton(
                  onPressed: () {
                    pushAndResult(context, OfferDialog(model), depend: false);
                  },
                  color: AppConfig.appColor,
                  padding: EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: white)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        ic_offer,
                        height: 22,
                        width: 22,
                        color: white,
                      ),
                      addSpaceWidth(10),
                      Text(
                        "Make Offer",
                        style: textStyle(true, 18, white),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  shopItem(BuildContext context, BaseModel model) {
    String image = getFirstPhoto(model.images);
    String category = model.getString(CATEGORY);
    String title = model.getString(TITLE);
    double price = model.getDouble(PRICE);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: white.withOpacity(0.1), width: 2)),
        child: Stack(
          //fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: image,
              fit: BoxFit.cover,
              height: double.infinity,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.all(8),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15), color: white),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text.rich(TextSpan(children: [
                        TextSpan(
                            text: "Category ",
                            style: textStyle(false, 12, black.withOpacity(.5))),
                        TextSpan(
                            text: category, style: textStyle(false, 12, black)),
                      ])),
                      addSpace(2),
                      Text(
                        title,
                        style: textStyle(false, 16, black),
                      ),
                      addSpace(2),
                      FlatButton(
                        onPressed: () {},
                        color: AppConfig.appColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: white)),
                        child: Center(
                          child: Text.rich(TextSpan(children: [
                            TextSpan(
                                text: "SHOP ",
                                style: textStyle(
                                    false, 12, white.withOpacity(.5))),
                            TextSpan(
                                text: "\$$price",
                                style: textStyle(true, 14, white)),
                          ])),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Container(
                decoration: BoxDecoration(color: white, shape: BoxShape.circle),
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(8),
                child: Icon(
                  Icons.favorite,
                  size: 17,
                  color: black.withOpacity(.7),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
