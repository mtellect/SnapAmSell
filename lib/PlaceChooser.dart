import 'dart:async';
import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

import 'AppEngine.dart';
import 'assets.dart';
import 'basemodel.dart';
import 'dialogs/inputDialog.dart';

/// The result returned after completing location selection.
class LocationResult {
  /// The human readable name of the location. This is primarily the
  /// name of the road. But in cases where the place was selected from Nearby
  /// places list, we use the <b>name</b> provided on the list item.
  String name; // or road

  /// The human readable locality of the location.
  String locality;

  /// Latitude/Longitude of the selected location.
  LatLng latLng;

  /// Formatted address suggested by Google
  String formattedAddress;

  String placeId;
}

/// Nearby place data will be deserialized into this model.
class NearbyPlace {
  /// The human-readable name of the location provided. This value is provided
  /// for [LocationResult.name] when the user selects this nearby place.
  String name;

  /// The icon identifying the kind of place provided. Eg. lodging, chapel,
  /// hospital, etc.
  String icon;

  // Latitude/Longitude of the provided location.
  LatLng latLng;
}

/// Autocomplete results item returned from Google will be deserialized
/// into this model.
class AutoCompleteItem {
  /// The id of the place. This helps to fetch the lat,lng of the place.
  String id;

  /// The text (name of place) displayed in the autocomplete suggestions list.
  String text;

  /// Assistive index to begin highlight of matched part of the [text] with
  /// the original query
  int offset;

  /// Length of matched part of the [text]
  int length;
}

/// Place picker widget made with map widget from
/// [google_maps_flutter](https://github.com/flutter/plugins/tree/master/packages/google_maps_flutter)
/// and other API calls to [Google Places API](https://developers.google.com/places/web-service/intro)
///
/// API key provided should have `Maps SDK for Android`, `Maps SDK for iOS`
/// and `Places API`  enabled for it
class PlaceChooser extends StatefulWidget {
  /// API key generated from Google Cloud Console. You can get an API key
  /// [here](https://cloud.google.com/maps-platform/)

  bool singlePlace;
  PlaceChooser({this.singlePlace=true});

  @override
  State<StatefulWidget> createState() {
    return PlaceChooserState();
  }
}

/// Place picker state
class PlaceChooserState extends State<PlaceChooser> {
  /// Initial waiting location for the map before the current user location
  /// is fetched.
  final String apiKey ="AIzaSyDXqqm4xYxWk6mTPgKg6GXsJIG2Ah8MT1U";

  static final LatLng initialTarget = LatLng(5.5911921, -0.3198162);

  final Completer<GoogleMapController> mapController = Completer();

  /// Indicator for the selected location
  List searchResults = [];
  final Set<Marker> markers = Set()
    ..add(
      Marker(
        position: initialTarget,
        markerId: MarkerId("selected-location"),
      ),
    );

  /// Result returned after user completes selection
  LocationResult locationResult;

  /// Overlay to display autocomplete suggestions
  OverlayEntry overlayEntry;

  List<NearbyPlace> nearbyPlaces = List();

  /// Session token required for autocomplete API call
  String sessionToken = getRandomId();

  GlobalKey appBarKey = GlobalKey();

  bool hasSearchTerm = false;

  String previousSearchTerm = '';

  Map<PolylineId, Polyline> polylines = <PolylineId, Polyline>{};
  int _polylineIdCounter = 1;

  List<LatLng> allPoints = [];

  // Values when toggling polyline pattern
  bool canSelect = false;
  bool showTip = false;
  bool ready = false;
  double mapZoom = 15;

