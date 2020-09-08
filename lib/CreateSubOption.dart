
import 'package:maugost_apps/ChooseOptions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/assets.dart';
import 'package:maugost_apps/basemodel.dart';

//import 'package:ABM/photo_picker/photo.dart';



class CreateSubOption extends StatefulWidget {
  Map item;
  CreateSubOption({this.item});
  @override
  _CreateSubOptionState createState() => _CreateSubOptionState();
}

class _CreateSubOptionState extends State<CreateSubOption> {

  final String progressId = getRandomId();

  TextEditingController nameController = new TextEditingController();
  String nameError;
  TextEditingController itemsController = new TextEditingController();
  String itemsError;
  TextEditingController itemsTitleController = new TextEditingController(text: "Model");
  String itemsTitleError;


  bool hasSubItems = false;
  int clickBack = 0;
  Map item;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    item = widget.item;
    if(item!=null){
      nameController.text = item[NAME];
      itemsController.text = item[ITEMS];
      itemsTitleController.text = item[ITEM_TITLE];
      hasSubItems = item[HAS_SUB_ITEMS]??false;
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext c) {
    return WillPopScope(
        onWillPop: () {
          int now = DateTime.now().millisecondsSinceEpoch;
          if ((now - clickBack) > 5000) {
            clickBack = now;
            showError("Click back again to exit");
            return;
          }
          Navigator.pop(context);
          return;
        },
        child: Scaffold(
            resizeToAvoidBottomInset: true,key: _scaffoldKey,
            backgroundColor: white,
            body: page()));
  }

   page() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        addSpace(40),
        new Container(
          width: double.infinity,
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
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
              Flexible(
                fit: FlexFit.tight,
                flex: 1,
                child: new Text(
                  item!=null?"Update Option":"Sub Option",
                  style: textStyle(true, 20, black),
                ),
              ),
              addSpaceWidth(10),
              FlatButton(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  color: blue3,
                  onPressed: () {
                    post();
                  },
                  child: Text(
                    item!=null?"UPDATE":"ADD",
                    style: textStyle(true, 14, white),
                  )),
              addSpaceWidth(15)
            ],
          ),
        ),
        //addLine(1, black.withOpacity(.2), 0, 5, 0, 0),
        AnimatedContainer(duration: Duration(milliseconds: 500),
          width: double.infinity,
          height: errorText.isEmpty?0:40,
          color: red0,
          padding: EdgeInsets.fromLTRB(10,0,10,0),
          child:Center(child: Text(errorText,style: textStyle(true, 16, white),)),
        ),
        Expanded(
          flex: 1,
          child: Scrollbar(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(0),
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[

                          inputTextView("Name", nameController, isNum: false,errorText: nameError,
                            onEditted: (){
                              nameError=null;
                              setState(() {});
                            },),
                          GestureDetector(
                            onTap: (){
                              setState(() {
                                hasSubItems= !hasSubItems;
                              });
                            },
                            child: Container(
                              height: 35,
                              margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              decoration: BoxDecoration(
                                  border: Border.all(color: blue0, width: 2),color: transparent,
                                  borderRadius: BorderRadius.circular(25)),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Flexible(
                                      flex: 1,
                                      fit: FlexFit.tight,
                                      child: Text("Add Items",style: textStyle(true, 16, blue0),)
                                  ),
                                  addSpaceWidth(10),
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                        color: hasSubItems ? blue0 : blue09,
                                        border: Border.all(color: blue0, width: 1),
                                        shape: BoxShape.circle),
                                    child:hasSubItems
                                        ? Center(
                                        child: Icon(
                                          Icons.check,
                                          color: white,
                                          size: 15,
                                        ))
                                        : Container(),
                                  )
                                ],
                              ),
                            ),
                          ),
                          if(hasSubItems)inputTextView("Items Title", itemsTitleController, isNum: false,
                            errorText: itemsTitleError,
                            onEditted: (){
                              itemsTitleError=null;
                              setState(() {});
                            },),
                          if(hasSubItems)inputTextView("Items (separate with comma)", itemsController, isNum: false,
                            errorText: itemsError,
                            onEditted: (){
                              itemsError=null;
                              setState(() {});
                            },),


                          addSpace(50),
                        ]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }


  void post() {
    String name = nameController.text.trim();
    String title = itemsTitleController.text.trim();
    String items = itemsController.text.trim();

    if(name.isEmpty && item==null){
      nameError = "Enter Name";
      setState(() {});
      return;
    }
    nameError = null;
    setState(() {});

    if(title.isEmpty && hasSubItems){
      itemsTitleError = "Enter Item Title";
      setState(() {});
      return;
    }
    itemsTitleError = null;
    setState(() {});

    if(items.isEmpty && hasSubItems){
      itemsError = "Enter Items";
      setState(() {});
      return;
    }
    itemsError = null;
    setState(() {});


    Map map = Map();
    map[NAME] = name;
    map[ITEMS] = items;
    map[ITEM_TITLE] = title;
    map[HAS_SUB_ITEMS] = hasSubItems;

    Navigator.pop(context,map);
  }

  snack(String text){
    Future.delayed(Duration(milliseconds: 100),(){
      showSnack(_scaffoldKey, text,);
    });
  }

  String errorText ="";
  showError(String text){
    errorText=text;
    setState(() {


    });
    Future.delayed(Duration(seconds: 1),(){
      errorText="";
      setState(() {});
    });
  }
}
