import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:maugost_apps/ChatMain.dart';
import 'package:maugost_apps/app/app.dart';
import 'package:maugost_apps/assets.dart';
import 'package:maugost_apps/basemodel.dart';
import 'package:maugost_apps/dialogs/inputDialog.dart';
import 'package:maugost_apps/dialogs/listDialog.dart';
import 'package:maugost_apps/dialogs/messageDialog.dart';
import 'package:maugost_apps/dialogs/progressDialog.dart';
import 'package:maugost_apps/payment_details.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:synchronized/synchronized.dart';
import 'package:timeago/timeago.dart' as timeAgo;
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import 'AppConfig.dart';
import 'MainAdmin.dart';
import 'SimpleVideoPlayer.dart';
import 'dialogs/OfferDialog.dart';
import 'main_pages/ShowDetails.dart';
import 'main_pages/ShowStore.dart';
import 'notificationService.dart';

final formatter = NumberFormat("#,###");
bool refreshPlan = false;
List AllHeadLineList = [];

String formatDOB(int v) {
  if (v < 10) return "0$v";
  return "$v";
}

Future<File> cropThisImage(String path, {bool circle = false}) async {
  return await ImageCropper.cropImage(
      sourcePath: path,
      cropStyle: circle ? CropStyle.circle : CropStyle.rectangle,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: AppConfig.appColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false),
      iosUiSettings: IOSUiSettings(
        minimumAspectRatio: 1.0,
      ));
}

getSingleCroppedImage(BuildContext context,
    {@required onPicked(String urlPath),
    bool crop = true,
    bool circle = false}) async {
  ImagePicker.pickImage(source: ImageSource.gallery).then((value) async {
    if (crop) {
      File file = await cropThisImage(value.path, circle: circle);
      if (null == file) return;
      onPicked(file.path);
      return;
    }

    onPicked(value.path);
  });
  return;
}

getVideoThumbnail(String path) async {
//  return (await VideoCompress()
//          .getThumbnailWithFile(path, quality: 100, position: -1))
//      .path;
}

getSingleVideo(BuildContext context,
    {@required onPicked(BaseModel photo)}) async {
  ImagePicker.pickVideo(source: ImageSource.gallery).then((value) async {
    if (null == value) return;
    final thumbnail = await getVideoThumbnail(value.path);
    final model = BaseModel()
      ..put(VIDEO_PATH, value.path)
      ..put(THUMBNAIL_PATH, thumbnail);
    onPicked(model);
  });
  return;
}

getMultiCroppedImage(BuildContext context,
    {@required onPicked(List<BaseModel> path),
    int max = 2,
    bool withVideo = false,
    String topTitle}) async {
// MultiImagePicker.pickImages(
//         maxImages: max,
//         enableCamera: true,
//         //selectedAssets: images,
//         cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
//         materialOptions: MaterialOptions(
//           actionBarColor: "#abcdef",
//           actionBarTitle: "Example App",
//           allViewTitle: "All Photos",
//           useDetailsView: false,
//           selectCircleStrokeColor: "#000000",
//         ),
//       ).then((value) {

//       }).catchError((e) {
//     //logError(e.code, e.message);
//   });
}

toast(scaffoldKey, text, {Color color}) {
  return scaffoldKey.currentState.showSnackBar(new SnackBar(
    content: Padding(
      padding: const EdgeInsets.all(0.0),
      child: Text(
        text,
        style: textStyle(false, 15, white),
      ),
    ),
    backgroundColor: color,
    duration: Duration(seconds: 2),
  ));
}

SizedBox addSpace(double size) {
  return SizedBox(
    height: size,
  );
}

addSpaceWidth(double size) {
  return SizedBox(
    width: size,
  );
}

int getSeconds(String time) {
  List parts = time.split(":");
  int mins = int.parse(parts[0]) * 60;
  int secs = int.parse(parts[1]);
  return mins + secs;
}

String getTimerText(int seconds, {bool three = false}) {
  int hour = seconds ~/ Duration.secondsPerHour;
  int min = (seconds ~/ 60) % 60;
  int sec = seconds % 60;

  String h = hour.toString();
  String m = min.toString();
  String s = sec.toString();

  String hs = h.length == 1 ? "0$h" : h;
  String ms = m.length == 1 ? "0$m" : m;
  String ss = s.length == 1 ? "0$s" : s;

  return three ? "$hs:$ms:$ss" : "$ms:$ss";
}

Container addLine(
    double size, color, double left, double top, double right, double bottom) {
  return Container(
    height: size,
    width: double.infinity,
    color: color,
    margin: EdgeInsets.fromLTRB(left, top, right, bottom),
  );
}

Container bigButton(double height, double width, String text, textColor,
    buttonColor, onPressed) {
  return Container(
    height: height,
    width: width,
    child: RaisedButton(
      onPressed: onPressed,
      color: buttonColor,
      textColor: white,
      child: Text(
        text,
        style: TextStyle(
            fontSize: 20,
            fontFamily: "FuturaB",
            fontWeight: FontWeight.normal,
            color: textColor),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
    ),
  );
}

Container boxedText(text, int key, int keyHolder, Color normalColor,
    Color selectedColor, Color normalTextColor, Color selectedTextColor) {
  bool selected = key == keyHolder;
  return Container(
    height: 45,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: selected ? selectedColor : null,
        border: !selected
            ? Border.all(width: 1, color: normalColor, style: BorderStyle.solid)
            : null),
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: TextStyle(
              fontSize: 15,
              fontFamily: "FuturaB",
              fontWeight: FontWeight.normal,
              color: selected ? selectedTextColor : normalTextColor),
        ),
      ),
    ),
  );
}

Future<File> loadFile(String path, String name) async {
  final ByteData data = await rootBundle.load(path);
  Directory tempDir = await getTemporaryDirectory();
  File tempFile = File('${tempDir.path}/$name');
  await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
  return tempFile;
}

textStyle(bool bold, double size, color,
    {underlined = false, bool withShadow = false, bool love = false}) {
  return TextStyle(
      color: color,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      // fontWeight:bold?FontWeight.bold: null,//FontWeight.normal,
      fontFamily: bold ? "AvertaB" : "Averta",
      fontSize: size,
      shadows: !withShadow
          ? null
          : (<Shadow>[
              Shadow(offset: Offset(4.0, 4.0), blurRadius: 6.0, color: black),
            ]),
      //decorationThickness: 3,
      decoration: underlined ? TextDecoration.underline : TextDecoration.none);
}

ThemeData darkTheme() {
  final ThemeData base = ThemeData();
  return base.copyWith(hintColor: white);
}

placeHolder(double height, {double width = 200}) {
  return new Container(
    height: height,
    width: width,
    color: blue0.withOpacity(.1),
    child: Center(
        child: Opacity(
            opacity: .3,
            child: Image.asset(
              ic_launcher,
              width: 20,
              height: 20,
            ))),
  );
}

tipBox(boxColor, String text, textColor, {margin}) {
  return Container(
    //width: double.infinity,
    margin: margin,
    decoration:
        BoxDecoration(color: boxColor, borderRadius: BorderRadius.circular(10)),
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        //mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Icon(
            Icons.info,
            size: 14,
            color: white,
          ),
          addSpaceWidth(10),
          Flexible(
            flex: 1,
            child: Text(
              text,
              style: textStyle(false, 15, textColor),
            ),
          )
        ],
      ),
    ),
  );
}

textBox(title, icon, mainText, tap) {
  return new Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        title,
        style: textStyle(false, 14, white.withOpacity(.5)),
      ),
      addSpace(10),
      new Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Image.asset(
            icon,
            width: 14,
            height: 14,
            color: white,
          ),
          addSpaceWidth(15),
          Flexible(
            flex: 1,
            child: Column(
              children: <Widget>[
                new Container(
                  width: double.infinity,
                  child: InkWell(
                      onTap: tap,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: Text(
                          mainText,
                          style: textStyle(false, 17, white),
                        ),
                      )),
                ),
                addLine(2, white, 0, 0, 0, 0),
              ],
            ),
          )
        ],
      ),
    ],
  );
}

Widget transition(BuildContext context, Animation<double> animation,
    Animation<double> secondaryAnimation, Widget child) {
  return FadeTransition(
    opacity: animation,
    child: child,
  );
}

/*selectCurrency(context, result) {
  List<String> images = List();
  List<String> titlesMain = List.from(currenciesText);
  List<String> titles = List.from(currenciesText);

  titles.sort((s1, s2) => s1.compareTo(s2));

  for (String s in titles) {
    images.add(currencies[titlesMain.indexOf(s)]);
  }

  pushAndResult(
      context,
      listDialog(
        titles,
        title: "Choose Currency",
        images: images,
      ), result: (_) {
    String title = _;
    result(title);
  });
}*/

loadingLayout({bool trans = false}) {
  return new Container(
    color: trans ? transparent : white,
    child: Stack(
      fit: StackFit.expand,
      children: <Widget>[
        /*
        Center(
          child: CircularProgressIndicator(
            //value: 20,
            valueColor: AlwaysStoppedAnimation<Color>(trans?white:blue5),
            strokeWidth: 2,
          ),
        ),*/
        Center(
            child: Container(
                width: 70,
                height: 70,
                child: LoadingIndicator(
                  indicatorType: Indicator.cubeTransition,
                  color: AppConfig.appColor,
                ))),
        Center(
          child: Opacity(
            opacity: 1,
            child: Image.asset(
              ic_plain,
//              color: white,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              //color: white,
            ),
          ),
        ),
      ],
    ),
  );
}

errorDialog(retry, cancel, {String text}) {
  return Stack(
    fit: StackFit.expand,
    children: <Widget>[
      Container(
        color: black.withOpacity(.8),
      ),
      Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: red0,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                          child: Text(
                        "!",
                        style: textStyle(true, 30, white),
                      ))),
                  addSpace(10),
                  Text(
                    "Error",
                    style: textStyle(false, 14, red0),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              text == null ? "An unexpected error occurred, try again" : text,
              style: textStyle(false, 14, white.withOpacity(.5)),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      )),
      Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: new Container(),
            flex: 1,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: FlatButton(
                      onPressed: retry,
                      child: Text(
                        "RETRY",
                        style: textStyle(true, 15, white),
                      )),
                ),
                addSpace(15),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: FlatButton(
                      onPressed: cancel,
                      child: Text(
                        "CANCEL",
                        style: textStyle(true, 15, white),
                      )),
                ),
              ],
            ),
          )
        ],
      ),
    ],
  );
}

addExpanded() {
  return Expanded(
    child: new Container(),
    flex: 1,
  );
}

addFlexible() {
  return Flexible(
    child: new Container(),
    flex: 1,
  );
}

emptyLayout(icon, String title, String text,
    {click,
    clickText,
    bool trans = false,
    bool noIconBack = false,
    iconColor = Colors.white}) {
  return Container(
    color: trans ? transparent : white,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            !(icon is String)
                ? Icon(
                    icon,
                    size: 50,
                    color: red0,
                  )
                : Image.asset(
                    icon,
                    height: 50,
                    width: 50,
                    color: red0,
                  ),
            addSpace(10),
            Text(
              title,
              style: textStyle(true, 20, trans ? white : black),
              textAlign: TextAlign.center,
            ),
            if (text.isNotEmpty) addSpace(5),
            if (text.isNotEmpty)
              Text(
                text,
                style: textStyle(false, 16,
                    trans ? (white.withOpacity(.5)) : black.withOpacity(.5)),
                textAlign: TextAlign.center,
              ),
            addSpace(10),
            click == null
                ? new Container()
                : FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    color: AppConfig.appColor,
                    onPressed: click,
                    child: Text(
                      clickText,
                      style: textStyle(true, 16, white),
                    ))
          ],
        ),
      ),
    ),
  );
}

List<String> getFromList(String key, List<BaseModel> models,
    {String sortKey, bool sortWithNumber = true}) {
  List<String> list = new List();
  //List<BaseModel> models = new List();

  if (sortKey != null) {
    models.sort((b1, b2) {
      if (sortWithNumber) {
        int a = b1.getInt(sortKey);
        int b = b2.getInt(sortKey);
        return a.compareTo(b);
      }
      String a = b1.getString(sortKey);
      String b = b2.getString(sortKey);
      return a.compareTo(b);
    });
  }

  for (BaseModel bm in models) {
    list.add(bm.getString(key));
  }

  return list;
}

int memberStatus(List list) {
  for (Map map in list) {
    BaseModel bm = new BaseModel(items: map);
    if (bm.getObjectId() == (userModel.getObjectId())) {
      if (bm.getBoolean(GROUP_ADMIN)) return ADMIN_MEMBER;
      return MEMBER;
    }
  }

  return NOT_MEMBER;
}

//bool levelHasLoaded = false;
//Map<String, BaseModel> levelList = new Map();
//
//bool schoolHasLoaded = false;
//Map<String, BaseModel> schoolList = new Map();
//
//bool studyHasLoaded;
//Map<String, BaseModel> studyList = new Map();

/*List<BaseModel> schoolList = new List();
List<BaseModel> studyList = new List();
List<BaseModel> levelList = new List();*/

/*void listenFromFire(String dBase, onLoaded) {
  Firestore.instance.collection(dBase).snapshots().listen((shots) {
    List<BaseModel> list = List();
    for (DocumentSnapshot d in shots.documents) {
      BaseModel model = BaseModel(doc: d);
      list.add(model);
    }
    onLoaded(list);
  });
}*/

pushAndResult(context, item, {result, opaque = false, bool depend = true}) {
  Navigator.push(
      context,
      PageRouteBuilder(
//          transitionsBuilder: transition,
          opaque: opaque,
          pageBuilder: (context, _, __) {
            return item;
          })).then((_) {
    if (_ != null) {
      if (result != null) result(_);
    }
  });
}

pushReplacementAndResult(context, item,
    {result, opaque = false, bool depend = true}) {
  Navigator.pushReplacement(
      context,
      PageRouteBuilder(
//          transitionsBuilder: transition,
          opaque: opaque,
          pageBuilder: (context, _, __) {
            return item;
          })).then((_) {
    if (_ != null) {
      if (result != null) result(_);
    }
  });
}

String getRandomId() {
  var uuid = new Uuid();
  return uuid.v1();
}

bool isLoggedIn = false;
bool isAdmin = true;
String currentProgress = "";
//String currentProgressText = "";
BaseModel currentUser = new BaseModel();

String getCountryCode(context) {
  return Localizations.localeOf(context).countryCode;
}

//String getDeviceId() {}
String getExtImage(String fileExtension) {
  if (fileExtension == null) return "";
  fileExtension = fileExtension.toLowerCase().trim();
  if (fileExtension.contains("doc")) {
    return icon_file_doc;
  } else if (fileExtension.contains("pdf")) {
    return icon_file_pdf;
  } else if (fileExtension.contains("xls")) {
    return icon_file_xls;
  } else if (fileExtension.contains("ppt")) {
    return icon_file_ppt;
  } else if (fileExtension.contains("txt")) {
    return icon_file_text;
  } else if (fileExtension.contains("zip")) {
    return icon_file_zip;
  } else if (fileExtension.contains("xml")) {
    return icon_file_xml;
  } else if (fileExtension.contains("png") ||
      fileExtension.contains("jpg") ||
      fileExtension.contains("jpeg")) {
    return icon_file_photo;
  } else if (fileExtension.contains("mp4") ||
      fileExtension.contains("3gp") ||
      fileExtension.contains("mpeg") ||
      fileExtension.contains("avi")) {
    return icon_file_video;
  } else if (fileExtension.contains("mp3") ||
      fileExtension.contains("m4a") ||
      fileExtension.contains("m4p")) {
    return icon_file_audio;
  }

  return icon_file_unknown;
}

getScreenWidth(context) {
  return MediaQuery.of(context).size.width;
}

getScreenHeight(context) {
  return MediaQuery.of(context).size.height;
}

uploadFile(File file, onComplete(res, error)) {
  final String ref = getRandomId();
  StorageReference storageReference = FirebaseStorage.instance.ref().child(ref);
  StorageUploadTask uploadTask = storageReference.putFile(file);
  uploadTask.onComplete
      /*.timeout(Duration(seconds: 3600), onTimeout: () {
    onComplete(null, "Error, Timeout");
  })*/
      .then((task) {
    if (task != null) {
      task.ref.getDownloadURL().then((_) {
        BaseModel model = new BaseModel();
        model.put(FILE_URL, _.toString());
        model.put(REFERENCE, ref);
        model.saveItem(REFERENCE_BASE, false);

        onComplete(_.toString(), null);
      }, onError: (error) {
        onComplete(null, error);
      });
    }
  }, onError: (error) {
    onComplete(null, error);
  });
}

Future<bool> isConnected() async {
  var result = await (Connectivity().checkConnectivity());
  if (result == ConnectivityResult.none) {
    return Future<bool>.value(false);
  }
  return Future<bool>.value(true);
}

void showProgress(bool show, BuildContext context,
    {String msg, bool cancellable = true, double countDown}) {
  String progressId = '1';
  if (!show) {
    currentProgress = progressId;
    return;
  }

  currentProgress = "";

  pushAndResult(
      context,
      progressDialog(
        progressId,
        message: msg,
        cancelable: cancellable,
      ),
      opaque: false,
      depend: false);
}

void showMessage(context, icon, iconColor, title, message,
    {int delayInMilli = 0,
    clickYesText = "OK",
    onClicked,
    clickNoText,
    bool cancellable = true,
    double iconPadding,
    bool = true,
    double textSize = 12}) {
  Future.delayed(Duration(milliseconds: delayInMilli), () {
    pushAndResult(
        context,
        messageDialog(
          icon,
          iconColor,
          title,
          message,
          clickYesText,
          noText: clickNoText,
          cancellable: cancellable,
          iconPadding: iconPadding,
          textSize: textSize,
        ),
        result: onClicked,
        opaque: false,
        depend: false);
  });
}

bool isEmailValid(String email) {
  if (!email.contains("@") || !email.contains(".")) return false;
  return true;
}

gradientLine({double height = 4, bool reverse = false, double alpha = .3}) {
  return Container(
    width: double.infinity,
    height: height,
    decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: FractionalOffset.topCenter,
            end: FractionalOffset.bottomCenter,
            colors: reverse
                ? [
                    black.withOpacity(alpha),
                    transparent,
                  ]
                : [transparent, black.withOpacity(alpha)])),
  );
}

openLink(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  }
}

void yesNoDialog(context, title, message, clickedYes,
    {bool cancellable = true, color = red0}) {
  Navigator.push(
      context,
      PageRouteBuilder(
          transitionsBuilder: transition,
          opaque: false,
          pageBuilder: (context, _, __) {
            return messageDialog(
              Icons.warning,
              color,
              title,
              message,
              "Yes",
              noText: "No, Cancel",
              cancellable: cancellable,
            );
          })).then((_) {
    if (_ != null) {
      if (_ == true) {
        clickedYes();
      }
    }
  });
}

String formatToK(int num) {
  return NumberFormat.compactCurrency(decimalDigits: 0, symbol: "").format(num);
}