  // constructor
  PlaceChooserState();
  bool singlePlace;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    singlePlace = widget.singlePlace;
  }

  void onMapCreated(GoogleMapController controller) {
    this.mapController.complete(controller);
    moveToCurrentUserLocation();
  }

  void _add() {
    final int polylineCount = polylines.length;

    if (polylineCount == 12) {
      return;
    }

    final String polylineIdVal = 'polyline_id_$_polylineIdCounter';
    _polylineIdCounter++;
    final PolylineId polylineId = PolylineId(polylineIdVal);

    final Polyline polyline = Polyline(
      polylineId: polylineId,
      consumeTapEvents: true,
      color: Colors.orange,
      width: 5,
      points: _createPoints(),
      onTap: () {
//        _onPolylineTapped(polylineId);
        var polyline = polylines[polylineId];
        var lat = polyline.points[0].latitude;
        var lon = polyline.points[0].longitude;
        allPoints.add(LatLng(lat,lon));
        _add();
      },
    );

    setState(() {
      polylines[polylineId] = polyline;
    });
  }

  @override
  void setState(fn) {
    if (this.mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    this.overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        key: this.appBarKey,
        title: SearchInput((it) {
          searchPlace(it);
        }),
        centerTitle: true,backgroundColor: app_blue,
        leading: null,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Stack(
              children: <Widget>[
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: initialTarget,
                    zoom: mapZoom,
                  ),
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  onMapCreated: onMapCreated,
                  markers: markers,
                  polylines: Set<Polyline>.of(polylines.values),
                  onTap: (l){
                    getLocationNameFromLat(l.latitude,l.longitude,(s)=>print("Place Name: $s"));
                    if(!canSelect){
                      clearOverlay();
                      moveToLocation(l);
                      return;
                    }
                    if(markers.isEmpty && allPoints.isEmpty){
                      markers.add(Marker(position: l,markerId: MarkerId("selected-location")));
                      allPoints.add(l);
                      _add();
                      return;
                    }
                    markers.clear();
                    allPoints.add(l);
                    _add();
                  },
                ),
                if(showTip)AnimatedOpacity(
                  duration: Duration(seconds:1),curve: Curves.ease,opacity: showTip?(1):0,
                  child: GestureDetector(
                    onTap: (){
                      showTip = false;
                      setState((){});
                    },
                    child: Container(
                        color:black.withOpacity(.8),padding: EdgeInsets.all(10),
                        child:Center(
                            child:Text("Tap different points on the map to select an area",style: textStyle(false,25,white),
                              textAlign: TextAlign.center,)
                        )
                    ),
                  ),
                )
              ],
            ),
          ),
          !canSelect? Container(
            height: 40,width: double.infinity,margin:EdgeInsets.all(10),
            child: FlatButton(onPressed: (){
              if(singlePlace){

                return;
              }
              restart();
            },color: blue6,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              child: Text(singlePlace?"OK":"Start Selection",style: textStyle(true,15,white),),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(25))),
            ),
          ):
          Container(
            margin:EdgeInsets.all(10),width: double.infinity,
            child: Row(
                children:[
                  Flexible(flex:1,fit:FlexFit.tight,child:Container(
                    height: 40,
                    child: FlatButton(onPressed: (){
                      if(allPoints.length<2){
                        toastInAndroid("Tap at least 2 points on the map");
                        return;
                      }

                      /*pushAndResult(context, MapInfo(),result: (_){
                        showProgress(true, context,msg: "Adding Map");
                        BaseModel model = new BaseModel();
                        model.put(MAP_NAME, _[0]);
                        model.put(SOULS_REQUIRED, int.parse(_[1].toString()));
                        model.put(MAP_POINTS, getPoints());
//                        model.put(MAP_ZOOM, mapController.future.then(onValue))
                        model.put(BRANCH_ID, userModel.getString(BRANCH_ID));
                        model.saveItem(MAP_BASE, true);

                        Future.delayed((Duration(seconds: 3)),(){
                          showProgress(false, context);
                          Future.delayed((Duration(milliseconds: 500)),(){
                            Navigator.pop(context,model);
                          });
                        });
                      });*/
                    },color: blue3,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      child: Text("OK",style: textStyle(true,15,white),),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(25))),
                    ),
                  )),
                  addSpaceWidth(10),
                  Flexible(flex:1,fit:FlexFit.tight,child:Container(
                    height: 40,
                    child: FlatButton(onPressed: (){
                      restart();
                    },color: red0,shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(25))),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      child: Text("Restart",style: textStyle(true,15,white),),
                    ),
                  ))
                ]
            ),
          ),
          this.hasSearchTerm
              ? SizedBox()
              : Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  child: Text(
                    "Nearby Places",
                    style: textStyle(true, 16, black),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                ),
                addLine(.5, black.withOpacity(.1), 20, 0, 20, 0),
                Expanded(
                  child: ListView(
                    children: this
                        .nearbyPlaces
                        .map((it) => NearbyPlaceItem(it, () {
                      moveToLocation(it.latLng);
                    }))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Hides the autocomplete overlay
  void clearOverlay() {
    if (this.overlayEntry != null) {
      this.overlayEntry.remove();
      this.overlayEntry = null;
    }
  }

  /// Begins the search process by displaying a "wait" overlay then
  /// proceeds to fetch the autocomplete list. The bottom "dialog"
  /// is hidden so as to give more room and better experience for the
  /// autocomplete list overlay.
  void searchPlace(String place) {
    // on keyboard dismissal, the search was being triggered again
    // this is to cap that.
    if (place == this.previousSearchTerm) {
      return;
    } else {
      previousSearchTerm = place;
    }

    if (context == null) {
      return;
    }

    clearOverlay();

    setState(() {
      hasSearchTerm = place.length > 0;
    });

    if (place.length < 1) {
      return;
    }

    final RenderBox renderBox = context.findRenderObject();
    Size size = renderBox.size;

    final RenderBox appBarBox =
    this.appBarKey.currentContext.findRenderObject();

    this.overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: appBarBox.size.height,
        width: size.width,
        child: Material(
          elevation: 1,
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 24,
            ),
            color: Colors.white,
            child: Row(
              children: <Widget>[
                SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                  ),
                ),
                SizedBox(
                  width: 24,
                ),
                Expanded(
                  child: Text(
                    "Finding place...",
                    style: textStyle(true, 16, black),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(this.overlayEntry);

    autoCompleteSearch(place);
  }

  /// Fetches the place autocomplete list with the query [place].
  void autoCompleteSearch(String place) {
    place = place.replaceAll(" ", "+");
    var endpoint =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?" +
            "key=${apiKey}&" +
            "input={$place}&sessiontoken=${this.sessionToken}";

    if (this.locationResult != null) {
      endpoint += "&location=${this.locationResult.latLng.latitude}," +
          "${this.locationResult.latLng.longitude}";
    }
    http.get(endpoint).then((response) {
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> predictions = data['predictions'];

        List<RichSuggestion> suggestions = [];

        if (predictions.isEmpty) {
          AutoCompleteItem aci = AutoCompleteItem();
          aci.text = "No result found";
          aci.offset = 0;
          aci.length = 0;

          suggestions.add(RichSuggestion(aci, () {}));
        } else {
          for (dynamic t in predictions) {
            AutoCompleteItem aci = AutoCompleteItem();

            aci.id = t['place_id'];
            aci.text = t['description'];
            aci.offset = t['matched_substrings'][0]['offset'];
            aci.length = t['matched_substrings'][0]['length'];

            BaseModel model = BaseModel();
            model.put(PLACE_NAME,aci.text);
            model.put(OBJECT_ID,aci.id);
            searchResults.add(model);
//            suggestions.add(RichSuggestion(aci, () {
//              FocusScope.of(context).requestFocus(FocusNode());
//              decodeAndSelectPlace(aci.text,aci.id);
//
//            }));
          }
        }

        setState(() {});
//        displayAutoCompleteSuggestions(suggestions);
      }
    }).catchError((error) {
      print(error);
    });
  }

  void getLocationNameFromLat(lat,lon,onComplete(String name)) {
    var endpoint =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?" +
            "key=${apiKey}&" +
            "sessiontoken=${this.sessionToken}";

    if (this.locationResult != null) {
      endpoint += "&location=${this.locationResult.latLng.latitude}," +
          "${this.locationResult.latLng.longitude}";
    }
    http.get(endpoint).then((response) {
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> predictions = data['predictions'];
        String name = "";
        if(predictions.isNotEmpty){
          for (dynamic t in predictions) {
          name = t['description'];
         break;
        }
        onComplete(name);
      }
    }
    }).catchError((error) {
      print(error);
    });
  }


  /// To navigate to the selected place from the autocomplete list to the map,
  /// the lat,lng is required. This method fetches the lat,lng of the place and
  /// proceeds to moving the map to that location.
  void decodeAndSelectPlace(String name,String placeId) {
    clearOverlay();
    showProgress(true, context);
    String endpoint =
        "https://maps.googleapis.com/maps/api/place/details/json?key=${apiKey}" +
            "&placeid=$placeId";

    http.get(endpoint).then((response) {
      showProgress(false,context);
      if (response.statusCode == 200) {
        Map<String, dynamic> location =
        jsonDecode(response.body)['result']['geometry']['location'];

        LatLng latLng = LatLng(location['lat'], location['lng']);

        BaseModel model = BaseModel();
        model.put(PLACE_NAME, name);
        model.put(OBJECT_ID, placeId);
        model.put(LATITUDE, latLng.latitude);
        model.put(LONGITUDE, latLng.longitude);
        Future.delayed(Duration(milliseconds: 500),(){
          Navigator.pop(context,model);
        });

      }
    }).catchError((error) {
      print(error);
      showProgress(false,context);
    });
  }

  /// Display autocomplete suggestions with the overlay.
  void displayAutoCompleteSuggestions(List<RichSuggestion> suggestions) {
    final RenderBox renderBox = context.findRenderObject();
    Size size = renderBox.size;

    final RenderBox appBarBox =
    this.appBarKey.currentContext.findRenderObject();

    clearOverlay();

    this.overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        top: appBarBox.size.height,
        child: Material(
          elevation: 1,
          color: Colors.white,
          child: Column(
            children: suggestions,
          ),
        ),
      ),
    );

    Overlay.of(context).insert(this.overlayEntry);
  }

  /// Moves the marker to the indicated lat,lng
  void setMarker(LatLng latLng) {
    // markers.clear();
    setState(() {
      markers.clear();
      markers.add(
        Marker(
          markerId: MarkerId("selected-location"),
          position: latLng,
        ),
      );
    });
  }

  /// Fetches and updates the nearby places to the provided lat,lng
  void getNearbyPlaces(LatLng latLng) {
    http
        .get("https://maps.googleapis.com/maps/api/place/nearbysearch/json?" +
        "key=${apiKey}&" +
        "location=${latLng.latitude},${latLng.longitude}&radius=150")
        .then((response) {
      if (response.statusCode == 200) {
        this.nearbyPlaces.clear();
        for (Map<String, dynamic> item
        in jsonDecode(response.body)['results']) {
          NearbyPlace nearbyPlace = NearbyPlace();

          nearbyPlace.name = item['name'];
          nearbyPlace.icon = item['icon'];
          double latitude = item['geometry']['location']['lat'];
          double longitude = item['geometry']['location']['lng'];

          LatLng _latLng = LatLng(latitude, longitude);

          nearbyPlace.latLng = _latLng;

          this.nearbyPlaces.add(nearbyPlace);
        }
      }

      // to update the nearby places
      setState(() {
        // this is to require the result to show
        this.hasSearchTerm = false;
      });
    }).catchError((error) {});
  }

  /// This method gets the human readable name of the location. Mostly appears
  /// to be the road name and the locality.
  void reverseGeocodeLatLng(LatLng latLng) {
    http
        .get("https://maps.googleapis.com/maps/api/geocode/json?" +
        "latlng=${latLng.latitude},${latLng.longitude}&" +
        "key=${apiKey}")
        .then((response) {
      if (response.statusCode == 200) {
        Map<String, dynamic> responseJson = jsonDecode(response.body);

        final result = responseJson['results'][0];

        String road = result['address_components'][0]['short_name'];
        String locality = result['address_components'][1]['short_name'];

        setState(() {
          this.locationResult = LocationResult();
          this.locationResult.name = road;
          this.locationResult.locality = locality;
          this.locationResult.latLng = latLng;
          this.locationResult.formattedAddress = result['formatted_address'];
          this.locationResult.placeId = result['place_id'];
        });
      }
    }).catchError((error) {
      print(error);
    });
  }

  /// Moves the camera to the provided location and updates other UI features to
  /// match the location.
  void moveToLocation(LatLng latLng) {
    this.mapController.future.then((controller) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: latLng,
            zoom: mapZoom,
          ),
        ),
      );
    });

    setMarker(latLng);

    reverseGeocodeLatLng(latLng);

    getNearbyPlaces(latLng);
  }

  void moveToCurrentUserLocation() {
    var location = Location();
    location.getLocation().then((locationData) {
      LatLng target = LatLng(locationData.latitude, locationData.longitude);
      moveToLocation(target);
    }).catchError((error) {
      // TODO: Handle the exception here
      print(error);
    });
  }

  restart(){
    markers.clear();
    allPoints.clear();
    polylines.clear();
    canSelect = true;
    showTip = true;
    setState((){});

    Future.delayed(Duration(seconds: 3),(){
      showTip = false;
      setState((){});
    });

  }

  getPoints(){
    Map map = Map();
    int counter = 0;
    for(LatLng l in allPoints){
      List item = [l.latitude,l.longitude];
      map["$counter"] = item;
      counter++;
    }
    return map;
  }

  List<LatLng> _createPoints() {
    final List<LatLng> points = <LatLng>[];
    final double offset = _polylineIdCounter.ceilToDouble();
    for(LatLng l in allPoints){
      points.add(l);
    }
    return points;
  }
}

