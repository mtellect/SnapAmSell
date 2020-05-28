import 'package:Strokes/AppEngine.dart';
import 'package:Strokes/MainAdmin.dart';
import 'package:Strokes/app/app.dart';
import 'package:Strokes/app_config.dart';
import 'package:Strokes/assets.dart';
import 'package:Strokes/basemodel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'ShowProduct.dart';

class MyProfile extends StatefulWidget {
  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
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
                "My Profile",
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
                      imageHolder(60, userModel.imageUrl,
                          stroke: 1, strokeColor: white),
                      Text(
                        userModel.getString(NAME),
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
            addSpace(10),
            Container(
              //height: 40,
              padding: EdgeInsets.all(10),
              alignment: Alignment.centerLeft,
              color: white.withOpacity(.02),
              child: Text(
                "Products",
                style: textStyle(true, 20, white),
              ),
            ),
            Builder(
              builder: (ctx) {
                if (!myProductSetup) loadingLayout();
                if (myProducts.isEmpty)
                  return Container(
                    height: getScreenHeight(context) * .5,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Image.asset(
                              ic_product,
                              width: 50,
                              height: 50,
                              color: AppConfig.appColor,
                            ),
                            Text(
                              "No Product Yet",
                              style: textStyle(true, 20, white),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                      childAspectRatio: 0.65),
                  itemBuilder: (c, p) {
                    BaseModel model = myProducts[p];
                    return shopItem(context, model);
                  },
                  itemCount: myProducts.length,
                  padding: EdgeInsets.all(7),
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                );
              },
            )
          ],
        ))
      ],
    );
  }
}

shopItem(BuildContext context, BaseModel model) {
  String image = getFirstPhoto(model.images);
  String category = model.getString(CATEGORY);
  String title = model.getString(TITLE);
  double price = model.getDouble(PRICE);
  return GestureDetector(
    onTap: () {
      pushAndResult(context, ShowProduct(model), depend: false);
    },
    child: ClipRRect(
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
    ),
  );
}
