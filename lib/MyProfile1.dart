
//  import 'dart:io';
// import 'dart:math';
// import 'dart:ui';

//  import 'package:Strokes/PaymentTest.dart';
// import 'package:Strokes/CurrencyMain.dart';
// import 'package:Strokes/EditProfile.dart';

// import 'package:Strokes/Settings.dart';
// import 'package:Strokes/ShowViewedMyProfile.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:image_cropper/image_cropper.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:timeago/timeago.dart' as timeAgo;
// import 'package:Strokes/assets.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';

// import 'AppEngine.dart';
// import 'PriceMain.dart';
// import 'basemodel.dart';
// import 'dialogs/inputDialog.dart';
// import 'dialogs/listDialog.dart';
//  import 'ShowPeople.dart';

// class MyProfile1 extends StatefulWidget {
//   BaseModel personModel;
//   bool fromChat;
//   MyProfile1(this.personModel,{this.fromChat=false});
//    @override
//    _MyProfile1State createState() => _MyProfile1State();
//  }

//  class _MyProfile1State extends State<MyProfile1> {

//    BaseModel personModel;
//    bool myProfile=false;
//    bool fromChat;
//    List viewedIds =[];
//    int chatCost = 10;
//    bool paidChat = true;
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     personModel = widget.personModel;
//     if(personModel.myItem()){
//       personModel=userModel;
//       myProfile=true;
//     }
//     fromChat = widget.fromChat;
// //    checkLove();
//     if(myProfile)loadViews();
//   }

//    loadViews()async{
//      QuerySnapshot shots = await Firestore.instance.collection(USER_BASE)
//          .where(VIEWS_IDS,arrayContains: userModel.getObjectId()).limit(12)
//          .getDocuments();
//      List people = [];
//      for(DocumentSnapshot doc in shots.documents){
//        BaseModel bm = BaseModel(doc:doc);
//        String id = bm.getObjectId();
//        if(isBlocked(null,userId: id))continue;
//        if (appSettingsModel.getList(DISABLED).contains(id)) continue;
//        if(appSettingsModel.getList(BANNED).contains(id))continue;
// //       if(!viewedIds.contains(bm.getObjectId()))viewedIds.add(bm.getObjectId());
//        people.add(bm);
//      }
//      people.sort((bm1,bm2)=>bm2.getInt(TIME_UPDATED).compareTo(bm1.getInt(TIME_UPDATED)));
//      for(BaseModel bm in people){
//        viewedIds.add(bm.getObjectId());
//      }
//      if(mounted)setState(() {

//      });
//    }

//    @override
//    Widget build(BuildContext context) {
//      return WillPopScope(
//        onWillPop: (){
//          Navigator.pop(context,true);
//          return;
//        },
//        child: Scaffold(
//          backgroundColor: fromChat?transparent:white,
//          body: page(),
//        ),
//      );
//    }

//    page(){
//      chatCost = appSettingsModel.getInt(CHAT_COST);
//      chatCost = chatCost==0?10:chatCost;
//      paidChat = !personModel.getList(LOVE_IDS).contains(userModel.getObjectId())
//          && !userModel.getList(PAID_CHATS).contains(personModel.getObjectId());

//      List foodList = personModel.getList(FOOD_LIST);
//      String image = personModel.getString(USER_IMAGE);
//      double currentDrive = personModel.getDouble(SEX_DRIVE);
//      bool canCook = personModel.getBoolean(CAN_COOK);
//      bool canSex = personModel.getBoolean(CAN_SEX);

//      String moreInfo = appSettingsModel.getString(MORE_INFO);
//      List moreItems = [];
//      if(moreInfo.isNotEmpty){
//        moreItems = convertStringToList(",", moreInfo);
//      }
//      List images = personModel.getList(IMAGES);
//      List allImages = [];
//      allImages.add(personModel.getString(USER_IMAGE));
//      allImages.addAll(images);
//      return Stack(
//        fit: StackFit.expand,
//        children: <Widget>[
//         if(!fromChat) CachedNetworkImage(imageUrl: image,fit: BoxFit.cover,height: MediaQuery.of(context).size.height,),
//          BackdropFilter(
//              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
//              child: Container(color: black.withOpacity(.6),)),

