import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/dialogs/listDialog.dart';
import 'package:maugost_apps/photo/change_notifier_builder.dart';
import 'package:maugost_apps/photo/image_item_widget.dart';
import 'package:maugost_apps/photo/photo_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:rect_getter/rect_getter.dart';
import 'package:synchronized/synchronized.dart';
import 'package:video_player/video_player.dart';

import '../assets.dart';
import '../main.dart';
import 'gallery_list_page.dart';

List mediaSelections = [];

class CustomGalleryContentListPage extends StatefulWidget {
  final AssetPathEntity path;
  final String topTitle;
  final bool singleMode;
  int maxSelection;
  int type;
  String galleryKey;
  CustomGalleryContentListPage(this.galleryKey,
      {Key key,
      this.path,
      this.topTitle,
      this.singleMode = false,
      this.type = 0,
      this.maxSelection = 6})
      : super(key: key);

  @override
  _CustomGalleryContentListPageState createState() =>
      _CustomGalleryContentListPageState();
}

class _CustomGalleryContentListPageState
    extends State<CustomGalleryContentListPage> {
  AssetPathEntity get path => widget.path;
  var listKey = RectGetter.createGlobalKey();

  PathProvider get provider =>
      Provider.of<PhotoProvider>(context).getOrCreatePathProvider(path);
  PhotoProvider get main_provider => Provider.of<PhotoProvider>(context);

//  bool multiple = false;
  String title = "";
//  int maxSelection = 6;
  @override
  void initState() {
    super.initState();
    title = path.name ?? "";
    title = title == "Recent" ? "" : title;
//    multiple = !widget.singleMode;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierBuilder(
      value: provider,
      builder: (_, __) {
        var length = path.assetCount;
        return Scaffold(
          backgroundColor: white,
          body: Stack(
            children: <Widget>[
              body(),
              if (1 == 2)
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    width: 60,
                    height: 60,
                    margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: FloatingActionButton(
                      onPressed: () async {
//                    List files = [];
//                    for(AssetEntity entity in provider.list){
//                      if(!mediaSelections.contains(entity))continue;
//                      File file = await entity.file;
//                      files.add(file);
//                    }

                        galleryResultController
                            .add([widget.galleryKey, mediaSelections]);
                        Navigator.pop(context);
                      },
                      heroTag: "c1a",
                      clipBehavior: Clip.antiAlias,
                      shape: CircleBorder(
//                        side: BorderSide(color: white,width: 2)
                          ),
                      backgroundColor: blue0,
                      child: Icon(
                        Icons.check,
                        color: white,
                        size: 30,
                      ),
                    ),
                  ),
                )
            ],
          ),
        );
      },
    );
  }

  Widget body() {
    if (!provider.isInit) {
      provider.onRefresh();
      return loadingLayout();
    }

    return Column(
      children: <Widget>[
        addSpace(40),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text(
                      widget.topTitle ?? "Select Media",
                      style: textStyle(true, 18, black),
                    ),
                    if (title.isNotEmpty)
                      new Text(
                        title,
                        style: textStyle(false, 14, black.withOpacity(.4)),
                      ),
                  ],
                ),
              ),
              addSpaceWidth(10),
              GestureDetector(
                onTap: () async {
                  await main_provider.refreshGalleryList(widget.type);

                  final page = GalleryListPage();
                  pushAndResult(context, page, result: (item) {
                    Future.delayed(Duration(milliseconds: 500), () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => CustomGalleryContentListPage(
                              widget.galleryKey,
                              path: item,
                              type: widget.type,
                              maxSelection: widget.maxSelection),
                        ),
                      );
                    });
                  });
                  /*Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (ctx) => page,
                  ));*/
                },
                child: Container(
                  width: 50,
                  height: 50,
                  color: transparent,
                  child: Center(
                    child: Icon(
                      Icons.folder,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  pushAndResult(context, listDialog(["Photo", "Video"]),
                      result: (_) async {
                    bool isVideo = _ == "Video";
                    final _picker = ImagePicker();
                    final pickedFile = isVideo
                        ? (await _picker.getVideo(source: ImageSource.camera))
                        : (await _picker.getImage(source: ImageSource.camera));
                    final File file = File(pickedFile.path);
//                  File file = await ImagePicker.pickImage(source: ImageSource.camera);
                    galleryResultController.add([
                      widget.galleryKey,
                      [
                        [file, isVideo]
                      ]
                    ]);
                    Navigator.pop(
                      context,
                    );
                  });
                },
                child: Container(
                  width: 50,
                  height: 50,
                  color: transparent,
                  child: Center(
                    child: Icon(
                      Icons.camera_alt,
                    ),
                  ),
                ),
              ),
              if (mediaSelections.isNotEmpty)
                GestureDetector(
                  onTap: () async {
                    /*showMessage(context, Icons.check, blue0, "Deselect All", "Are you sure?",onClicked: (_){
                    if(_==true){
//                      multiple=false;
                      mediaSelections.clear();
                      setState(() {

                      });
                    }
                  });*/
//                  List files = [];
//                  for(AssetEntity entity in provider.list){
//                    if(!mediaSelections.contains(entity))continue;
//                    File file = await entity.file;
//                    files.add(file);
//                  }
                    galleryResultController
                        .add([widget.galleryKey, mediaSelections]);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    color: transparent,
                    child: Center(
                      child: Icon(
                        Icons.check_circle,
                        color: blue0,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        addSpace(5),
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
        Expanded(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: Scrollbar(
              child: NotificationListener<ScrollNotification>(
                onNotification: (scroll) {
                  getVisible();
                  return false;
                },
                child: GridView.builder(
                  key: listKey,
                  itemBuilder: gridItem,
                  padding: EdgeInsets.all(0),
                  physics: BouncingScrollPhysics(),
                  itemCount: provider.showItemCount,
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent:
                          ((MediaQuery.of(context).size.width) / 3),
                      mainAxisSpacing: 0,
                      childAspectRatio: .5,
                      crossAxisSpacing: 0),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  var _keys = {};

  Widget gridItem(BuildContext context, int index) {
    final list = provider.list;
    if (/*list.length>PathProvider.loadCount &&*/ list.length / 2 == index) {
      onLoadMore();
      return Container();
    }

    if (index > list.length) {
      return Container();
    }

    final entity = list[index];

    _keys[index] = RectGetter.createGlobalKey();

    bool isVideo = entity.type == AssetType.video;
    return RectGetter(
      key: _keys[index],
      child: GestureDetector(
        onTap: () async {
          if (!widget.singleMode) {
            if (!mediaSelections.contains(entity)) {
              if (mediaSelections.length == widget.maxSelection) {
                showError("Max selection reached");
                return;
              }
              if (entity.type == AssetType.video) {
                File file = await entity.file;
                VideoPlayerController _controller =
                    VideoPlayerController.file(file);
                await _controller.initialize();
                int duration = _controller.value.duration.inSeconds;
                if (duration > (Duration.secondsPerMinute * 2)) {
                  showMessage(context, Icons.error, red0, "Too Long",
                      "Video cannot be longer than 2 minutes");
                  return;
                }
              }
              mediaSelections.add(entity);
            } else {
              mediaSelections.remove(entity);
              if (mediaSelections.isEmpty) {
//                  multiple=false;
              }
            }
            setState(() {});
            return;
          }
          File file = await entity.file;
          if (entity.type == AssetType.video) {
            File file = await entity.file;
            VideoPlayerController _controller =
                VideoPlayerController.file(file);
            await _controller.initialize();
            int duration = _controller.value.duration.inSeconds;
            if (duration > (Duration.secondsPerMinute * 3)) {
              showMessage(context, Icons.error, red0, "Too Long",
                  "Video cannot be longer than 3 minutes");
              return;
            }
          }
          galleryResultController.add([
            widget.galleryKey,
            [entity]
          ]);
          Navigator.pop(
            context,
          );
        },
        onLongPress: () {
//          if(widget.singleMode)return;
//          if(multiple)return;
//          multiple=true;
//          mediaSelections.add(entity);
//          setState(() {
//
//          });
        },
        child: Container(
          width: double.infinity,
          color: transparent,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(1),
                color: default_white,
                child: (ImageItemWidget(
                  key: ValueKey(entity),
                  entity: entity,
                )),
              ),
              if (mediaSelections.isNotEmpty)
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                          color: black.withOpacity(.5),
                          shape: BoxShape.circle,
                          border: Border.all(color: white, width: 1.5)),
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: mediaSelections.contains(entity)
                              ? blue0
                              : transparent,
                          shape: BoxShape.circle,
                        ),
                        child: mediaSelections.contains(entity)
                            ? Center(
                                child: Text(
                                  "${mediaSelections.indexOf(entity) + 1}",
                                  style: textStyle(true, 11, white),
                                ),
                              )
                            : Container(),
                      )),
                ),
            ],
          ),
        ),
      ),
    );
  }

  int lastChecked = 0;
  getVisible() async {
    /// First, get the rect of ListView, and then traver the _keys
    /// get rect of each item by keys in _keys, and if this rect in the range of ListView's rect,
    /// add the index into result list.
    /// var
    int now = DateTime.now().millisecondsSinceEpoch;
    int diff = now - lastChecked;
    if (diff < (Duration.millisecondsPerSecond * 3)) return;
    lastChecked = now;
    var rect = RectGetter.getRectFromKey(listKey);
    var _items = <int>[];
    var ids = <String>[];
    _keys.forEach((index, key) {
      var itemRect = RectGetter.getRectFromKey(key);
      if (itemRect != null &&
          !(itemRect.top > rect.bottom || itemRect.bottom < rect.top)) {
        _items.add(index);
        AssetEntity entity = provider.list[index];
        if (entity.type == AssetType.video) {
          ids.add(entity.id);
//          print("Visible: $index");
        }
      }
    });
    if (ids.isNotEmpty) galleryController.add(ids);
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool loadingMore = false;
  Future<void> onLoadMore() async {
    if (!mounted) {
      return;
    }
    if (loadingMore) return;
    loadingMore = true;
    var lock = Lock();
    lock.synchronized(() async {
      await provider.onLoadMore();
      loadingMore = false;
    });
  }

  Future<void> _onRefresh() async {
    if (!mounted) {
      return;
    }
    await provider.onRefresh();
  }

  String errorText = "";
  showError(String text) {
    errorText = text;
    setState(() {});
    Future.delayed(Duration(seconds: 1), () {
      errorText = "";
      setState(() {});
    });
  }
}
