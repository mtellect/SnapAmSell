import 'package:Strokes/AppEngine.dart';
import 'package:Strokes/MainAdmin.dart';
import 'package:Strokes/OfferDialog.dart';
import 'package:Strokes/app/app.dart';
import 'package:Strokes/app/dotsIndicator.dart';
import 'package:Strokes/app_config.dart';
import 'package:Strokes/assets.dart';
import 'package:Strokes/auth/login_page.dart';
import 'package:Strokes/basemodel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  BaseModel theUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    model = widget.model;
    loadUser();
  }

  loadUser() {
    if (widget.model.getUserId().isEmpty) return;
    Firestore.instance
        .collection(USER_BASE)
        .document(widget.model.getUserId())
        .get()
        .then((value) {
      theUser = BaseModel(doc: value);
      model.put(NAME, theUser.getString(NAME));
      model.put(USER_IMAGE, theUser.getString(USER_IMAGE));
//      model.put(NAME, theUser.getString(NAME));
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: modeColor,
      body: page(),
    );
  }

  page() {
    int p = cartLists.indexWhere((e) => e.getObjectId() == model.getObjectId());
    bool isInCart = p != -1;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(top: 35, right: 10, left: 10, bottom: 10),
          child: Row(
            children: [
              BackButton(
                color: white,
                onPressed: () {
                  Navigator.pop(context, "");
                },
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
                      return GestureDetector(
                        onTap: () {
                          pushAndResult(
                              context,
                              ViewImage(
                                  model.images.map((e) => e.imageUrl).toList(),
                                  p),
                              depend: false);
                        },
                        child: CachedNetworkImage(
                          imageUrl: image.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (c, s) {
                            return placeHolder(getScreenHeight(context) * .4,
                                width: double.infinity);
                          },
                        ),
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
                      userImageItem(context, theUser ?? model,
                          size: 60, strokeSize: 1),
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
        if (!model.myItem())
          Container(
            padding: EdgeInsets.all(15),
            child: Row(
              children: [
                FlatButton(
                  onPressed: () {
                    if (!isLoggedIn) {
                      pushAndResult(context, LoginPage(), depend: false);
                      return;
                    }
                    if (null == theUser) return;
                    clickChat(context, theUser, false);
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
                      if (!isLoggedIn) {
                        pushAndResult(context, LoginPage(), depend: false);
                        return;
                      }

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
                FlatButton(
                  onPressed: () {
                    cartController.add(model);
                    setState(() {});
                  },
                  color: isInCart ? red : green,
                  padding: EdgeInsets.all(20),
                  shape: CircleBorder(
                      //borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: black.withOpacity(.7))),
                  child: Image.asset(
                    ic_cart,
                    height: 20,
                    width: 20,
                    color: white,
                  ),
                ),
              ],
            ),
          )
      ],
    );
  }
}
