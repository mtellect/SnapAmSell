
// import 'dart:io';
// import 'dart:math';
// import 'dart:ui';

// import 'package:Strokes/AppEngine.dart';
// import 'package:Strokes/MyProfile1.dart';
// import 'package:Strokes/basemodel.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// import 'package:pull_to_refresh/pull_to_refresh.dart';
// import 'package:timeago/timeago.dart' as timeAgo;

// import 'MainAdmin.dart';
// import 'assets.dart';

// class MyConnects extends StatefulWidget {
//   @override
//   _MyConnectsState createState() => _MyConnectsState();

// }

// class _MyConnectsState extends State<MyConnects> {
  
//   bool setup = false;
//   List peopleList = [];
// //  List peopleIdsToLoad = [];
//   String loveQuote ="";

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     updateSeen();
//     List quotes = appSettingsModel.getList(LOVE_QUOTE);
//     if(quotes.isNotEmpty){
//       loveQuote = quotes[Random().nextInt(quotes.length)];
//     }
//   }


//  /* updateSeen(){
//     List list = userModel.getList(LOVE_LIST);
//     list.sort((a,b)=>b[TIME].compareTo(a[TIME]));
//     List newList = [];
//     for(Map map in list){
//       Map item = map;
//       item[STATUS] = APPROVED;
//       newList.add(item);
//       peopleIdsToLoad.add(item[OBJECT_ID]);
//     }
//     userModel.put(LOVE_LIST, newList);
//     userModel.updateItems();

//     loadPeople();
//   }*/

//  List connectsIds = [];
//  updateSeen()async{
//    QuerySnapshot shots = await Firestore.instance.collection(CONNECTS_BASE).where(PARTIES,
//        arrayContains: userModel.getObjectId()).orderBy(TIME,descending: true).getDocuments();

//    for(DocumentSnapshot doc in shots.documents){
//      BaseModel model = BaseModel(doc:doc);
//      String otherId = getOtherPersonId(model);
//      if(!connectsIds.contains(otherId))connectsIds.add(otherId);
//      if(!model.getList(READ_BY).contains(userModel.getObjectId())){
//          model.putInList(READ_BY, userModel.getObjectId(),true);
//          model.updateItems();
//          print("Updating Read");
//      }
//    }

//    loadPeople();
//  }

//   List loadedIds = [];
//   int loadMax = 20;
//   loadPeople()async{
//     int loadCount = 0;
//     for(String id in connectsIds){
//       if(isBlocked(null,userId: id))continue;
//       if(loadedIds.contains(id))continue;
//       loadedIds.add(id);

//       DocumentSnapshot doc = await Firestore.instance.collection(USER_BASE).document(id).get();
//       if(doc==null)continue;
//       if(!doc.exists)continue;
//       BaseModel user = BaseModel(doc:doc);
//       peopleList.add(user);

//       loadCount++;
//       if(loadCount==(loadMax/2)){
//         setup=true;
//         setState(() {});
//       }
//       if(loadCount>=loadMax)break;
//     }

//     setup = true;
//     try{
//       refreshController.loadComplete();
//     }catch(e){}
//     if(mounted)setState(() {