//          Column(
//            children: <Widget>[
//              addSpace(80),
//              Expanded(flex: 1,
//                child: Center(
//                  child: SingleChildScrollView(
//                    padding: EdgeInsets.all(0),
//                    child: Column(
//                      crossAxisAlignment: CrossAxisAlignment.center,
//                      children: <Widget>[
// //                       addSpace(70),
//                        Center(
//                          child: SingleChildScrollView(
//                            padding: EdgeInsets.all(0),
//                            scrollDirection: Axis.horizontal,
//                            child: Row(
//                              crossAxisAlignment: CrossAxisAlignment.end,
//                              mainAxisSize: MainAxisSize.min,
//                              children: <Widget>[
//                                GestureDetector(
//                                  onTap: (){
//                                    pushAndResult(context, ViewImage(allImages, 0));
//                                  },
//                                  child: Container(
//                                    margin: EdgeInsets.fromLTRB(5,10,5,0),
//                                    width: MediaQuery.of(context).size.width/3,
//                                    height: MediaQuery.of(context).size.width/2,
//                                    child: Card(
//                                      color: default_white,elevation: 0,clipBehavior: Clip.antiAlias,
//                                      shape: RoundedRectangleBorder(
//                                          borderRadius: BorderRadius.all(Radius.circular(10)),
//                                          side: BorderSide(color: black.withOpacity(.1),width: .5)
//                                      ),
//                                      child: CachedNetworkImage(imageUrl: personModel.getString(USER_IMAGE),fit: BoxFit.cover,),
//                                    ),
//                                  ),
//                                ),
//                                Row(mainAxisSize: MainAxisSize.min,
//                                  children: List.generate(images.length, (p){

//                                    return GestureDetector(
//                                      onTap: (){
//                                        pushAndResult(context, ViewImage(allImages, p+1));
//                                      },
//                                      child: Container(
//                                        margin: EdgeInsets.fromLTRB(0,0,5,0),
//                                        width: 50,
//                                        height: 70,color: transparent,
//                                        child: Card(
//                                          color: default_white,elevation: 0,clipBehavior: Clip.antiAlias,
//                                          shape: RoundedRectangleBorder(
//                                              borderRadius: BorderRadius.all(Radius.circular(10)),
//                                              side: BorderSide(color: black.withOpacity(.1),width: .5)
//                                          ),
//                                          child: CachedNetworkImage(imageUrl: images[p],fit: BoxFit.cover,),
//                                        ),
//                                      ),
//                                    );
//                                  }),
//                                ),
//                              ],
//                            ),
//                          ),
//                        ),
//                        addSpace(10),
//                        if(myProfile && viewedIds.isNotEmpty)GestureDetector(
//                          onTap: (){
//                            pushAndResult(
//                                context,
//                                ShowViewedMyProfile(),opaque: false,result: (_){

//                            });
//                          },
//                          child: Container(
//                            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
//                            margin: EdgeInsets.fromLTRB(10, 0, 10, 5),
//                            decoration: BoxDecoration(color: black,borderRadius: BorderRadius.all(Radius.circular(25))),
//                            child: Row(
//                              mainAxisSize: MainAxisSize.min,
//                              children: <Widget>[
//                                Icon(Icons.remove_red_eye,color: white,size: 15,),
//                                addSpaceWidth(5),
//                                Text("${viewedIds.length>10?"10+":viewedIds.length} Profile View${viewedIds.length==1?"":"s"}",style: textStyle(true, 14, white),)
//                              ],
//                            ),
//                          ),
//                        ),
//                        if(myProfile)GestureDetector(
//                          onTap: (){
//                            pushAndResult(context, PaymentTest(),result: (_){
//                              setState(() {

//                              });
//                            });
//                          },
//                          onLongPress: (){
//                            if(!isAdmin)return;

//                            pushAndResult(
//                                context,
//                                listDialog(
//                                    ["Set Prices","Set Currency","My Credit","Send Credits"]),
//                                result: (_) {
//                                  if (_ == "Send Credits") {
//                                    pushAndResult(
//                                        context, inputDialog("Email, Credits", hint: "Email, Credits"),
//                                        result: (_) async {
//                                          if (!_.contains(",")) {
//                                            toastInAndroid("Invalid");
//                                            return;
//                                          }
//                                          if (userModel.getString(EMAIL) != "johnebere58@gmail.com") {
//                                            toastInAndroid("Only John can perform this command");
//                                            return;
//                                          }
//                                          String email = _.split(",")[0].trim().toLowerCase();
//                                          int credits = int.parse(_.split(",")[1].trim());

