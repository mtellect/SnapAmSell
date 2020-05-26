
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

import 'AppEngine.dart';
import 'assets.dart';
import 'basemodel.dart';

class ShowPhoto extends StatefulWidget {
  List paths;
  ShowPhoto(this.paths);

  @override
  _ShowPhotoState createState() => _ShowPhotoState();
}

class _ShowPhotoState extends State<ShowPhoto> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List paths;
  PageController pc = PageController();
  ScrollController sc = ScrollController();
  int currentPage = 0;
  List<TextEditingController> messageControllers = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    paths = widget.paths;
    for(File file in paths)messageControllers.add(new TextEditingController());
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, "");
      },
      child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: black,
          body: Container(
            child: new Stack(
              fit: StackFit.expand,
              children: <Widget>[
                PageView.builder(
                  itemBuilder: (c, p) {
                    var item = paths[p];
                    return Image.file(
                      item,
//                      fit: BoxFit.cover,
                    );
                  },
                  itemCount: paths.length,
                  onPageChanged: (p) {
                    setState(() {
                      currentPage = p;
                      sc.animateTo(p.ceilToDouble(),
                          duration: Duration(milliseconds: 500),
                          curve: Curves.ease);
                    });
                  },
                  controller: pc,
                ),
                Align(alignment: Alignment.topCenter,child: gradientLine(height: 80,reverse: true,alpha: .8),),
                new Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      height: 50,
                      margin: EdgeInsets.fromLTRB(0, 30, 0, 20),
                      width: double.infinity,
                      child: new Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () async {
                              Navigator.pop(context, "");
                            },
                            child: Container(
                              //margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
                                width: 50,
                                height: 50,
                                child: Icon(
                                  Icons.arrow_back,
                                  color: white,
                                  size: 30,
                                )),
                          ),
                          Flexible(
                              fit: FlexFit.tight, flex: 1, child: Container()),
                          GestureDetector(
                            onTap: () async {
                              File croppedFile =
                              await ImageCropper.cropImage(
                                sourcePath: paths[currentPage].path,/*aspectRatio: CropAspectRatio(ratioX: 4,ratioY:6),*/compressQuality: 100,
                                maxWidth: 3000,
                                maxHeight: 3000,
                              );
                              if (croppedFile != null) {
                                setState(() {
                                  paths[currentPage] = File(croppedFile.path);
                                });
                              }
                            },
                            child: Container(
                              //margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
                                width: 50,
                                height: 50,
                                child: Icon(
                                  Icons.crop_rotate,
                                  color: white,
                                  size: 25,
                                )),
                          ),
                          paths.length == 1
                              ? Container()
                              : GestureDetector(
                            onTap: () {
                              yesNoDialog(context, "Delete?",
                                  "Are you sure you want to delete this?",
                                      () {
                                    paths.removeAt(currentPage);
                                     setState(() {});
                                  });
                            },
                            child: Container(
                              //margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
                                width: 50,
                                height: 50,
                                child: Icon(
                                  Icons.delete,
                                  color: white,
                                  size: 25,
                                )),
                          )
                        ],
                      ),
                    )),
                new Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.all(20),
                            child: FloatingActionButton(onPressed: (){
                              clickShare();
                            },heroTag: "p33",clipBehavior: Clip.antiAlias,
                              shape: CircleBorder(),
                              child: Icon(Icons.send,color: white,),
                            ),
                          ),
                          Container(
                            color: black.withOpacity(.8),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxHeight: 120),
                              child: new TextField(
                                onSubmitted: (_) {

                                },
                                textCapitalization: TextCapitalization.sentences,
                                decoration: InputDecoration(
                                    hintText: "Add a caption",
                                    hintStyle: textStyle(
                                        false, 20, white.withOpacity(.6)),contentPadding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                                    border: InputBorder.none),
                                style: textStyle(false, 20, white),
                                controller: messageControllers[currentPage],
                                cursorColor: white,
                                cursorWidth: 1,
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                scrollPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              ),
                            ),
                          ),
                          paths.length == 1
                              ? Container()
                              : new Container(
                            color: black.withOpacity(.8),
                            height: 50,
                            width: double.infinity,
                            child: ListView.builder(
                              itemBuilder: (c, p) {
                                var item = paths[p];
                                return GestureDetector(
                                  onTap: () {
                                    pc.jumpToPage(p);
                                  },
                                  child: Container(
                                    width: 50,
                                    decoration: p != currentPage
                                        ? null
                                        : BoxDecoration(
                                        border: Border.all(
                                            color: blue0, width: 3)),
                                    child: Image.file(
                                      item,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                              shrinkWrap: true,
                              padding: EdgeInsets.all(0),
                              itemCount: paths.length,
                              scrollDirection: Axis.horizontal,
                              controller: sc,
                            ),
                          )
                        ],
                      ),
                    )),
              ],
            ),
          )),
    );
  }

  clickShare(){
    List models = [];
    for(int i=0;i<paths.length;i++){
      File file = paths[i];
      String text = messageControllers[i].text.trim();
      BaseModel model = BaseModel();
      model.put(STORY_IMAGE, file.path);
      model.put(STORY_TEXT, text);
      models.add(model);
    }

    Navigator.pop(context, models);
  }
}
