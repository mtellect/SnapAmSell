import 'package:awesome_card/awesome_card.dart' as card;
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:line_icons/line_icons.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/assets.dart';

class AddCard extends StatefulWidget {
  @override
  _AddCardState createState() => _AddCardState();
}

class _AddCardState extends State<AddCard> {
  String cardNumber = "";
  String cardHolderName = "";
  String expiryDate = "";
  String cvv = "";
  bool showBack = false;
  FocusNode _focusNode;

  final nameController = TextEditingController();
  final cvvController = TextEditingController();

  final numberController =
      new MaskedTextController(mask: '0000 **** **** 0000');

  final expiryController =
      new MaskedTextController(mask: '00/00 **** **** 0000');

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool defaultAddress = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _focusNode = new FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _focusNode.hasFocus ? showBack = true : showBack = false;
      });
    });
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
                    "New Card",
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
          padding: EdgeInsets.all(0),
          children: [
            card.CreditCard(
              cardNumber: cardNumber,
              cardExpiry: expiryDate,
              cardHolderName: cardHolderName,
              cvv: cvv,
              bankName: "",
              showBackSide: showBack,
              frontBackground: card.CardBackgrounds.black,
              backBackground: card.CardBackgrounds.white,
              showShadow: true,
            ),
            addSpace(30),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: black.withOpacity(0.04)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  textFieldBox(nameController, "Card Holder", (v) {
                    setState(() {
                      cardHolderName = v;
                    });
                  }),
                  textFieldBox(numberController, "Card Number", (v) {
                    setState(() {
                      cardNumber = v;
                    });
                  }, number: true),
                  Row(
                    children: [
                      Flexible(
                        child: textFieldBox(expiryController, "Expire", (v) {
                          setState(() {
                            expiryDate = v;
                          });
                        }, number: true),
                      ),
                      Flexible(
                        child: textFieldBox(cvvController, "CVV", (v) {
                          setState(() {
                            cvv = v;
                          });
//                                StripeService.doConversion(widget.amount)
//                                    .then((value) {
//                                  payText =
//                                      "PAY " +
//                                      value.getString(AMOUNT_TO_PAY);
//                                  if (mounted) setState(() {});
//                                });
                        }, focusNode: _focusNode, maxLength: 3, number: true),
                      )
                    ],
                  ),
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
                                  width: defaultAddress ? 1.5 : 1,
                                  color: black
                                      .withOpacity(defaultAddress ? 1 : 0.3))),
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
          ],
        ),
      ),
    );
  }

  textFieldBox(
      TextEditingController controller, String hint, setstate(String v),
      {focusNode, int maxLength, bool number = false}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: TextFormField(
        focusNode: focusNode,
        maxLength: maxLength,
        //maxLengthEnforced: false,
        controller: controller,
        cursorColor: black,
        decoration: InputDecoration(hintText: hint, counter: Container()),
        onChanged: setstate,
        keyboardType: number ? TextInputType.number : null,
      ),
    );
  }
}