//                                          showMessage(
//                                              context,
//                                              ic_coin,
//                                              blue0,
//                                              "Send ${formatPrice(credits.toString())} Credit?",
//                                              "to $email", onClicked: (_) async {
//                                            if (_ == true) {
//                                              String id = getRandomId();
//                                              Firestore.instance
//                                                  .collection(USER_BASE)
//                                                  .where(EMAIL, isEqualTo: email)
//                                                  .getDocuments(source: Source.server)
//                                                  .then((shots) {
//                                                for (DocumentSnapshot shot in shots.documents) {
//                                                  BaseModel model = BaseModel(doc: shot);
//                                                  hmcr(model, id, credits, true, false);
//                                                  toastInAndroid("Creditting User...");
//                                                  break;
//                                                }
//                                              }).catchError((e) {
//                                                showMessage(
//                                                    context, Icons.error, red0, "Error occurred", e.toString());
//                                              });
//                                            }
//                                          });
//                                        });
//                                  }
//                                  if(_=="Set Currency"){
//                                    pushAndResult(context, CurrencyMain());
//                                  }
//                                  if (_ == "Set Prices") {
//                                    pushAndResult(context, PriceMain(false));
//                                  }

//                                  if (_ == "My Credit") {
//                                    pushAndResult(
//                                        context,
//                                        inputDialog(
//                                          "My Credit",
//                                          hint: "Enter Amount",
//                                          inputType: TextInputType.number,
//                                        ), result: (_) {
//                                      int amt = int.parse(_.trim());
//                                      userModel.put(MCR, amt);
//                                      userModel.updateItems();
//                                      setState(() {});
//                                    });
//                                  }
//                                });
//                          },
//                          child: Container(
//                            padding: EdgeInsets.fromLTRB(10, 3, 10, 3),
//                            margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
//                            decoration: BoxDecoration(
//                                border: Border.all(color: gold,width: 1),borderRadius: BorderRadius.all(Radius.circular(25))
//                            ),
//                            child: Row(mainAxisSize: MainAxisSize.min,
//                              children: <Widget>[
//                                Image.asset(ic_coin,width: 15,height: 20,color:Colors.amber),
//                                addSpaceWidth(5),
//                                Text("${userModel.getInt(MCR)} Coins",style: textStyle(true, 14, gold),),
//                              ],
//                            ),
//                          ),
//                        ),
//                        Text(getFullName(personModel),style: textStyle(false, 30, white),textAlign: TextAlign.center,),
//                        if(!myProfile)Text(
//                            "${!isAdmin?"":"Joined ~ ${timeAgo.format(
//                              DateTime.fromMillisecondsSinceEpoch(
//                                  personModel.getInt(TIME)),
//                            )} | "}Last seen ${timeAgo.format(
//                                DateTime.fromMillisecondsSinceEpoch(
//                                    personModel.getInt(TIME_UPDATED)))}",
//                            style: textStyle(
//                                false, 12, white.withOpacity(.3))),

//                        Container(
//                          margin: EdgeInsets.all(15),
//                          padding: EdgeInsets.all(10),
//                          decoration: BoxDecoration(color: black.withOpacity(.7),
//                              border: Border.all(color: white.withOpacity(.2),width: 1),
//                              borderRadius: BorderRadius.all(Radius.circular(10))),
//                          child: Column(
//                            children: <Widget>[
//                              Text("My Ideal ${personModel.isMale()?"Wife":"Husband"}",style: textStyle(true, 12, white.withOpacity(.5)),textAlign: TextAlign.center,),
//                              addSpace(8),
//                              Text(personModel.getString(IDEAL),style: textStyle(false, 16, white),textAlign: TextAlign.center,),
//                              addSpace(8),
//                            ],
//                          ),
//                        ),