formatPrice(String price) {
  if (price.contains("000000")) {
    price = price.replaceAll("000000", "");
    price = "${price}M";
  } else if (price.length > 6) {
    double pr = (int.parse(price)) / 1000000;
    return "${pr.toStringAsFixed(1)}M";
  } else if (price.contains("000")) {
    price = price.replaceAll("000", "");
    price = "${price}K";
  } else if (price.length > 3) {
    double pr = (int.parse(price)) / 1000;
    return "${pr.toStringAsFixed(1)}K";
  }
  return price;
}

replyThis(
  context,
  BaseModel comment,
  onEdited,
) {
  pushAndResult(
      context, inputDialog("Reply", hint: "Write a Reply...", okText: "SEND"),
      result: (_) {
    BaseModel model = new BaseModel();
    model.put(MESSAGE, _);
    model.put(ITEM_ID, comment.getString(ITEM_ID));
    model.put(COMMENT_ID, comment.getObjectId());
    model.saveItem(COMMENT_BASE, true);
    Future.delayed(Duration(seconds: 1), () {
      onEdited();

      createNotification([comment.getUserId()], "replied your comment", comment,
          ITEM_TYPE_COMMENT,
          user: userModel, id: "${comment.getObjectId()}");
      pushToPerson(comment, "replied your comment");
    });
  });
}

showCommentOptions(
    context, model, onEdited, onDeleted, bool myPost, bool isReply) {
  List<String> options = List();
  if (isAdmin) options.add(model.getBoolean(HIDDEN) ? "Unhide" : "Hide");
  if (isAdmin || model.myItem()) {
    options.addAll(["Edit", "Copy", "Delete"]);
  } else if (myPost) {
    options.addAll(["Copy", "Delete"]);
  } else {
    options.addAll(["Copy"]);
  }
  pushAndResult(context, listDialog(options), result: (_) {
    if (_ == "Hide") {
      yesNoDialog(context, "Hide Comment?",
          "Are you sure you want to hide this comment?", () {
        model.put(HIDDEN, true);
        onEdited();
      });
    } else if (_ == "Unhide") {
      model.put(HIDDEN, false);
      onEdited();
    } else if (_ == "Reply") {
      replyThis(
        context,
        model,
        onEdited(),
      );
    } else if (_ == "Edit") {
      pushAndResult(
          context,
          inputDialog("Edit Comment",
              message: model.getString(MESSAGE),
              hint: "Comment...",
              okText: "UPDATE"), result: (_) {
        model.put(MESSAGE, _.toString());
        model.updateItems();
        onEdited();
      });
    } else if (_ == "Delete") {
      yesNoDialog(
          context, "Delete?", "Are you sure you want to delete this comment?",
          () {
        model.deleteItem();
        /*commentsList
            .removeWhere((bm) => bm.getObjectId() == model.getObjectId());*/
        onDeleted(model);
      });
    } else if (_ == "Copy") {
//      ClipboardManager.copyToClipBoard(model.getString(MESSAGE));
    }
  });
}

refreshUser(BaseModel model /*, BaseModel theUser*/) {
  if (model == null) return;

  Firestore.instance
      .collection(USER_BASE)
      .document(model.getString(USER_ID))
      .get()
      .then((shot) {
    BaseModel theUser = BaseModel(doc: shot);
    String name = theUser.getString(NAME);
    String image = theUser.getString(USER_IMAGE);

    if (name != model.getString(NAME) || image != model.getString(USER_IMAGE)) {
      model.put(NAME, name);
      model.put(USER_IMAGE, image);
      model.updateItems();
    }
  });
}

String showAllId = "";

void uploadItem(StreamController<String> uploadingController,
    String uploadingText, String successText, BaseModel model,
    {BaseModel listExtras, onComplete}) {
  List keysToUpload = model.getList(FILES_TO_UPLOAD);
  if (keysToUpload.isEmpty) {
    model.saveItem(model.getString(DATABASE_NAME), true,
        document: model.getObjectId(), onComplete: () {
      if (successText != null) {
        uploadingController.add(successText);
        Future.delayed(Duration(seconds: 2), () {
          uploadingController.add(null);
        });
      }
      if (onComplete != null) onComplete();
    });
    return;
  }

  if (uploadingText != null) uploadingController.add(uploadingText);

  String key = keysToUpload[0];
  var item = model.get(key);

  if (item is List) {
    uploadItemFiles(item, List(), (res, error) {
      if (error != null) {
        uploadItem(uploadingController, uploadingText, successText, model,
            listExtras: listExtras, onComplete: onComplete);
        return;
      }
      if (listExtras != null) {
        List ext = List.from(listExtras.getList(key));
        //List ext = List.from(extraImages);
        ext.addAll(res);
        model.put(key, ext);
      } else {
        model.put(key, res);
      }
      keysToUpload.removeAt(0);
      model.put(FILES_TO_UPLOAD, keysToUpload);
      uploadItem(uploadingController, uploadingText, successText, model,
          listExtras: listExtras, onComplete: onComplete);
    });
  } else {
    List list = List();
    list.add(item);
    uploadItemFiles(list, List(), (res, error) {
      if (error != null) {
        uploadItem(uploadingController, uploadingText, successText, model,
            listExtras: listExtras, onComplete: onComplete);
        return;
      }
      List urls = res;
      model.put(key, urls[0].toString());
      keysToUpload.removeAt(0);
      model.put(FILES_TO_UPLOAD, keysToUpload);
      uploadItem(uploadingController, uploadingText, successText, model,
          listExtras: listExtras, onComplete: onComplete);
    });
  }
}

uploadItemFiles(List files, List urls, onComplete) {
  if (files.isEmpty) {
    onComplete(urls, null);
    return;
  }
  var item = files[0];
  var file = item is String ? File(item) : item;
  uploadFile(file, (res, error) {
    if (error != null) {
      onComplete(null, error);
      return;
    }

    files.removeAt(0);
    urls.add(res.toString());
    uploadItemFiles(files, urls, onComplete);
  });
}

String getFirstPhoto(List images) {
  String image = "";
  if (images.isNotEmpty) {
    var item = images[0];
    BaseModel m;
    if (item is Map) {
      m = BaseModel(items: item);
    } else {
      m = item;
    }
    if (m.getBoolean(IS_VIDEO)) {
      image = m.getString(THUMBNAIL_URL);
    } else {
      image = m.getString(IMAGE_URL);
    }
  }
  return image;
}

uploadMediaFiles(List<BaseModel> photos,
    {onUploaded(List<BaseModel> uploaded), onError}) async {
  List<BaseModel> upload = [];
  for (int p = 0; p < photos.length; p++) {
    BaseModel photo = photos[p];
    bool isLocal = photo.isLocal;
    bool isVideo = photo.isVideo;
    if (isLocal) {
      File file = File(photo.imageUrl);
      if (!await file.exists()) continue;
      uploadFile(file, (res, err) {
        if (null != err) {
          onError(err);
          return;
        }
        if (isVideo) {
          File thumbFile = File(photo.thumbnailUrl);
          uploadFile(thumbFile, (resVideo, error) {
            if (null != err) {
              onError(err);
              return;
            }

            final bm = BaseModel()
              ..put(IMAGE_URL, res)
              ..put(THUMBNAIL_URL, resVideo)
              ..put(IS_VIDEO, true);

            upload.add(bm);
            if (p == photos.length - 1) {
              onUploaded(upload);
            }
          });
          return;
        }

        final bm = BaseModel()..put(IMAGE_URL, res);

        upload.add(bm);
        if (p == photos.length - 1) {
          onUploaded(upload);
        }
      });
    } else {
      upload.add(photo);
      if (p == photos.length - 1) {
        onUploaded(upload);
      }
    }
  }
}

Future<String> get localPath async {
  final directory = await getApplicationDocumentsDirectory();
  // if (Platform.isIOS) directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<bool> checkLocalFile(String name) async {
  final path = await localPath;
  File file = File('$path/$name');
  return await file.exists();
}

Future<File> getLocalFile(String name) async {
  final path = await localPath;
  return File('$path/$name');
}

Future<File> getDirFile(String name) async {
  final dir = Platform.isIOS
      ? await getApplicationDocumentsDirectory()
      : await getExternalStorageDirectory();
  var testDir =
      await Directory("${dir.path}/maugost_apps").create(recursive: true);
  return File("${testDir.path}/$name");
}

String formatDuration(Duration position) {
  final ms = position.inMilliseconds;

  int seconds = ms ~/ 1000;
  final int hours = seconds ~/ 3600;
  seconds = seconds % 3600;
  var minutes = seconds ~/ 60;
  seconds = seconds % 60;

  final hoursString = hours >= 10 ? '$hours' : hours == 0 ? '00' : '0$hours';

  final minutesString =
      minutes >= 10 ? '$minutes' : minutes == 0 ? '00' : '0$minutes';

  final secondsString =
      seconds >= 10 ? '$seconds' : seconds == 0 ? '00' : '0$seconds';

  final formattedTime =
      '${hoursString == '00' ? '' : hoursString + ':'}$minutesString:$secondsString';

  return formattedTime;
}

int getPositionForLetter(String text) {
  return az.indexOf(text.toUpperCase());
}

String az = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
String getLetterForPosition(int position) {
  return az.substring(position, position + 1);
}

String convertListToString(String divider, List list) {
  StringBuffer sb = new StringBuffer();
  for (int i = 0; i < list.length; i++) {
    String s = list[i];
    sb.write(s);
    sb.write(" ");
    if (i != list.length - 1) sb.write(divider);
    sb.write(" ");
  }

  return sb.toString().trim();
}

List<String> convertStringToList(String divider, String text) {
  List<String> list = new List();
  var parts = text.split(divider);
  for (String s in parts) {
    list.add(s.trim());
  }
  return list;
}

class ReadMoreText extends StatefulWidget {
  String text;
  bool full;
  var toggle;
  int minLength;
  double fontSize;
  var textColor;
  var moreColor;
  bool center;
  bool canExpand;

  ReadMoreText(
    this.text, {
    this.full = false,
    this.minLength = 150,
    this.fontSize = 14,
    this.toggle,
    this.textColor,
    this.moreColor = blue0,
    this.center = false,
    this.canExpand = true,
  });

  @override
  _ReadMoreTextState createState() => _ReadMoreTextState();
}

class _ReadMoreTextState extends State<ReadMoreText> {
  bool expanded;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    expanded = widget.full;
  }

  @override
  Widget build(BuildContext context) {
    return text();
  }

  text() {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
              text: widget.text.length <= widget.minLength
                  ? widget.text
                  : expanded
                      ? widget.text
                      : (widget.text.substring(0, widget.minLength)),
              style:
                  textStyle(false, widget.fontSize, widget.textColor ?? black)),
          TextSpan(
              text: widget.text.length < widget.minLength || expanded
                  ? ""
                  : "...",
              style: textStyle(false, widget.fontSize, black)),
          TextSpan(
            text: widget.text.length < widget.minLength
                ? ""
                : expanded ? " Read Less" : "Read More",
            style: textStyle(true, widget.fontSize - 2, widget.moreColor,
                underlined: false),
            recognizer: new TapGestureRecognizer()
              ..onTap = () {
                setState(() {
                  if (widget.canExpand) expanded = !expanded;
                  if (widget.toggle != null) widget.toggle(expanded);
                });
              },
          )
        ],
      ),
      textAlign: widget.center ? TextAlign.center : TextAlign.left,
    );
  }
}

moreButton(String text, onTapped) {
  return new Container(
    height: 22,
    width: 70,
    child: new FlatButton(
        padding: EdgeInsets.all(0),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: black.withOpacity(.1), width: 1)),
        color: blue09,
        onPressed: onTapped,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            //addSpaceWidth(10),
            Text(
              text,
              style: textStyle(true, 10, black.withOpacity(.5)),
              maxLines: 1,
            ),
            //addSpaceWidth(10),
          ],
        )),
  );
}

marketMoreItem(context, BaseModel bm, onTap) {
  List images = bm.getList(IMAGES);
  String firstImage = images.isEmpty ? "" : images[0];
  return new Container(
    width: 130,
    child: GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: .5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CachedNetworkImage(
              height: 100,
              placeholder: (c, p) {
                return placeHolder(100);
              },
              imageUrl: firstImage,
              fit: BoxFit.cover,
            ),
            new Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    bm.getString(ITEM_NAME),
                    maxLines: bm.getInt(TYPE) == MARKET_TYPE_SERVICES ? 2 : 1,
                    //textAlign: TextAlign.center,
                    style: textStyle(true, 10, black),
                    overflow: TextOverflow.ellipsis,
                  ),
                  //addSpace(5),
//                  Text(
//                    bm.getString(DESCRIPTION),
//                    maxLines: 2,
//                    //textAlign: TextAlign.center,
//                    style: textStyle(false, 12, black.withOpacity(.5)),
//                    overflow: TextOverflow.ellipsis,
//                  ),
                  //addSpace(6),
//                  type == MARKET_TYPE_SERVICES
//                      ? Container()
//                      : addLine(.5, black.withOpacity(.1), 0, 6, 0, 3),
                  bm.getInt(TYPE) == MARKET_TYPE_SERVICES
                      ? Container()
                      : Container(
                          margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              /*Image.asset(
                                currencies[currenciesText
                                    .indexOf(bm.getString(CURRENCY))],
                                //fit: BoxFit.cover,
                                width: 10,
                                height: 10,
                                color: blue3.withOpacity(.5),
                              ),*/
                              //addSpaceWidth(3),
                              Flexible(
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 2),
                                  child: Text(
                                    bm.getString(PRICE),
                                    maxLines: 1,
                                    style: textStyle(
                                        true, 10, blue3.withOpacity(.5)),
                                  ),
                                ),
                              ),
                              /*addSpaceWidth(5),
                              Icon(
                                Icons.bookmark_border,
                                size: 15,
                                color: blue0,
                              )*/
                            ],
                          )),
                ],
              ),
            )
          ],
        ),
      ),
    ),
  );
}

marketItem(context, BaseModel bm, int size) {
  int type = bm.getType();
  List images = bm.getList(IMAGES);
  String firstImage = images.isEmpty ? "" : images[0];
  return new Container(
    child: GestureDetector(
      onTap: () {
        //pushAndResult(context, MarketMain(bm, bm.getType()));
      },
      onLongPress: () {
        if (isAdmin) {
          pushAndResult(context, listDialog(["Change Type"]), result: (_) {
            if (_ == "Change Type") {
              var options = ["Items", "Foodstuff", "Services"];
              pushAndResult(context, listDialog(options), result: (_) {
                bm.put(TYPE, options.indexOf(_));
                bm.updateItems();
              });
            }
          });
        }
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: .5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CachedNetworkImage(
              height: double.parse(size.toString()),
              placeholder: (c, p) {
                return Container(
                  height: double.parse(size.toString()),
                  color: blue0.withOpacity(.1),
                  child: Center(
                      child: Opacity(
                          opacity: .3,
                          child: Image.asset(
                            ic_launcher,
                            width: 20,
                            height: 20,
                          ))),
                );
              },
              imageUrl: firstImage,
              fit: BoxFit.cover,
            ),
            new Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    bm.getString(ITEM_NAME),
                    maxLines: 2,
                    //textAlign: TextAlign.center,
                    style: textStyle(true, 10, black),
                    overflow: TextOverflow.ellipsis,
                  ),
                  //addSpace(5),
//                  Text(
//                    bm.getString(DESCRIPTION),
//                    maxLines: 2,
//                    //textAlign: TextAlign.center,
//                    style: textStyle(false, 12, black.withOpacity(.5)),
//                    overflow: TextOverflow.ellipsis,
//                  ),
                  //addSpace(6),
//                  type == MARKET_TYPE_SERVICES
//                      ? Container()
//                      : addLine(.5, black.withOpacity(.1), 0, 6, 0, 3),
                  type == MARKET_TYPE_SERVICES
                      ? Container()
                      : Container(
                          margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              /*Image.asset(
                                currencies[currenciesText
                                    .indexOf(bm.getString(CURRENCY))],
                                //fit: BoxFit.cover,
                                width: 10,
                                height: 10,
                                color: blue3.withOpacity(.5),
                              ),*/
                              //addSpaceWidth(3),
                              Flexible(
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 2),
                                  child: Text(
                                    bm.getString(PRICE),
                                    maxLines: 1,
                                    style: textStyle(
                                        true, 10, blue3.withOpacity(.5)),
                                  ),
                                ),
                              ),
                              /*addSpaceWidth(5),
                              Icon(
                                Icons.bookmark_border,
                                size: 15,
                                color: blue0,
                              )*/
                            ],
                          )),
                ],
              ),
            )
          ],
        ),
      ),
    ),
  );
}

marketAdItem(context, BaseModel bm) {
  List images = bm.getList(IMAGES);
  if (images.isNotEmpty) images.shuffle();
  String firstImage = images.isEmpty ? "" : images[0];
  firstImage = firstImage.isEmpty ? bm.getString(THUMBNAIL_URL) : firstImage;
  int iconPosition = actionTexts.indexOf(bm.getString(ACTION_TEXT));
  return new Container(
    width: 120,
    height: 150,
    child: Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      elevation: .5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: new CachedNetworkImage(
              //height: 80,
              /*placeholder: (c, p) {
                return Container(
                  height: 80,
                  color: blue0.withOpacity(.1),
                  child: Center(
                      child: Opacity(
                          opacity: .3,
                          child: Image.asset(
                            ic_launcher,
                            width: 20,
                            height: 20,
                          ))),
                );
              },*/
              imageUrl: firstImage,
              fit: BoxFit.cover,
            ),
          ),
          /*new Container(
            width: double.infinity, color: blue09,
//                    decoration: BoxDecoration(
//                        color: blue09,
//                        borderRadius: BorderRadius.circular(25),
//                        border: Border.all(color: default_white, width: 1)),
            child: new Padding(
              padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    ic_world,
                    color: black.withOpacity(.4),
                    width: 8,
                    height: 8,
                  ),
                  addSpaceWidth(3),
                  Flexible(
                    flex: 1,
                    child: Text(
                      "Sponsored",
                      maxLines: 1,
                      style: textStyle(false, 8, black.withOpacity(.4)),
                    ),
                  ),
                  addSpaceWidth(3),
                ],
              ),
            ),
          ),*/
          addSpace(3),
          new Padding(
            padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  bm.getString(ITEM_NAME),
                  maxLines: 1,
                  //textAlign: TextAlign.center,
                  style: textStyle(true, 10, black),
                  //overflow: TextOverflow.ellipsis,
                ),
                bm.getString(SHORT_DESCRIPTION).isEmpty
                    ? Container()
                    : addSpace(3),
                bm.getString(SHORT_DESCRIPTION).isEmpty
                    ? Container()
                    : Text(
                        bm.getString(SHORT_DESCRIPTION),
                        maxLines: 2,
                        //textAlign: TextAlign.center,
                        style: textStyle(false, 9, black.withOpacity(.5)),
                        overflow: TextOverflow.ellipsis,
                      ),
              ],
            ),
          ),
          new Container(
              height: 22,
              width: double.infinity,
//                decoration: BoxDecoration(
//                    color: red0, borderRadius: BorderRadius.circular(5)),
              margin: EdgeInsets.all(5),
              child: FlatButton(
                padding: EdgeInsets.all(0),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                    side: BorderSide(color: black.withOpacity(.1), width: 1)),
                color: red0,
                onPressed: () {
                  clickOnAd(context, bm);
                },
                child: Center(
                    child: Text(
                  bm.getString(ACTION_TEXT).toUpperCase(),
                  style: textStyle(true, 8, white),
                  maxLines: 1,
                )),
              ) /*new Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                addSpaceWidth(5),
                Center(
                    child: iconPosition == -1
                        ? Container()
                        : Icon(
                            actionIcons[iconPosition],
                            color: white.withOpacity(.7),
                            size: 10,
                          )),
                iconPosition == -1 ? Container() : addSpaceWidth(3),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Text(
                    bm.getString(ACTION_TEXT),
                    style: textStyle(true, 8, white),
                    maxLines: 1,
                  ),
                ),
//                            addSpaceWidth(10),
//                            Center(
//                                child: Icon(
//                                  Icons.navigate_next,
//                                  color: white.withOpacity(.6),
//                                  size: 16,
//                                )),
                addSpaceWidth(5),
              ],
            ),*/
              ),
        ],
      ),
    ),
  );
}

