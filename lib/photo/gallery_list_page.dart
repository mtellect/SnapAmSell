import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maugost_apps/photo/photo_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import '../AppEngine.dart';
import '../assets.dart';

class GalleryListPage extends StatefulWidget {
  const GalleryListPage({Key key}) : super(key: key);

  @override
  _GalleryListPageState createState() => _GalleryListPageState();
}

class _GalleryListPageState extends State<GalleryListPage> {
  PhotoProvider get provider => Provider.of<PhotoProvider>(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            addSpace(30),
            new Container(
              width: double.infinity,
              child: new Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
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
                    fit: FlexFit.tight,
                    flex: 1,
                    child: new Text(
                      "Gallery List",
                      style: textStyle(true, 17, black),
                    ),
                  ),
                  addSpaceWidth(10),
                ],
              ),
            ),
            Expanded(
              child: Scrollbar(
                child: ListView.builder(
                  padding: EdgeInsets.all(0),
                  itemBuilder: _buildItem,
                  itemCount: provider.list.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final item = provider.list[index];
    return GestureDetector(
      child:
          /*ListTile(
        title: Text(item.name),
        subtitle: Text("count : ${item.assetCount}"),
        trailing: Text("isAll : ${item.isAll}"),
      )*/
          Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(5),
            ),
            border: Border.all(color: black.withOpacity(.1), width: .5),
            color: blue09),
        margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        padding: const EdgeInsets.all(10),
        child: Row(
          //crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              width: 50,
              height: 50,
              child: FutureBuilder(
                builder: (c, s) {
                  if (!s.hasData) return Container();
                  List<AssetEntity> list = s.data;
                  if (list.isEmpty) return Container();
                  AssetEntity item = list[0];

                  return FutureBuilder<Uint8List>(
                    future: item.thumbDataWithSize(150, 150),
                    builder: (context, snapshot) {
                      Widget w;
                      if (snapshot.hasError) {
                        w = Center(
                          child: Text(
                            "Loading Error!",
                            style: textStyle(true, 12, black.withOpacity(.5)),
                          ),
                        );
                      }
                      if (snapshot.hasData) {
                        //ImageLruCache.setData(item, size, snapshot.data);
                        w = Image.memory(
                          snapshot.data,
                          fit: BoxFit.cover,
                        );
                      } else {
                        w = Center(
                          child: Icon(
                            Icons.image,
                            color: black.withOpacity(.3),
                          ),
                        );
                      }

                      return w;
                    },
                  );
                },
                future: item.assetList,
              ),
            ),
            addSpaceWidth(10),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Flexible(
                      fit: FlexFit.loose,
                      child:
                          Text(item.name, style: textStyle(true, 16, black))),
                  //addSpace(5),
                  Text("${item.assetCount}",
                      style: textStyle(false, 12, black.withOpacity(.5))),
                ],
              ),
            ),
          ],
        ),
      ),
      onTap: () => Navigator.pop(context, item),
    );
  }
}
