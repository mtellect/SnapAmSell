import 'package:flutter/material.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/assets.dart';
import 'package:virtual_keyboard/virtual_keyboard.dart';

import 'AppConfig.dart';

class ChatOfferDialog extends StatefulWidget {
  final double prevPrice;
  final String description;
  const ChatOfferDialog(this.prevPrice, this.description);
  @override
  _ChatOfferDialogState createState() => _ChatOfferDialogState();
}

class _ChatOfferDialogState extends State<ChatOfferDialog> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: transparent,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              color: black.withOpacity(.4),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  )),
              //padding: EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      padding: EdgeInsets.all(15),
                      child:
                          Text("\$$text", style: textStyle(true, 40, black))),
                  Container(
                    //color: Colors.deepPurple,
                    child: VirtualKeyboard(
                        height: 300,
                        textColor: black.withOpacity(.8),
                        type: VirtualKeyboardType.Numeric,
                        onKeyPress: _onKeyPress),
                  ),
                  if (widget.prevPrice > 0)
                    Container(
                        padding: EdgeInsets.all(15),
                        alignment: Alignment.center,
                        color: black.withOpacity(.02),
                        child: Text.rich(
                          TextSpan(children: [
                            TextSpan(
                              text: "${widget.description}",
                              style:
                                  textStyle(false, 16, black.withOpacity(0.6)),
                            ),
                            TextSpan(
                              text: "\$${widget.prevPrice}",
                              style: textStyle(true, 20, black),
                            )
                          ]),
                        )),
                  Container(
                    padding: EdgeInsets.all(15),
                    child: Row(
                      children: [
                        FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          color: white,
                          padding: EdgeInsets.all(20),
                          shape: CircleBorder(
                              //borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: black.withOpacity(.7))),
                          child: Icon(
                            Icons.close,
                            //color: AppConfig.appColor,
                          ),
                        ),
                        addSpaceWidth(10),
                        Flexible(
                          child: FlatButton(
                            onPressed: () {
                              sendOffer();
                            },
                            color: AppConfig.appColor,
                            padding: EdgeInsets.all(20),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: white)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  ic_offer,
                                  height: 22,
                                  width: 22,
                                  color: white,
                                ),
                                addSpaceWidth(10),
                                Text(
                                  "SEND OFFER",
                                  style: textStyle(true, 18, white),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  addSpace(20)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  String text = '';

  /// Fired when the virtual keyboard key is pressed.
  _onKeyPress(VirtualKeyboardKey key) {
    if (key.keyType == VirtualKeyboardKeyType.String) {
      text = text + (/*shiftEnabled ? key.capsText :*/ key.text);
    } else if (key.keyType == VirtualKeyboardKeyType.Action) {
      switch (key.action) {
        case VirtualKeyboardKeyAction.Backspace:
          if (text.length == 0) return;
          text = text.substring(0, text.length - 1);
          break;
        case VirtualKeyboardKeyAction.Return:
          text = text + '\n';
          break;
        case VirtualKeyboardKeyAction.Space:
          text = text + key.text;
          break;
        /* case VirtualKeyboardKeyAction.Shift:
          shiftEnabled = !shiftEnabled;
          break;*/
        default:
      }
    }
    // Update the screen
    setState(() {});
  }

  void sendOffer() {
    Navigator.pop(context, text);
  }
}
