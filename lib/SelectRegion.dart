import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/basemodel.dart';

import 'assets.dart';

class SelectRegion extends StatefulWidget {
  String selectedState;
  String selectedRegion;
  bool canSelectOnlyState;
  SelectRegion(
      {this.selectedState,
      this.selectedRegion,
      this.canSelectOnlyState = false});
  @override
  _SelectRegionState createState() => _SelectRegionState();
}

class _SelectRegionState extends State<SelectRegion> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController searchController = TextEditingController();

  bool setup = false;
  bool showCancel = false;
  FocusNode focusSearch = FocusNode();
  List<BaseModel> allItems = [];
  List<BaseModel> items = [];
  String selectedState;
  String selectedRegion;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedState = widget.selectedState;
    selectedRegion = widget.selectedRegion;
    loadItems();
  }

  loadItems() async {
    setup = false;
    setState(() {});
    QuerySnapshot shots = await Firestore.instance
        .collection(COUNTRY_BASE)
        .where(COUNTRY, isEqualTo: defaultCountry)
        .getDocuments();
    for (DocumentSnapshot shot in shots.documents) {
      BaseModel model = BaseModel(doc: shot);
      allItems.add(model);
    }
    reload();
  }

  reload() {
    String search = searchController.text.trim().toLowerCase();
    items.clear();
    for (BaseModel item in allItems) {
      if (search.isNotEmpty) {
        if (item.getString(STATE).toLowerCase().contains(search)) {
          items.add(item);
        } else {
          List cities = List.from(item.getList(CITY));
          bool exist = false;
          for (String s in cities)
            if (s.toLowerCase().contains(search)) exist = true;
          if (exist) {
            items.add(item);
            selectedState = item.getString(STATE);
          }
        }
        continue;
      }
      items.add(item);
    }
    setup = true;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
//         if(currentPage!=0){
//           pageController.animateToPage(0, duration: Duration(milliseconds: 500), curve: Curves.ease);
//           return;
//         }
        Navigator.pop(context);
        return;
      },
      child: Scaffold(
        body: page(),
        backgroundColor: white,
        key: _scaffoldKey,
      ),
    );
  }

  page() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        addSpace(40),
        Row(
          children: <Widget>[
            InkWell(
                onTap: () {
                  Navigator.pop(context);
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
                flex: 1,
                fit: FlexFit.tight,
                child: Text(
                  "Region",
                  style: textStyle(true, 25, black),
                )),
            addSpaceWidth(20),
          ],
        ),
        addSpace(5),
        if (setup)
          Container(
            height: 45,
            margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
            decoration: BoxDecoration(
                color: white.withOpacity(.8),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: black.withOpacity(.1), width: 1)),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              //mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                addSpaceWidth(10),
                Icon(
                  Icons.search,
                  color: orange01.withOpacity(.5),
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
                          orange1.withOpacity(.5),
                        ),
                        border: InputBorder.none,
                        isDense: true),
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
        GestureDetector(
          onTap: () {
            // checkLocation(context, (_) {
            //   if (_ != null) {
            //     Navigator.pop(context, [_.getString(STATE), _.getString(CITY)]);
            //   }
            // });
          },
          child: Container(
            padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
            color: transparent,
            child: Row(
              children: [
                Icon(
                  Icons.place,
                  color: blue0,
                ),
                addSpaceWidth(10),
                Flexible(
                  fit: FlexFit.tight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "My Location",
                        style: textStyle(true, 14, blue0),
                      ),
                      Text(
                        "Detect Location",
                        style: textStyle(false, 12, black.withOpacity(.4)),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        if (widget.canSelectOnlyState)
          Container(
            height: 40,
            margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
//                            width: 70,
            child: FlatButton(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                                padding: EdgeInsets.all(0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                    side: BorderSide(color: orange1, width: 2)),
                color: transparent,
                onPressed: () {
                  Navigator.pop(context, ["", ""]);
                },
                child: Text(
                  "Whole $defaultCountry",
                  style: textStyle(true, 16, orange1),
                )),
          ),
        addLine(1, black.withOpacity(.1), 0, 0, 0, 0),
        Expanded(
          child: !setup
              ? loadingLayout()
              : setup && allItems.isEmpty
                  ? emptyLayout(
                      Icons.place, "Nothing to display", "Tap to retry",
                      clickText: "Retry", click: () {
                      loadItems();
                    })
                  : mainPage(),
        ),
      ],
    );
  }

  mainPage() {
    return ListView.builder(
      itemBuilder: (c, p) {
        BaseModel model = items[p];
        String state = model.getString(STATE);
        bool selected = selectedState == state;
        List cities = List.from(model.getList(CITY));
        List cities1 = List.from(model.getList(CITY));
        String search = searchController.text.trim().toLowerCase();
        if (search.isNotEmpty &&
            !state.toString().toLowerCase().contains(search.toLowerCase())) {
          cities.clear();
          for (String s in cities1)
            if (s.toLowerCase().contains(search)) cities.add(s);
        }
        return Column(
          children: [
            GestureDetector(
              onTap: () {
                if (selectedState == state) {
                  selectedState = "";
                } else {
                  selectedState = state;
                }
                setState(() {});
              },
              child: Container(
                decoration: BoxDecoration(
                  color: selected ? default_white : white,
                ),
                padding: EdgeInsets.fromLTRB(15, 15, 0, 15),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: [
                        addSpaceWidth(10),
                        Flexible(
                            fit: FlexFit.tight,
                            child: Text(
                              state,
                              style: textStyle(false, 18, black),
                            )),
                        addSpaceWidth(5),
                        Icon(
                          selected
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          size: 25,
                          color: black.withOpacity(.5),
                        ),
                        addSpaceWidth(10),
                      ],
                    ),
                    if (selected)
                      Container(
                        margin: EdgeInsets.fromLTRB(50, 0, 20, 0),
                        decoration: BoxDecoration(
                            border: Border(
                                left:
                                    BorderSide(color: dark_green0, width: 2))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.canSelectOnlyState)
                              Container(
                                height: 40,
                                margin: EdgeInsets.fromLTRB(20, 20, 20, 10),
//                            width: 70,
                                child: FlatButton(
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
//                                padding: EdgeInsets.all(0),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                        side: BorderSide(
                                            color: dark_green0, width: 2)),
                                    color: transparent,
                                    onPressed: () {
                                      selectedState = state;
                                      Navigator.pop(
                                          context, [selectedState, ""]);
                                    },
                                    child: Text(
                                      "Whole $state",
                                      style: textStyle(true, 16, dark_green0),
                                    )),
                              ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(cities.length, (index) {
                                String name = cities[index];
                                return GestureDetector(
                                  onTap: () {
                                    selectedRegion = name;
                                    Navigator.pop(context,
                                        [selectedState, selectedRegion]);
                                  },
                                  child: Container(
                                    color: transparent,
                                    margin: EdgeInsets.fromLTRB(35, 0, 0, 0),
//                                 height: 50,
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                          height: 50,
                                          child: Row(
                                            children: <Widget>[
                                              Flexible(
                                                child: Text(
                                                  name,
                                                  style: textStyle(
                                                      false, 18, black),
                                                ),
                                                flex: 1,
                                                fit: FlexFit.tight,
                                              ),
                                              addSpaceWidth(10),
//                                        if(!widget.singleMode)checkBox(selected),
                                            ],
                                          ),
                                        ),
                                        addLine(.5, black.withOpacity(.1), 0, 0,
                                            0, 0)
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            addLine(.5, black.withOpacity(.1), 0, 0, 0, 0)
          ],
          mainAxisSize: MainAxisSize.min,
        );
      },
      shrinkWrap: true,
      padding: EdgeInsets.all(0),
      itemCount: items.length,
    );
  }

  /*askForLocation()async{
     Location location = new Location();
     await location.requestService();
     await location.requestPermission();
   }
*/
}
