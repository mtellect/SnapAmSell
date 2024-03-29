library flutter_page_video;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maugost_apps/AppConfig.dart';
import 'package:screen/screen.dart';
import 'package:video_player/video_player.dart';

class SimpleVideoPlayer extends StatefulWidget {
  final String source;
  final File file;
  final bool isFullScreen;
  final bool isAsset;
  final vidDuration;

  SimpleVideoPlayer(
      {this.vidDuration,
      this.source,
      this.file,
      this.isFullScreen = false,
      this.isAsset = false});

  @override
  _SimpleVideoPlayerState createState() => _SimpleVideoPlayerState();
}

class _SimpleVideoPlayerState extends State<SimpleVideoPlayer> {
  VideoPlayerController controller;
  VoidCallback listener;
  bool hideBottom = true;

  @override
  void initState() {
    super.initState();
    listener = () {
      if (!mounted) {
        return;
      }
      /*if (controller.value.position.toString().split(".")[0] ==
          controller.value.duration.toString().split(".")[0]) {
        controller.seekTo(Duration.zero);
        controller.pause();
      }*/
      if (widget.vidDuration != null) {
        widget.vidDuration(controller.value.duration.toString().split(".")[0]);
      }
      setState(() {});
    };
    if (widget.isAsset) {
      controller = VideoPlayerController.asset(widget.source);
    } else {
      controller = widget.file != null
          ? VideoPlayerController.file(widget.file)
          : VideoPlayerController.network(widget.source);
    }

    controller.initialize();
    controller.setLooping(true);
    controller.addListener(listener);
    controller.play();
    Screen.keepOn(true);
    if (widget.isFullScreen) {
      SystemChrome.setEnabledSystemUIOverlays([]);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    Screen.keepOn(false);
    if (widget.isFullScreen) {
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PlayView(
        controller,
        allowFullScreen: !widget.isFullScreen,
      ),
    );
  }
}

class PlayView extends StatefulWidget {
  VideoPlayerController controller;
  bool allowFullScreen;

  PlayView(this.controller, {this.allowFullScreen: true});

  @override
  _PlayViewState createState() => _PlayViewState();
}

class _PlayViewState extends State<PlayView> {
  VideoPlayerController get controller => widget.controller;
  bool hideBottom = true;

  void onClickPlay() {
    if (!controller.value.initialized) {
      return;
    }
    setState(() {
      hideBottom = false;
    });
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) {
          return;
        }
        if (!controller.value.initialized) {
          return;
        }
        if (controller.value.isPlaying && !hideBottom) {
          setState(() {
            hideBottom = true;
          });
        }
      });
      controller.play();
    }
  }

  void onScreenTouched() {
    if (!controller.value.initialized) {
      return;
    }
    setState(() {
      hideBottom = false;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) {
        return;
      }
      if (!controller.value.initialized) {
        return;
      }
      if (controller.value.isPlaying && !hideBottom) {
        setState(() {
          hideBottom = true;
        });
      }
    });
  }

  void onClickFullScreen() {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      // current portrait , enter fullscreen
      SystemChrome.setEnabledSystemUIOverlays([]);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      Navigator.of(context)
          .push(PageRouteBuilder(
        settings: RouteSettings(),
        pageBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget child) {
              return Scaffold(
                resizeToAvoidBottomPadding: false,
                body: PlayView(controller),
              );
            },
          );
        },
      ))
          .then((value) {
        // exit fullscreen
        SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      });
    }
  }

  void onClickExitFullScreen() {
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      // current landscape , exit fullscreen
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = AppConfig.appColor;
    if (controller.value.initialized) {
      final Size size = controller.value.size;
      return GestureDetector(
        child: new Container(
            color: Colors.black,
            child: Stack(
              children: <Widget>[
                Center(
                    child: AspectRatio(
                  aspectRatio: size.width / size.height,
                  child: VideoPlayer(controller),
                )),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: hideBottom
                        ? Container()
                        : Opacity(
                            opacity: 0.8,
                            child: Container(
                                height: 30.0,
                                color: Colors.grey,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    GestureDetector(
                                      child: Container(
                                        child: controller.value.isPlaying
                                            ? Icon(
                                                Icons.pause,
                                                color: primaryColor,
                                              )
                                            : Icon(
                                                Icons.play_arrow,
                                                color: primaryColor,
                                              ),
                                      ),
                                      onTap: onClickPlay,
                                    ),
                                    Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 5.0),
                                        child: Center(
                                          child: Text(
                                            "${controller.value.position.toString().split(".")[0]}",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        )),
                                    Expanded(
                                        child: VideoProgressIndicator(
                                      controller,
                                      allowScrubbing: true,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 1.0, vertical: 1.0),
                                      colors: VideoProgressColors(
                                          playedColor: primaryColor),
                                    )),
                                    Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 5.0),
                                        child: Center(
                                          child: Text(
                                            "${controller.value.duration.toString().split(".")[0]}",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        )),
                                    Container(
                                      child: widget.allowFullScreen
                                          ? Container(
                                              child: MediaQuery.of(context)
                                                          .orientation ==
                                                      Orientation.portrait
                                                  ? GestureDetector(
                                                      child: Icon(
                                                        Icons.fullscreen,
                                                        color: primaryColor,
                                                      ),
                                                      onTap: onClickFullScreen,
                                                    )
                                                  : GestureDetector(
                                                      child: Icon(
                                                        Icons.fullscreen_exit,
                                                        color: primaryColor,
                                                      ),
                                                      onTap:
                                                          onClickExitFullScreen,
                                                    ),
                                            )
                                          : Container(),
                                    )
                                  ],
                                )),
                          )),
                Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: onClickPlay,
                    child: controller.value.isPlaying
                        ? Container()
                        : Icon(
                            Icons.play_circle_filled,
                            color: primaryColor,
                            size: 48.0,
                          ),
                  ),
                )
              ],
            )),
        onTap: onScreenTouched,
      );
    } else if (controller.value.hasError && !controller.value.isPlaying) {
      return Container(
        color: Colors.black,
        child: Center(
          child: RaisedButton(
            onPressed: () {
              controller.initialize();
              controller.setLooping(true);
              controller.play();
            },
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            child: Text("play error, try again!"),
          ),
        ),
      );
    } else {
      return Container(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}
