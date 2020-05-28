import 'package:Strokes/AppEngine.dart';
import 'package:Strokes/MainAdmin.dart';
import 'package:Strokes/app_config.dart';
import 'package:Strokes/assets.dart';
import 'package:Strokes/basemodel.dart';
import 'package:flutter/material.dart';

import 'MyProfile.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
        Row(
          children: [
            Flexible(
              child: Container(
                height: 45,
                margin: EdgeInsets.fromLTRB(20, 15, 0, 10),
                decoration: BoxDecoration(
                    color: white.withOpacity(.1),
                    borderRadius: BorderRadius.circular(25),
                    border:
                        Border.all(color: white.withOpacity(0.2), width: 1)),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    addSpaceWidth(10),
                    Icon(
                      Icons.search,
                      color: white.withOpacity(.5),
                      size: 17,
                    ),
                    addSpaceWidth(10),
                    Text(
                      "Search products on Fetish",
                      style: textStyle(false, 19, white.withOpacity(.6)),
                    )
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                showListDialog(
                    context, ["All", "Cosmetics", "Free", "Others"], (p) {});
              },
              icon: Icon(
                Icons.dashboard,
                color: white,
              ),
            )
          ],
        ),
        Flexible(
          child: Builder(
            builder: (ctx) {
              if (!productSetup) loadingLayout();
              if (productLists.isEmpty)
                return Center(
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
                          style: textStyle(true, 20, black),
                          textAlign: TextAlign.center,
                        ),
                      ],
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
                  BaseModel model = productLists[p];
                  return shopItem(context, model);
                },
                itemCount: productLists.length,
                padding: EdgeInsets.all(7),
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
              );
            },
          ),
        )
      ],
    );
  }
}
