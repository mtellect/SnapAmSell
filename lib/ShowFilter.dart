import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:maugost_apps/AppConfig.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/SelectRegion.dart';
import 'package:maugost_apps/assets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ChooseProductCategory.dart';

class ShowFilter extends StatefulWidget {
  final String categoryId;

  const ShowFilter({Key key, this.categoryId = ''}) : super(key: key);
  @override
  _ShowFilterState createState() => _ShowFilterState();
}

class _ShowFilterState extends State<ShowFilter> {
//  String state ="";
//  String city ="";
//  bool splittable = false;
//  int sortType =0;

  final price1Controller = new MoneyMaskedTextController(
      decimalSeparator: ".", thousandSeparator: ",");
  final price2Controller = new MoneyMaskedTextController(
      decimalSeparator: ".", thousandSeparator: ",");

//  Map sortMap = {};
//  String category = "";

  reset() {
    price1Controller.clear();
    price2Controller.clear();
    FILTER_SPLITTABLE = false;
    FILTER_MIN_PRICE = 0;
    FILTER_MAX_PRICE = 0;
    FILTER_SORT_TYPE = 0;
    setState(() {});
  }

  checkDraft() async {
    if (FILTER_MIN_PRICE != 0) price1Controller.updateValue(FILTER_MIN_PRICE);
    if (FILTER_MAX_PRICE != 0) price2Controller.updateValue(FILTER_MAX_PRICE);
    setState(() {});
  }

  saveDraft() async {
    try {
      if (price1Controller.text.isNotEmpty) {
        FILTER_MIN_PRICE = price1Controller.numberValue;
      }
    } catch (e) {}
    ;
    try {
      if (price2Controller.text.isNotEmpty) {
        double max = price2Controller.numberValue;
        double min =
            price1Controller.text.isEmpty ? 0 : price1Controller.numberValue;
        if (max < min && max != 0) {
          showErrorDialog(context, "Max Price cannot be less than Min Price");
          return;
        }
        FILTER_MAX_PRICE = max;
      }
    } catch (e) {}
    Navigator.pop(context, true);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // try {
    //   price1Controller.text = "";
    // } catch (e) {}
    // try {
    //   price2Controller.text = "";
    // } catch (e) {}
    checkDraft();
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
        resizeToAvoidBottomInset: true, backgroundColor: white, body: page());
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
                  "Filter Results",
                  style: textStyle(true, 22, black),
                ),
              ),
              Container(
                height: 40,
//                            width: 0,
                child: FlatButton(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                                  padding: EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                        side: BorderSide(color: red0, width: 2)),
                    color: transparent,
                    onPressed: () {
                      yesNoDialog(context, "Clear", "Clear all filters", () {
                        reset();
                        saveDraft();
                      });
                    },
                    child: Text(
                      "Clear Filters",
                      style: textStyle(true, 15, red0),
                    )),
              ),
              addSpaceWidth(15)
            ],
          ),
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
                          addSpace(10),
                          clickText(
                              "Category",
                              //FILTER_CATEGORY.isEmpty ? "All" : FILTER_CATEGORY,
                              FILTER_SUB_CATEGORY.isEmpty &&
                                      FILTER_CATEGORY.isEmpty
                                  ? "All"
                                  : FILTER_SUB_CATEGORY.isEmpty
                                      ? "All"
                                      : "${FILTER_CATEGORY.isEmpty ? "All" : "$FILTER_SUB_CATEGORY in"} $FILTER_CATEGORY",
                              () {
                            pushAndResult(
                              context,
                              ChooseProductCategory(
                                [],
                                singleMode: true,
                                onlyMain: true,
                                popResult: true,
                                category: FILTER_CATEGORY,
                                subCategory: FILTER_SUB_CATEGORY,
                              ),
                              result: (List item) {
                                FILTER_CATEGORY = item[0] ?? "";
                                FILTER_SUB_CATEGORY = item[1] ?? "";
                                setState(() {});
                              },
                            );
                          }),
                          clickText(
                            "Region",
                            defaultState.isEmpty && defaultCity.isEmpty
                                ? "$defaultCountry"
                                : defaultState.isEmpty
                                    ? ""
                                    : "${defaultCity.isEmpty ? "" : "$defaultCity in"} $defaultState",
                            () {
                              pushAndResult(
                                  context,
                                  SelectRegion(
                                    selectedRegion: defaultCity,
                                    selectedState: defaultState,
                                    canSelectOnlyState: true,
                                  ), result: (_) async {
                                defaultState = _[0];
                                defaultCity = _[1];
                                SharedPreferences pref =
                                    await SharedPreferences.getInstance();
                                pref.setString(DEFAULT_STATE, defaultState);
                                pref.setString(DEFAULT_CITY, defaultCity);
                                setState(() {});
                              });
                            },
                          ),
                          Row(
                            children: [
                              Flexible(
                                fit: FlexFit.tight,
                                child: inputTextView(
                                    "Min Price", price1Controller,
                                    isNum: true,
                                    onEditted: () {},
                                    isAmount: true,
                                    useCurrentCountry: true),
                              ),
                              addSpaceWidth(15),
                              Flexible(
                                fit: FlexFit.tight,
                                child: inputTextView(
                                    "Max Price", price2Controller,
                                    isNum: true,
                                    onEditted: () {},
                                    isAmount: true,
                                    useCurrentCountry: true),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                FILTER_SPLITTABLE = !FILTER_SPLITTABLE;
                              });
                            },
                            child: Container(
                              height: 35,
                              margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
//                                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
//                                decoration: BoxDecoration(
//                                    border: Border.all(color: blue0, width: 2),color: transparent,
//                                    borderRadius: BorderRadius.circular(25)),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                        color: FILTER_SPLITTABLE
                                            ? light_green3
                                            : blue09,
                                        border: Border.all(
                                            color: light_green3, width: 1),
                                        shape: BoxShape.circle),
                                    child: FILTER_SPLITTABLE
                                        ? Center(
                                            child: Icon(
                                            Icons.check,
                                            color: white,
                                            size: 15,
                                          ))
                                        : Container(),
                                  ),
                                  addSpaceWidth(10),
                                  Flexible(
                                      flex: 1,
                                      fit: FlexFit.tight,
                                      child: Text(
                                        "Splittable",
                                        style:
                                            textStyle(true, 16, light_green3),
                                      )),
                                ],
                              ),
                            ),
                          ),
                          clickText("Sort Order", sortOrders[FILTER_SORT_TYPE],
                              () {
                            showListDialog(
                              context,
                              sortOrders,
                              (_) {
                                String s = _[0];
                                FILTER_SORT_TYPE = sortOrders.indexOf(s);
                                setState(() {});
                              },
                              selections: [sortOrders[FILTER_SORT_TYPE]],
                              //singleSelection: true,
                            );
                          }, icon: Icons.sort),
                          Container(
                            height: 50,
                            width: double.infinity,
                            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                            child: FlatButton(
                              onPressed: () {
                                saveDraft();
                              },
                              color: AppConfig.appColor,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25)),
                                // side: BorderSide(color: blue3,width: 2)
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                              child: Text(
                                "Apply Filter",
                                style: textStyle(true, 20, black),
                                maxLines: 1,
                              ),
                            ),
                          ),
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

  chooseProductCategory(List<dynamic> list, {bool singleMode, bool onlyMain}) {}
}
