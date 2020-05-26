import 'dart:io';

import 'package:Strokes/AppEngine.dart';
import 'package:Strokes/app/app.dart';
import 'package:Strokes/app_config.dart';
import 'package:Strokes/assets.dart';
import 'package:Strokes/basemodel.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo/photo.dart';
import 'package:photo_manager/photo_manager.dart';

enum CameraPosition { front, back }
enum CameraFlash { flashOn, flashOff }

cameraFlashIcon(CameraFlash flash) {
  if (flash == CameraFlash.flashOff) {
    return Icon(
      Icons.flash_off,
      color: Colors.white,
    );
  }

  return Icon(
    Icons.flash_on,
    color: Colors.white,
  );
}

class SellCamera extends StatefulWidget {
  final bool cameraAlone;

  const SellCamera({
    Key key,
    this.cameraAlone = false,
  }) : super(key: key);
  @override
  _SellCameraState createState() => _SellCameraState();
}

class _SellCameraState extends State<SellCamera>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  bool get hasNotInitialized {
    return null == cameraController || !cameraController.value.isInitialized;
  }

  List<BaseModel> selectedPhotos = [];
  int maxImageLimit = 10;

  CameraController cameraController;
  //FlashCameraController cameraController;
  CameraPosition cameraPosition = CameraPosition.back;
  CameraFlash cameraFlash = CameraFlash.flashOff;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    changeTapText();
    loadCameraSettings();
  }

  switchCameraLens() async {
    await cameraController?.dispose();

    if (mounted)
      setState(() {
        if (cameraPosition == CameraPosition.back) {
          cameraPosition = CameraPosition.front;
          loadCameraSettings(p: 1);
        } else {
          cameraPosition = CameraPosition.back;
          loadCameraSettings(p: 0);
        }
      });
  }

  switchCameraFlash() async {
    setState(() {
      if (cameraFlash == CameraFlash.flashOn) {
        // cameraController.flash(false);
        cameraController.turnOffFlash();
        cameraFlash = CameraFlash.flashOff;
      } else {
        // cameraController.flash(true);
        cameraController.turnOnFlash();
        cameraFlash = CameraFlash.flashOn;
      }
    });
  }

  loadCameraSettings({int p = 0}) async {
    if (cameras.isEmpty) return;

    await Future.delayed(Duration(milliseconds: 8));
    cameraController = CameraController(
      cameras[p],
      ResolutionPreset.high,
    );

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      //selectedPhotos.clear();
      if (mounted) setState(() {});
      if (cameraController.value.hasError) {
        print('Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _showCameraException(CameraException e) {
    showMessage(
        context, Icons.error, red, "Camera Error ${e.code}", e.description,
        cancellable: true);
  }

  changeTapText() {
    Future.delayed(Duration(seconds: 7), () {
      tapText = tapText == text1 ? text2 : text1;
      if (mounted) setState(() {});
      changeTapText();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        loadCameraSettings();
        break;
      case AppLifecycleState.inactive:
        cameraController?.dispose();
        break;
      case AppLifecycleState.paused:
        cameraController?.dispose();
        break;
      case AppLifecycleState.detached:
        cameraController?.dispose();
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController?.dispose();
    super.dispose();
  }

  imagesPreviewUI() {
    return LayoutBuilder(
      builder: (ctx, box) {
        if (selectedPhotos.isEmpty) {
          return Container();
        }
        return Container(
          height: 170,
          color: Colors.transparent,
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 150,
                  //color: Colors.white,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: selectedPhotos.length,
                      itemBuilder: (ctx, p) {
                        BaseModel photo = selectedPhotos[p];
                        bool isVideo = photo.isVideo;

                        return ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(3),
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: FadeInImage(
                                  placeholder:
                                      AssetImage("assets/images/images.png"),
                                  image: FileImage(File(isVideo
                                      ? photo.getString(THUMBNAIL_PATH)
                                      : photo.getString(IMAGE_PATH))),
                                  fit: BoxFit.cover,
                                  width: 150,
                                  height: 150,
                                ),
                              ),
                              iconVideo(isVideo),
                              Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: black.withOpacity(.1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(2),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedPhotos.removeWhere((e) =>
                                          e.getObjectId() ==
                                          photo.getObjectId());
                                    });
                                  },
                                  child: Container(
                                    height: 30,
                                    width: 30,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        color: red00, shape: BoxShape.circle),
                                    child: Icon(
                                      Icons.clear,
                                      color: white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      }),
                ),
              ),
              if (selectedPhotos.isNotEmpty)
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    height: 60,
                    width: 60,
                    margin: EdgeInsets.only(right: 15),
                    child: FlatButton(
                      onPressed: () {
//                        pushAndResult(
//                            context,
//                            PreviewPhotos(
//                              selectedData: selectedPhotos,
//                            ), result: (_) {
//                          if (null == _) return;
//                          Navigator.pop(context, _);
//                        });
                      },
                      color: AppConfig.appColor,
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(15),
                      child: Stack(
                        children: <Widget>[
                          Icon(
                            Icons.check,
                            color: Colors.white,
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              '${selectedPhotos.length}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
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

  iconVideo(bool isVideo) {
    if (!isVideo) {
      return Container(
        width: 0,
        height: 0,
      );
    }
    return Align(
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.black.withOpacity(.5),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(.3), width: 1)),
        child: Icon(
          Icons.videocam,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }

  cameraControlTools() {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(bottom: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Flexible(
                child: Container(
                  width: MediaQuery.of(context).size.width / 3,
                  alignment: Alignment.center,
                  child: recording
                      ? Container()
                      : IconButton(
                          onPressed: () {
                            if (hasNotInitialized) return;
                            switchCameraFlash();
                          },
                          icon: cameraFlashIcon(cameraFlash),
                        ),
                ),
              ),
              Flexible(
                child: Container(
                  width: MediaQuery.of(context).size.width / 3,
                  alignment: Alignment.center,
                  child: new Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onDoubleTap: () {
                        if (hasNotInitialized) return;
                        if (recording) return;
                        onVideoRecordButtonPressed();
                      },
                      onTap: () {
                        if (hasNotInitialized) return;

                        if (recording) {
                          onStopButtonPressed(false);
                          return;
                        }
                        if (timerCounting) {
                          if (mounted)
                            setState(() {
                              timerCounting = false;
                              timerCount = 4;
                            });
                          return;
                        }
                        onTakePictureButtonPressed();
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          if (recording)
                            Container(
                              decoration: BoxDecoration(
                                  color: black.withOpacity(.8),
                                  borderRadius: BorderRadius.circular(25)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  AnimatedOpacity(
                                    opacity: recordingOpacity,
                                    duration: Duration(milliseconds: 500),
                                    child: Container(
                                      margin: EdgeInsets.all(10),
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                          color: red0, shape: BoxShape.circle),
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      recordTimerText,
                                      style: textStyle(true, 12, white),
                                    ),
                                  ),
                                  GestureDetector(
                                      onTap: () {
                                        onStopButtonPressed(true);
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        child: Icon(
                                          Icons.close,
                                          color: white,
                                          size: 20,
                                        ),
                                      ))
                                ],
                              ),
                            ),
                          new AnimatedContainer(
                            duration: Duration(milliseconds: 500),
                            width: buttonSize,
                            height: buttonSize,
                            margin: EdgeInsets.fromLTRB(20, 10, 20, 20),
                            decoration: BoxDecoration(
                                color: buttonColor,
                                border: Border.all(color: white, width: 5),
                                shape: BoxShape.circle),
                            padding: EdgeInsets.all(5),
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 500),
                              decoration: BoxDecoration(
                                  color: buttonColor, shape: BoxShape.circle),
                              child: Center(
                                  child: Stack(
                                children: <Widget>[
                                  if (timerCounting || recording)
                                    Align(
                                        alignment: Alignment.center,
                                        child: Container(
                                          width: 25,
                                          height: 25,
                                          color: red0,
                                        )),
                                ],
                              )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                child: Container(
                  width: MediaQuery.of(context).size.width / 3,
                  alignment: Alignment.center,
                  child: recording
                      ? Container()
                      : IconButton(
                          onPressed: () {
                            if (hasNotInitialized) return;
                            switchCameraLens();
                          },
                          icon: Icon(
                            Icons.switch_camera,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
          if (!recording) ...[
            addSpace(8),
            Text(
              'Double Tap for video,Tap for photo',
              style: textStyle(false, 14, white),
            )
          ]
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      onDismissed: (d) => Navigator.pop(context),
      direction: DismissDirection.vertical,
      key: Key('key'),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: cameraView(),
      ),
    );
  }

  cameraView() {
    return Stack(
      children: <Widget>[
        if (hasNotInitialized)
          Container(
            margin: EdgeInsets.only(bottom: 80),
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(white),
            ),
          )
        else
          Container(
            //margin: EdgeInsets.only(bottom: 100),
            child: AspectRatio(
              aspectRatio: cameraController.value.aspectRatio,
              child: CameraPreview(
                cameraController,
              ),
            ),
          ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: EdgeInsets.only(bottom: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (!recording) imagesPreviewUI(),
                cameraControlTools()
              ],
            ),
          ),
        ),
        //if (false)
        Align(
          alignment: Alignment.topLeft,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                  color: white.withOpacity(.2), shape: BoxShape.circle),
              margin: EdgeInsets.only(left: 15, top: 35),
              child: Icon(
                Icons.close,
                color: white,
                size: 20,
              ),
            ),
          ),
        ),
        if (!widget.cameraAlone)
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () {
                pickAssets();
              },
              child: Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                    color: AppConfig.appColor.withOpacity(.2),
                    shape: BoxShape.circle),
                margin: EdgeInsets.only(right: 15, top: 35),
                child: Icon(
                  Icons.image,
                  color: white,
                  size: 20,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void onTakePictureButtonPressed() async {
    //cameraController.captureImage();

    takePicture().then((String filePath) async {
      if (mounted) {
        if (widget.cameraAlone) {
          File file = await cropThisImage(filePath, circle: true);
          final photo = createPhotoModel(
              urlPath: file.path, thumbnail: "", objectId: getRandomId());
          Navigator.pop(context, photo);
          return;
        }

        final model = createPhotoModel(
            urlPath: filePath, thumbnail: "", objectId: getRandomId());
        addToList(model);
      }
    });
  }

  onError(e) {}

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
  double buttonSize = 95;
  var buttonColor = Colors.black;
  double tapOpacity = 0;
  String tapText = "";
  final String text1 = "Double Tap \nfor\n Video";
  final String text2 = "Single Tap \nfor\n Photo";
  bool showGrid = false;
  bool useTimer = false;
  bool timerCounting = false;
  int timerCount = 4;
  double timerOpacity = 0;
  bool recording = false;
  int recordTimer = 0;
  int maxRecordTime = 300;
  String recordTimerText = "00:00";
  String videoFilePath = "";
  double recordingOpacity = 1;

  void onVideoRecordButtonPressed() {
    if (recording) return;
    if (widget.cameraAlone) return;
    recording = true;
    recordTimer = 0;
    recordTimerText = "00:00";
    recordingOpacity = 1;
    if (mounted) setState(() {});
    createRecordTimer();
    startVideoRecording().then((String filePath) {
      videoFilePath = filePath;
      if (mounted) setState(() {});
    });
    return;
  }

  void onStopButtonPressed(bool cancel) {
    recording = false;
    recordTimer = 0;
    if (mounted) setState(() {});
    stopVideoRecording();
  }

  createRecordTimer() {
    Future.delayed(Duration(seconds: 1), () {
      if (!recording) {
        return;
      }
      recordTimer++;
      recordingOpacity = recordingOpacity == 1 ? 0 : 1;

      int min = recordTimer ~/ 60;
      int sec = recordTimer % 60;

      if (sec == 90) onStopButtonPressed(true);

      String m = min.toString();
      String s = sec.toString();

      String ms = m.length == 1 ? "0$m" : m;
      String ss = s.length == 1 ? "0$s" : s;

      recordTimerText = "$ms:$ss";

      if (mounted) setState(() {});
      createRecordTimer();
    });
  }

  Future<String> takePicture() async {
    if (hasNotInitialized) return null;
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (cameraController.value.isTakingPicture) return null;

    try {
      await cameraController.takePicture(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  Future<String> startVideoRecording() async {
    if (hasNotInitialized) return null;

    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/acclaim/stories';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.mp4';

    if (cameraController.value.isRecordingVideo) return null;

    try {
      videoFilePath = filePath;
      await cameraController.startVideoRecording(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  Future<void> stopVideoRecording() async {
    if (!cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      await cameraController.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }

    String videoThumbnail = await getVideoThumbnail(videoFilePath);

    print("Okore $videoThumbnail");

    final model = createPhotoModel(
        objectId: getRandomId(),
        urlPath: videoFilePath,
        thumbnail: videoThumbnail,
        isVideo: true);
    addToList(model);
  }

  Future<void> pauseVideoRecording() async {
    if (!cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      await cameraController.pauseVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> resumeVideoRecording() async {
    if (!cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      await cameraController.resumeVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  addToList(BaseModel model) {
    int p = selectedPhotos
        .indexWhere((e) => e.getObjectId() == model.getObjectId());
    if (p != -1) {
      selectedPhotos[p] = model;
    } else {
      selectedPhotos.add(model);
    }
    setState(() {});
  }

  void pickAssets() async {
    PhotoPicker.pickAsset(
            pickType: PickType.onlyImage,
            context: context,
            provider: I18nProvider.english,
            rowCount: 3)
        .then((value) async {
      if (value == null) return;
      for (var a in value) {
        String path = (await a.originFile).path;
        bool isVideo = a.type == AssetType.video;
        BaseModel model = BaseModel();
        model.put(OBJECT_ID, a.id);
        model.put(IMAGE_URL, path);
        model.put(IS_VIDEO, isVideo);
//        if (isVideo) {
//          model.put(THUMBNAIL_URL,
//              (await VideoCompress().getThumbnailWithFile(path)).path);
//        }
        addToList(model);
      }

      setState(() {});
    }).catchError((e) {});

    /// Use assetList to do something.
  }
}

BaseModel createPhotoModel(
    {@required String urlPath,
    @required String thumbnail,
    String caption = "",
    String objectId = "",
    bool isVideo = false,
    bool isLocal = true}) {
  if (objectId.isEmpty) objectId = getRandomId();
  return BaseModel()
    ..put(OBJECT_ID, objectId)
    ..put(IMAGE_PATH, urlPath)
    ..put(THUMBNAIL_PATH, thumbnail)
    ..put(IS_VIDEO, isVideo);
}