createReport(context, BaseModel theModel, int type, String message) {
  BaseModel report = BaseModel();
  report.put(MESSAGE, message);
  report.put(THE_MODEL, theModel.items);
  report.put(REPORT_TYPE, type);
  report.put(STATUS, STATUS_UNDONE);
  report.saveItem(REPORT_BASE, true);
  NotificationService.sendPush(
      topic: 'admin',
      title: 'Pending',
      tag: 'reports',
      body: 'Some reports are pending');
  showMessage(context, Icons.report, blue0, "Report Sent",
      "Thank you for submitting a report, we will review this and take neccessary actions",
      cancellable: true, delayInMilli: 500);
}

groupItem(context, BaseModel model, onTap) {
  List members = model.getList(GROUP_MEMBERS);
  int count = members.length;
  count = count == 0 ? 1 : count;
  String countText =
      count.toString().replaceAll("000000", "M").replaceAll("000", "K");
  List images = model.getList(IMAGES);
  String firstImage = images.isEmpty ? "" : images[0];
  return Container(
    child: Center(
      child: Container(
        width: 300,
        height: 300,
        child: GestureDetector(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              firstImage.isEmpty
                  ? Container()
                  : Card(
                      shape: CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      color: blue0,
                      elevation: .5,
                      child: Stack(
                        children: <Widget>[
                          CachedNetworkImage(
                            imageUrl: firstImage,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            color: black.withOpacity(.5),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  model.getString(GROUP_NAME),
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: textStyle(false, 12, white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Flexible(
                    child: Container(),
                    flex: 1,
                  ),
                  new Container(
                    height: 25,
                    margin: EdgeInsets.fromLTRB(0, 5, 5, 0),
                    decoration: BoxDecoration(
                        color: red0,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: white, width: 1)),
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.person,
                            size: 12,
                            color: white.withOpacity(.8),
                          ),
                          addSpaceWidth(2),
                          Text(
                            countText,
                            style: textStyle(false, 12, white),
                          )
                        ],
                      ),
                    )),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    ),
  );
}

updateMyTopics(String id, bool add) {
  if (!userModel.getBoolean(PUSH_NOTIFICATION)) return;
  List myTopics = List.from(userModel.getList(TOPICS));
  if (add) {
    firebaseMessaging.subscribeToTopic(id);
    myTopics.add(id);
  } else {
    firebaseMessaging.unsubscribeFromTopic(id);
    myTopics.remove(id);
  }
  userModel.put(TOPICS, myTopics);
  userModel.updateItems();
}

void createNotification(
    List parties, String message, BaseModel theModel, int type,
    {BaseModel user, String id}) {
  if (theModel != null && theModel.myItem()) {
    return;
  }
  //toastInAndroid("Notifying");

  if (id == null) {
    BaseModel model = BaseModel();
    model.put(PARTIES, parties);
    model.put(MESSAGE, message);
    if (theModel != null) model.put(THE_MODEL, theModel.items);
    model.put(TYPE, type);
    //model.put(PEOPLE, people);
    model.saveItem(NOTIFY_BASE, true);
    return;
  }

  Firestore.instance.collection(NOTIFY_BASE).document(id).get().then((_) {
    //toastInAndroid(_.toString());
    BaseModel model = BaseModel(doc: _);
    List people = List.from(model.getList(PEOPLE));
    int p = people.indexWhere(
      (map) => map[USER_ID] == user.getUserId(),
    );
    //toastInAndroid(p.toString());
    if (p == -1) {
      model.put(PARTIES, parties);
      model.put(MESSAGE, message);
      if (theModel != null) model.put(THE_MODEL, theModel.items);
      model.put(TYPE, type);

      Map thePerson = Map();
      thePerson[USER_ID] = user.getUserId();
      thePerson[USER_IMAGE] = user.getString(USER_IMAGE);
      thePerson[NAME] = user.getString(NAME);

      people.add(thePerson);
      model.put(PEOPLE, people);
      model.put(READ_BY, List());

      if (!_.exists) {
        model.saveItem(NOTIFY_BASE, true, document: id);
      } else {
        model.updateItems();
      }
    }
  }, onError: (_) {
    //toastInAndroid(_.toString());
    createNotification(parties, message, theModel, type, id: id, user: user);
  });
}

tipMessageItem(String title, String message) {
  return Container(
    //width: 300,
    //height: 300,
    child: new Card(
        color: red03,
        elevation: .5,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: new Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.info,
                    size: 14,
                    color: white,
                  ),
                  addSpaceWidth(5),
                  Text(
                    title,
                    style: textStyle(true, 12, white.withOpacity(.5)),
                  ),
                ],
              ),
              addSpace(5),
              Text(
                message,
                style: textStyle(false, 16, white),
                //overflow: TextOverflow.ellipsis,
              ),
              /*Container(
                margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                decoration: BoxDecoration(
                    color: white, borderRadius: BorderRadius.circular(3)),
                child: Text(
                  "APPLY",
                  style: textStyle(true, 9, black),
                ),
              ),*/
            ],
          ),
        )),
  );
}

niceButton(double width, text, click, image,
    {bool = false, bool selected = false}) {
  return new Container(
    width: width,
    child: new FlatButton(
        padding: EdgeInsets.all(0),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
            side: BorderSide(color: blue0, width: 1),
            borderRadius: BorderRadius.circular(25)),
        color: selected ? blue0 : transparent,
        onPressed: click,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            addSpaceWidth(15),
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Text(
                text,
                style: textStyle(true, 12, selected ? white : blue0),
                maxLines: 1,
              ),
            ),
            addSpaceWidth(10),
            new Container(
                margin: EdgeInsets.fromLTRB(0, 0, 15, 0),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                    color: selected ? white : blue0, shape: BoxShape.circle),
                child: Center(
                    child: (image is String)
                        ? Image.asset(
                            image,
                            width: 12,
                            height: 12,
                            color: selected ? blue0 : white,
                          )
                        : Icon(
                            image,
                            color: selected ? blue0 : white,
                            size: 12,
                          ))),
          ],
        )),
  );
}

clickOnAd(context, BaseModel model) {
  List<String> clicks = List.from(model.getList(CLICKS));

  String action = model.getString(ACTION_TEXT);
  if (action != CONTACT_US) {
    model.putInList(CLICKS, userModel.getObjectId(), true);
    model.updateItems();

    openLink(model.getString(ACTION_LINK));

    /*if (!clicks.contains(userModel.getObjectId())) {
      clicks.add(userModel.getObjectId());
      model.put(CLICKS, clicks);
      model.updateListWithMyId(CLICKS, true);
    }*/
  } else {
    List<String> options = List();
    List optionsIcons = List();
    String phone = model.getString(CONTACT_PHONE);
    String email = model.getString(CONTACT_EMAIL);
    String whats = model.getString(CONTACT_WHATS);
    whats = whats.replaceAll("+", "");

    if (phone.isNotEmpty) {
      options.add("Call Now");
      optionsIcons.add(Icons.call);
    }
    if (email.isNotEmpty) {
      options.add("Send Email");
      optionsIcons.add(Icons.email);
    }
    if (whats.isNotEmpty) {
      options.add("Chat on Whatsapp");
      optionsIcons.add(Icons.chat_bubble);
    }

    pushAndResult(
        context,
        listDialog(
          options,
          images: optionsIcons,
          title: "Contact Us",
        ), result: (_) {
      if (_ == "Call Now") {
        openLink("tel://$phone");
      }
      if (_ == "Send Email") {
        openLink(
            "mailto:$email?subject=${model.getString(ITEM_NAME)}&body=${"Hi, i am interested in your ad i saw on maugost_apps App"}");
      }
      if (_ == "Chat on Whatsapp") {
        openLink(
            "https://wa.me/$whats?text=${"Hi, i am interested in your ad \"${model.getString(ITEM_NAME)}\" i saw on Strokes App"}");
      }

      model.putInList(CLICKS, userModel.getObjectId(), true);
      model.updateItems();
      /*if (!clicks.contains(userModel.getObjectId())) {
        clicks.add(userModel.getObjectId());
        model.put(CLICKS, clicks);
        model.updateListWithMyId(CLICKS, true);
      }*/
    });
  }
}

placeCall(String phone) {
  openLink("tel://$phone");
}

sendEmail(String email) {
  openLink("mailto:$email");
}

//List<BaseModel> levelList = List();

void showLevels(context, onSelected) async {
  showProgress(true, context, cancellable: true);
  List<BaseModel> levelList = [];
  QuerySnapshot shots =
      await Firestore.instance.collection(LEVEL_BASE).getDocuments();
  for (DocumentSnapshot shot in shots.documents) {
    BaseModel model = BaseModel(doc: shot);
    if (model.getInt(STATUS) == PENDING) continue;
    levelList.add(model);
  }
  showProgress(false, context);
  Future.delayed(Duration(milliseconds: 700), () {
    List<String> items = getFromList(TITLE, levelList, sortKey: INDEX);
    //toastInAndroid(items.length.toString());
    Navigator.push(
        context,
        PageRouteBuilder(
            transitionsBuilder: transition,
            opaque: false,
            pageBuilder: (context, _, __) {
              return listDialog(
                items,
                title: "Select level",
              );
            })).then((_) {
      if (_ != null) {
        onSelected(_);
      }
    });
  });
}

smallButton(icon, text, clicked) {
  return new Container(
    height: 40,
    child: new FlatButton(
        padding: EdgeInsets.all(0),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        color: blue09,
        onPressed: clicked,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            addSpaceWidth(10),
            Center(
                child: Icon(
              icon,
              color: blue0,
              size: 14,
            )),
            addSpaceWidth(5),
            Text(
              text,
              style: textStyle(true, 12, blue0),
              maxLines: 1,
            ),
            addSpaceWidth(12),
          ],
        )),
  );
}

List<String> getSearchString(String text) {
  text = text.toLowerCase().trim();
  if (text.isEmpty) return List();

  List<String> list = List();
  list.add(text);
  var parts = text.split(" ");
  for (String s in parts) {
    if (s.isNotEmpty) list.add(s);
    for (int i = 0; i < s.length; i++) {
      String sub = s.substring(0, i);
      if (sub.isNotEmpty) list.add(sub);
    }
  }
  for (int i = 0; i < text.length; i++) {
    String sub = text.substring(0, i);
    if (sub.isNotEmpty) list.add(sub.trim());
  }
  return list;
}

filterItem(
    bool selected, image, double iconSize, String text, onTapped, onRemoved,
    {bool = false, bool useTint = true}) {
  return Container(
    height: 30,
    color: selected ? white : blue2,
    child: InkWell(
      onTap: onTapped,
      child: Container(
        height: 30,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            addSpaceWidth(10),
            !(image is String)
                ? Icon(
                    image,
                    size: iconSize,
                    color: !useTint ? null : selected ? blue1 : white,
                  )
                : Image.asset(
                    image,
                    color: !useTint ? null : selected ? blue1 : white,
                    width: iconSize,
                    height: iconSize,
                  ),
            addSpaceWidth(5),
            Text(
              text,
              style: textStyle(false, 14, selected ? blue1 : white),
            ),
            addSpaceWidth(10),
            !selected
                ? Container()
                : InkWell(
                    onTap: onRemoved,
                    child: Container(
                      width: 30,
                      height: 30,
                      //margin: EdgeInsets.fromLTRB(6, 0, 0, 0),
                      color: blue09,
                      child: Center(
                        child: Icon(
                          Icons.close,
                          size: 12,
                          color: black.withOpacity(.5),
                        ),
                      ),
                    ),
                  )
          ],
        ),
      ),
    ),
  );
}

handleMobileCredits(String id, String userId, int credits, bool add,
    {onAdded, bool hasFree = false}) async {
  if (userId == userModel.getObjectId()) {
    hmcr(
      userModel,
      id,
      credits,
      add,
      hasFree,
      onAdded: onAdded,
    );
    return;
  }
  Firestore.instance
      .collection(USER_BASE)
      .document(userId)
      .get(source: Source.server)
      .then((shot) {
    BaseModel model = BaseModel(doc: shot);
    hmcr(model, id, credits, add, hasFree);
  }, onError: (e) {
    handleMobileCredits(id, userId, credits, add);
  });
}

hmcr(BaseModel model, String id, int credits, bool add, bool hasFree,
    {onAdded}) {
  List mcrIds = model.getList(MCR_IDS);
  int mcr = model.getInt(MCR);
  int mcrFree = model.getInt(MCR_FREE);
  if (!mcrIds.contains(id)) {
    mcrIds.add(id);
    model.put(MCR_IDS, mcrIds);

    if (add) {
      mcr = mcr + credits;
      if (hasFree) {
        mcrFree = mcrFree + credits;
      }
    } else {
      mcr = mcr - credits;
      mcrFree = mcrFree > mcr ? mcr : mcrFree;
    }

    model.put(MCR, mcr);
    model.put(MCR_FREE, mcrFree);
    model.updateItems();
    if (onAdded != null) onAdded();

    if (add) {
      createNotification(
        [model.getObjectId()],
        "You have been credited with $credits Coins",
        null,
        ITEM_TYPE_MCR,
      );
      if (model.getBoolean(PUSH_NOTIFICATION)) {
        NotificationService.sendPush(
          body: "You have been credited with $credits Coins",
          token: model.getString(TOKEN),
        );
      }
    }
  }
}

rateApp() {
  String packageName = appSettingsModel.getString(PACKAGE_NAME);
  if (packageName.isEmpty) return;

  userModel.put(HAS_RATED, true);
  userModel.updateItems();
  String link = "http://play.google.com/store/apps/details?id=$packageName";
  openLink(link);
}

userItem(context, BaseModel user, onFollowed, {bool hidden = false}) {
  int now = DateTime.now().millisecondsSinceEpoch;
  int lastUpdated = user.getInt(TIME_UPDATED);
  bool notOnline =
      ((now - lastUpdated) > (Duration.millisecondsPerMinute * 10));
  bool isOnline = user.getBoolean(IS_ONLINE) && (!notOnline) && !hidden;
  int gender = user.getInt(GENDER);
  return new InkWell(
    onTap: () {
      if (hidden) return;
      // pushAndResult(
      //     context,
      //     MyProfile1(
      //       user,
      //     ));
    },
    //margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
    child: Container(
      //color: white,
      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Stack(
                //fit: StackFit.expand,
                children: <Widget>[
                  new Card(
                    shape:
                        CircleBorder(side: BorderSide(color: blue09, width: 1)),
                    clipBehavior: Clip.antiAlias,
                    color: white,
                    elevation: .5,
                    child: Stack(
                      children: <Widget>[
                        Container(
                          width: 50,
                          height: 50,
                          color: blue09,
                          child: Center(
                              child: Image.asset(
                                  gender == MALE ? ic_male : ic_female,
                                  color: blue0,
                                  width: 20,
                                  height: 20)),
                        ),
                        if (!hidden)
                          CachedNetworkImage(
                            width: 50,
                            height: 50,
                            imageUrl: user.getString(USER_IMAGE),
                            fit: BoxFit.cover,
                          ),
                      ],
                    ),
                  ),
                  !isOnline
                      ? Container()
                      : Container(
                          width: 10,
                          height: 10,
                          margin: EdgeInsets.fromLTRB(5, 5, 0, 0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: white, width: 2),
                            color: red0,
                          ),
                        ),
                ],
              ),
              addSpaceWidth(10),
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Text(
                  //"Emeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",
                  user.getString(NAME),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: textStyle(true, 18, white),
                ),
              ),
              addSpaceWidth(10),
              Container(
                width: 40,
                height: 40,
                child: FlatButton(
                  onPressed: () {
                    clickChat(context, user, false);
                  },
                  shape: CircleBorder(side: BorderSide(color: white, width: 2)),
                  child: Icon(
                    Icons.chat,
                    color: white,
                    size: 20,
                  ),
                  padding: EdgeInsets.all(0),
                ),
              )
            ],
          ),
          addSpace(5),
          addLine(.5, white.withOpacity(.1), 0, 5, 0, 0)
        ],
      ),
    ),
  );
}

label(icon, String text, double iconSize, {bool showLine = true}) {
  if (text.isEmpty) return Container();
  return Container(
    //height: 30,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                  color: blue09,
                  shape: BoxShape.circle,
                  border: Border.all(color: black.withOpacity(.1), width: .5)),
              child: Center(
                child: !(icon is String)
                    ? Icon(icon, size: iconSize, color: black.withOpacity(.5))
                    : Image.asset(
                        icon,
                        width: iconSize,
                        height: iconSize,
                        color: black.withOpacity(.5),
                      ),
              ),
            ),
            addSpaceWidth(5),
            Flexible(
              child: Text(
                text,
                style: textStyle(false, 12, black.withOpacity(.4)),
              ),
            )
          ],
        ),
        !showLine
            ? Container()
            : addLine(.5, black.withOpacity(.1), 25, 0, 0, 0),
      ],
    ),
  );
}

clickFollow(BaseModel personModel) {
  String uId = personModel.getObjectId();
  bool following = userModel.getList(FOLLOWING).contains(uId);
  if (!following) {
    createNotification([personModel.getUserId()], "started following you", null,
        ITEM_TYPE_PROFILE,
        user: userModel, id: "${personModel.getObjectId()}follow");
    if (personModel.getBoolean(PUSH_NOTIFICATION)) {
      Map data = Map();
      data[TYPE] = PUSH_TYPE_FOLLOW;
      data[OBJECT_ID] = userModel.getObjectId();
      NotificationService.sendPush(
          body: "${userModel.getString(NAME)} started following you",
          token: personModel.getString(TOKEN),
          tag: '${userModel.getObjectId()}follow',
          data: data);
    }
  }
  personModel.putInList(FOLLOWERS, userModel.getObjectId(), !following);
  userModel.putInList(FOLLOWING, uId, !following);
  personModel.updateItems(updateTime: false);
  userModel.updateItems(updateTime: false);
  updateMyTopics(personModel.getObjectId(), !following);
}

