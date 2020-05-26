

import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'AppEngine.dart';
import 'assets.dart';
import 'basemodel.dart';

class StoryText extends StatefulWidget {
   @override
   _StoryTextState createState() => _StoryTextState();
 }

 class _StoryTextState extends State<StoryText> {

   List colorKeys=[BLUE,GREEN,RED,BROWN,DARK_GREEN,DARK_BLUE,ORANGE];
   int currentColor = 0;
   TextEditingController messageController = TextEditingController();
   bool showEmoji = false;
   FocusNode messageNode = FocusNode();

   getBackColor(){
     return getColorForKey(colorKeys[currentColor]);
   }

   @override
   Widget build(BuildContext context) {
     return Scaffold(backgroundColor: getBackColor(),
         body: Stack(
           children: <Widget>[
             page(),
             if(messageController.text.isNotEmpty)Align(alignment: Alignment.bottomCenter,
             child: Container(
               margin: EdgeInsets.only(bottom: showEmoji?270:60),
               child: FloatingActionButton(onPressed: (){
                 clickShare();
               },heroTag: "p34",clipBehavior: Clip.antiAlias,backgroundColor: blue3,
                 shape: CircleBorder(),
                 child: Icon(Icons.send,color: white,),
               ),
             ),)
           ],
         ));
   }

   page(){
     return Column(
       children: <Widget>[
       Expanded(child: Center(
         child: SingleChildScrollView(
           child: TextField(
             textCapitalization: TextCapitalization.sentences,
             decoration: InputDecoration(
                 hintText: "Type a status",
                 hintStyle: textStyle(
                     true, 40, white.withOpacity(.3),),contentPadding: EdgeInsets.fromLTRB(20,40,20,20),
                 border: InputBorder.none),
             style: textStyle(true, 40, white),textAlign: TextAlign.center,
             controller: messageController,
             cursorColor: white,
             cursorWidth: 2,onChanged: (_){
               setState(() {

               });
           },
             maxLines: null,focusNode: messageNode,
             keyboardType: TextInputType.multiline,
             scrollPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
           ),
         ),
       )),
         Row(
           mainAxisSize: MainAxisSize.min,
           children: <Widget>[
             GestureDetector(
               onTap: (){
                 setState(() {
                   showEmoji = !showEmoji;
                   if (showEmoji) {
                     FocusScope.of(context)
                         .requestFocus(FocusNode());
                   } else {
                     FocusScope.of(context)
                         .requestFocus(messageNode);
                   }
                 });
               },
               child: Container(
                   width: 50,height: 50,color: transparent,
                   child: Center(child: Icon(showEmoji
                       ? Icons.keyboard
                       : Icons.insert_emoticon,color: white,))),
             ),
             GestureDetector(
               onTap: (){
                 setState(() {
                   currentColor = currentColor+1;
                   currentColor = currentColor==colorKeys.length?0:currentColor;
                 });
               },
               child: Container(
                   width: 50,height: 50,color: transparent,
                   child: Center(child: Icon(Icons.color_lens,color: white,))),
             ),

           ],
         ),
         if(showEmoji)EmojiPicker(
           onEmojiSelected: (emoji, category) {
             String text = messageController.text;
             StringBuffer sb = StringBuffer();
             sb.write(text);
             sb.write(emoji.emoji);
             messageController.text = sb.toString();
             setState(() {});
           },
           //recommendKeywords: ["happy", "love"],
         )
       ],
     );
   }
   clickShare(){
     BaseModel model = BaseModel();

     model.put(OBJECT_ID, getRandomId());
     model.put(DATABASE_NAME, STORY_BASE);
     model.put(COLOR_KEY, colorKeys[currentColor]);
     model.put(STORY_TEXT, messageController.text.trim());
     Navigator.pop(context, model);
   }
 }
