library app;

import 'dart:ui';

import 'package:Strokes/AppEngine.dart';
import 'package:Strokes/app/currencies.dart';
import 'package:Strokes/app_config.dart';
import 'package:Strokes/assets.dart';
import 'package:camera/camera.dart';
import 'package:currency_pickers/currency_pickers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'countries.dart';

part 'countryChooser.dart';
part 'currencyChooser.dart';
// part 'dotsIndicator.dart';
// part 'gridCollage.dart';
// part 'infoDialog.dart';
// part 'inputDialog.dart';
// part 'listDialog.dart';
// part 'messageDialog.dart';
// part 'navigation.dart';
// part 'notificationService.dart';
// part 'placeChooser.dart';
// part 'preview_image.dart';
// part 'progressDialog.dart';
 part 'rating.dart';
// part 'unicons.dart';

class Countries {
  final String countryName;
  final String countryFlag;
  final String countryCode;

  Countries({this.countryName, this.countryFlag, this.countryCode});
}

class Currencies {
  final String symbol;
  final String name;
  final String symbolNative;
  final int decimalDigits;
  final rounding;
  final String code;
  final String namePlural;

  Currencies(
      {this.symbol,
      this.name,
      this.symbolNative,
      this.decimalDigits,
      this.rounding,
      this.code,
      this.namePlural});
}

List<Currencies> getCurrencies() {
  return currenciesMap.values
      .map((e) => Currencies(
          code: e["code"],
          decimalDigits: e["decimal_digits"],
          name: e["name"],
          namePlural: e["name_plural"],
          rounding: e["rounding"],
          symbol: e["symbol"],
          symbolNative: e["symbol_native"]))
      .toList();
}

List<Countries> getCountries() {
  return countryMap
      .map((c) => Countries(
          countryName: c["Name"],
          countryCode: '+${c["Code"]}',
          countryFlag: 'flags/${c["ISO"]}.png'))
      .toList();
}

Countries country =
    getCountries().singleWhere((e) => e.countryName == 'Nigeria');
List<CameraDescription> cameras = [];
