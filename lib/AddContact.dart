import 'dart:async';
import 'dart:ui';

import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/assets.dart';

class AddContact extends StatefulWidget {
  Map item;
  AddContact({this.item});
  @override
  _AddContactState createState() {
    return _AddContactState();
  }
}

class _AddContactState extends State<AddContact> {
  TextEditingController nameController = new TextEditingController();
  TextEditingController phoneController = new TextEditingController();
  TextEditingController whatController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  FocusNode focusName = FocusNode();
  FocusNode focusPhone = FocusNode();
  FocusNode focusEmail = FocusNode();
  FocusNode focusWhat = FocusNode();

  String phonePref = "234";
  String whatsPref = "234";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    focusName.addListener(() {
      setState(() {});
    });
    focusPhone.addListener(() {
      setState(() {});
    });
    focusEmail.addListener(() {
      setState(() {});
    });
    focusWhat.addListener(() {
      setState(() {});
    });

    if (widget.item != null) {
      String name = widget.item[NAME] ?? "";
      String phone = widget.item[PHONE_NUMBER] ?? "";
      phonePref = widget.item[PHONE_PREF] ?? "";
      String whats = widget.item[WHATSAPP_NUMBER] ?? "";
      whatsPref = widget.item[WHATSAPP_PREF] ?? "";
      String email = widget.item[EMAIL] ?? "";

      nameController.text = name;
      phoneController.text = phone;
      whatController.text = whats;
      emailController.text = email;
    } else {
      loadPrefs();
    }
  }

  loadPrefs() async {
    Country country = CountryPickerUtils.getCountryByName(defaultCountry);
    phonePref = country.phoneCode;
    whatsPref = country.phoneCode;
    setState(() {});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext cc) {
    return Scaffold(
        backgroundColor: white,
        key: _scaffoldKey,
        resizeToAvoidBottomInset: true,
        body: page());
  }

  page() {
    return Stack(
      fit: StackFit.expand,
      children: [
//        Image.asset(farm,fit: BoxFit.cover,),
//        BackdropFilter(
//            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
//            child: Containit: BoxFit.cover,),
//        BackdropFilter(
//            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
//            child: Container(color: white.withOpacity(.8),)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  margin: EdgeInsets.only(top: 40),
                  width: 50,
                  height: 50,
                  child: Center(
                      child: Icon(
                    Icons.cancel,
                    color: black.withOpacity(.2),
                    size: 35,
                  )),
                )),
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
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Container(
//                    color: black,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        addSpace(30),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.perm_contact_calendar,
                              size: 30,
                            ),
                            addSpaceWidth(10),
                            Text(
                              "Contact Person",
                              style: textStyle(true, 30, black),
                            )
                          ],
                        ),
                        addSpace(20),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: new TextField(
                            controller: nameController,
//                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            focusNode: focusName,
                            decoration: InputDecoration(
                              isDense: true,
                              prefixIcon: Icon(Icons.person,
                                  size: 22,
                                  color: focusName.hasFocus
                                      ? black
                                      : black.withOpacity(.5)),
                              labelStyle: textStyle(
                                false,
                                22,
                                black.withOpacity(.35),
                              ),
                              labelText: "Name",
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide:
                                      BorderSide(color: black, width: 2)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(
                                      color: black.withOpacity(.5), width: 1)),
                            ),
                            style: textStyle(
                              false,
                              22,
                              black,
                            ),
                            cursorColor: black,
                            cursorWidth: 1,
                            maxLines: 1,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: new TextField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                            focusNode: focusPhone,
                            decoration: InputDecoration(
                              isDense: true,
                              prefixIconConstraints:
                                  BoxConstraints(maxHeight: 40),
                              prefixIcon: GestureDetector(
                                onTap: () {
                                  pickCountry(context, (_) {
                                    phonePref = _.phoneCode;
                                    setState(() {});
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.only(left: 15, right: 10),
                                  padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                  decoration: BoxDecoration(
                                      color: focusPhone.hasFocus
                                          ? black
                                          : black.withOpacity(.4),
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Text(
                                    "+$phonePref",
                                    style: textStyle(true, 15, white),
                                  ),
                                ),
                              ),
                              labelStyle: textStyle(
                                false,
                                22,
                                black.withOpacity(.35),
                              ),
                              labelText: "Phone Number",
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide:
                                      BorderSide(color: black, width: 2)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(
                                      color: black.withOpacity(.5), width: 1)),
                            ),
                            style: textStyle(
                              false,
                              22,
                              black,
                            ),
                            cursorColor: black,
                            cursorWidth: 1,
                            maxLines: 1,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: new TextField(
                            controller: whatController,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                            focusNode: focusWhat,
                            decoration: InputDecoration(
                              isDense: true,
                              prefixIconConstraints:
                                  BoxConstraints(maxHeight: 40),
                              prefixIcon: GestureDetector(
                                onTap: () {
                                  pickCountry(context, (_) {
                                    whatsPref = _.phoneCode;
                                    setState(() {});
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.only(left: 15, right: 10),
                                  padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                  decoration: BoxDecoration(
                                      color: focusWhat.hasFocus
                                          ? black
                                          : black.withOpacity(.4),
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Text(
                                    "+$whatsPref",
                                    style: textStyle(true, 15, white),
                                  ),
                                ),
                              ),
                              labelStyle: textStyle(
                                false,
                                22,
                                black.withOpacity(.35),
                              ),
                              labelText:
                                  "Whatsapp ${focusWhat.hasFocus ? "Number" : "(Optional)"}",
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide:
                                      BorderSide(color: black, width: 2)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(
                                      color: black.withOpacity(.5), width: 1)),
                            ),
                            style: textStyle(
                              false,
                              22,
                              black,
                            ),
                            cursorColor: black,
                            cursorWidth: 1,
                            maxLines: 1,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: new TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            focusNode: focusEmail,
                            decoration: InputDecoration(
                              isDense: true,
                              prefixIcon: Icon(Icons.email,
                                  color: focusEmail.hasFocus
                                      ? black
                                      : black.withOpacity(.5)),
                              labelStyle: textStyle(
                                false,
                                22,
                                black.withOpacity(.35),
                              ),
                              labelText:
                                  "Email ${focusEmail.hasFocus ? "Number" : "(Optional)"}",
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide:
                                      BorderSide(color: black, width: 2)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(
                                      color: black.withOpacity(.5), width: 1)),
                            ),
                            style: textStyle(
                              false,
                              22,
                              black,
                            ),
                            cursorColor: black,
                            cursorWidth: 1,
                            maxLines: 1,
                          ),
                        ),
                        addSpace(20),
                        Container(
                          height: 60,
                          width: double.infinity,
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: RaisedButton(
                            elevation: 5,
                            onPressed: () {
                              addPerson();
                            },
                            color: orange0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              // side: BorderSide(color: blue3,width: 2)
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                            child: Text(
                              "Add",
                              style: textStyle(true, 25, white),
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void addPerson() async {
    String name = nameController.text.trim();
    String phone = phoneController.text.trim();
    String email = emailController.text.trim();
    String what = whatController.text.trim();

    if (name.isEmpty) {
      showError("Enter Name");
      return;
    }
    if (phone.isEmpty) {
      showError("Enter Phone Number");
      return;
    }

    /* if(phone.isNotEmpty) {
      phone = phone.startsWith("0") ? phone.substring(1) : phone;
      phone = "+$phonePref$phone";
    }
    if(what.isNotEmpty){
      what = what.startsWith("0")?what.substring(1):what;
      what = "+$whatsPref$what";
    }*/

    Map item = {
      NAME: name,
      PHONE_NUMBER: phone,
      PHONE_PREF: phonePref,
      EMAIL: email,
      WHATSAPP_NUMBER: what,
      WHATSAPP_PREF: whatsPref,
    };

    print(item);
    Navigator.pop(context, item);
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  String errorText = "";
  showError(String text) {
    errorText = text;
    setState(() {});
    Future.delayed(Duration(seconds: 2), () {
      errorText = "";
      setState(() {});
    });
  }
}
