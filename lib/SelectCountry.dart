import 'package:country_pickers/countries.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'AppEngine.dart';
import 'assets.dart';

class SelectCountry extends StatefulWidget {
  @override
  _SelectCountryState createState() => _SelectCountryState();
}

class _SelectCountryState extends State<SelectCountry> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController searchController = TextEditingController();

  bool setup = true;
  bool showCancel = false;
  FocusNode focusSearch = FocusNode();
  List<Country> listItems = [];
  List<Country> allItems = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listItems.addAll(countryList);
    allItems.addAll(countryList);
  }

  reload() {
    String search = searchController.text.trim();
    listItems.clear();
    for (Country c in allItems) {
      String s = c.name;
      if (search.isNotEmpty && !s.toLowerCase().contains(search.toLowerCase()))
        continue;
      listItems.add(c);
    }
    setState(() {});
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
                  "Country",
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
                  color: dark_green0.withOpacity(.5),
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
                          dark_green0.withOpacity(.5),
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
        Expanded(
            child: ListView.builder(
          padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
          itemBuilder: (context, position) {
            Country country = listItems[position];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                position == 0
                    ? Container()
                    : addLine(.5, black.withOpacity(.1), 0, 0, 0, 0),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(listItems[position]);
                  },
                  child: new Container(
                    color: white,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(5, 15, 10, 15),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Card(
                            child: CountryPickerUtils.getDefaultFlagImage(
                                CountryPickerUtils.getCountryByIsoCode(
                                    country.isoCode)),
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25)),
                          ),
                          addSpaceWidth(10),
                          Flexible(
                            flex: 1,
                            fit: FlexFit.tight,
                            child: Text(
                              country.name,
                              style:
                                  textStyle(false, 18, black.withOpacity(.8)),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 10, right: 0),
                            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                            decoration: BoxDecoration(
                                color: black.withOpacity(.4),
                                borderRadius: BorderRadius.circular(5)),
                            child: Text(
                              "+${country.phoneCode}",
                              style: textStyle(true, 15, white),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          itemCount: listItems.length,
          shrinkWrap: true,
        )),
      ],
    );
  }
}
