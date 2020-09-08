import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maugost_apps/AddCountry.dart';
import 'package:maugost_apps/AppEngine.dart';

import 'assets.dart';

class CountryManager extends StatefulWidget {
  @override
  _ChoosecountryListtate createState() => _ChoosecountryListtate();
}

class _ChoosecountryListtate extends State<CountryManager> {
  bool setup = false;
  List countryList = [];
//  BaseModel selectedFarm;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadItems();
  }

  loadItems() async {
    countryList = appSettingsModel.getList(COUNTRY_LIST);
    setup = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: page(),
      backgroundColor: white,
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
                    size: 20,
                  )),
                )),
            Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Text(
                  "Country Manager",
                  style: textStyle(true, 25, black),
                )),
            addSpaceWidth(10),
            /*if(countryList.isNotEmpty)*/ FlatButton(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                color: dark_green0,
                onPressed: () {
                  pushAndResult(context, AddCountry(), result: (_) {
                    countryList.add(_);
                    setState(() {});
                  });
                },
                child: Text(
                  "Add Country",
                  style: textStyle(true, 14, white),
                )),
            addSpaceWidth(20),
          ],
        ),
        addSpace(10),
        Expanded(
            child: !setup
                ? loadingLayout()
                : countryList.isEmpty
                    ? emptyLayout(
                        Icons.flag,
                        "No Country Found",
                        "You have not added any country yet",
                        /* clickText: "Add Farm",click: (){
                           pushAndResult(context, CreateFarm(),result: (_){
                             countryList.add(_);
                             setState(() {});
                           });
                         }*/
                      )
                    : ListView.builder(
                        itemBuilder: (c, p) {
                          Map map = countryList[p];
                          String name = map[NAME];
                          String currency = map[CURRENCY];
                          String currencyLogo = map[CURRENCY_LOGO];
                          double to1Dollar = map[VALUE_TO_ONE_DOLLAR];
                          return GestureDetector(
                            onLongPress: () {
                              pushAndResult(
                                  context,
                                  AddCountry(
                                    item: map,
                                  ));
                            },
                            child: Card(
                              margin: EdgeInsets.all(10),
                              elevation: 5,
                              clipBehavior: Clip.antiAlias,
                              shadowColor: black.withOpacity(.1),
                              color: white,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  side: BorderSide(
                                      color: black.withOpacity(.1), width: .5)),
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                            fit: FlexFit.tight,
                                            child: Text(
                                              name,
                                              style:
                                                  textStyle(false, 25, black),
                                            )),
                                        addSpaceWidth(10),
                                        CachedNetworkImage(
                                          imageUrl: currencyLogo,
                                          width: 18,
                                          height: 18,
                                          fit: BoxFit.fill,
                                          //color: black.withOpacity(.5),
                                        ),
                                      ],
                                    ),
                                    addSpace(10),
                                    Row(
                                      children: [
                                        Text(
                                          currency,
                                          style: textStyle(true, 14, blue0),
                                        ),
                                        addSpaceWidth(5),
                                        Text(
                                          "$to1Dollar",
                                          style: textStyle(true, 14, black),
                                        ),
                                        addSpaceWidth(5),
                                        Text(
                                          "= 1 USD",
                                          style: textStyle(true, 14, blue0),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.all(0),
                        itemCount: countryList.length,
                      ))
      ],
    );
  }
}
