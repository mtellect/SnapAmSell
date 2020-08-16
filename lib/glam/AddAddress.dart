import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/assets.dart';

class AddAddress extends StatefulWidget {
  @override
  _AddAddressState createState() => _AddAddressState();
}

class _AddAddressState extends State<AddAddress> {
  final vp = PageController();
  int currentPage = 0;

  final addressName = TextEditingController();
  final addressStreet0 = TextEditingController();
  final addressStreet1 = TextEditingController();
  final addressState = TextEditingController();
  final mobileNumber = TextEditingController();
  bool defaultAddress = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(top: 30, right: 10, left: 10, bottom: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BackButton(),
                Container(
                  margin: EdgeInsets.only(left: 15),
                  child: Text(
                    "New Address",
                    style: textStyle(true, 25, black),
                  ),
                )
              ],
            ),
          ),
          addressPage(),
          Container(
            padding: EdgeInsets.all(20),
            child: FlatButton(
              onPressed: () {},
              color: black,
              padding: EdgeInsets.all(15),
              child: Center(
                  child: Text(
                "SAVE",
                style: textStyle(false, 18, white),
              )),
            ),
          )
        ],
      ),
    );
  }

  addressPage() {
    return Flexible(
      child: Container(
        child: ListView(
          padding: EdgeInsets.all(10),
          children: [
            inputTextView("Name Address", addressName, isNum: false),
            inputTextView("Street Address1", addressStreet0, isNum: false),
            inputTextView("Street Address2", addressStreet1, isNum: false),
            inputTextView("Address State", addressState, isNum: false),
            inputTextView("Phone Number", addressName, isNum: false),
            addSpace(10),
            GestureDetector(
              onTap: () {
                setState(() {
                  defaultAddress = !defaultAddress;
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 25,
                    width: 25,
                    alignment: Alignment.center,
                    child: Icon(
                      LineIcons.check,
                      size: 15,
                      color: black.withOpacity(defaultAddress ? 1 : 0.3),
                    ),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color:
                                black.withOpacity(defaultAddress ? 1 : 0.3))),
                  ),
                  addSpaceWidth(10),
                  Text(
                    "Set as Default",
                    style: textStyle(defaultAddress, 16,
                        black.withOpacity(defaultAddress ? 1 : .6)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
