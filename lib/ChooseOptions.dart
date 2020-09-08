
 import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/CreateOption.dart';
import 'package:maugost_apps/basemodel.dart';
import 'package:maugost_apps/dialogs/inputDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'assets.dart';

class ChooseOptions extends StatefulWidget {
  List selections;
  ChooseOptions(this.selections);
   @override
   _ChooseOptionsState createState() => _ChooseOptionsState();
 }

 class _ChooseOptionsState extends State<ChooseOptions> {
   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
   TextEditingController searchController = TextEditingController();

   bool setup = false;
   bool showCancel = false;
   FocusNode focusSearch = FocusNode();
  List allItems = [];
  List items = [];
  List selections;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selections=widget.selections;
    allItems = appSettingsModel.getList(OPTIONS);
    allItems.sort((m1,m2)=>m1[DISPLAY_NAME].compareTo(m2[DISPLAY_NAME]));
    reload();
  }

   reload(){
     String search = searchController.text.trim().toLowerCase();
     items.clear();
     for(Map item in allItems){
       if(search.isNotEmpty){
         List values = item.values.toList();
         bool exist = false;
         for(var a in values){
           if(a.toString().toLowerCase().contains(search)){
             exist = true;
             break;
           }
         }
         if(!exist)continue;
       }
       items.add(item);
     }

     if(mounted)setState(() {

     });
   }

   @override
   Widget build(BuildContext context) {
     return WillPopScope(
       onWillPop: (){
         Navigator.pop(context,selections);
         return;
       },
       child: Scaffold(
         body: page(),backgroundColor: white,key: _scaffoldKey,
       ),
     );
   }

   page(){
     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: <Widget>[
         addSpace(40),
         Row(
           children: <Widget>[
             InkWell(
                 onTap: () {
                   Navigator.pop(context,selections);
                 },
                 child: Container(
                   width: 50,
                   height: 50,
                   child: Center(
                       child: Icon(
                         Icons.keyboard_backspace,
                         color: black,
                         size: 25,
                       )),
                 )),
             Flexible(flex:1,fit:FlexFit.tight,child: Text("Options",style: textStyle(true, 25, blue3),)),
             addSpaceWidth(10),
             FlatButton(
                 materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                 shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(25)),
                 color: red0,
                 onPressed: () {
                   pushAndResult(context, CreateOption(),result: (_){
                     allItems.add(_);
                     reload();
                   });
                 },
                 child: Text(
                   "Create",
                   style: textStyle(true, 14, white),
                 )),
             addSpaceWidth(20),
           ],
         ),
         addSpace(5),
         Container(
           height: 45,
           margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
           decoration: BoxDecoration(
               color: white.withOpacity(.8),
               borderRadius: BorderRadius.circular(25),
               border: Border.all(color: black.withOpacity(.1),width: 1)
           ),
           child: Row(
             mainAxisSize: MainAxisSize.max,
             crossAxisAlignment: CrossAxisAlignment.center,
             //mainAxisAlignment: MainAxisAlignment.center,
             children: <Widget>[
               addSpaceWidth(10),
               Icon(
                 Icons.search,
                 color: blue3.withOpacity(.5),
                 size: 17,
               ),
               addSpaceWidth(10),
               new Flexible(
                 flex: 1,
                 child: new TextField(
                   textInputAction: TextInputAction.search,
                   textCapitalization: TextCapitalization.sentences,
                   autofocus: false,
                   onSubmitted: (_) {
                     //reload();
                   },
                   decoration: InputDecoration(
                       hintText: "Search",
                       hintStyle: textStyle(
                         false,
                         18,
                         blue3.withOpacity(.5),
                       ),
                       border: InputBorder.none,isDense: true),
                   style: textStyle(false, 16, black),
                   controller: searchController,
                   cursorColor: black,
                   cursorWidth: 1,
                   focusNode: focusSearch,
                   keyboardType: TextInputType.text,
                   onChanged: (s) {
                     showCancel = s.trim().isNotEmpty;
                     setState(() {});
                     reload();
                   },
                 ),
               ),
               GestureDetector(
                 onTap: () {
                   setState(() {
                     focusSearch.unfocus();
                     showCancel = false;
                     searchController.text = "";
                   });
                   reload();
                 },
                 child: showCancel
                     ? Padding(
                   padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                   child: Icon(
                     Icons.close,
                     color: black,
                     size: 20,
                   ),
                 )
                     : new Container(),
               )
             ],
           ),
         ),
         Expanded(child: ListView.builder(itemBuilder: (c,p){
           Map item = items[p];
           BaseModel model = BaseModel(items: item);
           String name = model.getString(NAME);
           String displayName = model.getString(DISPLAY_NAME);
           List subItems = model.getList(ITEMS);
           bool multiple = model.getBoolean(MULTIPLE);
           bool selected = selections.contains(name);
           return GestureDetector(
             onTap: (){
               if(!selections.contains(name)){
                 selections.add(name);
               }else{
                 selections.remove(name);
               }
               setState(() {

               });
             },
             onLongPress: (){
               showListDialog(context, ["Edit","Delete"], (int x){
                 if(x==0){
                   pushAndResult(context, CreateOption(item:item),result: (_){
                     int index = allItems.indexWhere((m) => m==item);
                     if(index!=-1)allItems[index] = _;

                     int index1 = items.indexWhere((m) => m==item);
                     if(index1!=-1)items[index1] = _;

                     appSettingsModel.put(OPTIONS, allItems);
                     appSettingsModel.updateItems();
                     setState(() {});
                   });
                 }
                 if(x==1){
                   yesNoDialog(context, "Delete?", "Delete This?", (){
                     items.remove(item);
                     allItems.remove(item);
                     appSettingsModel.put(OPTIONS, allItems);
                     appSettingsModel.updateItems();
                     setState(() {

                     });
                   });
                 }
               },);
             },
             child: Container(
               decoration: BoxDecoration(
                   borderRadius: BorderRadius.all(Radius.circular(5),),border: Border.all(
                   color: black.withOpacity(.1),width: .5
               ),color: blue09
               ),
               margin: const EdgeInsets.fromLTRB(10,0,10,10),
               padding: const EdgeInsets.all(10),
               child: Row(
                 children: <Widget>[
                   addSpaceWidth(5),
                   Flexible(child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                      Text(displayName,style: textStyle(true, 18, blue3),),
                       addSpace(10),
                       nameItem("Unique Name", name),
                       nameItem("Items", subItems.toString()),
                       nameItem("Multi Selection", multiple.toString()),
                     ],
                   ),flex: 1,fit: FlexFit.tight,),
                   addSpaceWidth(10),
                   checkBox(selected),
//                 addSpaceWidth(10)
                 ],
               ),
             ),
           );
         },physics: BouncingScrollPhysics(),padding: EdgeInsets.all(0),itemCount: items.length,)),
         Container(width: double.infinity,height: 50,
           child: FlatButton(
               materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
               shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(0)),
               color: blue3,
               onPressed: () {
                Navigator.pop(context,selections);
               },
               child: Text(
                 "Select",
                 style: textStyle(true, 18, white),
               )),
         ),
       ],
     );
   }
 }