/// Custom Search input field, showing the search and clear icons.
class SearchInput extends StatefulWidget {
  final ValueChanged<String> onSearchInput;

  SearchInput(this.onSearchInput);

  @override
  State<StatefulWidget> createState() {
    return SearchInputState();
  }
}

class SearchInputState extends State<SearchInput> {
  TextEditingController editController = TextEditingController();

  Timer debouncer;

  bool hasSearchEntry = false;

  SearchInputState();

  @override
  void initState() {
    super.initState();
    this.editController.addListener(this.onSearchInputChange);
  }

  @override
  void dispose() {
    this.editController.removeListener(this.onSearchInputChange);
    this.editController.dispose();

    super.dispose();
  }

  void onSearchInputChange() {
    if (this.editController.text.isEmpty) {
      this.debouncer?.cancel();
      widget.onSearchInput(this.editController.text);
      return;
    }

    if (this.debouncer?.isActive ?? false) {
      this.debouncer.cancel();
    }

    this.debouncer = Timer(Duration(milliseconds: 500), () {
      widget.onSearchInput(this.editController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8,
      ),
      child: Column(
        children: [
          Row(
            children: <Widget>[
              Icon(
                Icons.search,
                color: Colors.black,
              ),
              SizedBox(
                width: 8,
              ),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search place",isDense: true,
                    border: InputBorder.none,
                    hintStyle: textStyle(false, 18, black.withOpacity(.4)),
                  ),
                  controller: this.editController,
                  style: textStyle(false, 16, black),
                  onChanged: (value) {
                    setState(() {
                      this.hasSearchEntry = value.isNotEmpty;
                    });
                  },
                ),
              ),
              SizedBox(
                width: 8,
              ),
              this.hasSearchEntry
                  ? GestureDetector(
                child: Icon(Icons.clear, color: black),
                onTap: () {
                  this.editController.clear();
                  setState(() {
                    this.hasSearchEntry = false;
                  });
                },
              )
                  : SizedBox(),
            ],
          ),
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: white,
      ),
    );
  }
}