//                        if(canCook)Container(
//                          margin: EdgeInsets.only(bottom: 15,left: 10,right: 10),
//                          child: Row(mainAxisSize: MainAxisSize.min,
//                            children: <Widget>[
//                              Container(
//                                  width: 14,height: 14,
//                                  decoration: BoxDecoration(color: white.withOpacity(.7),shape: BoxShape.circle)
//                                  ,child: Icon(!canCook?(Icons.close):Icons.check,color: black.withOpacity(.5),size: 12,)),
//                              addSpaceWidth(5),
//                              Text("Cooking",style: textStyle(true, 14, white.withOpacity(.7)),),
//                              addSpaceWidth(10),
//                              Flexible(child: SingleChildScrollView(scrollDirection: Axis.horizontal,padding: EdgeInsets.all(0),
//                                child: Row(mainAxisSize: MainAxisSize.min,
//                                  children: List.generate(foodList.length, (p){
//                                    return Container(
//                                      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
//                                      margin: EdgeInsets.only(right: 5),
//                                      decoration: BoxDecoration(color: black.withOpacity(.3),borderRadius: BorderRadius.all(Radius.circular(10))),
//                                      child: Text(foodList[p],style: textStyle(true, 12, white),),
//                                    );
//                                  }),),
//                              ))
//                            ],),
//                        ),
//                        if(canSex)Row(mainAxisSize: MainAxisSize.min,
//                          children: <Widget>[
//                            IgnorePointer(
//                              ignoring: true,
//                              child: RatingBar(
//                                initialRating: 3,glow: true,
//                                direction: Axis.horizontal,
//                                allowHalfRating: true,itemSize: 16,
//                                itemCount: 5,
//                                ratingWidget: RatingWidget(
//                                  full: getAssetImage(heart),
//                                  half: getAssetImage(heart_half),
//                                  empty: getAssetImage(heart_border),
//                                ),
//                                itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
//                                onRatingUpdate: (rating) {
//                                },
//                              ),
//                            ),
//                            addSpaceWidth(5),
//                            Text("Sex Drive",style: textStyle(true, 14, white),),
//                          ],),
//                        if(moreItems.isNotEmpty)Container(
//                          margin: EdgeInsets.only(top: 10),
//                          child: Column(
//                            children:List.generate(moreItems.length, (p){
//                              String title = moreItems[p];
//                              String text = personModel.getString(title);
//                              return (text.isEmpty)?Container():nameItem(title, text,color: white,center:true);
//                            }),
//                          ),
//                        ),
//                        addSpace(50),
//                      ],
//                    ),
//                  ),
//                ),
//              ),
// //             addSpace(10),
//              if(myProfile)Container(
//                width: double.infinity,
//                height: 70,
//                margin: EdgeInsets.all(0),
//                child:FlatButton(
//                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                    shape: RoundedRectangleBorder(
//                        borderRadius: BorderRadius.circular(0)),
//                    color: black,
//                    onPressed: () {
//                      pushAndResult(context, EditProfile(),result: (_){
//                        personModel=_;
//                        setState(() {
//                        });
//                      });
//                    },
//                    child: Text(
//                      "Edit Profile",
//                      style: textStyle(true, 20, white),
//                    )),
//              ),
//              if(!myProfile && !fromChat)Container(
//      width: double.infinity,
//      height: 70,
//      margin: EdgeInsets.all(0),
//      child:FlatButton(
//      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//      shape: RoundedRectangleBorder(
//      borderRadius: BorderRadius.circular(0)),
//      color: black,
//      onPressed: () {
//        if(paidChat){
//          if(userModel.getInt(MCR)<chatCost && !isAdmin){
//            showMessage(context, ic_coin, gold, "Insufficient Coins", "You do not have enough coins to start chat",iconPadding: 10,
//            clickNoText: "Cancel",clickYesText: "Buy Coins",onClicked: (_){
//              if(_==true){
//                pushAndResult(context, PaymentTest(),result: (_){
//                  setState(() {

//                  });
//                });
//              }
//                });
//            return;
//          }
//          userModel.putInList(PAID_CHATS, personModel.getObjectId(), true);
//          handleMobileCredits(personModel.getObjectId(), userModel.getObjectId(), chatCost, false);
//          clickChat(context, personModel, false);
//          return;
//        }
// clickChat(context, personModel, false);
//      },
//      child: Column(mainAxisSize: MainAxisSize.min,
//        children: <Widget>[
//          Text(
//          "Start Chat",
//          style: textStyle(true, 20, white),
//          ),
//          if(paidChat)addSpace(3),
//          if(paidChat)Row(mainAxisSize: MainAxisSize.min,
//            children: <Widget>[
//              Image.asset(ic_coin,width: 15,height: 20,color:Colors.amber),
//              addSpaceWidth(5),
//              Text("$chatCost",style: textStyle(false, 14, gold),),
//            ],
//          ),
//        ],
//      )),
//      ),