notifyCourseFollowers(BaseModel model) async {
  String courseId = model.getString(COURSE_ID);
  String courseName = model.getString(COURSE_NAME);
  DocumentSnapshot doc = await Firestore.instance
      .collection(STUDY_BASE)
      .document(courseId)
      .get(source: Source.server)
      .catchError((e) {
    notifyCourseFollowers(model);
  });

  if (doc == null) return;
  BaseModel course = BaseModel(doc: doc);
  if (course != null) {
    List followers = course.getList(FOLLOWERS);
    if (followers.isNotEmpty) {
      createNotification(
          followers,
          "A new document on $courseName is available",
          model,
          ITEM_TYPE_LIBRARY);
      Map data = Map();
      data[TYPE] = PUSH_TYPE_LIB;
      data[OBJECT_ID] = model.getObjectId();
      NotificationService.sendPush(
          title: 'Library',
          body:
              "A new document on ${courseName.toLowerCase().trim()} is available",
          topic: course.getObjectId(),
          tag: model.getObjectId(),
          data: data);
    }
  }
}

pushToPerson(BaseModel model, String message, {String title}) async {
  String userId = model.getUserId();
  DocumentSnapshot doc = await Firestore.instance
      .collection(USER_BASE)
      .document(userId)
      .get(source: Source.server)
      .catchError((e) {
    pushToPerson(model, message, title: title);
  });
  if (doc == null) return;
  BaseModel user = BaseModel(doc: doc);
  if (!user.getBoolean(PUSH_NOTIFICATION)) return;
  String token = user.getString(TOKEN);

  NotificationService.sendPush(
      title: title,
      body: '${userModel.getString(NAME).trim()} $message',
      token: token,
      tag: model.getObjectId());
}

/*notifyUserFollowers(BaseModel model) async {
  String userId = model.getUserId();
  String courseName = model.getString(COURSE_NAME);
  DocumentSnapshot doc =
      await Firestore.instance.collection(USER_BASE).document(userId).get();
  BaseModel user = BaseModel(doc: doc);
  List followers = user.getList(FOLLOWERS);
  if (followers.isNotEmpty) {
    String fName = user.getString(NAME).split(" ")[0];
    createNotification(
        followers,
        "$fName uploaded a new document on $courseName",
        model,
        ITEM_TYPE_LIBRARY);
  }
}*/

clickChat(context, BaseModel theUser, bool isGroup,
    {bool replace = false, bool depend = true}) {
  String chatID = createChatId(theUser.getObjectId());
  BaseModel chat = BaseModel();
  chat.put(PARTIES, [userModel.getObjectId(), theUser.getObjectId()]);
  chat.saveItem(CHAT_IDS_BASE, false, document: chatID);
  userModel.putInList(DELETED_CHATS, chatID, false);
  userModel.updateItems();
  if (replace) {
    pushReplacementAndResult(
        context,
        ChatMain(
          chatID,
          otherPerson: theUser,
        ),
        depend: depend);
  } else {
    pushAndResult(
        context,
        ChatMain(
          chatID,
          otherPerson: theUser,
        ),
        depend: depend);
  }
}

String createChatId(String hisId) {
  String myId = userModel.getObjectId();
  List ids = [];
  for (int i = 0; i < myId.length; i++) {
    ids.add(myId[i]);
  }
  for (int i = 0; i < hisId.length; i++) {
    ids.add(hisId[i]);
  }
  ids.sort((a, b) => a.compareTo(b));
  StringBuffer sb = StringBuffer();
  for (String s in ids) {
    sb.write(s);
  }
  return sb.toString().trim();
}

BaseModel createChatModel(String chatId, BaseModel model, bool isGroup) {
  BaseModel myModel = new BaseModel();
  myModel.put(OBJECT_ID, chatId);
  myModel.put(CHAT_ID, chatId);
  myModel.put(USER_ID, model.getObjectId());
  if (isGroup) {
    myModel.put(GROUP_NAME, model.getString(GROUP_NAME));
    myModel.put(IMAGES, model.getList(IMAGES));
  } else {
    myModel.put(NAME, model.getString(NAME));
//    myModel.put(LAST_NAME, model.getString(LAST_NAME));
    myModel.put(USER_IMAGE, model.getString(USER_IMAGE));
  }
  return myModel;
}

/*String chatExists(BaseModel theUser, bool isGroup) {
  int existing = 0;
  String theId;
  String theUserId = theUser.getObjectId();
  List<Map> myChats = List.from(userModel.getList(MY_CHATS));
  List<Map> hisChat = List.from(theUser.getList(MY_CHATS));

  for (Map chat in myChats) {
    BaseModel bm = new BaseModel(items: chat);
    String chatId = bm.getString(CHAT_ID);
    if (chatId.contains(theUserId)) {
      existing++;
      theId = chatId;
      break;
    }
  }
  if (isGroup) {
    return existing != 1 ? null : theId;
  }

  for (Map chat in hisChat) {
    BaseModel bm = new BaseModel(items: chat);
    String chatId = bm.getString(CHAT_ID);
    if (chatId.contains(userModel.getUserId())) {
      existing++;
      theId = chatId;
      break;
    }
  }
  return existing != 2 ? null : theId;
}*/

bool isSameDay(int time1, int time2) {
  DateTime date1 = DateTime.fromMillisecondsSinceEpoch(time1);

  DateTime date2 = DateTime.fromMillisecondsSinceEpoch(time2);

  return (date1.day == date2.day) &&
      (date1.month == date2.month) &&
      (date1.year == date2.year);
}

bool chatRemoved(BaseModel chat) {
  if (chat.getBoolean(DELETED)) {
    return true;
  }
  if (chat.getList(HIDDEN).contains(userModel.getObjectId())) {
    return true;
  }
  return false;
}

tabIndicator(int tabCount, int currentPosition, {margin}) {
  return Container(
    padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
    margin: margin,
    decoration: BoxDecoration(
        color: black.withOpacity(.7), borderRadius: BorderRadius.circular(25)),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: getTabs(tabCount, currentPosition),
    ),
  );
  /*return Marker(
      markerId: MarkerId(""),
      infoWindow: InfoWindow(),
      icon: await BitmapDescriptor.fromAssetImage(ImageConfiguration(), ""));*/
}

getTabs(int count, int cp) {
  List<Widget> items = List();
  for (int i = 0; i < count; i++) {
    bool selected = i == cp;
    items.add(Flexible(
      fit: FlexFit.loose,
      child: Container(
        width: selected ? 10 : 8,
        height: selected ? 10 : 8,
        //margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
        decoration: BoxDecoration(
            color: white.withOpacity(selected ? 1 : (.5)),
            shape: BoxShape.circle),
      ),
    ));
    if (i != count - 1) items.add(addSpaceWidth(5));
  }

  return items;
}
/*

SmartRefresher refreshList(refreshController,bool up,bool down){
  return SmartRefresher page() {
    return SmartRefresher(
      controller: refreshController,
      enablePullDown: down,
      enablePullUp: true,
      //headerConfig: RefreshConfig(visibleRange: 100.0),
      footer: (c, mode) {
        return ClassicIndicator(
          mode: mode,
          idleText: "",
          idleIcon: Container(),
          textStyle: textStyle(false, 14, black),
        );
      },
      onRefresh: (_) {
        if (_ == true) {
//          Future.delayed(Duration(milliseconds: 1500), () {
//            loadItems(true);
//          });
        } else {
          //refreshController.sendBack(false, RefreshStatus.noMore);
          Future.delayed(Duration(milliseconds: 1500), () {
            loadPeople();
          });
        }
      },
      onOffsetChange: (_, c) {},
      child: scroll(),
    );
  };
}*/

imageHolder(
  double size,
  imageUrl, {
  double stroke = .5,
  strokeColor = blue0,
  bool local = false,
  iconHolder = Icons.person,
  double iconHolderSize = 14,
  bool showDot = false,
  onImageTap,
}) {
  return GestureDetector(
    onTap: onImageTap,
    child: new AnimatedContainer(
      curve: Curves.ease,
      duration: Duration(milliseconds: 300),
      width: size,
      height: size,
      child: Stack(
        children: <Widget>[
          AnimatedContainer(
            curve: Curves.ease,
            duration: Duration(milliseconds: 300),
            width: size,
            height: size,
            child: new Card(
              margin: EdgeInsets.all(stroke),
              shape: CircleBorder(
                  side: BorderSide(color: strokeColor, width: stroke)),
              clipBehavior: Clip.antiAlias,
              color: white,
              elevation: .5,
              child: Stack(
                children: <Widget>[
                  Center(
                    child: Icon(
                      iconHolder,
                      color: black_color,
                      size: iconHolderSize,
                    ),
                  ),
                  imageUrl is File
                      ? (Image.file(imageUrl,
                          width: size, height: size, fit: BoxFit.cover))
                      : local
                          ? Image.asset(
                              imageUrl,
                              width: size,
                              height: size,
                              fit: BoxFit.cover,
                            )
                          : CachedNetworkImage(
                              width: size,
                              height: size,
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                            ),
                ],
              ),
            ),
          ),
          !showDot
              ? Container()
              : Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: white, width: 2),
                      color: red0,
                    ),
                  )),
        ],
      ),
    ),
  );
}

String getExtToUse(String fileExtension) {
  if (fileExtension == null) return "";
  fileExtension = fileExtension.toLowerCase().trim();
  if (fileExtension.contains("doc")) {
    return "doc";
  } else if (fileExtension.contains("xls")) {
    return "xls";
  } else if (fileExtension.contains("ppt")) {
    return "ppt";
  }

  return fileExtension;
}

class ViewImage extends StatefulWidget {
  List images;
  int position;
  ViewImage(
    this.images,
    this.position,
  );
  @override
  _ViewImageState createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> {
  List images;
  int position;
  PageController controller;
  @override
  void initState() {
    // TODO: implement initState
    images = widget.images;
    position = widget.position;
    controller = PageController(initialPage: position);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<PhotoViewGalleryPageOptions> list = List();
    for (String image in images) {
      list.add(PhotoViewGalleryPageOptions(
        imageProvider:
            (image.startsWith("https://") || image.startsWith("http://"))
                ? NetworkImage(image)
                : FileImage(File(image)),
        initialScale: PhotoViewComputedScale.contained,
        /* maxScale: PhotoViewComputedScale.contained * 0.3*/
      ));
    }
    // TODO: implement build
    return Container(
      color: black,
      child: Stack(children: <Widget>[
        CachedNetworkImage(
          imageUrl: images[position],
          height: MediaQuery.of(context).size.height,
        ),
        BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              color: black.withOpacity(.6),
            )),
        PhotoViewGallery(
          pageController: controller,
          pageOptions: list,
          onPageChanged: (p) {
            position = p;
            setState(() {});
          },
        ),
        new Container(
          margin: EdgeInsets.fromLTRB(0, 25, 0, 0),
          width: 50,
          height: 50,
          child: FlatButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onPressed: () {
              Navigator.pop(context);
            },
            child: Center(
                child: Icon(
              Icons.keyboard_backspace,
              color: white,
              size: 25,
            )),
          ),
        ),
        if (images.length > 1)
          Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(flex: 1, child: Container()),
              new Padding(
                padding: const EdgeInsets.all(20),
                child: tabIndicator(images.length, position),
              ),
            ],
          )
      ]),
    );
  }
}

class RaisedGradientButton extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final double width;
  final double height;
  final Function onPressed;
  final bool round;
  final bool addShadow;

  const RaisedGradientButton(
      {Key key,
      @required this.child,
      this.gradient,
      this.width = double.infinity,
      this.height = 50.0,
      this.onPressed,
      this.addShadow = true,
      this.round = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: round ? null : BorderRadius.circular(25),
          boxShadow: !addShadow
              ? null
              : [
                  BoxShadow(
                    color: Colors.grey[500],
                    offset: Offset(0.0, 1.5),
                    blurRadius: 1.5,
                  ),
                ],
          shape: round ? BoxShape.circle : BoxShape.rectangle),
      child: Material(
        color: Colors.transparent,
        child: FlatButton(
            shape: round
                ? CircleBorder()
                : RoundedRectangleBorder(
                    borderRadius: round ? null : BorderRadius.circular(25),
                  ),
            color: Colors.transparent,
            onPressed: onPressed,
            padding: EdgeInsets.all(0),
            child: Center(
              child: child,
            )),
      ),
    );
  }
}

