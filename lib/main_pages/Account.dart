import 'package:Strokes/AppEngine.dart';
import 'package:Strokes/MainAdmin.dart';
import 'package:Strokes/app/app.dart';
import 'package:Strokes/app_config.dart';
import 'package:Strokes/assets.dart';
import 'package:Strokes/auth/login_page.dart';
import 'package:Strokes/auth/signUp_page.dart';
import 'package:Strokes/basemodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo/photo.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_compress/video_compress.dart';

import 'EditProfile.dart';

class Account extends StatefulWidget {
  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: page(),
    );
  }

  page() {
    return ListView(
      padding: EdgeInsets.all(0),
      children: [
        if(!isLoggedIn)Container(
          width: double.infinity,
//          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: black.withOpacity(.05),
              borderRadius: BorderRadius.circular(5)),
          child: Row(
            children: [
              Flexible(child: FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                      side: BorderSide(
                          color: black,width: 2
                      )),
//                    color: blue3,
                  onPressed: (){
                    pushAndResult(context, LoginPage(), depend: false);
                  },
                  child: Text(
                    "Login",
                    style: textStyle(true, 16, black),
                  )),fit: FlexFit.tight,),
             addSpaceWidth(10),
             Flexible(child: FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                      side: BorderSide(
                          color: black,width: 2
                      )),
//                    color: blue3,
                  onPressed: (){
                    pushAndResult(context, SignUp(), depend: false);
                  },
                  child: Text(
                    "Signup",
                    style: textStyle(true, 16, black),
                  )),fit: FlexFit.tight,),

            ],
          ),
        ),
        if(isLoggedIn)Container(
          width: double.infinity,
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: black.withOpacity(.05),
//                  border: Border.all(color: black.withOpacity(.09)),
              borderRadius: BorderRadius.circular(5)),
          child: Column(
//                    crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              userImageItem(context, userModel,
                  size: 60, strokeSize: 1,padLeft: false),
              Text(
                userModel.getString(NAME),
                style: textStyle(true, 20, black),
              ),
              StarRating(
                rating: 5,
                size: 16,
                color: AppConfig.appColor,
                borderColor: black,
              ),
              addSpace(5),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: 12,
                        color: black,
                      ),
                      addSpaceWidth(2),
                      Text(
                        "Buyer",
                        style: textStyle(false, 12, black),
                      ),
                    ],
                  ),
                  addSpaceWidth(10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 8,
                        width: 8,
                        decoration: BoxDecoration(
                            color: dark_green0, shape: BoxShape.circle),
                      ),
                      addSpaceWidth(2),
                      Text(
                        "Active",
                        style: textStyle(false, 12, black),
                      ),
                    ],
                  ),
                ],
              ),
//                      Spacer(),
              Container(
//                    decoration: BoxDecoration(
//                        border: Border.all(color: black, width: 2),
//                        color: black.withOpacity(.9),
//                        borderRadius: BorderRadius.circular(15)
//                      //shape: BoxShape.circle
//                    ),
//                    padding: EdgeInsets.all(5),
                //height: 70,
                //width: 70,
                alignment: Alignment.center,
                child: Row(
                    mainAxisSize: MainAxisSize.min,
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
                            Container(
                              width: 40,height: 40,
                              decoration: BoxDecoration(
                                  color: AppConfig.appColor,
                                  shape: BoxShape.circle
                              ),
                              child: Center(
                                child: Icon(
                                  icon,
                                  size: 18,
                                  color: white_color,
                                ),
                              ),
                            ),
                            addSpace(5),
                            Text(
                              "15 $title",
                              style: textStyle(false, 13, black),
                            ),
                          ],
                        ),
                      );
                    })),
              ),
            ],
          ),
        ),
        if(isLoggedIn)Container(
          color: black.withOpacity(.05),
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.only(top: 10, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //fieldItem(Icons.home, brown, "Delivery Address", () {}),
              fieldItem(Icons.person, green, "Edit Profile", () {
                pushAndResult(
                    context,
                    EditProfile(
                      modeEdit: true,
                    ),
                    depend: false);
              }),
              fieldItem(Icons.headset_mic, blue1, "Support", () {}),
              fieldItem(Icons.help, black.withOpacity(.5), "Help", () {}),
            ],
          ),
        ),
        Container(
          color: black.withOpacity(.05),
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.only(top: 0, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              fieldItem(
                  Icons.notifications_active, blue1, "Notifications", () {}),
              fieldItem(
                  Icons.lock, black.withOpacity(.5), "Privacy Policy", () {}),
              fieldItem(Icons.person, blue, "Tell a friend", () {}),
            ],
          ),
        ),
        if(isLoggedIn)Container(
          color: black.withOpacity(.05),
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.only(top: 0, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              fieldItem(Icons.exit_to_app, red, "Logout", () {}),
            ],
          ),
        ),
        addSpace(100)
      ],
    );
  }

  fieldItem(icon, color, title, onPressed) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            //height: 40,
            decoration: BoxDecoration(
                border: Border.all(color: white.withOpacity(.02))),
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      //borderRadius: BorderRadius.circular(8)
                    ),
                    child: Icon(
                      icon,
                      color: white_color,
                      size: 18,
                    )),
                addSpaceWidth(10),
                Text(
                  title,
                  style: textStyle(false, 16, black),
                ),
              ],
            ),
          ),
        ),
        //addLine(0.09, black, 0, 10, 0, 10),
      ],
    );
  }

  void pickAssets(String s) async {
//    final photos = s == "normal" ? profilePhotos : hookUpPhotos;
    PhotoPicker.pickAsset(
            context: context, provider: I18nProvider.english, rowCount: 3)
        .then((value) async {
      if (value == null) return;
      for (var a in value) {
        String path = (await a.originFile).path;
        bool isVideo = a.type == AssetType.video;
        BaseModel model = BaseModel();
        model.put(OBJECT_ID, a.id);
        model.put(IMAGE_URL, path);
        model.put(IS_VIDEO, isVideo);
        if (isVideo) {
          model.put(THUMBNAIL_URL,
              (await VideoCompress().getThumbnailWithFile(path)).path);
        }
//        int p = photos.indexWhere((e) => e.getObjectId() == a.id);
//        if (p != -1) {
//          photos[p] = model;
//        } else {
//          photos.add(model);
//        }
//        uploadPhotos(model, s, a.id);
      }

      setState(() {});
    }).catchError((e) {});

    /// Use assetList to do something.
  }
}
