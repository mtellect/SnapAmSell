
// import 'dart:io';

// import 'package:Strokes/AppEngine.dart';
// import 'package:Strokes/assets.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:firebase_ml_vision/firebase_ml_vision.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:image_cropper/image_cropper.dart';
// import 'package:image_picker/image_picker.dart';

// import 'dialogs/inputDialog.dart';


// class EditProfile extends StatefulWidget {
//   @override
//   _page2State createState() => _page2State();
// }

// class _page2State extends State<EditProfile> {

//   TextEditingController fNameController = TextEditingController();
//   TextEditingController lNameController = TextEditingController();
//   TextEditingController spouseController = TextEditingController();

//   List<TextEditingController> controllers = [];

//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   String keyCook;
//   String keySex;
//   List foodList;
//   double currentDrive;
//   List moreItems = [];

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     keyCook = userModel.getBoolean(CAN_COOK)?"YES":"NO";
//     keySex = userModel.getBoolean(CAN_SEX)?"YES":"NO";
//     foodList = userModel.getList(FOOD_LIST);
//     currentDrive = userModel.getDouble(SEX_DRIVE);


//     fNameController.text = userModel.getString(NAME);
// //    lNameController.text = userModel.getString(LAST_NAME);
//     spouseController.text = userModel.getString(IDEAL);

//     String moreInfo = appSettingsModel.getString(MORE_INFO);
//     if(moreInfo.isNotEmpty){
//       moreItems = convertStringToList(",", moreInfo);
//       for(String s in moreItems){
//         TextEditingController tController = TextEditingController();
//         tController.text = userModel.getString(s);
//         controllers.add(tController);
//       }
//     }


//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: (){
//         Navigator.pop(context,userModel);
//         return;
//       },
//       child: SafeArea(
//         child: Scaffold(
//           body: page(),backgroundColor: white,key: _scaffoldKey,
//         ),
//       ),
//     );
//   }

//   page(){

//     List images = userModel.getList(IMAGES);
//     return Column(

//       children: <Widget>[
//         addSpace(10),
//         new Container(
//           width: double.infinity,
//           child: new Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisSize: MainAxisSize.max,
//             children: <Widget>[
//               InkWell(
//                   onTap: () {
//                     Navigator.of(context).pop(userModel);
//                   },
//                   child: Container(
//                     width: 50,
//                     height: 50,
//                     child: Center(
//                         child: Icon(
//                           Icons.keyboard_backspace,
//                           color: black,
//                           size: 25,
//                         )),
//                   )),
//               Flexible(
//                 fit: FlexFit.tight,
//                 flex: 1,
//                 child: new Text(
//                   "Edit Profile",
//                   style: textStyle(true, 23, black),
//                 ),
//               ),
//               addSpaceWidth(10),