/*showAdminFunctions(context) {
  if (!isAdmin) return;
  pushAndResult(
      context,
      listDialog([
        "LogOut",
        "Plan Settings",
        "Create Admin Quote",
        "Create Admin Quiz",
        "Admin Quiz Prize",
        "Game Position",
        "Admin Item Position",
        "All Quiz",
        "All Admin Quiz",
        "Prev Quiz",
        "Clone Quiz",
        "Voice",
        "Ad Key",
        "Ad Key Video",
        "Ad Key Inter",
        "Rave Key",
        "Voice Text",
//        "Admin Quote Titles",
        "Count Signups",
        "Send Credits",
        "Headline",
        "Create Quiz",
        "Advert CPR",
        "Min Ad Budget",
        "Posts Ad Spacing",
        "Lib Ad Spacing",
        "Lib Cross Ad Spacing",
        "Market Ad Spacing",
        "Broad Cost",
        "Level Main",
        "Pending Main",
        "Create Ad",
        "All Ads",
        "Send Broadcast",
        "Face Settings",
        "Material Types",
        "Reports",
        "About Link",
        "Privacy Link",
        "Terms Link",
        "Package Name",
        "Support Email",
        "Show Version",
        "Update Version",
        "Add Admin User",
        "Remove Admin User",
        isAdmin ? "Disable Admin" : "Enable Admin"
      ]), result: (_) async {
    if (_ == "Send Credits") {
      pushAndResult(
          context, inputDialog("Email, Credits", hint: "Email, Credits"),
          result: (_) async {
        if (!_.contains(",")) {
          toastInAndroid("Invalid");
          return;
        }
        if (userModel.getString(EMAIL) != "johnebere58@gmail.com") {
          toastInAndroid("Only John can perform this command");
          return;
        }
        String email = _.split(",")[0].trim().toLowerCase();
        int credits = int.parse(_.split(",")[1].trim());

        showMessage(
            context,
            ic_coin,
            blue0,
            "Send ${formatPrice(credits.toString())} Credit?",
            "to $email", onClicked: (_) async {
          if (_ == true) {
            String id = getRandomId();
            Firestore.instance
                .collection(USER_BASE)
                .where(EMAIL, isEqualTo: email)
                .getDocuments(source: Source.server)
                .then((shots) {
              for (DocumentSnapshot shot in shots.documents) {
                BaseModel model = BaseModel(doc: shot);
                hmcr(model, id, credits, true, false);
                toastInAndroid("Creditting User...");
                break;
              }
            }).catchError((e) {
              showMessage(
                  context, Icons.error, red0, "Error occurred", e.toString());
            });
          }
        });
      });
    }
    if (_ == "All Admin Quiz") {
      pushAndResult(context, ShowAllAdminQuiz());

    }
    if (_ == "All Quiz") {
//          pushAndResult(context, GpaMain());
      pushAndResult(context, ShowAllQuiz());
    }
    if (_ == "Prev Quiz") {
      pushAndResult(context, ShowPrevWinners());
    }
    if (_ == "Create Admin Quote") {
      pushAndResult(context, PostQuote(), result: (_) {
        if (_ != null) {
          BaseModel model = _;
          uploadItem(uploadingController, "Uploading Quote...",
              "Quote uploaded successfully", model);
          //startUploading(model, POST_TYPE_QUIZ);
        }
      });
    }

    if (_ == "Clone Quiz") {
      */ /*Firestore.instance.collection("quizBase3").getDocuments().then((shots) {
        for (DocumentSnapshot doc in shots.documents) {
          BaseModel model = BaseModel(doc: doc);
          model.saveItem(QUIZ_BASE, true, document: model.getObjectId());
        }
        toastInAndroid("done");
      });*/ /*
//      pushAndResult(context, preGame());
    }
    if (_ == "Voice") {
      bool shown = appSettingsModel.getBoolean(HIDE_VOICE);
      appSettingsModel.put(HIDE_VOICE, !shown);
      appSettingsModel.updateItems();
    } else if (_ == "Count Signups") {
      */ /*Firestore.instance
              .collection("quizBase1")
              .getDocuments()
              .then((shots) {
            for (DocumentSnapshot doc in shots.documents) {
              BaseModel model = BaseModel(doc: doc);
              model.saveItem(QUIZ_BASE, true);
            }
            toastInAndroid("done");
          });*/ /*

      toastInAndroid("Counting...");
      Firestore.instance.collection(USER_BASE).getDocuments().then((shots) {
        int allCount = 0;
        int newCount = 0;
        int activeCount = 0;
        int max = 0;
        StringBuffer sb = StringBuffer();
        for (DocumentSnapshot doc in shots.documents) {
          BaseModel model = BaseModel(doc: doc);
          try{
            if(model.getString(COUNTRY)=="NG" && max<1000){
              String name = model.getString(NAME);
              if(name.trim().isNotEmpty) {
                List parts = name.split(" ");
                sb.write("${parts[1]}");
                sb.write(",");
                max++;
              }
            }
          }catch(e){}
          if (model.getBoolean(NEW_APP)) {
            newCount++;
          }
          if (model.getInt(TIME_UPDATED) >
              (DateTime.now().millisecondsSinceEpoch -
                  (Duration.millisecondsPerDay * 2))) {
            activeCount++;
          }
          allCount++;
        }
//        ClipboardManager.copyToClipBoard(sb.toString().trim());
        toastInAndroid(
            "All - $allCount, New - $newCount, Active - $activeCount");
      });
    } else if (_ == "Show Version") {
      PackageInfo pack = await PackageInfo.fromPlatform();
      toastInAndroid(pack.version);
    } else if (_ == "Create Admin Quiz") {
      pushAndResult(
          context,
          PostQuiz(
            adminQuiz: true,
          ), result: (_) {
        if (_ != null) {
          BaseModel model = _;
          uploadItem(uploadingController, "Uploading Quiz...",
              "Quiz uploaded successfully", model);
          //startUploading(model, POST_TYPE_QUIZ);
        }
      });
    } else if (_ == "Headline") {
      pushAndResult(context, PostHeadline(), result: (_) {
        if (_ != null) {
          BaseModel model = _;
          uploadItem(
            uploadingController,
            "Uploading Headline...",
            "Headline uploaded successfully",
            model,
          );
          //startUploading(model, POST_TYPE_HEADLINE);
        }
      });
    } else if (_ == "Create Quiz") {
      pushAndResult(context, quizPost(), result: (_) {
        if (_ != null) {
          BaseModel model = _;
          uploadItem(uploadingController, "Uploading Quiz...",
              "Quiz uploaded successfully", model, onComplete: () {
            NotificationService.sendPush(
                title: "Live Quiz",
                body: "New live quiz available, join now",
                topic: 'all',
                liveTimeInSeconds: (Duration.secondsPerDay),
                tag: 'maugostQuiz');
          });
        }
      });
    } else if (_ == "Plan Settings") {
      pushAndResult(
          context,
          listDialog([
            "Bronze Count",
            "Bronze Cost",
            "Bronze Cost Usd",
            "Silver Count",
            "Silver Cost",
            "Silver Cost Usd",
            "Gold Count",
            "Gold Cost",
            "Gold Cost Usd",
            "Send Plan",
            "Enable Plan",
            "Disable Plan",
            "Enable Sub",
            "Disable Sub",
          ]), result: (_) {
        if (_ == "Enable Plan") {
          userModel.put(LIB_ACTIVE, true);
          userModel.updateItems();
        }
        if (_ == "Disable Plan") {
          userModel.put(LIB_ACTIVE, false);
          userModel.updateItems();
        }
        if (_ == "Send Plan") {
          pushAndResult(
              context, inputDialog("Email, PlanCode", hint: "Email, PlanCode"),
              result: (_) async {
            if (!_.contains(",")) {
              toastInAndroid("Invalid");
              return;
            }
            if (userModel.getString(EMAIL) != "johnebere58@gmail.com") {
              toastInAndroid("Only John can perform this command");
              return;
            }
            String email = _.split(",")[0].trim().toLowerCase();
            int planCode = int.parse(_.split(",")[1].trim());

            showMessage(
                context,
                Icons.featured_play_list,
                blue0,
                "Send ${getPlanName(planCode)}?",
                "to $email", onClicked: (_) async {
              if (_ == true) {
                String id = getRandomId();
                Firestore.instance
                    .collection(USER_BASE)
                    .where(EMAIL, isEqualTo: email)
                    .getDocuments(source: Source.server)
                    .then((shots) {
                  if (shots.documents.isEmpty) {
                    toastInAndroid("No such user");
                    return;
                  }
                  for (DocumentSnapshot shot in shots.documents) {
                    BaseModel model = BaseModel(doc: shot);
                    handleActivation(context, planCode, model, () {});
                    toastInAndroid("Activating User...");
                    break;
                  }
                }).catchError((e) {
                  showMessage(context, Icons.error, red0, "Error occurred",
                      e.toString());
                });
              }
            });
          });
        }
        if (_ == "Enable Sub")
          appSettingsModel.put(DISABLE_SUB,false);
          appSettingsModel.updateItems();
        if (_ == "Disable Sub")
          appSettingsModel.put(DISABLE_SUB,true);
          appSettingsModel.updateItems();
        if (_ == "Bronze Count")
          updateSettingsItem(context, "Bronze Count", BRONZE_COUNT, true);
        if (_ == "Bronze Cost")
          updateSettingsItem(context, "Bronze Cost", BRONZE_COST, true);
        if (_ == "Bronze Cost Usd")
          updateSettingsItem(context, "Bronze Cost Usd", BRONZE_COST_USD, true);

        if (_ == "Silver Count")
          updateSettingsItem(context, "Silver Count", SILVER_COUNT, true);
        if (_ == "Silver Cost")
          updateSettingsItem(context, "Silver Cost", SILVER_COST, true);
        if (_ == "Silver Cost Usd")
          updateSettingsItem(context, "Silver Cost Usd", SILVER_COST_USD, true);

        if (_ == "Gold Count")
          updateSettingsItem(context, "Gold Count", GOLD_COUNT, true);
        if (_ == "Gold Cost")
          updateSettingsItem(context, "Gold Cost", GOLD_COST, true);
        if (_ == "Gold Cost Usd")
          updateSettingsItem(context, "Gold Cost Usd", GOLD_COST_USD, true);
      });
    } else if (_ == "Game Position") {
      updateSettingsItem(context, "Game Position", GAME_POSITION, true);
    } else if (_ == "Ad Key") {
      updateSettingsItem(context, "Ad Key", AD_KEY, false, allowEmpty: true);
    } else if (_ == "Ad Key Video") {
      updateSettingsItem(context, "Ad Key Video", AD_KEY_VIDEO, false,
          allowEmpty: true);
    } else if (_ == "Ad Key Inter") {
      updateSettingsItem(context, "Ad Key Inter", AD_KEY_INTER, false,
          allowEmpty: true);
    } else if (_ == "Rave Key") {
      updateSettingsItem(context, "Rave Key", RAVE_KEY, false);
    } else if (_ == "Admin Quiz Prize") {
      pushAndResult(
          context,
          inputDialog(
            "Admin Quiz Prize (MCR)",
            message: appSettingsModel.getInt(ADMIN_QUIZ_PRIZE).toString(),
          ), result: (_) async {
        String text = _.trim();
        appSettingsModel.put(ADMIN_QUIZ_PRIZE, int.parse(text));
        appSettingsModel.updateItems();
      });
    } else if (_ == "Admin Item Position") {
      pushAndResult(
          context,
          inputDialog(
            "Admin Item Position",
            message: appSettingsModel.getInt(ADMIN_ITEM_POSITION).toString(),
          ), result: (_) async {
        String text = _.trim();
        appSettingsModel.put(ADMIN_ITEM_POSITION, int.parse(text));
        appSettingsModel.updateItems();
      });
    } else if (_ == "Voice Text") {
      pushAndResult(context, inputDialog("Voice Text"), result: (_) async {
        String text = _.trim();
        appSettingsModel.put(VOICE_TEXT, text);
        appSettingsModel.updateItems();
      });
    } else if (_ == "Add Admin User") {
      pushAndResult(context, inputDialog("Email Address"), result: (_) async {
        String email = _.toLowerCase().trim();

        QuerySnapshot shots = await Firestore.instance
            .collection(USER_BASE)
            .where(EMAIL, isEqualTo: email)
            .limit(1)
            .getDocuments();
        for (DocumentSnapshot doc in shots.documents) {
          BaseModel model = BaseModel(doc: doc);
          model.put(IS_ADMIN, true);
          model.updateItems();
          toastInAndroid("Added");
        }
      });
    } else if (_ == "Remove Admin User") {
      pushAndResult(context, inputDialog("Email Address"), result: (_) async {
        String email = _.toLowerCase().trim();

        QuerySnapshot shots = await Firestore.instance
            .collection(USER_BASE)
            .where(EMAIL, isEqualTo: email)
            .limit(1)
            .getDocuments();
        for (DocumentSnapshot doc in shots.documents) {
          BaseModel model = BaseModel(doc: doc);
          model.put(IS_ADMIN, false);
          model.updateItems();
          toastInAndroid("Removed");
        }
      });
    } else if (_ == "Show All Posts") {
      appSettingsModel.put(SHOW_ALL_POSTS, true);
      appSettingsModel.updateItems();
    } else if (_ == "Dont Show All Posts") {
      appSettingsModel.put(SHOW_ALL_POSTS, false);
      appSettingsModel.updateItems();
    } else if (_ == "Pending Main") {
      pushAndResult(context, PendingMain());
    } else if (_ == "Broad Cost") {
      pushAndResult(
          context,
          inputDialog(
            "Broad Cost",
            hint: "Cost of Broadcasting a message",
            message: appSettingsModel.getInt(BROAD_COST).toString(),
          ), result: (_) {
        appSettingsModel.put(BROAD_COST, int.parse(_));
        appSettingsModel.updateItems();
      });
    } else if (_ == "Admin Quote Titles") {
      updateSettingsItem(context, "Quote Titles (separate with comma)", ADMIN_QUOTE_TITLES, false);
    } else if (_ == "Package Name") {
      updateSettingsItem(context, "Package Name", PACKAGE_NAME, false);
    } else if (_ == "Privacy Link") {
      updateSettingsItem(context, "Privacy Link", PRIVACY_LINK, false);
    } else if (_ == "Terms Link") {
      updateSettingsItem(context, "Terms Link", TERMS_LINK, false);
    } else if (_ == "About Link") {
      updateSettingsItem(context, "About Link", ABOUT_LINK, false);
    } else if (_ == "Support Email") {
      updateSettingsItem(context, "Support Email", SUPPORT_EMAIL, false);
    } else if (_ == "Update Version") {
      updateSettingsItem(context, "Version Code", VERSION_CODE, true);
    } else if (_ == "Posts Ad Spacing") {
      updateSettingsItem(context, "Posts Ad Spacing", POSTS_AD_SPACING, true);
    } else if (_ == "Lib Cross Ad Spacing") {
      updateSettingsItem(
          context, "Lib Cross Ad Spacing", LIB_CROSS_AD_SPACING, true);
    } else if (_ == "Lib Ad Spacing") {
      updateSettingsItem(context, "Lib Ad Spacing", LIB_AD_SPACING, true);
    } else if (_ == "Market Ad Spacing") {
      updateSettingsItem(context, "Market Ad Spacing", MARKET_AD_SPACING, true);
    } else if (_ == "Min Ad Budget") {
      pushAndResult(
          context,
          inputDialog(
            "Min Ad Budget",
            hint: "Min Budget",
            message: appSettingsModel.getInt(MIN_BUDGET).toString(),
          ), result: (_) {
        appSettingsModel.put(MIN_BUDGET, int.parse(_));
        appSettingsModel.updateItems();
      });
    } else if (_ == "Advert CPR") {
      pushAndResult(
          context,
          inputDialog(
            "Advert CPR",
            hint: "Cost Per Reach",
            message: appSettingsModel.getDouble(COST_PER_REACH).toString(),
          ), result: (_) {
        appSettingsModel.put(COST_PER_REACH, double.parse(_));
        appSettingsModel.updateItems();
      });
    } else if (_ == "All Ads") {
      pushAndResult(context, ShowAds());
    } else if (_ == "Create Ad") {
      pushAndResult(context, PostAd());
    } else if (_ == "Send Broadcast") {
      pushAndResult(context, BroadcastMessage());
    } else if (_ == "Level Main") {
      pushAndResult(context, LevelsMain());
    } else if (_ == "Saved Posts") {
      pushAndResult(
          context,
          ShowPosts(
            "Saved Posts",
            keyText: SAVED,
          ));
    } else if (_ == "Hidden Posts") {
      pushAndResult(
          context,
          ShowPosts(
            "Hidden Posts",
            keyText: HIDDEN,
          ));
    } else if (_ == "Enable Admin") {
      isAdmin = true;
    } else if (_ == "Disable Admin") {
      isAdmin = false;
    } else if (_ == "Reports") {
      pushAndResult(context, ReportMain());
    } else if (_ == "Material Types") {
      pushAndResult(
          context,
          inputDialog(
            "Material Type",
            hint: "Use (,) to separate",
            message: convertListToString(
                ",", appSettingsModel.getList(MATERIAL_TYPE)),
          ), result: (_) {
        List list = convertStringToList(",", _);
        appSettingsModel.put(MATERIAL_TYPE, list);
        appSettingsModel.updateItems();
      });
    } else if (_ == "LogOut") {
      clickLogout(context);
    } else if (_ == "Face Settings") {
      pushAndResult(
          context,
          listDialog([
            "Face Type Manual",
            "Face Type Auto",
            "Face Frequency",
            "Reset Face",
            "Clear Saved Faces"
          ]), result: (_) {
        BaseModel faceSettings =
            BaseModel(items: appSettingsModel.getMap(FACE_SETTINGS));
        if (_ == "Face Type Auto") {
          yesNoDialog(context, "Auto Face", "Are you sure?", () {
            putFaceSettings(FACE_TYPE, FACE_TYPE_AUTO);
          });
        }
        if (_ == "Face Type Manual") {
          yesNoDialog(context, "Manual Face", "Are you sure?", () {
            putFaceSettings(FACE_TYPE, FACE_TYPE_MANUAL);
          });
        }
        if (_ == "Face Frequency") {
          pushAndResult(
              context,
              inputDialog(
                "Time in Hours",
                inputType: TextInputType.number,
                message: faceSettings.getInt(FACE_FREQ).toString(),
              ), result: (_) {
            putFaceSettings(FACE_FREQ, int.parse(_));
          });
        }
        if (_ == "Reset Face") {
          yesNoDialog(context, "Reset Face", "Are you sure?", () {
            appSettingsModel.remove(FACE_ITEM);
            appSettingsModel.updateItems();
          });
        }
        if (_ == "Clear Saved Faces") {
          yesNoDialog(context, "Clear Saved Faces", "Are you sure?", () {
            faceSettings.remove(PREVIOUS_FACES);
            appSettingsModel.put(FACE_SETTINGS, faceSettings.items);
            appSettingsModel.updateItems();
          });
        }
      });
    }
  });
}*/

smallTitle(String text,
    {buttonIcon = Icons.search, String buttonText, onButtonClicked}) {
  return Container(
    margin: EdgeInsets.fromLTRB(15, 10, 15, 10),
    child: Row(
      children: <Widget>[
        Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: Text(
            text,
            style: textStyle(true, 14, black.withOpacity(.5)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        buttonText == null
            ? Container()
            : new Container(
                //width: 50,
                //margin: EdgeInsets.fromLTRB(5, 0, 5, 5),
                height: 25,
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                      side:
                          BorderSide(color: black.withOpacity(.1), width: .5)),
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onPressed: onButtonClicked,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        buttonIcon,
                        size: 12,
                        color: black.withOpacity(.4),
                      ),
                      addSpaceWidth(2),
                      Text(
                        buttonText,
                        style: textStyle(true, 10, black.withOpacity(.4)),
                      ),
                    ],
                  ),
                  color: blue09,
                ),
              )
      ],
    ),
  );
}

checkSummary(String courseId, String matType) async {
  DocumentSnapshot doc =
      await Firestore.instance.collection(STUDY_BASE).document(courseId).get();
  BaseModel bm = BaseModel(doc: doc);
  if (bm.getString(SUMMARY).isEmpty) {
    bm.put(SUMMARY, "1 $matType");
    bm.updateItems();
  }
}

class MySeparator extends StatelessWidget {
  final double height;
  final Color color;

  const MySeparator({this.height = 1, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashWidth = 10.0;
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
        );
      },
    );
  }
}

setTimetables() async {
  /* SharedPreferences prefs = await SharedPreferences.getInstance();
  List timetableList = List.from(prefs.getStringList(TIME_TABLE) ?? []);
  bool muted = prefs.getBool(TIME_TABLE_MUTED) ?? false;
  await flutterLocalNotificationsPlugin.cancelAll();
  if (muted) return;

//  toastInAndroid("Settings timetable...");
  for (String s in timetableList) {
    String key = s.split("-")[0].trim();
    String value = s.split("-")[1].trim();
    value = value == null ? "" : value;
    if (value == null || value.isEmpty) continue;

    String dayText = key.split(" ")[0].trim();
    String t2 = key.split(" ")[1].trim();

    int hour = int.parse(t2);
    int num = hour > 12 ? (hour - 12) : hour;
    String am = hour > 12 ? "PM" : "AM";
    String timeText = "$num:00$am";

    int pId = key.hashCode + hour;

    var time = Time(hour - 1, 55, 0);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'maugost weekly channel id',
        'maugost timetable',
        'maugost timetable notification');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
        pId,
        'Strokes Timetable',
        '$value at $timeText',
//          Day.Wednesday,
        getDayOfWeek(dayText),
        time,
        platformChannelSpecifics);
    //toastInAndroid("Set ${hour - 1} $dayText");
  }*/
}

/*
scheduleQuizNotification(BaseModel quizModel) async {
  String id = quizModel.getObjectId();
  if (DateTime.now().millisecondsSinceEpoch > quizModel.getInt(QUIZ_TIME))
    return;
  List players = quizModel.getList(QUIZ_PLAYERS);
  int playerIndex =
      players.indexWhere((m) => m[OBJECT_ID] == userModel.getObjectId());
  if (playerIndex == -1) return;

  var dateTime = DateTime.fromMillisecondsSinceEpoch(
      (quizModel.getInt(QUIZ_TIME) - (Duration.millisecondsPerMinute * 5)));
  int hour = dateTime.hour;
  var time = Time(hour, dateTime.minute, 0);
  int x = hour > 12 ? (hour - 12) : hour;
  String am = hour > 12 ? "PM" : "AM";
  String text = "$x$am";
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'maugost quiz channel id', 'maugost quiz', 'maugost quiz notification');
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
      id.hashCode,
      'Live Quiz Starting...',
      'Please launch your App Asap',
      getDayOfWeekInt(dateTime.day),
      time,
      platformChannelSpecifics);

//  SharedPreferences prefs = await SharedPreferences.getInstance();
//  List<String> notifyList =
//      List.from(prefs.getStringList(PENDING_NOTIFY) ?? []);
//  if (!notifyList.contains(id)) notifyList.add(id);
//  prefs.setStringList(PENDING_NOTIFY, notifyList);
  //toastInAndroid("$text -  $hour");
}
*/

calcResultAdmin(context, BaseModel model, int delay, {onComplete}) async {
  String quizId = model.getObjectId();
  showProgress(true, context,
      msg: "Calculating Results", cancellable: onComplete != null);

  DocumentSnapshot doc = await Firestore.instance
      .collection(QUIZ_BASE)
      .document(model.getObjectId())
      .get(source: Source.server)
      .catchError((error) {
    showProgress(false, context);
    showMessage(context, Icons.error, red0, "Error Occurred",
        "An error occurred, check your internet connection and try again",
        delayInMilli: 800, clickYesText: "Retry", onClicked: (_) {
      calcResultAdmin(context, model, 0);
    });
  });
  BaseModel quizModel = BaseModel(doc: doc);

  Future.delayed(Duration(seconds: delay), () async {
    QuerySnapshot shots = await Firestore.instance
        .collection(SESSION_BASE)
        .where(QUIZ_ID, isEqualTo: quizModel.getObjectId())
        .getDocuments(source: Source.server)
        .catchError((error) {
      showProgress(false, context);
      showMessage(context, Icons.error, red0, "Error Occurred",
          "An error occurred, check your internet connection and try again",
          delayInMilli: 800, clickYesText: "Retry", onClicked: (_) {
        calcResultAdmin(context, quizModel, 0);
      });
    });

    if (shots == null) return;

    int highScore = 0;
    Map summation = Map();
    List loadedIds = [];

    for (DocumentSnapshot doc in shots.documents) {
      BaseModel model = BaseModel(doc: doc);
      String id = '${model.getString(USER_ID)}${model.getInt(QUESTION_INDEX)}';
      if (loadedIds.contains(id)) continue;
      loadedIds.add(id);

      if (model.getBoolean(CORRECT)) {
        String userId = model.getString(USER_ID);
        int score = summation[userId] ?? 0;
        score = score + 1;
        if (score > highScore) highScore = score;
        summation[userId] = score;
      }
    }

    List players = quizModel.getList(QUIZ_PLAYERS);
    List playersResults = [];
    for (Map player in players) {
      bool lighter = player[LIGHTER] ?? false;
      if (lighter) {
        int sc = player[SCORE] ?? highScore;
        if (highScore > sc) {
          player[SCORE] = highScore;
        }
        if (highScore < sc) {
          highScore = sc;
        }
        playersResults.add(player);
        continue;
      }
      String userId = player[OBJECT_ID];
      int score = summation[userId];
      Map pr = player;
      pr[SCORE] = score;
      playersResults.add(pr);
    }

    quizModel.put(QUIZ_PLAYERS, playersResults);
    quizModel.put(HIGH_SCORE, highScore);
    quizModel.put(SUMMED, true);
    quizModel.updateItems();

    showProgress(false, context);
    Future.delayed(Duration(milliseconds: 800), () {
      if (onComplete != null) {
        onComplete(quizModel);
      } else {
        Navigator.pop(context, quizModel);
      }
    });
  });
}

