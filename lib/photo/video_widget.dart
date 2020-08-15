import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/photo/lru_map.dart';
import 'package:photo_manager/photo_manager.dart';

import '../assets.dart';

class VideoWidget extends StatefulWidget {
  final AssetEntity entity;

  const VideoWidget({
    Key key,
    @required this.entity,
  }) : super(key: key);

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
//  VideoPlayerController _controller;
  StreamSubscription sub;
  List<String> visibleIds = [];
  AssetEntity entity;
  String id;
  bool ready = false;
  @override
  void initState() {
    super.initState();
    entity = widget.entity;

    /*sub = galleryController.stream.listen((List<String> ids){
      return;
      visibleIds = ids;
      bool visible = ids.contains(entity.id);
      if(!_controller.value.initialized)return;
      if(!visible){
        if(_controller.value.isPlaying && !_controller.value.initialized)_controller.pause();
      }else{
        if(!_controller.value.isPlaying && ids.isNotEmpty && ids[ids.length-1]==entity.id){
          _controller.play();
          print("Playing...");
        }
      }
    });*/
    setup();
  }

  setup() async {
    /* return;
    File file = await entity.file;
    _controller = VideoPlayerController.file(file)
      ..initialize().then((_) {
        if(visibleIds.isNotEmpty && visibleIds[visibleIds.length-1]==entity.id)_controller.play();
        ready=true;
        setState(() {

        });
      });
    _controller.setVolume(0);
    _controller.setLooping(true);*/
  }

  @override
  void dispose() {
//    _controller?.dispose();
//    sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return /*!ready || (!_controller.value.initialized)?(
        Container(child: Center(
          child: Icon(Icons.videocam,color: black.withOpacity(.3),),
        )
    )):*/
        buildVideoPlayer();
  }

  buildVideoPlayer() {
    final size = 300;
    final u8List = ImageLruCache.getData(entity, size);
    return GestureDetector(
//      onPanStart: (_){
//        if(_controller.value.initialized && !_controller.value.isPlaying)_controller.play();
//      },
//      onPanDown: (_){
//        if(_controller.value.initialized && !_controller.value.isPlaying)_controller.play();
//      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Align(
              alignment: Alignment.center,
              child: u8List != null
                  ? (Image.memory(
                      u8List,
                      width: size.toDouble(),
                      height: size.toDouble(),
                      fit: BoxFit.cover,
                    ))
                  : FutureBuilder<Uint8List>(
                      future: entity.thumbDataWithSize(size, size),
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
                          ImageLruCache.setData(entity, size, snapshot.data);
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
                    )
              /*AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
              child: entity.VideoPlayer(_controller)
          )*/
              ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              margin: EdgeInsets.all(5),
              child: Text(
                getTimerText(entity.videoDuration.inSeconds),
                style: textStyle(true, 12, white),
              ),
              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
              decoration: BoxDecoration(
                  color: black.withOpacity(.5),
                  borderRadius: BorderRadius.all(Radius.circular(25))),
            ),
          )
        ],
      ),
    );
  }
}