//             ],
//           ),
//         ),
//         Expanded(flex: 1,
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[

//                 Center(
//                   child: SingleChildScrollView(
//                     padding: EdgeInsets.all(0),
//                     scrollDirection: Axis.horizontal,
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       mainAxisSize: MainAxisSize.min,
//                       children: <Widget>[
//                         GestureDetector(
//                           onTap: () {
//                             pickSingleImage(profilePhoto: true);
//                           },
//                           child: Container(
//                             margin: EdgeInsets.fromLTRB(5,10,5,0),
//                             width: MediaQuery.of(context).size.width/3,
//                             height: MediaQuery.of(context).size.width/2,
//                             child: Card(
//                               color: default_white,elevation: 0,clipBehavior: Clip.antiAlias,
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.all(Radius.circular(10)),
//                                   side: BorderSide(color: black.withOpacity(.1),width: .5)
//                               ),
//                               child: CachedNetworkImage(imageUrl: userModel.getString(USER_IMAGE),fit: BoxFit.cover,),
//                             ),
//                           ),
//                         ),
//                         Row(mainAxisSize: MainAxisSize.min,
//                           children: List.generate(images.length, (p){

//                             return Container(
//                               margin: EdgeInsets.fromLTRB(0,0,5,0),
//                               width: 50,
//                               height: 70,color: transparent,
//                               child: GestureDetector(
//                                 onTap: (){
//                                   showListDialog(context, ["View Photo","Remove Photo"], (int x){
//                                     if(x==0){
//                                       pushAndResult(context, ViewImage([images], p));
//                                     }
//                                     if(x==1){
//                                       yesNoDialog(context, "Remove Photo?", "Are your sure", (){
//                                         deleteFileOnline(images[p]);
//                                         images.removeAt(p);
//                                         userModel.put(IMAGES,images);
//                                         userModel.updateItems();
//                                         setState(() {

//                                         });
//                                       });
//                                     }
//                                   });
//                                 },
//                                 child: Card(
//                                   color: default_white,elevation: 0,clipBehavior: Clip.antiAlias,
//                                   shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.all(Radius.circular(10)),
//                                       side: BorderSide(color: black.withOpacity(.1),width: .5)
//                                   ),
//                                   child: CachedNetworkImage(imageUrl: images[p],fit: BoxFit.cover,),
//                                 ),
//                               ),
//                             );
//                           }),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Center(
//                   child: InkWell(
//                     onTap: () {
//                       pickSingleImage(profilePhoto: false);
//                     },
//                     child: Container(
//                       margin: EdgeInsets.only(top: 10),
//                       padding: EdgeInsets.fromLTRB(10,5,10,5),
// //                      width: 150,
// //                    height: 100,
//                       decoration: BoxDecoration(
//                           color: blue09,
//                           borderRadius: BorderRadius.circular(5),
//                           border: Border.all(
//                               color: black.withOpacity(.1), width: .5)),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: <Widget>[
//                           Icon(
//                             Icons.image,
//                             color: blue0,
//                             size: 16,
//                           ),
//                           addSpaceWidth(5),
//                           Text(
//                             "Add More Photos",
//                             textAlign: TextAlign.center,
//                             style: textStyle(true, 14, blue0),
//                           ),


//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(20,20,20,10),
//                   child: Text("First Name",style: textStyle(true, 12, black.withOpacity(.5)),),
//                 ),
//                 textbox(fNameController,"First Name",center: false),
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(20,0,20,10),
//                   child: Text("Last Name",style: textStyle(true, 12, black.withOpacity(.5)),),
//                 ),
//                 textbox(lNameController,"Last Name",center: false),
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(20,0,20,10),
//                   child: Text("Describe your ideal spouse",style: textStyle(true, 12, black.withOpacity(.5)),),
//                 ),
//                 textbox(spouseController,"Describe your ideal ${userModel.isMale()?"wife":"husband"}",
//                     lines: 5,center: false),
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(20,0,20,10),
//                   child: Text("Can you cook?",style: textStyle(true, 12, black.withOpacity(.5)),),
//                 ),
//                 groupedButtons(["YES","NO"], keyCook, (text) {
//                   keyCook=text;
//                    setState(() {
//                   });
//                 }, selectedColor: getWifeColor(), normalColor: getWifeColor(),
//                     selectedTextColor: white, normalTextColor: getWifeColor()),
//                 if(keyCook=="YES")Container(
//                   margin: EdgeInsets.only(top: 10,bottom: 0),
// //              height: 40,
//                   child: SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: Center(
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: <Widget>[
//                           Container(
//                             height: 30,
//                             width: 100,
//                             margin: EdgeInsets.fromLTRB(20, 0, 10, 0),
//                             child: FlatButton(
//                               color: default_white,
//                               onPressed: (){
//                                 pushAndResult(context, inputDialog("Food Name",),result: (_){
//                                   foodList.add(_.toString().trim());
//                                   setState(() {

//                                   });
//                                 });
//                               }, child: Text("Add Food",style: textStyle(true, 12, black),),
//                             ),
//                           ),
//                           Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: List.generate(foodList.length, (p){
//                               return GestureDetector(
//                                 onTap: (){
//                                   yesNoDialog(context, "Remove?", "Remove this item?", (){
//                                     foodList.remove(foodList[p]);
//                                     setState(() {

//                                     });
//                                     setState(() {
//                                     });
//                                   });
//                                 },
//                                 child: Container(
//                                     color: transparent,
//                                     margin: EdgeInsets.only(right: 10),
//                                     child: Text(foodList[p],style: textStyle(false, 14, black.withOpacity(.5)),)),
//                               );
//                             }),
//                           )
//                         ],
//                       ),
//                     ),padding: EdgeInsets.all(0),),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(20,10,20,10),
//                   child: Text("Do you love sex?",style: textStyle(true, 12, black.withOpacity(.5)),),
//                 ),
//                 groupedButtons(["YES","NO"], keySex, (text) {
//                   keySex=text;
//                   setState(() {
//                   });
//                 }, selectedColor: getWifeColor(), normalColor: getWifeColor(),
//                     selectedTextColor: white, normalTextColor: getWifeColor()),
//                 if(keySex=="YES")Padding(
//                   padding: const EdgeInsets.fromLTRB(20,20,20,20),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: <Widget>[
//                       Text("Rate your sex drive",style: textStyle(true, 14, Colors.amber),),
//                       addSpace(10),
//                       RatingBar(
//                         initialRating: currentDrive,glow: true,
//                         direction: Axis.horizontal,
//                         allowHalfRating: true,
//                         itemCount: 5,
//                         ratingWidget: RatingWidget(
//                           full: getAssetImage(heart),
//                           half: getAssetImage(heart_half),
//                           empty: getAssetImage(heart_border),
//                         ),
//                         itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
//                         onRatingUpdate: (rating) {
//                           currentDrive = rating;
//                           setState(() {
// //                  _rating = rating;
//                           });
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//                 if(moreItems.isNotEmpty)Column(
//                   children: List.generate(moreItems.length, (p){
//                     String title = moreItems[p];
//                     TextEditingController tController = controllers[p];
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: <Widget>[
//                         Padding(
//                           padding: const EdgeInsets.fromLTRB(20,0,20,10),
//                           child: Text(title,style: textStyle(true, 12, black.withOpacity(.5)),),
//                         ),
//                         textbox(tController,"",center: false),
//                       ],
//                     );
//                   }),
//                 ),
//                 addSpace(50),
//               ],
//             ),
//           ),
//         ),
//         Container(
//           width: double.infinity,
//           height: 60,
//           margin: EdgeInsets.all(0),
//           child:FlatButton(
//               materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(0)),
//               color: red0,
//               onPressed: () {
//                 updateProfile();
//               },
//               child: Text(
//                 "Update",
//                 style: textStyle(true, 16, white),
//               )),
//         )
//       ],
//     );
//   }

//   updateProfile(){
//     String fName = fNameController.text.trim();
//     String lName = lNameController.text.trim();
//     String ideal = spouseController.text.trim();

//     if(fName.length<2){
//       showSnack(_scaffoldKey, "Enter your first name",useWife: true);
//       return;
//     }
//     if(lName.length<2){
//       showSnack(_scaffoldKey, "Enter your last name",useWife: true);
//       return;
//     }
// //    if(city.length<2){
// //      snack("Enter your current city");
// //      return;
// //    }
//     if(ideal.length<2){
//       snack("Describe your ideal ${userModel.isMale()?"wife":"husband"}");
//       return;
//     }

//     userModel.put(CAN_SEX, keySex=="YES");
//     userModel.put(SEX_DRIVE, currentDrive);

//     userModel.put(CAN_COOK, keyCook=="YES");
//     userModel.put(FOOD_LIST, foodList);

//     userModel.put(NAME, fName);
// //    userModel.put(LAST_NAME, lName);
// //    userModel.put(CITY, city);
//     userModel.put(IDEAL, ideal);
//     userModel.put(PROFILE_UPDATED, DateTime.now().millisecondsSinceEpoch);

//     for(int i=0;i<moreItems.length;i++){
//       String title = moreItems[i];
//       TextEditingController textEditingController = controllers[i];
//       userModel.put(title,textEditingController.text.trim());
//     }

//     userModel.updateItems();
//     Future.delayed(Duration(milliseconds: 1000),(){
//     Navigator.pop(context,userModel);
//     });
//   }

//   pickSingleImage({@required bool profilePhoto}) async {
//     File file = await ImagePicker.pickImage(source: ImageSource.gallery);
//     File croppedFile = await ImageCropper.cropImage(
//       sourcePath: file.path,aspectRatio: CropAspectRatio(ratioX: 4,ratioY:6),compressQuality: 100,
//       maxWidth: 3000,
//       maxHeight: 3000,
//     );
//     if (croppedFile != null) {
//       File firstImage = croppedFile;

//       savePhoto(firstImage,profilePhoto);
//     }
//   }

//   savePhoto(File image,bool profilePhoto)async{
//     showProgress(true, context,msg: profilePhoto?"Updating Photo":"Saving Photo");

//     bool face = await hasFace(image);
//     if(!face){
//       showProgress(false, context);
//       showMessage(context, Icons.face, red0, "No face detected", "Upload another photo and try again",
//           delayInMilli: 500);
//       return;
//     }

//     uploadFile(image, (res,error){
//       showProgress(false, context);
//       if(error!=null){
//         showMessage(context, Icons.error, red0, "Error", "Error updating photo, try again later",delayInMilli: 500);
//         return;
//       }
//       if(profilePhoto) {
//         userModel.put(USER_IMAGE, res);
//       }else{
//         List images = userModel.getList(IMAGES);
//         images.add(res);
//         userModel.put(IMAGES, images);
//       }
//       userModel.put(PROFILE_UPDATED, DateTime.now().millisecondsSinceEpoch);
//       userModel.updateItems();
// //      showMessage(context, Icons.check, blue0, "Success", "Your profile photo has been updated successfully",delayInMilli: 600,);
//       if(mounted)setState(() {

//       });
//     });
//   }

//   Future<bool> hasFace(File file)async{
//     showProgress(true, context);
//     final image = FirebaseVisionImage.fromFile(file);
//     final faceDetector = FirebaseVision.instance.faceDetector();
//     List<Face> faces = await faceDetector.processImage(image);
//     showProgress(false, context);
//     return faces.isNotEmpty;
//   }

//   snack(String text){
//     showSnack(_scaffoldKey, text);
//   }

// }