myCheckBox(bool selected) {
  return new Container(
    //padding: EdgeInsets.all(2),
    child: Container(
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: blue09,
          border: Border.all(color: black.withOpacity(.1), width: 1)),
      child: Container(
        width: 13,
        height: 13,
        margin: EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? blue6 : transparent,
        ),
        child: Icon(
          Icons.check,
          size: 8,
          color: white,
        ),
      ),
    ),
  );
}

String getLastSeen(BaseModel user) {
  int time = user.getInt(TIME_UPDATED);
  int now = DateTime.now().millisecondsSinceEpoch;
  int diff = now - time;
  if (diff > (Duration.millisecondsPerDay * 77)) return null;
  return diff > (Duration.millisecondsPerDay * 30)
      ? "Last seen: some weeks ago"
      : "Last seen: ${timeAgo.format(DateTime.fromMillisecondsSinceEpoch(time), locale: "en")}";
}

commentItem(context, BaseModel comment, List repliesList, onEdited, onDeleted,
    bool myPost,
    {bool isReport = false, bool isReply = false}) {
  //refreshUser(comment, user);
  List stars = List.from(comment.getList(STARS));
  List<BaseModel> replies = isReply
      ? List()
      : List.from(repliesList
          .where((bm) => bm.getString(COMMENT_ID) == comment.getObjectId()));
  //replies = List.from(replies.reversed);
  bool starred = stars.contains(userModel.getObjectId());
  bool showAll = showAllId == comment.getObjectId();
  return (comment.getBoolean(HIDDEN) && !(myPost || isAdmin))
      ? Container()
      : new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Stack(
              children: <Widget>[
                new GestureDetector(
                  onLongPress: () {
                    if (isReport) return;
                    showCommentOptions(
                        context, comment, onEdited, onDeleted, myPost, isReply);
                  },
                  child: Opacity(
                    opacity: comment.getBoolean(HIDDEN) && !comment.myItem()
                        ? (.3)
                        : 1,
                    child: Container(
                      margin: EdgeInsets.fromLTRB(40, 0, 40, 15),
                      decoration: BoxDecoration(
                          color: blue09,
                          borderRadius: BorderRadius.circular(25)),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  comment.getString(NAME).split(" ")[0],
                                  maxLines: 1,
                                  style: textStyle(true, 12, black),
                                ),
                                addSpaceWidth(5),
                                Text(
                                  timeAgo.format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          comment.getTime()),
                                      locale: "en_short"),
                                  style: textStyle(
                                      false, 12, black.withOpacity(.3)),
                                ),
                              ],
                            ),
                            addSpace(5),
                            Text(
                              comment.getString(MESSAGE),
                              style: textStyle(false, 17, black),
                            ),
                            isReport || isReply ? Container() : addSpace(5),
                            isReport || isReply
                                ? Container()
                                : new Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      stars.isEmpty
                                          ? Container()
                                          : Text(
                                              "${stars.length}",
                                              style: textStyle(false, 12,
                                                  blue3.withOpacity(.5)),
                                            ),
                                      stars.isEmpty
                                          ? Container()
                                          : addSpaceWidth(5),
                                      new GestureDetector(
                                        onTap: () {
                                          comment.putInList(
                                              STARS,
                                              userModel.getObjectId(),
                                              !starred);
                                          comment.updateItems();

                                          /* if (starred) {
                                            stars.remove(
                                                userModel.getObjectId());
                                            comment.updateListWithMyId(
                                                STARS, false);
                                          } else*/
                                          if (!starred) {
                                            //stars.add(userModel.getObjectId());
//                                            comment.updateListWithMyId(
//                                                STARS, true);
                                            createNotification(
                                                [comment.getUserId()],
                                                "starred your comment",
                                                comment,
                                                ITEM_TYPE_COMMENT,
                                                user: userModel,
                                                id: "${comment.getObjectId()}star");
                                            pushToPerson(comment,
                                                "starred your comment");
                                          }
                                          //comment.put(STARS, stars);
                                          onEdited();
                                        },
                                        child: Icon(
                                          starred
                                              ? Icons.star
                                              : Icons.star_border,
                                          size: 15,
                                          color: starred
                                              ? blue0
                                              : blue3.withOpacity(.5),
                                        ),
                                      ),
                                      addSpaceWidth(20),
                                      replies.isEmpty
                                          ? Container()
                                          : Text(
                                              "${replies.length}",
                                              style: textStyle(false, 12,
                                                  blue3.withOpacity(.5)),
                                            ),
                                      replies.isEmpty
                                          ? Container()
                                          : addSpaceWidth(5),
                                      new GestureDetector(
                                        onTap: () {
                                          replyThis(
                                            context,
                                            comment,
                                            onEdited,
                                          );
                                        },
                                        child: Icon(
                                          Icons.reply,
                                          size: 15,
                                          color: red0.withOpacity(.5),
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                new GestureDetector(
                  onTap: () {
//              pushAndResult(
//                  context, MyProfile(userId: comment.getString(USER_ID),));
                  },
                  child: new Container(
                    decoration: BoxDecoration(
                      color: blue0,
                      border: Border.all(width: 2, color: white),
                      shape: BoxShape.circle,
                    ),
                    margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    width: 40,
                    height: 40,
                    child: Stack(
                      children: <Widget>[
                        Card(
                          margin: EdgeInsets.all(0),
                          shape: CircleBorder(),
                          clipBehavior: Clip.antiAlias,
                          color: transparent,
                          elevation: .5,
                          child: Stack(
                            children: <Widget>[
                              Container(
                                width: 40,
                                height: 40,
                                color: blue0,
                                child: Center(
                                    child: Icon(
                                  Icons.person,
                                  color: white,
                                  size: 15,
                                )),
                              ),
                              CachedNetworkImage(
                                width: 40,
                                height: 40,
                                imageUrl: comment.getString(USER_IMAGE),
                                fit: BoxFit.cover,
                              ),
                            ],
                          ),
                        ),
                        /*!isOnline
                            ? Container()
                            : Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: white, width: 2),
                                  color: red0,
                                ),
                              ),*/
                      ],
                    ),
                  ),
                )
              ],
            ),
            replies.isEmpty || showAll || replies.length <= 3
                ? Container()
                : Center(
                    child: GestureDetector(
                    onTap: () {
                      showAllId = comment.getObjectId();
                      onEdited();
                    },
                    child: Container(
                      margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
                      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                      child: Icon(
                        Icons.more_horiz,
                        size: 20,
                        color: black,
                      ),
                      decoration: BoxDecoration(
                          color: blue09,
                          borderRadius: BorderRadius.circular(25)),
                    ),
                  )),
            replies.isEmpty
                ? Container()
                : Container(
                    margin: EdgeInsets.fromLTRB(40, 0, 15, 0),
                    child: ListView.builder(
                      itemBuilder: (c, p) {
                        return commentItem(
                            context,
                            replies[showAll || replies.length <= 3
                                ? p
                                : (replies.length - (3 - p))],
                            List(),
                            onEdited,
                            onDeleted,
                            comment.myItem(),
                            isReply: true);
                      },
                      shrinkWrap: true,
                      itemCount:
                          showAll || replies.length <= 3 ? replies.length : 3,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.all(0),
                    ),
                  )
          ],
        );
}

String getPlayStoreLink() {
  if (appSettingsModel == null) return "";
  String package = appSettingsModel.getString(PACKAGE_NAME);
  if (package.isEmpty) return "";
  String appLink = "http://play.google.com/store/apps/details?id=$package";
  return appLink;
}

clickLogout(context) {
  yesNoDialog(context, "Logout?", "Are you sure you want to logout?", () {
    userModel.put(IS_ONLINE, false);
    userModel.updateItems();
    for (String s in userModel.getList(TOPICS))
      firebaseMessaging.unsubscribeFromTopic(s);
    userModel = BaseModel();
    lastMessages.clear();
    lastOffers.clear();
    nList.clear();
    orderList.clear();
    orderSetup = false;
    offerSetup = false;
    chatSetup = false;
    isLoggedIn = false;
    FirebaseAuth.instance.signOut().then((value) async {
      await GoogleSignIn().signOut();
      await FacebookLogin().logOut();
    });
  });
}

int getMyAge(BaseModel e) {
  return getAge(DateTime.parse(e.getString(BIRTH_DATE)));
}

int getAge(DateTime date) {
  int now = DateTime.now().millisecondsSinceEpoch;
  int diff = now - date.millisecondsSinceEpoch;
  Duration duration = Duration(milliseconds: diff);
  int age = duration.inDays ~/ 365;
  return age;
}

shareButton(color, String text, icon, onTap, {width}) {
  return Container(
    height: 30,
    width: width,
    margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
    child: new FlatButton(
//        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
            side: BorderSide(color: color, width: 1)),
        color: white,
        onPressed: onTap,
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              text,
              style: textStyle(false, 12, color),
              maxLines: 1,
            ),
            addSpaceWidth(5),
            Icon(
              icon,
              color: color,
              size: 14,
            ),
          ],
        )),
  );
}

String oldNumber = "";
bool checking = false;