//            ],
//          ),

//          if(myProfile)Align(alignment: Alignment.topRight,
//          child: InkWell(
//              onTap: () {
//                pushAndResult(context, Settings(),opaque: false);
//              },
//              child: Container(
//                width: 50,
//                height: 50,
//                margin: EdgeInsets.only(top: 30,right: 5),
//                child: Center(
//                    child: Icon(
//                      Icons.settings,
//                      color: white,
//                      size: 25,
//                    )),
//              )),),
//   if(!myProfile)Align(alignment: Alignment.topRight,
//          child: InkWell(
//              onTap: () {
//                showListDialog(context, ["Report","Block"], (int p){
//                  if(p==0){
//                    showListDialog(context, ["Spam","Fake Profile","Others Specify"], (int p){
//                      if(p==0){
//                        createReport(context, personModel, REPORT_TYPE_PROFILE,"Spam");
//                      }
//                      if(p==1){
//                        createReport(context, personModel, REPORT_TYPE_PROFILE,"Fake Profile");
//                      }
//                      if(p==2){
//                        pushAndResult(context, inputDialog("Report",hint: "Write a report",),result: (_){
//                          createReport(context, personModel, REPORT_TYPE_PROFILE, _.trim());
//                        });
//                      }
//                    },title: "Report");
//                  }
//                  if(p==1){
//                    showMessage(context, Icons.block, red0, "Block ${personModel.getString(NAME)}",
//                        "${userModel.isMale()?"He":"She"} won't be able to find your profile or connect with you",clickYesText: "BLOCK",clickNoText: "Cancel",onClicked: (_){
//                         if(_==true){
//                           userModel.putInList(BLOCKED, personModel.getObjectId(), true);
//                           blockedIds.add((personModel.getObjectId()));

//                           String dId = personModel.getString(DEVICE_ID);
//                           if(dId.isNotEmpty)userModel.putInList(BLOCKED, dId, true);
//                           blockedIds.add(dId);

//                           userModel.getObjectId();
//                           showProgress(true, context,msg: "Blocking...");
//                           Future.delayed(Duration(seconds: 2),(){
//                             showProgress(false, context);
//                             showMessage(context, Icons.block, blue0, "Blocked!", "This person has been blocked. Changes will apply when you restart your App",
//                                 delayInMilli: 500,onClicked: (_){
//                           Navigator.pop(context);
//                                 },cancellable: false);
//                           });
//                         }
//                        });
//                  }
//                });
//              },
//              child: Container(
//                width: 50,
//                height: 50,
//                margin: EdgeInsets.only(top: 30,right: 5),
//                child: Center(
//                    child: Icon(
//                      Icons.flag,

//                      color: white,
//                      size: 25,
//                    )),
//              )),),

//  Align(alignment: Alignment.topLeft,
//          child: InkWell(
//              onTap: () {
//                Navigator.of(context).pop();
//              },
//              child: Container(
//                width: 50,
//                height: 50,
//                margin: EdgeInsets.only(top: 30,left: 5),
//                child: Center(
//                    child: Icon(
//                      Icons.keyboard_backspace,
//                      color: white,
//                      size: 25,
//                    )),
//              )),)

//        ],
//      );
//    }




//    pickSingleImage() async {
//      File file = await ImagePicker.pickImage(source: ImageSource.gallery);
//      File croppedFile = await ImageCropper.cropImage(
//        sourcePath: file.path,aspectRatio: CropAspectRatio(ratioX: 4,ratioY:6),compressQuality: 100,
//        maxWidth: 3000,
//        maxHeight: 3000,
//      );
//      if (croppedFile != null) {
//        File firstImage = croppedFile;
// //       profileImages.add(firstImage.path);
// //       setState(() {});
//      uploadFile(firstImage, (res,error){
//        if(error!=null){
//          toastInAndroid(error.toString());
//          return;
//        }
//        personModel.put(USER_IMAGE, res);
//        personModel.updateItems();
//        if(mounted)setState(() {

//        });
//      });
//      }
//    }
//  }