//     });
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(body: Stack(
//       fit: StackFit.expand,
//       children: <Widget>[
//         CachedNetworkImage(imageUrl: userModel.getString(USER_IMAGE),fit: BoxFit.cover,height: MediaQuery.of(context).size.height,),
//         BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
//             child: Container(color: black.withOpacity(.6),)),
//         page(),
//         Align(alignment: Alignment.topLeft,
//           child: InkWell(
//               onTap: () {
//                 Navigator.of(context).pop();
//               },
//               child: Container(
//                 width: 50,
//                 height: 50,
//                 margin: EdgeInsets.only(top: 30,left: 5),
//                 child: Center(
//                     child: Icon(
//                       Icons.keyboard_backspace,
//                       color: white,
//                       size: 25,
//                     )),
//               )),)        
//       ],
//     ),);
//   }

//   RefreshController refreshController = RefreshController();

//   page(){
//     if(!setup)return loadingLayout(trans: true);
//     if(setup && peopleList.isEmpty)return Container(
//       child: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(10),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               Image.asset(ic_couple,width: 30,height: 30,color: white,),
//               Text(userModel.isMale()?"No Wifee":"No Hubby",style: textStyle(true, 40, white),textAlign: TextAlign.center,),
//               Text(userModel.isMale()?"You have not been accepted by any potential wife yet":
//                 "You have not accepted any potential husband yet",style: textStyle(false, 16, white.withOpacity(.5)),textAlign: TextAlign.center,),
//             ],
//           ),
//         ),
//       ),
//     );

//     return SmartRefresher(
//       controller: refreshController,
//       enablePullDown: false,
//       enablePullUp: true,
//       header: Platform.isIOS ? WaterDropHeader() : WaterDropMaterialHeader(),
//       footer: ClassicFooter(
//         idleText: "",
//         idleIcon: Icon(Icons.arrow_drop_down, color: transparent),
//       ),
//       onLoading: () {
//         loadPeople();
//       },
//       onOffsetChange: (_, d) {},
//       child: SingleChildScrollView(
//         child: Column(
//           children: <Widget>[
//             addSpace(80),
//             Image.asset(ic_couple,color: white.withOpacity(.5),height: 60,),
//             if(loveQuote.isNotEmpty) Padding(
//               padding: const EdgeInsets.fromLTRB(20,5,20,0),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   Icon(
//                     Icons.format_quote,
//                     size: 20,
//                     color: white.withOpacity(.5),
//                   ),
//                   Flexible(child: Text(loveQuote,
//                     style: textStyle(false, 20, white.withOpacity(.5)),textAlign: TextAlign.center,)),
//                 ],
//               ),
//             ),
//             addSpace(15),
//             StaggeredGridView.countBuilder(
//               crossAxisCount: 4,
//               itemCount: peopleList.length,
//               itemBuilder: (BuildContext context, int index) {
//                 BaseModel bm = peopleList[index];
//                 return GestureDetector(
//                   onTap: (){
//                     pushAndResult(context, MyProfile1(bm,));
//                   },
//                   child: Hero(
//                     tag: bm.getObjectId(),
//                     child: Card(
//                       color: default_white,elevation: 0,clipBehavior: Clip.antiAlias,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(10)),
//                           side: BorderSide(color: bm.isMale()?blue0:pink0,width: 3)
//                       ),
//                       child: Stack(fit:StackFit.expand,children: <Widget>[
//                         CachedNetworkImage(imageUrl: bm.getString(USER_IMAGE),fit: BoxFit.cover,),
//                         Align(
//                           alignment: Alignment.bottomCenter,
//                           child: gradientLine(height: 120, alpha: .8, reverse: false),
//                         ),
//                         if(isOnline(bm))Align(
//                           alignment: Alignment.topLeft,
//                           child: Container(margin: EdgeInsets.all(5),
//                           child:  onlineDot(),),
//                         ),
//                         Align(
//                           alignment: Alignment.bottomLeft,
//                           child: Padding(
//                             padding: const EdgeInsets.all(10.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,mainAxisSize: MainAxisSize.min,
//                               children: <Widget>[

//                                 Text(
//                                   getFullName(bm),
//                                   style: textStyle(true, 16, white,),maxLines: 2,
//                                 ),
//                                 Text(
//                                   "Last seen ${timeAgo.format(
//                                 DateTime.fromMillisecondsSinceEpoch(bm.getInt(TIME_UPDATED)),locale: "en_short")}",
//                                   style: textStyle(false, 12, white.withOpacity(.5),),
//                                   maxLines: 1,overflow: TextOverflow.ellipsis,
//                                 ),

//                               ],
//                             ),
//                           ),
//                         ),
//                       ]),
//                     ),
//                   ),
//                 );
//               },
//               padding: EdgeInsets.all(0),
//               staggeredTileBuilder: (int index) =>
//               new StaggeredTile.count(2, index.isEven ? 3 : 2.5),physics: NeverScrollableScrollPhysics(),
//               shrinkWrap: true,
//               mainAxisSpacing: 4.0,
//               crossAxisSpacing: 4.0,
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