inputTextView(String title, controller,
    {@required isNum,
    onEditted,
    int maxLine = 1,
    onTipClicked,
    String errorText,
    double corner = 5,
    bool isAmount = false,
    var priceIcon,
    focusNode,
    bool useCurrentCountry = false}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      if (errorText != null)
        Text(
          errorText,
          style: textStyle(true, 12, red0),
        ),
      if (errorText != null) addSpace(5),
//      addSpace(10),
      Container(
        //height: 45,
        constraints: BoxConstraints(maxHeight: 150),
        margin: EdgeInsets.fromLTRB(0, 0, 0, 15),
        decoration: BoxDecoration(
            color: blue09,
            borderRadius: BorderRadius.circular(corner),
            border: Border.all(
                color: errorText != null ? red0 : black.withOpacity(.1),
                width: errorText != null ? 1 : .5)),
        child: Row(
          children: <Widget>[
            // if (isAmount || icon != null) addSpaceWidth(10),
            // if (isAmount)
            //   Container(
            //     margin: EdgeInsets.only(top: 2),
            //     child: CachedNetworkImage(
            //       imageUrl: getCurrencyLogo(
            //           useCurrentCountry ? currentCountry : defaultCountry),
            //       width: 14,
            //       height: 14,
            //       fit: BoxFit.cover,
            //       color: black.withOpacity(.3),
            //     ),
            //   ),

            if (isAmount != null) addSpaceWidth(15),
            if (priceIcon != null)
              priceIcon is String
                  ? Image.asset(
                      priceIcon,
                      height: 18,
                      width: 18,
                      color: black.withOpacity(.3),
                    )
                  : Icon(priceIcon, size: 18, color: black.withOpacity(.5)),

            if (priceIcon != null)
              priceIcon is String
                  ? (Image.asset(
                      priceIcon,
                      height: 14,
                      width: 14,
                      color: black.withOpacity(.3),
                    ))
                  : (Icon(
                      priceIcon,
                      size: 14,
                      color: black.withOpacity(.3),
                    )),
            Flexible(
              child: new TextField(
                onSubmitted: (_) {
                  //postHeadline();
                },
//                textInputAction: maxLine==1?TextInputAction.done:TextInputAction.newline,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.fromLTRB(
                      (isAmount || priceIcon != null) ? 10 : 15, 10, 15, 10),
                  counter: null,
                  labelText: title,
                  labelStyle: textStyle(false, 18, black.withOpacity(.3)),
                  /*counterStyle: textStyle(true, 0, white)*/
                ),
                style: textStyle(
                  false,
                  18,
                  black,
                ),
                controller: controller, focusNode: focusNode,
                cursorColor: black,
                cursorWidth: 1,
//                          maxLength: 50,
                maxLines: maxLine > 1 ? null : maxLine,
                keyboardType: isNum
                    ? (TextInputType.number)
                    : maxLine == 1
                        ? TextInputType.text
                        : TextInputType.multiline,
                inputFormatters: [],
                scrollPadding: EdgeInsets.all(0),
                onChanged: (s) {
                  onEditted();
                },
                /*onChanged: (String s) {
                  if (!isAmount) {
                    onEditted();
                    return;}
                  if (checking || s.trim().length<4) {
                    onEditted();
                    return;}
                  checking = true;
                  controller.text = formatAmount(s);
                  onEditted();
                  Future.delayed(Duration(milliseconds: 100), () {
                    final val =
                    TextSelection.collapsed(offset: controller.text.length);
                    controller.selection = val;
                    checking = false;
                    onEditted();
                  });
                },*/
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

clickText(
  String title,
  String text,
  onClicked, {
  icon,
  double height: 60,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
//      if(text.isNotEmpty)Text(
//        title,
//        style: textStyle(true, 14, dark_green03),
//      ),
//      if(text.isNotEmpty)addSpace(10),
      GestureDetector(
        onTap: () {
          onClicked();
        },
        child: Container(
//          height: height,
          width: double.infinity, constraints: BoxConstraints(minHeight: 60),
          margin: EdgeInsets.fromLTRB(0, 0, 0, 15),
          padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
          decoration: BoxDecoration(
              color: blue09,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: black.withOpacity(.1), width: .5)),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (text.isNotEmpty)
                  Text(
                    title,
                    style: textStyle(false, 12, black.withOpacity(.3)),
                  ),
                Row(
                  children: <Widget>[
                    if (icon != null)
                      Icon(
                        icon,
                        size: 18,
                        color: black.withOpacity(.5),
                      ),
                    if (icon != null) addSpaceWidth(5),
                    Flexible(
                      child: new Text(
                        text.isNotEmpty ? text : title,
                        style: textStyle(false, 18,
                            text.isEmpty ? black.withOpacity(.3) : black),
//                        maxLines: 1,overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

inputTextViewX(String title, controller,
    {@required isNum,
    int maxLine = 1,
    priceFormatted,
    onTipClicked,
    priceIcon,
    bool selectorMode = false,
    onSelected}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Row(
        children: <Widget>[
          Flexible(
            fit: FlexFit.tight,
            child: Text(
              title,
              style: textStyle(true, 14, black),
            ),
          ),
          if (onTipClicked != null)
            GestureDetector(
              onTap: () {
                onTipClicked();
              },
              child: Text(
                "What's this?",
                style: textStyle(false, 12, blue0),
              ),
            ),
        ],
      ),
      addSpace(10),
      GestureDetector(
        onTap: () {
          if (null != onSelected) onSelected();
        },
        child: Container(
          //height: 45,
          margin: EdgeInsets.fromLTRB(0, 0, 0, 15),
          decoration: BoxDecoration(
//            color: blue09,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: black, width: 2)),
          child: Row(
            children: <Widget>[
              if (priceIcon != null) addSpaceWidth(15),
              if (priceIcon != null)
                priceIcon is String
                    ? Image.asset(
                        priceIcon,
                        height: 18,
                        width: 18,
                        color: black.withOpacity(.3),
                      )
                    : Icon(priceIcon, size: 18, color: black.withOpacity(.5)),
              Flexible(
                child: new TextField(
                  onSubmitted: (_) {
                    //postHeadline();
                  },
//                textInputAction: maxLine==1?TextInputAction.done:TextInputAction.newline,
                  textCapitalization: TextCapitalization.sentences,
                  enabled: !selectorMode,

                  decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.fromLTRB(
                          (priceIcon != null) ? 5 : 10, 10, 10, 10),
                      hintText: "",
                      hintStyle: textStyle(false, 18, black.withOpacity(.2)),
                      counter: null
                      /*counterStyle: textStyle(true, 0, white)*/
                      ),
                  style: textStyle(
                    false,
                    18,
                    black,
                  ),
                  controller: controller,
                  cursorColor: black,
                  cursorWidth: 1,
//                          maxLength: 50,
                  maxLines: maxLine,
                  keyboardType:
                      isNum ? (TextInputType.number) : TextInputType.text,
                  scrollPadding: EdgeInsets.all(0),
                  onChanged: (String s) {
                    if (priceFormatted == null) return;
                    if (checking || s.trim().length < 4) {
                      priceFormatted();
                      return;
                    }
                    checking = true;

                    controller.text = formatAmount(s);
                    priceFormatted();

                    Future.delayed(Duration(milliseconds: 100), () {
                      final val = TextSelection.collapsed(
                          offset: controller.text.length);
                      controller.selection = val;
                      checking = false;
                      priceFormatted();
                    });
                  },
                ),
              ),
              if (selectorMode)
                Container(
                  margin: EdgeInsets.only(right: 10),
                  child: Icon(Icons.arrow_drop_down_circle,
                      size: 20, color: black.withOpacity(.5)),
                )
            ],
          ),
        ),
      ),
    ],
  );
}

String formatAmount(String text) {
  if (text == null) return "";
  if (text.isEmpty) return "";
  text = text.replaceAll(",", "");
  RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  Function mathFunc = (Match match) => '${match[1]},';

  return text.replaceAllMapped(reg, mathFunc);
}

nameItem(String title, String text, {color, bool center = false}) {
  color = color ?? black;
  return Container(
//    margin: EdgeInsets.only(bottom: 10),
    child: RichText(
      text: TextSpan(children: [
        TextSpan(text: title, style: textStyle(true, 13, color)),
        TextSpan(text: " ", style: textStyle(false, 14, color.withOpacity(.5))),
        TextSpan(
            text: "$text", style: textStyle(false, 14, color.withOpacity(.5)))
      ]),
      textAlign: center ? TextAlign.center : TextAlign.left,
    ),
  );
}

checkBox(bool selected, {double size: 13, checkColor = blue6}) {
  return new Container(
    //padding: EdgeInsets.all(2),
    child: Container(
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: blue09,
          border: Border.all(color: black.withOpacity(.1), width: 1)),
      child: Container(
        width: size,
        height: size,
        margin: EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? checkColor : transparent,
        ),
        child: Icon(
          Icons.check,
          size: size <= 16 ? 8 : null,
          color: !selected ? transparent : white,
        ),
      ),
    ),
  );
}

showListDialog(
  context,
  List items,
  onSelected, {
  title,
  images,
  bool useTint = true,
  selections,
}) {
  pushAndResult(
      context,
      listDialog(
        items,
        title: title,
        images: images,
        useTint: useTint,
        selections: selections,
      ), result: (_) {
    if (_ is List) {
      onSelected(_);
    } else {
      onSelected(items.indexOf(_));
    }
  }, opaque: false, depend: false);
}

//abstract class OnListItemSelected{
//  onSelected({int position,List selections});
//}

int getTodayMilli() {
  DateTime now = DateTime.now();
  return DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
}

int getWeekMilli() {
  DateTime now = DateTime.now();
  return DateTime(now.year, now.month, now.weekday).millisecondsSinceEpoch;
}

int getMonthMilli() {
  DateTime now = DateTime.now();
  return DateTime(
    now.year,
    now.month,
  ).millisecondsSinceEpoch;
}

int getYearMilli() {
  DateTime now = DateTime.now();
  return DateTime(
    now.year,
  ).millisecondsSinceEpoch;
}

String getOutreachPlaces(List soulList) {
  List list = [];
  for (BaseModel bm in soulList) {
    String mapName = bm.getString(MAP_NAME);
    if (!list.contains(mapName)) list.add(mapName);
  }
  return convertListToString(",", list);
}

String getAges(List soulList) {
  int minAge = 100000;
  int maxAge = 0;
  for (BaseModel bm in soulList) {
    int age = bm.getInt(SOUL_AGE);
    minAge = age < minAge ? age : minAge;
    maxAge = age > maxAge ? age : maxAge;
  }
  return "$minAge - $maxAge";
}

int getMilestoneCount(List soulList, String key) {
  int count = 0;
  for (BaseModel bm in soulList) {
    if (bm.getInt(key) != 0) count++;
  }
  return count;
}

class PlayVideo extends StatefulWidget {
  String id;
  String link;
  File videoFile;

  PlayVideo(this.id, this.link, {this.videoFile});
  @override
  _PlayVideoState createState() => _PlayVideoState();
}

class _PlayVideoState extends State<PlayVideo> {
  File videoFile;
  String videoLink;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    videoFile = widget.videoFile;
    if (videoFile == null) checkVideo();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        color: black,
        child: Stack(children: [
          /* chewieControl == null
              ? Container()
              : Center(
                  child: Chewie(
                    controller: chewieControl,
                  ),
                ),*/
          videoLink == null && videoFile == null
              ? Container()
              : videoFile != null
                  ? SimpleVideoPlayer(
                      file: videoFile,
                    )
                  : SimpleVideoPlayer(
                      source: videoLink,
                    ),
          new Container(
            margin: EdgeInsets.fromLTRB(0, 25, 0, 0),
            width: 50,
            height: 50,
            child: FlatButton(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onPressed: () {
                Navigator.pop(context);
              },
              child: Center(
                  child: Icon(
                Icons.keyboard_backspace,
                color: white,
                size: 25,
              )),
            ),
          )
        ]));
  }

  void checkVideo() async {
    String videoFileName = "${widget.id}${widget.link.hashCode}.mp4";

    File file = await getLocalFile(videoFileName);
    bool exist = await file.exists();

    if (!exist) {
      downloadFile(file);
      videoLink = widget.link;
      setState(() {});
      //createVideo(true, link: widget.link);
    } else {
      //createVideo(false, file: file);
      videoFile = file;
      setState(() {});
    }
  }

  void downloadFile(File file) async {
    //toastInAndroid("Downloading...");

    QuerySnapshot shots = await Firestore.instance
        .collection(REFERENCE_BASE)
        .where(FILE_URL, isEqualTo: widget.link)
        .limit(1)
        .getDocuments();
    if (shots.documents.isEmpty) {
      //toastInAndroid("Link not found");
    } else {
      for (DocumentSnapshot doc in shots.documents) {
        if (!doc.exists || doc.data.isEmpty) continue;
        BaseModel model = BaseModel(doc: doc);
        String ref = model.getString(REFERENCE);
        StorageReference storageReference =
            FirebaseStorage.instance.ref().child(ref);
        storageReference.writeToFile(file).future.then((_) {
          //toastInAndroid("Download Complete");
        }, onError: (error) {
          //toastInAndroid(error);
        }).catchError((error) {
          //toastInAndroid(error);
        });

        break;
      }
    }
  }
}

bool nameValid(String name) {
  int sameCount = 0;
  String prevText = "";
  for (int i = 0; i < name.length; i++) {
    String s = name[i].toLowerCase();
    if (prevText.isEmpty) {
      prevText = s;
      continue;
    }
    if (s == prevText) {
      sameCount++;
      if (sameCount > 2) return false;
    } else {
      sameCount = 0;
    }
  }

  return true;
}

showSnack(GlobalKey<ScaffoldState> key, String text, {bool useWife = false}) {
  key.currentState
      .showSnackBar(getSnack(key.currentContext, text, useWife: useWife));
}

SnackBar getSnack(context, String text, {bool useWife = false}) {
  return SnackBar(
    content: Text(
      text,
      style: textStyle(true, 16, white),
      textAlign: TextAlign.center,
    ),
    backgroundColor: black,
    duration: Duration(seconds: 2),
  );
}

Widget getAssetImage(String asset) {
  return Image.asset(
    asset,
    height: 30.0,
    width: 30.0,
    color: Colors.amber,
  );
}

groupedButtons(
  List options,
  String currentSelection,
  onSelected(text, position), {
  @required selectedColor,
  @required normalColor,
  @required selectedTextColor,
  @required normalTextColor,
}) {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: EdgeInsets.all(0),
    physics: BouncingScrollPhysics(),
    child: Row(
      mainAxisSize: MainAxisSize.max,
      children: List.generate(options.length, (p) {
        String text = options[p];
        bool selected = currentSelection == text;
        return GestureDetector(
            onTap: () {
              onSelected(text, options.indexOf(text));
            },
            child: Container(
              height: 35,
              constraints: BoxConstraints(minWidth: 70),
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              margin: EdgeInsets.fromLTRB(
                  p == 0 ? 0 : 5, 0, p == options.length - 1 ? 0 : 5, 0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: selected ? selectedColor : null,
                  border: !selected
                      ? Border.all(
                          width: 1,
                          color: normalColor,
                          style: BorderStyle.solid)
                      : null),
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                      fontSize: 14,
                      fontFamily: "AvertaB",
                      fontWeight: FontWeight.normal,
                      color: selected ? selectedTextColor : normalTextColor),
                ),
              ),
            ));
      }),
    ),
  );
}

bool passwordVisible = false;
textbox(TextEditingController controller, String hint,
    {int lines = 1,
    bool isName = false,
    focusNode,
    bool isPass = false,
    refresh,
    maxLength,
    bool center = true,
    onChanged,
    bool dontPad = false,
    bool isNum = false,
    double rad = 25}) {
  return Container(
    constraints: BoxConstraints(minHeight: 45),
    margin: EdgeInsets.fromLTRB(
        dontPad ? 0 : 15, 0, dontPad ? 0 : 15, dontPad ? 0 : 15),
    padding: EdgeInsets.fromLTRB(isPass ? 40 : 10, 0, 10, 0),
//    height: lines>1?null:50,
    decoration: BoxDecoration(
      border: Border.all(color: black.withOpacity(.5), width: 2),
      borderRadius: BorderRadius.circular(rad),
//        color: blue09
    ),
    child: new TextField(
      controller: controller,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      textCapitalization:
          isPass ? TextCapitalization.none : TextCapitalization.sentences,
      textInputAction:
          lines > 1 ? TextInputAction.newline : TextInputAction.done,
      focusNode: focusNode,
      decoration: InputDecoration(
          hintText: hint,
          isDense: true,
          suffix: !isPass
              ? null
              : GestureDetector(
                  onTap: () {
                    passwordVisible = !passwordVisible;
                    if (refresh != null) refresh();
                  },
                  child: Text(
                    passwordVisible ? "HIDE" : "SHOW",
                    style: textStyle(false, 12, black.withOpacity(.5)),
                  )),
          hintStyle: textStyle(
            false,
            18,
            black.withOpacity(.35),
          ),
          border: InputBorder.none),
      textAlign: center ? TextAlign.center : TextAlign.left,
      style: textStyle(
        false,
        18,
        black,
      ),
      maxLength: isName ? 30 : null,
      cursorColor: black, obscureText: isPass && !passwordVisible,
      onChanged: onChanged,
      //maxLength: 200,
      cursorWidth: 1,
      minLines: lines, maxLines: lines,
    ),
  );
}

textboxTv(String text, String hint, onTap) {
  return GestureDetector(
    onTap: () {
      onTap();
    },
    child: Container(
      margin: EdgeInsets.fromLTRB(15, 0, 15, 15),
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      height: 50,
      decoration: BoxDecoration(
          border: Border.all(color: black.withOpacity(.1), width: 1),
          borderRadius: BorderRadius.circular(5),
          color: blue09),
      child: Center(
        child: Text(text.isEmpty ? hint : text,
            style: textStyle(
              false,
              22,
              black.withOpacity(text.isNotEmpty ? (1) : .35),
            )),
      ),
    ),
  );
}

String getFullName(BaseModel bm) {
  return "${bm.getString(NAME)}";
}

String getFirstName(bm) {
  return bm.getString(NAME).split(" ")[0].trim();
}

getChatMessage(BaseModel chat) {
  String text = chat.getString(MESSAGE);
  int type = chat.getType();
  if (type == CHAT_TYPE_DOC) text = "Document";
  if (type == CHAT_TYPE_IMAGE) text = "Photo";
  if (type == CHAT_TYPE_VIDEO) text = "Video (${chat.getString(VIDEO_LENGTH)})";
  if (type == CHAT_TYPE_REC)
    text = "Voice Message (${chat.getString(AUDIO_LENGTH)})";
  return text;
}

getChatIcon(BaseModel chat) {
  int type = chat.getType();
  var icon;
  if (type == CHAT_TYPE_DOC) icon = Icons.assignment;
  if (type == CHAT_TYPE_IMAGE) icon = Icons.photo;
  if (type == CHAT_TYPE_VIDEO) icon = Icons.videocam;
  if (type == CHAT_TYPE_REC) icon = Icons.mic;
  if (icon == null) return Container();
  return icon;
}

Map createLoveMap(BaseModel user) {
  Map myMap = Map();
  myMap[TIME] = DateTime.now().millisecondsSinceEpoch;
  myMap[OBJECT_ID] = user.getUserId();
  myMap[STATUS] = PENDING;
  return myMap;
}

/*bool hasLove(BaseModel user,String userId){
  List lovers = user.getList(LOVE_LIST);
  return (lovers.indexWhere((map)=>map[OBJECT_ID]==userId))!=-1;
}*/

createLoveListForHubbyx(String uId, {int delay = 0}) async {
  var lock = Lock();
  await lock.synchronized(() async {
    Future.delayed(Duration(seconds: delay), () async {
//      toastInAndroid("Updating Hubby");
      DocumentSnapshot doc = await Firestore.instance
          .collection(USER_BASE)
          .document(uId)
          .get(source: Source.server)
          .catchError((e) {
        delay = delay + 10;
        delay = delay > 60 ? 10 : delay;
        createLoveListForHubbyx(uId, delay: delay);
        return null;
      });

      if (doc == null) return;
      if (!doc.exists) return;

      BaseModel hubby = BaseModel(doc: doc);
//      hubby.putInList(LOVE_LIST, createLoveMap(userModel), true);
      hubby.updateItems();

      if (hubby.getBoolean(PUSH_NOTIFICATION))
        NotificationService.sendPush(
          token: hubby.getString(TOKEN),
          title: "New Wifee",
          body: "${userModel.getString(NAME)} accepted your wifee request",
          tag: '${userModel.getObjectId()}wifee',
        );
    });
  });
}

getOtherPersonId(BaseModel chatModel) {
  List parties = chatModel.getList(PARTIES);
  parties.remove(userModel.getObjectId());
  if (parties.isEmpty) return "";
  return parties[0];
}

String getProfileKey(BaseModel user) {
  return "${user.getString(USER_ID)}${user.getInt(PROFILE_UPDATED)}";
}

bool isBlocked(model, {String userId}) {
  if (userId != null) {
    if (userId.isNotEmpty && blockedIds.contains(userId)) return true;
    return false;
  }

  String oId = model.getObjectId();
  String uId = model.getString(USER_ID);
  String dId = model.getString(DEVICE_ID);
  if (oId.isNotEmpty && blockedIds.contains(oId)) return true;
  if (uId.isNotEmpty && blockedIds.contains(uId)) return true;
//  if(dId.isNotEmpty && blockedIds.contains(dId))return true;

  return false;
}

updateSettingsItem(context, String title, String key,
    {@required bool isNumber, allowEmpty}) {
  pushAndResult(
      context,
      inputDialog(
        title,
        hint: title,
        inputType: isNumber ? TextInputType.number : TextInputType.text,
        message: !isNumber
            ? (appSettingsModel.getString(key))
            : appSettingsModel.getInt(key).toString(),
        allowEmpty: allowEmpty,
      ), result: (_) {
    appSettingsModel.put(key, !isNumber ? (_.trim()) : int.parse(_.trim()));
    appSettingsModel.updateItems();
  });
}

Future<void> toastInAndroid(String text) async {
  const platform = const MethodChannel("channel.john");
  try {
    await platform.invokeMethod('toast', <String, String>{'message': text});
  } on PlatformException catch (e) {
    //batteryLevel = "Failed to get what he said: '${e.message}'.";
  }
}

Future<void> openTheFile(String filePath) async {
  const platform = const MethodChannel("channel.john");
  try {
    await platform.invokeMethod('openFile', <String, String>{'path': filePath});
  } on PlatformException catch (e) {
    //batteryLevel = "Failed to get what he said: '${e.message}'.";
  }
}

Future<void> shareApp({String message}) async {
  const platform = const MethodChannel("channel.john");
  try {
    await platform
        .invokeMethod('shareApp', <String, String>{'message': message});
  } on PlatformException catch (e) {
    //batteryLevel = "Failed to get what he said: '${e.message}'.";
  }
}

Future<void> updatePackage() async {
  String package = appSettingsModel.getString(PACKAGE_NAME);
  if (package.isEmpty) return;
  const platform = const MethodChannel("channel.john");
  try {
    await platform.invokeMethod(
        'updatePackage', <String, String>{'packageName': package});
  } on PlatformException catch (e) {
    //batteryLevel = "Failed to get what he said: '${e.message}'.";
  }
}

Color getColorForKey(String key) {
  if (key == RED) return red0;
  if (key == GREEN) return light_green3;
  if (key == BROWN) return brown0;
  if (key == DARK_GREEN) return dark_green0;
  if (key == ORANGE) return orange3;
  if (key == DARK_BLUE) return blue4;
  return blue0;
}

double screenWidth(context) {
  return MediaQuery.of(context).size.width;
}

double screenHeight(context) {
  return MediaQuery.of(context).size.height;
}

onlineDot() {
  return Container(
    width: 10,
    height: 10,
    margin: EdgeInsets.fromLTRB(5, 5, 0, 0),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: white, width: 2),
      color: red0,
    ),
  );
}
//
//getFullname(BaseModel personModel) {
//  return "${personModel.getString(NAME)} ${personModel.getString(LAST_NAME)}";
//}

bool isOnline(BaseModel user) {
  int now = DateTime.now().millisecondsSinceEpoch;
  int lastUpdated = user.getInt(TIME_UPDATED);
  bool notOnline =
      ((now - lastUpdated) > (Duration.millisecondsPerMinute * 10));
  return user.getBoolean(IS_ONLINE) && (!notOnline);
}

deleteFileOnline(String url) async {
  QuerySnapshot shots = await Firestore.instance
      .collection(REFERENCE_BASE)
      .where(FILE_URL, isEqualTo: url)
      .limit(1)
      .getDocuments();

  for (DocumentSnapshot doc in shots.documents) {
    BaseModel model = BaseModel(doc: doc);
    String ref = model.getString(REFERENCE);
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child(ref);
    storageReference.delete();
  }
}

peopleItem(context, BaseModel user) {
  int now = DateTime.now().millisecondsSinceEpoch;
  int lastUpdated = user.getInt(TIME_UPDATED);
  bool notOnline =
      ((now - lastUpdated) > (Duration.millisecondsPerMinute * 10));
  bool isOnline = user.getBoolean(IS_ONLINE) && (!notOnline);
  int gender = user.getInt(GENDER);

  bool dontChat = false;
  /*!user.getList(LOVE_IDS).contains(userModel.getObjectId()) &&
      !userModel.getList(PAID_CHATS).contains(user.getObjectId());*/
  return GestureDetector(
    onTap: () {
      // pushAndResult(
      //     context,
      //     MyProfile1(
      //       user,
      //     ));
    },
    child: Container(
      color: transparent,
      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Stack(
                //fit: StackFit.expand,
                children: <Widget>[
                  new Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        side: BorderSide(color: blue09, width: 1)),
                    clipBehavior: Clip.antiAlias,
                    color: white,
                    elevation: .5,
                    child: Stack(
                      children: <Widget>[
                        Container(
                          width: 70,
                          height: 100,
                          color: blue09,
                          child: Center(
                              child: Image.asset(
                                  gender == MALE ? ic_male : ic_female,
                                  color: blue0,
                                  width: 20,
                                  height: 20)),
                        ),
                        CachedNetworkImage(
                          width: 70,
                          height: 100,
                          imageUrl: user.getString(USER_IMAGE),
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  ),
                  !isOnline
                      ? Container()
                      : Container(
                          width: 10,
                          height: 10,
                          margin: EdgeInsets.fromLTRB(5, 5, 0, 0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: white, width: 2),
                            color: red0,
                          ),
                        ),
                ],
              ),
              addSpaceWidth(10),
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      //"Emeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",
                      user.getString(NAME),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: textStyle(true, 18, white),
                    ),
                    Text(
                      isOnline
                          ? "Online now"
                          : "Last seen ${timeAgo.format(DateTime.fromMillisecondsSinceEpoch(user.getInt(TIME_UPDATED)), locale: "en_short")}",
                      style: textStyle(
                        false,
                        12,
                        white.withOpacity(.5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              addSpaceWidth(10),
              if (!dontChat)
                Container(
                  width: 40,
                  height: 40,
                  child: FlatButton(
                    onPressed: () {
                      clickChat(context, user, false);
                    },
                    shape: CircleBorder(
//                    side: BorderSide(color: white,width: 2)
                        ),
                    color: black,
                    child: Icon(
                      Icons.chat,
                      color: white,
                      size: 20,
                    ),
                    padding: EdgeInsets.all(0),
                  ),
                ),
              addSpaceWidth(10),
              /* Image.asset(ic_coin,width: 15,height: 20,color:Colors.amber),
                addSpaceWidth(5),
                Text("$chatCost",style: textStyle(false, 14, gold),),
                addSpaceWidth(10),

                addSpaceWidth(10),*/
            ],
          ),
          addSpace(5),
          addLine(.5, white.withOpacity(.1), 0, 5, 0, 0)
        ],
      ),
    ),
  );
}

void downloadFile(File file, String urlLink, onComplete(e)) async {
  print("Downloading $urlLink");
  QuerySnapshot shots = await Firestore.instance
      .collection(REFERENCE_BASE)
      .where(FILE_URL, isEqualTo: urlLink)
      .limit(1)
      .getDocuments();
  if (shots.documents.isEmpty) {
    onComplete("not found");
    print("$urlLink not found");
    return;
  }
  for (DocumentSnapshot doc in shots.documents) {
    if (!doc.exists || doc.data.isEmpty) continue;
    print("OKORE >>>> DOWNLOADING....<<<<");
    String ref = doc.data[REFERENCE];
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child(ref);
    storageReference.writeToFile(file).future.then((_) {
      onComplete(null);
    }, onError: (error) {}).catchError((error) {
      file.delete();
      onComplete(error);
    });

    break;
  }
}

class CodeWheeler {
  final int milliseconds;
  VoidCallback action;
  Timer _timer;
  int page = 0;

  CodeWheeler({this.milliseconds});

  run(Function action) {
    if (null != _timer) {
      _timer.cancel();
    }
    _timer = Timer.periodic(Duration(milliseconds: milliseconds), (_) {
      action();
    });
  }

  close() {
    _timer?.cancel();
  }
}

