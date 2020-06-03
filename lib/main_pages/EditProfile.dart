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
      backgroundColor: white,
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
                color: black,
              ),
              Text(
                "${widget.modeEdit ? "Edit" : "Create"} Profile",
                style: textStyle(true, 25, black),
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

                      color: black.withOpacity(.05),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person,
                          size: 100,
                          color: black.withOpacity(.3),
                        ),
                        Text(
                          "Add Image",
                          style: textStyle(false, 16, black),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              color: black.withOpacity(.05),
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.only(top: 10, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Account Information",
                    style: textStyle(false, 16, black),
                  ),
                  addSpace(10),
                  textField(fullName, "First Name",),
                  addSpace(10),
                  textField(userName, "UserName")
                ],
              ),
            ),
            Container(
              color: black.withOpacity(.05),
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.only(top: 10, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Contact Information",
                    style: textStyle(false, 16, black),
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
                side: BorderSide(color: black.withOpacity(.3))),
            child: Center(
              child: Text(
                "SAVE",
                style: textStyle(true, 16, black),
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
          border: Border.all(color: black.withOpacity(.05))),
      child: TextField(
        controller: controller,
        maxLines: max,
        decoration: InputDecoration(
            labelText: hint,labelStyle: textStyle(true,12,black),
            border: InputBorder.none,
            fillColor: black.withOpacity(.05),
            filled: true),
      ),
    );
  }
}
