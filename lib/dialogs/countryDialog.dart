import 'dart:ui';

import 'package:country_pickers/countries.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/assets.dart';

class countryDialog extends StatefulWidget {
  @override
  _countryDialogState createState() => _countryDialogState();
}

class _countryDialogState extends State<countryDialog> {
  BuildContext context;
  TextEditingController searchController = TextEditingController();

  bool setup = false;
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
    this.context = context;
    return Scaffold(
      backgroundColor: transparent,
      body: Stack(fit: StackFit.expand, children: <Widget>[
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
              child: Container(
                color: black.withOpacity(.7),
              )),
        ),
        page()
      ]),
    );
  }

  page() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25, 45, 25, 25),
        child: new Container(
          decoration: BoxDecoration(
              color: white, borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Container(
                  width: double.infinity,
                  child: new Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      addSpaceWidth(15),
                      Image.asset(
                        ic_launcher,
                        height: 14,
                        width: 14,
                      ),
                      addSpaceWidth(10),
                      new Flexible(
                        flex: 1,
                        child: new Text(
                          "Your Country",
                          style: textStyle(true, 14, black),
                        ),
                      ),
                      addSpaceWidth(15),
                    ],
                  ),
                ),
                addSpace(5),
                Container(
                  height: 45,
                  margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  decoration: BoxDecoration(
                      color: white.withOpacity(.8),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                          color: app_blue.withOpacity(.5), width: 1)),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    //mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      addSpaceWidth(10),
                      Icon(
                        Icons.search,
                        color: app_blue.withOpacity(.5),
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
                addLine(.5, black.withOpacity(.1), 0, 0, 0, 0),
                Flexible(
                  fit: FlexFit.loose,
                  child: Container(
                    color: white,
                    child: new ConstrainedBox(
                      constraints: BoxConstraints(
                          maxHeight: (MediaQuery.of(context).size.height / 2) +
                              (MediaQuery.of(context).orientation ==
                                      Orientation.landscape
                                  ? 0
                                  : (MediaQuery.of(context).size.height / 5))),
                      child: Scrollbar(
                        child: new ListView.builder(
                          padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                          itemBuilder: (context, position) {
                            Country country = listItems[position];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                position == 0
                                    ? Container()
                                    : addLine(
                                        .5, black.withOpacity(.1), 0, 0, 0, 0),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context)
                                        .pop(listItems[position]);
                                  },
                                  child: new Container(
                                    color: white,
                                    width: double.infinity,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 15, 0, 15),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          CountryPickerUtils
                                              .getDefaultFlagImage(
                                                  CountryPickerUtils
                                                      .getCountryByIsoCode(
                                                          country.isoCode)),
                                          addSpaceWidth(10),
                                          Flexible(
                                            flex: 1,
                                            fit: FlexFit.tight,
                                            child: Text(
                                              country.name,
                                              style: textStyle(false, 18,
                                                  black.withOpacity(.8)),
                                            ),
                                          ),
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
                        ),
                      ),
                    ),
                  ),
                ),
                addLine(.5, black.withOpacity(.1), 0, 0, 0, 0),

                //gradientLine(alpha: .1)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