fieldSelector(String title,
    {bool active = false,
    double size = 100.0,
    double margin = 10.0,
    onTap,
    AlignmentGeometry alignment = Alignment.center}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 40,
      decoration: BoxDecoration(
          border: active ? null : Border.all(width: 1),
          color: active ? AppConfig.appColor : white,
          borderRadius: BorderRadius.circular(25)),
      padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
      margin: EdgeInsets.fromLTRB(0, 0, 10, 5),
      width: size,
      alignment: alignment,
      child: Text(title, style: textStyle(true, 14, active ? white : black)),
    ),
  );
}

String getChatDate(int milli) {
  final formatter = DateFormat("MMM d 'AT' h:mm a");
  DateTime date = DateTime.fromMillisecondsSinceEpoch(milli);
  return formatter.format(date);
}

String getChatTime(int milli) {
  final formatter = DateFormat("h:mm a");
  DateTime date = DateTime.fromMillisecondsSinceEpoch(milli);
  return formatter.format(date);
}

String getTimeAgo(int sec) {
  return timeAgo.format(DateTime.fromMillisecondsSinceEpoch(sec));
}

userImageItem(
  context,
  BaseModel model, {
  double size = 40,
  double strokeSize = 4,
  strokeColor = white_color,
  bool padLeft = true,
}) {
  return new GestureDetector(
    onTap: () {
      pushAndResult(
          context,
          ShowStore(
            model,
          ),
          depend: false);
    },
    child: new AnimatedContainer(
      duration: Duration(milliseconds: 500),
      decoration: BoxDecoration(
        border: Border.all(width: strokeSize, color: strokeColor),
        shape: BoxShape.circle,
        color: AppConfig.appColor,
      ),
      margin: EdgeInsets.fromLTRB(padLeft ? 10 : 0, 0, 0, 0),
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          model.userImage.isEmpty
              ? Center(
                  child: Text(
                    getInitials(model.getString(NAME)),
                    style: textStyle(true, 14, white),
                  ),
                )
              : Card(
                  margin: EdgeInsets.all(0),
                  shape: CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  color: transparent,
                  elevation: 0,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      Container(
                        width: size,
                        height: size,
                        child: Center(
                            child: Icon(
                          Icons.person,
                          color: white,
                          size: 15,
                        )),
                      ),
                      CachedNetworkImage(
                        imageUrl: model.userImage,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                ),

          /*ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Container(
//                width: size,
              height: size,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppConfig.appColor,
                  gradient: LinearGradient(colors: [
                    orange01,
                    orange04,
                  ])),
              child: model.userImage.isEmpty
                  ? Center(
                      child: Text(
                        getInitials(model.getString(NAME)),
                        style: textStyle(true, 14, white),
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: model.userImage,
                      fit: BoxFit.cover,
                    ),
            ),
          ),*/
          if (isOnline(model) && !model.myItem())
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: white, width: 2),
                color: red0,
              ),
            ),
        ],
      ),
    ),
  );
}

getInitials(String name) {
  if (name.isEmpty) return "";
  if (name.trim().contains(" ")) {
    var parts = name.split(" ");
    return ("${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}")
        .toUpperCase();
  }
  // if (name.length >= 2) {
  //   return (name.substring(0, 2)).toUpperCase();
  // }
  return name.substring(0, 1).toUpperCase();
}

shopItem(BuildContext context, BaseModel model, setState,
    {onLiked, bool isFavorite = false}) {
  String id = model.getObjectId();
  String image = getFirstPhoto(model.images);
  String category = model.getString(CATEGORY);
  String title = model.getString(TITLE);
  double price = model.getDouble(PRICE);
  int p = cartLists.indexWhere((e) => e.getObjectId() == id);
  bool isInCart = p != -1;
  int fP = productLists.indexWhere((e) => e.getObjectId() == id);
  bool isFavorite = model.getList(LIKES).contains(userModel.getUserId());
  bool isPromoted = model.getBoolean(IS_PROMOTED);

  return GestureDetector(
    onTap: () {
      pushAndResult(
          context,
          ShowDetails(
            model,
            objectId: id,
          ),
          depend: false);
    },
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(color: black.withOpacity(.1)
//            border: Border.all(color: white.withOpacity(0.1), width: 2)
            ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: image,
                    fit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity,
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () {
                        if (fP != -1)
                          productLists[fP]
                            ..putInList(
                                LIKES, userModel.getUserId(), !isFavorite)
                            ..updateItems();
                        setState();
                      },
                      child: Container(
                        decoration:
                            BoxDecoration(color: white, shape: BoxShape.circle),
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.all(8),
                        height: 35,
                        width: 35,
                        alignment: Alignment.center,
                        /* child: Center(
                    child: Icon(
                      Icons.favorite,
                      size: 15,
                      color: isFavorite ? green_dark : black.withOpacity(.7),
                    ),
                  ),*/
                        child: FlareActor("assets/icons/Favorite.flr",
                            shouldClip: false,
                            color: isFavorite ? red : black.withOpacity(0.5),
                            fit: BoxFit.cover,
                            animation: isFavorite
                                ? "Favorite"
                                : "Unfavorite" //_animationName
                            ),
                      ),
                    ),
                  ),
                  if (isPromoted)
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                          color: AppConfig.appColor,
                        ),
                        padding: EdgeInsets.all(6),
                        //margin: EdgeInsets.all(8),
                        height: 35,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.public_rounded,
                              size: 15,
                            ),
                            addSpaceWidth(4),
                            Text(
                              "Sponsored",
                              style: textStyle(false, 12, black),
                            )
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(1),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  )),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: textStyle(false, 14, black),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        addSpace(2),
                        Text("\$${formatCurrency.format(price)}",
                            style: textStyle(true, 14, AppConfig.appColor)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (!model.myItem()) cartController.add(model);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: isInCart ? red : black.withOpacity(.4),
                          shape: BoxShape.circle),
                      padding: EdgeInsets.all(8),
                      child: Image.asset(
                        ic_cart,
                        height: 15,
                        width: 15,
                        color: white,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

shopItemX(BuildContext context, BaseModel model, setState,
    {onLiked(BaseModel model), bool isFavorite = false}) {
  String id = model.getObjectId();
  String image = getFirstPhoto(model.images);
  String category = model.getString(CATEGORY);
  String title = model.getString(TITLE);
  double price = model.getDouble(PRICE);
  int p = cartLists.indexWhere((e) => e.getObjectId() == id);
  bool isInCart = p != -1;
  //bool isFavorite = model.getList(LIKED).contains(userModel.getUserId());

  return GestureDetector(
    onTap: () {
      pushAndResult(
          context,
          ShowDetails(
            model,
            objectId: id,
          ),
          depend: false);
    },
    child: ClipRRect(
      borderRadius: BorderRadius.circular(5),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(color: black.withOpacity(.1)
//            border: Border.all(color: white.withOpacity(0.1), width: 2)
            ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: image,
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.fromLTRB(8, 8, 8, 8),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  color: white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
//                            Text.rich(TextSpan(children: [
//                              TextSpan(
//                                  text: "Category ",
//                                  style: textStyle(false, 12, black.withOpacity(.5))),
//                              TextSpan(
//                                  text: category, style: textStyle(false, 12, black)),
//                            ])),
//                            addSpace(2),
                            Text(
                              title,
                              style: textStyle(false, 14, black),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                            addSpace(2),
                          ],
                        ),
                      ),
                      FlatButton(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onPressed: () {
                          if (!model.myItem()) cartController.add(model);
                        },
                        color: isInCart ? red : AppConfig.appColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
//                            side: BorderSide(color: white)
                        ),
                        child: Center(
                          child: Text.rich(TextSpan(children: [
                            TextSpan(
                                text: isInCart ? "REMOVE " : "SHOP ",
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
            // Align(
            //   alignment: Alignment.topRight,
            //   child: GestureDetector(
            //     onTap: () {
            //       int p = productLists.indexWhere(
            //           (e) => e.getObjectId() == model.getObjectId());
            //       if (p == -1) return;
            //
            //       print("okkk");
            //
            //       productLists[p]
            //         ..putInList(LIKES, userModel.getUserId(), true)
            //         ..updateItems();
            //       setState();
            //       print("model>>> ${model.getList(LIKED)}");
            //       //onLiked(model);
            //
            //     },
            //     child: Container(
            //       decoration:
            //           BoxDecoration(color: white, shape: BoxShape.circle),
            //       padding: EdgeInsets.all(10),
            //       margin: EdgeInsets.all(8),
            //       height: 35,
            //       width: 35,
            //       // child: Icon(
            //       //   Icons.favorite,
            //       //   size: 17,
            //       //   color: black.withOpacity(.7),
            //       // ),
            //       child: FlareActor("assets/icons/Favorite.flr",
            //           shouldClip: false,
            //           color: isFavorite ? green_dark : black.withOpacity(.5),
            //           fit: BoxFit.cover,
            //           animation: isFavorite
            //               ? "Favorite"
            //               : "Unfavorite" //_animationName
            //           ),
            //     ),
            //   ),
            // )
          ],
        ),
      ),
    ),
  );
}

enum UniqueStatus {
  searching,
  available,
  failed,
  none,
}

textInputField(
    {@required TextEditingController controller,
    @required String title,
    @required String hint,
    @required String asset,
    bool isPass = false,
    bool isPhone = false,
    UniqueStatus unique = UniqueStatus.none,
    FocusNode focusNode,
    IconData icon,
    void Function() refresh,
    void Function(String) onSearching,
    onPhoneTap,
    int maxLines = 1,
    bool disableIconAsset = false,
    Color fillColor,
    bool fill = false}) {
  return Container(
    padding: EdgeInsets.only(left: 15, right: 15),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        addSpace(5),
        Text(
          title,
          style: textStyle(false, 14, AppConfig.appColor),
        ),
        addSpace(4),
        Container(
          padding: EdgeInsets.only(left: 15, right: 15),
          decoration: BoxDecoration(
              color: fill ? black.withOpacity(0.08) : white,
              border: Border.all(
                color: black.withOpacity(fill ? 0 : 0.2),
              ),
              borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              if (!disableIconAsset)
                Icon(
                  icon,
                  color: AppConfig.appColor,
                ),
              if (!disableIconAsset)
                Container(
                  height: 20,
                  width: 1,
                  color: black.withOpacity(.1),
                  margin: EdgeInsets.only(left: 5, right: 15),
                ),
              Flexible(
                child: TextField(
                  controller: controller,
                  maxLines: maxLines,
                  obscureText: isPass && !passwordVisible,
                  keyboardType: isPhone ? TextInputType.number : null,
                  onChanged: (unique == null || onSearching == null)
                      ? null
                      : onSearching,
                  decoration: InputDecoration(
                      suffix: !isPass
                          ? null
                          : GestureDetector(
                              onTap: () {
                                passwordVisible = !passwordVisible;
                                if (refresh != null) refresh();
                              },
                              child: Text(
                                passwordVisible ? "HIDE" : "SHOW",
                                style:
                                    textStyle(false, 12, black.withOpacity(.5)),
                              )),
                      hintText: hint,
                      hintStyle: textStyle(false, 16, black.withOpacity(.6)),
                      border: InputBorder.none),
                ),
              ),
              if (null != unique)
                Container(
                  height: 20,
                  width: 20,
                  alignment: Alignment.center,
                  child: uniqueBuilder(unique),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: unique == UniqueStatus.none
                          ? transparent
                          : unique == UniqueStatus.searching
                              ? transparent
                              : unique == UniqueStatus.available ? green : red),
                ),
              if (isPhone && (null != onPhoneTap)) ...[
                Container(
                  height: 20,
                  width: 1,
                  color: black.withOpacity(.1),
                  margin: EdgeInsets.only(left: 5, right: 15),
                ),
                GestureDetector(
                  onTap: () {
                    onPhoneTap();
                  },
                  child: Row(children: [
                    addSpaceWidth(5),
                    Image.asset(country.countryFlag, height: 20, width: 20),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: black.withOpacity(.4),
                    ),
                  ]),
                ),
              ]
            ],
          ),
        ),
      ],
    ),
  );
}

uniqueBuilder(UniqueStatus status) {
  switch (status) {
    case UniqueStatus.searching:
      // TODO: Handle this case.
      return CircularProgressIndicator(
        strokeWidth: 2,
        //valueColor: AlwaysStoppedAnimation(AppConfig.appColor),
      );
      break;
    case UniqueStatus.available:
      // TODO: Handle this case.
      return Icon(
        Icons.check,
        color: white,
        size: 15,
      );
      break;
    case UniqueStatus.failed:
      // TODO: Handle this case.
      return Icon(
        Icons.error_outline,
        color: white,
        size: 15,
      );
      break;
    case UniqueStatus.none:
      // TODO: Handle this case.
      return Container();
      break;
  }
}

selectorField({
  @required String value,
  @required String title,
  @required String hint,
  String asset,
  IconData icon,
  void Function() onTap,
  bool fill = false,
  bool disableIconAsset = false,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.only(left: 15, right: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          addSpace(5),
          Text(
            title,
            style: textStyle(false, 14, AppConfig.appColor),
          ),
          addSpace(4),
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: fill ? black.withOpacity(0.08) : white,
                border: Border.all(
                  color: black.withOpacity(fill ? 0 : 0.2),
                ),
                borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                if (null == icon && !disableIconAsset)
                  Image.asset(
                    asset,
                    height: 20,
                    width: 20,
                    fit: BoxFit.cover,
                    color: AppConfig.appColor,
                  )
                else if (null != asset && !disableIconAsset)
                  Icon(
                    icon,
                    color: AppConfig.appColor,
                  ),
                if (!disableIconAsset)
                  Container(
                    height: 20,
                    width: 1,
                    color: black.withOpacity(.1),
                    margin: EdgeInsets.only(left: 5, right: 15),
                  ),
                Text(
                  value ?? hint,
                  style: textStyle(
                      false, 16, black.withOpacity(value == null ? 0.5 : 1)),
                ),
                Spacer(),
                Icon(
                  Icons.arrow_drop_down_circle,
                  color: black.withOpacity(.5),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

double get accountBalance => userModel.getDouble(ESCROW_BALANCE);

fundWallet(BuildContext context, {onProcessed, bool isPremium = false}) async {
  if (isPremium) {
    pushAndResult(
        context,
        PaymentDetails(
          amount: 10,
          isSubscription: true,
        ),
        depend: false, result: (_) {
      if (onProcessed != null) onProcessed(true);
    });
    return;
  }

  pushAndResult(context, AmountDialog(), depend: false, result: (_) async {
    if (null == _) return;
    pushAndResult(
        context,
        PaymentDetails(
          amount: _,
        ),
        depend: false, result: (BaseModel _) {
      if (null == _) return;
//      double availableBalance = userModel.getDouble(ESCROW_BALANCE);
//      userModel
//        ..put(ESCROW_BALANCE, availableBalance + _.getDouble(AMOUNT))
//        ..updateItems();
      onProcessed(true);
    });
  });
}

fundSeller(BuildContext context, BaseModel seller, double amount,
    {onProcessed}) async {
  showMessage(context, Icons.warning, red, "Pay Seller?",
      "Are you sure you want to proceed with the payment to seller @${seller.getString(NAME)}?",
      clickYesText: "Pay", clickNoText: "Go Back", onClicked: (_) {
    if (!_) return;
    double accountBal = userModel.getDouble(ESCROW_BALANCE);
    double accountBalSeller = seller.getDouble(ESCROW_BALANCE);
    double leftOver = accountBal - amount;
    double addToSeller = accountBalSeller + amount;
    userModel
      ..put(ESCROW_BALANCE, leftOver)
      ..updateItems();
    seller
      ..put(ESCROW_BALANCE, addToSeller)
      ..updateItems();
    if (null != onProcessed) onProcessed();
  });
}

void handleOrder(
    BuildContext context, List<BaseModel> products, double offerAmount,
    {onOfferSettled}) {
  showMessage(context, LineIcons.shopping_cart, green_dark, "CheckOut?",
      "Are you sure want to proceed to checkout and process products?",
      clickNoText: "Go Back", clickYesText: "CheckOut", onClicked: (_) {
    if (!_) return;
    //TODO 1. Deduct funds from my wallet and move into order created
    //TODO 2. (Migrate) products into Order with status ORDER_PENDING
    //TODO 3. Create a push notification to the seller

    //TODO 1.
    List idsNotified = [];
    double accountBal = userModel.getDouble(ESCROW_BALANCE);
    double leftOver = accountBal - offerAmount;
    userModel
      ..put(ESCROW_BALANCE, leftOver)
      ..updateItems();

    //TODO 2.
    String orderId = getRandomId();
    for (var product in products) {
      String id = getRandomId();
      String productId = product.getObjectId();
      String userImage = product.userImage;
      String name = product.getString(NAME);
      String sellerId = product.getUserId();
      List grouped = products.where((e) => e.getUserId() == sellerId).toList();
      int count = grouped.length;
      List parties = [userModel.getObjectId(), sellerId];
      product
        ..put(OBJECT_ID, id)
        ..put(ORDER_ID, orderId)
        ..put(PRODUCT_ID, productId)
        ..put(SELLER_ID, sellerId)
        ..put(SETTLING_AMOUNT, offerAmount)
        ..put(PARTIES, parties)
        ..saveItem(ORDER_BASE, true, document: id);

      //TODO 3.
      BaseModel notifyModel = BaseModel();
      String message = 'An order request for your product was requested!';
      if (count > 1)
        message = 'An order request for your products was requested!';
      notifyModel
        //..put(MESSAGE, message)
        ..put(ORDER_ID, orderId)
        ..put(PRODUCT_ID, productId)
        ..put(PARTIES, [sellerId])
        ..put(USER_IMAGE, userImage)
        ..put(USER_ID, sellerId)
        ..put(NAME, name)
        ..saveItem(NOTIFY_BASE, false);
      if (idsNotified.contains(sellerId)) continue;
      Firestore.instance
          .collection(USER_BASE)
          .document(sellerId)
          .get()
          .then((value) {
        BaseModel seller = BaseModel(doc: value);
        notifyModel..remove(UPDATED_AT)..remove(CREATED_AT);
        NotificationService.sendPush(
            title: "Product Ordered!",
            data: notifyModel.items,
            token: seller.getString(TOKEN));
        idsNotified.add(sellerId);
      });
      onOfferSettled();
    }
  });
}

checkError(context, e, {bool indexErrorOnly = true}) {
  String error = e.toString();

  print(e);

  if (error.contains("PRECONDITION") ||
      error.contains('The query requires an index')) {
    String link =
        error.substring(error.indexOf("https://"), error.indexOf(", null"));
    showMessage(context, Icons.error, blue0, "Index Needed", link,
        clickYesText: "Create Index", onClicked: (_) {
      if (_ == true) {
        openLink(link);
      }
    });
  } else {
    if (!indexErrorOnly)
      showErrorDialog(
        context,
        e.toString(),
      );
  }
}

showErrorDialog(context, String message,
    {onOkClicked, bool cancellable = true}) {
  showMessage(context, Icons.error, red0, "Oops!", message,
      delayInMilli: 500, cancellable: cancellable, onClicked: (_) {
    if (_ == true) {
      if (onOkClicked != null) onOkClicked();
    }
  });
}
