import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:line_icons/line_icons.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/assets.dart';
import 'package:maugost_apps/basemodel.dart';

import 'ShowDesigner.dart';

class DesignersPage extends StatefulWidget {
  @override
  _DesignersPageState createState() => _DesignersPageState();
}

class _DesignersPageState extends State<DesignersPage>
    with AutomaticKeepAliveClientMixin {
  List<BaseModel> designers = [];
  String sortBy = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  bool setup = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  loadData() async {
    http.get("https://fakerapi.it/api/v1/users?_quantity=100").then((resp) {
      if (resp.statusCode != 200) return;
      final map = jsonDecode(resp.body);
      designers =
          List.from(map['data']).map((e) => BaseModel(items: e)).toList();
      setup = true;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return designersList();
    return Scaffold(
      backgroundColor: white,
      body: designersList(),
    );
  }

  designersList() {
    if (!setup) return loadingLayout(trans: true);
    return ListView.builder(
        itemCount: sortBy.length,
        padding: EdgeInsets.all(0),
        itemBuilder: (c, p) {
          String sorted = sortBy.substring(p, p + 1);
          List<BaseModel> sortedDesigners = designers.where((model) {
            String fName = model.getString("firstname");
            return fName.startsWith(sorted);
          }).toList();

          if (sortedDesigners.isEmpty) return Container();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                padding: EdgeInsets.all(10),
                child: Text(
                  sorted,
                  style: textStyle(true, 20, black),
                ),
                decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    )),
              ),
              GridView.builder(
                  padding: EdgeInsets.all(0),
                  itemCount: sortedDesigners.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3),
                  itemBuilder: (c, pp) {
                    BaseModel model = sortedDesigners[pp];
                    String image = model.getString("image");
                    String fName = model.getString("firstname");
                    String lName = model.getString("lastname");
                    String name = "$fName $lName";

                    return GestureDetector(
                      onTap: () {
                        pushAndResult(
                            context,
                            ShowDesigner(
                              model: model,
                              url: "$image$p$pp",
                            ));
                      },
                      child: Container(
                        color: transparent,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: CachedNetworkImage(
                                imageUrl: "$image$p$pp",
                                height: 90,
                                width: 90,
                                fit: BoxFit.cover,
                                placeholder: (c, s) {
                                  return Container(
                                    height: 90,
                                    width: 90,
                                    child: Icon(LineIcons.user),
                                    decoration: BoxDecoration(
                                      color: white.withOpacity(.09),
                                      shape: BoxShape.circle,
                                    ),
                                  );
                                },
                              ),
                            ),
                            Text(
                              name,
                              style: textStyle(false, 14, white),
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      ),
                    );
                  }),
            ],
          );
        });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
