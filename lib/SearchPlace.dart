import 'dart:convert';
import 'dart:ui';

import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/AppConfig.dart';
import 'package:maugost_apps/assets.dart';
import 'package:maugost_apps/basemodel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong/latlong.dart';

class SearchPlace extends StatefulWidget {
  @override
  _SearchPlaceState createState() => _SearchPlaceState();
}

class _SearchPlaceState extends State<SearchPlace> {
  TextEditingController searchController = TextEditingController();
  List searchResults = [];
  bool _progressLoading = false;
  bool _showCancel = false;
//  bool _noResultFound = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

/*     searchController.addListener(() {
       String text = searchController.text;
       if (text.trim().isEmpty) {
         if (_showCancel)
           setState(() {
             searchResults.clear();
             _progressLoading=false;
             _showCancel = false;
           });

         return;
       }
       createSearchHandler();
     });*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      backgroundColor: Colors.transparent,
    );
  }

  page() {
    return new Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        new Container(
//              height: 60,
          color: AppConfig.appColor,
          padding: EdgeInsets.fromLTRB(0, 40, 0, 10),
          child: Row(
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
                      color: white,
                      size: 25,
                    )),
                  )),
              Flexible(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      //mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        addSpaceWidth(10),
                        Icon(
                          Icons.search,
                          color: AppConfig.appColor.withOpacity(.5),
                          size: 17,
                        ),
                        addSpaceWidth(10),
                        new Flexible(
                          flex: 1,
                          child: new TextField(
                            textInputAction: TextInputAction.search,
                            textCapitalization: TextCapitalization.sentences,
                            autofocus: true,
                            onSubmitted: (_) {
                              //search();
                            },
                            onChanged: (_) {
                              if (_.trim().isEmpty) {
                                setState(() {
                                  _progressLoading = false;
                                  searchResults.clear();
                                });
                                return;
                              }
                              createSearchHandler();
                            },
                            decoration: InputDecoration(
                              hintText: "Search place",
                              hintStyle: textStyle(
                                false,
                                18,
                                black.withOpacity(.5),
                              ),
                              isDense: true,
                              border: InputBorder.none,
                            ),
                            style: textStyle(false, 18, black),
                            controller: searchController,
                            cursorColor: black,
                            cursorWidth: 1,
                            keyboardType: TextInputType.text,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              searchResults.clear();
//                               _noResultFound = false;
                              searchController.text = "";
                            });
                          },
                          child: _showCancel
                              ? Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 15, 0),
                                  child: Icon(
                                    Icons.close,
                                    color: AppConfig.appColor,
                                    size: 20,
                                  ),
                                )
                              : new Container(),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        Expanded(
            flex: 1,
            child: _progressLoading
                ? loadingLayout(trans: true)
                : ListView.builder(
                    padding: EdgeInsets.only(top: 20),
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, position) {
                      BaseModel bm = searchResults[position];
                      return GestureDetector(
                        onTap: () {
                          decodeAndSelectPlace(
                              bm.getString(PLACE_NAME), bm.getObjectId());
                        },
                        child: Container(
                          margin: EdgeInsets.fromLTRB(20, 0, 10, 10),
                          child: Card(
                            color: white,
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Text(
                                bm.getString(PLACE_NAME),
                                style: textStyle(false, 20, black),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    shrinkWrap: true,
                    itemCount: searchResults.length,
                  ))
      ],
    );
  }

  void decodeAndSelectPlace(String name, String placeId) {
    showProgress(true, context);
    String endpoint =
        "https://maps.googleapis.com/maps/api/place/details/json?key=${apiKey}" +
            "&placeid=$placeId";

    http.get(endpoint).then((response) {
      showProgress(false, context);
      if (response.statusCode == 200) {
        Map<String, dynamic> location =
            jsonDecode(response.body)['result']['geometry']['location'];

        LatLng latLng = LatLng(location['lat'], location['lng']);

        BaseModel model = BaseModel();
        model.put(PLACE_NAME, name);
        model.put(OBJECT_ID, placeId);
        model.put(LATITUDE, latLng.latitude);
        model.put(LONGITUDE, latLng.longitude);
        Future.delayed(Duration(milliseconds: 500), () {
          Navigator.pop(context, model);
        });
      }
    }).catchError((error) {
      print(error);
      showProgress(false, context);
    });
  }

  bool handlerSet = false;
  void createSearchHandler() {
    _showCancel = true;
    _progressLoading = true;
    setState(() {});
    if (handlerSet) return;
    handlerSet = true;

    Future.delayed(Duration(seconds: 2), () {
      runSearch();
      handlerSet = false;
    });
  }

  final String apiKey = "AIzaSyDXqqm4xYxWk6mTPgKg6GXsJIG2Ah8MT1U";
  void runSearch() async {
    searchResults.clear();
    String place = searchController.text.trim().toLowerCase();
    String sessionToken = getRandomId();
    if (place.isEmpty) {
      _progressLoading = false;
      return;
    }

    var endpoint =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?" +
            "key=${apiKey}&" +
            "input={$place}&sessiontoken=${sessionToken}";

    http.get(endpoint).then((response) {
      _progressLoading = false;
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> predictions = data['predictions'];

        for (dynamic t in predictions) {
          BaseModel model = BaseModel();
          model.put(PLACE_NAME, t['description']);
          model.put(OBJECT_ID, t['place_id']);
//          print("Search.... ${t['terms']}");
          List terms = List.from(t['terms']);
          String country = terms[terms.length - 1]["value"];
//          print("Search..2.. $country");
          model.put(COUNTRY, country);

          searchResults.add(model);
        }
//        _noResultFound = searchResults.isEmpty;
        setState(() {});
      }
    }).catchError((error) {
      _progressLoading = false;
      print(error);
    });
  }
}