class SelectPlaceAction extends StatelessWidget {
  final String locationName;
  final VoidCallback onTap;

  SelectPlaceAction(this.locationName, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: blue4,
      child: InkWell(
        onTap: () {
          this.onTap();
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      locationName,
                      style: textStyle(true, 16, white),
                    ),
                    Text(
                      "Tap to select this location",
                      style: textStyle(false, 13, white.withOpacity(.5)),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward,
                color: white,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class NearbyPlaceItem extends StatelessWidget {
  final NearbyPlace nearbyPlace;
  final VoidCallback onTap;

  NearbyPlaceItem(this.nearbyPlace, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            child: Row(
              children: <Widget>[
                Image.network(
                  nearbyPlace.icon,
                  width: 16,
                ),
                SizedBox(
                  width: 24,
                ),
                Expanded(
                  child: Text(
                    "${nearbyPlace.name}",
                    style: textStyle(true, 16, black),
                  ),
                )
              ],
            )),
      ),
    );
  }
}

class RichSuggestion extends StatelessWidget {
  final VoidCallback onTap;
  final AutoCompleteItem autoCompleteItem;

  RichSuggestion(this.autoCompleteItem, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            color: white,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: RichText(
                    text: TextSpan(children: getStyledTexts(context)),
                  ),
                )
              ],
            )),
        onTap: this.onTap,
      ),
    );
  }

  List<TextSpan> getStyledTexts(BuildContext context) {
    final List<TextSpan> result = [];

    String startText =
    this.autoCompleteItem.text.substring(0, this.autoCompleteItem.offset);
    if (startText.isNotEmpty) {
      result.add(
        TextSpan(
          text: startText,
          style: textStyle(false, 15, black.withOpacity(.7)),
        ),
      );
    }

    String boldText = this.autoCompleteItem.text.substring(
        this.autoCompleteItem.offset,
        this.autoCompleteItem.offset + this.autoCompleteItem.length);

    result.add(TextSpan(
      text: boldText,
      style: textStyle(true, 15, black),
    ));

    String remainingText = this
        .autoCompleteItem
        .text
        .substring(this.autoCompleteItem.offset + this.autoCompleteItem.length);
    result.add(
      TextSpan(
        text: remainingText,
        style: textStyle(true, 15, black),
      ),
    );

    return result;
  }

}
