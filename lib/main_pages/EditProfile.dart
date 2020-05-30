import 'package:Strokes/AppEngine.dart';
import 'package:Strokes/MainAdmin.dart';
import 'package:Strokes/app_config.dart';
import 'package:Strokes/assets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class EditProfile extends StatefulWidget {
  final bool modeEdit;

  const EditProfile({Key key, this.modeEdit = false}) : super(key: key);
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final fullName = TextEditingController();
  final userName = TextEditingController();
  final phoneNumber = TextEditingController();
  final emailNumber = TextEditingController();
  String selectedGender;
  String contactAddress;
  double addressLat = 0.0;
  double addressLong = 0.0;
  String profilePhoto;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

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
        Container(
          padding: EdgeInsets.only(top: 35, right: 10, left: 10, bottom: 10),
          child: Row(
            children: [
              BackButton(
                color: white,
              ),
              Text(
                "${widget.modeEdit ? "Edit" : "Create"} Profile",
                style: textStyle(true, 25, white),
              ),
              Spacer(),
            ],
          ),
        ),
        Flexible(
            child: ListView(
          padding: EdgeInsets.all(0),
          children: [
            Container(
              margin: EdgeInsets.only(top: 10, bottom: 10),
              child: CachedNetworkImage(
                height: 250,
                width: double.infinity,
                imageUrl: userModel.userImage,
                placeholder: (c, s) {
                  return Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      //shape: BoxShape.circle,

                      color: white.withOpacity(.05),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person,
                          size: 100,
                          color: white.withOpacity(.3),
                        ),
                        Text(
                          "Add Image",
                          style: textStyle(false, 16, white),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              color: white.withOpacity(.05),
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.only(top: 10, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Account Information",
                    style: textStyle(false, 16, white),
                  ),
                  addSpace(10),
                  textField(fullName, "First Name"),
                  addSpace(10),
                  textField(userName, "UserName")
                ],
              ),
            ),
            Container(
              color: white.withOpacity(.05),
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.only(top: 10, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Contact Information",
                    style: textStyle(false, 16, white),
                  ),
                  addSpace(10),
                  textField(fullName, "Residential Address"),
                  addSpace(10),
                  textField(userName, "LandMark Description", max: 4)
                ],
              ),
            ),
          ],
        )),
        Container(
          padding: EdgeInsets.all(15),
          child: FlatButton(
            onPressed: () {},
            color: AppConfig.appColor,
            padding: EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: white.withOpacity(.3))),
            child: Center(
              child: Text(
                "SAVE",
                style: textStyle(true, 16, white),
              ),
            ),
          ),
        )
      ],
    );
  }

  textField(controller, hint, {int max}) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: black.withOpacity(.1))),
      child: TextField(
        controller: controller,
        maxLines: max,
        decoration: InputDecoration(
            labelText: hint,
            border: InputBorder.none,
            fillColor: white.withOpacity(.3),
            filled: true),
      ),
    );
  }
}
